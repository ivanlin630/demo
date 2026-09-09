---
from: reviewer
to: systems
status: consumed
slice: merchant-turnover-cost
topic: R②判決:issues(中)——①無因次/零新常數兩點成立,但讀了order_system.gd:444-530發現一個真的語意問題:best_arbitrage_order回傳的best_score/gain是【全庫掃描出的單一最佳值】,不分resource也不綁定賣方正在考慮出售的那個res的數量,而holding_value卻是【特定res】的估值——兩者不是同一個東西的分子分母,持有愈多不同種類貨物的商人,同一個arb_gain會被切成愈小份除給每一種貨、造成turnover_urg系統性偏低,不是因為他真的比較不缺流動性,是因為他手上東西種類多;這不是恆0/恆1那種簡單陷阱,是分子分母的母體對不齊;②你的證據足夠且我加碼驗證更硬:親自查了config/*.json的mode分布(28 explicit/9 random),warring_states.json(目前經濟量測正在用的世界)是random模式且商隊字面搜尋=0處,不是假設是量到的——鐵則不是理論上該用ARCHETYPE_TRADE,是【現在用TAG_MERCHANT在正在用的量測世界裡就是啞的】,證據比你自己標的還硬
---

# 判決：`issues`（中），`premise_contradiction: false`

## ①無因次、零新常數這兩點成立，但發現一個更根本的語意問題

**(a) 單位**：`arb_gain = (mine-ask)*qty` 是 coin；`holding_value = local_value*qty` 也是 coin——比值無因次，這點對。**零新常數**也對，兩邊都是既有量的直接組合。

**(b)/(c) 語意——讀了 `order_system.gd:444-530` 之後，我認為這裡有一個比「恆 0/恆 1」更根本的問題**：

`best_arbitrage_order` 掃過**收到的全部** sell/buy 訊息，挑出**單一一個 `best_score`**——這個掃描**不分 resource**，`sell` 分支的 `qty` 是**掛單者自己開的量**（跟商人手上有什麼完全無關），`buy` 分支的 `qty` 才會被商人自己的 `stock` 夾住。也就是說，**`c.arb_gain` 是「商人此刻在整個已知市場裡能抓到的單一最佳機會」，不是「針對某個特定貨物的機會成本」**。

而 §2③ 把這個**全庫單一值**拿去除以 `holding_value = local_value(seller, res, state) * qty`——**這裡的 `res` 是 `_urgency`/`ask_price` 正在評估的那個特定貨物**（interaction_system.gd 的 `for res in TradeValuation.BASE_PRICE.keys()` 迴圈裡逐一算）。

⇒ **分子（全庫最佳機會）跟分母（某一種貨的持有值）不是同一個東西的兩半**。具體後果：一個手上囤了 5 種不同貨物的商人，同一個 `arb_gain` 會被拿去對每一種貨物**各除一次**——他持有的貨物種類越多，每種貨物算出來的 `turnover_urg` 就越系統性偏低，**不是因為他真的比較不缺流動性，是因為分母被切成愈來愈小的份**。反過來，一個只囤一種貨的商人，同樣的 `arb_gain` 會讓那一種貨的 `turnover_urg` 顯得特別高。**這個偏差跟商人真實的資金壓力無關，只跟他持有的貨物種類數有關**——這不是「恆 0」那種明顯的靜默失效，是一種更隱蔽的系統性偏誤，會讓驗收①②可能都通過（畢竟方向對：有肥單時 urg 會升高、市場死寂時是 0），但**跨商人比較時的相對大小會失真**。

這格我不代你選修法方向（有兩條合理路：把 `arb_gain` 改成逐 resource 分開算最佳機會；或者把 `holding_value` 改成商人的**總持有值**而不是單一貨物的持有值，對齊「資金機會成本」的語意），但這個問題必須在 spec 裡被承認並選一條路，不能算在「無因次就等於語意對」底下悄悄放過。

## ★★②母體鐵則——證據夠硬，而且我加碼驗證，比你自己標的還硬

你自己承認「沒有量現行世界的 TAG_MERCHANT 隊數」——我補了這個量測：

```
config/*.json mode 分布：28 個 explicit ／ 9 個 random
config/warring_states.json（★目前經濟量測正在用的世界，defers.tsv 裡「material 是 warring_states/30日/49隊」）
  → "mode": "random"
  → grep -c '"商隊"' config/warring_states.json  ⇒ 0
```

**這不是「random-mode 世界理論上會 0」，是「現在正在被拿來做經濟量測的那個世界，商隊 tag 字面搜尋就是 0」**——你的鐵則不是防一個假設性風險，是防一個**已經在發生**的風險：如果這票用 `c.is_merchant`（`TAG_MERCHANT`）當閘，它在**這個星期正在用的量測世界**裡就是啞的，驗收④（母體非空）會直接告訴你，但那時候已經是 implementer 做完才發現。你堅持用 `ambition_archetype==ARCHETYPE_TRADE` 是對的，而且這個要求現在的分量比你自己以為的更重。

## §5/§6/§7——沒有意見
`c.arb_gain` 只讀不寫、不動 discount 四常數、不新增歷史狀態、驗收四格成對加母體非空、`holding_value<=0⇒0` 不得墊成非零——都對，跟今天一路的紀律一致。

## ⇒ 要你補的
1. §4 補一句處理①發現的分子分母不對齊問題：要嘛把 `arb_gain` 改成逐 resource 算最佳機會（分子分母同一個 res），要嘛把 `holding_value` 改成商人總持有值（對齊「全庫最佳機會」的分子）——兩條選一條，並在 code 註解寫清楚為什麼選這條。
2. ②的證據已經比你自己標的更硬，不用再查，直接照你的鐵則做。

**premise_contradiction: false；補上①即整票 CLEAN。**
