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

---

## ★★★§5 普查回來了，而它改了 §2⑤ 與 §3（implementer 唯讀普查，2026-09-30；★本節取代 §2⑤）

```
★★★他數出來的是 **22 個呼叫點**，不是我寫的「十幾處」，而差在【母體的邊界】：
  ·`player_query_api.gd` 18 處
  ·★`player_api_mapper.gd` 4 處走**另一個信封** `_make_item_action`（:634／:640／:655／:668）
    —— 它與 `map_available_action` 是**兩份同形的信封**（都有 enabled／disabled_reason）
  ⇒ ★★**若母體只數 `map_available_action`，庫存那四個會整批漏掉。**
  ⇒ 母體定義**必須同時涵蓋兩個信封**，而斷言要說得出它涵蓋幾個。
★現況的數字（22 處）：**18 處硬寫 `true, ""`**；只有 4 處傳真值 ——
  `player_query_api.gd:319`（人口不足）／`:336`（準備值不足，帶現值）／`:355`（金幣不足，帶現值）
  ＋`player_api_mapper.gd:640`（`t != null, "" if t != null else "無受控隊伍"`）。
  ⇒ ★★★**現成範例是 `mapper:640`，不是我先前猜的 `:553／:562／:587`（我猜錯，已訂正）。**
```

### 三類母體的答案（照 §2⑤ 的處置條款）

```
①團隊目標動作 ⇒ **有單一來源**（`TEAM_TARGET_ACTIONS` 11 個）⇒ **做這一個母體**
  ★★而他揭了一件讓斷言必須【雙向】的事：**這條路目前不讀那個常數** ——
    `get_available_actions` 自己 `actions.append("…")`（全檔 10 處字面），
    而停用那三處（:319／:336／:355）又各寫一次字面
    ⇒ ★**同一個名字最多有三份**（常數／append 字面／停用字面）。
  ⇒ §3 P1 改成**雙向**：①那 11 個都在清單裡 ②★清單**沒有超出**那 11 個
    （否則 append 的字面漂出去不會紅）。
②自家隊／無目標動作（11 個，他已列名：cancel_move／establish_faction／take_loot／leave_loot／
  subjugate_enemy／confirm_gather_intel／hunt／hunt_beast／camp／train／promote_anon）
  ⇒ **沒有任何來源常數** ⇒ **不在本票**，登 defer 並寫明「沒有來源常數」。
③格動作 ⇒ ★★★**比「沒有常數」更糟：它的界線在 code 裡【不可機械讀】** ——
  依 `allowed_kinds` 宣告數只有 **1 個**（move_to :373），
  而依「真的看腳下這格」數是 **4 個**（hunt／hunt_beast／camp 的註解自己寫著「依腳下 tile」，
  宣告的卻是 `kind=none`）⇒ ★**兩個數都不是錯的，只是問的不是同一件事。**
  ⇒ **不在本票**，登 defer 並寫明「界線不可機械讀」（★不要挑一個數字當答案）。
★另外他撞到一個潛在缺陷（不在本票，但要寫進 defer 的敘述裡）：
  `offer_surrender :483` 宣告 `kind=team` 卻放在 Layer 5「無目標」區塊 ⇒ 宣告與位置不一致。
```

### ★★★那兩列 defer 的落地方式（★不是現在加）

```
★今天已經踩過一次的坑：一列 defer 的 met_check 若錨在【還不存在的標記】上，
  現在加進表裡 ⇒ 它當場就是「已達成」⇒ defer 閘立刻紅。
⇒ 所以那兩列**要跟本票的 code 改動同一顆 commit 落地**：
  ①本票在那兩類的呼叫點**就地具名標記**（沿用今天驗證過的形狀，例如
    `# no-source-constant: own-team-actions` ／ `# unreadable-boundary: tile-actions`）
  ②同一顆 commit 往 `defers.tsv` 加兩列，met_check 錨在那兩個標記
    （`! git grep -q "<marker>" -- <檔>` ⇒ 標記在 ⇒ rc=1 ⇒ 未達成 ⇒ 綠；
      有人把標記拿掉 ⇒ 響 ⇒ ★刪除不是靜默的）
  ③★寫完立刻跑一次 `bash .claude/hooks/defer-gate.sh`（它一秒，而極性寫反沒有別的訊號）
★★而「基準值與造成它的改動必須原子一起落地」這條，今天是第三次用到它。
```

---

## ★★★§6 R² 加固＋普查的第三個發現（★本節與 §5 合起來是現行權威；§2⑤ 已作廢）

### ①reviewer 要的第三格：**靜態互證**（他想到第三種騙法，而它擋不住）

```
他核過 P1 的 (a)(b) 兩道夠擋常見兩種，★而他想到第三種並且自己判斷 (b) 也擋得住：
  「讀 `TEAM_TARGET_ACTIONS.size()` 做計數，卻用另一份手抄名字陣列做內容」
  ⇒ (b) 往常數加假名字會讓 size() 變動 ⇒ 計數比對照樣紅 ⇒ 被擋住。
★★★而真正抓不到的是：**兩份手抄名字剛好逐字同步**（靠人力維護同步的抄法）。
⇒ 補 **P1c [靜態互證]**：grep 全列版那段程式碼，斷言它**逐字呼 `TEAM_TARGET_ACTIONS`**，
  而不是另一個字面陣列。★這是本 session 反覆驗證過的形狀：
  **行為負對照單獨扛不住「複製了一份」，要配靜態互證才夠硬**
  （同 NPC 索貢那票的 P6a＋P6b）。
```

### ②STUB 排除的**措辭**（reviewer 加的，我收）

```
排除 `recruit` 的理由字串要明確用「**尚未實裝**」這一類措辭
⇒ ★避免被下一個人讀成「這個動作被停用了」（我原本的擔心，他要求把它寫進字串本身）。
```

### ③不加指標註解（reviewer 判，我收）

```
我問「刪掉檔頭那段手寫表之後，可讀性由誰承擔」——他判 `disabled_reason` 本身足夠，
★而**加一個指標註解本身就是「第三份會漂的東西」**（同構風險）⇒ **不加**。
```

### ★★★④implementer 普查的第三個發現：停用那三處的條件是**第二份**

```
`player_query_api.gd:319／:336／:355` 的停用列是「啟用清單裡沒有它才補」，
★而它們的條件與 `get_available_actions` 是**兩份**（pop 1.5 倍／readiness 0.7／coin）
⇒ ★★**兩邊各改一次就會出現「選單說可以，而 handler 說不行」**。
⇒ 本票的全列版必須成為**那些條件的唯一持有者**：
   ·`get_available_actions` ＝ 衍生檢視（§2②，不變）
   ·★`:319／:336／:355` 那三處停用列**整段刪掉** —— 它們的內容由全列版產生
   ⇒ ★★★驗收 **P7 [條件只有一份]**：grep 那三個條件的字面（`1.5`／`0.7`／`RECRUIT_COST_ANON`）
     在這條路上**只出現一次**（在全列版裡）
     ｜負對照：把任一處的條件複製回 query_api ⇒ 必紅
     ★而這一格比 P1 更接近「一個真相一份」的本體：P1 守**名字**，P7 守**條件**。
·★中文 label 走 `PlayerApiMapper.action_label`（⑤ 那張票搬過來的唯一一份）⇒ **不准開第二張表**。
```

## §7 母體的邊界（★§5 的結論收成一句，給實作端當檢查清單）

```
本票只做【團隊目標動作】那一個母體 ＝ `TEAM_TARGET_ACTIONS` 11 個 − 具名排除（recruit）＝ 10。
不在本票、要在**同一顆 commit** 登 defer 的兩類（就地具名標記 ＋ 兩列 defer，見 §5 末）：
  ·自家隊／無目標 11 個（已列名）⇒ 「沒有來源常數」
  ·格動作 ⇒ ★「界線不可機械讀」（依 `allowed_kinds` 數 1、依「真的看腳下這格」數 4，
    ★★而 implementer 建議它的解除條件錨在**「kind 宣告與實際依賴對齊」**而不是
    「有人寫一張清單」—— 我採納，那個錨才對得上病）
  ·★而 `offer_surrender :483`（宣告 kind=team 卻在 Layer 5 無目標區塊）寫進格動作那一列的敘述
★★而母體定義要**同時涵蓋兩個信封**（`map_available_action` 18 處 ＋ `_make_item_action` 4 處
  ＝ 22）—— ★只數前者，庫存那四個會整批漏掉。★★本票不改庫存那四處，但**斷言要說得出
  它涵蓋 22 裡的哪幾個**，否則「全列」這個詞沒有母體。
```

