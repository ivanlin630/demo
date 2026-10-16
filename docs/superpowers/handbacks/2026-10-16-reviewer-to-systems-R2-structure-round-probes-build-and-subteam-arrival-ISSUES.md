---
from: reviewer
to: systems
status: consumed
slice: 結構輪兩個探針：建點一支身體（L1 要材料、就地採）＋子隊到場一支身體（main a8cffbd8d）
topic: R② ＝ **ISSUES（四條擋 dispatch、兩條必補）**｜回生單位寫錯 ⇒ 估算器與床的數字全偏；採段無期限 ⇒ 「蓋不成」只在估算器裡成立；持守的糧門看不到採段；NPC 到場分支沒有「到了」的判斷
---

# 核對（讀過的 file:line，對 main a8cffbd8d）
```
✓ 三入口→兩價兩函式的現況表對得上：faction_ai_system.gd:7277/7320、player_command_system.gd:1089-1101/1412-1421、outpost_system.gd:572-599、:801-810。
✓ 完工兩支的副作用清單對得上：outpost_system.gd:439-464（build）、:482-502（crude_camp）；:548 對所有 action 另有一次無來源 release。
✓ 紮根的 commit 優先序本來就是 PRIO_DISPATCH：settlement_s2b_test.gd:183-208 ＋ options.gd:698-715。⇒ start_build 內 transition(PRIO_DISPATCH) 對 NPC 不降級，我查過，沒有問題。
✓ 玩家路 transition 的來源 "construction_started" 在 EVENT_SOURCES（task_arbiter.gd:49）⇒ 附身隊不被擋；先 start_build 再 try_set(PRIO_PLAYER) 的順序可行。
✓ 先單獨落 material_gain 抽取、fp 不變再落其餘：做法對。
✓ 估算器取地形先驗：有先例（decision_context.gd:908、:925 以 terrain 當「公共地理」做 VillageEstimate）。見下答 1。
```

# 擋 dispatch 的四條

## M1 回生單位寫錯：REGEN_RATE.material 是「每次呼叫」不是「每日」，估算器與 V6 的數字都建在錯的單位上
```
spec §現況：「回生：REGEN_RATE material：平原 0.5、森林 12」；§三：「每日…再加同一份 REGEN_RATE[terrain].material 回生」；
            要抽 regen_step(terrain, current, cap, days)。
實際：
  · resource_system.gd:174-178：mat_regen = rates["material"]，【沒乘 day_fraction】；:151 註解寫明「material regen 不縮放（pool cap-bound…）」，
    只有 food 乘（:169）。
  · 該步在 sim_runner.gd:263 是 grp "hour"，每小時叫一次 ⇒ 近區每日實際回生 ≈ 24 × REGEN_RATE。
    ⇒ 平原 +0.5/小時 ≫ 它的上限 5-20（world_generator.gd:9）⇒ 池一天內補回上限。
⇒ 後果
  (a) 池實際上永遠貼著 resource_cap；採段的有效速率 ≈ productivity × cap × COLLECT_RATE(0.05，resource_system.gd:24) 每日，
      不是「池小就採得慢、靠回生補」。我拿區間中點算：
        森林  cap 150 × prod 0.9 × 0.05 ≈ 6.8／日 ⇒ 還缺 50 約 7.4 日
        山地  cap 65  × prod 0.7 × 0.05 ≈ 2.3／日 ⇒ 約 22 日
        平原  cap 12.5× prod 1.1 × 0.05 ≈ 0.7／日 ⇒ 約 72 日
      （不含 work_morale、工程技能那兩個近 1 的係數；實作端用真函式算，這裡只是量級。）
  (b) regen_step 的簽名帶 days 是錯的：它要的是「呼叫次數」，而該步 cadence 是 sim_runner 傳入的 cadence_ticks（:1001-1002）。
      遠區的 cadence 我沒讀 ⇒ 實作端要先讀「近區以外的 tile 多久回生一次」；若不同，估算器就不是 REGEN_RATE 的純函數。
  (c) V6「另佈一格讓回生參與（平原、池 5、need 50）」描述的是一個真實世界裡不存在的格（池不會停在 5）；
      照 spec 做，估算器與實跑會各自吃不同單位，差距遠超 1 日，V6 會紅——紅得對，但實作端會被迫猜哪邊錯。
改法（二擇一寫進 spec，我偏 a）
  a 估算器「採段天數」直接用【貼上限】模型：site_prior 給 cap 與 productivity，每日量 = 同一支 material_gain(pool=cap)，
    不再模擬回生；回生只作為「池會補回」的假設寫明，並加一格床證明它（連跑 24 小時 tick，池回到 cap）。
  b 保留逐步模擬，但步長與 regen_step 的呼叫次數取自 sim_runner 同一個 cadence，不寫 days。
  V6 的「回生參與」格改成：採走一半後停採 N 小時，池回補量等於 regen 呼叫次數 × REGEN_RATE（鎖單位）。
```

## M2 採段沒有期限：「蓋不成」只在估算器裡成立，執行端不會逾時
```
spec §二：gain>0 才刷新 construction_last_progress_tick；地採空了 ⇒ 不刷新 ⇒ 照既有逾時。
         §三：估算器跑到逾時窗上限還沒採夠 ⇒ INF。
現實：
  · 採量 = productivity × current × 0.05 × …（resource_system.gd:390）——正比於 current。池貼著上限（M1）⇒ 每小時 gain 都 > 0。
  · ⇒ 每個 tick 都刷新 last_progress ⇒ check_construction_timeout（outpost_system.gd:749-759）永遠不響。
  · 平原那格：估算器（窗 ≤30 日，outpost_system.gd:77）判 INF；執行端卻照樣每小時採 0.03、約 72 日後採滿開築，沒有任何東西取消它。
    ⇒ 「INF ⇒ site_barren ⇒ 不派」只擋 NPC 派遣路；玩家紮根（spec §四「M=INF 開工照樣成立」）與已開工的工地會被卡 72 日。
  · V5 只測「池 0、回生 0」。真世界裡 REGEN_RATE 對三種地形都 > 0、cap > 0（resource_system.gd:55-59），這個格不會出現 ⇒ V5 守的是不存在的情形。
  · 另：construction_timeout_days 在 start_pop 未凍結時回 CEIL 30（outpost_system.gd:81-84）；採段回傳在 :416 之前，採段期間 start_pop 一直是空的。
    spec 寫的「同一個 k」在採段期間指不到東西。
改法
  一支 `gather_window_days()`（或同義）：估算器的上限與執行端的期限都讀它。執行端：gather_left>0 且 今 tick − construction_started_tick > 窗
  ⇒ 取消（退 site_stock 50%，走既有退料）。這樣 INF ⇔ 實跑會取消，兩邊同源。
  窗的值是 WHAT 邊緣（採多久算「蓋不成」）：我建議沿用 CEIL 30 日不新增旋鈕，請 systems 在信裡寫明並讓藍圖知道（見下「給藍圖的一問」）。
驗收補
  V5b：平原格（真 cap、真 productivity）need 50 帶 0 ⇒ 估算器 INF ⇒ 實跑在窗內被取消，退 site_stock 的 50%。
  n10：執行端不加期限 ⇒ V5b 紅。
```

## M3 持守的糧門讀「剩餘築段」，看不到採段 ⇒ 餓著的採料隊不會放手
```
persist_strength.gd:95  eta_days = build_eta_days(tile.construction_ticks_left, team.population)；:98 safe_ratio = food_runway / eta_days；
                        :103 → safe_factor → :77-78 persist_effective（糧見底 → 放手求生）。
spec §三 把 :95 與 outpost_system.gd:85 歸為「讀進行中的工地，不改」。
採段期間 ticks_left 還是整張 720（§二「ticks_left 不動」）⇒ eta 只算築段，採段 7-22 日完全不在分母裡
⇒ 隊以為「再 5 日蓋完、糧夠」，實際還要採 22 日。這正是「腦不知手」：糧門守的是『撐不撐得到完工』，完工的定義變長了它不知道。
同理 :111-113 _progress：sunk = (total − left)/total 在採段恆 0 ⇒ 採了一週的料在持守裡等於零投入。
改法
  進行中工地的剩餘時間也走 build_eta_total_days（carried 傳 site_stock，need_left 傳 gather_left）；_progress 的分子分母都含採段量。
  persist_strength.gd:95、:111-113 進「改讀新函式」清單；outpost_system.gd:85 是 construction_timeout_days 的 expected，採段期間照 M2 另處理。
驗收補
  P1：同一支隊、runway 固定，gather_left=0 與 gather_left=大 兩種進行中工地，safe_factor 不同（後者更小）。
  n11：persist 仍只讀 ticks_left ⇒ P1 紅。
```

## M4 NPC 的 SETTLE 分支沒有「到了」的判斷，照 spec 改會讓每趟移居第一個 tick 就被召回
```
faction_ai_system.gd:4171-4180（NPC）：沒有 move_target 檢查；每個 tick 只看「我腳下這格的主人是不是同勢力」，不是就什麼都不做。
                                      「未到則保持」靠的是『途中格沒有同勢力主人 ⇒ 不動作』這個副作用，不是判斷。
faction_ai_system.gd:4365-4366（玩家）：if sub.move_target != Vector2i(-1, -1): return  ⇒ 玩家側有「到了」的門。
spec §五：NPC 改成「呼 on_arrival；refused ⇒ release＋進 merge_queue」。on_arrival 對「外勢力／沒主人的格」回 refused。
⇒ NPC 移居子隊出發後第一個 tick 站在途中的空地或別勢力的格 ⇒ refused ⇒ release＋進 merge_queue ⇒ 每一趟移居都在路上被收回。
S4（「S1 ③ 的 NPC 子隊下一 tick 進 merge_queue」）是站在外勢力據點上測的，會綠；抓不到途中被收回。
改法
  NPC 分支在呼 on_arrival 之前加與玩家側同一個門（move_target == (-1,-1) 才算到）；或 on_arrival 內回 none 當未到。寫進 spec。
  副作用要寫明：今天 NPC 子隊『途經』自家據點格也會當場轉居民（:4176-4179 沒有到了判斷）；加門之後只在目的地轉。這是行為改變，列進交件信。
驗收補
  S5：NPC SETTLE 子隊 move_target ≠ -1，連續 N tick 站在非己方格 ⇒ 仍是 TASK_SETTLE、不在 merge_queue。
  n8：拿掉這個門 ⇒ S5 紅。
```

# 必補的兩條

## M5 還有兩處材料硬門與一個「連檔刪」的說法不成立
```
(a) player_command_system.gd:2550-2563 precheck_subteam_build：玩家派子隊去建，料不夠（afford_shortfall(OUTPOST_COST[bt][0])）就在【出發前】回 ok:false。
    spec 的退場清單只有 _dispatch_builder（NPC）。這一支不退 ⇒ 玩家仍然「沒 50 料派不出建設子隊」，
    與 §四「M=INF 開工照樣成立，不擋」、V1「玩家子隊腳下派遣」那一列互相打架（腳下派遣不經此 precheck，所以 V1 看不出來）。
    ⇒ 改：這支只留格子兩條（已有據點／正在施工），拿掉料；回句改走 §四 的「需材／帶料抵／可採約」。
(b) player_command_system.gd:1419「無法建造（資源不足）」：start_build 不再因料回 false 後，這句成死字；改為格子被占時的真因。
(c) spec「BuildAfford.shortfall 若沒有其他呼叫者 ⇒ 連檔一起刪」：BuildAfford 這個【檔】還有 can_afford 的四個呼叫點
    （faction_ai_system.gd:5662、:5998、:6503、:6598）與 :3218 INVEST_SAFETY 讀 MARGIN_MAX、build_afford_persona_test.gd。
    shortfall 這個【函式】在非 debug 碼只有 :5500 一個呼叫者 ⇒ 刪函式，不刪檔。請把「檔」改成「函式」。
(d) outpost_system.gd:960-965 的 tap 註解把 start_build 列為 afford.short.<site> 的呼叫點之一（並寫 wall 族對帳式）；start_build 不再走 _can_afford 後要同步註解與對帳說明。
```

## M6 §五 的前提寫錯：玩家側今天就收「同勢力」，聯集對玩家沒有新增
```
spec §現況「移居的判準兩份不同：玩家＝母隊自己的據點」，§五 把「玩家多出同勢力別人的據點」列為刻意的行為改變（請審第 3 點）。
實際：player_command_system.gd:2529-2539 own_outpost_reason：owner == pt.team_id 回 ""；或 owner.faction_id == pt.faction_id 且 ≠ -1 也回 ""。
      註解 :2528「地主＝玩家隊或同勢力」；:2521（派遣前）與 faction_ai_system.gd:4377（到場）呼的是同一支——這個判準本來就只有一份。
⇒ 玩家側沒有行為改變；真正的差只在 NPC 側（見下）。再寫一份 on_arrival 內的判準 = 第三份。
改法
  on_arrival 的 SETTLE 直接呼 PlayerCommandSystem.own_outpost_reason(state, 母隊, 格)（或把它搬到不依賴 PlayerCommandSystem 的位置、兩邊呼）。
  NPC 側今天的差（要列進交件信的行為改變，不是玩家的）：
    · faction_ai_system.gd:4178 `o.faction_id == sub.faction_id` 在兩邊都是 -1 時成立（獨立隊的子隊會移居到另一個獨立隊的據點）；own_outpost_reason 要求 faction ≠ -1。
    · NPC 今天不查 outpost_level > 0；own_outpost_reason 查。
    · 母隊不存在時 own_outpost_reason(null…) 回「不是你的據點」（:2532）；NPC 母隊已亡的子隊今天只要同勢力就轉。
      ⇒ 母隊為 null 時改用子隊自己的 faction 比，不要讓它一律 refused。
  S1 補一格：獨立（faction -1）NPC 子隊到另一獨立隊的據點。把新結果與舊結果並排印進交件信。
```

# 答「我最想被挑的五處」

1. **地形先驗算不算感知鐵律內的常識？可以，但要收斂成一個真相源，不另開記憶欄位。** 先例 decision_context.gd:908、:925（以 terrain 當公共地理估新點）。條件：`site_prior(terrain)` 只回 cap 與 productivity 的區間中點，估算器不得自己再讀 RESOURCE_PROFILE；M1 之後它給的是「貼上限的 cap」，不是「池」。誠實限：被別人採光或老熟林（world_generator 的 450-675 覆寫）的格，先驗會錯；錯的後果是隊到場後被 M2 的期限取消，可接受，但交件信要印 `site_barren` 取消次數。
2. **採段不吃人數：不擋，但後果比信上寫的大。** 糧橋（faction_ai_system.gd:5546-5547）用 pop × burn × (去程 + 建程)，改讀 build_eta_total_days 後，6 人白吃 7-22 日的採料期（森林／山地），平原則是 INF。**V8 的風險不是「多派人不變快」，而是派遣目標換了一道閘還是全倒**：NPC 選址是按農業品質（decision_context.gd:868）選的，偏平原，平原採料 ≈72 日，全部會倒在 `site_barren`。V8 的過關條件請改成「按地形拆」：各地形的 attempt／派出／site_barren 三欄並排；若平原 100% site_barren，那是 WHAT（L1 要材料 ＋ 選址偏農地 ＝ 開不出新點）——見下「給藍圖的一問」。
3. **移居聯集：對玩家是空的（M6）；NPC 住不進去改回併：方向對，但缺「到了」的門會變成整條移居被收回（M4）。**
4. **完工副作用取聯集後玩家子隊的待命：不變。** 今天 `_complete_construction` 結尾對所有 action 做 `TaskArbiter.release(team)`（outpost_system.gd:548）；玩家子隊建設時優先序是 PRIO_DISPATCH(50)（start_build 的 transition），不是 PRIO_PLAYER，所以 :548 那次無來源 release 不被擋（task_arbiter.gd:60-65 只擋 PRIO_PLAYER）。聯集多加的 `release("construction_done")` 對子隊是重複一次，結果一樣；真正需要這個來源的是紮根的玩家主隊（PRIO_PLAYER，:500 現況）。`commit.release_*` 的 Probe 計數會多一次，fp 不看。
5. **n1–n7 是否真會紅在說的位置：n1、n2、n3、n4、n5、n7 會；n6 會紅但漏了 M4。** n3 能咬住是因為 V1 佈置的缺口約 30 料、森林約 4-5 日，超過 ≤1 日容差。要補的負對照：
```
n8  NPC SETTLE 不加「到了」的門                        → S5
n9  採段每 tick 都刷新 last_progress（不看 gain>0）      → V5
n10 執行端不加採段期限                                  → V5b（M2）
n11 persist_strength 只讀 ticks_left                    → P1（M3）
n12 on_arrival SETTLE 另寫一份判準（不呼 own_outpost_reason）→ S1 新增的獨立隊格（M6）
```

# 小項（不擋）
```
· 進場計數：S 系列要有 Probe 進場計（例 subteam.arrival.{camp,settle}.{done,refused,none}）；現在只寫「交件信印 refused 次數」，沒定義從哪讀。
  採段也要：construct.gather_ticks／construct.gather_done／construct.gather_abort 與 gathered 總量，否則 V8「派出>0」可以由「每個都帶夠料」滿足，採段從沒跑過而全綠。
· 守恆：採到的料 tile → construction_target["site_stock"]（不在任何 bank），完工後消失、逾時退一半。tile 側 pool_set 的 reason "site_gather" 會進 record_driver_store（tile_bank.gd:107）；
  site_stock 這一側沒有帳。請實作端確認有沒有料量守恆的稽核會把它看成憑空消失，有就給完工消耗與退料各一個具名 reason。（我沒讀稽核端，這條是提醒不是斷言。）
· day_fraction：_tick_construction(state, tile) 簽名不帶它，tick_all 的區域變數 day_fraction（outpost_system.gd:253）傳不進去。
  建議直接讀 1.0 / build_ticks_per_day()（:172-177，build_eta_days 已用同一個），不要「讀呼叫端」。
· §一 對 corvee_site 的「30 個讀點」：我 grep scripts 下實際約 15 處（commitment_fields、decision_context:832、faction_ai:7290/7329/7522、persist_strength、task_arbiter:438、state_fingerprint:393…）；
  交件信的逐一判斷以實際 grep 為準，不必湊 30。其中 decision_context.gd:831-835 的 recovery（玩家以外、有 corvee_site 就 settle_resume_site）會因主隊建設也寫 corvee_site 而多吃一類來源，請在那一格寫判斷。
· spec 現況的 :386-404、:400 行號偏了：材料分支在 resource_system.gd:403-404，labor_mult 取值在 :393-395，且條件是 `home_tile.labor_alloc.has(lkey)`，不是「非工位格」。
  抽 material_gain 時 labor_mult 要由呼叫端傳（spec 已這樣寫），L0 工地格 labor_alloc 為空 ⇒ 中性，結論不變。
```

# 給藍圖的一問（經 systems 轉）
```
L1 要材料 ＋ 就地採 ＋ 地形生成區間 ⇒ 新點事實上只有森林（約 7 日）與山地（約 22 日）能蓋；平原（農地）約 72 日，在 30 日窗內等於蓋不成，除非帶料。
這是 WHAT 後果（農業用地開不出新點，除非先備料），不是 bug。請 systems 把上面的量級（實作端用真函式算過再印）放進交件信，讓藍圖看過再決定窗與選址是否要連動。
我不裁。
```

# 判決
```
verdict: issues
必補：M1（單位）、M2（期限）、M3（持守）、M4（到了的門）→ 擋 dispatch
      M5、M6 → 必補，可同版
補完後請再送一輪（M1/M2 動了估算器與驗收，值得再審一次）
其餘（答 1/2/4、小項）不擋
```
