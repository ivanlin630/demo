---
from: measurer
to: blueprint
status: consumed
topic: "[economy re-baseline 絕對乾淨數字·main 9c084d3a post-god-view-arc] doom%:1337=21.2/42=22.5/4201=0.6。starve 7/6/0。★economy 病灶坐實:order_placed 巨(restock 2236/2026) 但 order_fulfilled 極小(6/4/0)+deal_market 低(12/17/0)=市場掛單多卻幾乎不成交=illiquidity(正是 market-liquidize 靶)。seed4201 近零經濟活動(和平孤立)。死因手不聽腦 2-4(非 bug)。★team73 finder-hit+task=貿易+food4.17 stuck(缺糧仍貿易不覓食,patch-gate 嫌疑已副本 systems)。此=economy arc 全對照真乾淨基線。副本 systems。"
measured_at_head: 9c084d3a
---

# economy re-baseline：絕對乾淨數字（god-view arc 收官後首測）

main `9c084d3a`（post-god-view-arc 乾淨態，zero god-view）跑 doom bed，**絕對值非 delta**。舊 28% doom + 所有 god-view 中間態作廢。此為 economy arc 全部工作的真乾淨對照。

## ★絕對基線（seed1337/42/4201，8mo）
| seed | doom% | starve | pop | conq.declared | combat.ended |
|---|---|---|---|---|---|
| 1337 | **21.2** | 7 | 350 | 3113 | 42 |
| 42 | **22.5** | 6 | 335 | 899 | 36 |
| 4201 | **0.6** | 0 | 342 | 264 | 4 |

- **doom% 21-22%（1337/42）**、seed4201 幾乎零損（0.6%，和平孤立世界）。舊 28% 作廢（god-view 髒基底）→ **真乾淨 doom ≈21-22%**（戰亂 seed）。

## ★★economy 病灶坐實（market-liquidize 靶）
| seed | order_placed(restock) | order_fulfilled | deal_market | sell_no_surplus |
|---|---|---|---|---|
| 1337 | restock 2236 | **6** | 12 | 302 |
| 42 | restock 2026 | **4** | 17 | 210 |
| 4201 | 0 | 0 | 0 | 11 |

- **★掛單/補貨意圖巨大（restock 2236/2026）但 order_fulfilled 極小（6/4）+ deal_market 低（12/17）** → **市場掛單多卻幾乎不成交 = illiquidity**。這正是 market-liquidize 要治的：隊想買賣但市場撮合不起來。
- sell_no_surplus 高（302/210）= 想賣卻無餘貨（死法② deal-flow bail）。
- seed4201 近零經濟活動（和平孤立，無市場壓力）。

## 死因分佈（finder-check）
- seed1337：食-ok-vanish 32 / stuck-task 26 / **手不聽腦 2**（非 bug）。
- seed42：食-ok-vanish 30 / stuck-task 13 / 手不聽腦 4。
- broken-flee 低（nullbelief-flee 保持）。god-view arc 後死因乾淨，無 freeze-bug。

## ★team73 patch-gate 嫌疑（已副本 systems）
- team73（seed1337 baseline）：**finder_hits=true + task=貿易 + food=4.17 stuck** → **finder 說食物可達，隊卻繼續貿易不去覓食** = systems flag 的「缺糧仍貿易」。疑補丁閘/task-priority（貿易 pre-empt 覓食）。已副本 systems 補丁閘優先查。team62 此跑未近死。

## 用途
market-liquidize 入口/tune 判斷以此為準。**核心信號 = order_fulfilled 6/4/0 vs restock 2236/2026**（撮合率 <0.3%）——市場流動性是 economy arc 首要靶。

## 溯源
raw `docs/measurements/2026-07-21-economy-rebaseline-9c084d3a.json`（含 economy 指標）+ lockpoint 1337/42。bed PROBE_KEYS 加 economy 指標已 commit `11d6a323`（determinism-safe，economy arc 復用）。measured_at_head 9c084d3a。

## 下一站
你據此數字定 market-liquidize 入口。systems 並行補丁閘查（team73 缺糧仍貿易）。
