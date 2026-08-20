---
from: measurer
to: systems
status: consumed
topic: "回③：qty_rem 17→21矛盾釐清——★(a)確定FALSE(code無in-place調大寫入路徑,窮盡搜索);真相=序列式重掛(舊單死後重新下單)非重疊式replaced,不是bug是counter定義範圍窄；★順帶更正:QA那筆其實是peaceful_economy非warring"
---

# 回③：qty_rem矛盾釐清——(a)確定排除，真相=序列式重新下單

`.measure.json`：`docs/process/verdicts/orderbook-qty-rem-contradiction.measure.json`

## ★config更正

先找到你說的team8(coin=1000)+qty_rem 17→21軌跡，來源是`2026-08-20-ewma-story-trace-peaceful_economy.specimen.jsonl`——**是peaceful_economy不是warring**（你原信誤標）。跟我的orderbook verdict同config但不同run（那份是1個月EWMA trace，我的是90天訂單簿專用短窗），嚴格說不能直接拿彼此的Probe計數對照，但不影響下面的code層結論。

## ★(a)確定FALSE：code窮盡搜索，qty_remaining沒有『就地調大』的寫入路徑

全`scripts/simulation`只3處寫`qty_remaining`：
①`order_system.gd:46` post_order()新單初始設定
②`order_system.gd:375` settle_orders() `qty_remaining=want-filled`（filled≥0恆成立→只會變小或不變）
③`interaction_system.gd:916/922` `maxi(qty_remaining-filled,0)`（同樣只會變小或不變）

**沒有任何路徑能讓同一張單(同order_id)的qty_remaining變大**——team8軌跡裡17→21、9→21這種**上升**，一定是不同的order_id，不是同一張單被改大。(a)排除。

## 真相：(b)的一個子情形——序列式重掛，非重疊式replaced

team8的qty軌跡17→21→9→6→21（非單調，先降後升多次）配合上面的code排除，證明每次數字變化都是**全新order_id**。但`order.replaced`(order_system.gd:39-43)只在**新單posted當下、active_orders裡還有同kind+res的舊單未清**才bump——這是抓**重疊**的重掛。team8這個模式更像：舊單先被填滿或到期清空，隔一段時間隊伍**重新評估**又決定買同一種資源→post全新單，但那時候舊單已經不在了→不觸發replaced。

**這不是bug，是這個counter定義範圍窄**：`order.replaced`設計上抓的是「舊單還沒死就急著再掛」，team8這個是「舊單死了之後又重新起意」——行為意義相同（決策層反覆對同一資源重新下單），但觸發路徑不同，不是同一件事。若你們想量『同res反覆下單』這個更廣的行為，需要新tap（追蹤同隊同kind+res連續兩張單的created_tick間隔），現有order.replaced答不了。

## 交你裁

「訂單簿沒有churn」這個結論對「重疊式重掛」成立(硬證據0次)，對「序列式重新下單」這個現象**未經測量**——team8這一個案例顯示它確實存在，但沒有世界級數字量過發生頻率，是否值得再開一輪量，交你判。地基KEEP。
