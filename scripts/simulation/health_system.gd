# scripts/simulation/health_system.gd
class_name HealthSystem

const BLOOD_MAX: float         = 100.0
const BLOOD_COMA_THRESHOLD: float = 30.0
const BLEEDING_MINOR_DRAIN: float = 3.0
const BLEEDING_MAJOR_DRAIN: float = 10.0
const POISON_HP_DRAIN: float   = 5.0
const RESOLVE_BLOOD_MAJOR: float = 30.0
const RESOLVE_BLOOD_MINOR: float = 10.0
const RESOLVE_POISON_HP: float = 10.0
const HP_REGEN_PER_TICK: float = 0.5
const HP_REGEN_FRACTURE: float = 0.05
const BLOOD_REGEN_PER_TICK: float = 0.2
# 餓傷流血：hunger >= 此值 → blood 改流失取代再生。
# tick_natural_regen 為 per-cadence（近區 ~24 次/日）非 per-tick；故 drain 取與
# BLOOD_REGEN_PER_TICK 同量級（每次呼叫），近區實際 ~5 血/日（spec 意圖值）。
const HUNGER_BLOOD_THRESHOLD: float = 0.7
const HUNGER_BLOOD_DRAIN_PER_TICK: float = 0.2
const CARRY_BASE: float        = 20.0
const CARRY_PER_BODY: float    = 10.0

static func _calc_status(hp: float, max_hp: float, _part: String) -> String:
	var ratio: float = hp / max_hp
	if ratio > 0.75:  return "healthy"
	if ratio > 0.25:  return "wounded"
	if ratio > 0.0:   return "critical"
	return "severed"   # HP=0: all parts including head/torso — fatal wound

static func receive_damage(unit: Dictionary, state: WorldState,
		part: String, final_dmg: float) -> void:
	var bp: Dictionary = _get_body_parts(unit, state)
	if not bp.has(part): return
	bp[part]["hp"] = maxf(bp[part]["hp"] - final_dmg, 0.0)
	bp[part]["status"] = _calc_status(bp[part]["hp"], bp[part]["max_hp"], part)

static func _get_body_parts(unit: Dictionary, state: WorldState) -> Dictionary:
	if unit.get("person_id", -1) != -1:
		var p: PersonData = state.persons.get(unit["person_id"])
		return p.body_parts if p else {}
	return unit.get("body_parts", {})

static func _fracture_speed_mult(bp: Dictionary) -> float:
	var broken: int = 0
	if bp.get("right_leg", {}).get("fracture", false): broken += 1
	if bp.get("left_leg",  {}).get("fracture", false): broken += 1
	if broken >= 2: return 0.1
	if broken == 1: return 0.5
	return 1.0

static func _max_carry(unit: Dictionary, state: WorldState) -> float:
	var p: PersonData = state.persons.get(unit.get("person_id", -1))
	var body: float = float(p.attributes.get("體力", 0.5)) if p else 0.5
	return CARRY_BASE + body * CARRY_PER_BODY

static func _calc_carry_weight(unit: Dictionary, state: WorldState) -> float:
	var total: float = 0.0
	for slot in unit.get("equipment", {}):
		var s: Dictionary = unit["equipment"][slot]
		if s.has("grade") and s["grade"] != "":
			total += ItemAttributes.get_weight(s["grade"])
	for item in unit.get("inventory", []):
		total += ItemAttributes.get_weight(item.get("grade", ""), item.get("qty", 1))
	return total

static func _weight_mult(unit: Dictionary, state: WorldState) -> float:
	var load: float  = _calc_carry_weight(unit, state)
	var cap: float   = _max_carry(unit, state)
	var ratio: float = load / maxf(cap, 0.001)
	if ratio <= 0.5: return 1.0
	return clampf(1.0 - (ratio - 0.5) * 1.0, 0.3, 1.0)

static func get_speed_mult(unit: Dictionary, state: WorldState) -> float:
	var p: PersonData = state.persons.get(unit.get("person_id", -1))
	var stamina_mult: float = float(unit.get("stamina", 1.0))
	var blood_mult: float   = 1.0
	var frac_mult: float    = 1.0
	var weight_mult: float  = _weight_mult(unit, state)
	if p:
		blood_mult = clampf(p.blood / BLOOD_MAX, 0.0, 1.0)
		frac_mult  = _fracture_speed_mult(p.body_parts)
	return stamina_mult * blood_mult * frac_mult * weight_mult

static func get_weight_stamina_drain_mult(unit: Dictionary,
		state: WorldState) -> float:
	var load: float  = _calc_carry_weight(unit, state)
	var cap: float   = _max_carry(unit, state)
	var ratio: float = load / maxf(cap, 0.001)
	if ratio <= 0.5: return 1.0
	return clampf(1.0 + (ratio - 0.5) * 2.0, 1.0, 3.0)

static func tick_status_effects(unit: Dictionary, state: WorldState) -> void:
	var bp: Dictionary = _get_body_parts(unit, state)
	var blood_drain: float = 0.0
	for part in bp:
		match bp[part].get("bleeding", "none"):
			"minor": blood_drain += BLEEDING_MINOR_DRAIN
			"major": blood_drain += BLEEDING_MAJOR_DRAIN
		if bp[part].get("poisoned", false):
			bp[part]["hp"] = maxf(bp[part]["hp"] - POISON_HP_DRAIN, 0.0)
			bp[part]["status"] = _calc_status(
				bp[part]["hp"], bp[part].get("max_hp", 50.0), part)
	if blood_drain > 0.0:
		_drain_blood(unit, state, blood_drain)

static func _drain_blood(unit: Dictionary, state: WorldState,
		amount: float) -> void:
	if unit.get("person_id", -1) != -1:
		var p: PersonData = state.persons.get(unit["person_id"])
		if p: p.blood = maxf(p.blood - amount, 0.0)
	else:
		unit["blood"] = maxf(float(unit.get("blood", 100.0)) - amount, 0.0)

static func resolve_negative_flags(state: WorldState, team: TeamData) -> void:
	var all_ids: Array = team.named_members.duplicate()
	if state.player_id != -1 and state.persons.has(state.player_id):
		if state.persons[state.player_id].team_id == team.team_id:
			if not all_ids.has(state.player_id):
				all_ids.append(state.player_id)
	var best_med: float = _best_skill(state, team, "醫療")
	for pid in all_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		for part in p.body_parts:
			var bp = p.body_parts[part]
			if bp.get("bleeding") == "major":
				if int(team.resources.get("medicine", 0)) >= 2:
					team.resources["medicine"] = int(team.resources["medicine"]) - 2
				elif randf() < best_med * 0.5:
					pass
				else:
					p.blood = maxf(p.blood - RESOLVE_BLOOD_MAJOR, 1.0)
				bp["bleeding"] = "none"
			if bp.get("bleeding") == "minor":
				if int(team.resources.get("medicine", 0)) >= 1:
					team.resources["medicine"] = int(team.resources["medicine"]) - 1
				elif randf() < best_med * 0.5:
					pass
				else:
					p.blood = maxf(p.blood - RESOLVE_BLOOD_MINOR, 1.0)
				bp["bleeding"] = "none"
			if bp.get("poisoned", false):
				if int(team.resources.get("medicine", 0)) >= 3:
					team.resources["medicine"] = int(team.resources["medicine"]) - 3
				elif randf() < best_med * 0.5:
					pass
				else:
					for p2 in p.body_parts:
						p.body_parts[p2]["hp"] = maxf(
							p.body_parts[p2]["hp"] - RESOLVE_POISON_HP, 1.0)
						p.body_parts[p2]["status"] = _calc_status(
							p.body_parts[p2]["hp"], p.body_parts[p2]["max_hp"], p2)
				bp["poisoned"] = false
			if bp.get("fracture", false):
				if int(team.resources.get("tools", 0)) >= 1:
					team.resources["tools"] = int(team.resources["tools"]) - 1
					bp["fracture"] = false

static func resolve_anon_units(state: WorldState, team_id: int) -> void:
	var team: TeamData = state.teams.get(team_id)
	var anon_units: Array = []
	for u in state.encounter_units:
		if u["team_id"] == team_id and u.get("person_id", -1) == -1:
			anon_units.append(u)
	for unit in anon_units:
		var bp: Dictionary = unit.get("body_parts", {})
		for part in bp:
			if bp[part].get("poisoned", false):
				bp[part]["hp"] = maxf(bp[part]["hp"] - RESOLVE_POISON_HP, 1.0)
				bp[part]["status"] = _calc_status(
					bp[part]["hp"], bp[part].get("max_hp", 50.0), part)
				bp[part]["poisoned"] = false
		if _is_unit_dead_bp(bp):
			team.population = maxi(team.population - 1, 0)
			continue
		var has_bleed: bool = false
		var has_major: bool = false
		for part in bp:
			if bp[part].get("bleeding", "none") == "major": has_major = true
			if bp[part].get("bleeding", "none") != "none":  has_bleed = true
		if has_bleed:
			var cost: int = 2 if has_major else 1
			if int(team.resources.get("medicine", 0)) >= cost:
				team.resources["medicine"] = int(team.resources["medicine"]) - cost
			else:
				team.wounded += 1
		if bp.values().any(func(x): return x.get("fracture", false)):
			team.wounded += 1
		elif bp.values().any(func(x): return x.get("status", "healthy") != "healthy"):
			team.wounded += 1

static func _is_unit_dead_bp(bp: Dictionary) -> bool:
	return bp.get("torso", {}).get("status", "healthy") == "severed"

static func tick_natural_regen(state: WorldState) -> void:
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		if p.team_id == -1: continue
		var has_bleeding: bool = false
		for part in p.body_parts:
			if p.body_parts[part].get("bleeding", "none") != "none":
				has_bleeding = true; break
		if p.hunger >= HUNGER_BLOOD_THRESHOLD:
			p.blood = maxf(p.blood - HUNGER_BLOOD_DRAIN_PER_TICK, 0.0)   # 餓傷：流失取代再生
		elif not has_bleeding:
			p.blood = minf(p.blood + BLOOD_REGEN_PER_TICK, BLOOD_MAX)
		for part in p.body_parts:
			var bp = p.body_parts[part]
			var regen: float = HP_REGEN_FRACTURE if bp.get("fracture", false) \
							   else HP_REGEN_PER_TICK
			bp["hp"] = minf(bp["hp"] + regen, bp["max_hp"])
			bp["status"] = _calc_status(bp["hp"], bp["max_hp"], part)

# 日邊界結算：blood<=0 的 named → 死亡（通用死因：餓死/失血）。
# named 死 = named_members.erase + pop-1（沿用戰死處理模式：person 留 state.persons，team_id 不改）。
# leader 死 → leader_id=-1，交既有繼承鏈（faction_ai _promote_successor / 玩家 _handle_player_leader_death）。
# 不 null team_id：保 _get_player_team_id 找得到玩家團 → 玩家 leader 餓死走 choose_heir forced event。
# 重複結算防護：只處理仍在編制（leader 或 named_members）的人；死後脫離編制即跳過。
static func check_starvation_deaths(state: WorldState) -> void:
	var dead: Array = []
	for pid in state.persons:
		var p: PersonData = state.persons[pid]
		if p.team_id == -1: continue
		if p.blood > 0.0: continue
		var team: TeamData = state.teams.get(p.team_id)
		if team == null: continue
		if team.leader_id != pid and pid not in team.named_members: continue
		dead.append(pid)
	for pid in dead:
		var p: PersonData = state.persons[pid]
		var team: TeamData = state.teams.get(p.team_id)
		if team == null: continue
		var cause: String = "餓死" if p.hunger >= 0.7 else "失血而亡"
		print("[Death] Person%d (team%d) %s" % [pid, p.team_id, cause])
		team.named_members.erase(pid)
		team.population = maxi(team.population - 1, 1)
		if team.leader_id == pid:
			team.leader_id = -1

static func use_splint(state: WorldState, pid: int, part: String) -> bool:
	var inv: Array = state.player_state.get("inventory", [])
	for i in range(inv.size()):
		if inv[i]["grade"] == "tools" and inv[i].get("qty", 0) >= 1:
			inv[i]["qty"] -= 1
			if inv[i]["qty"] <= 0: inv.remove_at(i)
			var p: PersonData = state.persons.get(pid)
			if p and p.body_parts.has(part):
				p.body_parts[part]["fracture"] = false
			return true
	return false

static func _best_skill(state: WorldState, team: TeamData,
		skill: String) -> float:
	var best: float = 0.0
	var ids: Array  = ([team.leader_id] as Array) + team.named_members
	for pid in ids:
		var p: PersonData = state.persons.get(pid)
		if p: best = maxf(best, float(p.skills.get(skill, 0.0)))
	return best
