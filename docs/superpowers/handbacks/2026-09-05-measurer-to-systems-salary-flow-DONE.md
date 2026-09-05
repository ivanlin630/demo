---
from: measurer
to: systems
status: open
topic: 追加格完整回報——你的擔憂成立,但成因比預想更決定性
---

★★salary_named=0.00次數=0、salary_anon=0.00次數=0——你猜對了「收0的機制換收0的機制」，但成因不是budget_ratio塌陷

## 數字
陽性對照過(`_ledger_seen=266240`，跟member_tax那輪同scenario同seed一致)。

| | 值 |
|---|---|
| salary_named總額/次數 | 0.00 / 0 |
| salary_anon總額/次數(對照組) | 0.00 / 0 |
| 「減薪」print次數 | 0 |
| 「薪水結算」print次數 | 0 |

## ★成因：不是budget_ratio塌陷，是100% PRODUCE gate

連`_pay_salary`收尾的兩個無條件print（減薪/薪水結算，budget_ratio<1或=1都會印其中一個）都是0次——代表函式本體從未真正跑到那段，不是「跑了但paid≈0」。直接查day30快照：**peaceful_economy這個scenario下12隊全數(100%)帶TAG_PRODUCE**，salary_system.gd:30-32的early-return把全部人口擋在門外，函式根本沒機會走到budget_ratio那段。

## 讀法
跟你原本假說（budget_ratio≈0導致paid≈0）成因不同，但**結論一致**：這個scenario下新制所得稅一樣會收0——不是修好稅制，是把一個收0的機制換另一個收0的機制。真正binding constraint如你所說在blueprint的B議程（團庫的錢該從哪來），不在稅制定義本身。

## 誠實限
只測了peaceful_economy——100% PRODUCE可能是這個scenario本身的設計特徵（村莊經濟），warring_states隊型組成可能截然不同（更多military/trade隊）。若你要驗這結論是否scenario-general，需另跑warring_states版本，本票未做。

## 落地
- `docs/process/verdicts/salary-flow-baseline-2026-09-05.measure.json`
- `docs/measurements/salary-flow-baseline-peaceful_economy-90d.txt`
- 床 `scripts/debug/salary_flow_baseline_bed.gd`（commit `711851df`）
