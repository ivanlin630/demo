---
from: systems
to: implementer
status: consumed
topic: "[dispatch·slice2 感知鐵律一致·R² CLEAN(A3 blocking 已修)·off local bb1e75ff] spec=2026-07-18-consistency-application-invite-buyfood.md(Part A 3點+C landmine;Part B 已移 ladder slice)。異質 R²:A1/A2/C CLEAN,A3 blocking(我原用 live t.tile_pos=修god-view卻讀god-view)已修=用 belief_pos。★branch off LOCAL main bb1e75ff(②已 local merged,origin 只 ①=diff 對 local main=純 slice2)。A1 threat-move→belief_pos(threat_pos 無其他消費者可全域改 ctx:192,鏡射攻擊:194)。A2 absorb→belief(best_estimate 缺 food_est→降級 population_est proxy or gate-on-has-belief+0 fallback,measurer 驗併入仍 fire known-target)。A3 invite 距離用 belief_pos 非 live。C path_system 純註解。TDD→measure(seed1337 team19 不再跨圖 settle)→QA→blueprint→merge。"
---

# slice2 感知鐵律一致套用（dispatch，R² CLEAN）

## spec + branch
- **spec**：`docs/superpowers/specs/2026-07-18-consistency-application-invite-buyfood.md`（**Part A 3 點 + Part C landmine**；Part B buy-food 已移入 ladder slice，不做）。
- **異質 Sonnet R²**：A1/A2/C CLEAN，**A3 blocking 已修**（見下）。
- **★branch off LOCAL main `bb1e75ff`**（② 已 local merged）：`git worktree add .worktrees/slice2-perception -b feat/slice2-perception`（off local main bb1e75ff）。**origin 只到 ①(1132bf0c)**→你 branch diff 對 **local main(bb1e75ff)=純 slice2**（別對 origin/main=會含 ②）。

## A1：threat DEFEND/求和 move → belief_pos
- `decision_context.gd:192` `c.threat_pos = _ot.tile_pos`（live）→ `options.gd:294`(DEFEND)/`:305`(求和) move target 讀它。
- **R² 坐实 threat_pos 無其他消費者**（grep 只 set@192 + read@294/305）→ **可全域改 `ctx:192`** 為 `BeliefSystem.belief_pos(state, team.team_id, _best_id)`（比局部改兩 to_task 乾淨）。鏡射攻擊 `options.gd:194`。
- = threat evasion intended（敵脫視→追 last-seen 非瞬鎖真位，[[invariants]] 已鎖）。

## A2：absorb → belief（降級 caveat）
- `decision_context.gd:369-372` 讀 target `effective_food`+`population`（live god-view）→ `terms.gd:214-218` 併入 util 消費。
- **★belief schema 缺 food_est**（R² 查 best_estimate 只有 population_est/tile_pos/armed_est/last_tick）→ **降級**：
  - gate on `has_belief`（無 belief→absorb_yield=0，不 god-view 直讀）。
  - 有 belief→用 `population_est` proxy（no explicit food→保守估，如 population_est/YIELD_NORM）或只 pop-based yield。
- **★measurer 驗**：併入在 known-target 情境仍 fire（降級可能降 併入 率，可接受=保守，但確認沒完全不 fire）。

## A3：invite 距離 gate 用 belief_pos（★R² blocking 修）
- `faction_ai_system.gd:574` `_try_invite_nearby_exile` 無距離 gate → 跨圖邀。
- **★用 belief 位置非 live**：`hex_distance(team.tile_pos, BeliefSystem.belief_pos(state, team.team_id, tid)) <= INVITE_RANGE`。**禁 `t.tile_pos`(live)**——用 live=修 god-view 卻讀 god-view=cosmetic（R² 血證：invite 照 live 觸發但 belief 該拒→跨圖 settle 照發生）。
- INVITE_RANGE=TEST VALUE（對齊 VisionSystem.VISION_RADIUS/近距，measurer 校 seed1337）。

## C：path_system landmine 純註解
- `path_system.gd` observe_velocity/estimate_catch_up/predict_intercept 頂加 god-view landmine 警告註（見 spec §Part C）。**純註解無邏輯變**。

## 完 → 下一站
- TDD（char bed：A1 threat 脫視追 last-seen、A2 無 belief→absorb 0、A3 belief 距離 gate 擋跨圖邀）。
- 完 → measurer（sim, seed1337/42/4201，**seed1337 team19 不再跨圖 settle**、跨派系 absorb 收斂、threat 不再瞬追）→ QA 故事稽核 → blueprint release-pass → 我 merge。
- 憲法：全 3 fix 都是「god-view→belief」= 感知鐵律強化，合憲。

## 溯源
異質 R²（A1/A2/C CLEAN + A3 belief_pos 修）;spec Part A;[[invariants]] 感知鐵律位置語義（belief last-seen）;blueprint roadmap (b) slice2 先。
