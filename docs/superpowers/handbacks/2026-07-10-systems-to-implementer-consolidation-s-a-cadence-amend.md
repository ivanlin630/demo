---
from: systems
to: implementer
status: open
topic: [S-A 追加] consolidate cadence gate（perf/churn 修，merge 前置）——加進 feat/consolidation-s-a
---

# 追加：consolidate cadence gate（S-A merge 前置）

blueprint churn 假設 systems profile **確認**（`decision_context:262-266` 每成員每 tick call `consolidate_target_of`→`_find_absorber` O(N)，無 cadence gate；S-A 食壓 scaled 讓 dispatch churn 疊上）→ 2x 慢、大窗跑不動。**加 cadence gate 進 feat/consolidation-s-a**（spec §HOW-4）。

## 改（cache consolidate target，1 日 cadence，鏡射 SUBTEAM_CADENCE）
1. `TeamData` +兩欄：`consolidate_target_cache: int = -1`、`consolidate_eval_next_tick: int = 0`。
2. `decision_context.gd:262-266` 整併 target 算法加 gate：
```gdscript
	c.consolidate_target_id = -1
	if team.faction_id != -1 and team.parent_team_id == -1:
		var _f = state.factions.get(team.faction_id)
		if _f != null and team.team_id != _f.leader_team_id:
			if state.world.current_tick >= team.consolidate_eval_next_tick:
				team.consolidate_target_cache = FactionAISystem.consolidate_target_of(state, team, _f)
				team.consolidate_eval_next_tick = state.world.current_tick + FactionAISystem.CONSOLIDATE_CADENCE
			c.consolidate_target_id = team.consolidate_target_cache
```
3. `faction_ai` +`const CONSOLIDATE_CADENCE: int = TimeScale.TICK_PER_DAY * 1`（鏡射 `SUBTEAM_CADENCE`）。

## 驗
- determinism 保（cache 純節流，同 seed 逐事件同軌——**務必驗 determinism PASS**，cache 邏輯錯會漂）。
- perf：`gather.readiness_prey`/`member.unified` 熱點 profile 前後對照，O(N) 掃頻率降。
- 大窗現能跑完（churn 掐掉）→ measurer 拿得到 gate#1/#3 樣本。

## 併其餘 S-A 一起 handback to:measurer
- measurer 改量：**distinct 隊數 + 每隊重派次數**（churn vs 廣度）+ `dispatch vs 實際 merge 成交`（我已提醒 measurer）。
- reviewer 對完整 S-A diff（含此 cadence gate）再過一輪 CLEAN + measurer gate#1/#3 → merge。
