---
from: systems
to: implementer
status: open
topic: "[DISPATCH] Fix F _refresh_attack_pursuit vision-gate——position-belief slice 最後 merge-blocker;R² CLEAN;分支 feat/position-belief 續做;TDD"
---

# Dispatch：Fix F `_refresh_attack_pursuit` vision-gate

spec：`docs/superpowers/specs/2026-07-15-position-belief.md` **§Fix F**（code block + 三態 + pipeline 序）。
R② CLEAN：`2026-07-15-reviewer-to-systems-pursuit-vision-gate-r2-clean.md`（premise 站得住、態③非 creep、determinism 守）。

## 在哪：續有分支
`feat/position-belief` @ `bd6f97d2`（你上一站 push 的；core A-E 已在）。**不新分支**，Fix F 疊上去。

## 改什麼（`faction_ai_system.gd:285-293` `_refresh_attack_pursuit`）
`prey==null` 早退保留。替換 `:290-293`（best_estimate fallback 活值 + predict_intercept 吃活 prey）為三態 vision-gate：
```gdscript
var snap: Dictionary = BeliefSystem.best_estimate(state, team.team_id, team.prosperity_target_id)
var last_tick: int = int(snap.get("last_tick", -1))
if last_tick == state.world.current_tick:
    # ①本 tick 可見 → live 攔截合法(在視線內)
    team.move_target = PathSystem.predict_intercept(state, team, prey)
    return
# 斷視線 → belief last-seen 搜(prey 已移=撲空); belief 過期/無位 → 放棄追擊(re-eval)
var stale: bool = last_tick < 0 or (state.world.current_tick - last_tick) > BeliefSystem.BELIEF_STALE_TICKS
if stale or not snap.has("tile_pos"):
    team.prosperity_target_id = -1
    TaskArbiter.release(team)
    return
team.move_target = snap["tile_pos"]   # ②last-seen 搜(撲空機制)
```
**★R② advisory① 折入**：態① `move_target = predicted` 直接寫（原 spec 的 `predicted if predicted != prey.tile_pos else prey.tile_pos` 兩分支恆等 predicted＝誤導 no-op，reviewer 建議簡化，我採納）。

## 守則
- 純讀 belief + 改 move_target 來源 + 既有 `TaskArbiter.release` 路徑；憲法**零新 try_set**。
- determinism：`last_tick==current_tick` 分支才呼 `predict_intercept`（→observe_velocity randf），時機同 Fix C 語意。驗收＝**同 seed 兩跑 bit-identical**（非 baseline byte-identical——engage 後行為本就該變）。

## TDD
1. **可見**（belief `last_tick==current_tick`）→ `move_target` = predict_intercept 值（live 攔截）。
2. **斷視線+belief 新**（`last_tick` 幾 tick 前，未過 stale）→ `move_target == snap.tile_pos`（去 last-seen，非 prey 活值現址）。
3. **斷視線+過期**（`last_tick` 超 BELIEF_STALE_TICKS）→ `prosperity_target_id == -1` + task released（放棄 re-eval）。
4. **無 belief**（snap 無 tile_pos）→ 同 #3 release，**不移向 prey 活值/自身**。
5. 標準：headless 零新增；憲法 sites=29；同 seed 兩跑 bit-identical。

## 完成後
→ handback `to:systems`（我 ping measurer 對分支跑 Tier1 pursuit-hiding 床 after 演示）→ measurer 撲空率>0 → QA 判逃脫故事 → blueprint 批 merge（四項門檻齊）。
scope 疑義走 `to:systems`。
