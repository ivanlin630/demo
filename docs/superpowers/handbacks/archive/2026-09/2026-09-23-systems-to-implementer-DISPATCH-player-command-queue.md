---
from: systems
to: implementer
status: consumed
slice: 玩家指令佇列化
topic: ★DISPATCH（R² CLEAN）：玩家指令改成**進佇列、在 tick 的固定一點被消費**，讓「同種子＋同一份指令記錄 ⇒ 逐字相同的結局」成立｜★★★負對照必須**跨過小時或日的邊界**，不是 ±1 格（同一小時內位移一格很可能逐字相同 ⇒ 那個負對照會恆綠）｜★P4 的豁免不是我說了算：把 `player_state` 整個換空跑一輪，fp 要不變
---

# 一、票與順位

spec：`docs/superpowers/specs/2026-09-23-player-command-queue-HOW.md`（R² CLEAN）。
**第五順位**：票B 電池 → 未加種子的閘床 → 查詢面補「家」→ render 不得寫 state → 本票。
★這張最大，★★所以它排最後不是因為不重要，是因為前四張都會動到它要踩的那些檔。

# ★★二、消費點釘死在哪（★這是全票的支點）

```
消費點 ＝ `_step1_advance_time()` **之後**，★★而【兩條分支都要】——
  包含 `encounter_active` 那一條（★漏掉它 ⇒ 遭遇戰期間的指令在另一個時間點生效 ⇒ 重播就對不上）
⇒ ★★★「決定性」在本票的定義是【重播可重現】，不是「每次跑都一樣」——
  那兩件事不同，而混用會讓你去修一個不存在的病。
```

# ★★★三、負對照為什麼要跨邊界（★這條是 R² 訂正我的）

```
我原本寫「把某條指令的 tick ±1」⇒ ★同一小時內位移一格，fp 很可能【逐字相同】⇒ 負對照恆綠
⇒ 改成【跨過一個小時或一天的邊界】：
   day_boundary 上 check_starvation_deaths／flush_forage_episodes／訊息剪枝本來就在動東西
   （`sim_runner.gd:490` 一帶）；hour_tick 上有 NEAR_CADENCE 的到期檢查
⇒ ★★★所以【母體選擇本身帶保證】：前後保證有世界差異，不是「可能有」。
★通則：一個負對照如果只是「大概會不一樣」，它就是一格會騙人的綠。
```

# 四、驗收（spec §5，逐格；四格互相咬）

```
P1 佇列：下指令後、推進前讀世界 ⇒ 沒變；推一個 tick ⇒ 變了
P2 重播：同種子＋同一份 command_log ⇒ final_fp 逐字相同
   ★母體非空：那份 log 至少 N≥5 條【真的改到世界】的指令｜★★負對照見上（跨邊界）
P3 無後門：grep 斷言 production 路徑上沒有 dispatch 的直接呼叫，只有消費點那一處
P4 ★豁免要證明：對每個寫進 player_state 的 key，證明它不被任何系統讀
   ⇒ 做法＝把 player_state 整個換成空的跑一輪，fp 不變（★母體＝那些 key 真的有被設過）
P5 ui-flow 綠（★指令語意變了 ⇒ 那 26 支 cell 會逐一面對「要先推進才看得到」）
P6 world-fp 不變（無人世界不下指令 ⇒ 佇列恆空 ⇒ 必須逐字相同）★這格證明你沒順手改到別的東西
P7 merge 前全電池
P8 ★同 tick 競態：同一顆 tick 內先 trade offer 再 move ⇒ 斷言 pending_trade_target 在該 tick 結束時已清除
   ★★這格不是在測 bug，是把「由順序決定的結果」釘成守衛
```

# 五、不在本票

見 spec §6。★**不要**順手擴成「所有輸入都走佇列」——那需要先有母體（先數有幾種輸入）。

★做完送 R² 給 reviewer＝demo-60，並立刻 SendMessage 敲他。
