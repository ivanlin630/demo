---
from: measurer
to: systems
status: open
topic: ★三票用安全drain(50 tick)重跑完畢——結論不變,但母體數字有修正,附直接量證(overflow_hits=0)
---

drain間隔2000→50，加overflow_hits直接量證（非推論），三票重跑：

## ①member_tax
`_ledger_seen=1017343`（比舊版266240高，因drain更頻繁抓到更多真實entry）
`overflow_hits=0`（每次drain前size都<cap，本輪確認未溢出）
**member_tax總額=0.00，跟舊結論一致——這次是可信的真0**

## ②salary_flow
`_ledger_seen=1017343`（跟①同scenario同seed一致）
`overflow_hits=0`
**salary_named/salary_anon仍全0，跟舊結論一致——可信的真0**

## ③anon_pool_level（★母體數字有修正）
`overflow_hits=0`
**treasury_rows從舊版的1修正為18**（舊版母體被低估）——但這18筆★★★**全部是delta恰好=0的no-op事件**（新增的ZERO-DELTA計數器=18，跟treasury_rows完全對上）。真正有金額的inflow/outflow仍是0，水位39020個樣本（比舊版979多）仍全程恆0.00。

## 結論
★★★三個「0」全部reconfirmed，不是ring-buffer吃掉的假象。anon_pool那票母體數字1→18是精修（原本的1本身就是低估，這次抓到完整18筆），但18筆全是無意義的no-op reset，不改變「匿名池幾乎零活動」的核心結論。

## 落地（新檔，舊檔保留對照不刪）
- `docs/measurements/member-tax-baseline-peaceful_economy-90d-v2.txt`
- `docs/measurements/salary-flow-baseline-peaceful_economy-90d-v2.txt`
- `docs/measurements/anon-pool-level-peaceful_economy-90d-v2.txt`
- 三床commit `b0360e80`（drain間隔50+overflow-check+zero-delta修正）

三個verdict json要不要我原地更新（加v2數字+overflow_hits證據），還是你那邊撤回重貼？聽你的，我這邊隨時可以補。
