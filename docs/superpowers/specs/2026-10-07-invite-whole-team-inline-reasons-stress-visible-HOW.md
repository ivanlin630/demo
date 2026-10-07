# 用戶續裁四件：邀請併入／動作清單印原因／招募空集合說原因／壓力看得見（HOW）

```
票源 ＝ 藍圖 `732c6bc31`（`…RULING-invite-whole-team-verb-inline-reasons-and-stress-visible.md`）
序 ＝ ②③ 小修同批（排在用戶第二手兩件那批）｜①④ 其後（深層批之前）
```

```
①【新玩家動詞「邀請併入」】可互動目標動作：對一支隊說「整隊過來跟我」（≠ invite_settle 邀請定居）
   ~~對方決策＝它自己的投靠秤反方向~~ ★R² 核：**沒有可逆的投靠秤** —— `_maybe_request_join_player` 只有閘＋寫入；`_find_absorb_target` 是強隊找弱隊吃的掠食者視角；
     唯一有人格加權公式的是換主評估 `faction_ai_system.gd::_trigger_defection_evaluation`（a 留／b 投降強鄰／c 自立），但它**不看邀請者是誰**（b＝慎重，與對方實力、關係無關）
   ⇒ ★藍圖裁：①併進「回應他人提案進決策引擎」框架票（勒索／邀請併入／結盟／進貢同一族），今天不造第二個秤；**在它做出來之前這個動詞不列**（列的條件＝做的條件）；②③④⑤ 照做
   接受＝整隊併入，走收留同一路（`player_command_system.gd` 收留那支：人口上限、食物 onboarding 照舊）；拒絕＝既有被拒後果（同一支收尾）
   ★列的條件＝做的條件：同格（或既有互動距離）、上限放得下、食物夠 —— 不夠就列成不可帶原因
   P：單人隊／殘隊被邀 ⇒ 依它的秤接受或拒絕（佈置兩種人格各一）；接受 ⇒ 人口＋N、對方隊消失（併入）；拒絕 ⇒ 被拒句＋既有後果
②【動作清單（不可）後印引擎短原因】例「[1]紮營（離據點太近）」——原因讀引擎的 disabled_reason，排版層禁自寫（版面 v2 ③ 原裁定）
   ★寬度預算明文：原因放不下時截在欄寬並以「…」結尾，完整原因按下去才印（不得截字無標記）
   P：每一個（不可）的動作行都帶原因（逐字等於引擎 disabled_reason 的短句）
③【招募空集合說為什麼】「[招募] 無可招募對象」⇒ 帶對象與原因，例「Team26 只有領袖一人，招募挖不到人」（★不指向「邀請併入」：那個動詞還不存在）
   ⇒ 原因由引擎給（招募那支的空集合原因）；P：單人隊被選為招募對象 ⇒ 印該句
④【壓力看得見】★R² 核：N1_flee 沒有固定門檻——它是 8 個反應分數＋0.2 底線的**相對 argmax**
   ⇒ 「高壓／可能離隊」＝這一輪反應評估裡 **N1_flee 的分數已過 0.2 底線、但沒贏 argmax**（可以發生、這次沒發生）—— 讀同一次評估的分數，不另抄門檻
   ★R² 核：scores 是 `reaction_system.gd::_evaluate_person`（:159-186）的區域變數、只回傳贏家字串 ⇒ **判斷寫在 _evaluate_person 內部、return 之前**（用它手上的 scores），結果寫到 person 一個欄位（例 flee_risk: bool）與預警事件；不在呼叫端或 UI 重算
   ⇒ 生存頁成員行加「高壓 N 人（名字…）」（N＝上面那個條件成立的人）；預警事件「<名> 壓力很高，可能離隊」：條件由否轉是時每人一次
   ⇒ `person.last_reaction == "N1_flee"`（`reaction_system.gd:462`）是已離隊的訊號，不是預警
⑤【壓力帳本帶原因】（藍圖 `75b2f7aa1`，與④同票）壓力的每一次寫入收成一支 `StressBank.adjust(person, delta, reason)`，
   ★R² 逐行核：**12 個**（我寫的 11 少算一個）——動態 10：`coin_treasury.gd:40`／`faction_ai_system.gd:2824`／`interaction_system.gd:755、1802`／
     `reaction_system.gd:127、418`／`resource_system.gd:588、609、611`／`task_arbiter.gd:253`；初始化 2：`game_setup.gd:790`／`person_generator.gd:55`
   ⇒ 初始化也走 StressBank（`StressBank.init(person, value)`：設起點、**不記帳**——起點不是 delta），single-writer 閘只准 StressBank 寫 person.stress，**無豁免**
   ⇒ 交件時重跑同一個掃描印命中數（樹會動，報掃描的數不報本表）
   內部 `record_driver(person, "stress", delta, reason, …)`（同資源帳本那套 driver ledger）
   ⇒ 成員頁每人印「壓力來源最近三筆」（讀帳本，不另存）；離隊事件句引主因（最近一段時間累積最多的 reason 的玩家可讀名，例「稅太重」），不再印「受不了壓力」
   ⇒ 單一寫者閘（single-writer）把 person.stress 列入：只准 StressBank 寫
   P：佈置三種來源各一筆 ⇒ 成員頁三筆來源正確；離隊句引主因；帳本 Σdelta＝stress 變化（同帳本守恆床的形狀）
   P：佈置一人壓力跨線 ⇒ 預警事件一次、生存頁列名；離隊時原因句照舊
已知問題清單相關列同 commit
```
