# HOW spec：三個【從來沒有被寫過】的人格鍵

owner: systems ｜ 2026-09-09 ｜ player_reachable: no ｜ 序：①移速票之後（blueprint 裁）

上游：`value-key-gate` 首次執行的產出（貧婪案的同一掃）。blueprint 裁「開票不進 backlog」。

## §1 病：`values.get("X")` 讀一個全庫從來沒有人寫過的 X

`Dictionary.get` 對不存在的鍵回 default ⇒ **那個量恆等於 default**，
而程式照跑、註解照樣描述它的效果。★這是 (ii) 型（看見了一個錯的值），
而且比 `貧婪` 那種形近字更難發現：**它從一開始就是錯的，沒有「之前是對的」可以 diff。**

```
計謀  advisor_system.gd:25      恆 0.5   ★HOLD（見 §2a，前提已更正，等 blueprint）
統領  decision/terms.gd:192     恆 0.5
順從  resource_system.gd:526    恆 0.5   ★BLOCKED（WHAT 缺口，等 blueprint 補鍵）
```

★正典 8 鍵（`person_data.gd` 的 `var values`）：野心／求生欲／義氣／貪婪／慎重／好戰／殘忍／信義。
★★`計謀`／`統領` 是 `person_data.gd:24-28` 的 **skills** 鍵 ⇒ 它們是**接錯 dict**，不是打字錯。

## §2 三條修法【不同】，不要一把抓

### (a) 計謀 ── ★UNHOLD（blueprint 2026-09-09 接受前提更正）

★★★**我原本報給 blueprint 的描述是錯的，已撤回**：
`_advisor_tone`（:24）只被 `_pick_variant` 的 `_:` default 分支呼叫（:53），
回一個**給 `TextBank.fmt` 的文案 variant 字串** ⇒ **presentation，不是決策閘**。
同函式另外三條分支（好戰/信義）讀的是真鍵、會 fire ⇒ 不可達的只有 `"sarcastic"` 這一個語氣。

⇒ blueprint 已重裁：**文案 variant 是 presentation 的離散選擇，不受「人格 WEIGH 不 GATE」管轄** ⇒ UNHOLD。
★修法＝最小的那個：`values.get("計謀", 0.5)` → `skills.get("計謀", 0.0)`。
★★**default 必須跟著改成 `0.0`**：skills 的預設是 0.0，沿用 0.5 會讓「沒有計謀技能的人」被當成中等計謀。

### (b) 統領 ── 可做

`terms.gd:192` 的 `scout_drive` 是**真的決策 util**（`_cmd` 進 `_smult` 乘上 `scout_staleness`）。
⇒ `ctx.leader_values.get("統領", 0.5)` → 讀 `skills` 的 `統領`，**default `0.0`**。
★注意 `ctx.leader_values` 是 values dict ⇒ 需要拿到 leader 的 `skills`；
若 `DecisionContext` 手上沒有 skills，**照 `_loyalty` 的同一套做法注入**
（`decision_context.gd:581` 是既有前例：`c.leader_values["_loyalty"] = c.leader_loyalty`），
★★而注入的鍵名要讓 `value-key-gate` 認得（它的正典包含「全庫真的被寫過的鍵」，所以注入即合法）。
★★★設計判斷保留：「統領技能當責任/關切 proxy」這個設計**先接對再懷疑**（blueprint 裁）；
接上後若讀數顯示 proxy 本身怪，**附讀數再議**，不在本票內改設計。

### (c) 順從 ── ★改讀 `慎重`（blueprint 裁：不開第九軸）

`resource_system.gd:521` 的註解寫著
`tolerance = 0.3 + 順從×0.2 + 義氣×0.1 − 野心×0.2`，問的是**居民對苛稅的忍耐度**。
正典 8 鍵**沒有**承載「服從性」語意的鍵（`義氣`＝對同伴的情義，該函式 :527 已另外讀了它；
`信義`＝守約，不是服從上位者）。
⇒ blueprint 裁：**不開第九條人格軸**，「苛稅忍耐度」的 `順從` 項改用 **`慎重`** 表達。
★理由（他的）：**忍耐 vs 反抗＝風險權衡，而 `慎重` 是那個語意的正身，不是借殼**。
★★通則同時立起來：**單一消費者不得開新人格軸**；同語意需求累積到多處，才回用戶議。
⇒ `resource_system.gd:526`：`values.get("順從", 0.5)` → `values.get("慎重", 0.5)`
   ★★★**註解 :521 的公式要一起改**（`0.3 + 順從×0.2 …` → `0.3 + 慎重×0.2 …`），
   否則就變成「註解描述一個不存在的輸入」——那正是這張票在治的病。
★這一格的價值不只在修：**它原本是一個被寫進註解、卻從來沒有輸入的設計**。

## §3 驗收（blueprint 裁的判準，逐格）

```
★三格共同：接線前該量【恆 0.5】⇒ 接線後【跨 agent 有變異】——
   ★★dump 分布（min/median/max ＋ 幾個不同的值），不是單點。
   ⇒ 只印一個 agent 的值不算：那分不出「接上了」與「剛好那個人是 0.5」。
★(b) 專屬：`scout_drive` 的 util 在【統領技能不同的 leader 之間】要分得開，
   而 `scout_staleness` 相同時差異只能來自 `_cmd` ⇒ 這格證明接線真的進了引擎秤。
★★★(a) 若解 HOLD：驗的是【語氣分布多出 "sarcastic" 這一支且比例合理】，
   ★不是驗「那條分支 fire 了」—— 判準要能分辨【機制對了】與【死碼復活了】（blueprint 語）。
```

## §4 守衛

`.claude/hooks/value-key-gate.sh`（已註冊）在本票做完後應對這三鍵**不再列出**。
★而它**不會因為本票而失去鑑別力**：正典是從 `person_data.gd` 讀出來的，
新增一個錯鍵一樣會紅。
