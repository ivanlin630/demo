---
owner: systems
status: 裁定版 v3（v1「補一行常數」撤銷；v2 的票甲【改形狀】——見 §票甲）
date: 2026-09-15
supersedes: 本檔 v1（`BASE_PRICE["coin"] = 1.0`）
---

# 裁定：原票撤銷，拆成兩票

## ① 原票錯在形狀，不是錯在方向

v1 要的是 `BASE_PRICE["coin"] = 1.0`。**撤銷。**

- `trade_valuation.gd:173-175` **已經有** `if res == "coin": return 1.0`
  ⇒ 「coin ＝ 1.0」**不是新規則**，它已經在 `local_value()` 裡了。
- 補進表 ⇒ **表與函式各有一份真相**（我們今天才為「兩處同型」記過一次）。
- ★★★**而更硬的理由是型別**：`BASE_PRICE` 是**商品表**，交易迴圈對「每一個有價的資源」做買賣配對
  （`interaction_system.gd:1291/1325/1332`、`player_trade_system.gd:39/45`、`player_api_mapper.gd:860`）
  ⇒ 補表 ⇒ **coin 變成一種可賣可換的商品**，「用 coin 換 coin」**型別上成立**。
  ⇒ ★**那是型別錯，不是數值錯** —— 而型別錯不能用「反正 1.0 是對的」抵銷。

## ② root：病在需求，不在定價（★靜態必然，非推測）

`maintain_coin` 0 次的原因，鏈條每一節都讀得出來：

```
goal_resolver.gd:44   status = effective_holding(coin) < NeedOracle.need_keep(coin) ? active : satisfied
need_oracle.gd:82     need_keep = _self_use + _supply_chain + _construction_facility_need
  _self_use            :236-249  coin 非 food／非 goods／非 PURE_INTERMEDIATE ⇒ 落末行
                                 pop × TARGET_PER_POP.get(res, 0.0)
                                 ★ trade_valuation.gd:30-51 的 TARGET_PER_POP 【沒有 coin 鍵】⇒ 0
  _supply_chain        :254-276  coin 不是任何配方的 `in`（manufacturing_system.gd 零筆 "coin"）⇒ 0
  _construction_...              建造成本明文「無 coin、無有限資源」
                                 （outpost_system.gd:9 ／ :94）⇒ 0
⇒ need_keep(state, team, "coin", *) ≡ 0.0
⇒ holding ≥ 0 ⇒ `holding < 0` 恆 false ⇒ status 恆 satisfied
⇒ 永不進 frontier ⇒ derived_payoff 0 次
```

★**兩條獨立證據對上了**：implementer 的**實跑 0 次**（4320 tick／seed 1337）
與此處的**靜態恆 0**（由表的缺席推出）—— 一條量到、一條證出來。

⇒ **待驗的那句話結案**：「這個世界的隊伍，從來不會因為想要錢而去做任何事」**成立**，
  ★★而**原因不是錢沒有價格，是這個世界裡沒有「想要錢」這個需求**。

## ③ ★★★真正的病：同一個形狀在兩張表上

`BASE_PRICE` 缺 coin、`TARGET_PER_POP` 缺 coin。
⇒ ★**每張 per-resource 表的預設值都是 `0`，而 `0` 在語意上是「不存在」，不是「零」**
⇒ coin 在每一條路上都被**靜默地**當成不存在，而缺席不會叫。

★★**而 `local_value():173` 的那個特判，就是補丁閘的教科書例子**：
有人已經撞過這個洞，修法是**在一個函式裡特判**，不是**修表**
⇒ 補丁把洞遮起來，洞在**其餘 37 處照樣開著**，而且從此沒人會再撞到它。
⇒ **de-patch 方向＝取價單一入口，不是再加一個特判。**

# 票甲【改形狀】：把「可交易品集合」從價目表裡拆出來

## 先驗已結案：答案 0，而且是**結構上不可能**，不是「這次剛好沒有」

implementer 逐處靜態證了 9 處（`2026-09-15-implementer-to-systems-pre-verify-answered-statically-...`）：
3 處鍵是字面量 `"food"`｜2 處來自 `FACILITY_DEFICIT_DEF` 的 outputs（全表無 coin）｜
1 處來自市場掛單（走獨立白名單 `order_system.gd:8 _ORDER_ELIGIBLE_RES`，9 種無 coin）｜1 處在測試檔｜
★**只有 `goal_resolver.gd:181`／`:220` 兩處的鍵來自 goal 的 `prereqs.res`** ——
**今天 0（唯一能給出 coin 的 `maintain_coin` 是 dormant），而票乙讓它復活的那一刻這兩處就會拿到 coin。**
⇒ 照 v2 寫的判準：**潛伏，不是現行** ⇒ **原本的「收斂 9 處取價點」不是重點。**

## ★★★真正該收斂的是【一張表同時是價格、又是可交易集合】

`BASE_PRICE` 被當成「可交易品清單」迭代 —— ★**而這張表兼作清單的病，已經有人撞過三次，
並且是用【逐處手工排除 coin】繞開的**：

```
interaction_system.gd:1289  巧遇賣 surplus   for res in BASE_PRICE.keys()   ❌ 無 coin 守衛
interaction_system.gd:1324  易貨 give        for give_res in ...            ✅ if give_res == "coin": continue
interaction_system.gd:1331  易貨 pay         for pay_res in ...             ✅ if pay_res == "coin" or ...
player_trade_system.gd:39   sellable 清單    for res in ...                 ❌ 無
player_trade_system.gd:45   prices 價目      for res in ...                 ❌ 無（★但這處是【映射】語意，見下）
player_api_mapper.gd:860    玩家可交易項     for res in ...                 ✅ if res == "coin": continue
                            ★★而它上一行的註解直接寫著
                            「可交易白名單：限 BASE_PRICE 項（coin 另列 face value）」
```

★**那三個手工守衛就是化石**：寫它們的人**知道** coin 不該進交易集合，
而他們的修法是**在自己那一處排除**，不是修型別 ⇒ **守漏了三處**。
⇒ ★★**與 `local_value():173` 的特判、與兩張表的缺席，是同一個病的第三次現形。**

## 本票要做的

1. **獨立列出「可交易品集合」**（例如 `TRADEABLE_RES`），六處迭代改讀它。
2. **刪掉那三個手工 coin 守衛** —— 它們是補丁化石，型別修好後就是死碼。
3. ★**區分兩種語意，不要一刀切**：
   - **集合語意**（誰可以被買賣）＝ `:1289`／`:1324`／`:1331`／`player_trade_system.gd:39`／`player_api_mapper.gd:860`
   - **映射語意**（每個東西多少錢）＝ `player_trade_system.gd:45` 的 `prices`
     ⇒ ★★**價目表裡有 coin＝1.0 是【對的】**，它不該被當成「可賣清單」處理。

## ★★★硬約束：新集合**不准**寫成 `BASE_PRICE.keys()` 的別名

`const TRADEABLE_RES = BASE_PRICE.keys()` ＝ **換個名字的同一張表** ⇒ 票乙補 coin 照樣炉。

### ★implementer 打中了我的守衛：「不含 coin」那一格**今天恆真**

★★**違規寫法會【通過】那一格** —— 因為 `BASE_PRICE.keys()` 今天本來就不含 coin。
⇒ 那是一個**零鑑別力**的格子（同族：無 assert 的守衛、恆真項）。

### ★★★而他提的修法（往 `BASE_PRICE` 塞假鍵）**寫不出來** —— 已實測

```
Godot 4.2.2 實跣：
SCRIPT ERROR: Parse Error: Cannot assign a new value to a constant.
  ⇒ ★`const Dictionary` 在 **編譯期**就擋，不是執行期報錯
  ⇒ ★★整支測試檔**載不起來** ⇒ 那不是「那一格紅」，那是**整支閘死掉**（而且永遠死）
```

### ⇒ 改用【宣告形狀】檢查（★宣告形狀的約束，誠實的儀器就是讀原始碼）

1. **格一（今天就有鑑別力）**：讀 `trade_valuation.gd` 原始碼，
   斷言可交易集合的**宣告右側不含 `BASE_PRICE`**。
2. **★★陽性對照（同一支測試內，不碰 production）**：拿一段**故意違規的字串**
   （`const TRADEABLE_RES = BASE_PRICE.keys()`）跑同一個判準，**斷言它會紅** ——
   ★★★否則那個判準本身可能根本不會紅，而沒人會發現。
3. **格三（語意，★標明它今天是恆真的）**：集合不含 coin。
   ★★**它的鑑別力要到票乙才出現** ⇒ 保留，但**不准拿它当成硬約束的證明**。

## ★驗收：本票【今天不會改變任何數字】

拆出來的集合今天**恰好等於** `BASE_PRICE.keys()`（因為 coin 還沒進表）⇒ **fp 應逐位元不變**。
★★**而那正是它能先做的理由**：**零差別的今天，防的是票乙的明天** ——
與既有那條「預防性 de-patch：修一個還沒發生的 bug，排在它能 fire 之前」同形。
⇒ ★★★**必須在 handback 講死「這張票不會改善任何症狀」**，否則它會被當成解法、然後驗收落空。

### ★★而 fp 不變只證等價，不證**被走到**（implementer 補，採納）

六處迭代改讀新集合之後，**要一顆 tap 證明讀的是新的那份** ——
否則**「改完了而其實沒接上」會以 fp 不變的形式通過驗收**。

### ★`prices` 分類的範圍（reviewer 已查，限縮）

`player_trade_system.gd:45` 的 `prices` 在**本 repo 可見消費者**裡沒有被當「可買清單」用
（唯一 caller `player_query_api.gd:103` → `sim_bridge.gd:265` API 邊界；`scripts/ui/` 零命中）。
⇒ ★**寫成「範圍＝本 repo 可見消費者」，不寫無條件安全**（牆外客端 reviewer 判不了）。

# 票乙：coin 的需求是衍生的（機制）

**★禁手抄物理**（本專案既有立法）：**不准往 `TARGET_PER_POP` 塞 `"coin": N`**
—— 那是「一支隊每人該有 N 塊錢」的手抄常數，**三個月後又爛**。修法形狀＝**改接線，不是改數值**。

**★★正確接線**：**錢的需求＝它要買的東西的預算**
⇒ `need_keep(coin)` 由**已經存在的 gap** 導出：
`Σ over res：max(need_keep(res) − holding(res), 0) × 取價(res)`，
**只算這支隊打算用買的**（而非自產的）—— 也就是 `_supply_chain` 的錢版。

**★★★遞迴 hazard 具名**：若 `need_keep(coin)` 反過來呼叫 `need_keep(res)`，
而任何 res 的鏈又回到 coin ⇒ 無限遞迴。
⇒ **硬約束：coin 必須是這張 DAG 的葉 —— coin 的 need 計算內禁再算 coin。**
（`_supply_chain` 已有兩層遞迴守衛的前例，可沿用其形狀。）

**驗收**：★這一票會**第一次**讓世界裡有「想要錢」這件事
⇒ 必問 **`maintain_coin` 會不會一上來就贏過一切**。
★**若它突然佔據 argmax 的多數 ⇒ 回報，不要在票裡壓它** —— 壓它是灌水，
正確的處置是問「為什麼缺口那麼大」。

**序**：**票乙等票甲** —— 它要用取價函式，而取價現在有兩份真相。

★**票乙上線那一刻會活過來的兩處**：`goal_resolver.gd:181`／`:220`
（鍵來自 goal 的 `prereqs.res`，而唯一能給出 coin 的是 `maintain_coin`）
⇒ **票乙必須把這兩處一起驗**，否則「復活」的第一個效果會出現在一個沒人盯的地方。

★★**票甲做完之後，型別就講得通了**：`local_value():173` 說「coin ＝ 1.0」**留著是對的** ——
**coin 有價格、但不在可交易集合裡**，而那正是「計價單位」該有的型別。
⇒ 所以 v2 寫的「票甲收斂完才談拆 :173」**修正為：不拆**。

## ★★★R² 判【非CLEAN】：`Σ gap × price` 結構上恆贏（reviewer 2026-09-15，我的第4問成立）

```
maintain_X  的 payoff ＝ (target − stock) × price   ← 【單一】缺口項
maintain_coin 若照票乙接    ＝ Σ 所有缺口項              ← 【全部】缺口項的和
⇒ 只要同時缺 ≥2 種資源，它就【嚴格大於】任一單一 goal，而多缺口是常態不是例外
⇒ ★實務上約等於恆贏（而它們確實在同一把尺上比 —— `goal_resolver.gd:186-188` 註解明寫「跨資源同單位」，那是設計本意）
```

### ★reviewer 給的兩條出路，我**兩條都不採**

「取 max 而非 Σ」、「除以缺口種類數」—— ★它們都是**把一個語意問題拿數值壓下去**，
而本專案有一條現成的規矩：**util 必須是真實期望價值，禁因為「贏太多」就往下調**。

### ★★★真正的問題是【重複計算】，不是量級

世界**已經**為每一個資源缺口生了一個 goal。
再生一個「所有缺口加總」的 goal 放進同一個 argmax ⇒ **同一份需求被數兩次**。
⇒ ★**錢不是一個與 food 並列的【目的】，它是達成別的目的的【手段】。**
⇒ ★★而這個框架本來就有放「手段」的位置：**`prereqs` 鏈**。
   `maintain_food` 的 resource prereq 已經有一條「買」的路（`goal_resolver.gd:983` 產 `TASK_TRADE` candidate）
   ⇒ **買需要錢** ⇒ 錢不夠時，那條路該長出一個**子前置：先弄到錢**（賣東西／接活／抶掠）。
   ⇒ ★★★**這自動解掉恆贏**：錢的需求**繼承它服務的那個 goal 的 payoff**，不加總、不與之並列比。

⇒ **而這也解釋了 `maintain_coin` 為什麼 dormant**：
  ★**它不是壞掉的，它是【在這個框架裡本來就沒有位置】** —— 一個注冊了、卻沒有任何路能讓它活過來的意圖。

### ★★★而這是 **WHAT** 層的分岐 ⇒ **呈報藍圖，不自裁**

原本排最前的理由是「錢沒有價格」＝一個 bug。
★**而現在的修法會改變世界的動機結構** ⇒ 那不再是純 HOW。
選項（呈給藍圖）：
- **A（我推薦）**：錢的需求走 **prereq 鏈**、掛在具體目的下面；`maintain_coin` 【拆掉或標死】。
- **B**：保留平行 goal，把量級正規化（max／除種類數）—— ★**我判它是灌水**，但它保留了「隊伍會因為想要錢而行動」這個可見的故事。
- **C**：不做。世界就是沒有「想要錢」這件事，錢只是交易的副產品。

⇒ **票乙在藍圖裁之前不派工。票甲不受影響，可以先走。**

# 不做 / 另立

- **不**補 `BASE_PRICE["coin"]`。
- **不**拆 `local_value():173` —— 票甲把集合拆出去之後，它就是**單位定義**的正確位置（v2 此條已修正）。
- `maintain_material` **85% payoff ＝ 0**（implementer 側報，未查）⇒ **另立一條**，不併本票。
- `faction_ai_system.gd:4654` 的逐鍵迴圈：implementer 已查證 coin gap ＝ 0 ⇒ **安全**，
  但它在票甲後應一併走取價函式。
