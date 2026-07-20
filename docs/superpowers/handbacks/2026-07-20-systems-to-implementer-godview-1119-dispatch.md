---
from: systems
to: implementer
status: consumed
topic: "[dispatch·god-view 1119 can_reach·R² CLEAN·便宜收尾·★off LOCAL main b5f9efa0] spec=2026-07-20-godview-1119-can-reach.md。god-view arc 最後 leak。root:_precond_met can_reach 分支(faction_ai_system.gd:1117-1119,行號驗過)讀 state.teams[target_id].tile_pos=live 他隊位算距(旁 force_ge_target:1113 用 BeliefSystem.best_estimate belief,不一致)。修=belief-gate 距離同 Slice D position 範式(belief_pos primitive)。★vacuous(<999 恆真)不擴本刀,已記 known_issues。TDD 3型。gate/headless 0new/determinism 2跑 byte-identical/measure輕(近-vacuous doom-delta 不惡化)。off LOCAL main b5f9efa0。task=systems+reviewer。做完→to:measurer(輕)。"
---

# dispatch：god-view 1119 can_reach（R² CLEAN，便宜收尾）

god-view arc **最後 leak**（A/F/E/D/B/C+null-belief-flee merged，這條 merged→全 leak 治完）。
spec：`docs/superpowers/specs/2026-07-20-godview-1119-can-reach.md`。reviewer R² **CLEAN**（範式一致/positionless→false 合 null-belief-flee/vacuous 不擴刀我認可/無 RNG）。

## ★★ branch base
- **off LOCAL main `b5f9efa0`**（禁 origin 落後）。pre-push hook 已裝。

## root（行號驗過，非 audit stale）
`_precond_met` 的 `"can_reach"` 分支（`faction_ai_system.gd:1117-1119`）讀 `state.teams[target_id].tile_pos` = **live 他隊位算距**。旁邊 `force_ge_target:1113` 已用 `BeliefSystem.best_estimate` belief → **不一致**。

現況：
```gdscript
"can_reach":
    return target_id != -1 and state.teams.has(target_id) \
        and _hex_dist(leader_team.tile_pos, state.teams[target_id].tile_pos) < 999
```

## 修（belief-gate 距離，同 Slice D position 範式 `belief_pos` primitive）
```gdscript
"can_reach":
    if target_id == -1 or not state.teams.has(target_id): return false
    var tgt_pos: Vector2i = BeliefSystem.belief_pos(state, f.leader_team_id, target_id)
    if tgt_pos == Vector2i(-1, -1): return false   # positionless/斷視線太舊 → 無法算可達
    return _hex_dist(leader_team.tile_pos, tgt_pos) < 999
```
- `leader_team.tile_pos` = **自身位（god-view 自己合法，own physical state 非他隊）**，不動。
- target 位 → `BeliefSystem.belief_pos(state, f.leader_team_id, target_id)`（同-faction 走 known_member_states / 跨-faction 走 best_estimate last-seen，內含 freshness BELIEF_STALE_TICKS + positionless→(-1,-1)）。
- **同 Slice D**（`path_system.gd:221` `belief_pos` + `no_belief_pos`→false）——完全一致範式。
- 可見（belief 本 tick 更新）→ belief_pos == live 位 → 用 live 距；斷視線→last-seen 距；太舊/positionless→(-1,-1)→false。

## ★vacuous 不擴本刀
`<999` 近-vacuous（hex 距遠 <999→恆真）=決策品質洞（若本該真 reachability gate），**已記 known_issues，非 god-view，別擴本刀**（本刀只治 live 讀→belief-gate；vacuous/PathSystem 真可達=economy/decision-quality 地盤另評）。別 scope creep 進 reachability 重設計。

## 驗收
- **TDD 3型**：①target 可見（belief 本 tick）→ 用 live 距（<999→true）②斷視線 recent→belief last-seen 距 ③positionless/太舊 belief→(-1,-1)→can_reach false（**不瞬鎖真位算可達**）。
- **gate** PASS（`constitution_gate.gd`）/ **headless** 0 new error / **determinism** 2 跑 byte-identical（無新 RNG）。
- **measure（→measurer，輕，近-vacuous 行為影響小）**：doom-delta seed1337/42 不惡化即可；god-view audit 這條路無 live 讀（belief-gate 證）。

## ★god-view arc 收尾
1119 merged → **A/F/E/D/B/C+null-belief-flee+1119 全 leak 治完** → 我做 constitution_gate 擴版（god-view detector 機器證零殘留）→ economy arc。

## 完成判定 = systems + reviewer。做完 → to:measurer（輕 measure）。
