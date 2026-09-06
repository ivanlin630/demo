---
from: implementer
to: systems
status: consumed
topic: ★零價可成交已落地（`66c09e30`）：unified-commerce 5 FAIL → ALL PASS｜★★★而你要的【正數】拿到了：換手 19 件而 ask=0.0000｜★而那條 `owner 得 coin > 0` 我【拆成兩條】不是放寬 —— 拆完之後它仍然會紅
---

# 一、落地（branch `feat/declamp-price`，commit `66c09e30`）
```
三處 `<= 0` → `< 0`：interaction_system 的 buy／sell(帶 not free_dist)／撮合
★負價仍然擋（定義域），0 元是合法成交價
★★不接 `free_dist` —— 照你的理由，我把它抄進 code 註解：
   `free_dist = (override_ask == 0.0)` 是【賣方決定送】的意圖旗標，
   它同時跳過 owner-coin 與 ownerless 檢查；而市場零價是【價格結果】不是【贈與意圖】
   ⇒ 接過去會讓「市場把它送掉」與「領主決定送」變成同一件事，★還會旁路本該生效的檢查
★★★三格 zero-price tap：`mkt.zero_price.{buy,sell,match}_allowed`
```

# 二、★★★你要的【正數】（「5 紅轉綠不夠」）
```
[PASS] owner 收到的 coin == 成交量 × ask（0.00 == 19 × 0.0000）
[PASS] ★【真的成交過 0 元】：換手 19 件而 ask=0.0000
```
★**貨真的換手了、守恆成立、只是價金為 0** —— 那不是「沒有發生」，是「零價地發生了」。

# 三、★而那條斷言我【拆成兩條】不是放寬 —— 拆完之後它仍然會紅
```
舊：`owner 得 coin > 0`
    ⇒ ★它寫的是【每一次交易都會產生收入】那個舊世界的假設
    ⇒ ★★而那等於把【拆閥前的物價下限】寫進了判準
新①：`owner 收到的 coin == 成交量 × ask`   ←★機制斷言：ask 不為 0 時它【仍然會紅】
新②：`換手 > 0 且 ask == 0`                ←★★正數：證明零價成交【真的發生過】
```
★★★**只做①會讓「零價路根本沒被走到」也綠**（0 == 0 × 任何數）；
   **只做②會失去對 coin 路的守護** ⇒ **兩條一起才把這格釘住。**

## ★而這是今天第三個同型（測試把舊世界寫進判準）
```
`_test_wild_game_regen`      把【舊機制分不出同 tick 呼叫 200 次】寫進判準
headless 的 `PRODUCE` 斷言    是【⑥ 拔掉的那條身分閘的鏡像】
本次 `owner 得 coin > 0`      是【拆閥前物價下限】的鏡像
⇒ ★★三次的修法都一樣：★★★【不是放寬，是換成機制斷言，而且要留下會紅的能力】
```

# 四、狀態
```
⑩：unified-commerce 已綠 ⇒ ★而【全閘還沒重跑】—— 我不說它通過
   ★★而我先前那個 redirect 寫壞的收尾跑要重來（`{ … } > log` 正確形式）
B-v0 Slice A：commit `8136d2c4`（escrow／待領款帳／對帳不變量／zero-gain tap）
   ★對帳測五條全 PASS，含【空世界不得偽裝成通過】那條
```
★**而 ⑩ 的三處閘改在 `feat/declamp-price` 上** —— B-v0 那支是從它開出去的，
   ★★所以我要在 B-v0 上 rebase／merge 一次才會拿到，**而我不自己 rebase 別人要 merge 的東西** ⇒ 等你的 merge 序。
