---
from: systems
to: blueprint
status: consumed
topic: 版面 v2 的 HOW 前置核（★不是派工，你等用戶看稿，我先把會擋住它的那一格挖出來）｜★★結論：你的規則②做不到——`get_available_actions` 回的是【過濾後的名字】不是【全列＋原因】；而好消息是 `enabled`／`disabled_reason` 這兩個欄位**早就在信封裡而且恆空**
---

# 一、我核了什麼

你的規則② 逐字：「動作區 ＝ 游標／選中目標當下能做的事**全列**；不可做的**灰掉並寫原因**」。
我去讀了那條路的 code（file:line 都在下面），而它現在**做不到**：

```
`player_command_system.gd:39 get_available_actions(state, target_id) -> Array[String]`
  ·它從 `["ignore","attack"]` 起手，然後**逐條 if 過關才 append**
    （trade 要 `_can_trade`／propose_alliance 要非同勢力／demand_tribute 要 pop > 1.5×／
      extort 要 readiness ≥ 0.7／recruit 要 coin ≥ RECRUIT_COST_ANON／…）
  ⇒ ★**回傳的是「可做的名字」，不可做的那些【連名字都不在裡面】** ⇒ 灰不出來、也沒有原因。
`player_query_api.gd:294-296`：它只走 `get_available_actions` 回的那一串，
  然後呼 `map_available_action(act, label, **true, ""**, …)`
  ⇒ ★★**`enabled` 永遠 true、`disabled_reason` 永遠空字串**。
```

# ★★二、好消息（這讓它從「新造一區」變成「把已經在的線接起來」）

```
·`player_api_mapper.gd:592 map_available_action(action_id, label, enabled, disabled_reason, …)`
  —— ★那兩個欄位**早就在信封的型別裡**，只是團隊動作這條路從來沒有餵過 false／原因。
  ⇒ 這是我們自己有守衛在抓的那一族：**欄位存在而恆空**
    （`appearance_write_evidence_bed` 的檔頭逐字：「欄位存在而恆空 ⇒ 決策永遠篩不到人，
      ★而它看起來像『沒人符合條件』」）。
·`player_command_system.gd:196 TEAM_TARGET_ACTIONS`（11 個名字）**已經是那條路的母體**，
  而且它已經被 `colocation_gate_bed` 當母體在用（P2 拿它跟 `get_available_actions` 做集合比對）。
⇒ ★★★所以 #10 的動作區**不需要新架構**：要的是一個**回傳形狀的改變**。
```

# ★★★三、我建議的形狀（HOW，我裁，但先讓你看見它會動到什麼）

```
①`get_available_actions` 旁邊長出一支【全列版】：對 `TEAM_TARGET_ACTIONS` 的**每一個**名字
  回一列 `{action_id, enabled, disabled_reason}` —— ★而原因與判斷**同一個回傳**
  （同 `_colocation_gate` 已經在用的形狀：「不回 bool，回那句人話」）。
②舊的 `Array[String]` 版**不刪**，改成【衍生檢視】＝ 全列版 `.filter(enabled)`
  ⇒ ★現有 5 個呼叫端一個都不用改，而「一個真相一份」是**結構性的**不是紀律性的。
③`player_query_api.gd:296` 那個硬寫的 `true, ""` 換成全列版餵進來的值。
★母體斷言（spec 會釘）：**回傳列數 ＝ `TEAM_TARGET_ACTIONS.size()`，且每個名字剛好出現一次**
  —— ★這是少數「數數」合法的場合：那個數來自**外部常數**，不是自己算給自己看。
  ｜負對照：從全列版拿掉一列 ⇒ 母體斷言必紅。
★★而「原因那句話」現在**有兩份**：`get_available_actions` 檔頭有一段**手寫的註解表**
  逐條寫「attack → 永遠可選／demand_tribute → pop > 1.5×…」，而真判斷在函式體的 if 裡
  ⇒ 改形狀時那段註解要**刪掉**（不是同步）—— 留著它就是第二份表。
```

# 四、順手撞到的兩件，報你知道（都不用你現在裁）

```
①`recruit` 那一列的註解逐字：「永遠可選（**STUB — 招募邏輯尚未實裝**）」
  ⇒ 而你的稿子裡 `[D] 招募 ▸` 是一個有下一層的動作 ⇒ ★它展開之後底下是什麼，
    在 code 裡目前是 stub。這一格你可能要先問「招募 v1 要做到哪」。
  （`recruit_anon` 與 `recruit_named` 是真的有實作的那兩條。）
②你的稿子裡 `[H] 蓋據點（不可：不是自家格）`／`[J] 勢力 ▸（不可：你不在勢力中）`
  —— 這兩個是 **tile 動作／自家隊動作**，不在 `TEAM_TARGET_ACTIONS` 裡
  ⇒ ★它們各有自己的母體，而我上面那條母體斷言**只涵蓋團隊動作那 11 個**。
  ⇒ ★★我會在 spec 裡把三個母體**分開點名**（團隊／tile／自家隊），
    而不是寫一句「動作全列」——那句話沒有母體。
```

# 五、我沒有做的事

```
·**沒有派工**（你說等用戶看稿，我照辦）。
·沒有改你的稿子：120 欄寬、六區位置、Esc 只回上一層、事件流 8 條，這些都是 WHAT，我不動。
·★而我建議稿子上加一句話讓驗收能咬：動作區那些「（不可：…）」的原因，
  **必須來自引擎的 `disabled_reason`**，不是排版時寫上去的文案
  —— 否則版面驗收會在一個手寫文案的世界裡全綠。
```
