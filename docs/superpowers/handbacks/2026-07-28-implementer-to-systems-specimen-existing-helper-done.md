---
from: implementer
to: systems
status: consumed
topic: "[done·R² 改做·用既有 SpecimenDumpHelper 全 API(非分支窄化版)+regression 鎖中性·請 R²→merge] feat/specimen-tracer-rng-fix b89da476。reviewer 揪對:pick_random bug 源=measurer 另一支已刪 ad-hoc,既有 untracked SpecimenDumpHelper(2026-07-19)本來零-RNG strided 中性。改做:①commit 既有檔全 API(SPECIMEN_TEAM_ID+SAMPLE_N+dump 2-arg,結束 untracked)②regression 改對既有檔跑(setup_from_env SPECIMEN_SAMPLE_N=10 normal-LOD ON==OFF byte-identical)③丟窄化版。診斷(leak=選取非 tracer)不變。閘:headless 0-new+gate 74+confound 4/4。observability_gate=followup(known_issues 已記)。"
branch: feat/specimen-tracer-rng-fix
commit: b89da476
base: 7fa04f38 (local main HEAD)
---

# done：R² 改做——用既有 SpecimenDumpHelper 全 API（請 R² → merge）

reviewer 異質 R² 好 catch，改做完成。

## R² catch（接受）
- 我上版新建 `SpecimenDumpHelper` **撞既有 untracked 同名同路徑**（2026-07-19，已零-RNG strided，跟我「新發明」逐字同）。
- **★真反轉**：`pick_random` bug 源 = **measurer 另一支已刪 ad-hoc temp wiring**，**非既有 helper**（它本來中性）。我不知情重新發明 + 意外窄化（砍 `SPECIMEN_TEAM_ID` / `dump` 2-arg → 會炸 `adhoc_specimen_demo:27` + measurer 死隊追蹤流程）。
- 診斷（leak = 選取耗 RNG、非 tracer wrap）**不變、獲 R² 認可**；錯的是修法（重造窄化 vs 用既有）。

## 改做（選項 1）
1. **commit 既有 untracked `scripts/debug/specimen_dump_helper.gd` 全 API**（`SPECIMEN_TEAM_ID` + `SPECIMEN_SAMPLE_N` + `dump(state, path)` 2-arg write_jsonl；結束 untracked = 本身待辦）。加 RNG-neutral 註（strided 零 RNG）+ 2026-07-28 揭露/鎖說明。
2. **regression 鎖既有檔中性**：`specimen_confound_test._test_dumphelper_normallod_neutral`——**normal-LOD**（非 force_full_hd）`setup_from_env`（`SPECIMEN_SAMPLE_N=10`）ON vs OFF **byte-identical**。★舊 confound（force_full_hd 遮 far）+ noninvasive（只驗 LOD 分區）都沒覆蓋此環境。
3. **丟窄化新檔**（`select`/零參數 `dump` 版）。
4. `adhoc_specimen_demo`（untracked，未進 worktree）+ `03b_measurer.md` 流程 = 全 API 保全 → 不炸。

## 閘（全綠）
- `specimen_confound_test` **4/4**（原 3 force_full_hd + 新 normal-LOD 既有檔 SPECIMEN_SAMPLE_N 中性）。
- headless 0-new（6 baseline）+ gate 74 removed=0。
- ★既有 helper `SPECIMEN_SAMPLE_N=10` normal-LOD ON==OFF byte-identical（核心硬驗）。
- SpecimenTracer + 既有 helper 皆免改行為（實證中性）；sim 碼未動 → determinism by construction。

## followup（本刀不做，known_issues 已記）
- **observability_gate**：`constitution_gate` 不掃 `scripts/debug/` + regex 無 `pick_random`/`shuffle`，量體近 v3 god-view detector → 另 slice。
- **過去 specimen 量測**：用既有 helper（中性）或 clean 重跑即修 → measurer clean 重跑（另 dispatch）。

## 待
systems R² → merge。→ measurer 用既有 SpecimenDumpHelper（現 committed + 鎖中性）重跑過去 specimen 量測。
