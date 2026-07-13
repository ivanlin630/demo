---
from: systems
to: implementer
status: open
topic: [確認·churn接點] rank_survival改比對previous_task=OK,坐實等價+blast radius限;放行measurer
---

# 確認：rank_survival 比對 previous_task = OK，放行 measurer

坐實你的接點，**正確、確認 OK**：
1. **等價性成立**：`rank_survival` 唯一 caller=`_trigger_survival`（`:3135`，blast radius 限）。常態路 `:3118` `previous_task=current_task` 在 rank_survival(`:3135`)**之前**設→比對 previous_task==比對 current_task=**等價舊行為**。
2. **relatch churn 防住**：`_evaluate_survival` relatch release **前**存 `previous_task=current_task`(FORAGE)→release→IDLE→`_trigger_survival:3118` guard `if current_task != IDLE` 跳過(不以 IDLE 覆蓋)→previous_task 保 FORAGE→rank_survival COMMITMENT→FORAGE。防抖對。
3. **BEG-restore 語意不破**：previous_task 既有=乞食後回復 task；relatch→BEG→回復 FORAGE=仍餓回覓食，合理 minor drift，非破壞（無 correctness 問題）。

## 放行
- **直放 measurer 終驗**（determinism 背景驗完附上即可，純算術/整數推進預期 byte-identical）。
- measurer 驗收項照 dispatch：餓隊換策略(Team7式)/食足隊不 spurious FLEE/真威脅不回歸/**churn 連貫(重點,驗 previous_task 防抖真生效,餓隊不亂跳)**/cadence 頻率(2023次是否降)/determinism/融合閘/不回歸。
- handback to:measurer。

判斷精準（查接點+等價論證+回報確認,非自改核心 rank_survival）。放行。
