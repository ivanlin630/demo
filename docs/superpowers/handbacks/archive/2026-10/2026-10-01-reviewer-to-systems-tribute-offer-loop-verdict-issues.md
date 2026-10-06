---
from: reviewer
to: systems
status: consumed
slice: 進貢提案（`tribute_offer`）—— 收尾接到玩家側 — R②
topic: verdict=issues（①逾時出口位置查到了且比預期更麻煩②異源確認成立③apply_tribute_accept的grudge副作用方向不對，三件都有具體file:line）
---

# 〇、樹核對

```
spec 基準樹 08d1f69c6，現在 main 是 c305b0c63。核過本票相關五個檔案
（interaction_system.gd／sim_runner.gd／diplomatic_ai_system.gd／player_command_system.gd／
player_api_mapper.gd）在這之間只有 player_command_system.gd 動過（面板去重那票），
其餘四個不變；player_command_system.gd 動的範圍不在本票引用的那三段（:1710 一帶、
_accept_diplomacy、respond_to_forced），逐段核過行內容仍與 spec 引用吻合，可以放心用
現在的 HEAD 審。
```

# 一、①逾時出口：找到了，而且它在第三個地方、什麼都不做

```
`sim_runner.gd:659-699`（hour_tick 那段）：fe_timeout 的處理分兩截——
  (a) :662「`if fe_timeout.get("action", "") == "aid_request":`」有專屬清理（beggar 那段）
  (b) :685-699 是**通用**的收尾，對**任何**非空、非 choose_heir 的 forced_event 都跑：
      只 emit "forced_event_timeout"、印訊息、清 `state.player_forced_event = {}`／
      `player_forced_event_id = ""`——**完全不碰 `from_id` 那一隊的 `order_task`／
      `TaskArbiter`／`diplomacy_reject_cooldown`**。

對 tribute_offer（action=="diplomacy", proposal=="tribute_offer"）而言：
  (a) 不會進（action 不是 "aid_request"）
  (b) 只清玩家側，NPC 側的 `order_task` 原封不動

⇒ 你的猜測成立：**逾時出口在另一個檔**（`sim_runner.gd`，不是 `player_command_system.gd`
或 `interaction_system.gd`）。★而且它比「只是位置不同」更麻煩：這個通用收尾段**同時服務
好幾種 forced_event 類型**（diplomacy 的各種 proposal、extort、join_request…），不能整段
套上共用收尾函式，要**新開一個條件分支**（`fe_timeout.get("action","")=="diplomacy" and
fe_timeout.get("proposal","")=="tribute_offer"`），只在這個分支裡呼那支共用函式。

★放哪裡的答案：共用函式**不能**是 `player_command_system` 的實例方法（`sim_runner.gd`
沒有那個實例的參照路徑，至少我沒找到）。本專案既有同型案例的做法是 `static func`——
`TaskArbiter.release(...)`／`DiplomaticAiSystem.REJECT_COOLDOWN` 在 `interaction_system.gd`
裡都是直接用類別名呼叫，不經實例——建議把共用收尾函式做成 `static func`（放
`diplomatic_ai_system.gd` 或獨立成一個檔），這樣 `sim_runner.gd`／`player_command_system.gd`
都能直接呼，不必互相持有對方的實例。

順帶核過拒絕出口（§3②）：`player_command_system.gd:1475`「`"refuse": result = { "ok": true,
"msg": "拒絕外交提案" }`」——跟逾時一樣，這是**所有 diplomacy 提案共用的通用分支**，不是
tribute_offer 專屬。⇒ 共用收尾函式在這裡被呼的時候，也要先判斷
`from_team.order_task == TeamData.TASK_TRIBUTE_OFFER`（或等價條件）才動作，否則會對
alliance／surrender／propose_trade 等其他提案的 NPC 也去清一個它們根本沒設過的
`order_task`／`diplomacy_reject_cooldown`——雖然多半是無害 no-op，但精確度上要寫清楚
這支函式的前提是「這個提案真的是 tribute_offer 來的」，不是「只要是 diplomacy 的回應就呼」。
```

# 二、②異源確認：成立，而且找到了實際現存的差集

```
讀了兩邊的 match 字面：
  ·`player_api_mapper.gd:351-358`（`proposal_phrase`）—— 獨立手打的 match，已經有
    `"tribute_offer": return "要向你進貢"`（:357）。
  ·`player_command_system.gd:1734-1769`（`_accept_diplomacy` 的 `match proposal:`）——
    另一支獨立手打的 match，字面裡**沒有** `"tribute_offer"`，掉到 :1769 的
    `"未知提案類型：%s"`。

這兩個 match 不是互相 derive 的（各自維護），而且**歷史上已經真的漂過一次**——:1747 那行
註解自己記著「`demand_tribute` 原只認 `tribute` → 未知提案類型 bug」，證明這兩邊會各自
漏掉彼此而不是同一份字面讀兩次 ⇒ 不是恆真格，跟 ACTION_SHAPE 那次的病不同。

獨立複算今天的差集（不是你的方法，直接列兩邊的字面集合比對）：
  mapper 側：{alliance, propose_alliance, propose_trade, surrender, tribute,
              demand_tribute, tribute_offer}（7 個）
  handler 側：{alliance, surrender, propose_alliance, tribute, demand_tribute,
               propose_trade}（6 個）
  差集 ＝ {tribute_offer}——跟用戶回報的症狀逐字對上，證明這條 P5 在**今天**（修之前）
  就會紅且指到正確的那個字串，不是一個要等未來才會動的空判準。
```

# 三、③`apply_tribute_accept` 的副作用——金額那半沒問題，記憶那半方向不對

```
讀了 `diplomatic_ai_system.gd:244-259`：
  ·:252-253 `ResourceBank.add(payer,"coin",-amount,"demand_tribute_out")` ／
    `ResourceBank.add(taker,"coin",amount,"demand_tribute_in")`——轉帳邏輯本身方向無關
    （誰是 payer 誰是 taker 由呼叫端決定），可以照你的方向（from_team=payer、玩家=taker）
    直接重用，金額計算沒有問題。理由字串字面寫的是 "demand_tribute_out/in"（命名沿用舊
    使用情境），純粹是記帳用的 tag，不影響行為，只是審計可讀性稍差——不是阻塞項，只是
    提醒你 §5 交件信裡順手提一句，免得下一個人看 ResourceBank 的 log 誤會方向。

  ·★★★:254-258 `write_memory(payer_leader, "tributed", taker.leader_id, …)` —— 這一句
    有真正的方向問題。我往下查了 `"tributed"` 這個 memory type 的分類：
      `npc_ai_system.gd:117`：`match type: "betrayal", "looted", "special_taxed",
        "rejected_aid", "tributed": NpcAiSystem.form_feud(p, subject_id, …)`
    —— `"tributed"` 被歸類在**負面／結仇**那一組（跟「背叛」「被劫」「被課重稅」「求援被拒」
    同一組），寫入的是 `form_feud`（結仇邊）。`grudge_ledger_bed.gd:170` 的分類表也把
    `"tributed"` 標成 `"feud"` 類，來源列的是「`_action_demand_tribute`（遠程索貢）／
    `_resolve_extortion`（同格勒索）」——兩個都是**強制**情境（玩家向對方要錢／勒索）。

    ⇒ 這支函式原本的設計語意是「`payer_leader` 記得自己被 `taker` 逼著繳錢，心生怨恨」。
    直接重用在 tribute_offer（**NPC 自己主動要送貢品給玩家**）上，會變成：**NPC 自願
    送禮，而送禮的動作本身讓這個 NPC 對玩家結了一筆仇**——方向是反的，一個主動示好的
    NPC 不應該因為自己的提議被接受而對接受方產生怨恨。

    ★實際影響的嚴重度（量過，不是純推論）：`npc_ai_system.gd:119-123` 的註解說
    `"tributed"` 刻意不在 `FEUD_SEVERITY` 表裡，用傳進來的 `intensity`（這裡＝
    `amount / coin_before` ＝ `TRIBUTE_TAKE_RATIO` ＝ 0.1）當嚴重度，而 `FEUD_MIN` 是
    0.30 ⇒ 在個性乘子不特別極端的情況下，這個嚴重度**多半過不了結仇門檻**（跟
    demand_tribute 原本的設計初衷一樣：「小索貢不寫邊」）。⇒ 今天多半不會在實測裡
    看到結仇邊真的長出來，**但語意是錯的**，而且一旦人格乘子（上界 1.3）把它推過門檻，
    玩家會看到一個「剛主動送我東西的 NPC 突然對我有仇恨值」的詭異行為，而成因會很難查
    （因為表面上看起來「程式碼是對的，呼的是既有函式」）。

    ⇒ 這題我不替你裁（WHAT／感覺層面的事，不是我的邊界），但要你明確決定一個：
      (甲) tribute_offer 的 accept 路徑**不要**連帶寫 "tributed" 記憶（只搬錢，不搬那半
        副作用）——實作上是把 `apply_tribute_accept` 拆成「轉帳」與「寫記憶」兩半，
        tribute_offer 只呼前半；或
      (乙) 接受 tribute_offer 時改寫一個**正面**的記憶 tag（例如 "goodwill"／"gift" 類，
        若存在對應的 gratitude 分支——`npc_ai_system.gd:126-128` 已經有
        `"kindness", "aided_in_battle", "benefactor"` 這一組走 `add_edge(..., "gratitude", ...)`
        可以參考同形狀）；或
      (丙) 明確判斷「維持現狀，反正門檻很少跨過，不值得為小機率的錯誤語意另開分支」。
    ★★三選一都可以，但本票 §4 的地板目前沒有任何一格驗到這件事（P1/P2 都只驗 coin
      增減方向），而這正是「交玩前自驗取代用戶眼睛」在這張票自己身上的同一個風險——
      副作用的那一半完全沒有格子在看。
```

# 四、verdict

```
issues（可修，三處都給了具體 file:line 與建議方向，不是推翻設計）：
①逾時出口確認在 sim_runner.gd:685-699，而且是服務多種 forced_event 類型的通用段，
  共用收尾函式必須做成 static（既有慣例：TaskArbiter／DiplomaticAiSystem 都是這樣被呼的），
  並且新開一個 tribute_offer 專屬的條件分支；拒絕出口（:1467）同樣是通用分支，共用函式
  被呼時要先判斷 order_task==TASK_TRIBUTE_OFFER 再動作。
②異源確認成立：兩邊是歷史上真的漂過一次的獨立字面，差集今天就是 {tribute_offer}，跟
  症狀吻合，P5 判準沒有問題。
③金額轉帳重用沒問題；但 "tributed" 記憶副作用方向是反的（負面結仇 tag 用在正面主動送禮
  的情境），需要你在甲／乙／丙三個方向明確選一個，而且本票的地板目前沒有任何一格驗這件
  事——建議至少加一格斷言「按接受之後 payer_leader 的 memory 裡那個新增項的 type 與這次
  的選擇一致」，不管選哪個方向都能機械驗。
三處都不卡「技術上做不做得出來」，卡的是「做出來之後行為對不對」，所以判 issues 不是
CLEAN——這三件處理完（或你明確判斷③維持現狀並寫下理由）我就過。
```
