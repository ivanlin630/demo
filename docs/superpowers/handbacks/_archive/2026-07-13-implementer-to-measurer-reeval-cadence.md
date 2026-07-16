---
from: implementer
to: measurer
status: consumed
topic: 重評 cadence 重構 T-cad1/2 交付 — 解IDLE-lock(9-zero上游根);branch feat/reeval-cadence已push,待Team7重評頻率主驗
---
# Hand Back: 重評 cadence 重構 T-cad1 + T-cad2

branch `feat/reeval-cadence`（已 push，疊 origin/main 含 T5）。spec `docs/superpowers/specs/2026-07-13-reeval-cadence-rework.md`。**解 9-zero 上游根**：非-unified 隊 IDLE-lock → 選長任務永不重評（Team7 覓食 90 天 1 決策）→ coeff/term 分數用不到。

## 實作摘要
- **T-cad1 週期重評**：`team_data.gd` +`decision_eval_next_tick`；`faction_ai` +`DECISION_CADENCE=TimeScale.TICK_PER_DAY×1`；`_evaluate_solo:1764` gate 改寫——舊 `current_task!=IDLE && !stuck → return`（永久 lock）改成 **週期(due) + IDLE 立即 + stuck + crisis 四閘**放行；排下次 cadence（crisis 短 cadence `/4` 反射）。
- **T-cad2 crisis 提前**：`_decision_crisis(state, team)` = pop 驟降（`rung_pop_last` vs pop，複用 S3 `RUNG_CRASH_POP_DROP_PCT`）/ food_flow 深負（`RUNG_CRASH_FOOD_DEEP`）。**純讀 team 已存欄，零 randf、零 gather**（避每 tick 全 gather perf）；威脅由既有 `threat_eval` cadence 路徑覆蓋，不在此重算。
- TDD：`_test_decision_cadence`（未過期非crisis→擋不重評 / 過期→放行+排 cadence）+ `_test_decision_crisis_bypass`（pop/food/穩態）PASS。

## 我方自驗（融合閘綠）
- headless **0 新增 SCRIPT ERROR**（3 pre-existing 同 baseline）；cadence/crisis test PASS。
- **constitution PASS**（sites=29）；**multi sanity 0 SCRIPT ERROR**（308s 完成，無崩潰）；**determinism byte-identical**（1337×1mo cmp；decision_eval_next_tick 整數推進、crisis 純讀）。

## 待驗收（工單，★主驗收=重評頻率）
1. **★Team7 類案重跑**（單隊 3mo SpecimenTracer trace）：重評次數 ~1 → 多次（每 cadence + crisis）。**主驗收**。
2. **9-zero 真改善**：per-option chosen——備戰/駐守/訓練等跨 seed 是否終於非零（有重評時機 + T1-T5 公平比較）。用 per-option/diag probe（`feat/peroption-probe` branch）。
3. **無 churn**：單隊 trace 連貫非鋸齒（COMMITMENT_BONUS 防抖）。
4. **不回歸**：TC2/survival-dominance/consolidation/combat/established organic + determinism + 融合閘。
5. **★perf**：headless per-tick 計時（週期重評 × 隊數，GODOT_TIMEOUT 監控）。multi 308s 完成（4 config full sim）；我未有 baseline 對比 → **請量 per-tick 是否 ≤ 原級**（cadence 每日重評增 compute，crisis 純讀 team 欄已極省）。

## 連動風險 / 註
- IDLE-lock 移除 → 非-unified 隊每 cadence 重評 = 行為改動（決策頻率↑），**baseline 位移非 regression**。churn 靠 COMMITMENT_BONUS 防（不疊回 IDLE-gate）。
- **威脅 crisis 未納 _decision_crisis**（避每 tick gather perf）→ 由既有 threat_eval cadence 覆蓋。organic 若見威脅隊反應遲滯 → 回報 systems（加威脅 crisis 或快取）。
- 序：T-cad3(成員)/T-cad4(unified) defer（本 slice 不做）。9-zero 若 T-cad1/2 後仍殘 → 承接 T1-T5 的 3 organic 觀察項帶數據裁。
