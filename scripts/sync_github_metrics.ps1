$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$dataPath = Join-Path $root "data/mainland-985.json"
$readmePath = Join-Path $root "README.md"
$beginMarker = "<!-- BEGIN:repo-table -->"
$endMarker = "<!-- END:repo-table -->"

$token = $env:GITHUB_TOKEN
if (-not $token) {
    $token = $env:GH_TOKEN
}
if (-not $token) {
    throw "GITHUB_TOKEN or GH_TOKEN is required."
}

$headers = @{
    Accept = "application/vnd.github+json"
    Authorization = "Bearer $token"
    "User-Agent" = "awesome-latex-thesis-template-sync"
    "X-GitHub-Api-Version" = "2022-11-28"
}

function Get-GitHubJson {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Url
    )

    Invoke-RestMethod -Uri $Url -Headers $headers
}

$syncedAt = [DateTime]::UtcNow.ToString("yyyy-MM-ddTHH:mm:ssZ")
$data = Get-Content $dataPath -Raw | ConvertFrom-Json -Depth 100

foreach ($school in $data) {
    foreach ($template in $school.templates) {
        $repoInfo = Get-GitHubJson -Url "https://api.github.com/repos/$($template.repo)"
        $commitInfo = Get-GitHubJson -Url "https://api.github.com/repos/$($template.repo)/commits?per_page=1"
        $lastCommitAt = ([DateTime]$commitInfo[0].commit.committer.date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")

        $template | Add-Member -NotePropertyName github_metrics -NotePropertyValue ([pscustomobject]@{
            stars = [int]$repoInfo.stargazers_count
            last_commit_at = $lastCommitAt
            last_synced_at = $syncedAt
        }) -Force
    }
}

$data | ConvertTo-Json -Depth 100 | Set-Content $dataPath -Encoding utf8NoBOM

$rows = foreach ($school in $data) {
    foreach ($template in $school.templates) {
        [pscustomobject]@{
            school_name_zh = $school.school_name_zh
            repo = $template.repo
            url = $template.url
            stars = [int]$template.github_metrics.stars
            last_commit_date = ([string]$template.github_metrics.last_commit_at).Substring(0, 10)
            maintenance_status = $template.maintenance_status
        }
    }
}

$sortedRows = $rows | Sort-Object @{ Expression = "stars"; Descending = $true }, school_name_zh, repo

$tableLines = @(
    "| 学校 | 仓库 | Stars | 最近提交 | 状态 |",
    "| --- | --- | ---: | --- | --- |"
)

foreach ($row in $sortedRows) {
    $repoLabel = $row.repo
    $tableLines += "| {0} | [`{1}`]({2}) | {3} | {4} | {5} |" -f $row.school_name_zh, $repoLabel, $row.url, $row.stars, $row.last_commit_date, $row.maintenance_status
}

$tableMarkdown = ($tableLines -join "`n")
$readme = Get-Content $readmePath -Raw
$pattern = "(?s)$([regex]::Escape($beginMarker)).*?$([regex]::Escape($endMarker))"
$replacement = "$beginMarker`n$tableMarkdown`n$endMarker"
$updatedReadme = [regex]::Replace($readme, $pattern, $replacement)
$updatedReadme | Set-Content $readmePath -Encoding utf8NoBOM
