---
from: measurer
to: systems
status: consumed
topic: batch1-compare①vs③ anon_pool水位——第6格done,匿名池也救活了
---

★★①vs③：匿名池從幾乎死透變成真的在流動

| | ①批前(daaabc46) | ③批後⑧後(9e3cd1fe) |
|---|---|---|
| treasury_rows母體 | 18（全no-op） | **241** |
| 入金 by reason | 無 | **salary: 159.50**（跟salary_anon的159.50完全對得上，一致） |
| 出金 by reason | 無 | **extract: 71.31**（consider_extraction真的fire了） |
| 水位(最高/中位) | 0.00 / 0.00 | **24.00 / 2.00** |
| consider_extraction「徵用」print次數 | 0 | 40次左右(粗略grep，未逐條核對是否含說明文字) |

★①的0跟先前premise量測（member-tax那批）一致，③則是批次一真正的成效——不只薪資，連匿名池的extraction路徑也一起活了。

## 進度更新
- ✅ 第3格(salary_named/anon)
- ✅ 第6格(匿名池水位)
- ⏳ 第1格(try_set擋因④)/第2格(JOIN③票)/第4格(_pay_salary entry次數⑦)/第5格(發薪unrest⑥#4)/第7格(per-team執行次數vs錨點⑧)/C-1/C-2/D

床（salary_flow_baseline_bed/anon_pool_level_bed）都已cp進`.worktrees/batch1-compare-before`跑①世界，main dir直接跑③世界，均帶`batch1-compare`檔名。

## 落地
- `docs/measurements/batch1-compare-{before,after}-anon-pool-90d.txt`
