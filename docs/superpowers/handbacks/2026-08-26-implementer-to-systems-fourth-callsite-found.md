---
from: implementer
to: systems
status: consumed
slice: local-value-state-required
topic: ★複驗結果:9 個 default 我獨立數同意(沒有第 10 個定義);★★★但呼叫端你少了一個檔——survival_layer_unify_test.gd:170-172 三處 reserve 省 state,刪 default 後會崩;★另 C 是 5 處不是 4 處(:11666 你漏了);仍未動工
---

# ①9 個 default — **我獨立數，同意，沒有第 10 個**
```
$ grep -rn "state: WorldState = null" scripts/
scripts/simulation/decision/decision_engine.gd:58   ← ★你標範圍外，我同意（reviewer 已複驗與 _stock 無關）
scripts/simulation/interaction_system.gd:662
scripts/simulation/player_trade_system.gd:19
scripts/simulation/trade_valuation.gd:85 :102 :109 :115 :121 :127 :136
```
⇒ **範圍內 9 個，逐一對得上你三訂的清單。debug 側零個定義**（只有一條同名變數與一行註解）。

# ★★★②呼叫端你少了一個檔 —— **`survival_layer_unify_test.gd`**
```
scripts/debug/survival_layer_unify_test.gd:170  TradeValuation.reserve(t, "food", {"慎重": 1.0, "野心": 0.0})
scripts/debug/survival_layer_unify_test.gd:171  TradeValuation.reserve(t, "food", {"慎重": 0.0, "野心": 1.0})
scripts/debug/survival_layer_unify_test.gd:172  TradeValuation.reserve(t, "food", {})
```
★**三處都省 `state`，而 `res == "food"` ⇒ 走 `SURVIVAL_GOODS` 分支 ⇒ `NeedOracle.need_keep(null, …)`**
—— ★★**刪 default 後這支會崩**，和 A（`slice_a_observe`）同型。
★**它是不是「還活著」我沒判**（可能跟 `_calc_reserve` 一樣是死碼）——
**判它該接還是該刪是你的裁量，我只負責把它攤出來。**

## ★★③C 是【5 處】不是 4 處
你列 `:11657 / :11658 / :11660 / :11665`，★**漏了 `:11666`**：
```
11666:  "超 reserve 部分可賣,實際=%.1f" % pts._sellable_qty(t, "material"))
```
★**漏法跟你自承的第②次一樣**：`:11665` 與 `:11666` 是**同一個 assert 的兩行**，
**斷言行有、訊息行也有** —— ★★**訊息字串裡的呼叫一樣會執行。**

# ★④我建議的機械查法（★不吃「誰畫母體」）
**接住清單不要用人眼列，用可達性反查**：
```
# 對每個【範圍內】函式名，抓所有呼叫，扣掉最後一個引數是 state 的
for f in reserve ask_price _sellable_qty local_value _urgency _food_urgency \
         _reserve_factor _reserve_factor_food_only; do
  grep -rn "\b$f(" scripts/ | grep -v "func $f" | grep -v ", *state)" | grep -v "^\s*#"
done
```
★**我就是這樣掃到 ②③ 的。** ⇒ **建議把它當這票的「接住清單產生器」，而不是各自列。**
★★**但它會有假陽性**（多行呼叫、變數不叫 `state`）——**方向是太吵不是太鬆**，逐條看一眼即可。

# ⑤狀態
★**仍未動工**（等 reviewer CLEAN）。**②③ 兩件我沒有自己動**，因為它們會改變「接住清單」的內容，
★**而那份清單是這票的前提，不是我的實作細節。**
