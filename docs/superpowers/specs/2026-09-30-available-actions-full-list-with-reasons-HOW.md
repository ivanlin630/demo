# HOW：動作全列 ＋ 原因 —— 把 `enabled`／`disabled_reason` 從【恆空】接起來

**這不是版面票。** 版面 v2（#10）在等用戶看稿，而本票是它的**前置**，
且它**自己就有價值**：兩個欄位存在於信封的型別裡而**從來沒有被餵過非預設值**。

**上游**：藍圖 2026-09-30 裁定四點（`DRAFT-text-ui-layout-v2-mock.md §四`，commit `996465d21`）：
①全列回傳 `{action_id, enabled, disabled_reason}`、舊版 ＝ 衍生檢視；母體比
`TEAM_TARGET_ACTIONS.size()` 合法。②「動作全列」拆成**三個具名母體**分開點名。
③「（不可：…）」必來自引擎 `disabled_reason`，排版層**禁寫文案**。
④招募 v1：只列已實裝的兩支，STUB 的泛用 `recruit` 不列。

## ★★★§1 前提（我開檔核過，file:line）

```
`player_command_system.gd:39 get_available_actions(state, target_id) -> Array[String]`
  ·從 `["ignore","attack"]` 起手，逐條 if 過關才 append
    （trade ← `_can_trade`／propose_alliance ← 非同勢力／demand_tribute ← pop > 1.5×／
      extort ← readiness ≥ 0.7／recruit ← coin ≥ RECRUIT_COST_ANON／recruit_anon ← 且目標有 anon／
      invite_settle ← `_can_invite_settle`／gather_intel、beg ← 無條件）
  ⇒ ★回傳的是【可做的名字】，不可做的**連名字都不在裡面**。
`player_query_api.gd:294-296`：只走那一串，然後
  `PlayerApiMapper.map_available_action(act, _action_label(act), **true, ""**, …)`
  ⇒ ★★`enabled` 恆 true、`disabled_reason` 恆空字串。
`player_api_mapper.gd:592 map_available_action(action_id, label, enabled, disabled_reason, …)`
  ⇒ ★★★**信封早就有那兩個欄位** ⇒ 本票不新增欄位，只讓它們**開始有內容**。
`player_command_system.gd:196 TEAM_TARGET_ACTIONS`（11 個名字）⇒ 團隊目標動作的母體已存在，
  而且 `colocation_gate_bed` 已經把它當母體在用（P2 拿它與 `get_available_actions` 做集合比對）。
★而 `get_available_actions` 的**檔頭有一段手寫註解表**逐條寫「attack → 永遠可選／
  demand_tribute → pop > 1.5×…」——那是同一組規則的**第二份**（真判斷在函式體的 if 裡）。
```

## §2 做什麼

```
①新增全列版（名字 HOW 自定，例：`get_action_availability(state, target_id) -> Array[Dictionary]`）：
   對 `TEAM_TARGET_ACTIONS` 的**每一個**名字回一列 `{action_id, enabled, disabled_reason}`。
   ★**原因與判斷同一個回傳**（沿用 `_colocation_gate` 已在用的形狀：不回 bool，回那句人話）。
   ★★而 `recruit`（STUB）**不在列**（藍圖④）—— ★不是「列出來設成 false」，是**不列**：
     它不是「現在不能做」，是「還沒有這個機制」⇒ 混進去會讓玩家等一個不存在的東西。
     ⇒ **而它要從 `TEAM_TARGET_ACTIONS` 之外被排除，且排除要就地具名寫理由**（母體 11 → 10）。
②`get_available_actions` 改成**衍生檢視**：`全列版.filter(enabled).map(action_id)`。
   ★★現有 5 個呼叫端（`player_query_api:294`／`headless_test` ×3／`c1_info_reconciliation_bed`／
     `query_returns_body_census_bed`）**一個都不改** ⇒ 「一個真相一份」是結構性的不是紀律性的。
③`player_query_api.gd:296` 那個硬寫的 `true, ""` 換成全列版餵進來的值。
④★**刪掉** `get_available_actions` 檔頭那段手寫註解表（不是同步它）——
   留著它就是第二份表，而第二份表會在下一次改條件時安靜地說謊。
⑤三個母體**分開點名**（藍圖②），各自跟**自己的來源常數**比：
   ·團隊目標動作 ← `TEAM_TARGET_ACTIONS`（扣掉具名排除的 `recruit`）
   ·格動作（蓋據點／市場動詞…）← 它自己的來源（★HOW 要先找出來；找不到單一來源
     ⇒ **回報**，不要自己造一個常數）
   ·自家隊動作（勢力／派子隊…）← 同上
   ⇒ ★★★而若②③的來源**不存在**，本票就只做團隊那一個母體，
     另兩個**登 defer 並寫明「沒有來源常數」**——不要為了湊「三個母體」而手抄清單。
```

## ★★§3 驗收

```
P1 [全列] 回傳列數 ＝ `TEAM_TARGET_ACTIONS.size()` − 具名排除數，且**每個名字剛好出現一次**
   ★這是少數「數數」合法的場合：那個數來自**外部常數**，不是自己算給自己看
   ｜負對照：從全列版拿掉一列 ⇒ 必紅
   ｜★負對照 b：往 `TEAM_TARGET_ACTIONS` 加一個假名字而全列版沒跟 ⇒ 必紅
     （★★這一格守的是【它真的在讀那個常數】，而不是剛好列了一樣多）
P2 [原因非空] 造一個「每一條都不可做」的狀態（窮玩家、弱小、非同勢力…）
   ⇒ 斷言：`enabled=false` 的每一列 `disabled_reason` **非空**
   ｜負對照：讓某一條回 `enabled=false` 但原因留空 ⇒ 必紅
   ★母體地板：印出【這一輪有幾列 false】—— 若是 0，這一格會在一個「什麼都能做」的世界裡恆綠
P3 [原因是引擎給的不是文案] 改引擎裡某一條的原因字串一個字
   ⇒ 斷言：從 `sim_bridge` 那條路讀回來的 `disabled_reason` **跟著變**（藍圖③的驗收句）
   ｜負對照：把它換成排版層寫死的字 ⇒ 必紅
P4 [舊介面零行為變化] `get_available_actions` 對同一個狀態回**逐字相同**的陣列（順序也一樣）
   ★★這一格是本票的安全網：5 個呼叫端都靠它
   ｜負對照：讓 filter 漏掉一條 ⇒ 必紅
P5 [★STUB 不在列] `recruit` **不出現**在全列版裡，而排除**就地具名寫了理由**
   ｜負對照：把它加回去 ⇒ 必紅（★它與 P1 的數是連動的，兩格要一起看）
P6 全電池 BATTERY_RC=0；★fp：**先量再換基準**（本票改的是查詢面，我預期 fp 不變）
   ⇒ 沒變就不要動，並把「為什麼沒變」寫進卷面（★預測不是授權）
```

## §4 不在本票
```
·版面 v2 的任何排版決定（120 欄寬／六區／Esc 層級／事件流 8 條）—— 那是 #10，等用戶看稿
·招募的意願秤（藍圖④：另票）
·`recruit` 那個 STUB 要不要實裝（WHAT）
·格動作／自家隊動作的母體若沒有來源常數 ⇒ 登 defer，不在本票造常數
```
