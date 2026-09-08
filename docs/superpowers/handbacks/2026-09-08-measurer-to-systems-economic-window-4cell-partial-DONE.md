---
from: measurer
to: systems
status: consumed
topic: 經濟窗四格①②③結果DONE，④撞到driver_ledger溢出正在重測
---

## 卷面首行
HEAD=`e265b5c36f2741f52062b7862dd64ebcd74caa4b`｜樹在跑之前clean｜實際跑到day=29/目標30天(96.7%)｜seed=1337/warring_states

## ①板厚
- 全世界所有tile平均=**0.5351**（樣本15，含零市場tile稀釋）
- 只算有市場的tile平均=**11.4420**（樣本14）

## ②成交量
嘗試(trade.meet)=**1699**｜成交(trade.deal)=**360**｜market撮合(trade.deal_market)=**74**｜零撮合(trade.meet_nodeal)=**1276**

## ③價差(buy估值−sell估值)
| 資源 | 樣本數 | 平均 | p50 | min/max |
|---|---|---|---|---|
| material | 538 | -2.415 | -2.400 | -8.000/7.201 |
| food | 216 | 3.604 | 4.031 | -7.335/10.000 |
| weapon_melee_low | 67 | 30.276 | 34.000 | -6.800/68.000 |

## ★arb_kill_zero_gain
總次數=**43582**（material 30107／food 13442／weapon_melee_low 33）——零價殺單機制大量觸發，token `ten-zero-gain-reach`可視為有數字支撐。

## ④農隊收入——★撞到driver_ledger溢出，正在重測
原始跑法drain間隔2000tick，跑出`[DRIVER-LEDGER] 開始丟棄舊列`警告21次——④的0筆是被溢出污染的假0，不可信。已寫獨立小床`farm_income_only_bed.gd`(drain間隔改50，同member_tax血教訓修法)重跑，背景跑中。

## 落地
- `docs/measurements/2026-09-08-economic-window-4cell-warring_states-30d.txt`（①②③③arb_kill_zero_gain可信，④作廢）
- 床 `scripts/debug/economic_window_4cell_bed.gd`（commit `e265b5c3`）
