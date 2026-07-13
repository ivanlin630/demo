# 重評 cadence 重構（9-zero 真上游根）— systems HOW

> 藍圖裁 pivot B(`cadence-pivot-decision-B`)：9-zero 真根=非-unified 隊「選一次鎖到底」（Team7 覓食 90 天 1 次決策）。term-scale/T1-T5=決策當下公平（merged,必要配套），此 slice 解「決策幾乎不發生」的上游根。

## premise（R① factcheck 對象，已 code 坐實）
- `uses_unified`(faction_ai:1438)= 只 TAG_MERCHANT/TAG_PRODUCE；其餘（多數）非-unified。
- `_evaluate_solo`(每 LOD-cadence 呼) IDLE-gate(1764)：`if current_task != IDLE and not _is_stuck: return`。
- `_is_stuck`(88)= task∈STUCK_TASKS[攻擊,掠奪] 且 move 空（窄）。
- → FORAGE/生產/駐守/建設/紮營(∉STUCK,不自然完成) → 永不回 IDLE → 永不重評。
- `_decide_unified`(1442) 無 IDLE-gate（已頻繁重評=收斂目標）。faction 成員(684-696)不呼 _evaluate_solo（債縫#3）。

## 觸發模型（藍圖框，HOW 落地）
`util = weight × eval × coeff` 只在 rank_scored 被呼時作用 → 重評必須夠頻繁才讓五層急迫度/coeff/威脅整合發揮。三閘 OR 觸發，取代 completion-gated 永久鎖：
1. **週期重評 baseline**：新 `DECISION_CADENCE`（TEST VALUE 1 日,鏡射 THREAT/INTENT_CADENCE）+ per-team `decision_eval_next_tick`。cadence 到→重評（收斂 unified「頻繁重評」，非「完成才重評」）。
2. **IDLE 立即**（既有語意保）：current_task==IDLE→立即重評（不等 cadence）。
3. **重大變化事件提前**：`_decision_crisis` 複用 S3 crash-bypass 判準（pop 驟降 RUNG_CRASH_POP_DROP_PCT / food_flow 深負 RUNG_CRASH_FOOD_DEEP / 威脅暴增 threat 跨門檻 / rung 變）→ 強制本 tick 重評（反射,不等下週期）。
4. **COMMITMENT_BONUS 防抖**（既有 rank_scored_ctx，不動）：週期重評不亂跳（同 option 加分承諾）。**不疊 IDLE-gate 二次鎖**。

## Task 拆分

### T-cad1：非-unified 週期重評（核心，解 Team7 鎖）
- `team_data.gd`：加 `var decision_eval_next_tick: int = 0`。
- `faction_ai_system.gd`：加 `const DECISION_CADENCE: int = TimeScale.TICK_PER_DAY * 1`（TEST VALUE）。
- `_evaluate_solo:1764` gate 改寫（取代 IDLE-lock）：
```gdscript
	# 重評 cadence 重構：週期 + IDLE 立即 + 事件提前（取代 completion-gated 永久鎖）。
	var _due: bool = state.world.current_tick >= team.decision_eval_next_tick
	var _idle: bool = team.current_task == TeamData.TASK_IDLE
	if not (_idle or _is_stuck(team) or _due):
		return
	team.decision_eval_next_tick = state.world.current_tick + DECISION_CADENCE
```
（事件提前 T-cad2 補入 `_crisis` 條件。）
- **survival-sticky 保**：週期重評時，survival 態(food 低)→survival_pressure 高→rank 自然續選 survival option（COMMITMENT_BONUS 疊）→不打斷覓食/逃。**但驗**：週期重評不致 survival latch 被非-survival option 搶（TC2/survival-dominance 不回歸）。
- TDD `_test_decision_cadence`：非-unified 隊 current_task=FORAGE(非IDLE非stuck)、cadence 到 → _evaluate_solo 重跑 rank（decision_eval_next_tick 前後推進；mock 一支隊驗 rank 被呼）。

### T-cad2：事件提前觸發（複用 crash-bypass）
- `_decision_crisis(state, team) -> bool`：複用 `AmbitionLadder.RUNG_CRASH_POP_DROP_PCT`/`RUNG_CRASH_FOOD_DEEP` + 威脅（threat_react 跨 threshold）。任一劇變→true。
- T-cad1 gate 加 `or _decision_crisis(state, team)`；crisis 時推**短 cadence**（R② 精修：`decision_eval_next_tick = current_tick + DECISION_CADENCE/4`,TEST VALUE）——遠比平常頻繁的反射,但避免每 tick 無界重評 churn/perf 爆。
- TDD `_test_decision_crisis_bypass`：pop 驟降 30% 隊 → crisis=true → 不等 cadence 立即重評。

### T-cad3：框架債縫#3——faction 成員重評路（★R② 裁拆獨立後續 slice，不在本輪 dispatch）
> R②(`cadence-rework-r2-verdict`)：成員進主 rank=新增寫入路徑與 `_assign_tasks` 雙寫 current_task，與 T-cad1/2「調頻率」不同風險類別,混同輪難歸因 regression。**拆獨立 slice,T-cad1/2 先行獨立 organic 驗後再開。** 以下設計保留待後續 slice：
- 成員(faction_id!=-1,非子隊)現只 `_evaluate_independent_strategy`(684-696)，無個人日常重評。
- **風險**：成員日常 task 由 `_assign_tasks`(faction 派工)管，加 _evaluate_solo 路徑恐與派工互搏（688 註警「避大面積互搏」）。
- **設計**：成員也走同 DECISION_CADENCE 重評**個人 option**，但**faction_duty term 已在 rank**（服從母團命令 option 高 util）→ 忠誠成員 rank 自然選 duty option、不忠選個人。**非另開路徑，是讓成員也進主 rank**（收斂 unified/solo/member 三路一 rank）。
- **但**：此改動面大（成員從無重評→有），須**獨立 organic 驗**（faction 協同不散、服從不回歸）。若 R②/measurer 判風險過高 → T-cad3 拆出後續 slice，T-cad1/2 先解主根。

### T-cad4：unified 路收斂（可選，低優先）
- `_decide_unified` 現每 LOD-tick 重評（無 cadence throttle）→ 加 DECISION_CADENCE throttle 收斂同節奏（perf + 一致）。**但 unified 行為已驗**→改動需確認不回歸。低優先，可 defer。

## 驗收（measurer 終驗）
- **★Team7 類案重跑**：撈同款單隊 3mo trace → 重評次數從 ~1 → 多次（每 DECISION_CADENCE + crisis）。**這是主驗收**（重評頻率真升）。
- **9-zero 真改善**：per-option chosen——備戰(威脅出現時重評→可選)/駐守/訓練 等跨 seed 是否終於非零（現在有重評時機了，配 T1-T5 公平比較）。
- **無 churn**：同隊不每 cadence 亂跳（COMMITMENT_BONUS 防抖生效）——單隊 trace 看連貫非鋸齒。
- **survival-sticky/faction 協同不回歸**：TC2、consolidation、combat、established organic 不劣化。
- **perf**：週期重評 O(23×term) × 隊 × cadence，headless per-tick 不爆（GODOT_TIMEOUT 監控）。
- **determinism** byte-identical。

## 風險（R②）
- churn（週期重評亂跳）——COMMITMENT_BONUS 是否夠防；抖則調 BONUS/cadence。
- survival latch 被搶——週期重評打斷絕境覓食？（survival_pressure 高應保）。
- T-cad3 成員互搏——faction 派工 vs 個人 rank 雙寫（獨立驗，必要時拆 slice）。
- perf——重評頻率×隊數。
- 全 TEST VALUE（DECISION_CADENCE/crisis 門檻），measurer 校。
