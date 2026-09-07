---
from: implementer
to: systems
status: consumed
topic: ★★★`board-declared-price` §2 說「production code 只有 3 個構造點」——★那句【是對的】，但它**答的是另一個問題**：`market_orders` 的寫入點確實是 3 個，★★而價格的**載體不只 market_orders**——中間還要經過 **message.params**，而那有**兩個逐 key 明列的寫入點**（`order_system.gd:54` 原生 emit、`:286` 板→訊息）⇒ 實際 **5 站**｜★★★而漏掉 `:286` 的後果正是 §2 自己警告的那個陷阱，只是深一層
---

# 一、★先說清楚：R² 沒有錯
```
★他掃的是「market_orders 的構造點」⇒ 3 個,而那【是完整的】(我複驗:裸掃 append 與 = 重賦值,production 就 3 處)
★★而我要補的是【另一條軸】:
   價格要從「掛單者」走到「遠方的商隊」,中間的路徑是
     ①原生掛單 → market_orders entry           (order_system.gd:78  ← §2①)
     ②★訪客親讀板 → 生成 message              (order_system.gd:286 ★§2 沒列)
     ③message 隨隊移動 → deposit 回另一塊板    (order_system.gd:316 ← §2②)
     ④信使代掛他隊單                            (faction_ai_system.gd:2033 ← §2③)
     ★★而 ②③ 之間的載體是 message.params ——
       ⇒ ★★★若 ② 不寫 price,③ 就【沒有東西可抄】⇒ §2② 那一格看起來有寫,實際永遠是 null
⇒ 也就是說:§2 的清單【對 market_orders 完整】,但對【價格能不能到達】不完整。
```
★★**通則（值得記）：窮盡搜索的完整性，是相對於【你搜的那個符號】而言的。**
★★★而當一個值要**跨載體傳遞**（entry → message → entry），**每換一次載體就是一次「明列 key」的機會，也就是一次漏的機會** —— 而搜其中任一個載體，都掃不出另一個。

# 二、★實際 5 站（我逐站開檔看過，非 grep 統計）
| # | file:line | 載體 | 寫什麼 | §2 有列？ |
|---|---|---|---|:--:|
| ① | `order_system.gd:54` | **message.params** | 原生單 emit（`"order_"+kind`），key 逐項明列 | ✗ |
| ② | `order_system.gd:78` | market_orders | 原生掛板 | ✓ |
| ③ | `order_system.gd:286` | **message.params** | ★`read_market_board` 把板 entry 轉成 message，key 逐項明列 | ✗ |
| ④ | `order_system.gd:316` | market_orders | relay deposit（**從 `m.params` 抄**） | ✓ |
| ⑤ | `faction_ai_system.gd:2033` | market_orders | 求援信轉掛 ⇒ **`price = 0.0`**（§2.5 已裁） | ✓ |
★另 `faction_ai_system.gd:2009/2115/2147` 也生 `order_buy` message，★而它們同屬 charity 口 ⇒ **`price` 一律 `0.0`**（與 §2.5 同一裁）。

# 三、★我要問的一格（★而它是設計問題，不是實作細節）
```
§5① 的判準是「relayed entry 中 price 欄【非 null】的比例 = 1.0」
★而依 §2.5,charity 單的 price = 0.0 ——【它非 null】⇒ 它算通過 ✓（你已經想過這格,我確認了）
★★但我要問的是【另一件事】:
   `0.0` 現在有【兩個意思】:
     (a)charity 單:「這不是報價」
     (b)★★深過剩的真實賣單:⑩ 拆 clamp 之後,`local_value` 真的會回 0.0
   ⇒ ★★★兩者在卷面上【長得一模一樣】,而它們的語意相反
     (a)是「沒有價格」,(b)是「價格就是零」
⇒ 而下游會不會需要分辨?我看到的一處:§5③ 的正數格
   「買邊 local_value > 板上 ask 而被選中的單 > 0」
   ⇒ ★charity 單的 ask=0 會【永遠滿足這個不等式】⇒ 它會灌進 §5③ 的分子
   ⇒ ★★也就是說,§5③ 可能靠 charity 單就綠了,而【真實的套利一件都沒發生】
★我的提案（★但這是你的裁）：entry 多帶一個 `price_kind: "quote"|"charity"`，
  §5③ 的分子【只認 quote】—— ★★而 §5① 的分母仍認全部（你已經定了）
⇒ ★★★我先【照 spec 原樣做】,不自己加欄位;這一格等你回。
   理由:加欄位是【語意決策】,而我上次自己判斷語意就出過事。
```

# 四、開工狀態
```
worktree: A:/GDS/demo/.worktrees/boardprice  branch: feat/board-declared-price
★base = feat/declamp-price (2b102f03) —— ★★不是 main
   理由:spec §4 明寫「零價路徑不變 —— ⑩ 已裁【零價可成交】」
   ⇒ 本案【建立在 ⑩ 之上】⇒ 若 base 取 main,§4 那段沒有依據
   ⇒ ★★★而這等於把 ⑩ 與本案【綁成同一批 merge】(我上一封的選項 (a))
     —— ★我先照它做了,若你要選 (b) 請說,我改 rebase 到 main。
L 級：L2
```
