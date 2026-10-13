---
from: implementer
to: systems
status: open
slice: 多格移動走一格就停（spec 2026-10-13-multi-hop-move-stops-after-first-tile-HOW）第一顆：只查不改
topic: ★寫者坐實＝(A)：tick 96 loop3 `_evaluate_threat` → `_decide_unified(src=threat)` → `TaskArbiter.try_set(…, "unified")` 替玩家隊選「覓食」、move_target (9,0)→(10,2)｜觀察已記來源（arbiter 入口＋_source／直接寫），等你第二輪 R² 後的修法節再動｜branch fix/multi-hop-move tip 936b9a8f2（已推，未 merge）
---

## 重現與寫入紀錄

床 `scripts/debug/multi_hop_move_writer_diag.gd`（diagnostic；藍圖同一串鍵，seed 1337）：

```
鍵 m   tick 61   move_target：(-1,-1) → (9,0)    來源 直接寫（player_command_system.move_to :2039）
鍵 x   tick 96   task：idle → 覓食               來源 arbiter.try_set:unified
                 move_target：(9,0) → (10,2)     來源 arbiter.try_set:unified
鍵 x   tick ~400 move_target：(10,2) → (-1,-1)   來源 直接寫（movement_system 抵達清除）⇒ UI 印「抵達 (10,2)」
```

- 臨時印 `_decide_unified` 的 src（沒 commit）：唯一一次對玩家隊的呼叫是 **src=threat，tick 96**。
- 玩家隊 Team15：faction_id −1、tags 只有「統領」⇒ `uses_unified` 是 false，leader／member 兩條到不了；solo 有 :4557 排除。
  ⇒ 進來的路是 loop3 `_evaluate_threat`（玩家隊 idle、威脅過門檻）→ :677 `_decide_unified(state, team, "threat")`。**loop3 對每一隊都跑，沒有排除玩家隊。**
- 開場就閒置（`MT_SKIP_KEYS=1 MT_IDLE_HOURS=72`，玩家從不下令）：3 天內 AI 對附身隊寫 **try_set:unified ×1**（task＋目的地），之後一直掛在「覓食」。

## 觀察（之後要變成 P5 守衛的那支）

- `TeamData.move_target` 與 `current_task` 加 setter：只有 `TeamData.mt_watch_tid` 那一隊才記（舊→新、來源）；預設 −9999，就是一次整數比較。
- `TaskArbiter` 四個入口（try_set／transition／release／set_strategic_move）：只有被觀察的那一隊才經 wrapper 掛 `watch_src`（try_set、transition 帶 `_source`）；其他隊直接進原本的函式本體，行為不變。
- setter 讀不到 `watch_src` ⇒ 記成「直接寫（不經 arbiter）」。
- ★`get_stack()` 在 headless、沒接除錯器的時候回空陣列 ⇒ 直接寫抓不到呼叫點，只能靠下面那份靜態清單對號入座。

## 不經 arbiter 的寫入點（靜態清單，`grep "\.move_target\s*=[^=]"`／`"\.current_task\s*=[^=]"`，排除 task_arbiter.gd）

**可能寫到附身隊（領袖隊本身）的：**

| 位置 | 函式 | 性質 |
|---|---|---|
| player_command_system.gd:2039／2048 | move_to／cancel_move | 玩家指令 |
| movement_system.gd:60 | process | 跟隨任務目標的 belief 位置（帶 order_target 的任務） |
| movement_system.gd:97／100 | process | FLEE 任務的目的地 |
| movement_system.gd:344／354／367 | _step_team | 抵達、無路、其他原因清除 |
| faction_ai_system.gd:548／560 | _refresh_attack_pursuit | 攻擊任務追擊對齊 |
| faction_ai_system.gd:4281 | _update_escort | 護送 |
| faction_ai_system.gd:7184／7192 | _commit_settle_site | 紮根 commit hook |
| faction_ai_system.gd:2984／3004 | _begin_village_relocate／tick_relocations_all | 村落遷移 |
| interaction_system.gd:1752 | _execute_settlement | 清除 |

**只寫子隊、信使或剛建立的隊的（不會碰到附身隊）：** faction_ai :1515／1521／2438／2642／2957／4155／4182／4320／4328／4383／5674；subteam_system :33／62／64／130／133／161／164；interaction :667／873；player_command :1183（下令子隊）；population :137、reaction :485、recruit_tutorial :16（都是新建的隊）。decision_context :630 是寫進 ctx 的副本，不是寫隊伍。

## 我先做了又退掉的東西（供參考，沒有 commit）

照舊版 spec (A) 寫了 loop3 逐站排除：`WorldState.is_possessed()`、`_decide_unified` 入口、survival／threat／scout／timeouts／takeover／residency／uprising／ambient／orders 各一道。收到你改走 arbiter 咽喉之後已退掉。patch 在 `C:\Users\I12\AppData\Local\Temp\claude\A--GDS-demo\440df8b3-945b-4cc6-bd63-9750aeb25aee\scratchpad\possessed-loop3-guards.patch`（140 行）。它列出的站，正好是 allowlist 要擋的那些來源。

## 下一步

等你第二輪 R² 後的修法節（TASK_TRAVEL＋PRIO_PLAYER、arbiter 咽喉 allowlist、附身隊跳過抗命）就動工；觀察會直接改成 P5 守衛。
