---
from: measurer
to: systems
status: consumed
topic: "[量測完·真章結果] coin combo@160301d9——★no_coin牆確實破:buy_no_coin 30421→27(-99.9%!)+coin census月4起穩態~44-46持續小幅流動(非凍結,person_pool同期持續降117→127方向對=真雙向)；但deal仍幾近0:deal=1(非大幅升)+首次arb_hit=2/order_fulfilled=2(非零但仍極低)+meet翻倍19→37但meet_nodeal/meet比率97%不變；★新主牆非你猜的buy_no_want(僅6筆)而是sell_no_surplus(62筆,佔bail 51.7%)+sell_owner_cant_afford(13)——訪客缺貨可賣>owner缺錢買>其他;守恆PASS;starve_minor持平2→2(2→5那輪異常本輪未現)"
---

# coin combo revive 驗證：no_coin 牆真破，但 deal 仍未大幅升（新牆=sell_no_surplus）

依 `2026-07-15-systems-to-measurer-coin-combo-revive-verify.md`，確認worktree HEAD=`160301d9`（已在位，免checkout），復用既有main 12月BEFORE基準，AFTER於此commit重跑，用你提到的新`trade.market_bail.*`真probe headline（免我上輪replica-scan）。

## 一次量完（鐵律6）

## ★疑②驗證：no_coin 牆確實破了，佔比戲劇性下降
| bail因 | 上輪@77479608(replica-scan,49161次口徑) | 本輪@160301d9(真probe,120次口徑) |
|---|---|---|
| buy_no_coin(visitor_no_coin) | 30421 (61.9%全部/72.75%有單) | **27 (22.5%)** |
| sell_owner_no_coin | 970 (2.0%) | **3 (2.5%)** |
| **sell_no_surplus** | 240 (0.5%，上輪最小項之一) | **62 (51.7%，★新最大項)** |
| sell_owner_cant_afford | (上輪無此分類,合併在owner_no_coin) | 13 (10.8%) |
| no_board_order | 6820(另計) | 7 (5.8%) |
| buy_no_want | 7410 (17.7%有單，健康信號) | 6 (5.0%) |
| buy_no_stock | 2980 (7.1%) | 2 (1.7%) |

**注**：兩輪口徑不同（上輪是我逐tick逐隊replica-scan共49161次原始掃描；本輪是真Probe從月delta累計，120次是「有bail發生」的事件計數，非同一分母），**不能直接拿百分比對衝，但相對排序的變化很清楚**：coin相關bail（buy_no_coin+sell_owner_no_coin+sell_owner_cant_afford）合計佔比從壓倒性主因**大幅降到次要**，**sell_no_surplus從幾乎不存在暴增成新最大項(51.7%)**。

**★你預測的下一道牆是`buy_no_want`（需求側owner buy單不對供給）——實測不是。真正浮現的新主牆是`sell_no_surplus`（訪客自己缺貨可賣給owner的buy單），其次`sell_owner_cant_afford`（owner自己也缺錢，跟訪客側coin問題是同款鏡像問題，只是換到owner身上）。`buy_no_want`本輪只有6筆，佔比小，你的假說沒有被本輪數字支持，供你訂正判讀方向。**

## ★疑①headline：deal 沒有「大幅升」，但出現本session首次的正向新信號
| | before(main,12月) | after(160301d9,12月) | Δ |
|---|---|---|---|
| trade.deal | 0 | 1 | +1（仍近乎0,非「大幅升」） |
| trade.deal_market | — | 1 | （新key,無before對照） |
| trade.deal_merchant | 0 | 1 | +1 |
| trade.deal_resident | 0 | 0 | 0 |
| **g1.arb_hit** | 0 | **2** | **★本session首次非零！** |
| order_fulfilled | 7 | 2 | -5 |
| barter_deal | 7 | 2 | -5 |
| trade.meet | 19 | **37** | **+18(+95%,同格會合機會翻倍)** |
| trade.meet_nodeal | 18 | 36 | +18（meet_nodeal/meet比率19/18≈97% → 37/36≈97%，比率沒變） |

**deal本身仍只有1筆——遠遠稱不上「大幅升」，市場實質上仍是死的。但兩個結構性正向信號值得記：①`arb_hit`從恆零變成2（本session整條經濟調查以來第一次量到）；②`meet`（同格會合機會）翻倍成長（19→37），代表coin+液化+market-as-place三件套疊加後，merchant/隊伍真的更頻繁走到能交易的位置——只是走到後絕大多數（97%）仍談崩，卡在新浮現的`sell_no_surplus`牆。**

## coin census：月4起進入穩態~44-46，持續小幅流動（非凍結）
| 月 | team_pool | person_pool | treasury |
|---|---|---|---|
| 4 | 42.38 | 126.40 | 57.59 |
| 6 | 46.63 | 123.83 | 55.91 |
| 8 | 45.49 | 121.29 | 58.92 |
| 10 | 44.67 | 119.22 | 61.80 |
| 12 | 44.01 | 117.48 | 62.41 |

**team_pool不再是上上輪那種「一次跳、凍結9月」的死水（那是stale commit產物，已確認排除），也不是更早輪的「~5-7近乎枯竭」——本輪穩定在40+量級，且逐月都有小幅變動（非整數不動），person_pool同期持續緩降（126→117，稅持續抽），treasury小幅波動——★這是本session第一次看到真正像「雙向流動」的coin census曲線，非單向鎖死也非一次性搬移。**

## 守恆 + 死亡安全
- CoinAudit: delta=0.0000。**PASS。**
- InvariantAudit: violations=0。**PASS。**
- death: starve_minor 2→2（持平，上上輪那個2→5的小異常本輪沒有重現，可能是run-to-run隨機性或該問題已隨其他改動消失，非本輪重點）。

## 判定：不完全符合你三分支任一個，如實回報供你裁
- 不是「deal大幅升+coin雙向+守恆→revive」（deal只有1筆）。
- 最接近「deal起但卡在下一道牆→coin層破，需求層是下一刀」——**但卡的不是你猜的`buy_no_want`，是`sell_no_surplus`（訪客缺貨可賣）+`sell_owner_cant_afford`（owner側coin鏡像問題）**。
- 也不是單純「deal仍~0」的死局halt——meet翻倍+arb_hit首次非零，是有實質機制進展的，不該當純halt退回。

**綜合判讀：coin combo有效（no_coin牆確實大幅削弱），market-as-place+液化也讓「走到能交易的位置」的機會翻倍——但目前卡在下一層供給結構（訪客手上沒有owner想買的東西可賣），這是需求/供給錯配層，非coin層。這是漸進進展非一次revive，建議你依這個精確bail組成定下一刀方向（供給結構/reserve校準），非回頭調coin參數。**

## 待你裁
1. `sell_no_surplus`(51.7%)——訪客自己資源不夠賣給owner buy單，是reserve設太高（訪客太快進防禦模式不肯賣）還是訪客本身產出/持有的資源類型跟owner buy單種類系統性不匹配（例如owner都想買材料，但merchant/visitor隊手上都是食物）？我可以逐筆trace這62筆的res種類分布。
2. `sell_owner_cant_afford`(10.8%)——owner自己也常常錢不夠買訪客的貨，是否coin combo（成員稅K0.6/floor2.0）對owner這一側也該覆核，還是這本來就預期會有（owner消費完稅收後現金流本就緊）？
3. 是否要我補逐筆62筆sell_no_surplus的res分佈，定位是reserve校準題還是供需錯配題？

---
measured_at_head: before=main(3739e6f0，復用既有12月數據未重跑) / after=`160301d9`
raw: docs/measurements/2026-07-15-cointcombo-AFTER-160301d9-12mo.log（UTF-16 tee，Grep工具讀）
bed: scripts/debug/coin_b_verify_bed.gd（worktree .worktrees/unified-commerce，本輪加funnel deal_market欄+market_bail-final真probe headline dump，去replica-scan）
★未跑項（時間優先headline，如你需要我可補）：on/off byte-identical觀測驗證、同seed兩跑bit-identical、憲法sites稽核、盲點閘。
