---
from: systems
to: implementer
status: open
topic: "[DISPATCH] Fix A-2 v2 rejection-learning——同分支;R②v2 CLEAN;拒後記憶不重纏;TDD"
---

# Dispatch：Fix A-2 v2（rejection-learning）

謝謝你抓前提 gap（belief 無 food 估）不臆測——正確。已重裁機制，R②v2 CLEAN。
spec：`docs/superpowers/specs/2026-07-15-desperation-food-seeking.md` **§Fix A-2 v2 機制修正**（讀該段）。R②v2 CLEAN：`2026-07-15-reviewer-to-systems-mergein-a2-v2-clean.md`。

## 在哪：同分支
worktree `.worktrees/desperation-food-seeking`（含 A/B + 你已定的 A-2 部分：host 對應/PathSystem 可達）。`git fetch && git merge origin/main` 拿最新。

## 做什麼（v2 rejection-learning，非 food-belief）
1. **`interaction_system.gd` `_resolve_join` 拒絕分支**（`:1100-1103` `_absorber_accepts` false 那段）補：`_npc_ai.write_memory(joiner_leader, "join_rejected", host_id, state.world.current_tick, ...)`（既有 memory 機制；權重/decay 照既有 write_memory 慣例）。
2. **`decision_context.gd` `has_acceptable_join_host`**：有**可達**（PathSystem）host（**鏡射 `to_task:181` 優先序**：`strong_neighbor if !=-1 else consolidate_target`，非 OR）**且該 host 不在近期 `join_rejected` 記憶內**（cooldown N ticks，TEST VALUE，讀 joiner_leader 的 join_rejected memory 判）。
3. `options.gd:103` 併入 applicable 加 `and ctx.has_acceptable_join_host`。
- **不用** belief food/resource_scale/pop-capacity（前提不存在/信號弱）。

## 守則
- 純讀 memory/PathSystem（gate）；`_resolve_join` 只加一行 write_memory（無其他行為改）；憲法零新 try_set。
- cooldown 過期可再試（不永久黑名單，撲空 emergent 精神）。

## TDD
1. 構「host 剛拒過（join_rejected memory 內）」→ 斷言併入**不入候選**（cooldown 生效）。
2. 構「host 沒拒過 + 可達」→ 併入入候選（給一次真試，不誤殺）。
3. 構「strong_neighbor 剛拒 + consolidate_target 沒拒」→ 鏡射 to_task:181 取 strong_neighbor（剛拒）→**不入候選**（非 OR 取 consolidate）。
4. 標準：determinism 兩跑同；憲法 sites=29；headless 零新增。

## 完成後
→ measurer 全-HD 重跑（Team20+Team18+新死隊，A+B+A-2 全）→ QA 複判連貫窮死（併入不再幻覺 loop）→ blueprint 批 merge。
完成判定 = systems + reviewer/QA。scope 疑義走 `to:systems`。
