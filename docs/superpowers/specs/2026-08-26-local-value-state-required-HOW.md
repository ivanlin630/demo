# `local_value` 的 `state` 改成必填（HOW）

`from: systems`｜`tier: behavior`（改 production 簽名；★但**行為不得變**，見驗收②）
`blocked-by:` 無（`local-value-blind-callsites` 已 merged `f9703eee`）

## 病：**那 17 個 blind 呼叫之所以【存在得起來】，是因為有一個 default**

```gdscript
static func local_value(team: TeamData, res: String, state: WorldState = null) -> float:
```
`_stock(state, team, res)`：`state == null` ⇒ **退回 `team.resources`（私產 only，不含自家糧倉）**
⇒ ★**忘記傳 ＝ 隊在對自己的庫存做決策時讀不到自己的庫存，而且【不會報錯】。**

★★**上一票修掉的是【17 個實例】；這票修的是【讓實例長得出來的那個條件】。**

## ★現況（merge 後實測，這是本票唯一的前提）
```
production（scripts/simulation/，排除註解）不帶 state 的呼叫 = 0
scripts/ 全域（含 debug/test）不帶 state 的呼叫       = 0   ← 9 個 debug caller 也全都帶
```
⇒ ★★★**那個 default 現在【零 users】。**

★**判準（default 三分類，2026-08-25 立）**：
| 類 | 處置 |
|---|---|
| ★**零 users** | ★**純負債 ⇒ 刪** ← **本案** |
| 只有錯的 users | 陷阱 ⇒ 刪 |
| 真收益＋真風險 | **不用 default，改用兩個入口**（`flow_utility` / `stock_utility` 就是這樣做的） |

## ★★★scope（2026-08-26 **二訂**：我第一版的切法是錯的，reviewer R² 打回）

### 我原本怎麼切、為什麼錯
**我切「①`local_value` ＋ ⑧包裝層 先做，②–⑦ 另開票」，理由是「零 users 要各自驗」。**
★**理由本身沒錯，切法錯了** —— ★★**我用【函式】當單位，而安全性質的單位是【`_stock(null, …)` 到不到得了】。**

reviewer 找到 `_stock()` 的**第二條入口**（我的前提檢查完全沒掃到，因為我只掃了 `local_value(`）：
```
reserve(team,res,leader_values,state=null)      ← 自己也有 default
  → _reserve_factor(…, state)
  → _urgency(team, state=null)                   ← 自己也有 default
  → _food_urgency(team, state=null)              ← 自己也有 default
  → _stock(state, team, "food")                  ← ★同一個 fallback
```
★**而 `ask_price`（⑦）也到得了**：`_urgency(seller, state)` ＋ `local_value(seller, res, state)`（`:127-132`）。
⇒ ★★★**②–⑦ 不是「另一票」，它們是【同一個 fallback 的其他入口】。
只刪 `local_value` 那個 default，`_stock(null,…)` 照樣到得了 —— 病沒被關掉，只是關了一扇門。**

### ⇒ 正確的 scope：**`trade_valuation.gd` ＋ `interaction_system.gd` 內【全部 8 個 default】一起刪**
| # | 函式 | 檔:行 |
|---|---|---|
| ① | `local_value` | `trade_valuation.gd:136` |
| ② | `reserve` | `:85` |
| ③ | `_reserve_factor` | `:102` |
| ④ | `_reserve_factor_food_only` | `:109` |
| ⑤ | `_food_urgency` | `:115` |
| ⑥ | `_urgency` | `:121` |
| ⑦ | `ask_price` | `:127` |
| ⑧ | `InteractionSystem.local_value`（包裝層） | `interaction_system.gd:662` |

★**⑨`player_trade_system.gd:19 _sellable_qty`（2026-08-26 三訂：從「範圍外」拉回【範圍內】）**
我原本標它「範圍外，各自要自己的 caller 窮盡」——★**但我沒做那個窮盡，reviewer 做了，結果不安全**：
它**自己也有 `state: WorldState = null`**，而且**直接轉送**給 `TradeValuation.reserve(team,res,leader_values,state)`
⇒ ★★**它在同一條可達鏈上，只是入口多疊一層、而且跨了檔案。**
⇒ **留著它 ＝ 這票的保證作廢**（見下方「④ 的洞」）。**⑨ 併入。**

★**真正的範圍外（reviewer 複驗過與 `_stock` 無關）**：`decision_engine.gd:58 rank_scored_ctx`。

## ★★動工前必須先接住的【三個】呼叫端（reviewer 逐條找到，缺一就會崩）
| # | 位置 | 現況 | 處置 |
|---|---|---|---|
| A | ★**`scripts/debug/slice_a_observe.gd:45`（★同一行【兩個】呼叫）** | `TradeValuation.reserve(t, "weapon_melee_low")` —— `leader_values` 與 `state` **兩個 default 都省**，而 `state` 就在同函式 scope（`:35`） | ★**補成 `reserve(t, res, {}, state)`** |
| B | `interaction_system.gd:667-669 _calc_reserve`（wrapper，簽名自己就沒有 `state`） | ★**零 caller ＝ 死碼**；它自己的註解已點名「**不崩但更隱密：靜默給出錯的估值。崩會被看見，這個不會**」 | ★★**刪掉**（零 users ＝ 純負債；不要「補參數讓它活」——沒人要它活） |

★**`weapon_melee_low` 不在 `SURVIVAL_GOODS(["food","medicine"])`** ⇒ 走 generic 分支 ⇒ 一路打到 `_stock(null,…)`
⇒ **刪 fallback 後，`godot --headless --script scripts/debug/slice_a_observe.gd` 會在
`resource_system.gd:438 own_granary_tile(null,…)` 當場崩。**

| # | 位置 | 現況 | 處置 |
|---|---|---|---|
| ★**C** | ★★**`scripts/debug/headless_test.gd:11657/11658/11660/11665`（4 處，同一支 `_test_trade_reserve_no_drain`）** | `pts._sellable_qty(t, "material")` 省 `state`，而 `state` 就在 `:11652` 手上 | 補成 `pts._sellable_qty(t, "material", {}, state)` |

★★★**C 比 A 嚴重**：**它在 `headless_test.gd`（baseline-7 主測試檔）裡**
⇒ **不是「以後有人跑才炸」，是【這票一 merge，下一次例行 headless 就炸】。**
★**而 `:11652` 的註解是這個測試自己寫的自認證詞**：
> 「reserve 的 state default 讓漏傳編得過」
⇒ **寫那行的人早就知道自己在吃 default 的便宜。** ★★**那正是 default 的真正代價：它讓「知道不對」也能過關。**

> ★**這不是第一次**：`scripts/debug/own_granary_null_caller_test.gd` 的檔頭就寫著
> 「**根修＝呼點補傳 state（非 own_granary 頭加 guard）**」——★★**同一個病已經修過一輪，而 default 讓它長回來。**
> ★★★**這正是本票存在的理由：修實例會長回來，刪掉 default 才不會。**

## 修法（★零數值改動）
1. `local_value(team, res, state)` —— **`state` 必填**（刪 `= null`）。
1b. ★`InteractionSystem.local_value` 包裝層 —— **同樣刪 `= null`**（否則病往上搬一層）。
2. `_stock()` 裡的 `if state != null` fallback —— ★**一併刪**。
   ★**理由**：留著它，就等於留著「傳了 null 也能跑」這條路 —— **簽名擋住的東西，不該被實作放行。**
3. **不新增任何「無世界」入口** —— ★**若日後真的出現「手上沒有 state」的合法呼叫者，
   那時再開一個【具名入口】**（如 `local_value_private_only()`），**不要把 default 加回來。**

> ★★**同族**：`stock-vs-flow` 的「**忘記選 ＝ 沒有函式可呼叫。用【入口】區分，不用【參數值】區分**」。
> **這票是同一條規則用在既有函式上。**

## 驗收
1. ★★**結構型，錨在【定義側】不是【呼叫側】，且【掃全樹】不寫死檔名**（★2026-08-26 四訂，reviewer 提醒）：
   ```
   grep -rn 'state: WorldState = null' scripts/ | grep -vE ':[0-9]+:[[:space:]]*(var |#)'    ⇒ ★剩 1 行
   ```
   ★**那唯一的 1 必須是 `decision_engine.gd:58 rank_scored_ctx`**（已複驗與 `_stock` 無關）。
   **排除的兩類**：`var last_state: WorldState = null`（區域變數宣告）／註解行。
   ★★**不要用 `grep 'func '` 過濾** —— ★★★**實測它會漏掉 `player_trade_system.gd:19`，
   因為那個簽名【跨兩行】，`func` 在上一行** ⇒ 現況它報 9，實際 10。
   ★**又一次「過濾條件本身把母體畫窄」** —— 這張票上第四次，形狀完全相同。
   ★★**為什麼不寫死檔名**：我原本寫「grep `trade_valuation.gd` ＋ `interaction_system.gd` ＝ 0」——
   ★★★**九個 default 刪完後那條【剛好也會＝0】，但那是因為第三個檔的 default 被刪掉了，
   不是因為 grep 涵蓋了它** ⇒ **一個判準可以【因為錯的理由】而綠**，
   而下一個長在別處的 default 它抓不到。⇒ **改成掃全樹 ＋ 集合型（剩下的那 1 個要指名）。**
   ★**為什麼錨在定義側**：**default 不存在 ⇒ blind 呼叫【不可代表】⇒ 根本不需要列舉呼叫點。**
   ★★**血證（同一票裡犯的）**：我上一版的「結構型」判準是
   `grep -o 'TradeValuation\.local_value([^)]*)' | grep -v ', state)'` ——
   ★★★**它把母體定義成「有 `TradeValuation.` 前綴的呼叫」，於是看不見包裝層那條
   `InteractionSystem.new().local_value(t, res, state)`** ⇒ **我報 9、reviewer 報 10，他對。**
   **我以為我把判準從【計數】換成了【結構】，其實只是把數錯換成了掃錯 —— 母體還是我畫的。**
2. ★★**`fp` 必須【不變】** —— ★**這票與上一票相反**：所有呼叫者本來就都傳 state，
   ⇒ **刪 default 不改變任何一次呼叫的實際引數** ⇒ **fp 變了就是有人被改到，是紅不是綠。**
   （★**「該不該變」由【這次改動會不會改到任何一次呼叫的引數】決定，不是由 tier 決定。**）
3. **headless 閘**：`bash .claude/hooks/test-ran-floor.sh <實跑輸出>` PASS（baseline 7）。
4. ★★★**「編譯即驗收」有一個洞，寫清楚**（reviewer 2026-08-26 揭，我原版④是錯的）：
   **少傳引數** ⇒ 編譯錯 ✅；★**但【自己也有 default 的轉送者】會用完整引數個數傳一個 `null` 下去**
   ⇒ **編得過、執行期才崩。** 血證：`pts._sellable_qty(t, "material")`（`headless_test.gd:11657` 等 4 處）
   —— `_sellable_qty` 用自己的 `null` default 補齊，再以**完整 4 引數**呼叫 `reserve(team,res,{},null)`。
   ⇒ ★★**真正的驗收是「可達閉包上的 default 數 ＝ 0」，編譯過只是它的【結果】，不是檢查本身。**
   ⇒ **所以 ⑨ 必須併入** —— 閉包上少關一個門，這票的保證就不存在。

## ★誠實限
**本票不會讓任何行為變好** —— 它讓**同一種 bug 以後長不出來**。
★**驗收②要求 `fp` 不變，所以本票【沒有】任何行為證據，也不該有。**
