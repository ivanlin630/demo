---
from: systems
to: implementer
status: consumed
topic: [dispatch·cadence] T-cad1週期重評+T-cad2 crisis提前——R②CLEAN(T-cad3拆後續);解Team7鎖死主根
---

# Dispatch：重評 cadence 重構 T-cad1 + T-cad2（解 9-zero 上游根）

R①premise CLEAN + R②CLEAN(T-cad1/2；T-cad3 拆後續 slice、T-cad4 defer)。spec `docs/superpowers/specs/2026-07-13-reeval-cadence-rework.md`。**新 worktree/branch**（`feat/reeval-cadence`，基於最新 origin/main=含 T5 merged）。

## 背景（真根）
非-unified 隊 `_evaluate_solo:1764` IDLE-lock → 選長任務(覓食/生產/駐守)永不回 IDLE→永不重評（Team7 覓食 90 天 1 決策）。→ coeff/term 分數幾乎用不到=9-zero 上游根。拿掉過強 IDLE-lock,改週期+IDLE+crisis 三閘。

## T-cad1：非-unified 週期重評
- `team_data.gd`：加 `var decision_eval_next_tick: int = 0`。
- `faction_ai_system.gd`：加 `const DECISION_CADENCE: int = TimeScale.TICK_PER_DAY * 1`（TEST VALUE）。
- `_evaluate_solo:1764` gate 改寫（取代 `if current_task != IDLE and not _is_stuck: return`）：
```gdscript
	# 重評 cadence 重構：週期 + IDLE 立即 + 事件提前（取代 completion-gated 永久鎖）。
	var _due: bool = state.world.current_tick >= team.decision_eval_next_tick
	if not (team.current_task == TeamData.TASK_IDLE or _is_stuck(team) or _due \
			or _decision_crisis(state, team)):
		return
	if _decision_crisis(state, team):
		team.decision_eval_next_tick = state.world.current_tick + DECISION_CADENCE / 4   # crisis 短 cadence(反射)
	else:
		team.decision_eval_next_tick = state.world.current_tick + DECISION_CADENCE
```
- TDD `_test_decision_cadence`：非-unified 隊 current_task=FORAGE(非IDLE非stuck)、`decision_eval_next_tick` 過期 → gate 放行重評；未過期+非crisis → 擋（cadence throttle 生效,非每 tick）。

## T-cad2：crisis 事件提前（複用 crash-bypass）
- `faction_ai_system.gd`：加 `_decision_crisis(state, team) -> bool`：複用 `AmbitionLadder.RUNG_CRASH_POP_DROP_PCT`(pop 驟降)/`RUNG_CRASH_FOOD_DEEP`(food_flow 深負) + 威脅(`threat_react >= threat_threshold`,用既有 ctx 或局部算)。任一劇變→true。純讀零 randf。
  - 注意 pop 驟降需上期 pop 基準——複用 `team.rung_pop_last`(S3 已有)或加短欄;food_flow 讀 `team.food_flow_avg`;威脅算需 gather 或局部（避免每 tick 全 gather perf——crisis 判儘量用 team 已存欄,threat 若需 gather 則接受該成本或用快取）。
- TDD `_test_decision_crisis_bypass`：pop 較 rung_pop_last 驟降 >30% 隊 → `_decision_crisis`=true。

## 硬約束
- **churn 防**：COMMITMENT_BONUS(既有 rank_scored_ctx)防抖,**不疊回 IDLE-gate**。
- **survival-latch 保**：週期重評時餓隊 survival option(覓食,coeff 高+COMMITMENT)自我強化續選——TDD/organic 驗不被無關 option 搶。
- **determinism**：decision_eval_next_tick 整數推進、crisis 純讀,零 randf。逐 task commit。
- **不做** T-cad3(成員,拆後續)/T-cad4(unified,defer)。

## 回報 → measurer 終驗（主驗收=重評頻率）
T-cad1/2 完 + 融合閘綠 → handback to:measurer：
- **★Team7 類案重跑**（單隊 3mo SpecimenTracer trace）：重評次數 ~1 → 多次（每 cadence + crisis）。**主驗收**。
- **9-zero 真改善**：per-option chosen——備戰/駐守/訓練 等跨 seed 是否終於非零（有重評時機了 + T1-T5 公平比較）。
- **無 churn**：單隊 trace 連貫非鋸齒（COMMITMENT 防抖）。
- **不回歸**：TC2/survival-dominance/consolidation/combat/established organic + determinism + 融合閘。
- **perf**：headless per-tick 計時（週期重評×隊數,GODOT_TIMEOUT 監控）。
有 blocker(churn/latch/perf 過險)→to:systems，別自改。守：不 pre-tune、不問 user。
