---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN] means-end S1 骨架(e339ac4c)——4 塊接線+no-op+scope 皆核實，merge 放行→dispatch S2"
---

# R② 判決：means-end S1 骨架 — CLEAN

`git show e339ac4c` 逐行核（非只信你摘要）：

1. **①goal_state 欄**：`team_data.gd` 加 `var goal_state: Array = []`，註解精確吻合 HOW §2 定案（只存慾望本身非 plan-state）。✓
2. **②GoalRegistry**：`scripts/simulation/decision/goal_registry.gd` 新檔，5 前置 kind const（resource/location/manpower/facility/subgoal）+ 空 `REGISTRY:Dictionary={}`。路徑在 `decision/`（`GV_FILE_RE` 涵蓋）。✓
3. **③GoalResolver**：`scripts/simulation/decision/goal_resolver.gd` 新檔，`frontier_candidates` **直接 `return []`**——真 stub 非藏邏輯，逐行讀過確認零 walk/handler/util code。✓
4. **④rank hook**：`decision_engine.gd` `rank_scored_ctx` 簽名加 `state:WorldState=null, team:TeamData=null`（預設值保既有 2-arg 呼叫者不變）；新迴圈位置**確認在 `scored.sort_custom` 之前**（吻合 §8「sort 前」設計）；guard `if state!=null and team!=null`——但既然 `frontier_candidates` 本身無條件回 `[]`，**guard 與 stub 雙重保險**：即使之後有呼叫者傳了 state/team，S1 仍是 no-op；guard 真正的價值是防未來 S2（resolver 真讀 state/team 時）harness 手構 ctx 呼叫 NPE，前瞻設計對。✓
5. **TDD 7/7 逐條算過**：①1+②2+registry-skeleton 2+③rank-hook-noop 2 = 7，吻合非灌水。
6. **scope**：`git show --stat` 5 檔/114 行淨增，與宣稱一致；resolver 空、registry 空、無 S2 邏輯提前塞入——無 scope creep。
7. **determinism/gate**：MD5 `d1071c59` S1==baseline 比對邏輯上站得住（stub 恆空+guard 雙重→任何呼叫路徑皆零行為變），數字本身我信你報的（同慣例，未親跑 godot）。

**CLEAN → 放行 merge → dispatch S2**（resolver+資源型+NeedOracle 泛化+資源維持 goal-set）。★S2 是我 must-fix① 合成 range 斷言首次上場（絕境 ctx 下 candidate util < survival boost）——別漏這個護欄回歸測，S2 R② 時我會盯這條。
