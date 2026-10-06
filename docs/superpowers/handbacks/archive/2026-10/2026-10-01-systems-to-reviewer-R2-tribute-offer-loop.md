---
from: systems
to: reviewer
status: consumed
slice: 進貢提案（`tribute_offer`）—— 接受要收得到貢，而提案者要讀得到結果
topic: R② 設計審｜spec `docs/superpowers/specs/2026-10-01-tribute-offer-loop-and-the-unconsumed-result-HOW.md`｜★★★這張票**現在就卡在你這一關**（藍圖裁它「排在終端骨架之前或併行」，而實作端序列做 ⇒ **併行就發生在你這條線上**）｜★要你優先打的是 §3③「三個出口共用一支收尾函式」與 §3④ 那條差集是否真異源
---

# 一、這張票是什麼（一句）

用戶第三輪玩測：對方「要向你進貢」→ 按接受 → 畫面印「**未知提案類型**」→ **兩小時後再來一次**，
★**而接受或拒絕都一樣重提**。

# 二、★真因（我開檔核過，而它比票上寫的更小）

```
**NPC↔NPC 那條路【已經有】收尾三件**（`interaction_system.gd:550-556`）：
  `TaskArbiter.release` ／ `diplomacy_reject_cooldown[target]` ／ `order_task = ""`
★**而玩家那條路（`:290-301 set_player_forced_event`）一件都沒有**
⇒ ★★不是「新增一個 handler」，是**把已經存在的收尾接到玩家那一側**
⇒ ★★★而它正好解釋用戶那句「**接受或拒絕都一樣重提**」：三個出口**都**沒有收尾。
```

# 三、★★★要你優先打的三處

```
①**§3③ 三個出口（接受／拒絕／逾時）共用一支收尾函式** ——
   我寫「抽一支共用的收尾函式，三處各呼一次」（形狀沿用 `refuse_if_not_in_encounter`）
   ⇒ ★要你打：**逾時那一條出口在哪**？我只核到 `sim_runner.gd:694` 有 forced_event 逾時的處理，
     **而我沒有逐支確認它會不會走到同一個地方** ⇒ 若它在另一個檔，那支共用函式要放哪裡？
②**§3④ 那條差集是否真的異源**：我寫「`player_api_mapper` 的提案字串表 × handler 的 `match` arm
   ⇒ 差集必空」並斷言它**異源**（一邊給玩家看的字串、一邊是 dispatch）
   ⇒ ★要你打：**它們會不會其實同源**（例如字串表是從 registry 導出的）？
     ★★若同源 ⇒ 那一格恆真 ⇒ 要換一邊（我今天才剛在另一票上栽過這個）。
③**金額那一半我用的是既有函式**：`diplomatic_ai_system.gd:244`
   `apply_tribute_accept(state, payer, taker) -> float`（`:251` `coin_before * TRIBUTE_TAKE_RATIO`）
   ⇒ 方向：`payer` ＝ 來進貢的那一隊、`taker` ＝ 玩家隊
   ⇒ ★要你打：**那支函式的副作用在玩家當 taker 時是否都成立**
     （`:254-258` 會寫 NPC 記憶 `"tributed"`；而它原本的語境是 `demand_tribute`）。
```

# 四、我已查完、所以不要你花時間的

```
·`TRIBUTE_TAKE_RATIO` 的字面**不得出現在本票**（`player_command_system.gd:1710` 那條既有紀律）。
·「刻意不接 `tribute_offer`」那段註解是 **systems 2026-09-30 的裁定**，而它**只做對了一半**
  （擋住了錯的改法 ＝ 併進 `"tribute"` arm 會走 `_pay_extortion` ⇒ 倒付；
   ★而沒有開「正確那一半」的票）⇒ 判準已寫進 spec §2。
·倒付守衛（`forced_event_panel_bed` 那一格）**保留且不得弱化**，而本票要加**正向格**
  （按接受之後玩家 coin **必須增加**，且量 ＝ `apply_tribute_accept` 的回傳）。
```

# 五、時程

★**你這一關是這張票唯一還沒過的** —— 實作端序列做（終端骨架 → 本票），
所以**你現在審，就是藍圖說的那個「併行」**。而它不急到要你插隊別的事。
