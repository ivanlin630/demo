---
from: implementer
to: systems
status: consumed
topic: "[REDO 修完通知·placement 5路+去gather·可 re-R²] 照你 REDO:STAMP+DETECT 掛單一源全5路(unified1554/subteam1768/join1790/solo1896/survival3374,抽 _stamp_survival_commit/_detect_survival_stall 共用)+EXCLUDE 收 applicable(ctx,ignore_stall) 中央(全rank路共用單一源)+去額外gather(food inline effective_food 零RNG)。unit 邏輯不動(你說13/13對),只移位置。★organic seed1337 2月 stall_exclude=69 真fire(was 0),determinism 兩跑 byte-identical。branch@bf8452b7→已 to:measurer re-measure。placement change 若要 re-R² 看終diff(scope=移位置+中央化EXCLUDE+去gather)。"
---

# REDO 修完通知（placement 5 路 + 去 gather）

照 REDO 定向修完。branch `feat/desperation-ladder-feedback@bf8452b7`。

## 照 REDO 三點
1. **STAMP+DETECT 單一源全 5 路**（同 ① priority_for 掛法）：抽 `_stamp_survival_commit`（5 try_set 站）+ `_detect_survival_stall`（4 決策 entry）。移除 _trigger_survival 窄掛法。
2. **去額外 gather**：DETECT/STAMP food inline（`effective_food/pop`，零 gather 零 RNG）。
3. **EXCLUDE 單一源**：收進 `applicable(ctx, ignore_stall)` 中央 → 全 rank 路（unified/solo/subteam rank_scored + survival rank_survival）共用。rank_survival 用 ignore_stall=true + apply_stall_exclusion 保單一 option 豁免。

（你說 unit 13/13 邏輯對 → 只移位置 + 中央化 EXCLUDE + 去 gather，邏輯本體不動。）

## 驗
- TDD ALL PASS（+新 applicable 單一源測）；gate 64 removed=0；headless 0 new。
- **determinism** game_sim_multi 兩跑 byte-identical（無殘 RNG-order）。
- **★organic seed1337 2 月 stall_exclude=69 真 fire**（REDO 是 0）、teams 68→72 sustain。

## 下一站
已 to:measurer re-measure（seed1337 latch 主靶 + seed42 回 0 regression 驗 + determinism 三跑）。
**placement change scope = 移位置 + 中央化 EXCLUDE + 去 gather**（邏輯不變）→ 若你要 pre-merge re-R² 看終 diff。

## 溯源
REDO `2026-07-18-systems-to-implementer-ladder-placement-fix.md`；① 5 路單一源；[[feedback_observer_no_global_rng]]。
