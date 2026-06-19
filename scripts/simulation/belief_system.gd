class_name BeliefSystem

# team_intel[obs][tgt] = Array of claim（G3b multi-claim）。
# claim: { value:Dictionary, source_id:int, source_type:String, tick:int, credibility:float, distorted:bool }
# 禁直讀 state.team_intel（決策/UI 一律走此）。讀容錯舊式 Dict（test/transitional）。

const MAX_CLAIMS_PER_TARGET := 4      # TEST VALUE
const MAX_CLAIMS_PER_OBSERVER := 200  # TEST VALUE

# 類型基準表（TEST VALUE，序遵 game-design：親見>隊友>商旅>流民）。
# 官方/酒館/書籍待 producer 再加（免休眠；現無寫端產這些類別）。
const CRED_BASE := { "親見": 1.0, "隊友": 0.8, "商旅": 0.6, "流民": 0.3 }
const TRUST_FLOOR := 0.5             # trust 0..1 → 乘數 0.5..1.5
const BELIEF_HOP_DECAY := 0.15       # 對齊 message HOP_DECAY
const CRED_AGE_FULL_DECAY := WorldState.TICKS_PER_DAY * 30  # TEST VALUE
const CRED_TIME_FLOOR := 0.2         # TEST VALUE
const TRUST_DELTA := 0.05            # TEST VALUE：親見比對 relayed → ±口碑步長

# G3c-2 技能識破（信假/生疑/裁決）
const DETECT_SCHEME_GAIN := 0.8       # TEST VALUE：對方計謀壓低我識破
const DETECT_SUSPECT_T := 0.3         # TEST VALUE：生疑門檻
const DETECT_ADJUDICATE_T := 0.6      # TEST VALUE：裁決門檻
const DETECT_SUSPECT_MULT := 0.5      # TEST VALUE：生疑 cred 折扣
const DETECT_ADJUDICATE_MULT := 0.2   # TEST VALUE：裁決 cred 折扣
# G3c-2 觀察吃技能
const OBS_SKILL_NOISE_GAIN := 0.5     # TEST VALUE：低技能額外觀察噪
# G3d-1 決策風險 gate
const GATE_CONF_LOW := 0.0    # TEST VALUE：莽者門檻
const GATE_CONF_HIGH := 0.6   # TEST VALUE：慎重者門檻

# 寫時可信度（時不變部分）：類型基準 × 身份信任 × 跳數衰減。
# 身份信任 = obs team known_reputations[source]（0..1，default 0.5）；親見 source==obs → 1.0。
static func source_credibility(state: WorldState, observer_id: int,
		source_type: String, source_id: int, hop: int) -> float:
	var base: float = float(CRED_BASE.get(source_type, 0.3))
	var trust := 0.5
	var obs_team: TeamData = state.teams.get(observer_id)
	if obs_team != null and source_id != observer_id:
		trust = float(obs_team.known_reputations.get(source_id, 0.5))
	var hop_decay: float = pow(1.0 - BELIEF_HOP_DECAY, hop)
	return clampf(base * (TRUST_FLOOR + trust) * hop_decay, 0.0, 1.5)

static func _time_decay(state: WorldState, tick: int) -> float:
	var age: int = state.world.current_tick - tick
	if age <= 0: return 1.0
	return clampf(1.0 - float(age) / float(CRED_AGE_FULL_DECAY), CRED_TIME_FLOOR, 1.0)

# 讀時可信度（排序用）= 寫時 cred × 時效衰減 → 新鮮勝陳舊。
static func effective_credibility(state: WorldState, claim: Dictionary) -> float:
	return float(claim["credibility"]) * _time_decay(state, int(claim["tick"]))

# 識破分級（信假/生疑/裁決）：我理解力 vs 對方計謀 → cred 折扣 + 疑點 flag。
# 非 un-distort（真值不隨行）：只壓對該謊的信任，不還原值。
static func detection_discount(my_skill: float, their_scheme: float) -> Dictionary:
	var detect: float = clampf(my_skill - their_scheme * DETECT_SCHEME_GAIN, 0.0, 1.0)
	if detect >= DETECT_ADJUDICATE_T:
		return { "discount": DETECT_ADJUDICATE_MULT, "suspicious": true }
	if detect >= DETECT_SUSPECT_T:
		return { "discount": DETECT_SUSPECT_MULT, "suspicious": true }
	return { "discount": 1.0, "suspicious": false }

# 觀察品質吃觀察者技能：base = 距離噪；低技能疊殘留噪（親見也錯，cred 仍 1.0）。
static func observation_noise(base_noise: float, skill: float) -> float:
	return clampf(base_noise + (1.0 - clampf(skill, 0.0, 1.0)) * OBS_SKILL_NOISE_GAIN, 0.0, 1.0)

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
	var best_eff: float = effective_credibility(state, best)
	for c in cs:
		var eff: float = effective_credibility(state, c)
		if eff > best_eff \
				or (eff == best_eff and int(c["tick"]) > int(best["tick"])):
			best = c; best_eff = eff
	return best["value"]

# credibility-weighted（G3d-2）：(1−最強源 eff_cred) + cred 加權值分歧。
# 親見高 cred 主導 → top→1 + 假源時效衰權重低 → spread 小 → 壓低不確定（查證可收斂）。
# 無 claim → 1.0；純未驗 relay → (1−cred) 高；真打架(雙新鮮高 cred 矛盾) → spread 高。
static func uncertainty(state: WorldState, obs_id: int, tgt_id: int) -> float:
	var cs: Array = claims(state, obs_id, tgt_id)
	if cs.is_empty(): return 1.0
	var best_val: float = float(best_estimate(state, obs_id, tgt_id).get("population_est", 0.0))
	var top := 0.0
	var wsum := 0.0
	var num := 0.0
	for c in cs:
		var w: float = effective_credibility(state, c)
		top = maxf(top, w)
		wsum += w
		num += w * absf(float((c["value"] as Dictionary).get("population_est", best_val)) - best_val)
	var spread := 0.0
	if wsum > 0.0001 and best_val > 0.0001:
		spread = num / (wsum * best_val)
	return clampf((1.0 - top) + spread, 0.0, 1.0)

# 風險 gate：個性慎重 × 情報不確定性 → 是否夠把握 commit 攻擊性行動。
# 莽者門檻低(照衝,假情報誘殺)；慎重者需高 confidence(矛盾情報按兵)。
static func confident_enough(state: WorldState, observer_id: int, target_id: int, caution: float) -> bool:
	var confidence: float = 1.0 - uncertainty(state, observer_id, target_id)
	var threshold: float = lerpf(GATE_CONF_LOW, GATE_CONF_HIGH, clampf(caution, 0.0, 1.0))
	return confidence >= threshold

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
	# 親見 record → 被動查證：比對同 tgt relayed claim 調 source 口碑
	if source_type == "親見" and source_id == obs_id:
		reconcile_firsthand(state, obs_id, tgt_id)

# 被動身份信任迴路：obs 對 tgt 有親見 → 比對各 relayed source pop_est → ±口碑。
# 準（比值近 1）升、離譜/失真降。scout 主動查證 = G3d（本層只被動偶遇）。
static func reconcile_firsthand(state: WorldState, obs_id: int, tgt_id: int) -> void:
	var obs_team: TeamData = state.teams.get(obs_id)
	if obs_team == null: return
	var cs: Array = claims(state, obs_id, tgt_id)
	var truth := -1.0
	for c in cs:
		if c["source_type"] == "親見" and int(c["source_id"]) == obs_id:
			truth = float((c["value"] as Dictionary).get("population_est", -1.0)); break
	if truth <= 0.0: return
	for c in cs:
		var sid: int = int(c["source_id"])
		if sid == obs_id or c["source_type"] == "親見": continue
		var rep: float = float((c["value"] as Dictionary).get("population_est", -1.0))
		if rep <= 0.0: continue
		var r: float = rep / truth
		if r >= 0.7 and r <= 1.3:
			obs_team.update_reputation(sid, TRUST_DELTA)
		elif r < 0.4 or r > 2.5 or bool(c.get("distorted", false)):
			obs_team.update_reputation(sid, -TRUST_DELTA)

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
