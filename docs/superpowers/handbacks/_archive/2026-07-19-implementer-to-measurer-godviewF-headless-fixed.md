---
from: implementer
to: measurer
status: consumed
topic: "[godview-F headless 1 NEW 修完·test-fixture gap·可續 doom-delta measure] 你 comprehensive(雙格式,上輪教訓傳承=好)揭 1 NEW『慎重者矛盾情報→派斥候查證』(headless_test:1013)。判定=test-fixture gap(同 slice2 款):測試 record_claim 設 population_est 沒帶 tile_pos→best_estimate.get(tile_pos,sentinel)→(-1,-1)→F1 scout guard 擋。production 三 belief 寫路(vision/interaction/relay)皆帶 tile_pos→真 belief 恆有位;F1 guard 對(無位不能 scout)。修=補 tile_pos 進 4 record_claim。headless comprehensive 回 6=baseline(0 new),char bed 5/5,gate 64。F1 code 未動=byte-identical 不變。branch@d0ab7f91。可續 doom-delta measure。"
---

# godview-F headless 1 NEW 修完（test-fixture gap，可續 measure）

## 你抓對了（comprehensive 雙格式，上輪教訓傳承 = 好）
20d4ce97 headless comprehensive = 7 vs baseline 6 → 1 NEW「慎重者矛盾情報→派斥候查證」（`headless_test.gd:1013`）。你用雙格式（`[FAIL]` + `Assertion failed`）抓到——正是上輪我漏的那半，這次擋下。

## 判定 = test-fixture gap（同 slice2 款，非 regression）
- 測試 `record_claim(..., {"population_est": ...}, ...)` 兩次設矛盾人口 intel **但沒帶 tile_pos** → `best_estimate().get("tile_pos", sentinel)` → `(-1,-1)` → F1 scout guard（`scout_pos==(-1,-1)→return false`）擋 → 斷言期待 TASK_SCOUT 失敗。
- **production 三 belief 寫路皆帶 tile_pos**：vision:113 `snap["tile_pos"]` / interaction:958 `snap["tile_pos"]` / message relay:217 繼承 src_val（源自 vision/interaction 的位）。→ **真 belief 恆有 tile_pos**；population-only claim = 測試手搭 artifact。
- **F1 guard 語意正確**：無 belief 位 → 不能 scout（不知往哪派斥候）。舊 code 用 live prey.tile_pos（god-view）騙位。F1 拔掉 = 對。

## 修
補 `tile_pos: Vector2i(2, 0)`（prey 位）進 4 個 `record_claim` entry（測試 A/B 各 2）= 鏡射 production belief。

## 驗
- **headless comprehensive（`[FAIL]` + `Assertion failed`）= 6 = baseline（0 new）**；查證 assert 消。
- char bed `godview_f_test` 5/5；gate 64 removed=0。
- **F1 code 未動**（只補測試 belief）→ 前 4-way byte-identical（base==F2-only==full==mine-2x=`b2452128`）不變。

## → 可續 doom-delta measure（branch@d0ab7f91）
seed1337/42/4201 is_sim=true → .qa.json；★track doom-delta（F1 缺 belief 不瞎追 live → fog cost 穩定/爬）。

## 溯源
你 comprehensive headless 抓 1 new；vision:113/interaction:958/message:217 belief tile_pos 恆寫；[[feedback_measure_first]]；同 slice2 test-fixture gap 款。
