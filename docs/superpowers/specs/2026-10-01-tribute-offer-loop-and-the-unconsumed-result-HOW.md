# HOW：進貢提案（`tribute_offer`）—— 接受要收得到貢，而提案者要讀得到結果

- **WHAT 權威**：用戶第三輪玩測（截圖坐實）＋blueprint 票
  `docs/superpowers/handbacks/2026-10-01-blueprint-to-systems-TICKET-tribute-offer-accept-is-unhandled-and-the-offer-loops.md`（`08d1f69c6`＋§六 `3c6e068e7`）
- **現象（用戶）**：19:00 Team11「要向你進貢」→ 按接受 → 「**未知提案類型：tribute_offer**」→ 21:00 再來一次；
  ★**而接受或拒絕都一樣重提**（用戶自己補的，這一句決定了修的重心）
- **HOW owner**：systems｜**序**：★引擎側真 bug 且每兩小時打斷玩家 ⇒ **排在終端骨架之前或併行**
- **基準樹**：`08d1f69c6`（以下每個 `file:line` 都在這棵樹上開檔讀過）

---

## §1 ★真因精確化（我開檔核過，而它比票上寫的更小、更可修）

```
票上寫「這條 proposal 不走 `_send_diplomacy_message` ⇒ 沒有 REJECT_COOLDOWN」。
★而實測：**NPC↔NPC 那條路【已經有】收尾三件** ——
  `interaction_system.gd:550-556`：`order_task == TASK_TRIBUTE_OFFER` ⇒
    ①`TaskArbiter.release(initiator)`
    ②`initiator.diplomacy_reject_cooldown[target_id] = … + DiplomaticAiSystem.REJECT_COOLDOWN`
    ③`initiator.order_task = ""`（註解逐字：「清 order_task（防殘留→下次外交/結盟誤路由為求和）」）
★★而**玩家那條路（`interaction_system.gd:290-301 set_player_forced_event`）一件都沒有** ——
  它只寫一個 forced_event 面板就回去了。
⇒ ★★★所以真因是：**同一個狀態機有兩條出口，而玩家那一條沒有收尾** ——
  **不是「新增一個 handler」，是把【已經存在的收尾】接到玩家那一側。**
⇒ 而這正好解釋用戶那句「**接受或拒絕都一樣重提**」：三個出口（接受／拒絕／逾時）
  **沒有任何一個**會 release／冷卻／清 `order_task` ⇒ 任務還在 ⇒ 下一輪再提。
```

## §2 ★★而「刻意不接」那段註解是我自己的裁定，它只做對了一半

```
`player_command_system.gd:1717-1725` 逐字：「★★★注意這裡【沒有】`tribute_offer`，而那是刻意的…
  若把它併進上面那支 `"tribute"` arm，會走 `_pay_extortion` ⇒ ★**變成玩家付錢給來進貢的人**」
  （systems 裁 2026-09-30，守它的是 `forced_event_panel_bed` 那一格）
★那個判斷**是對的**（「把所有字串都加進 match」確實比現在的 bug 更糟）。
★★**而它只做了一半**：我擋住了錯的改法，**卻沒有開票把正確的那一半做掉**
  ⇒ 留給玩家的是：**永遠收不到貢品 ＋ 畫面印一句內部錯誤 ＋ 每兩小時再問一次**。
⇒ ★★★判準（寫給自己）：**裁「不做 X」的同時要開「正確的那一半」的票** ——
  否則一個**刻意的空缺**會長成玩家面的缺陷，而它的卷面長相是「這裡有一段很有道理的註解」。
```

## §3 做什麼

```
①**接受 ＝ 收貢**（新 arm，**不要併進 `"tribute"`**）：
   ★金額**不要新算也不要抄常數** —— 用既有那支：
     `diplomatic_ai_system.gd:244 static func apply_tribute_accept(state, payer, taker) -> float`
     （`:251` `amount = coin_before * TRIBUTE_TAKE_RATIO`；`:252-253` `payer→taker` 轉 coin）
   ⇒ **方向**：`payer` ＝ 來進貢的那一隊（`from_team`）、`taker` ＝ 玩家隊
   ⇒ ★★所以「金額用 NPC 側自己算的那份」**已經成立**（它吃 payer 自己的 coin），
     而本票**不得出現 `TRIBUTE_TAKE_RATIO` 的字面**（同 `:1710` 那條既有紀律）
   ⇒ ★★★附帶已經有的東西：`:254-258` 會寫 NPC 記憶 `"tributed"`
     ⇒ 「對方記得」那一半**不必新做**。
②**拒絕 ＝ 婉拒**：結果**必有一句話**（「拒絕禁靜默」）＋對方記得（同 NPC 被拒的後果）。
③★★★**提案者消費結果**（blueprint §六：**修的重心在這裡，accept 的 arm 只是一半**）：
   接受／拒絕／**逾時**三個出口**各自**都要做 §1 那三件（release／冷卻／清 `order_task`）
   ⇒ ★**實作形狀**：不要在三個地方各抄一次 —— 抽**一支共用的收尾函式**，三處各呼一次
     （形狀沿用已核過 CLEAN 的 `refuse_if_not_in_encounter`：單一定義 ＋ 三個消費者 ＋ 反向掃）。
④`player_api_mapper` 的提案字串表 × handler 的 `match` arm ⇒ **差集必空**
   ★而這兩邊**異源**（一邊是給玩家看的字串表、一邊是 dispatch）⇒ 它不是恆真格
   ⇒ 差集非空 ⇒ **紅並指名那個字串**（★這一格擋的是「下一個提案類型又忘了接」）。
⑤**倒付守衛保留**（`forced_event_panel_bed` 那一格：按接受之後玩家 coin **不得減少**）
   ⇒ ★**而要加正向格**：按接受之後玩家 coin **必須增加**，且增加的量 ＝ `apply_tribute_accept` 的回傳
   ⇒ ★★兩格一起看才完整：舊格守「不要變成倒付」、新格守「它真的收到了」。
```

## §4 地板（P）

```
P1 [接受] 造一個 `tribute_offer` forced_event ⇒ 按接受 ⇒ 玩家 coin **增加**、對方 coin **減少**
   ★母體地板：對方 `coin_before > 0`（否則 `apply_tribute_accept` 回 0 ⇒ 這一格恆綠）
P2 [不倒付] 既有那一格**不得弱化**（★它的負對照是「故意併進 `"tribute"` arm ⇒ coin 減少 ⇒ 紅」）
P3 [★三個出口各自不再重提] 接受／拒絕／逾時**各一格**，各自斷言 **24h 內零再到達**
   ⇒ ★★**各自獨立紅**（blueprint 明寫）⇒ 不准用一格覆蓋三件
   ⇒ ★★★床要**印到達序列**（tick ＋ 提案類型 ＋ from_id）—— 否則「零再到達」在一個
     「對方根本沒機會再提」的世界裡恆真
P4 [結果必有一句] 三個出口的回傳 `msg` 皆非空，且**不得含內部識別字**
   （★「未知提案類型：tribute_offer」就是這一條的反例樣本）
P5 [差集] ④那條：mapper 字串表 ∖ handler arm ＝ ∅ 且 handler arm ∖ 字串表 ＝ ∅（雙向）
P6 [收尾單一定義] §3③ 那支共用函式**只有一處定義**、**三個呼叫點**，反向掃無第四處自己寫的收尾
P7 [電池] 全電池（★本票改引擎與床 ⇒ 那幾格的綠必須是新檔的綠）
```

## §5 不在本票

```
✘ 「真息兵行為」的其餘部分（`interaction_system.gd:544` 註解逐字把它登為 backlog／WHAT）
  —— ★而**本票把其中一半答掉了**（接受＝收貢），剩下的留在那條註解裡
✘ `demand_tribute`（玩家向對方要貢）那條路的任何改動
✘ 畫面那六個缺陷（它們在終端 REPL 那張票的自驗母體裡）
```


---

## §6 R② 紀錄（reviewer，`532648d89`，verdict ＝ **issues**）—— 三件逐件處理完

### ★①逾時出口的位置查到了，而它比我寫的更麻煩（他的 file:line，我採用）

```
`sim_runner.gd:685-699` ＝ **服務「所有非 aid_request 的 forced_event」的通用收尾段**
⇒ ★**不能整段套共用函式** ⇒ 要在裡面新開一個
  `action == "diplomacy" and proposal == "tribute_offer"` 的**專屬分支**才呼。
★★而「那支共用函式放哪裡」他也答了：`sim_runner.gd` **沒有 `PlayerCommandSystem` 的實例參照**
  ⇒ 共用收尾函式做成 **`static func`**（★本專案 `TaskArbiter.release`／
  `DiplomaticAiSystem.REJECT_COOLDOWN` 都是這樣被類別名直呼的 ⇒ **不是新花樣**）。
★★★而他順手核了**拒絕出口**：`player_command_system.gd:1475` 的 `"refuse"`
  同樣是**所有 diplomacy 提案共用**的通用分支
  ⇒ 共用收尾函式在那裡被呼時要**先判** `from_team.order_task == TeamData.TASK_TRIBUTE_OFFER`
  —— 否則會對 alliance／surrender／propose_trade 的 NPC **去清一個它們沒設過的 `order_task`**。
```

★**而這裡我要糾一個措辭**：他寫「多半無害 no-op 但精確度要寫清楚」——
⇒ ★★**不要寫「多半無害」**：我今天才在一份「母體窮盡」的裁定裡**替一整桶編了理由**
（判「舊 leader 已死 ⇒ skip 保護」，而那個 skip 從來沒被觸發過）。
⇒ ★★★所以**加那個 `if`**（它便宜），而**不要**用一句「多半無害」把它留著 ——
**一個沒有被逐情境驗過的 no-op，它的理由就是編的。**

### ★②異源確認成立，而它今天就會紅（不是空判準）

```
mapper 側（`player_api_mapper.gd:351-358`）與 handler 側（`player_command_system.gd:1734-1769`）
是**兩支獨立手打的 match**，★而**歷史上真的漂過一次**（`:1747` 註解自己記著 `demand_tribute` 那次 bug）
⇒ 他獨立列了兩邊今天的字面集合，**差集 ＝ {tribute_offer}** ⇒ 與症狀逐字對上
⇒ ★★所以 P5 **今天就會紅** —— 它不是「等未來才生效的空判準」。
```

### ★★★③裁：**甲**（accept 路徑不連帶寫那筆記憶）＋ 乙 的那一半**呈藍圖**（不擋）

```
他查到的真問題：`apply_tribute_accept:254-258` 的
  `write_memory(payer_leader, "tributed", taker.leader_id, …)`
而 `npc_ai_system.gd:117` 把 `"tributed"` 歸在 **betrayal／looted／special_taxed／rejected_aid**
同一組 ⇒ 走 **`form_feud`（結仇邊）**；`grudge_ledger_bed.gd:170` 也把它分類成 feud 類，
來源列的是 `demand_tribute`（遠程索貢）與 `resolve_extortion`（同格勒索）**兩個強制情境**。
⇒ ★直接重用在**NPC 主動送禮**的 `tribute_offer` 上 ⇒ 語意變成
  「**NPC 主動示好，而這個動作本身讓它對玩家結仇**」⇒ **方向是反的**。
★★而他也量了嚴重度：`FEUD_SEVERITY` 表**刻意不收** `"tributed"`、用 intensity（≈0.1）當嚴重度、
  `FEUD_MIN = 0.30` ⇒ **多半不會跨門檻**，但**人格乘子極端時還是可能** ——
  而那時玩家會看到「**剛送我東西的 NPC 突然對我有仇恨值**」。
```

★**裁：甲** —— **accept 路徑只重用「轉帳」那一半，不連帶寫那筆記憶。**
理由是 **HOW 層的**（所以我裁，不丟藍圖）：**同一支函式同時做「轉帳」與「寫關係」，
而那兩件事的方向在不同情境下不同** ⇒ ★★那是**一個函式承擔了兩個語意**
⇒ 重用它 ＝ 把**強制情境**的關係語意**偷渡**到**自願情境** ⇒ 拆（只用轉帳那半）。
★★★而「**NPC 主動送貢之後，它對玩家的感覺應該是什麼**」是 **WHAT** ⇒ **呈藍圖**（乙 的那一半：
`npc_ai_system.gd:126-128` 已有 `kindness／aided_in_battle／benefactor` 走 **gratitude** 的形狀可參考）
⇒ ★而它**不擋本票**：甲 是**不表態**的安全底（零關係寫入），乙 可以日後作為一個**刻意的 WHAT 決定**加上去。
★**否決丙**（維持現狀＋寫理由）：理由會是「門檻很少跨過」—— 而那正是
「**替一個沒被驗過的 no-op 編理由**」那一族（見上面 ①的糾正）。

### ★★★★而他建議的那一格地板我採用，並補上它的反向走法

```
他：「本票 §4 地板目前沒有一格驗這半 ⇒ 至少加一格斷言
  『按接受之後 payer_leader 新增那筆 memory 的 type 跟你選的方向一致』。」
⇒ P8 [關係副作用的方向] 按接受之後，`payer_leader` 新增的
  **`"tributed"` 類記憶 ＝ 0 筆**（＝裁定甲：accept 不寫關係）
⇒ ★**反向走法（照「＝ 0 的斷言要有反向走法」那條）**：
  **`demand_tribute` 那條路必須寫得出 `"tributed"`** ——
  ★★否則那個 0 分不出「**accept 不寫**」與「**那個記憶機制整個壞了／被刪了**」。
```
