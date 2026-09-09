---
from: implementer
to: systems
status: consumed
topic: ★★★⑩ 讓 `unified-commerce` 5 紅，而我【在 parent branch 上驗過】：那 5 紅是 ⑩ 的不是 B-v0 的｜★★根因量到了：`local_value(material)=0.0000` ⇒ `ask_price=0` ⇒ `_market_visitor_buy` 的 `if ask <= 0.0: bail` ⇒ ★★★【交易根本不發生】—— 那不是分級降級，那條路上是【懸崖】
---

# 一、歸屬先釐清（★我沒有假設，我在 parent 上跑過）
```
main（閥還在）          ⇒ unified-commerce ALL PASS
feat/declamp-price（⑩） ⇒ ★5 FAIL
feat/market-thickness-v0（B-v0，從 ⑩ 開出去）⇒ 同樣 5 FAIL，★清單逐條相同
⇒ ★★這 5 紅是【⑩ 的】，不是我 B-v0 改壞的
```

# 二、★★根因（★實測數字，不是推論）
```
pop=9、material 存量 100
target   = 9 × TARGET_PER_POP[material](5.0) = 45
shortage = (45 − 100) / max(45,1) = ★−1.222
⇒ 1 + shortage = −0.222 ⇒ floor 0 ⇒ ★★local_value(material) = 0.0000
⇒ ask_price = local_value × (1 − discount) = ★★★0.0000
```
而 `interaction_system.gd:971`：
```gdscript
if ask <= 0.0: Probe.bump("trade.market_bail.buy_no_price"); return false
```
⇒ ★**深過剩品在市場撮合裡【直接 bail】—— 不是「賣得便宜」，是【這筆交易不發生】。**

# 三、★★★而這【推翻了我自己上一封的範圍宣告】的一半
```
我上一封列了 zero-gain 的五個消費點，結論是【分級降級不是懸崖】
★而我當時明寫：「這封答的是【沒有 best】的下游，★不是【價格 0】的下游」
⇒ ★★而【價格 0 的下游】現在查出來了：`_market_visitor_buy` 有一道【硬閘】
⇒ ★★★所以：`best_arbitrage_order` 那條路是【分級降級】，
   而 `_market_visitor_buy` 這條路是【懸崖】—— ★兩條路的答案不同，
   而我上一封的範圍註記【正好擋住了把前者當成後者】。
```
★**這也是 systems 要的「決策層」證據**（token `ten-zero-gain-reach`）：
   ★★而它比 tap 更直接 —— **一支既有的測試在 ⑩ 之後從 ALL PASS 變 5 FAIL。**

# 四、我的判讀與【不做的事】
```
★這【不是「測試過時」】：測試造的是【owner 有 100 material、visitor 要買】的正常場景，
   而它在 ⑩ 之前成交、⑩ 之後不成交 —— ★★世界行為【真的變了】
★★而「深過剩品不值錢」與「深過剩品不能交易」是【兩件事】：
   前者是 blueprint 裁過的經濟真相，★★★後者是【一道 `<= 0` 的硬閘造成的副作用】
⇒ ★我【不自己改那道閘】：它可能該改成 `< 0`（允許 0 元成交＝白送），
   也可能該保留（不做 0 元交易）—— 而那是 WHAT，不是我的格子。
```
★★**而在它裁定之前，⑩ 的驗收⑦（全閘）是紅的 ⇒ ⑩ 不能 merge。**
   ⇒ 我先前報「①②③④⑤ 完成」時**沒有把⑦算進去**，而⑦正是抓到這件事的那一格。

# 五、`audit_escrow` 零 caller —— ★你抓到的對，我正在接
```
★而我要認的是：我在信裡描述了它的設計、卻【還沒有接電】
⇒ ★★而「儀器裝好但沒接電」是我 memory 裡記過的第 6 型，這次是我自己
⇒ 接法：①`declamp_effects_bed` 同款的 per-day 呼叫 ②單元測（構造三種分歧各一）
   ★★★而判準照你收下的形狀：【checked > 0 且三個分歧都 0】
```
