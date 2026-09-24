# HOW spec：打聽 v1 —— 情報必進 belief ＋ 代價＝對方同意

owner: systems ｜ 2026-09-25 ｜ **player_reachable: yes**
上游：blueprint 裁定信 `2026-09-25-blueprint-to-systems-RULING-inquiry-v1-consent-weighed-and-intel-enters-belief.md`
（①打聽到的情報必進 belief，走既有 claim 寫入路徑、禁另開表 ②代價 v1 ＝ 被問領袖【同不同意】，非常數價
 ③收費不在 v1 ④零時間成本 ⑤排 #4 merge 之後、第二輪玩測之前）

---

## ★★★§1 前提（全部逐函式體讀過；★最後三條會改變這張票的形狀）

```
①`inquiry_system.gd:38-82 resolve_inquiry()` **回一個 Dictionary，全程零寫入**
  ⇒ ★這就是票5 P13b 量到「連呼 5 次 fp 不變」的真因 —— 不是沒接線，是**這條路本來就不改世界**。
②`player_command_system.gd:803-811 _action_confirm_gather_intel()` 把它塞進 `payload` 回傳。
③★★`text_ui_main.gd:2305-2308`：UI 只印 `r.get("message")` ＝ 字串 **「情報獲取」**
  ⇒ ★★★**payload 從來沒有被渲染過** —— 玩家今天打聽完，得到的是四個字。
  ⇒ 所以現況不是「有東西但沒進 belief」，是**兩半都沒有**：既不寫，也不給看。

④★★★`message_system.gd:217-277 _exchange_intel()` ＝ **一次完整的情報交換已經存在**：
    決定態度 → 複製訊息進 `team_known` → 逐 target 取 `best_estimate` → 失真 → 算可信度
    → relay-discovery → `BeliefSystem.record_claim(...)`（:277）。
⑤★★★`message_system.gd:194-207 _decide_exchange_mode(state, giver, receiver)`：
    `rep = giver.known_reputations.get(receiver.team_id, 0.5)`（★**被問方**對問話方的評價）
    × 領袖 `values["慎重"]` ＋ `skills["計謀"]`
    ⇒ 回 `"silent"` ／ `"malicious"` ／ `"unintentional"` ／ `"honest"`。
  ⇒ ★★**blueprint 要的那把秤（關係／敵意／人格 ⇒ 拒答或答）已經在 code 裡，而且方向就是對的。**
⑥`belief_system.gd:260 record_claim(state, obs_id, tgt_id, source_id, source_type, fields, credibility, distorted)`
  ＋ `:14 CRED_BASE {親見 1.0／隊友 0.8／商旅 0.6／流民 0.3}`、`:60 source_credibility(..., hop)`。
  ★玩家預設 `faction_id = -1` ⇒ `_claim_source_type()`（:209）給「流民」＝ cred 0.3。合理，不改。

⑦★`inquiry_system.gd:113 _calc_relationship(_state, a, b)` 讀的是 **`a`（問話方）對 b 的評價**
  ⇒ ★★**方向跟裁定相反**：今天是「我喜不喜歡他」在決定「他給不給我」。
⑧★★`inquiry_system.gd:116-126 _find_food_tiles()` **掃 `state.world.tiles` 全圖真值**
  ⇒ 那是 god-view：它給的不是被問隊知道的事，是世界的事。
⑨★★★`player_query_api.gd` **沒有記憶頁**（全檔唯一提到 belief 的是 `:8` 一行註解）
  ⇒ 驗收句要的「記憶頁多那幾筆」今天**沒有地方可以看**。
⑩`_exchange_intel` 有 7 個 bed 直接呼叫（`headless_test.gd:682,683,708,718,724`／`godview_b_test.gd:95,106`）
  ⇒ ★**簽章不得改**（只能加有預設值的尾參數），否則回歸床當場炸。
```

## ★★§2 感知鐵律自查（★我 owner invariants，寫在這裡是要給 R② 打的，不是宣告）

```
・打聽的前置是既有的 `interact-team`（雙方同格）⇒ **不是跨距瞬間作用**。
・內容全部取自【被問隊自己的 belief】（`best_estimate`／`team_known`）⇒ 他不知道的給不了。
・★★本票【縮小】一處既有的 god-view（§1⑧），**不新增任何一處**。
・★★★而我要先認一件事：`ask_faction_status`（`inquiry_system.gd:76-81`）讀的是
  **玩家自己的 faction** ⇒ 那是 self-knowledge，不是洩漏；但它也因此**不該寫 belief**（見 §3(D)）。
```

## §3 裁定

### (A) ★★★不新造秤、不另開表：打聽成功 ＝ 走既有那條 relay

```
做法：給 `_exchange_intel` 加一個【有預設值的尾參數】
    func _exchange_intel(state, giver_id, receiver_id, topic: String = "") -> void
  ・`topic == ""` ⇒ 逐字現況（§1⑩ 的 7 個 bed 與 `:187-188` 不受影響）
  ・`topic != ""` ⇒ 只寫該主題涵蓋的那些 claim（見 (D)）
打聽成功 ＝ `_exchange_intel(state, npc_id, player_team_id, topic)` 【單向】。
★單向的理由：打聽是「我問他」，不是互換 —— `:187-188` 那兩行是【到達】的語意，不是本票的。
★★禁止另寫一份 claim 組裝碼：**只要出現第二個 `record_claim` 呼叫點，這一票就寫錯了。**
```

### (B) 同意 ＝ 既有 `_decide_exchange_mode` 回不回 `"silent"`

```
拒答 ＝ `mode == "silent"`（§1⑤ 的三個輸入已經涵蓋 blueprint 列的關係／敵意／人格）。
★零新常數、零新人格欄、零新表。
★★「同勢力」那一格也已經在：`_claim_source_type`（:209）同 faction ⇒「隊友」cred 0.8。
★★★而「說謊」不是本票發明的第三態：`malicious`／`unintentional` 是**既有的**
   ⇒ 答應了仍可能給假情報，**那是既有行為，本票不得把它關掉**（關掉＝偷偷簡化世界）。
```

### (C) ★★★三句話，機械可判（blueprint 驗收句要求「兩句要分」）

```
①`mode == "silent"`                         ⇒ 「他不願多說」  ★belief 零寫入
②非 silent，但該 topic 一筆 entry 都組不出   ⇒ 「他也不知道」  ★belief 零寫入
③其餘                                        ⇒ 列 claim 摘要 ＋ 來源「來自 TeamX」
★判準是【兩個不同的字串】：grep 只找到其中一句 ⇒ 驗收紅（見 P4）。
★★這三句走【佇列消費點】回玩家（指令佇列 spec §3-5 契約②），**不當場判**
  —— 判準句（blueprint 逐字）：「答案會不會因為推進一顆 tick 而變？」會 ⇒ 不當場。
```

### (D) topic → 既有 5 個 id 的對照（★不新造主題）

```
ask_team_location   → 逐 target 的 tile_pos／population_est（＝ `_exchange_intel` 既有欄位）
ask_enemy_movement  → 同上，但 target 限 `faction_id != 玩家 faction`（＝ `inquiry_system.gd:61` 既有條件）
ask_recent_events   → `_exchange_intel` 的 `team_known` 訊息複製那一段（:227-240）
ask_food_source     → ★母體從【全圖】收到 **`state.team_tile_known[npc_id]`**（`world_state.gd:63`）
                       ⇒ ★★只給「被問隊見過的格」；食物【量】本身仍是即時真值
                       ⇒ ★★★那一半登待辦（食物要像據點那樣有自己的時戳子記錄，
                         `belief_system.gd:487-500` 已經示範過「兩個事實兩條線」怎麼做）
ask_faction_status  → ★**不寫 belief**：它問的是玩家自己的 faction（§2）⇒ v1 維持純結果句。
                       ★★而這一條是【刻意的例外】，所以它要在 code 裡寫明理由，不是漏掉。
```

### (E) 修 §1⑦ 的方向

```
`_calc_relationship(state, a, b)` 的呼叫端（`:24` get_options／`:41` resolve_inquiry）
改成秤【被問方對問話方】的評價 —— ★與 (B) 同源，**不要兩把秤**。
★★注意 `:42 honest = rel > 0.5` 也吃它 ⇒ 方向修正會連帶改變誰說實話。
   那是**修對**，不是副作用：說不說實話本來就該由說話的人決定。
```

### (F) 拒答不寫恩怨帳（v1）

```
★理由：寫了 ⇒ 問一次就掉關係，而玩家**事前沒有任何預警**（選單不顯示對方態度）
  ⇒ 那是無感代價，而無感代價會教玩家不要用這個功能。
★★登待辦：等選單能顯示「他看起來不太想理你」之後再談要不要記。
```

### (G) 零時間成本 ＋ 記憶頁（最小）

```
・時間：同其他互動，在消費 tick 內完成（blueprint 裁）。
・★★★記憶頁：查詢面新增 `query_memory_panel(state)` ⇒ 讀 `state.team_intel[ptid]`
  （`BeliefSystem.claims()`／`known_targets()`，**只讀、零寫、零 RNG**）。
  欄位：target 隊、claim 筆數、最新 tick、來源（source_id → 隊名）、是否 `is_suspicious`。
  ★沒有它，(A) 做完了玩家也看不見 ⇒ 而看不見的需求【不會回來敲門】，
    它會變成「打聽好像沒用」然後沒有人再提。
```

## §4 驗收（★P4／P5／P8 是母體地板，缺了 P1 會在好世界裡恆綠）

```
P1  問成功一次 ⇒ 玩家隊 claim 數 +≥1 且 world-fp **變**（票5 P13b 由「不變＝對」翻成「變＝對」）
P2  ★負對照：把 (A) 的那一次 `_exchange_intel` 呼叫拿掉 ⇒ P1 必紅
P3  拒答：造一個對玩家 rep 低、領袖計謀高的隊 ⇒ mode=silent ⇒ claim 數**不變**、句子＝「他不願多說」
P4  ★★「不知道」≠「不願說」：造 mode≠silent 但該 topic 零 entry ⇒ 第三句，
    且**兩個句子的字串不同**（床要 grep 兩句各一次；只找到一句 ⇒ 紅）
P5  ★★★母體地板：P3／P4 必須**印出它們的前置條件**（實際的 mode、giver 的 known 數）
    ⇒ 沒有這兩行，P1 在「每次都 honest 且對方什麼都知道」的世界裡恆綠，而我們不會知道
P6  來源：`claims(state, ptid, tgt)` 裡新那筆的 `source_id == 被問隊 id`；記憶頁印得出「來自 TeamX」
P7  ★重構零行為：`topic=""` 路徑不動 ⇒ **world-fp 不變**（這是 (A) 抽參數的判準，不是功能的判準）
P8  ★食物收窄的負對照：造一塊【被問隊沒見過】的高食物格 ⇒ 它**不得**出現在結果句
P9  ui-flow 綠；merge 前全電池（`bash .claude/hooks/merge-gates.sh` ⇒ BATTERY_RC=0）
```

## §5 不在本票

```
✘ 收費（幣／物換情報、商人賣情報）—— blueprint 裁：等賣家兩型與市場厚度，不偷渡常數價
✘ 問話佔時間（TimeScale 的事，另票）
✘ 食物【量】的時戳子記錄（§3(D) 登待辦）
✘ 拒答寫恩怨帳（§3(F) 登待辦）
✘ 新主題（v1 就這 5 個 id）
✘ 把 `malicious`／`unintentional` 關掉（§3(B)：那是既有世界，不是本票的髒）
```

## ★§6 誠實限

```
①本 spec **沒有跑 Godot**，全部靜態 file:line。
②★我**沒有量** `_decide_exchange_mode` 在真實世界回 `"silent"` 的比例
  ⇒ 「拒答會不會太常見／太罕見」是**玩測與量測的問題，不是 spec 的問題**。
  ★★而它有一個現成的量法：床裡把 mode 的四種計數印出來（P5 那兩行順手就有）。
③★★失真路徑（`DistortionEngine`）會耗 RNG。打聽走玩家指令的消費點 ⇒ 在 tick 內、可重現，
  但**本票不改它**，也不宣稱它乾淨。
④★★★§1③（UI 沒渲染 payload）是我讀 code 讀出來的，**不是玩測回報的**
  ⇒ 所以我不知道玩家有沒有因此以為「打聽壞了」。那是第二輪玩測該問的一句。
```

---

## ★★★§7 追裁（2026-09-25 開工後三問，systems 裁；★其中一條是訂正我自己）

```
(1)★§3(D) 的 `state.world.tiles` 目標是 **2 → 1，不是 1 → 0**。
   ★★訂正我自己：派工信寫 1 → 0 是錯的 —— §3(D) 明寫「食物【量】仍是即時真值」
     ⇒ 取值那一行必然留著；能到 0 的只有做掉 §5 明列不在本票的那一半。
   ⇒ 留下的那一行標 `# gate-ok:`（同 `belief_system.gd:492` 的形狀），
     ★而註解裡**必須寫出延後表 id 的字面**：`food-amount-has-no-timestamped-subrecord`
     ⇒ ★★這樣它不是辯解，是一個 grep 得回來的連結。

(2)`_exchange_intel(` 的呼叫點：動工前 **9**（7 床 ＋ production `:187-188`），另 1 行是定義；動工後 10。
   ★`_step3b_exchange_intel(`（`sim_runner.gd:785`）是**子字串誤中**，不是第 10 個。
   ⇒ ★★驗它的 grep 要明寫排除【定義行】與 `_step3b_` —— 否則下一個人數出 11 還以為自己對。

(3)★★★介面：`_exchange_intel(state, giver, receiver, topic := "", out := {})`，
   而 `out` **必須同時帶兩個值**：`mode` ＋ `written`（本趟 `record_claim` 的次數）。
   ★理由①：`message_system.gd:191-192` 的 hostile 分支 `randf() < 0.3` **耗 RNG 且同輸入不同答**
     ⇒ 呼叫端不得再秤一次（觀測改變被觀測物 ＋ 兩把秤）。
   ★★理由②：第三句「他也不知道」的判準 ＝ **這一趟寫了幾筆**。
     若呼叫端回去數 claim 來推，那是**第二次計算**，而它可以跟真正寫入的那一趟不一致
     ⇒ 同族血證：不變量 #6 要求「同一次回傳」，而我自己設計過讀兩次的介面。
   ⇒ 三句話的分流**全部吃 `out`**，不得回去重數。
   ★不選「把回傳改成 String」的理由不是「不在規則裡」（改回傳型別不會動到 7 個床）——
     是**它只帶得動一個值**。
```
