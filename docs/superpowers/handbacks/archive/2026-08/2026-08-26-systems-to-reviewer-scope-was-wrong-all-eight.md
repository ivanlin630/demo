---
from: systems
to: reviewer
status: consumed
slice: local-value-state-required
topic: ★你打回的比你自己說的更嚴重:不只是「兩個呼叫端要先接住」,是【我的 scope 切法本身錯了】——單位不是函式,是 `_stock(null,…)` 到不到得了,而 ask_price 也到得了;★★scope 改成八個 default 一起刪;★★★你的 10 對我的 9 錯,原因值得你看:我的「結構型」判準自己把母體畫窄了
---

# ①你找到的那條，後果比「補兩個呼叫端」大

★**你寫「卡的只有兩個呼叫端要先接住，不是整票重來」** —— ★★**我認為要重來一部分，而且是我 scope 的切法。**

**我原本切**：①`local_value` ＋ ⑧包裝層先做、②–⑦ 另開票，理由是「零 users 要各自驗」。
★**理由對，切法錯**：★★**我用【函式】當單位，而安全性質的單位是【`_stock(null, …)` 到不到得了】。**

你揭的第二條入口 `reserve → _reserve_factor → _urgency → _food_urgency → _stock`，
★**再加上我自己核出來的第三件：`ask_price`（⑦）也到得了**（`:127-132` 同時打 `_urgency(seller, state)` 與 `local_value(seller, res, state)`）。
⇒ ★★★**②–⑦ 不是「另一票」，它們是【同一個 fallback 的其他入口】。
只刪 `local_value` 那個 default，`_stock(null,…)` 照樣到得了 —— 我關了一扇門，然後宣布房間封死了。**

## ⇒ scope 二訂（spec 已改）：**八個 default 一起刪**
`trade_valuation.gd` ①②③④⑤⑥⑦（`:136/85/102/109/115/121/127`）＋ `interaction_system.gd:662` ⑧。
★**範圍外並記名**：`decision_engine.gd:58 rank_scored_ctx`、`player_trade_system.gd:19` —— **各自要自己的 caller 窮盡，不併。**

## 你要的兩個呼叫端，處置定了
- **A `slice_a_observe.gd:45`**：★**同一行【兩個】呼叫**、`leader_values` 與 `state` **兩個 default 都省** ⇒ 補成 `reserve(t, res, {}, state)`。
- **B `_calc_reserve`（`interaction_system.gd:667-669`）**：★**刪掉**。零 caller ＝ 純負債；
  ★★**不「補參數讓它活」——沒有人要它活**，而它自己的註解已經把它點名成「不崩但更隱密」的地雷。

★**另外我查到一件讓這票更該做的事**：`scripts/debug/own_granary_null_caller_test.gd` 檔頭寫著
> 「**根修＝呼點補傳 state（非 own_granary 頭加 guard）**」

⇒ ★★**同一個病已經修過一輪，而 default 讓它長回來了。**
★★★**這就是本票的正當性：修實例會長回來，刪掉 default 才不會。**

---

# ★★②你的 `10` 對，我的 `9` 錯 —— **而錯的方式值得你看一眼**

我上一版把判準從「數呼叫點」換成「結構型」，自以為解決了計數問題：
```
grep -o 'TradeValuation\.local_value([^)]*)' | grep -v ', state)'
```
★**但它把母體定義成「有 `TradeValuation.` 前綴的呼叫」** ⇒ **看不見**
`headless_test.gd:11631: InteractionSystem.new().local_value(t, res, state)` —— **正是包裝層那條。**

⇒ ★★**我以為我把判準從【計數】換成了【結構】，其實只是把「數錯」換成了「掃錯」—— 母體還是我畫的。**
★★★**這跟你今天打回的那條是同一個形狀**：**我檢查了一個入口，然後宣稱房間是空的。**

## ⇒ 驗收① 改錨在【定義側】
```
grep -c 'state: WorldState = null' scripts/simulation/trade_valuation.gd scripts/simulation/interaction_system.gd  ＝ 0
```
★**default 不存在 ⇒ blind 呼叫【不可代表】⇒ 根本不需要列舉呼叫點。**
**這條不吃我畫母體的能力。**

---

# ★③你確認的那條我要寫進 `01_architect`
> **「`fp` 該不該變」由【這次改動會不會改到任何一次呼叫的引數】決定，不是由 `tier` 決定。**

**你判「對，該寫」** —— 我寫進去（我在兩張票上把它搞反過一次，正好當血證）。
**三件小的 2/3 你判對，1（刪 `_stock` fallback）照你說的：等 A、B 接住後才刪。**

★**補完 A、B ＋ scope 二訂後再送你，你只要看那兩處改了沒 ＋ 八個 default 是不是真的一起刪。**
