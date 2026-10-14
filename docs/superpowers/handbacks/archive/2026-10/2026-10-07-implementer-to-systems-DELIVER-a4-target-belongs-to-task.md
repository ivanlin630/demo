---
from: implementer
to: systems
status: consumed
slice: A4 目的地屬任務（transition 必填 move_target＋2 處 try_set 禁沿用）
topic: ★**交件｜BATTERY_RC=0｜105 綠／0 紅**（run-id `29871-20261007-005009`，HEAD `291e14f28`）｜branch `feat/a4-target-belongs-to-task` 遠端 tip **`a5a551e18`**｜fp **不變（量的）**｜陽性對照＝fp 世界 t65 Team26（換手當下）；Team40 不是樣本
---

# 一、先查（spec §0）：Team40 不是樣本

```
fp 世界（warring_states、seed 20260922），臨時儀器（已還原）：
  [A4DBG] t8973 try_set Team40 idle→貿易 target_param=(10,25) cur_mt=(-1,-1) src=ambition
  [A4OPT] t8973 Team40 opt=貿易 task=貿易 target=(10,25) owner=40 arch=商業 resident=false
⇒ 換手當下 move_target 已是 (-1,-1)；(10,25) 是「貿易」套利分支**新給的**目標，不是沿用
★訂正我 A3 信兩句：
  ①「t8973 換成貿易而 move_target 沒重設、沿用逃跑的」—— 錯（從每 tick 開頭的快照推的，看不到同 tick 內清→設回同一格）
  ②母體表「貿易不會派到自家」—— 錯：`_merchant_trade_target` 的套利分支 `best_arbitrage_order` 只排除**自己下的單**，
    不排除**掛在自家市集上的別人的單** ⇒ 可以把商隊派到自家市集（Team40 就是）—— 你已轉藍圖
```

# 二、實例（臨時儀器：transition 換手且 move_target ≠ (-1,-1)）

```
30 天觀察世界（default、seed 1337、玩家活著）：transition 換手 3 次、沿用 **0**
fp 世界：換手 7 次、沿用 **1**：
  [A4TR] t65 Team26 idle→建設 沿用 move_target=(20,6) at=(22,4)
  腳下 (22,4) ct=26 target={upgrade_facility, workshop}｜(20,6) ct=-1（沒有工程）
  呼叫點 outpost_system.gd:675 _begin_facility_construction
★定性（我上一則說錯，已訂正）：舊版這個沿用**只活在換手當下**——同一個 tick 內別的寫入者就把 move_target
  改成工地格 (22,4)，30 tick 後它仍在工地 ⇒ **不變量在換手當下被違反、今天沒有可觀察的世界後果**
```

# 三、11 個 transition 呼叫點（呼叫點／新任務／傳了什麼／為什麼）

| 呼叫點 | 新任務 | 傳 | 為什麼 |
|---|---|---|---|
| faction_ai_system.gd:2982 遷村 | MIGRATE | `target_pos` | 遷村目的地（下一行原本就設這個） |
| faction_ai_system.gd:5673 復工 | BUILD | `tile.tile_pos` | 工地那一格（下一行原本就設這個） |
| faction_ai_system.gd:7984 叛離 A 路 | 等待新領主 | `(-1,-1)` | 等待＝不走；★**唯一改行為的一處**（見下） |
| interaction_system.gd:1692 安頓 | 生產 | `(-1,-1)` | 原地生產（下一行原本就清） |
| interaction_system.gd:1719 轉居民 | 生產 | `(-1,-1)` | 原地生產 |
| outpost_system.gd:583 start_build | 建設 | `(-1,-1)` | 就地施工（`_get_team_tile`） |
| outpost_system.gd:606 start_upgrade_level | 建設 | `(-1,-1)` | 同上 |
| outpost_system.gd:675 _begin_facility_construction | BUILD | `(-1,-1)` | 同上（tile 由 start_upgrade_facility 的 `_get_team_tile` 傳入）——★Team26 這條 |
| outpost_system.gd:693 start_demolish | 建設 | `(-1,-1)` | 同上 |
| outpost_system.gd:835 _subteam_upgrade_level | BUILD | `(-1,-1)` | 同上（呼叫端 `_get_team_tile`） |
| outpost_system.gd:886 demolish_with_control | BUILD | `(-1,-1)` | 同上 |

★寫入在三道守衛**之後**：被擋下（combat lock／crisis 免疫／emergency-respect）⇒ 任務沒換、目的地也不動
★床側 7 處（headless_test 1、transition_arbiter_bypass_test 6）補 `(-1,-1)`；後者順手補 `@bed-kind: acceptance`＋`slice:`

## ★等待新領主那一處（你要的單列）

```
舊版：沿用前一個任務的 move_target ｜ 新版：(-1,-1)（等待＝不走）
實際值（臨時儀器，origin/main 528e2daeb）：
  fp 世界：呼叫 **0** 次
  30 天觀察世界：呼叫 **86** 次，**全是 Team14、舊任務全是「逃跑」**（舊 move_target ∈ {(7,3), (4,6), (-1,-1)}）
    ⇒ 下一次呼叫時任務仍是逃跑 ⇒ **86 次全被 transition 的守衛擋下**（逃跑高優先、等待新領主是 AMBIENT）⇒ 實際換手 **0**
⇒ 這處的行為改變在兩個世界都**沒有實際發生**
★順帶（不修）：Team14 對同一個叛離判定在 30 天內撞了 86 次、每次都被擋 ⇒ 是否該留失敗記號／cadence，給你判
```

# 四、2 處 try_set 傳舊 move_target

```
faction_ai_system.gd:7856 起義 → TASK_HOLD：team.move_target if current_task == TASK_HOLD else (-1,-1)
interaction_system.gd:832  信使下令 → order：target.move_target if current_task == order else (-1,-1)
⇒ 同任務只換目標＝合法（沿用）；換任務 ⇒ 清空（信使只帶任務、不帶目的地；起義＝就地守）
```

# 五、驗收（床 `scripts/debug/task_target_handoff_bed.gd`）

```
P1 Team26 t65 那一次 transition 換手（換手**當下**取樣）：given (-1,-1)、move_target (-1,-1)、task 建設、tick 65
   ★母體地板：工地 (22,4) ct ＝ 26
P2 Probe 開 3000 tick：try_set ok 459 bad 0｜transition ok 2 bad 0｜release ok 53 bad 0
P3 `current_task = ` 直接寫入反向掃（scripts/simulation）9 命中：task_arbiter.gd 5（try_set／release／transition）
   ＋ reaction_system.gd:485、population_system.gd:137（新隊建立，move_target 預設 (-1,-1)）＋ recruit_tutorial.gd:16（寫別的隊）
   ＋ decision/decision_context.gd:618（寫 ctx 欄位＝讀隊的值）⇒ task_arbiter.gd 那份窮盡結論今天仍成立
負對照（拿掉 transition 那一行寫入＝舊行為）：
   ★第一版 P1（量 tick 末＋30 tick 後的位置）照樣綠 ⇒ 沒鑑別力（同 tick 內被蓋掉）⇒ 改成換手當下取樣
   改後：P1 紅（換手當下 move_target (20,6)，給 (-1,-1)）＋ P2 transition bad 1（同一筆 Team26）
儀器：TaskArbiter._note_handoff（Probe-gated、零 RNG）——try_set 四個寫入點／transition／release 回傳那一刻比對
原文：docs/measurements/2026-10-07-a4-target-belongs-to-task.txt
```

# 六、fp

```
本信那一輪 world-fp ✓（286s）、world-fp-ctrl ✓（555s）⇒ final_fp ＝ 8c9b2d72…（基準）⇒ **基準不動**
為何沒變：fp 世界裡唯一一次沿用（Team26 t65）在同一個 tick 內就被別的寫入者改成工地格 ⇒ 修法只改了「換手當下」那一瞬，
  tick 末的世界狀態逐位相同；「等待新領主」那一處在 fp 世界 0 呼叫；2 處 try_set 在 fp 世界的換手若是同任務則照舊沿用
（上一輪 bed-kind 紅的那一輪也是 world-fp ✓ ⇒ 兩輪一致）
```

# 七、新列（四欄；expect 從輸出逐字抄）

```
id      task-target-handoff
cmd     GODOT_TIMEOUT=900 powershell -NoProfile -File ./tools/godot.ps1 --headless --script scripts/debug/task_target_handoff_bed.gd
expect  === task_target_handoff DONE === errors: 0
```

# 八、分支

```
branch feat/a4-target-belongs-to-task tip a5a551e18（最後一顆 ＝ artifact 落 291e14f28 那一輪）；rebase 在 origin/main 之上
main 之後只多了 docs/ ⇒ 沒重跑
```

