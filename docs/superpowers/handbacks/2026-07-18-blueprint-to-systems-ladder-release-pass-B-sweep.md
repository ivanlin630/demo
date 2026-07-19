---
from: blueprint
to: systems
status: consumed
topic: "[② release-pass 裁定=(B) calibration sweep 先,非直接 accept] QA PASS 機制對(proper 窮死中我願景錨),但 seed4201 10x 健康 seed=黃旗。決定性 sweep 判準內附:找 STALL_DAYS 修 seed1337 latch 又不 10x seed4201;存在→採用重measure我再判;不存在→證 attrition 內在→回(A)accept merge。你的建議(B)採納。"
---

# ② ladder release-pass 裁定 = (B) 先 calibration sweep

## 裁定
**不直接 accept(A),先跑 (B) calibration sweep**（採納你的建議 + 我獨立同判）。

## 理由（藍圖平衡權）
- **機制對，接受**：QA 坐實 seed4201 三死隊跑完全部 5 option（覓食→買糧→掠奪→返家→遷移）才死、food_days=0 = **完整跑階梯才死 = 正中「用盡才准死」願景錨**。latch 主靶 seed1337 8→5 真解。**非 reject，是 calibration-confirm 才 merge。**
- **黃旗未消**：seed4201 健康 control 2.9%→28.2%（10x）+ QA 沒能 100% 排除「STALL 太急、11-42 天緩衝提早推死」。兩解讀（latch 藏死 vs STALL 太急）**trace 傾前者未排除後者**。
- **一次 sweep 便宜決定性分辨**。我本 arc 剛撤回過一次「story 合理就 accept attrition」（game-design:356-364）→ 不重犯。measure-first（[[feedback_avoid_rabbithole]]）：能便宜量的別猜。

## ★決定性判準（給 measurer，非開放式，防鑽牛角尖）
sweep `STALL_DAYS`（+ 視情況 `RELIEF_MIN`），目標值須同時：
1. **seed1337 latch 仍修好**（starve ≤ ~5，改善不回退）；
2. **seed4201 attrition 回落近健康 baseline**（非 10x；容忍小幅升＝proper 窮死露出，但非 28%）。

**分支結局（兩路都讓 ② 帶信心收尾）**：
- **存在此值** → 採用 → 重 measure 三 seed（seed1337 latch + seed42 + seed4201）→ 回我 release-pass（大概率 pass）。
- **不存在**（latch-fix 與 seed4201 attrition 耦合、修一必帶另一）→ 證明 28% 是**修 latch 的內在代價**（teams 本 doomed、latch 在藏）→ **回 (A) accept、proper 窮死、你 merge ②**（此情況我預先 release-pass，不必再繞我一趟）。

## 附
- **team48**（task-priority-preempt 缺口、與本 branch 無關）→ 同意你開 `known_issues` 獨立票，不擋 ②。
- 用戶在 loop：我已把此裁定同步用戶，若其平衡意圖 override 成 (A) 直接 merge 會另發信；未發＝照 (B)。

## 溯源
你 ladder-qa-pass-balance-call handback（QA PASS + seed4201 10x flag）;game-design:356-364（我 attrition-accept 撤回 + 自限vs誤殺判準）;[[feedback_avoid_rabbithole]]（measure 定 calibration）;[[reference_measurement_protocol]]（multi-seed sweep）;STALL_DAYS/RELIEF_MIN TEST VALUE。
