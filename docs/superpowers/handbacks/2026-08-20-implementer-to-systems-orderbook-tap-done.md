---
from: implementer
to: systems
status: consumed
topic: "[訂單簿 tap done（純觀測）·branch feat/orderbook-tap @2f50c1b3·T1 WorldState.next_order_id 持久計數器(非 static)+created_tick、★順手修既有隱患:原 oid=global_messages.size() 借訊息 id 空間、訊息一裁剪就重複發號·T2 order.placed/filled(兩路)/abandoned(附 sample 帶 order_id+age)/★replaced(同隊同 kind 同 res 舊單未清再掛=重掛 churn 硬證據)+分型·T3 床 watch_prefixes 加 trade./order. + ★結尾 dump 全量 Probe.counts+samples(smoke 實測 257 key)·T4 specimen orders 帶 order_id/created_tick/age_days·驗:新增秒級確定性床 orderbook_tap_test ALL PASS(4 probe 全打出)+constitution 75+det×3 byte-identical fp=dd047873b3597e2dfe1a90a679a4ad34=與現 main 相同(純觀測零行為變)·★守禁令:只跑秒級小床與 a4、未跑任何長 run;headless_test(~9 分鐘)暫緩待大考後補·★一個待你判的點:order_id 數值來源換了(不再與 message id 同號)、a4 1000t 窗 fp 相同,但若有邏輯以 order_id 排序/比大小,長窗可能有差、我沒找到這種 caller 但沒法窮盡保證]"
branch: feat/orderbook-tap
commit: 2f50c1b3
---

# 訂單簿健康度 tap done（純觀測）

## T1 身分與壽命
- **`WorldState.next_order_id`**：專用全域遞增計數器、**存 state 非 static var**（照你點的 beast id 前科）。
- **★順手修掉既有隱患**：原本 `oid = state.global_messages.size()`＝**借訊息 id 空間**，訊息一被裁剪（size 縮回）就會**重複發號**。現在專用計數器只增不減。
- 每筆 `active_orders` 加 **`created_tick`**；既有讀 orders 的地方只加欄、語意不變。

## T2 生命週期 probe
| probe | 觸發 |
|---|---|
| `order.placed`（+ `placed.<kind>_<res>`） | `post_order` |
| `order.filled` | `settle_orders` 與**直接撮合路**（`interaction_system`）兩處，qty 歸零 |
| `order.abandoned` | 逾時清除；附 `bump_sample` 帶 `order_id/team/kind/res/qty_rem/age_ticks` |
| **`order.replaced`**（+分型） | **同隊同 kind 同 res 舊單未清就再掛**＝重掛 churn 硬證據（取代 `qty_rem` 不減反增的推測） |

## T3 床的過濾器補洞
- `exam_12mo_bed` 的 `watch_prefixes` 加 **`trade.` / `order.`**。
- **★結尾 dump 全量 `Probe.counts` + `Probe.samples`** 到 JSONL 最後一行。smoke 實測最後一行 **257 個 key**，完整 `trade.*` 家族（`post_buy/post_sell/arb_*/market_bail.*/deal*/meet*`…）都在。這條就是你說的「過濾器沒列到的 family 事後救不回」的保險。

## T4 specimen orders 摘要
帶 `order_id` / `created_tick` / `age_days`。實測輸出：`{"order_id":1,"created_tick":10,"age_days":0,"kind":"sell","res":"food","qty_rem":1265}`。

## 驗（★守你的禁令）
- **新增 `orderbook_tap_test`（確定性、秒級、不需長 run）ALL PASS**：`placed=2`＋分型、`replaced=1`＋分型、`filled=2`、`abandoned=1`＋sample（`age_ticks=1201`）、`order_id` 遞增不撞、`created_tick` 有值。
- constitution **PASS 75**；determinism **三跑 byte-identical** `fp=dd047873b3597e2dfe1a90a679a4ad34`＝**與現 main 相同**（純觀測零行為變）。
- **只跑了秒級小床 + a4（1000 tick）**，**沒跑任何長 run**；**`headless_test`（~9 分鐘）依禁令暫緩**，等大考跑完我補（或你判可接受就我立刻補）。

## ★一個待你判的點（我沒法窮盡保證）
`order_id` 的**數值來源換了**（不再與 message id 同號）。a4 1000-tick 窗 **fp 相同**，且我 grep 過讀 `order_id` 的地方都是**等值比對**（board 同步、直接撮合），沒看到以 `order_id` 排序或比大小的邏輯——但那是 grep 的結論、不是窮盡證明。若你要更硬，可在大考後的短窗跑一次「換號前後 fp 對照」；或你認為等值比對已足夠就結案。

地基 KEEP。
