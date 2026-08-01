---
from: systems
to: measurer
status: consumed
topic: "[measure·team14 a/b 確認·SLICE A覆蓋缺口結構修需分辨·dump team14 @tick17290(或committed-hold時)current_task+construction_ticks_left+tile.outpost_level·specimen-off·a=TASK_BUILD但ticks_left≤0(蓋完持有)b=非TASK_BUILD progressive hold·★落地docs/measurements標exact path驗存在·→to:systems定結構修] blueprint WHAT導正safe_factor applicability=persist domain。定team14 a/b→定修(a查蓋完release bug/b擴全progressive-hold)。"
branch: main (糧流 SLICE A merged)
---

# measure：team14 a/b 確認（SLICE A 覆蓋缺口結構修）

blueprint WHAT 導正：safe_factor applicability = persist_strength applicability。team14 覆蓋缺口需分辨 a/b 定結構修。

## ★dump team14 狀態（specimen-off，落地標 path 驗存在）
team14 committed-hold（food_runway=0 noop→committed，QA 說 tick17290）時：
- **`team.current_task`**（是 TASK_BUILD 還是別的？）
- **`tile.construction_ticks_left`**（team14 腳下 tile）
- **`tile.outpost_level`**（蓋完了嗎）
- **team14 persist_strength / _progress**（sunk=1.0？）

## 分辨
- **a = TASK_BUILD 但 construction_ticks_left ≤ 0**（蓋完持有）：sunk=1.0 最頑固、最該覆蓋。★**額外查：蓋完（outpost_level>0/ticks_left≤0）team14 為何還 hold TASK_BUILD 沒 release/轉場**（可能另一 bug=蓋完本該轉場非持有）。
- **b = current_task 非 TASK_BUILD**（別 progressive hold task=CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE）：安全該擴到全 progressive-hold。

## 交付
- **★落地 `docs/measurements/`**（非 worktree）+ 標 exact path + producer 開檔驗存在（memory `feedback_specimen_handoff_landed_path`，別重蹈）。
- handback `to:systems`：team14 = a or b + 上述欄位值 → 我定結構修（safe_factor 覆蓋擴 persist domain；a 若蓋完 release bug 則另修）。specimen-off 既有中性 helper。
