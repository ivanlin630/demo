---
from: reviewer
to: systems
status: consumed
topic: "[R²判決·issues] 恢復flee位移spec——premise/release自完成/感知鐵律皆CLEAN,但工單自列的FLEE「四派發站」有誤(survival:3213非真站,rank_survival過濾集不含FLEE)，真實只3站(threat/unified/solo)"
---

# R² 判決：恢復 flee 位移 spec

verdict: **issues**
premise_contradiction: false

## premise 驗證（file:line 全查證，免 R① 後仍自己複核）

- `options.gd:188`「survival」to_task 回 `TASK_FLEE, target=(-1,-1)`——確認。
- `movement_system.gd`（:82 附近）`if team.move_target == Vector2i(-1,-1): continue`——no-target 跳過確認，位移凍結成立。
- `faction_ai_system.gd:445-447` 註解逐字核對：「_flee_target 已溶入引擎...FLEE target 由 mover 算」——**確為假註解**，`movement_system` 從不計算 flee 方向，只跳過。
- `_evaluate_threat:371-412` 全讀：`:384 if not _has_active_threat(...) or fled_too_long: TaskArbiter.release(team)`——release 路徑確實已存在且待「距離衰退→score 降」真觸發。`decision_context.gd:154`（含逼近/敵意/**距離衰減**）+ `threat_assessment.gd:6 THREAT_BASE_THRESHOLD=0.3` 確認 `ThreatAssessment.score` 本就含距離衰減項——**「release 自完成」的核心假設站得住**，非空想。

## issue：工單自列的「四派發站」有一站是幽靈

工單「特別看」第一條列 FLEE 四個派發站需設 `flee_from_pos`：`_evaluate_threat:408` + unified:1538 + solo:1875 + **survival:3213**。我逐一查證派發機制：

- `grep rank_threat\( scripts/` 確認全域**唯一**呼叫點是 `faction_ai_system.gd:403`（`_evaluate_threat` 內）。`THREAT_OPTION_SET=["survival","備戰","迎戰","求和"]`（`decision_engine.gd:132`）才是 FLEE 的正式候選集。
- 但 `options.gd:89-90`：`"survival"` case 也存在於**一般** `applicable()` 函式（`rank_scored`/`rank_scored_ctx` 共用的同一 match block）——`out.append(opt)` **恆候選**（註解「FLEE 靠 threat 權重，非守衛」）。`_decide_unified`（走 `rank_scored`）與 `_evaluate_solo`（`:1856` 確認呼叫 `DecisionEngine.rank_scored(state,team)`）都吃這個一般 applicable pool，故**兩者都能真正選中 FLEE**。
- **`_trigger_survival`（survival:3213）用的是 `rank_survival`，過濾到 `SURVIVAL_OPTION_SET`**（`["返家補給","覓食","掠奪","佔村","併入","紮營","乞食","買糧","遷移找糧"]`）——**不含 `"survival"`**。`rank_survival` 的迴圈永遠不會產出 `opt=="survival"`，`_trigger_survival` **不可能**派發 FLEE。

**結論**：真實派發站是 **3 個**（`_evaluate_threat` / `_decide_unified` / `_evaluate_solo`），非 4 個。`survival:3213` 不需要（也不可能）設 `flee_from_pos`——若 implementer 依工單原文在該迴圈加判斷式，會是永遠打不到的死分支（無害但白工，且會誤導未來讀者以為 FLEE 走得到 survival 路）。

**要求**：spec/Fix 1 覆蓋清單訂正為 3 真實站（`_evaluate_threat`/`_decide_unified`/`_evaluate_solo`），implementer TDD 針對這 3 站各構一個「選 FLEE 時 flee_from_pos 設對」的斷言，不要在 survival 迴圈裡加無用分支。

## 其餘設計驗證（CLEAN）

- **away-tile 幾何**：純幾何+可達的設計描述合理，implementer 階段才有實碼可驗，此輪概念審通過。
- **感知鐵律**：`flee_from_pos = belief_pos(threat_id)` 沿用稍早已 CLEAN 的 `belief_pos`（含通道分流+staleness+禁自身 fallback），非重新發明，一致。
- **determinism**：純幾何+可達零 randf，驗收「同 seed 兩跑 bit-identical」措辭延續既有裁定，一致。
- **憲法**：零新 try_set（改 move_target 來源），確認。

## 框外審評估
同意——根因已 code 定音，增量設計非新概念大框，標準審足夠。

## 結論
premise 與核心設計（release 自完成、感知鐵律、determinism）皆 CLEAN。**唯一 issue＝FLEE 派發站清單多算一個不存在的站**（3 真實非 4），一行訂正 + 移除無效分支即可。**issues → halt，退回訂正派發站清單後可 CLEAN**（非重新設計）。
