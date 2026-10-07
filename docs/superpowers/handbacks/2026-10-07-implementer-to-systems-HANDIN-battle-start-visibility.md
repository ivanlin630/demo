---
from: implementer
to: systems
status: consumed
slice: 戰鬥區第二輪（F1 R 的回應只有結果行／F2 開戰互見＋親見寫 belief／F3 推進鍵後結果行）
topic: ★**交件｜已知紅 0**｜BATTERY_RC=0｜110 綠／0 紅（run-id `21777-20261007-155724`，HEAD `48e7e5961`）｜branch `feat/battle-start-visibility` 遠端 tip **`2488f4b75`**（已疊 origin/main 33f2ba8f7＝票 T 之後；含 artifact 一顆）｜world-fp 468ffb9e → **f50d38fb**（開戰親見寫 belief，雙方）
---

# 一、改了什麼（spec 2026-10-07-battle-start-visibility-and-r-feedback-HOW.md）

```
F1 原因句其實有印 —— 在戰鬥區最底下「訊息：」，而結果行留著上一道令「✓ 行動：攻擊：發起攻擊」⇒ 兩個出口，玩家看結果行
   ⇒ 單一出口＝結果行：encounter_view.key_reply()（這一鍵的原因句；沒有 ⇒ 這一鍵之後戰報的第一句、玩家那句優先）
   ⇒ 拒絕類 _log 標 ✗；「訊息：」那一行拿掉；text_ui_main.build_regions 戰鬥中 result 讀 key_reply
F2 開戰互見：敵方單位【進過我方視野、之後不在】才入霧（_was_in_view／_left_view）；還沒進過視野的照可見（地圖、目標欄）
   ★第一版「還站在最後看到那一格」被真打抓到（REPL_SEED=2 野獸伏擊：輪到玩家前戰鬥已推進幾 tick、敵人一動就入霧 ⇒ 第一屏看不到敵人）
   畫面外單位印方向鍵＋格數「A（W 方向 15 格）」（六向＝QWEASD 移動同一套）
   開戰親見：VisionSystem.write_sighting（_write_tier01 的公開包裝；dist 0／dist_f 1.0；用 live_team）雙方都寫
   ★偏離（要你知道）：spec 指定掛 NpcCombatSystem.start_combat ⇒ 掛了；★但玩家的戰鬥走 EncounterSystem.init_encounter 開打、
     不經 start_combat ⇒ 只掛那一處的話，畫面上的戰鬥一筆親見都不寫 ⇒ init_encounter 也掛（同一支 write_sighting）
F3 Space／X／G 推進結束時結果行＝「推進到 第 N 天 HH:MM」；被截斷＝「推進停在 …（遭遇戰／看到新的隊伍／stall 原因）」
   （_request_key_advance 記目標 tick；_process 推進結束那一刻寫 —— 不在按下那一刻，走多少是世界的權利）
已知問題清單加三列並標已修
```

# 二、驗收

```
P1 三格修前紅（紅格那顆 6d2773d6d 開獨立樹跑）：F1×2／F2×2／F3 共 5 條 ⇒ 修後綠
   負對照（各改回一處）：結果行不讀 key_reply ⇒ BATTLE④；看得到只看視野 ⇒ F2；推進句不寫 ⇒ F3
P2 E2E errors 0｜已知紅排除 0（E2E 也一起疊了票 T 的床改動）
P3 play.py 真打卷面 docs/measurements/2026-10-07-play-py-real-battle.txt（REPL_SEED=2）：
   推進停在 第 3 天 10:14（遭遇戰）／開戰第一屏 目標：A（野獸）距離 15 格／R「✗ 沒有在攻擊範圍內的敵人（目標 A 距離 15 格，射程 1 格）」
   ／每拍回應在結果行（@（你） 待機、移動到…）／畫面外「A（W 方向 15 格）」／連按 X「✓ 推進到 第 N 天 HH:00」
P4 fp f50d38fb（單跑量；歸因＝開戰親見多寫 belief、多耗 _write_tier01 的 RNG）
```

# 三、電池第一輪紅 3（都是本票造成的）⇒ 已修

```
ui-flow P8s：X 推進那一行改成 _request_key_advance(_snap_to(TICKS_PER_HOUR)) ⇒ 那一行也認（主詞不變）
live-team-ratchet：write_sighting 改用 state.live_team()
fatigue-by-activity P1：RNG 變了 ⇒ 世界出現一刻都沒停過的短命隊（Team34 流亡 65 小時都在覓食走動、Team35 運輸子隊 53 小時都在運輸）
   ⇒ 母體收一刀：疲勞 > 0 時有過不出力 pass 的隊（新探針 fatigue.restpass_pos.byteam，只計數）；降沒降照舊由床逐 tick 取樣判
   ★這是改了票 T 的守衛母體 —— 判準：照機制它們本來就不會降（沒有任何回復 pass），不是回復壞了；沒停過的照印、不判
E2E effect=encounter 快照加 encounter_initial_pop：RNG 變了之後那一步變成「對方接受投降」⇒ 走 cleanup、沒有結算記錄
```

# 四、要你知道的

```
①F2 的「開戰互見」讓還沒進過視野的敵人顯示【真實位置】（spec 的裁定：未走出過 ⇒ 照可見）—— 遠處移動中的敵人位置也看得到，直到它進過視野又離開
②真跑 480 小時沒遇到戰鬥的 seed 不少（1337、3）：追看得到的隊伍常常追不上；play_real_battle 換 seed 才打到
```
