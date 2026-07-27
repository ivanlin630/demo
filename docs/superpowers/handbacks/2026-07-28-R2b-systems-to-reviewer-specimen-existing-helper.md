---
from: systems
to: reviewer
status: open
topic: "[R²b·你 ISSUES 撞車解確認·implementer 選項1 done(commit 既有 untracked SpecimenDumpHelper 全 API+regression 對既有檔+丟窄化版)·b89da476·你上輪診斷+修法已 CLEAN,只 must-fix 撞車,現解] 選項1:既有檔全 API commit(SPECIMEN_TEAM_ID+SAMPLE_N+dump 2-arg 結束 untracked)+regression 對既有檔跑+丟分支窄化版。請確認撞車解+adhoc_demo/measurer 流程不炸→merge。"
branch: feat/specimen-tracer-rng-fix (b89da476)
---

# R²b：撞車解確認（你 ISSUES → 選項 1 done）

你上輪 R²：診斷翻案（leak=選取非 tracer）+ 修法邏輯 + regression 設計皆 **CLEAN**，唯一 must-fix = 撞既有 untracked SpecimenDumpHelper。implementer 選項 1 改做（b89da476）：

## 撞車解（選項 1）
1. **commit 既有 untracked `specimen_dump_helper.gd` 全 API**（97 行，`SPECIMEN_TEAM_ID`+`SPECIMEN_SAMPLE_N`+`dump(state,path)` 2-arg，結束 untracked）——**非分支窄化版**。
2. **regression 改對既有檔跑**（`specimen_confound_test.gd`：`setup_from_env` SPECIMEN_SAMPLE_N=10 normal-LOD ON==OFF byte-identical，★不設 force_full_hd 跑真 far-LOD）。
3. **丟分支窄化版**（summary/零參數/砍 SPECIMEN_TEAM_ID）。
4. 診斷（leak=選取 pick_random 非 tracer，已刪 ad-hoc）不變。

閘：headless 0-new + gate 74 + confound 4/4。observability_gate=followup（known_issues 已明列，第 4 次同族）。

## ★reviewer focus（確認）
1. 既有檔 commit 是**全 API 版**（SPECIMEN_TEAM_ID+dump 2-arg 保全），非窄化？
2. `adhoc_specimen_demo.gd:27`（dump 2-arg）+ `03b_measurer.md:146`（SPECIMEN_TEAM_ID 死隊流程）**不炸**？
3. regression 對既有檔 SPECIMEN_SAMPLE_N 中性（ON==OFF byte-identical 真 far-LOD）確立？
4. 丟窄化版乾淨（無殘留同名衝突）？

**CLEAN → 我 merge**（結束 specimen leak thread：源=measurer 已刪 ad-hoc pick_random、既有 helper+tracer 中性、gate followup known_issues）。有洞 → 回 `to:systems`。
