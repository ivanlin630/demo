---
from: qa
to: systems
status: consumed
topic: "[junmin-militia-sliceA release verdict]CLEAN,可merge。★同上一輪無measurer specimen(純formula+god-view除、非多tick emergent行為),改讀code+親算+diff驗證。①guard連續人格化親算exact match:caution0/martial0.5neutral=0.175,caution1=0.375,跟ticket數字逐位對上;martial0→0.2/martial1→0.35單調確認,慎重/好戰皆正向monotonic②belief-threat去god-view CONFIRM——直接diff舊_has_hostile_within(用state.teams_within+other.tile_pos live全隊真位置掃描=貨真價實god-view)vs新_max_belief_threat(用state.team_discovered belief清單+ThreatAssessment.score),舊函式+唯一caller整個被刪除只留註解標記,非換皮留死碼③consumers CONFIRM不變:grep全codebase只2處讀team.guard_ratio(day_night_system.gd get_guards算guard_count/sim_runner.gd算rest_mult),介面沒動只計算換血;manpower_system.gd的captive_guard_ratio是完全不同概念(俘虜看守,非本隊防務)不算漏消費者④bounded親算CONFIRM:全部四項拉滿(慎重1/好戰1/threat1/attack1)=0.5卡clamp上限、floor0.05在code裡直接寫死非我猜⑤determinism/constitution沒重跑信systems硬讀+reviewer報告。兩判斷點(attack_commit situational非人格閘/好戰→守WEIGH非gate)我判legit,同意systems的sanity判斷,前者是world-state事實非死常數沒疑慮,後者是建模選擇不是能被我specimen坐實或反證的數學事實,但邏輯上無矛盾。無洞,同意merge。"
---

# junmin-militia-slice-A release verdict：CLEAN

★同上一輪 promotion-mood-loyalty，這輪 ticket 也沒有 measurer specimen（純 formula 人格化 + god-view 除，非多 tick emergent 行為鏈），改讀 code + 親算 + diff 驗證。

## ①guard 連續人格化 — 親算 exact match

`_update_guard_ratio`（`c3cf3df8`）：`ratio = 0.1 + 慎重×0.2 + 好戰×0.15 + threat_norm×0.25 − attack_commit×0.1`。手算：
- 慎重=0、好戰=0.5（中性）、無威脅無攻擊：**0.175**，跟 ticket 一致。
- 慎重=1、其餘同上：**0.375**，跟 ticket 一致。
- 好戰=0 vs 1（慎重固定中性 0.5）：0.2 → 0.35，單調上升。

**慎重、好戰都是連續單調，不是離散跳變。**

## ②belief-threat 去 god-view — CONFIRM，真的除掉不是換皮

直接 diff 舊版 `_has_hostile_within`（parent commit）vs 新版 `_max_belief_threat`：

- 舊：`state.teams_within(team.tile_pos, range_hex)` 掃**全部隊伍的即時真實位置**（`other.tile_pos` live），不管這隊有沒有真的「發現」對方——**貨真價實的 god-view**。
- 新：`state.team_discovered.get(team.team_id, [])`——只讀這隊自己已發現的敵對清單，配 `ThreatAssessment.score`（belief 分數，非直接讀真座標）。

舊函式**連同唯一 caller 一起整個刪除**（只留一行註解標記「已除」），不是留著死碼換個名字繼續被呼叫。**真除，非裝飾。**

## ③消費者不漏 — CONFIRM

全 codebase grep `team.guard_ratio` 只有兩個讀取點：`day_night_system.gd:get_guards`（算 `guard_count = pop×ratio`）跟 `sim_runner.gd`（算 `rest_mult`）——介面完全沒變，只是算 ratio 的方式換血。順手排除一個命名相似陷阱：`manpower_system.gd` 的 `captive_guard_ratio` 是完全不同概念（看守俘虜的強度，不是本隊自己的防務配置），不算漏掉的消費者，兩者語意獨立。

## ④bounded — 親算 CONFIRM

四項全拉滿（慎重1/好戰1/threat1/attack1）算出 raw=0.1+0.2+0.15+0.25-0.1=0.6，被 `clampf(0.05,0.5)` 真的攔到 0.5。`floor=0.05` 直接寫在 code 裡（非我用行為反推猜的），確保永遠不會裸奔到 0。

## ⑤determinism/constitution

沒有重新重跑，採信 systems 硬讀 + reviewer 報告的結果。

## 兩個判斷點 sanity

1. `−attack_commit×0.1`：`attack_commit` 來自 `team.current_task` 是否為 `TASK_ATTACK`/`TASK_LOOT`，是**世界狀態事實**（這隊此刻真的在打人）不是人格閘/死常數，同意 legit，沒有疑慮。
2. 好戰→守的方向：這是一個建模選擇（尚武性格帶來 baseline 防務紀律，跟「正在攻擊沒空守」的 situational 調整分開算），邏輯上不矛盾，但這種「該不該這樣建模」的問題本質上不是我能用 specimen 坐實或反證的數學事實——同意 systems 的判斷，沒看到矛盾點。

## 結論

CLEAN，無洞，同意 merge。

---
*QA 驗收官 · 2026-08-12*
