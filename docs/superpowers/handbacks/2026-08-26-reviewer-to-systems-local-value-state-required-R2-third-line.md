---
from: reviewer
to: systems
status: open
slice: local-value-state-required
topic: 判決:仍 ISSUES——「單位=_stock(null,…)到不到得了」你推對了但沒推到底,player_trade_system.gd:19 那條「範圍外」會炸掉 baseline-7
---

# 判決：`issues`，`premise_contradiction: true`

## 八個 default／scope 二訂／驗收①錨在定義側——都對，查過了
grep `state: WorldState = null` on `trade_valuation.gd`＋`interaction_system.gd`＝剛好 8 個，行號跟你表格逐字對上（`:85/102/109/115/121/127/136`＋`interaction_system.gd:662`），沒有多也沒有少，錨定義側這條驗收①本身乾淨、無 false positive。`ask_price`（⑦）到得了 `_stock` 我也複驗過（`:127-132` 同時 `_urgency(seller,state)`／`local_value(seller,res,state)`）。`decision_engine.gd:58 rank_scored_ctx` 我查過，跟 `TradeValuation`/`_stock` 無關（自己一條獨立語意），排除對。

## ★★但「單位＝`_stock(null,…)`到不到得了」這句你推對了，卻沒推到底
你把 `player_trade_system.gd:19` 標「範圍外，各自要自己的 caller 窮盡，不併」——★**但你沒做那個「自己的 caller 窮盡」，我做了，結果不安全**：

`_sellable_qty(team,res,leader_values={},state=null)`（`player_trade_system.gd:18-19`）**自己也有 default**，內部呼叫 `TradeValuation.reserve(team,res,leader_values,state)`——這條鏈跟你已經抓的那條**是同一條**，只是入口多疊一層。★**它有沒有被空著呼叫？有，而且就在 `headless_test.gd`（baseline-7 那個檔）裡**：

```
headless_test.gd:11652   var state := WorldState.new()   # ★同上：reserve 的 state default 讓漏傳編得過
headless_test.gd:11657   assert(pts._sellable_qty(t, "material") < 1.0, ...)      ← state 沒傳
headless_test.gd:11658   ...pts._sellable_qty(t, "material"))                      ← 同上
headless_test.gd:11660   assert(is_equal_approx(pts._sellable_qty(t, "material"), ...   ← 同上
headless_test.gd:11665   assert(pts._sellable_qty(t, "material") > 40.0, ...)      ← 同上
```
★★**`:11652` 的註解是這個測試自己寫的、自我認罪的證詞**：「reserve 的 state default 讓漏傳編得過」——寫這行的人早就知道這是在吃 default 的便宜。

## ★崩點跟你抓到的那兩個同型
`_sellable_qty(t,"material")` 省 `state` ⇒ 用自己的 `null` default ⇒ 傳進 `TradeValuation.reserve(team,res,{},null)`——
★★**這是「完整 4 引數呼叫」，不是「少傳一個引數」**——`reserve` 就算把 `state` 改必填，這裡照樣編得過（引數個數對），只是值是 `null`。
⇒ 一路 `_reserve_factor→_urgency→_food_urgency→_stock(null,…)` ⇒ **`_stock()` fallback 一刪，這 4 行下次跑 `headless_test.gd` 當場崩**——不是「以後有人跑才炸」，是**這票一 merge、下一次例行 headless 跑就炸**，比 `slice_a_observe.gd` 那個嚴重，因為它在 baseline-7 主測試檔裡。
⇒ **④「編譯即驗收」接不住這個**：這不是省略引數的編譯錯誤，是引數個數對、值是 null 的執行期崩潰——跟你抓到 `ask_price` 那條同一種「單位不是函式是可達性」，只是這次可達性穿過了另一個檔案自己的 default。

## ⇒ 要你補的（第三條，動工前必須先接住）
| # | 位置 | 處置 |
|---|---|---|
| C | `headless_test.gd:11657/11658/11660/11665`（4 處，同一支 `_test_trade_reserve_no_drain`） | 補成 `pts._sellable_qty(t, "material", {}, state)`——`state` 就在同函式 `:11652` 手上 |

補完 C 之後，`_sellable_qty` 自己的 default（`player_trade_system.gd:19`）也會變成零 users——★**要不要順手一起刪，你裁**（跟這票 8 個同政策，但你已經明講這個檔要獨立開票，我不越界替你決定，只確保 C 補了讓這票不會一 merge 就崩）。

**A、B（你上一封已定案）＋ C（這封新找到）都接住後才能刪 `_stock()` fallback。** 判準本身（八個一起刪、驗收①錨定義側）沒問題，不用再動；只差這一條呼叫端。
