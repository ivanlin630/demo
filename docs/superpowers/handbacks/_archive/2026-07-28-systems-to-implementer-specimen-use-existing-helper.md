---
from: systems
to: implementer
status: consumed
topic: "[★R² ISSUES 解·選項1·你分支新 SpecimenDumpHelper 撞既有 untracked 同名同路徑(2026-07-19,已零RNG strided,pick_random bug 源是 measurer 另一支已刪 ad-hoc 非既有 helper)·你不知情重新發明+意外窄化(砍 SPECIMEN_TEAM_ID/dump 零參數炸 adhoc_demo)·改:commit 既有檔保全API+regression 鎖中性,丟分支窄化版·gate followup known_issues 已記] reviewer 異質 R² 揪:既有 SpecimenDumpHelper 本來中性,你分支修=重新發明+窄化撞車。改用既有檔。"
branch: feat/specimen-tracer-rng-fix (改做)
---

# 實作：用既有 SpecimenDumpHelper（選項 1，別新檔窄化）

## R² ISSUES（reviewer 異質好 catch）
你分支新 `SpecimenDumpHelper` **撞既有 untracked 同名同路徑**（`scripts/debug/specimen_dump_helper.gd`，2026-07-19 建，debug tooling 慣例未 commit）：
- **既有檔已零 RNG strided**（`all_ids.sort()`+`step=size/n`+`all_ids[int(i*step)]`，跟你「新發明」逐字一樣）+ 支援 `SPECIMEN_TEAM_ID`（明確隊清單，含死隊）+ `SPECIMEN_SAMPLE_N`；`dump(state, path="")` 兩參數呼 `write_jsonl`。
- **你分支窄化**：只認 `SPECIMEN_SAMPLE_N` 砍 `SPECIMEN_TEAM_ID`；`dump()` 零參數呼 `summary()`。→ 炸 `adhoc_specimen_demo.gd:27`（dump 兩參數）+ 丟 `03b_measurer.md:146` 標準流程死隊追蹤依賴。
- **★真反轉**：pick_random bug 源 = **measurer 那次 temp wiring（另一支獨立、已 revert 不在 repo 的 ad-hoc 腳本）**，**不是既有 SpecimenDumpHelper**（它本來中性）。你分支「修」= 不知情重新發明既有能力 + 意外做窄。

## 改做（選項 1）
1. **commit 既有 untracked `scripts/debug/specimen_dump_helper.gd` 進 repo**（結束 untracked 狀態＝本身待辦，保全 API 全集：`SPECIMEN_TEAM_ID` + `SPECIMEN_SAMPLE_N` + `dump(state, path)` 兩參數 write_jsonl）。**別用你分支窄化版蓋掉**。
2. **regression 鎖既有檔 `SPECIMEN_SAMPLE_N` 中性**：normal-LOD（★不設 `force_full_hd`，跑真 far-LOD——原 bug 環境）specimen ON==OFF byte-identical。你分支已寫的 regression 邏輯好，**改成對既有檔跑**（驗既有 SPECIMEN_SAMPLE_N 零 RNG）。
3. **丟分支窄化新檔**（`summary()` 零參數版）。若你的 `summary()` 有真用途（既有檔沒有的能力）→ **加新函式名到既有檔**，不砍 `dump`/`SPECIMEN_TEAM_ID`。
4. 確認 `adhoc_specimen_demo.gd` + `03b_measurer.md` 流程不炸（既有 API 保全）。

## gate followup（已記 known_issues）
observability_gate（機器擋 observe/選取路徑碰 RNG）= followup slice（reviewer：`constitution_gate` SCAN_DIR 不掃 `scripts/debug/`、regex 不含 pick_random/shuffle，量體接近 v3 god-view 偵測器，非一行）。**已明列 known_issues**（第 4 次同族，別靠人工記性）。本刀不做。

## 閘 + 交付
- headless 0-new + gate 74 + ★既有檔 SPECIMEN_SAMPLE_N regression（normal-LOD ON==OFF byte-identical）+ adhoc_demo/measurer 流程不炸。
- handback `to:systems` → R² → merge。
