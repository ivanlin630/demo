---
from: implementer
to: systems
status: open
slice: 票 T 疲勞回復綁活動（§1–§7）
topic: ★**交件｜已知紅 0**｜BATTERY_RC=0｜110 綠／0 紅（run-id `47058-20261007-134619`，HEAD `98dd2e93b`）｜branch `feat/fatigue-by-activity` 遠端 tip **`0961a1842`**（已疊 main 3dba70ba0 之後的 origin/main；含 artifact 一顆）｜world-fp → **468ffb9e**（疲勞改模擬＋與 main 的 XB／BS 疊在一起，單跑量得）｜新列 fatigue-by-activity
---

# 一、改了什麼（spec 2026-10-06-ticket-t-fatigue-recovers-by-activity-HOW.md）

```
§1 疲勞只在【有出力】的 pass 累積：SimRunner.fatigue_exertion(state, team) → moved／combat／task／""
   ·moved：TeamData.moved_since_fatigue（移動步驟設、疲勞 pass 讀完清）—— ★偏離：spec 寫讀 move 記錄，我用旗標（移動步驟是唯一寫入點）
   ·task：FATIGUE_EXERT_TASKS 一張表；其餘 pass 照「沒出力」回復
   ·覓食／製造／運輸沒有綁任務的寫入點 ⇒ 不算出力（已在 spec 標的位置寫明）
§1③ 玩家面：狀態列舊行「狀態: X  疲勞: N%」逐字保留（ui-flow 零損失的舊行），下一行「體力：級距」（精神好／有點累／疲憊，走得慢／累垮了，只剩三成速度）
     玩家動作「休息」（自家隊動作區；precheck_rest；constitution 基線一行）；終端自驗 (j)
§2 「休息」option：TASK_REST 第一個寫入者、目的地＝自己那一格 —— ★修：(-1,-1) 會被派工迴圈當成不可派
§5(a) need_hierarchy L_SURVIVAL＝max(糧項, 疲勞)
§6 ①休息的優先序：累垮（≥ FATIGUE_EXHAUSTED）⇒ PRIO_SURVIVAL，否則 PRIO_DISPATCH ②累垮時 rest_drive ＋ FATIGUE_LOYALTY_PENALTY × 具名人數 ③P1 只判會移動或戰鬥的隊，整月原地的印出糧撐天數
§7 疲勞乘式只剩 SimRunner.stamina_factor 一處（移動、路徑估算、遭遇戰起始體力兩處、施工進度、訓練經驗）；EncounterSystem.MIN_STAMINA_TO_DODGE＝STAMINA_AT_EXHAUSTED
```

# 二、驗收（fatigue_by_activity 床，本輪）

```
P1 會移動或戰鬥的隊 30 天都至少降過一次（沒降過 0）｜P2 地板隊·小時比例 0.1024 ＜ 修前 0.6225
P3 疲勞降的那一刻上次之後沒移動過（違反 0）｜P4 駐守一夜 0.800→0.584；反向標成移動過 0.800→0.869｜P5 Σ分類＝pass 數 15758
P6 驅力隨疲勞嚴格上升、休息 30 天被選 6 次｜P9 疲勞高而吃飽的隊·pass 144（贏家前 5 含休息）
P10 同隊同工程施工一天：累垮 72 ＜ 精神好 240；休息後回 240｜P11 疲勞乘式只剩 stamina_factor 一處｜P13 累垮不能閃避、0.5 能
```

# 三、交件前電池收尾（都是本票造成的）

```
·失敗反饋分類表加「休息」（①不成立：原地動作）｜success-sentence 70→71／50→51、探索床 SPEC_ACTIONS_L2 50→51（新動作 rest，重量不放寬）
·headless：行軍測試標移動過、ETA 測試疲勞取 0.8（§7 統一成 stamina_factor 一條曲線，0.5 不降速）、rest 進 UI 覆蓋表、Team0 疲勞改判「全世界至少一支」
·E2E：休息讓 N 21→22 ⇒ 走法第一次走到「攻擊」：
   ①_to_main 投降被拒後改待機打到分出勝負 ②B 側 G 補 tick 被事件截斷（A t181／B t60）⇒ 再按直到追上 ③effect=encounter 快照加 last_encounter_outcome
```

# 四、要你知道的

```
①藍圖 round4b 的 F4「下令走兩格 36 小時」：本票之後疲勞會回復、累垮才剩三成速 ⇒ 實物要在交玩那一輪再看
②疲勞 branch 疊在 main 3dba70ba0 之後；與我正在做的戰鬥區第二輪（feat/battle-start-visibility）互不依賴，但都改 terminal_e2e_bed ⇒ 後 merge 的那一顆要重跑一次電池
```
