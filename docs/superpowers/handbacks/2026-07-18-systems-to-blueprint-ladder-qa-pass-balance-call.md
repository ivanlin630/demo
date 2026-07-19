---
from: systems
to: blueprint
status: consumed
topic: "[② ladder QA PASS·但 seed4201 健康→10x attrition=你的平衡裁+我建議 calibration sweep] QA 故事稽核 PASS:seed4201 3死隊(team16/19/52)逐一排除5 option(覓食→買糧→掠奪→返家→遷移全cooldown)才落fallback死=絕境階梯完整跑過才死=你願景錨『用盡才准死』正面示範,死時food_days=0已確死非誤殺。latch主靶seed1337 8→5改善。★但QA flag給你(WHAT/平衡非QA判權):seed4201從『從未死健康control』→10x attrition,即使每案故事合理,這淨波動合平衡意圖否=你過目。我HOW觀點:logic對(無mis-fire)但calibration可疑——10x健康seed+QA說『每隊第一次fire有11-42天緩衝無法100%排除premature』=STALL_DAYS/RELIEF_MIN可能太急。建議merge前measurer sweep STALL_DAYS找『修seed1337 latch又不10x seed4201』的值(de-risk,便宜)。你裁:(A)accept釋出(死是proper窮死,latch本在藏這些死)/(B)先calibration sweep。team48=既有task-priority-preempt缺口與本branch無關→我開known_issues獨立票。"
---

# ② ladder QA PASS + seed4201 平衡裁（你的球）

## QA 故事稽核 = PASS（機制對，非 mis-fire）
QA 獨立讀 seed4201 raw trace（team16 完整 300 快照）：
- **3 死隊（team16/19/52）逐一排除 5 個 option**（覓食→買糧→掠奪→返家補給→遷移找糧全 cooldown）**才落 fallback 死** = **絕境階梯完整跑過才死** = 你願景錨「絕境階梯用盡才准死」的**正面示範**，非 bug。
- 死時 food_days=0.00（排除當下已確死）→ 排除不是死因，teams 本已 doomed。
- **latch 主靶 seed1337：8→5 starve 改善**（latch 真的解了）。team93 乾淨窮死。
- QA 判**非 mis-fire**（換格非明顯更差、非緊急斷）。**.qa.json PASS。**

## ★你的球（WHAT/平衡，QA 明確讓給你）
QA flag：seed4201 從「**從未死的健康 control**」→「**10x attrition（2.9%→28.2%）**」。**即使每個案故事合理，這 seed 層級大幅波動是否合你的平衡意圖 = 你過目，非 QA 判權。**

## 我的 HOW 觀點（供你裁）
- **logic 對**（QA 坐实無 mis-fire：沒誤排除正起作用的 option）。
- **但 calibration 可疑**：10x 健康 seed + QA 唯一殘留「**每隊第一次 fire 有 11-42 天緩衝，無法 100% 排除 premature**」→ **STALL_DAYS/RELIEF_MIN 可能太急**（第一次排除得太早，累積把 marginal 隊推向階梯底）。
- **一種解讀**：seed4201 的 latch 本來在**藏**這些死（teams 卡一格苟延），② 讓它們 proper 窮死=更誠實但更多死。**另一解讀**：STALL 太急把本可多撐的隊提早推死。QA trace 傾前者但沒 100% 排除後者。

## 裁定選項（你 release-pass 權）
- **(A) accept 釋出**：死是 proper 窮死（階梯用盡），latch 本在藏這些死，接受更誠實的 attrition → 我 merge ②。
- **(B) 先 calibration sweep**（我建議）：merge 前 measurer sweep `STALL_DAYS`（+ 可能 RELIEF_MIN）找「**修 seed1337 latch 又不 10x seed4201**」的值——de-risk premature 第一次 fire，便宜（一次參數 sweep）。找到 → 重 measure 三 seed → 你再判。
- **我傾 (B)**：10x 健康 seed 即使故事合理，也值一次便宜 sweep 確認不是 STALL 太急；但你若判「proper 窮死＞假 latch-苟延」符合平衡意圖，(A) 也站得住。**你的平衡意圖權。**

## 附
- **team48** = 另一個既有 task-priority-preempt 缺口，**與本 branch 無關**（QA 抓）→ 我開 `known_issues` 獨立票，不擋 ②。

## 溯源
QA bb1e75ff 故事稽核 PASS + 平衡 flag（seed4201 10x）;measurer 混合結果;stall calibration（STALL_DAYS/RELIEF_MIN TEST VALUE）;[[reference_measurement_protocol]] multi-seed sweep;[[feedback_avoid_rabbithole]]（measure 定 calibration 非猜）。
