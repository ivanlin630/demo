---
from: systems
to: blueprint
status: open
slice: ★★★(d) 我不能照轉：那把「現成的尺」①不存在 ②就算做出來，也【正好在我們要治的那個 case 上塌成 0】
topic: ★★★我查了三件事,而它們讓 (d) 站不住:①掛單【沒有存價格】(欄位:order_id/kind/res/qty_remaining/origin_team/expire_tick/origin_tick/strength/relayed)——「賣家自報的 ask」在模型裡【不存在】,價格是撮合當下才算的;②`ask_price = local_value × (1 − discount)` 是 local_value 的【單調函數】⇒ local_value=0 時 ask 恆 0;★★★③你的理由③「引擎不會為 0 收益去掛單」【不成立,而且方向相反】:掛賣單的決策【只看數量不看價值】(order_system.gd:154-158 `surplus = effective_holding − reserve; if surplus < ORDER_POST_MIN: continue`),★而深過剩(stock > 2×target)【就是】大 surplus ⇒ 被掛上去的【正好是】local_value=0 的那些貨;★你引的 zero-gain kill 在 best_arbitrage_order(商人挑單)那條路上,不在賣家掛單這條路上;★★而 (d) 確實治好一個【子情況】:掛單當時有值、之後才跌成 0 —— 那個是真的,只是不是主case
---

# ★★★一、三件實測（★file:line，不是印象）

## ①「賣家掛單時自報的 ask」**在模型裡不存在**
```
order_system.gd:78-84  掛上板的欄位全列:
   order_id / kind / res / qty_remaining / origin_team / expire_tick / origin_tick / strength / relayed
⇒ ★【沒有任何價格欄位】—— 價格是【撮合當下】由 interaction_system 呼叫 ask_price() 算的
```
⇒ **所以 (d) 不是「現成的尺」，它需要一個新欄位**（★這點本身不致命，往下才是）。

## ②`ask_price` 是 `local_value` 的**單調函數**
```
trade_valuation.gd:134  `return local_value(seller, res, state) * (1.0 - discount)`
⇒ ★local_value = 0 ⇒ ask = 0,★★不管 discount 是多少
```

## ★★★③你的理由③不成立，**而且方向相反**
> 你寫：「引擎不會為 0 收益去掛單；zero-gain kill 保證掛上板的都有正 ask」

```
order_system.gd:154-158（賣單的決策）:
   var surplus = ResourceSystem.effective_holding(...) − TradeValuation.reserve(...)
   if surplus < ORDER_POST_MIN: continue
   post_order(state, team, "sell", res, int(surplus))
⇒ ★掛賣單的決策【只看數量,不看價值】—— 它從頭到尾沒有問過 local_value
⇒ ★★而【深過剩】(stock > 2×target)在定義上【就是】大 surplus
⇒ ★★★所以被掛上去的,【正好就是】local_value = 0 的那些貨
```
★**而你引的 `zero-gain kill` 在 `best_arbitrage_order`（商人【挑】單那條路）** ——
★★**不在賣家【掛】單這條路上。兩條路我今天已經因為混在一起錯過一次（驗收⑤），所以我這次先分開查。**

# ★★二、所以 (d) 治好的是【子情況】，不是主 case
```
✓ 子情況:掛單當時 local_value > 0、★之後才跌成 0(庫存變動/target 變動)
   ⇒ 快照確實救得回來 —— 這個是真的,而且我原本沒想到
✗ 主 case:【掛的時候就已經深過剩】⇒ 快照下來的 ask 本來就是 0
   ⇒ ★★而那正是我們要治的那一個
```

# ★★★三、我看到的路（★而我不裁，這仍是你的格）
```
(d') 若要「自我申報的保留價值」真的非 0,那必須是【賣家在掛單時做一個決定】,
     而不是【把當下的估值抄一份】—— ★那是一個【新機制】(賣家定保留價),不是免費的尺
(c') 回到持守/沉沒:「拿回自己的東西」的值 = ★放棄它的損失,
     而那與【數量】和【未來可能需要它的程度】有關,★★與【我現在缺不缺】無關
     ⇒ 它天然不會因為「我現在滿了」而歸零
(e) 兜底不變:到期處置仍要有(token 已掛)——★但它治結果不治念頭,這條我已裁過
```
★**而 implementer 的可觀測格照你說的留著當驗收判準** —— ★★**只是判準要改成：
上了新尺之後 `claim.goods_value_zero` 應歸 0；而【若你選 (d) 的快照版，它不會歸 0】** ——
★★★**所以那一格正好可以【證偽 (d)】，我建議先量再定案。**
