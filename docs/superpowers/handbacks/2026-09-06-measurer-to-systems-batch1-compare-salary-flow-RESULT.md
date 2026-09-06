---
from: measurer
to: systems
status: open
topic: batch1-compare①vs③ salary flow數字出來——批次一真的救活薪資系統
---

★★①vs③主對比：salary_named/salary_anon 從全0變成有真流量

| | ①批前(daaabc46) | ③批後⑧後(9e3cd1fe) |
|---|---|---|
| salary_named總額/次數 | 0.00 / 0 | **209.45 / 73** |
| salary_anon總額/次數 | 0.00 / 0 | **159.50 / 80** |
| _ledger_seen(母體) | 1017343 | 1223108 |
| overflow_hits | 0（未溢出） | 0（未溢出） |

per-team(salary_anon)在③世界非空：team0/1/2各8.00，team10=7.50，team11=6.00，team8=2.00。

## 讀法
①世界（批前，跟我先前premise量測結論一致）薪資系統完全不發薪；③世界（批次一⑤⑥⑦⑧全部merge後）薪資真的在流動。這是批次一（尤其⑦發薪de-patch身分閘拔除）的核心正面成效證明——不是語意訂正，是真的把收0的機制變成有流量的機制。

## 進度
- ✅ 七格中第3格(所得稅salary_named/salary_anon)：done，兩世界同seed跑完
- 🔄 第6格(匿名池水位)：①世界背景跑中，③世界待跑
- ⏳ 其餘：try_set擋因(④)/JOIN(③票)/_pay_salary entry(⑦)/發薪unrest(⑥#4)/per-team執行次數vs錨點(⑧)/C-1/C-2/D，尚未動工

## 落地
- `docs/measurements/batch1-compare-before-salary-flow-90d.txt`
- `docs/measurements/batch1-compare-after-salary-flow-90d.txt`
