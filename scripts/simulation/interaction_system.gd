class_name InteractionSystem

# ──────── 貿易常數 ────────
const BASE_PRICE: Dictionary = {
	"food":              2.0,
	"material":          4.0,
	"goods":             5.0,
	"gem":              20.0,
	"ore_gold":         10.0,
	"ore_silver":        5.0,
	"ore_iron":          8.0,
	"ore_steel":        12.0,
	"weapon_melee_low":  8.0,
	"weapon_melee_high": 18.0,
	"weapon_ranged_low": 9.0,
	"weapon_ranged_high": 20.0,
}
const TARGET_PER_POP: Dictionary = {
	"food":              10.0,
	"material":           5.0,
	"goods":              3.0,
	"gem":                1.0,
	"ore_gold":           2.0,
	"ore_silver":         3.0,
	"ore_iron":           3.0,
	"ore_steel":          1.5,
	"weapon_melee_low":   1.0,
	"weapon_melee_high":  0.5,
	"weapon_ranged_low":  0.8,
	"weapon_ranged_high": 0.4,
}
const FOOD_RESERVE_TICKS: float = 20.0   # TEST VALUE — food 最低自留（pop × 0.1 × N ticks）
const MAX_COIN_PER_TRADE: float = 300.0  # TEST VALUE — 每次交易買方預算上限

const ROUND_CASUALTY_RATE: float    = 0.1
const WOUNDED_TREATMENT_RATE: float = 0.3
const TRIBUTE_RATE: float           = 0.25
const LOOT_RATE: float              = 0.3
const COMBAT_THRESHOLD: float       = 0.7
const COMBAT_ABANDON_THRESHOLD: float = 0.2
const ROUND_READINESS_DRAIN: float  = 0.08
const READINESS_RECOVERY_BASE: float = 0.04
const READINESS_FOOD_COST: float    = 0.05
const VOLLEY_CASUALTY_RATE: float     = 0.05
const PURSUIT_RATE: float             = 0.05
const FLANKING_MULT: float            = 1.3
const MORALE_CASCADE_THRESHOLD: float = 0.3

const HIT_WEIGHTS: Dictionary = {
	"head": 0.10, "torso": 0.40,
	"right_arm": 0.10, "left_arm": 0.10,
	"right_leg": 0.15, "left_leg": 0.15,
}
const STATUS_ORDER: Array = ["healthy", "wounded", "critical", "severed"]
const CRITICAL_DEATH_CHANCE_BASE: float = 0.10
const CRITICAL_RECOVER_CHANCE_BASE: float = 0.40

var _msg: SimMessageSystem
var _vision: VisionSystem
var _equip: EquipmentSystem
var _skill_sys: SkillSystem

func _init() -> void:
	_msg    = SimMessageSystem.new()
	_vision = VisionSystem.new()
	_equip = EquipmentSystem.new()
	_skill_sys = load("res://scripts/simulation/skill_system.gd").new()

# ──────── 主入口 ────────

func process_on_arrival(state: WorldState, arrived_ids: Array, all_team_ids: Array) -> void:
	_tick_readiness(state, all_team_ids)
	_tick_critical_npcs(state, all_team_ids)
	_process_ongoing_combat(state, all_team_ids)
	var _sub := SubteamSystem.new()
	for arrived_id in arrived_ids:
		if not state.teams.has(arrived_id):
			continue
		if _sub.try_merge_back(state, arrived_id):
			continue
		var arrived: TeamData = state.teams[arrived_id]
		if arrived.current_task == "護衛":
			continue
		for other_id in state.teams:
			if other_id == arrived_id:
				continue
			var other: TeamData = state.teams[other_id]
			if other.tile_pos != arrived.tile_pos:
				continue
			_try_interact(state, arrived_id, other_id)
	HealthSystem.tick_natural_regen(state)

# ──────── 整備值恢復 + 傷兵治療（交戰中均不進行） ────────

func _tick_readiness(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		if team.combat_target != -1:
			continue
		if team.wounded > 0:
			_treat_wounded(state, team)
		if team.readiness >= 1.0:
			continue
		var deficit: float = 1.0 - team.readiness
		var morale_factor: float = 1.0 - clampf(float(team.unrest_turns) / 30.0, 0.0, 1.0)
		var food_needed: float  = deficit * float(team.population) * READINESS_FOOD_COST
		var food_avail: float   = float(team.resources.get("food", 0))
		var food_used: float    = minf(food_needed, food_avail)
		team.resources["food"]  = food_avail - food_used
		var resource_factor: float = 0.3 + 0.7 * (food_used / maxf(food_needed, 0.001))
		var leader = state.persons.get(team.leader_id)
		var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
		var excess: float = clampf((cmd - 0.8) / 0.2, 0.0, 1.0)
		var recovery: float = READINESS_RECOVERY_BASE * (1.0 + excess * 0.5)
		team.readiness = minf(team.readiness + recovery * morale_factor * resource_factor, 1.0)

func _treat_wounded(state: WorldState, team: TeamData) -> void:
	var best_medicine: float = 0.0
	var named_ids: Array = team.named_members
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p != null:
			best_medicine = maxf(best_medicine, float(p.skills.get("醫療", 0.0)))
	var food_per_person: float = float(team.resources.get("food", 0)) / maxf(team.population, 1)
	var resource_factor: float = clampf(food_per_person / 2.0, 0.3, 1.0)
	var to_treat: int = mini(maxi(1, int(round(team.wounded * WOUNDED_TREATMENT_RATE))), team.wounded)
	var save_rate: float = (0.4 + best_medicine * 0.5) * resource_factor
	var saved: int = int(round(float(to_treat) * save_rate))
	var died: int  = to_treat - saved
	team.wounded   -= to_treat
	team.population = maxi(team.population - died, 1)
	if died > 0:
		print("[Treat] Team%d 治療 %d 傷兵：救 %d 死 %d (medicine=%.2f)" % [
			team.team_id, to_treat, saved, died, best_medicine])

# ──────── 持續戰鬥結算 ────────

func _process_ongoing_combat(state: WorldState, all_team_ids: Array) -> void:
	var processed: Dictionary = {}
	for tid in all_team_ids:
		if processed.has(tid) or not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var enemy_id: int = team.combat_target
		if enemy_id == -1 or not state.teams.has(enemy_id):
			if enemy_id != -1:
				team.combat_target = -1
			continue
		var enemy: TeamData = state.teams[enemy_id]
		if enemy.combat_target != tid:
			team.combat_target = -1
			continue
		processed[tid]      = true
		processed[enemy_id] = true
		_resolve_combat_round(state, tid, enemy_id)

# ──────── 新互動判斷 ────────

func _try_interact(state: WorldState, id_a: int, id_b: int) -> void:
	_vision.reveal_encounter(state, id_a, id_b)
	_write_tier2_intel(state, id_a, id_b)
	_write_tier2_intel(state, id_b, id_a)
	if state.player_id != -1:
		var player_person: PersonData = state.persons.get(state.player_id)
		if player_person != null:
			var player_team_id: int = player_person.team_id
			var is_a_player: bool = (id_a == player_team_id)
			var is_b_player: bool = (id_b == player_team_id)
			if is_a_player or is_b_player:
				var npc_id: int      = id_b if is_a_player else id_a
				var npc: TeamData    = state.teams.get(npc_id)
				var pt: TeamData     = state.teams.get(player_team_id)
				if npc == null or pt == null:
					return

				# 路徑 1：NPC 攻擊玩家 → 直接 EncounterSystem（維持原有邏輯）
				if npc.combat_target == player_team_id:
					state.encounter_attacker_id = npc_id
					state.encounter_defender_id = player_team_id
					state.encounter_active      = true
					if not state.player_hostile_teams.has(npc_id):
						state.player_hostile_teams.append(npc_id)
					print("[Encounter] 玩家遭遇戰觸發 Team%d vs Team%d" % [npc_id, player_team_id])
					return

				# 同陣營：不 return，讓後面 NPC-NPC 邏輯處理（徵收/合併等）
				var same_faction: bool = pt.faction_id != -1 \
					and pt.faction_id == npc.faction_id
				if same_faction:
					pass   # 繼續執行到 NPC-NPC 邏輯
				# 路徑 2：NPC 外交提案
				elif npc.current_task == TeamData.TASK_DIPLOMACY:
					if state.player_forced_event.is_empty():   # 不覆蓋現有強制事件
						state.player_forced_event = {
							"from_id":  npc_id,
							"action":   "diplomacy",
							"proposal": npc.order_task if npc.order_task != "" else "alliance"
						}
						state.player_forced_event_id = str(randi()) + "_" + str(randi())
					return
				# 路徑 3：NPC 勒索
				elif npc.current_task == TeamData.TASK_LOOT:
					if state.player_forced_event.is_empty():
						state.player_forced_event = { "from_id": npc_id, "action": "extort" }
						state.player_forced_event_id = str(randi()) + "_" + str(randi())
					return
				# 路徑 4：NPC 無敵意 → 玩家可主動選擇互動
				else:
					if not state.player_pending_targets.has(npc_id):
						state.player_pending_targets.append(npc_id)
					return
	var a: TeamData = state.teams[id_a]
	var b: TeamData = state.teams[id_b]
	if a.combat_target != -1 or b.combat_target != -1:
		return
	# 貿易：跨勢力均可，優先於外交/攻擊判斷
	if a.current_task == TeamData.TASK_TRADE:
		_resolve_trade(state, a, b)
		return
	if b.current_task == TeamData.TASK_TRADE:
		_resolve_trade(state, b, a)
		return
	var same_faction: bool = a.faction_id != -1 and a.faction_id == b.faction_id
	if same_faction:
		if a.current_task == "徵收":
			_resolve_tribute(state, id_a, id_b)
		elif b.current_task == "徵收":
			_resolve_tribute(state, id_b, id_a)
		elif a.current_task == "信使" and a.order_target_id == id_b:
			_deliver_order(state, id_a, id_b)
		elif b.current_task == "信使" and b.order_target_id == id_a:
			_deliver_order(state, id_b, id_a)
		elif a.current_task == "idle" and b.current_task == "idle":
			var absorber: int = id_a if a.population >= b.population else id_b
			var absorbed: int = id_b if absorber == id_a else id_a
			var abs_team: TeamData = state.teams[absorbed]
			var all_npcs: Array = []
			if abs_team.leader_id != -1: all_npcs.append(abs_team.leader_id)
			all_npcs.append_array(abs_team.named_members)
			SubteamSystem.new().merge_teams(state, absorber, absorbed, all_npcs)
		elif (a.current_task == TeamData.TASK_MERGE and a.order_target_id == id_b) \
				or (b.current_task == TeamData.TASK_MERGE and b.order_target_id == id_a):
			_try_merge(state, id_a, id_b)
		return
	if a.current_task == "外交":
		_try_diplomacy(state, id_a, id_b)
		return
	if b.current_task == "外交":
		_try_diplomacy(state, id_b, id_a)
		return
	if a.current_task == "攻擊":
		_start_combat(state, id_a, id_b)
	elif b.current_task == "攻擊":
		_start_combat(state, id_b, id_a)
	elif a.current_task == "掠奪" and a.readiness >= COMBAT_THRESHOLD:
		if _should_pay_tribute(state, id_b, id_a):
			_resolve_extortion(state, id_a, id_b)
		elif _should_attack(state, id_a, id_b):
			_start_combat(state, id_a, id_b)
	elif b.current_task == "掠奪" and b.readiness >= COMBAT_THRESHOLD:
		if _should_pay_tribute(state, id_a, id_b):
			_resolve_extortion(state, id_b, id_a)
		elif _should_attack(state, id_b, id_a):
			_start_combat(state, id_b, id_a)

# ──────── 決策函式 ────────

func _should_pay_tribute(state: WorldState, def_id: int, atk_id: int) -> bool:
	var def: TeamData = state.teams[def_id]
	if def.current_task == "逃跑":
		return true
	var leader: PersonData = state.persons.get(def.leader_id)
	if leader == null:
		return false
	var survival: float = float(leader.values.get("求生欲", 0.5))
	var caution: float  = float(leader.values.get("慎重", 0.5))
	var honor: float    = float(leader.values.get("義氣", 0.5))
	var weakness: float = _team_strength(state, def_id) / maxf(_team_strength(state, atk_id), 0.01)
	var score: float    = survival * 0.4 + caution * 0.3 - honor * 0.3 + (1.0 - weakness) * 0.3
	return score > 0.4

func _should_attack(state: WorldState, atk_id: int, def_id: int) -> bool:
	var atk: TeamData = state.teams[atk_id]
	var leader: PersonData = state.persons.get(atk.leader_id)
	if leader == null:
		return false
	var ambition: float  = float(leader.values.get("野心", 0.5))
	var caution: float   = float(leader.values.get("慎重", 0.5))
	var greed: float     = float(leader.values.get("貪婪", 0.5))
	var martial: float   = float(leader.values.get("好戰", 0.5))
	var str_ratio: float = _team_strength(state, atk_id) / maxf(_team_strength(state, def_id), 0.01)
	var score: float     = ambition * 0.3 + martial * 0.3 + greed * 0.2 + (str_ratio - 1.0) * 0.2 - caution * 0.5
	return score > 0.0

# ──────── 結算函式 ────────

func _start_combat(state: WorldState, atk_id: int, def_id: int) -> void:
	var atk: TeamData = state.teams[atk_id]
	var def: TeamData = state.teams[def_id]
	atk.combat_target = def_id
	def.combat_target = atk_id
	_msg.emit_message(state, "combat_start",
		"Team %d 對 Team %d 宣戰" % [atk_id, def_id], atk)
	print("[Combat Start] Team%d vs Team%d" % [atk_id, def_id])
	_resolve_volley(state, atk_id, def_id)

func _resolve_volley(state: WorldState, id_a: int, id_b: int) -> void:
	var volley_a: float = _ranged_strength(state, id_a)
	var volley_b: float = _ranged_strength(state, id_b)
	var total: float = volley_a + volley_b
	if total <= 0.0:
		return
	var a: TeamData = state.teams[id_a]
	var b: TeamData = state.teams[id_b]
	var eff_a: int  = maxi(a.population - a.wounded, 1)
	var eff_b: int  = maxi(b.population - b.wounded, 1)
	var loss_a: int = maxi(int(float(eff_a) * volley_b / total * VOLLEY_CASUALTY_RATE), 0)
	var loss_b: int = maxi(int(float(eff_b) * volley_a / total * VOLLEY_CASUALTY_RATE), 0)
	_apply_casualties(state, id_a, loss_a)
	_apply_casualties(state, id_b, loss_b)
	print("[Volley] Team%d→%d  Team%d→%d" % [id_a, loss_a, id_b, loss_b])
	_skill_sys.on_volley(state, state.teams[id_a])
	_skill_sys.on_volley(state, state.teams[id_b])

func _resolve_combat_round(state: WorldState, id_a: int, id_b: int) -> void:
	var a: TeamData  = state.teams[id_a]
	var b: TeamData  = state.teams[id_b]

	var terrain_b: float = _terrain_defense_mult(state, b)
	var terrain_a: float = _terrain_defense_mult(state, a)

	var str_a: float = _team_strength(state, id_a) * a.readiness
	var str_b: float = _team_strength(state, id_b) * b.readiness * terrain_b
	var total: float = str_a + str_b
	var eff_a: int   = maxi(a.population - a.wounded, 1)
	var eff_b: int   = maxi(b.population - b.wounded, 1)

	var loss_a: int = max(int(round(eff_a * str_b / total * ROUND_CASUALTY_RATE)), 0)
	var loss_b: int = max(int(round(eff_b * str_a / total * ROUND_CASUALTY_RATE)), 0)

	if eff_a >= eff_b * 3:
		var tactics_b: float = 0.0
		var leader_b: PersonData = state.persons.get(b.leader_id)
		if leader_b != null:
			tactics_b = float(leader_b.skills.get("戰術", 0.0))
		var flank_mult: float = FLANKING_MULT - tactics_b * 0.3
		loss_b = int(round(float(loss_b) * flank_mult))
	if eff_b >= eff_a * 3:
		var tactics_a: float = 0.0
		var leader_a: PersonData = state.persons.get(a.leader_id)
		if leader_a != null:
			tactics_a = float(leader_a.skills.get("戰術", 0.0))
		var flank_mult: float = FLANKING_MULT - tactics_a * 0.3
		loss_a = int(round(float(loss_a) * flank_mult))

	_apply_casualties(state, id_a, loss_a)
	_apply_casualties(state, id_b, loss_b)

	var wnd_ratio_a: float = float(a.wounded) / float(maxi(a.population, 1))
	var wnd_ratio_b: float = float(b.wounded) / float(maxi(b.population, 1))
	var drain_a: float = ROUND_READINESS_DRAIN * (2.0 if wnd_ratio_a > MORALE_CASCADE_THRESHOLD else 1.0)
	var drain_b: float = ROUND_READINESS_DRAIN * (2.0 if wnd_ratio_b > MORALE_CASCADE_THRESHOLD else 1.0)
	a.readiness = maxf(a.readiness - drain_a, 0.0)
	b.readiness = maxf(b.readiness - drain_b, 0.0)

	print("[Round] Team%d(rd=%.2f,terrain=%.2f) vs Team%d(rd=%.2f,terrain=%.2f)  wnd+%d/%d  eff=%d/%d" % [
		id_a, a.readiness, terrain_a, id_b, b.readiness, terrain_b, loss_a, loss_b,
		maxi(a.population - a.wounded, 1), maxi(b.population - b.wounded, 1)])

	if maxi(a.population - a.wounded, 1) <= 1:
		_end_combat(state, id_b, id_a)
		return
	if maxi(b.population - b.wounded, 1) <= 1:
		_end_combat(state, id_a, id_b)
		return
	if a.readiness <= COMBAT_ABANDON_THRESHOLD:
		_force_retreat(state, id_a, id_b)
		return
	if b.readiness <= COMBAT_ABANDON_THRESHOLD:
		_force_retreat(state, id_b, id_a)
		return
	_skill_sys.on_combat_round(state, a)
	_skill_sys.on_combat_round(state, b)
	_try_retreat(state, id_a, id_b)
	if a.combat_target != -1:
		_try_retreat(state, id_b, id_a)

func _end_combat(state: WorldState, winner_id: int, loser_id: int) -> void:
	var winner: TeamData = state.teams[winner_id]
	var loser: TeamData  = state.teams[loser_id]
	winner.combat_target = -1
	loser.combat_target  = -1
	var winner_p = state.persons.get(winner.leader_id)
	var cruelty: float = float(winner_p.values.get("殘忍", 0.5)) if winner_p else 0.5
	var effective_loot: float = LOOT_RATE * (1.0 + cruelty * 0.7)
	for res in ["food", "material", "coin", "goods",
				"weapon_melee_low", "weapon_melee_high",
				"weapon_ranged_low", "weapon_ranged_high"]:
		var taken: float = float(loser.resources.get(res, 0)) * effective_loot
		winner.resources[res] = float(winner.resources.get(res, 0)) + taken
		loser.resources[res]  = float(loser.resources.get(res, 0)) - taken
	# 戰敗 looted 記憶：敗方全員記住勝方 leader
	var _npc_ai_loot := NpcAiSystem.new()
	for pid in ([loser.leader_id] as Array) + loser.named_members:
		var vp: PersonData = state.persons.get(pid)
		if vp:
			_npc_ai_loot.write_memory(vp, "looted", winner.leader_id,
				state.world.current_tick, 0.7)
	# 勝方 aided_in_battle 記憶：支援護衛 team 全員
	var _npc_ai_aid := NpcAiSystem.new()
	for escort_id in state.teams:
		var escort: TeamData = state.teams[escort_id]
		if escort.current_task == "護衛" and escort.order_target_id == winner_id \
				and escort.tile_pos == winner.tile_pos:
			for pid in ([winner.leader_id] as Array) + winner.named_members:
				var sp: PersonData = state.persons.get(pid)
				if sp:
					_npc_ai_aid.write_memory(sp, "aided_in_battle", escort.leader_id,
						state.world.current_tick, 0.5)
	if cruelty > 0.6:
		var worsen_chance: float = (cruelty - 0.6) * 0.5
		for pid in state.persons:
			var p: PersonData = state.persons[pid]
			if p.team_id != loser_id: continue
			for part in p.body_parts:
				if p.body_parts[part]["status"] == "wounded" and randf() < worsen_chance:
					p.body_parts[part]["status"] = "critical"
	# loot 結算後，全 named_members loyalty 懲罰（依義氣）
	for pid in winner.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var yi_qi: float = float(p.values.get("義氣", 0.5))
		p.loyalty -= (1.0 - yi_qi) * 0.05
	_msg.emit_message(state, "combat_end",
		"Team %d 擊潰 Team %d" % [winner_id, loser_id], winner)
	print("[Combat End] Team%d 勝 Team%d (rd=%.2f/%.2f wnd=%d/%d)" % [
		winner_id, loser_id, winner.readiness, loser.readiness,
		winner.wounded, loser.wounded])
	var _tile_id: int = winner.tile_pos.x * 1000 + winner.tile_pos.y
	var _tile: HexTileData = state.world.tiles.get(_tile_id)
	if _tile != null:
		OutpostSystem.new().capture(state, winner_id, _tile)
	_skill_sys.on_combat_end(state, winner)
	_skill_sys.on_combat_end(state, loser)
	_apply_pursuit(state, winner_id, loser_id)
	var _pp_end: PersonData = state.persons.get(state.player_id)
	var _ptid_end: int = _pp_end.team_id if _pp_end else -1
	if _ptid_end == -1 or winner_id != _ptid_end:
		_try_subjugate(state, winner_id, loser_id)

func _force_retreat(state: WorldState, retreater_id: int, pursuer_id: int) -> void:
	var retreater: TeamData = state.teams[retreater_id]
	var pursuer: TeamData   = state.teams[pursuer_id]
	retreater.combat_target = -1
	pursuer.combat_target   = -1
	print("[Exhaust] Team%d 力竭撤退 (rd=%.2f wnd=%d)" % [
		retreater_id, retreater.readiness, retreater.wounded])
	var _tile_id: int = pursuer.tile_pos.x * 1000 + pursuer.tile_pos.y
	var _tile: HexTileData = state.world.tiles.get(_tile_id)
	if _tile != null:
		OutpostSystem.new().capture(state, pursuer_id, _tile)
	_skill_sys.on_combat_end(state, retreater)
	_skill_sys.on_combat_end(state, pursuer)
	_apply_pursuit(state, pursuer_id, retreater_id)
	var _pp_fr: PersonData = state.persons.get(state.player_id)
	var _ptid_fr: int = _pp_fr.team_id if _pp_fr else -1
	if _ptid_fr == -1 or pursuer_id != _ptid_fr:
		_try_subjugate(state, pursuer_id, retreater_id)

func _apply_pursuit(state: WorldState, winner_id: int, loser_id: int) -> void:
	if not state.teams.has(winner_id) or not state.teams.has(loser_id):
		return
	var winner: TeamData = state.teams[winner_id]
	var loser:  TeamData = state.teams[loser_id]
	if winner.population < loser.population * 2:
		return
	var pursuit_loss: int = maxi(int(float(loser.population) * PURSUIT_RATE), 0)
	if pursuit_loss <= 0:
		return
	_apply_casualties(state, loser_id, pursuit_loss)
	print("[Pursuit] Team%d 追擊 Team%d +%d傷亡" % [winner_id, loser_id, pursuit_loss])

func _resolve_extortion(state: WorldState, atk_id: int, def_id: int) -> Dictionary:
	var atk: TeamData = state.teams[atk_id]
	var def: TeamData = state.teams[def_id]
	var gained: Dictionary = {}
	for res in ["food", "material", "goods", "coin"]:
		var tribute: float = float(def.resources.get(res, 0)) * TRIBUTE_RATE
		if tribute > 0.0:
			atk.resources[res] = float(atk.resources.get(res, 0)) + tribute
			def.resources[res] = float(def.resources.get(res, 0)) - tribute
			gained[res] = tribute
	_msg.emit_message(state, "extortion",
		"Team %d 向 Team %d 收過路費" % [atk_id, def_id], atk)
	print("[Extort] Team%d 勒索 Team%d，Team%d 妥協給付" % [atk_id, def_id, def_id])
	return gained

func _try_retreat(state: WorldState, team_id: int, enemy_id: int) -> void:
	var team: TeamData = state.teams[team_id]
	if team.combat_target == -1 or team.current_task != "逃跑":
		return
	var leader: PersonData = state.persons.get(team.leader_id)
	var survival: float = 0.5
	if leader != null:
		survival = float(leader.values.get("求生欲", 0.5))
	var str_ratio: float = _team_strength(state, team_id) / maxf(_team_strength(state, enemy_id), 0.01)
	var retreat_chance: float = survival * 0.5 + (1.0 - minf(str_ratio, 1.0)) * 0.3
	if randf() < retreat_chance:
		var enemy: TeamData = state.teams[enemy_id]
		team.combat_target  = -1
		enemy.combat_target = -1
		print("[Retreat] Team%d 成功撤退 (rd=%.2f wnd=%d)" % [team_id, team.readiness, team.wounded])

func _team_strength(state: WorldState, team_id: int) -> float:
	var base: float = _strength_raw(state, team_id)
	var team: TeamData = state.teams.get(team_id)
	if team == null:
		return base
	for tid in state.teams:
		if tid == team_id:
			continue
		var t: TeamData = state.teams[tid]
		if t.current_task == "護衛" and t.order_target_id == team_id \
				and t.tile_pos == team.tile_pos:
			base += _strength_raw(state, tid)
	return base

func _terrain_defense_mult(state: WorldState, team: TeamData) -> float:
	var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
	var tile: HexTileData = state.world.tiles.get(tile_id)
	if tile == null:
		return 1.0
	match tile.terrain:
		"forest":   return 1.2
		"mountain": return 1.15
	return 1.0

func _strength_raw(state: WorldState, team_id: int) -> float:
	var team: TeamData = state.teams.get(team_id)
	if team == null:
		return 0.0
	var leader: PersonData = state.persons.get(team.leader_id)

	var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
	var excess: float = clampf((cmd - 0.8) / 0.2, 0.0, 1.0)
	var leadership_mult: float = 1.0 + excess * 0.5

	var tactics: float = float(leader.skills.get("戰術", 0.0)) if leader else 0.0
	var tactics_mult: float = 1.0 + tactics * 0.3

	var melee_str:  float = 0.0
	var ranged_str: float = 0.0
	var named_ids: Array = ([team.leader_id] as Array) + team.named_members
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var grade: String = p.equipment["hand_1"].get("grade", "")
		var wtype: String = grade.replace("weapon_", "") if grade.begins_with("weapon_") else "none"
		match wtype:
			"melee_low":
				melee_str  += (0.5 + float(p.skills.get("戰鬥", 0.0)) * 0.5) * 0.8
			"melee_high":
				melee_str  += (0.5 + float(p.skills.get("戰鬥", 0.0)) * 0.5) * 1.2
			"ranged_low":
				ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 0.8
			"ranged_high":
				ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 1.2
			_:
				melee_str  += 0.3

	var named_count: int = named_ids.size()
	var anon_pop: int    = maxi(team.population - team.wounded - named_count, 0)
	melee_str += float(anon_pop) * team.armed_anon_ratio * 0.5

	return (melee_str + ranged_str) * leadership_mult * tactics_mult

func _ranged_strength(state: WorldState, team_id: int) -> float:
	var team: TeamData = state.teams.get(team_id)
	if team == null:
		return 0.0
	var ranged_str: float = 0.0
	var named_ids: Array = ([team.leader_id] as Array) + team.named_members
	for pid in named_ids:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var grade: String = p.equipment["hand_1"].get("grade", "")
		var wtype: String = grade.replace("weapon_", "") if grade.begins_with("weapon_") else "none"
		match wtype:
			"ranged_low":
				ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 0.8
			"ranged_high":
				ranged_str += (0.5 + float(p.skills.get("弓箭", 0.0)) * 0.5) * 1.2
	return ranged_str

# ──────── 傷亡分配 ────────

func _apply_casualties(state: WorldState, team_id: int, count: int) -> void:
	if count <= 0:
		return
	var team: TeamData = state.teams[team_id]
	var named_ids: Array = team.named_members
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	for i in range(count):
		if not named_ids.is_empty() and randf() < float(named_ids.size()) / maxf(float(team.population), 1.0):
			var idx: int = randi() % named_ids.size()
			var pid: int = named_ids[idx]
			var p = state.persons.get(pid)
			if p != null:
				_hit_person(state, team_id, p)
		else:
			team.wounded += 1
	_equip.on_anon_casualties(team, count)

func _hit_person(state: WorldState, team_id: int, p) -> void:
	var part: String = _random_part()
	var cur_idx: int = STATUS_ORDER.find(p.body_parts[part]["status"])
	if cur_idx < 0:
		return
	var vital: bool = part == "head" or part == "torso"
	if cur_idx >= STATUS_ORDER.size() - 1:
		if vital:
			_kill_named_npc(state, team_id, p)
		return
	var new_status: String = STATUS_ORDER[cur_idx + 1]
	p.body_parts[part]["status"] = new_status
	print("[Hit] Person%d %s: %s → %s" % [p.id, part, STATUS_ORDER[cur_idx], new_status])
	if vital and new_status == "critical":
		print("[Critical] Person%d %s 瀕死" % [p.id, part])
	elif not vital and new_status == "severed":
		_kill_named_npc(state, team_id, p)

func _random_part() -> String:
	var roll: float = randf()
	var acc: float = 0.0
	for part in HIT_WEIGHTS:
		acc += HIT_WEIGHTS[part]
		if roll < acc:
			return part
	return "torso"

# ──────── Critical NPC 每 Tick 判定 ────────

func _tick_critical_npcs(state: WorldState, all_team_ids: Array) -> void:
	for tid in all_team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var medicine: float = _best_medicine(state, team)
		var named_ids: Array = team.named_members
		if team.leader_id != -1:
			named_ids.append(team.leader_id)
		for pid in named_ids:
			var p = state.persons.get(pid)
			if p == null:
				continue
			var has_critical: bool = false
			for part in ["head", "torso"]:
				if p.body_parts[part]["status"] == "critical":
					has_critical = true
					break
			if not has_critical:
				continue
			var death_chance: float = CRITICAL_DEATH_CHANCE_BASE * (1.0 - medicine * 0.5)
			if randf() < death_chance:
				_kill_named_npc(state, tid, p)
				continue
			var recover_chance: float = CRITICAL_RECOVER_CHANCE_BASE * medicine
			if randf() < recover_chance:
				for part in ["head", "torso"]:
					if p.body_parts[part]["status"] == "critical":
						p.body_parts[part]["status"] = "wounded"
						print("[Recover] Person%d %s: critical → wounded" % [p.id, part])

func _kill_named_npc(state: WorldState, team_id: int, p) -> void:
	var team: TeamData = state.teams[team_id]
	print("[Death] Person%d (%s) 死亡 (Team%d)" % [p.id, p.person_name, team_id])
	if team.leader_id == p.id:
		var event_system = load("res://scripts/simulation/event_system.gd").new()
		var succeeded: bool = event_system.on_leader_death(state, team)
		if not succeeded and team.faction_id != -1 and state.factions.has(team.faction_id):
			var f = state.factions[team.faction_id]
			if f.leader_team_id == team.team_id:
				state.disband_faction(team.faction_id)
	team.named_members.erase(p.id)
	if team.leader_id == p.id:
		team.leader_id = -1
	team.population = maxi(team.population - 1, 1)
	var _death_grade: String = p.equipment["hand_1"].get("grade", "")
	var _death_wtype: String = _death_grade.replace("weapon_", "") if _death_grade.begins_with("weapon_") else "none"
	_equip.on_named_death(team, _death_wtype)
	p.equipment["hand_1"] = { "type": "none", "grade": "" }
	state.persons.erase(p.id)

# ──────── 勢力互動 ────────

func subjugate_team(state: WorldState, winner_id: int, loser_id: int) -> void:
	_try_subjugate(state, winner_id, loser_id)

func _try_subjugate(state: WorldState, winner_id: int, loser_id: int) -> void:
	var winner: TeamData = state.teams[winner_id]
	var loser:  TeamData = state.teams[loser_id]
	if loser.faction_id != -1 or not winner.tags.has("統領"):
		return
	var fid: int = winner.faction_id
	if fid == -1:
		fid = state.create_faction(winner_id)
	else:
		state.factions[fid].member_team_ids.append(loser_id)
	loser.faction_id = fid
	state.snapshot_faction_member(loser_id, state.world.current_tick)
	_msg.emit_message(state, "subjugate",
		"Team%d 主服 Team%d，加入勢力%d" % [winner_id, loser_id, fid], winner)
	print("[Faction] Team%d 主服 Team%d → 勢力%d" % [winner_id, loser_id, fid])

func _try_diplomacy(state: WorldState, initiator_id: int, target_id: int) -> void:
	var initiator: TeamData = state.teams[initiator_id]
	var target: TeamData    = state.teams[target_id]
	if initiator.faction_id != -1 and initiator.faction_id == target.faction_id:
		return
	var target_leader = state.persons.get(target.leader_id)
	if target_leader == null:
		return
	var honor: float     = float(target_leader.values.get("義氣",  0.5))
	var trust: float     = float(target_leader.values.get("信義", 0.5))
	var str_init: float  = _team_strength(state, initiator_id)
	var str_tgt: float   = _team_strength(state, target_id)
	var str_ratio: float = str_init / maxf(str_tgt, 0.01)
	var accept: float    = honor * 0.5 + trust * 0.3 + maxf(str_ratio - 1.0, 0.0) * 0.2
	if accept < 0.35:
		return
	# initiator 已有勢力 → 直接招募 target；否則以強者為 leader 建新勢力
	var fid: int = initiator.faction_id
	if fid == -1:
		var strong_id: int = initiator_id if str_init >= str_tgt else target_id
		fid = state.create_faction(strong_id)
	if not state.factions[fid].member_team_ids.has(target_id):
		state.factions[fid].member_team_ids.append(target_id)
	target.faction_id = fid
	state.snapshot_faction_member(target_id, state.world.current_tick)
	initiator.current_task = "idle"
	_msg.emit_message(state, "diplomacy",
		"Team%d 外交 → Team%d 加入勢力%d" % [initiator_id, target_id, fid], initiator)
	print("[Faction] Team%d 外交 Team%d → 勢力%d" % [initiator_id, target_id, fid])

func _try_merge(state: WorldState, id_a: int, id_b: int) -> void:
	var a: TeamData = state.teams[id_a]
	var b: TeamData = state.teams[id_b]
	var merger_id: int = id_a if a.current_task == TeamData.TASK_MERGE else id_b
	var target_id: int = id_b if merger_id == id_a else id_a
	var merger: TeamData = state.teams[merger_id]
	if merger.order_target_id != target_id:
		return
	var absorbed_team: TeamData = state.teams[target_id]
	var all_npcs: Array = []
	if absorbed_team.leader_id != -1: all_npcs.append(absorbed_team.leader_id)
	all_npcs.append_array(absorbed_team.named_members)
	SubteamSystem.new().merge_teams(state, merger_id, target_id, all_npcs)
	merger.current_task = TeamData.TASK_IDLE
	merger.order_target_id = -1

func _resolve_tribute(state: WorldState, collector_id: int, payer_id: int) -> void:
	var collector: TeamData = state.teams[collector_id]
	var payer:     TeamData = state.teams[payer_id]
	var f = state.factions.get(collector.faction_id)
	if f == null or f.leader_team_id != collector_id:
		return
	if not f.member_team_ids.has(payer_id):
		return
	var payer_p = state.persons.get(payer.leader_id)
	var base_rate: float = f.tribute_rate
	if payer_p != null:
		base_rate += (float(payer_p.values.get("義氣",  0.5)) - 0.5) * 0.1
		base_rate += (float(payer_p.values.get("信義", 0.5)) - 0.5) * 0.1
		base_rate -= float(payer_p.values.get("貪婪", 0.5)) * 0.1
		base_rate -= float(payer_p.skills.get("商業", 0.0)) * 0.05
	var str_ratio: float = _team_strength(state, payer_id) / maxf(_team_strength(state, collector_id), 0.01)
	if str_ratio > 1.2:
		base_rate *= maxf(1.0 - (str_ratio - 1.0) * 0.5, 0.0)
	base_rate = clampf(base_rate, 0.0, 0.5)
	for res in ["food", "goods", "coin"]:
		var amount: float = float(payer.resources.get(res, 0)) * base_rate
		if amount <= 0.0:
			continue
		payer.resources[res]     = float(payer.resources.get(res, 0)) - amount
		collector.resources[res] = float(collector.resources.get(res, 0)) + amount
	collector.current_task = "idle"
	collector.move_target  = Vector2i(-1, -1)
	_msg.emit_message(state, "tribute",
		"Team%d 向 Team%d 徵收（rate=%.2f）" % [collector_id, payer_id, base_rate], collector)
	print("[Tribute] Team%d 徵收 Team%d rate=%.2f" % [collector_id, payer_id, base_rate])

func _deliver_order(state: WorldState, messenger_id: int, target_id: int) -> void:
	var messenger: TeamData = state.teams[messenger_id]
	var target: TeamData    = state.teams[target_id]
	var order: String = messenger.order_task if messenger.order_task != "" else "idle"
	target.current_task       = order
	messenger.current_task    = "idle"
	messenger.order_target_id = -1
	messenger.order_task      = ""
	var parent: TeamData = state.teams.get(messenger.parent_team_id)
	if parent != null:
		messenger.move_target = parent.tile_pos
	# T-02 快照A：信使抵達 = 情報傳遞，更新 messenger 母隊在 faction 中的快照
	if messenger.parent_team_id != -1:
		state.snapshot_faction_member(messenger.parent_team_id, state.world.current_tick)
	_msg.emit_message(state, "order_delivered",
		"Team%d 傳令 Team%d → task=%s" % [messenger_id, target_id, order], messenger)
	print("[Order] Team%d 傳令 Team%d → %s" % [messenger_id, target_id, order])

func _best_medicine(state: WorldState, team: TeamData) -> float:
	var best: float = 0.0
	var named_ids: Array = team.named_members
	if team.leader_id != -1:
		named_ids.append(team.leader_id)
	for pid in named_ids:
		var p = state.persons.get(pid)
		if p != null:
			best = maxf(best, float(p.skills.get("醫療", 0.0)))
	return best

# ──────── 貿易 ────────

func _local_value(team: TeamData, res: String) -> float:
	if not BASE_PRICE.has(res):
		return 0.0
	var pop: float    = maxf(float(team.population), 1.0)
	var stock: float  = float(team.resources.get(res, 0))
	var target: float = pop * float(TARGET_PER_POP.get(res, 1.0))
	var sr: float     = clampf((target - stock) / maxf(target, 1.0), -0.5, 1.0)
	return float(BASE_PRICE[res]) * (1.0 + sr)

func _resolve_trade(state: WorldState, seller: TeamData, buyer: TeamData) -> void:
	var buyer_coin: float = float(buyer.resources.get("coin", 0))
	if buyer_coin <= 0.0:
		return

	var s_leader = state.persons.get(seller.leader_id)
	var commerce: float = float(s_leader.skills.get("商業", 0.0)) if s_leader else 0.0

	var budget: float       = minf(buyer_coin, MAX_COIN_PER_TRADE)
	var total_earned: float = 0.0

	# 計算每種資源的利潤空間，排序後優先賣最值錢的
	var res_list: Array = []
	for res in BASE_PRICE.keys():
		var stock: float = float(seller.resources.get(res, 0))
		if res == "food":
			var min_food: float = float(seller.population) * 0.1 * FOOD_RESERVE_TICKS
			stock = maxf(stock - min_food, 0.0)
		if stock <= 0.0:
			continue
		var ask: float = _local_value(seller, res) * (1.0 - commerce * 0.1)
		var bid: float = _local_value(buyer, res)
		if ask <= 0.0 or ask > bid:
			continue
		res_list.append({ "res": res, "stock": stock, "ask": ask, "bid": bid })

	res_list.sort_custom(func(a, b): return (a["bid"] - a["ask"]) > (b["bid"] - b["ask"]))

	for entry in res_list:
		var ask: float = float(entry["ask"])
		if budget < ask:
			break
		var res: String    = entry["res"]
		var max_qty: float = minf(float(entry["stock"]), floorf(budget / ask))
		if max_qty <= 0.0:
			continue
		seller.resources[res]  = float(seller.resources.get(res, 0)) - max_qty
		buyer.resources[res]   = float(buyer.resources.get(res, 0))  + max_qty
		var cost: float        = max_qty * ask
		total_earned += cost
		budget       -= cost

	if total_earned <= 0.0:
		return

	seller.resources["coin"] = float(seller.resources.get("coin", 0)) + total_earned
	buyer.resources["coin"]  = buyer_coin - total_earned

	_msg.emit_message(state, "trade_done",
		"Team%d→Team%d 貿易 coin=%.0f" % [seller.team_id, buyer.team_id, total_earned], seller)
	print("[Trade] Team%d→Team%d coin+%.0f（商業=%.2f）" % [
		seller.team_id, buyer.team_id, total_earned, commerce])
	_grow_commerce_skill(state, seller)
	seller.current_task = TeamData.TASK_IDLE

func _grow_commerce_skill(state: WorldState, team: TeamData) -> void:
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var charm: float  = float(p.attributes.get("魅力", 0.5)) * p.get_attribute_mult("魅力")
		var will: float   = float(p.attributes.get("毅力", 0.5)) * p.get_attribute_mult("毅力")
		var growth: float = 0.003 * charm * (0.5 + will * 0.5) * p.get_skill_mult("商業")  # TEST VALUE
		p.skills["商業"]  = minf(float(p.skills.get("商業", 0.0)) + growth, 1.0)

func _write_tier2_intel(state: WorldState, obs_id: int, tgt_id: int) -> void:
	var tgt: TeamData = state.teams.get(tgt_id) as TeamData
	if tgt == null: return
	var tgt_leader: PersonData = state.persons.get(tgt.leader_id) as PersonData
	if not state.team_intel.has(obs_id):
		state.team_intel[obs_id] = {}
	var snap: Dictionary = state.team_intel[obs_id].get(tgt_id, {}).duplicate()
	snap["tier"]           = 2
	snap["tile_pos"]       = tgt.tile_pos
	snap["last_tick"]      = state.world.current_tick
	snap["population_est"] = tgt.population
	snap["faction_id"]     = tgt.faction_id
	snap["tags"]           = tgt.tags.duplicate()
	snap["current_task"]   = tgt.current_task
	snap["food_est"]       = float(tgt.resources.get("food",     0.0))
	snap["material_est"]   = float(tgt.resources.get("material", 0.0))
	snap["coin_est"]       = float(tgt.resources.get("coin",     0.0))
	snap["goods_est"]      = float(tgt.resources.get("goods",    0.0))
	var actual_armed: int  = _calc_armed(state, tgt)
	snap["armed_est"]      = actual_armed
	var honor: float   = float(tgt_leader.values.get("信義",  0.5)) if tgt_leader else 0.5
	var scheme: float  = float(tgt_leader.skills.get("計謀",  0.0)) if tgt_leader else 0.0
	var martial: float = float(tgt_leader.values.get("好戰",  0.5)) if tgt_leader else 0.5
	var caution: float = float(tgt_leader.values.get("慎重",  0.5)) if tgt_leader else 0.5
	var deceive_chance: float = (1.0 - honor) * 0.5 + scheme * 0.2  # TEST VALUE
	var disguise_tags: Array  = ["統領", "軍隊", "流亡", "子團"]
	var has_disguise_tag: bool = false
	for dtag in disguise_tags:
		if tgt.tags.has(dtag): has_disguise_tag = true; break
	if has_disguise_tag and randf() < deceive_chance:
		# 偽裝平民：低報武器，高報其他資源
		snap["armed_est"]    = roundi(actual_armed * randf_range(0.2, 0.4))
		snap["food_est"]     *= randf_range(1.5, 2.5)
		snap["material_est"] *= randf_range(1.5, 2.5)
		snap["goods_est"]    *= randf_range(1.5, 2.5)
	else:
		var is_bluff_task:     bool = tgt.current_task in ["攻擊", "掠奪"]
		var is_bluff_martial:  bool = martial > 0.6
		var is_bluff_merchant: bool = tgt.tags.has("商隊") and caution > 0.5
		var armed_ratio: float = float(actual_armed) / maxf(float(tgt.population), 1.0)
		if (is_bluff_task or is_bluff_martial or is_bluff_merchant) \
				and armed_ratio < 0.6 and randf() < deceive_chance:
			# 虛張聲勢：高報武器，低報其他資源
			var bluffed: int  = roundi(actual_armed * randf_range(2.0, 4.0))
			snap["armed_est"] = maxi(0, mini(bluffed, tgt.population - 1))
			snap["food_est"]     *= randf_range(0.3, 0.7)
			snap["material_est"] *= randf_range(0.3, 0.7)
			snap["goods_est"]    *= randf_range(0.3, 0.7)
	state.team_intel[obs_id][tgt_id] = snap

# 處決俘虜：呼叫者負責移除 NPC；此函數只結算目擊者 loyalty 懲罰
func execute_prisoner(state: WorldState, team_id: int) -> void:
	var team: TeamData = state.teams.get(team_id)
	if team == null: return
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var yi_qi: float = float(p.values.get("義氣", 0.5))
		p.loyalty -= yi_qi * 0.08
	print("[Atrocity] Team%d 處決俘虜，目擊者 loyalty 懲罰" % team_id)

# 夜間突襲判定：防守方紮營且無崗哨 → 突襲成功
# TODO: 接入 _try_interact，返回 true 時設 combat_type = "pursuit"
func _check_night_raid(state: WorldState, attacker: TeamData,
		defender: TeamData) -> bool:
	var dns := DayNightSystem.new()
	if defender.current_task != "rest": return false
	if dns.get_camp_vision_range(state, defender) > 0: return false
	return true

func _calc_armed(state: WorldState, team: TeamData) -> int:
	var named_armed: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid) as PersonData
		if p and p.equipment["hand_1"].get("type", "none") != "none":
			named_armed += 1
	var named_count: int = 1 + team.named_members.size()
	var anon_pop: int    = maxi(team.population - named_count, 0)
	return named_armed + roundi(float(anon_pop) * team.armed_anon_ratio)

# ──────── 玩家直接呼叫接口（繞過 current_task 檢查）────────

# 供 PlayerCommandSystem 呼叫：不需要 seller 有 TASK_TRADE
# 先嘗試 target 賣 player 買；若無成交再試 player 賣 target 買
# 返回 { "ok": bool, "msg": String }
func resolve_trade_direct(state: WorldState, initiator_id: int, target_id: int) -> Dictionary:
	var pt: TeamData  = state.teams.get(initiator_id)
	var tgt: TeamData = state.teams.get(target_id)
	if pt == null or tgt == null:
		return { "ok": false, "msg": "隊伍不存在" }
	# 嘗試 target 賣、initiator 買
	var tgt_coin_before: float = float(tgt.resources.get("coin", 0.0))
	_resolve_trade(state, tgt, pt)
	if float(tgt.resources.get("coin", 0.0)) != tgt_coin_before:
		return { "ok": true, "msg": "貿易成功" }
	# 若無成交，嘗試 initiator 賣、target 買
	var pt_coin_before: float = float(pt.resources.get("coin", 0.0))
	_resolve_trade(state, pt, tgt)
	if float(pt.resources.get("coin", 0.0)) != pt_coin_before:
		return { "ok": true, "msg": "貿易成功" }
	return { "ok": false, "msg": "無可交易資源" }

func preview_trade(state: WorldState, from_id: int, to_id: int) -> Dictionary:
	var from_t: TeamData = state.teams.get(from_id)
	var to_t:   TeamData = state.teams.get(to_id)
	if from_t == null or to_t == null:
		return { "feasible": false, "player_gives": {}, "player_gets": {} }

	var gives: Dictionary = {}
	var gets:  Dictionary = {}

	var from_food: float  = float(from_t.resources.get("food", 0))
	var to_food: float    = float(to_t.resources.get("food", 0))
	var from_coin: float  = float(from_t.resources.get("coin", 0))
	var to_coin: float    = float(to_t.resources.get("coin", 0))

	# 玩家付出：若對方 food 更少，付出部分食物
	if to_food < from_food * 0.5 and from_food > 10:
		gives["food"] = minf(from_food * 0.2, from_food)

	# 玩家獲得：若對方 coin 更多，取一部分
	if to_coin > from_coin * 1.5 and to_coin > 10:
		gets["coin"] = minf(to_coin * 0.2, to_coin)

	var feasible: bool = not (gives.is_empty() and gets.is_empty())
	return { "feasible": feasible, "player_gives": gives, "player_gets": gets }

# 供 PlayerCommandSystem 呼叫：不需要 aggressor 有 TASK_LOOT
# 直接執行勒索資源轉移（food/material/goods/coin × TRIBUTE_RATE）
# 返回 { "ok": bool, "accepted": bool, "msg": String }
func resolve_extortion_direct(state: WorldState, aggressor_id: int, target_id: int) -> Dictionary:
	var from_t: TeamData = state.teams.get(aggressor_id)
	var to_t:   TeamData = state.teams.get(target_id)
	if from_t == null or to_t == null:
		return { "ok": false, "accepted": false, "msg": "隊伍不存在" }

	# NPC refuse logic — only when player is aggressor
	var player_p: PersonData = state.persons.get(state.player_id)
	var player_team_id: int  = player_p.team_id if player_p != null else -1
	if aggressor_id == player_team_id:
		var leader: PersonData = state.persons.get(to_t.leader_id) if to_t.leader_id != -1 else null
		var caution: float = float(leader.values.get("慎重", 0.5)) if leader else 0.5
		var pride:   float = float(leader.values.get("義氣", 0.5)) if leader else 0.5
		var fear:    float = leader.fear if leader else 0.3
		var power_r: float = float(from_t.population) / maxf(float(to_t.population), 1.0)
		var score:   float = (power_r - 1.0) * 0.4 + caution * 0.2 \
		                   - pride * 0.3 + fear * 0.2 + from_t.readiness * 0.2
		var accepted: bool = score > 0.5   # TEST VALUE
		if not accepted:
			print("[Extort] Team%d 拒絕勒索 (score=%.2f)" % [target_id, score])
			return { "ok": true, "accepted": false, "msg": "對方拒絕勒索" }

	# 資源轉移
	var gained: Dictionary = _resolve_extortion(state, aggressor_id, target_id)
	if gained.is_empty():
		return { "ok": true, "accepted": true, "msg": "勒索完成（對方資源耗盡，無所得）" }
	var parts: Array = []
	for res in gained:
		var amount: int = int(gained[res])
		if amount > 0:
			parts.append("%s+%d" % [res, amount])
	var detail: String = ", ".join(parts) if not parts.is_empty() else "少量資源"
	return { "ok": true, "accepted": true, "msg": "勒索完成（%s）" % detail }
