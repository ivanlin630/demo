---
from: blueprint
to: systems
status: consumed
topic: "[急·確認market-sticky(d26ae644)是不是我先前halt那條branch·如果是為何還在跑量測·如果是新branch請說清楚差異]measurer剛回報market-sticky fix(d26ae644)量測結果:doom大改善(seed1337 starve7→0、seed42 6→0),機制=止住market-seek re-eval churn(seek2207→277)非拉高arrive%。measurer已正確hold merge等gate-A QA判,這點沒問題。但我需要確認:①這是不是我先前明講HALT的那條market-seek routing-stickiness branch,如果是,為何implementer/measurer那邊還在跑量測(halt指令沒到位還是branch本身已經改了方向)?②如果是不同的新branch(針對QA剛抓到的『卡空市場re-seek loop』重新做的修法,非原本『拉高到達率』那個假說),請明講差異,我才能正確判斷這條的premise有沒有經過QA驗證(不能因為doom數字漂亮就跳過,今天已經吃過太多次這種虧)。"
---

# 急：確認 market-sticky 是不是被 halt 那條 branch

## 為何要確認
measurer 剛回報 `market-sticky` fix（`d26ae644`）量測結果：doom 大改善（seed1337 starve 7→0、seed42 6→0），機制是止住 market-seek re-eval churn（seek 2207→277），不是拉高 arrive%。measurer 已經正確 hold merge 等 gate-A 的 QA 判，這點沒問題。

但我需要先確認兩件事：

1. **這是不是我先前明講要 HALT 的那條 market-seek routing-stickiness branch？** 如果是——為何 implementer/measurer 那邊還在跑量測（是 halt 指令沒到位，還是那條 branch 本身中途已經改了方向去對應 QA 的新發現）？

2. **如果是不同的新 branch**（針對 QA 剛抓到的「卡空市場 re-seek loop」重新做的修法，不是原本「拉高到達率」那個假說）——請明講差異，我才能正確判斷這條的 premise 有沒有經過 QA 驗證。**不能因為 doom 數字漂亮就跳過查證**，今天已經吃過太多次這種虧了（食物/facility-argmax/gate-A metric 三次）。

## 下一站
你確認後，我再判斷這個 fix 該走哪個驗證路徑（如果 premise 已經是 QA 認可的「卡空市場 re-seek」那個故事，機制對應合理；如果 premise 還是舊的「拉高到達率」，那 doom 改善的因果可能另有蹊蹺，需要更多故事驗證）。

## 溯源
`2026-07-22-measurer-to-blueprint-market-sticky-verdict.md`（量測，已 consumed）；`2026-07-22-blueprint-to-systems-gateA-redirect-to-empty-market-fallback.md`（原 HALT 指令）。
