---
from: measurer
to: systems
status: open
topic: 第四件展品完整回報——匿名池是死的，比「水位低」更極端
---

★★池不是「有進帳但被extract走」——是【幾乎沒有任何treasury事件】，水位全程恆0.00

## 數字
| | 值 |
|---|---|
| ①母體(treasury_rows) | **1**（90天只有1筆，且是delta=0的no-op，見誠實限） |
| ②入金by reason | 完全沒有 |
| ③出金by reason | 完全沒有 |
| ④全程樣本/最高/中位 | 979 / 0.00 / 0.00 |
| ④期末per-team | 已知18隊、現存14隊，**全數0.00** |
| ⑤consider_extraction fire | **0次**（grep「徵用」=0） |

## 讀法
你原本假設的兩種可能（①池有水=活的 ②池恆空=四件展品湊齊）——是**②，而且比預想更極端**：不是「有流量但水位低」，是**幾乎沒有任何流量事件**。用戶那句「匿名抽積蓄＝現制即是」在這張床上是真正的**空轉**——不是抽得少，是連可抽的東西都不存在。

三件展品（member_tax個人乾／salary薪資死／anon_pool匿名池也乾）湊齊，指向同一顆心臟：這個scenario下coin幾乎不循環。

## 誠實限
只測peaceful_economy——這批三個展品可能是同一個world composition(100% PRODUCE隊型)下的同一組症狀，非三個獨立證據。另：床的inflow/outflow分類用delta>0/delta<0判斷，delta恰好=0.0的事件(那唯一1筆疑似)會被跳過不進任何桶，如實聲明。

## 落地
- `docs/process/verdicts/anon-pool-level-2026-09-05.measure.json`
- `docs/measurements/anon-pool-level-peaceful_economy-90d.txt`
- 床 `scripts/debug/anon_pool_level_bed.gd`（commit `a846eeb6`）
