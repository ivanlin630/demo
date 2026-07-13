# ⑦ 釋放統一：單一「何時重評」predicate（systems HOW）

> 藍圖裁 B(`skip-2-do-7`)：跳過②(成員洞不存在),直接⑦。四套獨立「何時重評」(survival release/threat release/stuck/timeout)收斂到單一 cadence+crisis 框架。**連帶症狀**:Team6 trace 90天1712次決策過頻(≈19/日不直覺)。

## 過頻真因（坐實）
- **`_decide_unified`(unified+faction 成員走)無 cadence gate**→faction AI 每 `NEAR_CADENCE`(1h,sim_runner:5)呼一次→**每小時重評≈24/日**。
- `_evaluate_solo`(獨立非-unified)已有 cadence gate(:1778,cadence rework 加)→~1/日。
- → 1712/90天=unified/成員每小時重評,**re-eval 時機不統一**(一路 throttle 一路不 throttle)。

## 架構紀律（硬性，藍圖 `architecture-discipline-reinforce`）
「何時重評」收斂=**單一 predicate `_should_reeval`** 驅動所有路,**非** cadence 函式內又長四段 if 換殼。releases 只設**狀態**(釋放 task→IDLE),不各自獨立 force 重評;唯一「該重評?」判斷在 `_should_reeval`。

## 設計

### 1. 單一重評 predicate（共用）
`FactionAISystem` 加：
```gdscript
# ⑦ 統一「何時重評」:所有 rank_scored 入口共用。releases 設 IDLE→此處判;busy 隊 throttle 到 cadence。
# 唯一「該不該重評」判斷點(架構紀律:非各路各判)。
func _should_reeval(state: WorldState, team: TeamData) -> bool:
    if team.current_task == TeamData.TASK_IDLE: return true      # 空閒/剛釋放→即重評
    if _is_stuck(team): return true                              # 卡住→重評
    if _decision_crisis(state, team): return true               # 劇變(食崩/pop驟降)→反射提前
    if _directive_fresh(state, team): return true               # ★R①#1:faction 新命令→即時響應(不等 cadence)
    return state.world.current_tick >= team.decision_eval_next_tick   # 否則 cadence 節流
```

### 1b. ★faction 命令即時響應（補 R①#1 缺口，守協同紅線）
R① 坐實：`_decide_unified` 加 cadence throttle 後,忙碌成員收新 faction 命令(f.goals 改:攻擊/徵收/外交令)最多隔 1 日才響應=破協同。**修:faction 命令變化=重評觸發**(納單一 predicate,非另路)：
- **stamp**：faction 設/改 member-relevant directive 處(f.goals/directive target 變)→`f.directive_change_tick = state.world.current_tick`。implementer 定位 faction goal 設點(strategic_ai/_assign_tasks 意圖設定路)stamp。
- **predicate**：`_directive_fresh(state, team) = team.faction_id != -1 and f.directive_change_tick > team.last_decision_tick`（成員 faction 命令在其上次決策後才變→即重評響應)。
- **`last_decision_tick`**：team 每次通過 `_should_reeval`+跑 rank 時設 = current_tick。
- → 忙碌成員收新命令**下一 tick 即重評**(非等 cadence);無新命令則 cadence throttle(修過頻)。命令響應即時 + 過頻修,兩全。架構紀律保(命令 freshness = 單一 predicate 的一個輸入條件,非獨立重評路)。
- `_evaluate_solo:1778` gate 改用 `_should_reeval`(語意等價,收斂)。
- **`_decide_unified` 開頭加 `_should_reeval` gate**(現無→加):
```gdscript
func _decide_unified(state: WorldState, team: TeamData) -> void:
    if not _should_reeval(state, team):
        return   # ⑦:unified/成員也 throttle(修每小時過頻);IDLE/stuck/crisis 仍即時
    team.decision_eval_next_tick = state.world.current_tick \
        + (DECISION_CADENCE / 4 if _decision_crisis(state, team) else DECISION_CADENCE)
    team.last_decision_tick = state.world.current_tick   # ★命令 freshness 比對基準
    ... (survival-sticky pass + rank_scored 原樣)
```
（`_evaluate_solo` gate 亦設 `last_decision_tick`。team_data 加 `var last_decision_tick: int = 0`。）

### 2. releases 收斂為「設 IDLE」非「各自 force 重評」
四套 release 保**狀態轉換語意**(釋放 sticky task),但不各自獨立驅動重評——release→IDLE→`_should_reeval` IDLE 分支即時接手。crisis 級變化→`_decision_crisis` 統一涵蓋。
- **survival release**(食恢復 hysteresis:3042)：`release(team)`→IDLE→即重評(IDLE 分支)。hysteresis(RECOVER_DAYS)保,release 判斷保留(它是狀態轉換非重評判斷)。
- **threat release**(no-threat:368/FLEE_TIMEOUT:95)：威脅消失/逾時→`release`→IDLE→即重評。**威脅消長納 `_decision_crisis`**(威脅暴增=crisis 提前重評;既有 threat 反射插隊 PRIO_THREAT 保留=刻意例外不動)。
- **stuck**:已在 `_should_reeval`(stuck 分支)。
- → 四套皆「設狀態→單一 predicate 接手」,無各自重評邏輯。

### 3. 保留的刻意例外（架構紀律允許，不動）
- **TaskArbiter 優先權插隊**(PRIO_SURVIVAL/THREAT 反射):快反射,不拖進 cadence(藍圖裁保留)。
- **survival release 的 hysteresis 判斷**:狀態轉換(何時脫 survival),非「何時重評」——保留(它 gate 的是 task 生命週期非決策節流)。
- **LOD**(sim_runner near/far):perf 分層,不動。

## R① premise（factcheck）
1. **`_decide_unified` 加 cadence throttle 不破 unified 行為**?——merchant 貿易 loop/producer/成員 faction_duty 響應:現每小時重評→改 cadence(1日+crisis+IDLE)是否致命令響應變慢(faction 攻擊令下達→成員最多隔 1 日才接?還是命令變化=crisis 即時)。查 faction 命令下達是否該即時(→需納 crisis)或可容 cadence 延遲。
2. **四套 release 收斂「設IDLE→predicate」無損 famine/combat/threat**?——各 release 現況是否已是「release→IDLE」(則收斂零行為變),還是有 release 後直接重派(繞 IDLE)的路。
3. **架構紀律**:收斂後「何時重評」是否真只剩 `_should_reeval` 一處判斷(+允許例外)?有無殘留某路自己判重評。

## 驗收（final 一次性）
- **★重評頻率改善**:Team6 式 trace 90天決策次數從 1712 降到合理(cadence 1/日+crisis+IDLE≈數十-百次,非千次)。
- **架構紀律自查**:「何時重評」判斷點收斂 `_should_reeval` 一處。
- **不回歸**:faction 命令響應/famine(食恢復脫survival)/combat/threat(FLEE逾時)/determinism/融合閘/9-zero。
- 代表隊 trace(故事連貫+頻率合理) + established 狀態 + 改動清單 + 架構紀律自查。

## 風險
- unified cadence throttle→faction 命令響應延遲(#1 premise 關鍵;若命令須即時→納 crisis-trigger)。
- release 若有繞-IDLE 直接重派路→收斂需先導回 IDLE。
- 全 TEST VALUE(DECISION_CADENCE 沿用),measurer 校頻率。
