# 中国内地 985 高校学位论文 LaTeX 模板收录

这是一个面向中国内地 `985` 高校的 GitHub 托管 LaTeX 学位论文模板索引项目。

当前收录范围：

- 仅收录中国内地 `985` 高校
- 仅收录学位论文 / 毕业设计 / 毕业论文模板
- 仅收录 GitHub 仓库
- 以学校为单位建立索引，并保留仓库级证据说明

本项目采取保守收录策略。只有在人工确认至少一个符合条件的 GitHub 仓库后，学校状态才会标记为 `covered`。

## 当前概览

- 跟踪学校数：`39`
- 已收录至少一个仓库的学校数：`32`
- 首轮检索后仍未确认的学校数：`7`

## 当前未确认学校

- 北京大学
- 北京师范大学
- 中国农业大学
- 中央民族大学
- 南开大学
- 中国海洋大学
- 西北农林科技大学

## 首批已确认仓库

| 学校 | 仓库 | 状态 |
| --- | --- | --- |
| 清华大学 | [`tuna/thuthesis`](https://github.com/tuna/thuthesis) | active |
| 北京理工大学 | [`BITNP/BIThesis`](https://github.com/BITNP/BIThesis) | active |
| 北京航空航天大学 | [`CheckBoxStudio/BUAAThesis`](https://github.com/CheckBoxStudio/BUAAThesis) | unknown |
| 哈尔滨工业大学 | [`hithesis/hithesis`](https://github.com/hithesis/hithesis) | active |
| 复旦大学 | [`stone-zeng/fduthesis`](https://github.com/stone-zeng/fduthesis) | active |
| 上海交通大学 | [`sjtug/SJTUThesis`](https://github.com/sjtug/SJTUThesis) | active |
| 南京大学 | [`nju-lug/NJUThesis`](https://github.com/nju-lug/NJUThesis) | active |
| 浙江大学 | [`TheNetAdmin/zjuthesis`](https://github.com/TheNetAdmin/zjuthesis) | active |
| 中国科学技术大学 | [`ustctug/ustcthesis`](https://github.com/ustctug/ustcthesis) | active |
| 武汉大学 | [`whutug/whu-thesis`](https://github.com/whutug/whu-thesis) | active |
| 中南大学 | [`CSUcse/CSUthesis`](https://github.com/CSUcse/CSUthesis) | unknown |
| 华南理工大学 | [`mengchaoheng/SCUT_thesis`](https://github.com/mengchaoheng/SCUT_thesis) | active |
| 电子科技大学 | [`bdebye/thesisuestc`](https://github.com/bdebye/thesisuestc) | active |
| 西安交通大学 | [`obster-y/XJTU-thesis`](https://github.com/obster-y/XJTU-thesis) | unknown |
| 西北工业大学 | [`1195343015/nwputhesis`](https://github.com/1195343015/nwputhesis) | unknown |

## 状态定义

- `covered`：已人工确认至少一个符合条件的 GitHub 仓库
- `unverified`：尚未人工确认到符合条件的 GitHub 仓库
- `archived`：存在相关仓库，但看起来已归档或长期不再维护

## 仓库收录规则

- 必须托管在 GitHub
- 必须主要面向学位论文、毕业论文或毕业设计写作
- 必须能明确关联到某一所中国内地 985 高校
- 课程报告、简历、幻灯片、通用文章模板不收录

## 目录结构

```text
schema/
  mainland-985.schema.json
data/
  mainland-985.json
```

## 数据字段

- `school_id`：稳定的 ASCII 学校标识
- `school_name_zh`：学校中文名
- `school_name_en`：学校英文名
- `city`：学校主校区所在城市
- `province`：省级行政区
- `project_985`：是否属于 985 工程高校
- `status`：当前收录状态
- `notes`：人工备注
- `templates`：该校已记录的 GitHub 模板仓库列表

模板字段：

- `name`：模板或仓库简称
- `repo`：`owner/name`
- `url`：GitHub 仓库地址
- `degree_types`：支持的学位类型
- `official_status`：`official`、`community` 或 `unknown`
- `maintenance_status`：`active`、`inactive`、`archived` 或 `unknown`
- `last_verified`：人工核验日期，格式为 `YYYY-MM-DD`
- `evidence`：用于说明收录依据的简短证据文本

## 当前进度

第一版已经补齐全部中国内地 `39` 所 `985` 高校的学校级记录，并为其中一部分学校补充了人工核验过的 GitHub 仓库。

## 后续计划

- 补齐全部 `39` 所高校的仓库确认
- 增加自动化 schema 校验
- 自动生成已收录 / 未收录学校表格
- 增加贡献说明，方便提交新学校或新仓库
