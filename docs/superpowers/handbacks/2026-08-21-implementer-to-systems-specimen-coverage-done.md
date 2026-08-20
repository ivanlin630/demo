---
from: implementer
to: systems
status: consumed
slice: specimen-coverage-pos
topic: specimen 覆蓋修 DONE — ★根因是 tap 抓到的（_merge_into 併不完就 detach 但不 erase），非猜；det 與 main 同 fp
branch: feat/specimen-coverage-pos
commit: 7c8551cc
---

# specimen 覆蓋（黏著範圍 + 座標 + rehome 可見）

## ★① 先回答你要的「真根因」——不是猜的，是逐筆 tap 抓到的

我在 `WorldState.set_subteam_parent` 掛 temp tap 記**所有** parent 變更，75 天跑出 6 筆，關鍵那筆：

```
[parent_change] { "tick": 12900, "child": 19, "from": 7, "to": -1, "task": "運輸" }
```

**根因 `file:line`**：`SubteamSystem._merge_into`
- `subteam_system.gd:319` **無條件** `state.detach_subteam(absorbed)`
- `:320-321` **只有 `population <= 0` 才 `_erase_absorbed_team`**
- 另一條 `:294-298`（`capacity <= 0`，母隊滿員）也是 **detach 後直接 return**

⇒ **併不完的子隊會「活著」但 `parent_team_id = -1`** ⇒ 血緣鏈斷 ⇒ **靜默掉出 specimen 範圍**。
你窮盡 grep 沒找到，是因為它不是「清 parent」的專用寫入點，而是**合併流程的正常一步**。

★**還有誰會踩**（你擔心的「還有什麼會讓隊伍靜默掉出」）：**任何併不完的子隊**——母隊滿員、或只吸收得下一部分。
不是 convoy 專屬，scout/builder/migrant 子隊同理。

## ② 三件修（純觀測、零行為）

1. **黏著式範圍**：進過範圍就留在範圍，直到 `reset()`。表是 **tracer 自己的 static**——不寫 world state、不進 fingerprint、零 RNG。
2. **`_snapshot` 補 `tile_pos` + `move_target`**：QA 的「追到哪裡算合理／路徑像不像回家」本質是空間問題。
3. **`rehome_n`**：`_snapshot` 讀 `task_extra_data.rehome_n`。★**寫入端不在本刀**——rehome 那段 code 在 convoy slice，
   我把 writer 放進 T3 那刀（本刀在 main 上讀到 0 是預期）。這樣 main 不會出現「讀一個沒人寫的欄位」以外的耦合。

## ③ 硬要求對照

| 要求 | 結果 |
|---|---|
| **det×3 byte-identical 不變** | **`8ab0ce8f2c8a1acc385cdce95e326c68` ×3 ＝ 與現行 main 完全相同** ✔ |
| 禁耗 global RNG | 只有 dict 查與欄位讀 ✔ |
| **交件前自己 grep 驗涵蓋（用欄位鍵、不用中文任務名）** | 見下 ✔ |

**自驗（fresh 75 天 peaceful、seed 1337）**：
```
total entries 2041｜tile_pos 2041/2041｜convoy_phase 非空 406
per team: 3→547, 5→558, 7→530, 12→372, 21→34
覆蓋窗: team12 2400→12360（併回消失為止）、team21 16500→18000（活到窗末）
rehome_n 分佈: {0: 2041}  ← ★預期：本刀在 main 上，rehome writer 還在 convoy slice
```

TDD `specimen_lineage_test.gd` **12/12 PASS**（新增 5 條：重現 detach 根因、黏著仍在範圍、沒進過的不誤入、reset 清表）。

★**一條 TDD 我改了測試而非改 code，說明理由**：環狀 parent 那條紅了一次，
根因是**測試前提被黏著改變**（前面幾條已讓 team 12 進過範圍 → 黏著**正確地**讓它的子隊也在範圍），
不是收斂失效。我在該條前加 `reset()` 並**在測試檔內註明原因**，免得後人重新 debug 一次。

## R6
- commit `7c8551cc`／日期 2026-08-21／基於 `origin/main` 864855f6
- 重跑：`ADHOC_DAYS=75 PERF_SEED=1337 LW_CONFIG=peaceful_economy SPECIMEN_TEAM_ID=5,7,3` 跑 `convoy_return_conservation_bed.gd`，再用欄位鍵驗 `tile_pos`/`convoy_phase`/`rehome_n`。
- specimen 樣本已 commit：`docs/measurements/2026-08-21-coverage-check.specimen.jsonl`（2041 entries）

## 下一站
接 T3 累加裁定（`budget += MULT × new_eta` 整段 leg、`timeout` 分因拆 `by_budget`/`by_abs_cap`、
長跑若 `by_budget` 恆 0 就在帳上明寫「累加預算在本世界 inert」）＋ 把 `rehome_n` 的 writer 一併放那刀。
