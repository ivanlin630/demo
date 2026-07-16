---
from: systems
to: implementer
status: consumed
topic: [dispatch·survival-path] latch重選(release-then-retrigger)+FLEE威脅gate——R②CLEAN;解餓隊鎖死+食足隊spurious FLEE餓死
---

# Dispatch：survival-path 解鎖（latch 重選 + FLEE 威脅 gate）

R②終審 CLEAN(`survival-path-r2-fix-verdict`)。spec `docs/superpowers/specs/2026-07-13-survival-path-unlock.md`。**新 branch `feat/survival-path`，基於最新 origin/main**（含 cadence T-cad1/2 merged）。

## ① survival-latch 重選（`faction_ai_system.gd _evaluate_survival:3023-3028`）
已餓+cadence 到→**release-then-retrigger**（spec 有完整 code）：
- `days_left >= SURVIVAL_RECOVER_DAYS and not proactive_camp` → release+return（既有,不動）。
- **新**：`not proactive_camp and days_left < WARNING_DAYS and (cadence 到 or _decision_crisis)` → 推 next_tick + `TaskArbiter.release(team)` + `_trigger_survival(state, team, severity)`。
- **★release 必須（R② 坐實）**：try_set 同-prio(PRIO_SURVIVAL vs PRIO_SURVIVAL)確定 no-op（task_arbiter:42 嚴格>、:57 例外只服務 PRIO_DISPATCH）→必先 release→IDLE 才能 _trigger_survival 重派。
- 複用既有 `decision_eval_next_tick`/`_decision_crisis`/`DECISION_CADENCE`（cadence slice 已加）。
- **churn 驗（R② 提）**：release 後 current_task=IDLE 可能破 `rank_survival` COMMITMENT 防抖基準→餓隊每 cadence 亂跳(覓食/買糧/掠奪/併入)。**build 時查 `rank_survival`(decision_engine.gd) COMMITMENT 比對基準**——若比對 current_task 而 release 已清成 IDLE→防抖失效。修法：重選前存 `previous_task` 供比對,或 rank_survival 用 `solo_task_last` 比對。查完回報接點怎接。
- TDD `_test_survival_relatch_repick`：餓隊 FORAGE + food 持續低 + cadence 到 → release+_trigger_survival 重跑,task 可換(非鎖死 FORAGE)。

## ② FLEE 威脅 gate（`terms.gd threat_pressure`，撤 T1 0.6 floor）
```gdscript
"threat_pressure":
    if ctx.threat <= 0.0:
        return 0.0
    return clampf(ctx.threat + ctx.team_panic * 0.4, 0.0, 1.0)
```
- 無威脅(threat=0)→FLEE eval=0（食足隊不 spurious FLEE）；panic 僅威脅時計（斷螺旋）。
- TDD `_test_flee_threat_gate`：threat=0→eval=0(不管 panic)；threat=0.8→eval≈0.8+panic。

## ③ stress decay → known_issues（記錄，不修）
`docs/known_issues.md` 記：person-system 成員 stress「累積不釋放」(驅 team_panic)=death spiral 根層,跨 reaction/morale;本 slice #2 決策層斷 FLEE 螺旋,stress 累積待 person 情緒系統獨立 arc。

## 硬約束
- 零 randf、逐項 commit、determinism。
- ① release-then-retrigger（非省略 release）;② threat=0 短路。
- **churn 接點查完回報**（不自定 COMMITMENT 基準改法,若需改 rank_survival 回 systems 確認）。

## 回報 → measurer 終驗
①②完 + churn 接點處理 + 融合閘綠 → handback to:measurer：
- **★餓隊換策略**(Team7 式)：forage 失效 → 重選換買糧/掠奪/併入（單隊 trace survival option 有變）。
- **★食足隊不 spurious FLEE**：食足無威脅隊 FLEE 選中率~0、不再餓死。
- **真威脅不回歸**：真威脅隊仍 FLEE/threat 反應。
- **churn**：餓隊重選不每 cadence 亂跳（連貫）。
- **① cadence 頻率**：螺旋斷後 2023次/90天是否降。
- determinism/融合閘/TC2/consolidation/combat/established 不回歸。
有 blocker(churn 破/互擾/回歸)→to:systems。守：不 pre-tune、不問 user。
