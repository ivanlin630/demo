class_name EquipmentSystem

const WEAPON_TYPES: Array  = ["melee_low", "melee_high", "ranged_low", "ranged_high"]
const UNITS_PER_EQUIP: int = 2

func tick_all(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		_update_equipment(state, team)
		_update_anon_ratio(state, team)

func _update_equipment(state: WorldState, team: TeamData) -> void:
	var equipped: Dictionary = { "melee_low": 0, "melee_high": 0, "ranged_low": 0, "ranged_high": 0 }
	var named_ids: Array = _get_named_ids(team)
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var wtype: String = p.equipment.get("weapon", "")
		if wtype in equipped:
			equipped[wtype] += 1

	for wtype in WEAPON_TYPES:
		var pool_key: String = "weapon_" + wtype
		var target: int = team.equip_order.get(wtype, 0)
		var current: int = equipped[wtype]
		var deficit: int = target - current

		if deficit > 0:
			var pool: int = int(team.resources.get(pool_key, 0))
			var can_equip: int = pool / UNITS_PER_EQUIP
			var to_equip: int = mini(deficit, can_equip)
			var equipped_count: int = 0
			for pid in named_ids:
				if equipped_count >= to_equip:
					break
				var p: PersonData = state.persons.get(pid)
				if p == null:
					continue
				if p.equipment.get("weapon", "") == "":
					p.equipment["weapon"] = wtype
					equipped_count += 1
			team.resources[pool_key] = pool - equipped_count * UNITS_PER_EQUIP
			if equipped_count > 0:
				print("[Equip] Team%d 裝備 %s ×%d" % [team.team_id, wtype, equipped_count])

		elif deficit < 0:
			var to_unequip: int = -deficit
			var unequipped_count: int = 0
			for pid in named_ids:
				if unequipped_count >= to_unequip:
					break
				var p: PersonData = state.persons.get(pid)
				if p == null:
					continue
				if p.equipment.get("weapon", "") == wtype:
					p.equipment["weapon"] = ""
					unequipped_count += 1
			var pool: int = int(team.resources.get(pool_key, 0))
			team.resources[pool_key] = pool + unequipped_count * UNITS_PER_EQUIP

func _update_anon_ratio(state: WorldState, team: TeamData) -> void:
	var named_ids: Array = _get_named_ids(team)
	var named_count: int = named_ids.size()
	var anon_pop: int = maxi(team.population - named_count, 0)
	if anon_pop <= 0:
		team.armed_anon_ratio = 0.0
		return
	var pool_remaining: int = 0
	for wtype in WEAPON_TYPES:
		pool_remaining += int(team.resources.get("weapon_" + wtype, 0))
	var armed_anon: int = mini(anon_pop, pool_remaining / UNITS_PER_EQUIP)
	team.armed_anon_ratio = float(armed_anon) / float(anon_pop)

func on_named_death(team: TeamData, wtype: String) -> void:
	if wtype == "":
		return
	var pool_key: String = "weapon_" + wtype
	var recovered: int = 2 if randf() < 0.5 else 0
	team.resources[pool_key] = int(team.resources.get(pool_key, 0)) + recovered

func on_anon_casualties(team: TeamData, anon_casualties: int) -> void:
	var armed_dead: int = int(float(anon_casualties) * team.armed_anon_ratio)
	var recovered_persons: int = armed_dead / 2
	var recovered_units: int   = recovered_persons * UNITS_PER_EQUIP
	if recovered_units <= 0:
		return
	var pool_total: int = _weapon_pool_total(team)
	if pool_total <= 0:
		return
	for wtype in WEAPON_TYPES:
		var pool_key: String = "weapon_" + wtype
		var cur: int = int(team.resources.get(pool_key, 0))
		if cur <= 0:
			continue
		var share: int = cur * recovered_units / pool_total
		team.resources[pool_key] = cur + share

func _weapon_pool_total(team: TeamData) -> int:
	var total: int = 0
	for wtype in WEAPON_TYPES:
		total += int(team.resources.get("weapon_" + wtype, 0))
	return total

func _get_named_ids(team: TeamData) -> Array:
	var ids: Array = team.advisors + team.members
	if team.leader_id != -1:
		ids.append(team.leader_id)
	return ids
