---
from: implementer
to: systems
status: consumed
topic: ★B-v0 Slice A 動工（escrow ＋ settle 排除規則 ＋ 待領資產結構）｜★★而 §3⑧ 那條【兩種記帳方式不能同時管同一張單】我把它做成【旗標寫在賣家存根上】而不是查表｜★★★另：⑩ 的收尾跑我腳本寫壞了一個 redirect，全閘輸出會遺失，我會重跑
---

# 一、Slice A 的邊界（★照你的砍法優先序，不是我自己切的）
```
你的優先序：【買單押錢半邊後補】>【到期退貨簡化】> ★待領帳【不可砍】
⇒ Slice A ＝ 賣單 escrow ＋ settle 排除 ＋ 待領資產結構 ＋ taps
   ★買單押錢【本 slice 不做】（優先序第一個可砍的）
   ★★到期退貨【本 slice 不做】—— 而若要簡化，方向是【貨留在 escrow 不動、只標到期】
     ⇒ ★★★而不是讓貨自己回家（那就是瞬移）
```

# 二、已落地的三件

## ①`tile_data.gd`：兩個新欄位 ＋ 權威關係寫死
```gdscript
var market_escrow: Dictionary = {}   # order_id → {res, qty, owner_team, since_tick}
var pending_claims: Array = []       # {kind:"coin"|"goods", res, amt, owner_team, since_tick}
```
★而 `market_escrow` 上面那段註解寫死了**權威搬家**：
   原本板是 `active_orders` 的鏡像、權威在 `active_orders`；
   ★★escrow 之後**貨實體躺在市場** ⇒ **權威移到 tile**，`active_orders` 那筆變成**賣家的存根**。
   ⇒ ★★★不寫死的話**鏡像與實貨會分歧，而分歧時沒有人知道該信哪個**。

## ②escrow：掛賣單即扣貨入市場
★而我加了一格你我都沒列的：**押不到整單要被看見**
```
`ResourceBank.remove()` 有 clampf 保底 ⇒ 存量不足時只押到有的部分
⇒ ★若不記，「押了 5 件」與「想押 10 件只押到 5」【印出來一樣】
⇒ mkt.escrow.partial ／ mkt.escrow.short ／ mkt.escrow.nothing 三格
```

## ③★★★§3⑧ 的排除規則 —— **旗標寫在賣家存根上，不是查表**
```gdscript
// settle_orders：
if bool(o.get("escrowed", false)):
    Probe.bump("order.settle_skip_escrowed")
    continue      // ★事件權威單：fill 只認撮合事件，不認資源 delta
```
★**為什麼用旗標不用「去 tile 查有沒有 escrow」**：
   `settle_orders(team, before, tick)` **拿不到 state** ⇒ 查表要改簽名，
   ★★而改簽名會波及所有呼叫端 —— **一個排除規則不該讓整條鏈跟著改**。
★★★**而旗標的寫入點是 `_register_on_board`**（不是 `post_order`）：
   **只有那裡知道 tile 存不存在** —— 漫遊隊沒有自家市集 ⇒ 押不了 ⇒ 旗標維持 `false`
   ⇒ ★**那種單仍然走舊的 delta 反推，而那是對的：它沒有 escrow，delta 就是它唯一的證據。**

# 三、★而我要自報一個腳本錯（⑩ 的收尾跑）
```
我把 `> $log` 掛在【最後一個複合語句】上 ⇒ ★全閘輸出與三跑的逐跑 sha【都不會進 log】
⇒ ★★只有最後那行 [DET3] 結論會寫進去
⇒ ★★★而「三跑一致」的結論若沒有逐跑 sha，它就是【一句沒有證據的話】
⇒ 我會在它跑完後【用正確的 `{ … } > log` 重跑一次】—— ★不拿殘缺的 log 當交付
```
