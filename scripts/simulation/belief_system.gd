class_name BeliefSystem

# team_intel[obs][tgt] = Array of claim（G3b multi-claim）。
# claim: { value:Dictionary, source_id:int, source_type:String, tick:int, credibility:float, distorted:bool }
# 禁直讀 state.team_intel（決策/UI 一律走此）。讀容錯舊式 Dict（test/transitional）。

const MAX_CLAIMS_PER_TARGET := 4      # TEST VALUE
const MAX_CLAIMS_PER_OBSERVER := 200  # TEST VALUE

static func _coerce(raw) -> Array:
	# Array → as-is；Dict（舊式/test）→ 單親見 claim；其餘 → []
	if raw is Array:
		return raw
	if raw is Dictionary and not raw.is_empty():
		return [{ "value": raw, "source_id": -1, "source_type": "親見",
			"tick": int(raw.get("last_tick", 0)),
			"credibility": float(raw.get("confidence", 1.0)), "distorted": false }]
	return []

static func claims(state: WorldState, obs_id: int, tgt_id: int) -> Array:
	return _coerce(state.team_intel.get(obs_id, {}).get(tgt_id, null))

static func has_belief(state: WorldState, obs_id: int, tgt_id: int) -> bool:
	return not claims(state, obs_id, tgt_id).is_empty()

static func known_targets(state: WorldState, obs_id: int) -> Array:
	return state.team_intel.get(obs_id, {}).keys()

static func best_estimate(state: WorldState, obs_id: int, tgt_id: int) -> Dictionary:
	var cs: Array = claims(state, obs_id, tgt_id)
	if cs.is_empty(): return {}
	var best: Dictionary = cs[0]
	for c in cs:
		if float(c["credibility"]) > float(best["credibility"]) \
				or (float(c["credibility"]) == float(best["credibility"]) and int(c["tick"]) > int(best["tick"])):
			best = c
	return best["value"]

static func uncertainty(state: WorldState, obs_id: int, tgt_id: int) -> float:
	var cs: Array = claims(state, obs_id, tgt_id)
	if cs.is_empty(): return 1.0
	if cs.size() == 1:
		return clampf(1.0 - float(cs[0]["credibility"]), 0.0, 1.0)
	var lo := INF; var hi := -INF
	for c in cs:
		var v: float = float((c["value"] as Dictionary).get("population_est", 0))
		lo = minf(lo, v); hi = maxf(hi, v)
	if hi <= 0.0: return 0.0
	return clampf((hi - lo) / hi, 0.0, 1.0)

static func record_claim(state: WorldState, obs_id: int, tgt_id: int,
		source_id: int, source_type: String, fields: Dictionary,
		credibility: float, distorted: bool) -> void:
	if not state.team_intel.has(obs_id):
		state.team_intel[obs_id] = {}
	var cs: Array = _coerce(state.team_intel[obs_id].get(tgt_id, null))
	var found := false
	for c in cs:
		if int(c["source_id"]) == source_id:
			(c["value"] as Dictionary).merge(fields, true)  # 同源累積/覆寫欄
			c["tick"] = int(state.world.current_tick)
			c["credibility"] = credibility
			c["distorted"] = distorted
			found = true
			break
	if not found:
		var v: Dictionary = {}
		v.merge(fields, true)
		cs.append({ "value": v, "source_id": source_id, "source_type": source_type,
			"tick": int(state.world.current_tick), "credibility": credibility, "distorted": distorted })
	_cap_target(cs)
	state.team_intel[obs_id][tgt_id] = cs
	_cap_observer(state, obs_id)

static func _cap_target(cs: Array) -> void:
	while cs.size() > MAX_CLAIMS_PER_TARGET:
		var worst := 0
		for i in range(1, cs.size()):
			if float(cs[i]["credibility"]) < float(cs[worst]["credibility"]) \
					or (float(cs[i]["credibility"]) == float(cs[worst]["credibility"]) and int(cs[i]["tick"]) < int(cs[worst]["tick"])):
				worst = i
		cs.remove_at(worst)

static func _cap_observer(state: WorldState, obs_id: int) -> void:
	var by_obs: Dictionary = state.team_intel[obs_id]
	var total := 0
	for t in by_obs:
		total += _coerce(by_obs[t]).size()
	# 溢出剪最老 claim（跨 tgt 找全域最老）
	while total > MAX_CLAIMS_PER_OBSERVER:
		var oldest_t = -1; var oldest_i = -1; var oldest_tick = INF
		for t in by_obs:
			var arr: Array = _coerce(by_obs[t])
			for i in arr.size():
				if int(arr[i]["tick"]) < oldest_tick:
					oldest_tick = int(arr[i]["tick"]); oldest_t = t; oldest_i = i
		if oldest_t == -1: break
		var arr2: Array = by_obs[oldest_t]
		arr2.remove_at(oldest_i)
		if arr2.is_empty(): by_obs.erase(oldest_t)
		total -= 1
