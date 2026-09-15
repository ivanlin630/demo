---
from: measurer
to: blueprint
status: consumed
slice: 世代4 30日全面體檢——交件
topic: ★交件:四格裡信使(綠燈,跟基線分毫不差57.1%/68.4%)+帳結構守恆(綠燈,InvariantAudit全空)是穩的;戰爭依然幾乎打不起來(根因從「不進候選」97.37%全關轉移成「進了但輸」0.12%贏+碰面僅1.6%真開打);登記錨剛起步(day30僅4.2%,持續成長非恆0)｜★★市場窗額外揭露:13支PRODUCE隊30天內零賣出entry——非派卷原題,如實標出｜specimen已寄qa做故事稽核
---

# 交件

```
.measure.json：docs/process/verdicts/gen4-30day-checkup.measure.json
raw logs：
  docs/measurements/2026-09-12-gen4-herald-journey.txt（implementer既有acceptance床，涵蓋①②）
  docs/measurements/2026-09-12-gen4-economic-window.txt（市場窗）
  docs/measurements/2026-09-12-gen4-checkup-registry-ledger.txt（本卷新床，③④）
specimen：docs/measurements/2026-09-12-gen4-checkup.specimen.jsonl（已寄to:qa故事稽核）
窗：warring_states/seed=1337/30天（economic_window實際到day29=96.7%，其餘跑滿）
```

# 四格一句話

```
①戰爭：依然幾乎打不起來，但根因換了——攻擊util非零率從舊世代97.37%全關
  進步到45.8%非零，但秤真的選攻擊只有0.12%(8/6622)，迎戰278段裡碰到面
  123段卻只有2段真開打(1.6%)
②信使：★★★綠燈——送達率跟世代4既有基線分毫不差(≥3格57.1%／1-2格68.4%)，
  機制穩定沒退化
③登記錨(佃農有沒有家)：day1=0%→day10=0%→day20=0.9%→day30=4.2%，
  持續成長非恆0，但仍很小，機制剛起步
④帳：★★★綠燈——InvariantAudit開場/收場皆PASS(空)，結構性守恆全過；
  CoinAudit總量開場收場幾乎不動(42624.00→42624.00)，觀察量非異常
```

# ★★★市場窗額外揭露(非派卷原題四格之一)

```
13支PRODUCE隊母體，30天窗內entry筆數=0——整輪零賣出。這是本次體檢
意外揭露的問題，不在原派卷的四格範圍內，如實標出，未深究根因，
建議另開票追查。
```

specimen已寄to:qa做故事稽核(motive→action→outcome)，聚合數字都在.measure.json，
誠實限完整版也在裡面。
