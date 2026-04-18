$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $root "data/universities.json"
$readmePath = Join-Path $root "README.md"
$beginMarker = "<!-- BEGIN:repo-table -->"
$endMarker = "<!-- END:repo-table -->"
$minStars = 100
$minLastCommitAt = [DateTime]"2024-01-01T00:00:00Z"

function Format-DegreeTypes {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$DegreeTypes
    )

    $labels = foreach ($degreeType in $DegreeTypes) {
        switch ($degreeType) {
            "undergraduate" { "本科" }
            "master" { "硕士" }
            "doctoral" { "博士" }
            default { $degreeType }
        }
    }

    ($labels | Select-Object -Unique) -join " / "
}

function Get-GitHubJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $json = gh api $Path --header "Accept: application/vnd.github+json" --header "X-GitHub-Api-Version: 2022-11-28"
    if (-not $json) {
        throw "Empty response from gh api for $Path"
    }
    $json | ConvertFrom-Json
}

$syncedAt = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
$data = Get-Content $dataPath -Raw | ConvertFrom-Json -Depth 100

$retainedSchools = @()

foreach ($school in $data) {
    $retainedTemplates = @()
    foreach ($template in $school.templates) {
        $repoInfo = Get-GitHubJson -Path "/repos/$($template.repo)"
        $commitInfo = Get-GitHubJson -Path "/repos/$($template.repo)/commits?per_page=1"
        $lastCommitAtUtc = ([DateTime]$commitInfo[0].commit.committer.date).ToUniversalTime()
        $lastCommitAt = $lastCommitAtUtc.ToString("yyyy-MM-ddTHH:mm:ssZ")
        $stars = [int]$repoInfo.stargazers_count

        $template | Add-Member -NotePropertyName github_metrics -NotePropertyValue ([pscustomobject]@{
            stars = $stars
            last_commit_at = $lastCommitAt
            last_synced_at = $syncedAt
        }) -Force

        if ($stars -ge $minStars -and $lastCommitAtUtc -ge $minLastCommitAt) {
            $retainedTemplates += [pscustomobject]@{
                repo = $template.repo
                degree_types = @($template.degree_types)
                github_metrics = [pscustomobject]@{
                    stars = $stars
                    last_commit_at = $lastCommitAt
                    last_synced_at = $syncedAt
                }
            }
        }
    }

    if ($retainedTemplates.Count -gt 0) {
        $retainedSchools += [pscustomobject]@{
            school_id = $school.school_id
            school_name_zh = $school.school_name_zh
            templates = @($retainedTemplates)
        }
    }
}

$retainedSchools | ConvertTo-Json -Depth 100 | Set-Content $dataPath -Encoding utf8NoBOM

$rows = foreach ($school in $retainedSchools) {
    foreach ($template in $school.templates) {
        [pscustomobject]@{
            school_name_zh = $school.school_name_zh
            repo = $template.repo
            url = "https://github.com/$($template.repo)"
            degree_types = Format-DegreeTypes -DegreeTypes @($template.degree_types)
            stars = [int]$template.github_metrics.stars
            last_commit_date = ([string]$template.github_metrics.last_commit_at).Substring(0, 10)
        }
    }
}

$sortedRows = $rows | Sort-Object @{ Expression = "stars"; Descending = $true }, school_name_zh, repo

$tableLines = @(
    "| 学校 | 仓库 | 学位类型 | Stars | 最近提交 |",
    "| --- | --- | --- | ---: | --- |"
)

foreach ($row in $sortedRows) {
    $repoLabel = $row.repo
    $tableLines += "| {0} | [`{1}`]({2}) | {3} | {4} | {5} |" -f $row.school_name_zh, $repoLabel, $row.url, $row.degree_types, $row.stars, $row.last_commit_date
}

$tableMarkdown = ($tableLines -join "`n")
$readme = Get-Content $readmePath -Raw
$pattern = "(?s)$([regex]::Escape($beginMarker)).*?$([regex]::Escape($endMarker))"
$replacement = "$beginMarker`n$tableMarkdown`n$endMarker"
$updatedReadme = [regex]::Replace($readme, $pattern, $replacement)
$updatedReadme | Set-Content $readmePath -Encoding utf8NoBOM
