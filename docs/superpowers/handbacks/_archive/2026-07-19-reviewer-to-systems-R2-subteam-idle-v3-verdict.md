---
from: reviewer
to: systems
status: consumed
topic: "[R² v3 verdict·subteam-idle 連續監看+orphan·CLEAN] 結構修對症:監看=edge-trigger(fire→release→IDLE→survival-gate 停 fire,非 level-spam)收斂;orphan 沿用 discipline_fail 雙向清 proven 路;位置/並存不誤傷。1 measure-verify(recall 收斂:_decide 旅途 re-pick forage 慢震盪?)+ perf note(每tick parent food_days)。"
---

# R² v3 verdict：subteam-idle-latch 連續母團監看 + orphan（結構修）

**VERDICT: CLEAN** — 可 redirect implementer extend 036fc42c。`premise_contradiction: false`。v3 對症補 v2 的 recall 結構洞（只駐點查→旅途盲視）。

factcheck 對 HEAD `c2b5847b`。

## v2 結構洞坐實
v2 `_parent_needs_food` 召回在 `move_target==-1`（駐 forage tile）分支內 → **旅途中 forager 不監看母團** → 母團垂危召不回，forager 已飽卻救不了。measurer seed1337 6→10 = 真結構洞。診斷對。

## R² v3 審點

1. **連續監看不 thrash → CLEAN（edge-trigger 非 level-spam）**。監看 gated `current_task in SURVIVAL_TASKS`。母團垂危 fire → merge_queue → loop2b（非 co-located）`release(sub)` → current_task=**IDLE** + `sub.move_target=parent.tile_pos`（`faction_ai:761-763`）。**release 後 current=IDLE → 監看(survival-gated)次 tick 不再 fire** = 一次性 edge-trigger（非每 tick level-spam）。IDLE forager 朝 parent 持續移動（每次 release 重設 move_target=parent=一致掉頭非位置振盪），cadence `_decide`（非每 tick）續推 → 抵 parent co-located → `try_merge_back` 交糧。**收斂**。
   - **★measure-verify（非 blocker）**：殘留收斂風險=旅途中 `_decide`（cadence）若 re-pick FORAGE（current→FORAGE→監看再 fire→再 recall）可能慢震盪。實務收斂靠：_decide cadence-gated（非每 tick）+ 短程（team73 forage↔parent ~3 tile）+ forager 高食→forage util 低→傾向 歸建。**measurer 驗 recall 是否單向收斂抵 parent，或 _decide 旅途 re-forage 造慢震盪**（若震盪→給監看直接設歸建態而非靠 _decide re-rank；但結構是 edge-trigger 非病態 thrash）。

2. **orphan detach 安全 → CLEAN**。`parent==null → detach_subteam + remove_tag(TAG_SUBTEAM) + release`（沿用 discipline_fail 現成路）。`detach_subteam`→`set_subteam_parent(child,-1)`（`world_state:157-166`）**雙向清**：child.parent_team_id=-1 + 從 parent.subteam_ids erase。→ next loop2 `parent_team_id==-1` → 走正常隊 eval（independent_strategy/solo）→ 獨立覓食/入 faction，不再無限囤糧。proven 路，雙向同步乾淨。

3. **監看位置不誤傷 → CLEAN**。放 `_check_discipline` 後、position-branch 前，gated `current_task in SURVIVAL_TASKS`。ESCORT(`:1723`)/SETTLE(`:1710`)**上段已 return**；BUILD/CONSTRUCT/UPGRADE/EXPAND **不在 SURVIVAL_TASKS** → gate skip。只 survival-work 進監看。（★impl 須確落 `in SURVIVAL_TASKS` gate，pre-merge R² 驗。）

4. **recall vs sated-deliver 並存不衝突 → CLEAN**。監看（in-transit OR on-tile，parent<LOW → merge_queue+return）先於 position-branch（arrived move_target=-1，sated/parent-need → merge）。arrived+parent-low → 監看先 fire 處理；arrived+sated → position-branch 處理；arrived+not-sated+parent-ok → position-branch return 留 tile。**單一 append（各路 return），無雙 merge_queue、無衝突**。

5. **無新 RNG/違憲 → CLEAN**。監看=parent lookup + `_survival_food_days(parent)` 純讀，零 RNG。orphan detach 沿用既有單寫者路。
   - **perf note**：監看每 tick per foraging-subteam 算 `_survival_food_days(parent)`（effective_food/pop）。若 forager 多 + effective_food 走 granary tile → 每 tick 累積成本。spec 已備「量出 spike 再 cadence-gate」——measurer 順帶看 phase timing，有 spike 則 cadence-gate（垂危 recall 容 SUBTEAM_CADENCE 延遲，不需每 tick）。

## 承 v2 must-pass（續有效）
seed42 famine 回 0 + 囤糧消 + 無 re-thrash + **seed1337 6→10 回落**（v3 治的 recall 洞）。measurer 綠才算治本。

## 回覆
CLEAN → redirect implementer extend 036fc42c（連續監看 gated SURVIVAL_TASKS + orphan detach + 保 v2 sated-merge）。impl pre-merge R² 重點：①監看真 gated SURVIVAL_TASKS（不誤傷）②orphan detach 雙向清 ③recall 收斂（measurer trace 抵 parent 非震盪）④seed1337/42 famine 雙回 0。
