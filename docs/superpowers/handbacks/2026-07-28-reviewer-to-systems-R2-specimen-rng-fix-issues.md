---
from: reviewer
to: systems
status: consumed
topic: "[R②異質 ISSUES] specimen RNG-neutral 修——診斷+修法邏輯 CLEAN，但撞既有 untracked SpecimenDumpHelper 同名同路徑不同 API，會炸掉既有 measurer 工作流"
---

# R② 判決：specimen selection RNG-neutral 修 — issues（診斷翻案 CLEAN，落地方式撞車）

## 診斷翻案：確認 CLEAN
親讀 `SpecimenDumpHelper.select()`（分支版）——`state.teams.keys()→sort()→strided index`，逐行確認零 randf/randi/pick_random/shuffle。regression test（`_test_dumphelper_normallod_neutral`）刻意**不設 `force_full_hd`**——核對 `sim_runner.gd` 確認這是關鍵：舊 confound test 全設 `force_full_hd=true`，繞過 far-batch LOD 路徑；新測跑在**真實 far-LOD 環境**（措者原 bug 出現的確切環境）下驗 selection+capture 雙路徑，非只信舊 bisect 的歷史結論。tracer 本身零改動（diff 只碰 2 個 debug 檔）——「tracer 中性免改」站得住。診斷翻案本身、修法邏輯、regression 設計皆扎實，非空話。

## ★must-fix（HIGH）：撞既有 untracked `SpecimenDumpHelper`，API 不相容，merge 會炸
親自 `git status` 確認：`A:\GDS\demo\scripts\debug\specimen_dump_helper.gd`**現在就存在**，untracked（2026-07-19 建，「debug tooling 慣例未 commit」），非空想同名巧合：
- **既有檔**（我讀過全文）：`setup_from_env` 支援 `SPECIMEN_TEAM_ID`(明確隊清單) **+** `SPECIMEN_SAMPLE_N`(strided，**已經是零 RNG**——`all_ids.sort()`+`step=size/n`+`all_ids[int(i*step)]`，跟這次分支「新發明」的演算法逐字一樣)；`dump(state, path="")` 兩參數，呼 `SpecimenTracer.flush()`+`write_jsonl(out_path)`。
- **分支新檔**：`setup_from_env` **只認 `SPECIMEN_SAMPLE_N`，砍掉 `SPECIMEN_TEAM_ID` 支援**；`dump()` **零參數**，改呼 `SpecimenTracer.summary()`（非 `write_jsonl`）。
- **`docs/process/03b_measurer.md:146`**（measurer 標準工作流 §⑤ 逐 specimen dump 段落）**明文**：「對象：鎖定 specimen 隊（`SPECIMEN_TEAM_ID`，含**死隊**——死因才是故事關鍵）」——`SPECIMEN_TEAM_ID` 不是可有可無的 extra，是**文件化的標準流程依賴**。
- **`scripts/debug/adhoc_specimen_demo.gd:27`**（既有驗收 demo，同批 2026-07-19 交付）直接呼 `SpecimenDumpHelper.dump(state, "docs/measurements/adhoc-demo.specimen.jsonl")`——兩參數。分支新 `dump()` 簽名是零參數，**這行會編譯期參數數目不符直接炸**。

**∴ 這不是「兩個檔剛好同名」的小事——是既有、文件化、有 downstream 依賴的工具被同路徑同 class_name 的窄化版本蓋掉**：merge 時 git 會因 untracked 檔案擋下（不會靜默蓋過），但若人工解決時選錯方向（直接拿分支版蓋掉），會同時：①炸 `adhoc_specimen_demo.gd`（參數不符）②丟失 `03b_measurer.md` 標準工作流依賴的 `SPECIMEN_TEAM_ID`（死隊死因追蹤能力）。

**★而且真正的反轉是**：既有檔的 `SPECIMEN_SAMPLE_N` 路徑**本來就已經是零 RNG strided**——這次診斷出的 pick_random bug，源頭是「measurer 那次 temp wiring」（commit message自承「已 revert 不在 repo」）——**是另一支獨立、已刪除的 ad-hoc 診斷腳本**，根本不是這個既有 `SpecimenDumpHelper`。分支這次「修」等於在不知情下**重新發明既有檔案已經有的能力**，還意外做窄了（砍 `SPECIMEN_TEAM_ID`）。

## 要求
別讓分支這個新檔取代既有檔。二選一，你判斷：
1. **確認既有 untracked 檔的 `SPECIMEN_SAMPLE_N` 路徑本來就中性**（我讀code是，你可另立小 regression 補實證）→ 這次「修」根本不需要新檔案，只要把既有檔正式 commit 進 repo（結束 untracked 狀態，這本身也是待辦）+ 視需要補一條 regression 鎖住 `SPECIMEN_SAMPLE_N` 中性即可。
2. 若你判斷既有檔案設計仍要調整（例如需要新 `select()`/`teardown()` API），**改名或合併**，不能用同 `class_name`+同路徑窄化砍掉 `SPECIMEN_TEAM_ID`——保留既有 API 全集，新增能力用新函式名，不砍舊的。

不管哪條，**merge 前必須解決這個 untracked 檔衝突**，不能讓它靠「git 擋下」被動發現——現在講清楚。

## gate followup 判——同意可拆
`constitution_gate.gd` 現況（我請 agent 讀過）：`SCAN_DIR` 根本不掃 `scripts/debug/`（specimen/observer 工具全住這裡），RNG 偵測 regex 也不含 `pick_random`/`shuffle`。要做這個偵測器需要新 scan-dir+新 file-predicate+新 regex 類別，量體接近當初 v3 god-view 偵測器那次，非一行 regex 能搞定。**同意可拆 followup**，但要求明確記進 known_issues（非只留在這封 handback 裡）——這是第 4 次同族洞（observer_no_global_rng 家族），blueprint 已多次點名，別讓這輪又靠人工記性接住。

## 判決
**issues** → 回你解 untracked 檔衝突（must-fix，merge 前）。診斷翻案+修法邏輯本身 CLEAN，不需重做，只是落地檔案要換個放法。gate followup 明列 known_issues 後可拆。
