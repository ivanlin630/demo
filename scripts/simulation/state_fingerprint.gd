class_name StateFingerprint

# ★F0 安全網（spec 2026-08-07-framework-F0-state-fingerprint-HOW）：全 world-state 結構化 canonical hash。
# ★★命門：純讀 state 零寫、★零 global RNG（觀測儀器不擾世界=[[feedback_observer_no_global_rng]] LOD→RNG 犯過 2 次、第三度警戒）。
# 用途：純結構 slice（抽 decision chunk/切模組）前後 fingerprint 三跑一致 + 多 seed×多床 regression 不變 = 真證「只搬位置」（行為零漂移）。
# full canonical（sorted-by-id + dict 顯式 sort[非信 GDScript4 插入序、跨 code 版本序穩定]+ float 量化 round 1e-4）→ hash collapse 任意 size 成定長。

const QUANT: float = 10000.0   # float 量化 1e-4（避浮點格式噪；round(x*QUANT) 整數化）

# 全 state canonical hash（decision-and-lifecycle-affected state；純讀零 RNG）。
static func compute(state: WorldState) -> String:
	var buf: PackedStringArray = PackedStringArray()
	_emit_teams(state, buf)
	_emit_persons(state, buf)
	_emit_factions(state, buf)
	_emit_belief(state, buf)
	_emit_tiles(state, buf)
	_emit_world(state, buf)
	return "\n".join(buf).md5_text()

# 逐域 fingerprint（除錯/假覆蓋檢：驗某域欄位在 27 筆真有變化非死值）。
static func compute_domains(state: WorldState) -> Dictionary:
	var t := PackedStringArray(); _emit_teams(state, t)
	var p := PackedStringArray(); _emit_persons(state, p)
	var f := PackedStringArray(); _emit_factions(state, f)
	var b := PackedStringArray(); _emit_belief(state, b)
	var ti := PackedStringArray(); _emit_tiles(state, ti)
	var w := PackedStringArray(); _emit_world(state, w)
	return {
		"teams": "\n".join(t).md5_text(), "persons": "\n".join(p).md5_text(),
		"factions": "\n".join(f).md5_text(), "belief": "\n".join(b).md5_text(),
		"tiles": "\n".join(ti).md5_text(), "world": "\n".join(w).md5_text(),
	}

# ──────── canonical 序列化 primitives（純函式）────────
static func _q(v: float) -> String:
	return str(roundi(v * QUANT))   # 量化整數化（穩定、無浮點格式噪）

static func _vec(v: Vector2i) -> String:
	return "%d,%d" % [v.x, v.y]

static func _dict_canon(d: Dictionary) -> String:
	var keys: Array = d.keys(); keys.sort()   # ★顯式 sort（非信插入序）
	var parts: PackedStringArray = PackedStringArray()
	for k in keys:
		parts.append("%s=%s" % [str(k), _val_canon(d[k])])
	return ";".join(parts)

static func _arr_canon(a: Array) -> String:
	var c: Array = []
	for x in a: c.append(str(x))
	c.sort()   # ★sort（set 語意欄如 tags/members 序穩定）
	return ";".join(PackedStringArray(c))

static func _val_canon(v) -> String:
	if v is float: return _q(v)
	if v is int or v is bool: return str(v)
	if v is Vector2i: return _vec(v)
	if v is Dictionary: return "{" + _dict_canon(v) + "}"
	if v is Array: return "[" + _arr_canon(v) + "]"
	return str(v)

# ──────── 域序列化（sorted by id、spec §2.1 欄位）────────
static func _emit_teams(state: WorldState, buf: PackedStringArray) -> void:
	var ids: Array = state.teams.keys(); ids.sort()
	for tid in ids:
		var t: TeamData = state.teams[tid]
		# 全 decision/lifecycle 持久欄（full canonical、最大化 drift 偵測）。
		# ★排除 ephemeral 快取（food_runway/persist_strength/food_flow_avg/need_urgency=recompute/EWMA）+ cadence 排程欄（*_eval_next_tick）+ observer/probe。
		buf.append("T|%d|pop=%d|minor=%d|prisoner=%d|task=%s|prio=%d|reason=%s|prev=%s|pos=%s|mt=%s|corvee=%s|fac=%d|parent=%d|combat=%d|social=%d|opt=%s|unrest=%d|famine=%s|rung=%d|phase=%s|res=%s|tags=%s|anon=%s|subs=%s|rep=%s|intent=%s|goals=%s" % [
			t.team_id, t.population, t.minor_population, t.prisoner_population, t.current_task, t.task_priority, t.task_reason, t.previous_task,
			_vec(t.tile_pos), _vec(t.move_target), _vec(t.corvee_site), t.faction_id, t.parent_team_id, t.combat_target, t.social_target,
			t.current_option, t.unrest_turns, _q(t.famine_days), t.ambition_rung, t.plan_phase,
			_dict_canon(t.resources), _arr_canon(t.tags), _dict_canon(t.anon_cohorts), _arr_canon(t.subteam_ids),
			_dict_canon(t.known_reputations), _dict_canon(t.solo_intent), _arr_canon(t.goal_state)])

static func _emit_persons(state: WorldState, buf: PackedStringArray) -> void:
	var ids: Array = state.persons.keys(); ids.sort()
	for pid in ids:
		var p: PersonData = state.persons[pid]
		buf.append("P|%d|team=%d|dead=%s|loy=%s|values=%s|skills=%s|mem=%s" % [
			p.id, p.team_id, str(p.is_dead), _q(p.loyalty),
			_dict_canon(p.values), _dict_canon(p.skills), _memory_canon(p.memory)])

# memory full canonical（type+key+tick sorted、非全 value dump=防噪但足偵移位漂移）。
static func _memory_canon(mem: Array) -> String:
	var lines: PackedStringArray = PackedStringArray()
	for m in mem:
		if m is Dictionary:
			lines.append("%s:%s:%s" % [str(m.get("type", "")), str(m.get("key", m.get("subject", ""))), str(m.get("tick", ""))])
		else:
			lines.append(str(m))
	var s: Array = []
	for l in lines: s.append(l)
	s.sort()
	return ";".join(PackedStringArray(s))

static func _emit_factions(state: WorldState, buf: PackedStringArray) -> void:
	var ids: Array = state.factions.keys(); ids.sort()
	for fid in ids:
		var f: FactionData = state.factions[fid]
		buf.append("F|%d|leader=%d|est=%s|members=%s|goals=%s|drivers=%s|relations=%s" % [
			f.faction_id, f.leader_team_id, str(f.is_established),
			_arr_canon(f.member_team_ids), _arr_canon(f.goals), _dict_canon(f.goal_drivers), _dict_canon(f.relations)])

static func _emit_belief(state: WorldState, buf: PackedStringArray) -> void:
	# per-observer sorted canonical（team_discovered / team_intel / known_reputations 結構摘要）。
	var obs: Array = state.team_discovered.keys(); obs.sort()
	for oid in obs:
		buf.append("Bd|%d|%s" % [oid, _arr_canon(state.team_discovered[oid])])
	var iobs: Array = state.team_intel.keys(); iobs.sort()
	for oid in iobs:
		buf.append("Bi|%d|%s" % [oid, _val_canon(state.team_intel[oid])])

static func _emit_tiles(state: WorldState, buf: PackedStringArray) -> void:
	var ids: Array = state.world.tiles.keys(); ids.sort()
	for tid in ids:
		var t: HexTileData = state.world.tiles[tid]
		if t.outpost_level <= 0 and t.construction_team_id == -1 and t.camp_level <= 0:
			continue   # 純野格無 outpost/施工/L0營地 → 不入 fingerprint（★S2a：camp_level>0 必入、否則 L0 變化 determinism 盲點）
		buf.append("H|%d|owner=%d|lvl=%d|camp=%d|campleft=%d|farm=%s|ctid=%d|cleft=%d|store=%s" % [
			tid, t.outpost_owner, t.outpost_level, t.camp_level, t.camp_ticks_left,
			str(t.get("farming_level")), t.construction_team_id, t.construction_ticks_left,
			_dict_canon(t.public_storage)])

static func _emit_world(state: WorldState, buf: PackedStringArray) -> void:
	buf.append("W|tick=%d|letters=%d|teams=%d|persons=%d|factions=%d|pending_erase=%d" % [
		state.world.current_tick, state.in_transit_letters.size(),
		state.teams.size(), state.persons.size(), state.factions.size(), state.teams_pending_erase.size()])
	# in_transit_letters canonical（kind/origin/target/relocate_to sorted、真送達漂移偵測）。
	var ls: Array = []
	for l in state.in_transit_letters:
		if l is Dictionary:
			ls.append("%s:%d:%s:%s" % [str(l.get("kind","")), int(l.get("origin_team_id",-1)), _vec(l.get("target_pos", Vector2i(-1,-1))), _vec(l.get("relocate_to", Vector2i(-1,-1)))])
	ls.sort()
	for e in ls: buf.append("L|" + e)
