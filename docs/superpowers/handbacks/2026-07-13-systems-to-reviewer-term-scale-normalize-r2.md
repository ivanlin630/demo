---
from: systems
to: reviewer
status: open
topic: [R②·S2.7] term-scale normalize 設計審(大範圍~13term,壓測優先序保全+回歸面)——dispatch 前
---

# R② 設計審：term-scale normalize（S2.7）

## 前置
- 藍圖裁 A(`normalize-decision-A`)：校準既有 term 量級納入重構，優先序→coeff、base→中性執行品質。
- spec `docs/superpowers/specs/2026-07-13-term-scale-normalize.md`（`git show HEAD` 後 commit）。
- premise（term 量級落差 0-12 vs 0.25-0.55）已 code 審坐實(`term-scale-conclusion` 量級表 from terms.gd)→免 R①，僅 R②。

## 內容
核心不變量：`util = weight(人格,0-1.5) × eval(執行品質,0-1) × coeff(需求,0.15-1)`；優先序**只**由 coeff。剝 ~13 term 的 urgency 乘子→移 coeff，保 quality 因子，正規化 [0,1]。faction_duty(§7 授權)例外不動。駐守 affinity 併校。逐 bucket 4 sub-task。

## 請 R② 重點壓測
1. **優先序保全（最高風險）**：剝 base urgency 後，coeff 值域 [0.15,1] **撐不撐得住 survival dominance**？spec worked example 證餓隊覓食 20× 壓訓練——查此推算，且查**邊界**（food 略低於門檻時 survival urgency 中等→coeff 中等→survival 是否仍夠壓過機會 option，或會出現「半餓隊跑去貿易」的 regression）。這是 A 案成立與否的命脈。
2. **回歸面（~13 term 改值域）**：查逐 bucket 拆分(T1 survival/T2 threat/T3 ambient/T4 整包)是否足以早抓 regression；哪些既有不變量測最可能被波及（TC2 survival-input/consolidation/combat/established/faction 服從）——spec 列的 organic 驗收是否覆蓋。
3. **faction_duty outlier**：§7 授權軸保 1.5 不正規化——查這是否破壞「統一公平比較」本意（duty 1.5 恆壓過 need 1.0=授權該贏,還是變成新的 scale 支配 bug）？exempt 是否該連 coeff 也 exempt(授權≠需求)？我判保現況+measurer 驗服從，但請壓測。
4. **urgency 是否剝淨**：查各新 eval 有無殘留優先序乘子（雙重編碼未清乾淨）；quality 因子(dist_disc/magnet/cap)保留是否正確（這些是機會品質非 urgency）。
5. **駐守 affinity 改 `[0.3,0.1,0.1,0.4,0.1]`**：esteem 主(知足經營)是否比舊 actual-heavy 合理；行和=1 確認。

## 註
- TEST VALUE 具體量級留 measurer organic 校（同前例）。
- CLEAN 則逐 sub-task dispatch implementer(T1→organic→T2→…)。有 blocker/premise 疑慮回 verdict。範圍大，慢工細審。
