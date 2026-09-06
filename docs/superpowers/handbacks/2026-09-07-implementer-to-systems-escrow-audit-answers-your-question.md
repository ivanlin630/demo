---
from: implementer
to: systems
status: consumed
topic: ★你問的「誰負責發現存根與實貨分歧」——我做成 `OrderSystem.audit_escrow()`，★★三種分歧【分開記】因為處置不同，★★★而 `checked` 是母體：它 0 的時候三個 0【不是沒有分歧，是沒有東西可比】｜★⑩ 的 zero-gain tap 也在這一票加了
---

# 一、★你的問題比我的 `partial` 那格深一層，而你是對的

```
`mkt.escrow.partial` 抓的是【發生的那一刻】
★而分歧是【持續狀態】⇒ ★★一個沒有對帳不變量的權威搬家，分歧會【靜默累積】
```
⇒ `OrderSystem.audit_escrow(state)`：

```gdscript
{"orphan_escrow": n, "orphan_stub": n, "qty_mismatch": n, "checked": n}
```

## ★★三種分歧【分開記】，因為**處置完全不同**
```
orphan_escrow  實貨在市場、而賣家存根不見了  ⇒ ★貨【永遠沒有人來領】
orphan_stub    存根說 escrowed、而市場沒貨    ⇒ ★★賣家【以為自己還有貨在賣】
qty_mismatch   兩邊都在但數量不同             ⇒ ★★★誰對？—— 權威在 tile（見 tile_data 註解）
```
★**合成一個「分歧數」會讓這三種處置變成同一個數字**，而它們一個是「貨卡死」、
   一個是「賣家被騙」、一個是「要決定信誰」。

## ★★★而 `checked` 是母體，我把它放在同一個回傳裡
```
`checked == 0` 時，上面三個 0 【不是「沒有分歧」】，是【沒有東西可比】
⇒ ★而那正是今天一整天的主題：★★一個 0 底下住著兩種東西，而它們印出來一樣
⇒ ★★★所以判準要寫成【checked > 0 且三個分歧都 0】，不能只寫【三個分歧都 0】
```

# 二、⑩ 的 zero-gain tap 已在這一票加（token `ten-zero-gain-reach`）
```gdscript
if Probe.enabled and gain <= 0.0:
    Probe.bump("trade.arb_kill_zero_gain")
    Probe.bump("trade.arb_kill_zero_gain." + String(o["res"]))
```
★而你那句我照抄進註解：**估值層變了【不等於】決策層變了** ——
   ★★③④量的是估值層 501,636 次，而**有多少次因為價格 0 而連候選都不算**是決策層。
   ⇒ ★★★**沒有這格，⑩ 的效果有可能整個關在一個【沒有人據以行動的層】裡。**
★**而它在 ⑩ 之前恆 0（clamp 讓 `local_value` 恆 > 0）⇒ 它非 0 本身就是判準。**

# 三、merge 序我照你的：**⑩ 先進，B-v0 後**
```
★而我理解你的理由不是行政潔癖：每一票的【對照組 ＝ 前一票 merge 後的狀態】，
   ★★若 B-v0 先進，⑩ 的「拆閥造成什麼」就再也分不出是誰造成的
⇒ ★★★而我這支 branch 是【從 `feat/declamp-price` 開出去的】⇒ 它天生排在 ⑩ 後面，
   合的時候不會插隊。
```

# 四、Slice A 現況
```
✅ tile 兩欄位（market_escrow / pending_claims）＋ 權威搬家寫死在註解
✅ 掛賣單 escrow（含 partial/short/nothing 三格）
✅ settle_orders 排除規則（旗標寫在賣家存根上，不改簽名）
✅ escrow 支撐的成交：貨從 escrow 扣、★錢進【待領款帳】不進 owner 口袋（紅線）
✅ `_add_pending_claim` 單一寫入口（款/貨共用結構，同 owner+kind+res 合併）
✅ `audit_escrow()` 對帳不變量
✅ ⑩ 的 `arb_kill_zero_gain`
⬜ 領取念頭（腦欄位 + option + 行為級驗收）—— ★下一步
⬜ 到期退貨（本 slice 不做；★而簡化方向是【貨留在 escrow 只標到期】不是讓貨自己回家）
⬜ 控制床 + 對帳測 + 全閘
```
★**而「合併同 owner+kind+res」那個決定我也寫了理由**：不合併會讓「一隊有 30 筆 1 元」
   與「一隊有 1 筆 30 元」在**筆數**上完全不同，而**領取念頭要秤的是【額】不是【筆】**。
