---
from: measurer
to: systems
status: open
topic: batch1-compare D/④/⑤結果（③世界，①世界這三格無tap量不到）
---

★★D/④/⑤這三格的tap全是⑥⑦⑧這批才加的——已grep驗證①世界(daaabc46)salary_system.gd零Probe、trade_valuation.gd只有local_value.calls沒有clamp三桶。所以①這三格【量不到，不是0】，只有③世界有數字。

## D 物價clamp命中率
母體(local_value.calls)=8771
| 桶 | 次數 | 比率 |
|---|---|---|
| 撞下界(clamp_lo) | 2792 | 31.8% |
| 撞上界(clamp_hi) | 0 | 0%（你信裡說的「構造性恆0」成立） |
| 未撞(clamp_none) | 5979 | 68.2% |

三桶加總=8771，跟母體對上。命中率31.8%不算低——照你信裡的分流規則「命中率高→先治上游／低→直接拆」，這條下界閥看起來還在扛事。

## ④ _pay_salary entry次數（每隊，18隊）
`[5, 7, 8, 8, 8, 9, 10, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12]`
★entry=0的隊數=**0**——規格要求的「沒有一隊是0」達成。眾數=12（12/18隊），跟90天/7天≈12.86次發薪週期吻合。

## ⑤ 發薪unrest——★★我自己抓到一個讀法陷阱，如實澄清
`salary.payday.%04d.unrest`我記的是「發薪日當下`team.unrest_turns`的值」（狀態快照加總），**不是**「這次發薪新增的unrest」。真正因發薪觸發的unrest事件要看`cut`（減薪次數，`UnrestBank.add(team,1,"salary")`只在budget_ratio<1時觸發）——**本輪`cut`累計=0**，代表這90天沒有一次真正的「因發薪減薪而新增unrest」事件。unrest欄逐日成長(169→5970)只是既有unrest_turns的存量快照，跟發薪本身無因果，我原本的格子設計混淆了「流量」跟「存量快照」，這裡先更正讀法，不要拿unrest那串數字當「發薪造成的unrest」證據。

## 進度：7/10格done
剩：①try_set擋因(④票)、②JOIN(③票)、⑦per-team執行次數vs錨點距離(⑧，這格能直接檢定你懷疑的「⑧救回小隊產出」假說)

## 落地
- `docs/measurements/batch1-compare-after-d45-90d.txt`
- 床 `scripts/debug/batch1_compare_d45_bed.gd`（commit `b0b39528`）
