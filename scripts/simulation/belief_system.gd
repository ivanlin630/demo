class_name BeliefSystem

# team_intel 單一讀 accessor。G3a 回現單 entry 語義；G3b 換 multi-claim 聚合（讀者零動）。
# 禁直讀 state.team_intel（決策讀者一律走此）。

static func best_estimate(state: WorldState, obs_id: int, tgt_id: int) -> Dictionary:
	return state.team_intel.get(obs_id, {}).get(tgt_id, {})

static func has_belief(state: WorldState, obs_id: int, tgt_id: int) -> bool:
	return not best_estimate(state, obs_id, tgt_id).is_empty()

static func uncertainty(state: WorldState, obs_id: int, tgt_id: int) -> float:
	var e: Dictionary = best_estimate(state, obs_id, tgt_id)
	if e.is_empty():
		return 1.0
	return clampf(1.0 - float(e.get("confidence", 1.0)), 0.0, 1.0)
