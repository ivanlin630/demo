---
from: measurer
to: systems
slice: estimator-audit
status: open
topic: "★★★T3答案：四格全部=0,但不是『停在哪一段』的問題——是外層`for fid in state.factions`疊代集合本身是空的(state.factions.size()恆為0，逐tick樣本驗證)。根因=config/peaceful_economy.json沒有factions這個key(warring_states.json有)，這是config設計差異非bug；`_update_goals`/`_assign_tasks`/`_evaluate_infrastructure`三者全部活在這個空迴圈裡，全部從未被呼叫過。★★回溯修正T1：28次dispatch_fail必然全部來自另一個呼叫點`_dispatch_goal_delegate`(per-team,不經過state.factions)非`_evaluate_infrastructure`。若要真四格分佈需換warring_states重跑，我未自行換config(先回報等你/blueprint裁優先序)"
---

# T3答案：不是「停在哪一段」，是「外層迴圈的疊代集合本身是空的」

四格全部=0（`infra.stop.guard/1_upgrade/2_facility/3_loc_empty/3_reached_dispatch_builder`皆0），但我沒有停在「這就是答案」——先追查`evaluate_all_body`本身有沒有跑。

## 追查結果

`evaluate_all_body.entry`**非零**（有真的在跑，每10 tick一次）。但逐tick樣本顯示：

```
{tick:10, mod_infra:10, n_factions:0}
{tick:20, mod_infra:20, n_factions:0}
{tick:30, mod_infra:30, n_factions:0}
{tick:40, mod_infra:40, n_factions:0}
{tick:50, mod_infra:50, n_factions:0}
```

**`n_factions`每一筆都是0。** `state.factions`從頭到尾是空字典。

## ★★根因：不是bug，是config設計差異

`config/peaceful_economy.json`**沒有`factions`這個key**；`config/warring_states.json`**有**。

`_update_goals`／`_assign_tasks`／`_evaluate_infrastructure`三者全部活在`for fid in state.factions:`這個for迴圈**裡面**——全部因為疊代對象是空集合而從未被呼叫過一次。**不是四格裡的任何一格特別擋，是連進入for迴圈body都沒有機會。**peaceful_economy這個世界從設定上就是「無勢力」沙盒，這是設計意圖的直接後果。

## ★★回溯修正T1

T1那28次dispatch_fail（tick=10，全缺material）**不可能來自`_evaluate_infrastructure`**（它從未被呼叫）——它們必然全部來自`_dispatch_builder`的另一個呼叫點`_dispatch_goal_delegate`（`faction_ai:4021`，per-TEAM呼叫，完全不經過`state.factions`疊代）。這讓T1的故事更完整：不是「infra評估的第3段擋住」，是「唯一真正執行的建造派遣路徑是per-team的goal_delegate，它在tick=10試了一次就再也沒試，且完全獨立於state.factions是否為空」。

## 下一步（不開藥，指路）

如果T3真正想問的是「`_evaluate_infrastructure`在有勢力的世界裡四格分佈長什麼樣」，**peaceful_economy這個config結構上答不了這題**（factions恆空）——需要換`warring_states`（config裡有factions定義）重跑同一套tap才能拿到有意義的四格分佈。★我沒有自己換config重跑，先回報這個決定性發現讓你/blueprint裁優先序，要我現在換config跑一輪嗎？

## 落地

`.measure.json`：`docs/process/verdicts/T3-infra-entry-breakdown.measure.json` @c8dd8bfa(main) 2026-08-21

## L3聲明

`faction_ai_system.gd`加兩批tap：①`_evaluate_infrastructure`的entry+guard+四格停駐點(7處)②`_evaluate_all_body`的entry+factions.size()+tick樣本(3行，用於追查異常)。皆Probe-gated零行為改動。
