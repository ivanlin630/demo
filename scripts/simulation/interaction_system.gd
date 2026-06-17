class_name InteractionSystem

# ──────── 貿易常數 ────────
# 定價規則：成品價 ≥ 原料價值（Σ in × BASE_PRICE）× 1.2（工藝品 gem 路線豁免）
const BASE_PRICE: Dictionary = {
	"food":               2.0,
	"material":           4.0,
	"herb":               3.0,
	"goods":             15.0,   # in 12
	"gem":               20.0,
	"ore_gold":          10.0,
	"ore_silver":         5.0,
	"ore_iron":           8.0,
	"ore_steel":         24.0,   # in 20
	"weapon_melee_low":  34.0,   # in 28
	"weapon_melee_high": 72.0,   # in 60
	"weapon_ranged_low": 39.0,   # in 32
	"weapon_ranged_high": 77.0,  # in 64
	"tools":             20.0,   # in 16
	"arrows":             4.0,   # in 3.2
	"armor_low":         30.0,   # in 24
	"armor_high":        72.0,   # in 60
	"horses":            15.0,
	"mounts":            45.0,   # horses + 草料 + 軍設施 margin
	"wagons":            72.0,   # in 59
	"medicine":          12.0,   # in 6
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
	"tools":              0.5,
	"arrows":             2.0,
	"armor_low":          0.3,
	"armor_high":         0.15,
	"horses":             0.5,
	"medicine":           1.0,
	"herb":               1.0,
	"mounts":             0.2,
	"wagons":             0.2,
}
const SURVIVAL_GOODS: Array = ["food", "medicine"]   # 飢荒不對稱 clamp 適用
const FOOD_RESERVE_TICKS: float = 20.0   # TEST VALUE — food 最低自留（pop × 0.1 × N ticks）
const MAX_COIN_PER_TRADE: float = 300.0  # TEST VALUE — 每次交易買方預算上限

const WOUNDED_TREATMENT_RATE: float  = 0.3
const TRIBUTE_RATE: float            = 0.25
const COMBAT_THRESHOLD: float        = 0.7
const READINESS_RECOVERY_BASE: float = 0.04
const READINESS_FOOD_COST: float     = 0.05

const AID_RESERVE_DAYS: float = 14.0
# 特別稅（徵收 task）= 一般稅率 × 此倍率，重於常態一般稅（戰時/缺糧額外加徵）。TEST VALUE
const SPECIAL_TAX_MULT: float = 1.5

var _msg:       SimMessageSystem
var _vision:    VisionSystem
var _equip:     EquipmentSystem
var _skill_sys: SkillSystem
var _combat:    NpcCombatSystem
var _npc_ai:    NpcAiSystem

func _init() -> void:
	_msg       = SimMessageSystem.new()
	_vision    = VisionSystem.new()
	_equip     = EquipmentSystem.new()
	_skill_sys = load("res://scripts/simulation/skill_system.gd").new()
	_combat    = NpcCombatSystem.new()
	_npc_ai    = NpcAiSystem.new()

# ──────── 主入口 ────────

func process_on_arrival(state: WorldState, arrived_ids: Array, all_team_ids: Array) -> void:
	_tick_readiness(state, all_team_ids)
	_combat.tick_critical_npcs(state, all_team_ids)
	_combat.process_ongoing_combat(state, all_team_ids)
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

# 寬版同格 scan：凡「本 tick 有移動」的 team（不限走到最終目標）即掃同格互動。
# 解 NPC-NPC encounter=0：追擊團路過 prey 格即觸發 try_interact，不必剛好 arrived。
# body 同 process_on_arrival，只是 driver 從 arrived_ids 換成 moved_ids。
func process_on_move(state: WorldState, moved_ids: Array, all_team_ids: Array) -> void:
	_tick_readiness(state, all_team_ids)
	_combat.tick_critical_npcs(state, all_team_ids)
	_combat.process_ongoing_combat(state, all_team_ids)
	var _sub := SubteamSystem.new()
	for moved_id in moved_ids:
		if not state.teams.has(moved_id):
			continue
		if _sub.try_merge_back(state, moved_id):
			continue
		var moved: TeamData = state.teams[moved_id]
		if moved.current_task == "護衛":
			continue
		for other_id in state.teams:
			if other_id == moved_id:
				continue
			var other: TeamData = state.teams[other_id]
			if other.tile_pos != moved.tile_pos:
				continue
			_try_interact(state, moved_id, other_id)
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
	var named_ids: Array = team.named_members.duplicate()   # MUST duplicate (Array by ref)
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
	AnonTierSystem.heal_random(team, saved)        # 救活：wounded → healthy
	AnonTierSystem.kill_wounded(team, died)        # 治療失敗死：移除 wounded 桶（population getter 自動反映）
	if died > 0:
		print("[Treat] Team%d 治療 %d 傷兵：救 %d 死 %d (medicine=%.2f)" % [
			team.team_id, to_treat, saved, died, best_medicine])

# ──────── 新互動判斷 ────────

func _try_interact(state: WorldState, id_a: int, id_b: int) -> void:
	if not state.teams.has(id_a) or not state.teams.has(id_b):
		return   # 本 tick 內滅團/合併移除 → id 仍留掃描迴圈，避免 state.teams[id] Out of bounds
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

				# 路徑 1：NPC 攻擊玩家 → 預備遭遇戰，等玩家選擇迎擊或投降
				if npc.combat_target == player_team_id:
					if state.player_pre_encounter.is_empty():
						state.player_pre_encounter = {
							"attacker_id": npc_id,
							"defender_id": player_team_id
						}
						if not state.player_hostile_teams.has(npc_id):
							state.player_hostile_teams.append(npc_id)
						print("[Encounter] 預備遭遇戰 Team%d → 玩家 Team%d" % [npc_id, player_team_id])
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
	if a.current_task == TeamData.TASK_TRADE or b.current_task == TeamData.TASK_TRADE:
		_resolve_market(state, a, b)
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
		elif a.current_task == "安頓":
			var tile: HexTileData = state.world.tiles.get(a.tile_pos.x * 1000 + a.tile_pos.y)
			if tile and tile.outpost_owner != -1:
				var o: TeamData = state.teams.get(tile.outpost_owner)
				if o and o.faction_id == a.faction_id:
					_convert_to_resident(state, a)
		elif b.current_task == "安頓":
			var tile2: HexTileData = state.world.tiles.get(b.tile_pos.x * 1000 + b.tile_pos.y)
			if tile2 and tile2.outpost_owner != -1:
				var o2: TeamData = state.teams.get(tile2.outpost_owner)
				if o2 and o2.faction_id == b.faction_id:
					_convert_to_resident(state, b)
		elif a.current_task == "安撫" and b.tags.has(TeamData.TAG_PRODUCE):
			_resolve_pacify(state, a, b)
		elif b.current_task == "安撫" and a.tags.has(TeamData.TAG_PRODUCE):
			_resolve_pacify(state, b, a)
		return
	if a.current_task == "外交":
		_try_diplomacy(state, id_a, id_b)
		return
	if b.current_task == "外交":
		_try_diplomacy(state, id_b, id_a)
		return
	if a.current_task == "乞食" and a.combat_target == id_b:
		_resolve_aid_request(state, id_a, id_b)
		return
	if b.current_task == "乞食" and b.combat_target == id_a:
		_resolve_aid_request(state, id_b, id_a)
		return
	if a.current_task == "攻擊":
		_combat.start_combat(state, id_a, id_b)
	elif b.current_task == "攻擊":
		_combat.start_combat(state, id_b, id_a)
	elif a.current_task == "掠奪" and a.readiness >= COMBAT_THRESHOLD:
		if _should_pay_tribute(state, id_b, id_a):
			_resolve_extortion(state, id_a, id_b)
		elif _should_attack(state, id_a, id_b):
			_combat.start_combat(state, id_a, id_b)
	elif b.current_task == "掠奪" and b.readiness >= COMBAT_THRESHOLD:
		if _should_pay_tribute(state, id_a, id_b):
			_resolve_extortion(state, id_b, id_a)
		elif _should_attack(state, id_b, id_a):
			_combat.start_combat(state, id_b, id_a)

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
	var weakness: float = _combat.team_strength(state, def_id) / maxf(_combat.team_strength(state, atk_id), 0.01)
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
	var str_ratio: float = _combat.team_strength(state, atk_id) / maxf(_combat.team_strength(state, def_id), 0.01)
	var score: float     = ambition * 0.3 + martial * 0.3 + greed * 0.2 + (str_ratio - 1.0) * 0.2 - caution * 0.5
	return score > 0.0


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
		"Team %d 向 Team %d 收過路費" % [atk_id, def_id], atk,
		{ "origin": str(atk_id), "target": str(def_id) })
	print("[Extort] Team%d 勒索 Team%d，Team%d 妥協給付" % [atk_id, def_id, def_id])
	return gained

# ──────── 勢力互動 ────────

func subjugate_team(state: WorldState, winner_id: int, loser_id: int) -> void:
	_combat.subjugate_team(state, winner_id, loser_id)

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
	var str_init: float  = _combat.team_strength(state, initiator_id)
	var str_tgt: float   = _combat.team_strength(state, target_id)
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
	TaskArbiter.release(initiator)
	_msg.emit_message(state, "diplomacy",
		TextBank.fmt("diplomacy", "honest", {
			"origin": str(initiator_id), "target": str(target_id)
		}),
		initiator,
		{ "origin": str(initiator_id), "target": str(target_id), "faction": str(fid) })
	print("[Faction] Team%d 外交 Team%d → 勢力%d" % [initiator_id, target_id, fid])

func _try_merge(state: WorldState, id_a: int, id_b: int) -> void:
	var a: TeamData = state.teams[id_a]
	var b: TeamData = state.teams[id_b]
	var merger_id: int = id_a if a.current_task == TeamData.TASK_MERGE else id_b
	var target_id: int = id_b if merger_id == id_a else id_a
	var merger: TeamData = state.teams[merger_id]
	if merger.order_target_id != target_id:
		return
	# absorbed_team is the MERGER (small team dissolving into target)
	var absorbed_team: TeamData = state.teams[merger_id]
	var all_npcs: Array = []
	if absorbed_team.leader_id != -1: all_npcs.append(absorbed_team.leader_id)
	all_npcs.append_array(absorbed_team.named_members)
	SubteamSystem.new().merge_teams(state, target_id, merger_id, all_npcs)
	# reset merger task (safe even if merger_id erased — GDScript ref stays valid)
	TaskArbiter.release(merger)
	merger.order_target_id = -1

func _resolve_tribute(state: WorldState, collector_id: int, payer_id: int) -> void:
	var collector: TeamData = state.teams[collector_id]
	var payer:     TeamData = state.teams[payer_id]
	# PRODUCE 居民：用 team.tax_rate，跳過勢力守衛
	if payer.tags.has(TeamData.TAG_PRODUCE):
		# 特別稅：一般稅率 × MULT，重於常態，進 collector(leader) 口袋（應急/戰爭）
		var rate: float = payer.tax_rate * SPECIAL_TAX_MULT
		# 資源轉移（surplus × rate，保留最低儲備）；累計搜刮量/庫存量算尖峰強度
		var total_take: float = 0.0
		var total_stock: float = 0.0
		for res in ["food", "material", "goods", "coin"]:
			var stock: float = float(payer.resources.get(res, 0))
			total_stock += stock
			var reserve: float = 0.0
			if res == "food":
				reserve = float(payer.population) * 14.0
			elif res == "coin":
				reserve = stock * 0.5
			var surplus: float = maxf(stock - reserve, 0.0)
			var take: float = surplus * rate
			if take <= 0.0:
				continue
			payer.resources[res]     = stock - take
			collector.resources[res] = float(collector.resources.get(res, 0)) + take
			total_take += take
		# 尖峰強度：本次搜刮占居民總庫存比例
		var taken_ratio: float = total_take / maxf(total_stock, 1.0)
		# 厭煩疊加：近期被同一 collector 特別稅次數（連續加徵 → 怨恨爆）
		var payer_leader: PersonData = state.persons.get(payer.leader_id)
		var tax_count: int = _count_recent_special_tax(payer_leader, collector_id) if payer_leader else 0
		# 重稅後果（既有 rate 門檻 + 尖峰搜刮比例 + 厭煩疊加）
		var stress_gain: float  = maxf(0.0, (rate - 0.3) * 0.3) \
			+ taken_ratio * 0.3 + float(tax_count) * 0.1
		var loyalty_loss: float = maxf(0.0, (rate - 0.2) * 0.1) + taken_ratio * 0.1
		var fear_gain: float    = maxf(0.0, (rate - 0.6) * 0.5)
		if payer_leader != null:
			_npc_ai.write_memory(payer_leader, "special_taxed", collector_id,
				state.world.current_tick, 0.5)
		var targets: Array = []
		if payer.leader_id != -1:
			targets.append(payer.leader_id)
		targets.append_array(payer.named_members)
		for pid in targets:
			var p: PersonData = state.persons.get(pid)
			if p == null:
				continue
			p.stress  = minf(p.stress  + stress_gain,  1.0)
			p.loyalty = maxf(p.loyalty - loyalty_loss, 0.0)
			p.fear    = minf(p.fear    + fear_gain,    1.0)
		if rate > 0.5:
			payer.unrest_turns += 1
		TaskArbiter.release(collector)
		_msg.emit_message(state, "tribute",
			TextBank.fmt("tribute", "honest", {
				"origin": str(collector_id), "target": str(payer_id), "rate": "%.2f" % rate
			}),
			collector,
			{ "origin": str(collector_id), "target": str(payer_id), "rate": "%.2f" % rate })
		print("[Tribute] Team%d 徵收居民 Team%d rate=%.2f" % [collector_id, payer_id, rate])
		return
	# 非 PRODUCE：原有勢力守衛 + value 修正邏輯
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
	var str_ratio: float = _combat.team_strength(state, payer_id) / maxf(_combat.team_strength(state, collector_id), 0.01)
	if str_ratio > 1.2:
		base_rate *= maxf(1.0 - (str_ratio - 1.0) * 0.5, 0.0)
	base_rate = clampf(base_rate, 0.0, 0.5)
	for res in ["food", "goods", "coin"]:
		var amount: float = float(payer.resources.get(res, 0)) * base_rate
		if amount <= 0.0:
			continue
		payer.resources[res]     = float(payer.resources.get(res, 0)) - amount
		collector.resources[res] = float(collector.resources.get(res, 0)) + amount
	TaskArbiter.release(collector)
	_msg.emit_message(state, "tribute",
		TextBank.fmt("tribute", "honest", {
			"origin": str(collector_id), "target": str(payer_id), "rate": "%.2f" % base_rate
		}),
		collector,
		{ "origin": str(collector_id), "target": str(payer_id), "rate": "%.2f" % base_rate })
	print("[Tribute] Team%d 徵收 Team%d rate=%.2f" % [collector_id, payer_id, base_rate])

func _deliver_order(state: WorldState, messenger_id: int, target_id: int) -> void:
	var messenger: TeamData = state.teams[messenger_id]
	var target: TeamData    = state.teams[target_id]
	var order: String = messenger.order_task if messenger.order_task != "" else "idle"
	# player herald：若信使是玩家下令派出的，同時更新 player_commanded_task
	var str_target_id: String = str(target_id)
	var is_player_order: bool = false
	if state.player_pending_orders.has(str_target_id):
		var pending: Dictionary = state.player_pending_orders[str_target_id]
		if pending.get("herald_id", -1) == messenger_id:
			is_player_order = true
			target.player_commanded_task = order
			state.player_pending_orders.erase(str_target_id)
			print("[Order] player herald 抵達 Team%d，player_commanded_task = %s" % [target_id, order])
	if order == TeamData.TASK_IDLE:
		TaskArbiter.release(target)
	else:
		# 玩家信使命令 60，NPC 對 NPC 下令 50；被高層擋下時 player_commanded_task
		# 仍保留意圖，faction_ai 後續重試
		var order_prio: int = TaskArbiter.PRIO_PLAYER if is_player_order else TaskArbiter.PRIO_DISPATCH
		TaskArbiter.try_set(state, target, order, target.move_target, order_prio, "herald_order")
	TaskArbiter.release(messenger)
	messenger.order_target_id = -1
	messenger.order_task      = ""
	var parent: TeamData = state.teams.get(messenger.parent_team_id)
	if parent != null:
		messenger.move_target = parent.tile_pos
	# T-02 快照A：信使抵達 = 情報傳遞，更新 messenger 母隊在 faction 中的快照
	if messenger.parent_team_id != -1:
		state.snapshot_faction_member(messenger.parent_team_id, state.world.current_tick)
	_msg.emit_message(state, "order_delivered",
		TextBank.fmt("order_delivered", "honest", {
			"origin": str(messenger_id), "target": str(target_id), "task": order
		}),
		messenger,
		{ "origin": str(messenger_id), "target": str(target_id), "task": order })
	print("[Order] Team%d 傳令 Team%d → %s" % [messenger_id, target_id, order])

# ──────── 貿易 ────────

func _local_value(team: TeamData, res: String) -> float:
	if not BASE_PRICE.has(res):
		return 0.0
	var pop: float    = maxf(float(team.population), 1.0)
	var stock: float  = float(team.resources.get(res, 0))
	var target: float = pop * float(TARGET_PER_POP.get(res, 1.0))
	var shortage: float = (target - stock) / maxf(target, 1.0)   # ≤ 1.0
	if res in SURVIVAL_GOODS and shortage > 0.5:
		# 生存品短缺過半 → 急速攀升：0.5→1.0 區間映射 sr 1.0→4.0（饑荒價最高 5×）
		shortage = 1.0 + (shortage - 0.5) * 6.0
	var sr: float = clampf(shortage, -0.5, 4.0 if res in SURVIVAL_GOODS else 1.0)
	return float(BASE_PRICE[res]) * (1.0 + sr)

# 公開存取（DTO 估值用）：_local_value 私有，trade_session DTO 經此取單價
func local_value(team: TeamData, res: String) -> float:
	return _local_value(team, res)

# ──────── 雙向 market 結算（取代舊 _resolve_trade）────────

func _calc_reserve(team: TeamData, res: String) -> float:
	if res == "food":
		return float(team.population) * 0.1 * FOOD_RESERVE_TICKS
	elif res == "coin":
		return float(team.resources.get(res, 0)) * 0.5
	# 其他資源：保留至 target 需求量，避免賣掉自己短缺的物資（否則雙向 market 會即買即賣）
	return float(team.population) * float(TARGET_PER_POP.get(res, 0.0))

func _execute_transfer(seller: TeamData, buyer: TeamData, res: String, qty: int, price: float) -> void:
	seller.resources[res] = float(seller.resources.get(res, 0)) - qty
	buyer.resources[res]  = float(buyer.resources.get(res, 0)) + qty
	buyer.resources["coin"]  = float(buyer.resources.get("coin", 0)) - qty * price
	seller.resources["coin"] = float(seller.resources.get("coin", 0)) + qty * price

# 「村長代管公庫」：居民團（PRODUCE+在自家 faction outpost）或 outpost owner team
# 在 outpost tile 上時，absorb public_storage 進 team.resources（臨時）
# 回傳 { res: original_team_amount } 供 spill_back 還原
static func _absorb_public_storage(state: WorldState, team: TeamData) -> Dictionary:
	var original: Dictionary = {}
	var tile: HexTileData = state.world.tiles.get(
		team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_owner == -1: return original
	# 條件：outpost owner 本身 或 居民團（PRODUCE+同 faction）
	var can_absorb: bool = (tile.outpost_owner == team.team_id) \
		or FactionAISystem.new()._is_resident_team(state, team)
	if not can_absorb: return original
	for res in tile.public_storage:
		var public_amount: float = float(tile.public_storage[res])
		if public_amount <= 0: continue
		var team_amount: float = float(team.resources.get(res, 0))
		original[res] = team_amount
		team.resources[res] = team_amount + public_amount
		tile.public_storage[res] = 0.0   # MOVE 出公庫（避免雙重存在，spill_back 再分流回去）
	return original

# trade 結束後，多出來的存回 public_storage（cap 限制；超量留 team）
static func _spill_back_public_storage(state: WorldState, team: TeamData,
		original: Dictionary) -> void:
	var tile: HexTileData = state.world.tiles.get(
		team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_owner == -1: return
	var can_spill: bool = (tile.outpost_owner == team.team_id) \
		or FactionAISystem.new()._is_resident_team(state, team)
	if not can_spill: return
	for res in original:
		var current: float = float(team.resources.get(res, 0))
		var orig: float = float(original[res])
		var diff: float = current - orig
		var cap: float = OutpostSystem.new()._get_storage_cap(tile, res)
		var stored: float = float(tile.public_storage.get(res, 0))
		if diff >= 0:
			var space: float = maxf(cap - stored, 0.0)
			var deposit: float = minf(diff, space)
			tile.public_storage[res] = stored + deposit
			team.resources[res] = orig + (diff - deposit)
		else:
			# team 賣掉超過借出的公庫量（連自家底貨也動了）→ 公庫歸零，team 保留實際剩餘（不憑空生）
			tile.public_storage[res] = maxf(stored + diff, 0.0)
			team.resources[res] = current

func _resolve_market(state: WorldState, a: TeamData, b: TeamData) -> void:
	var a_original: Dictionary = _absorb_public_storage(state, a)
	var b_original: Dictionary = _absorb_public_storage(state, b)
	var a_coin_before: float = float(a.resources.get("coin", 0))
	_attempt_trade_direction(state, a, b)
	_attempt_trade_direction(state, b, a)
	if absf(float(a.resources.get("coin", 0)) - a_coin_before) > 0.001:
		print("[Market] Team%d <-> Team%d 成交（公庫接入）" % [a.team_id, b.team_id])
	_spill_back_public_storage(state, a, a_original)
	_spill_back_public_storage(state, b, b_original)
	if a.current_task == TeamData.TASK_TRADE: TaskArbiter.release(a)
	if b.current_task == TeamData.TASK_TRADE: TaskArbiter.release(b)

func _attempt_trade_direction(state: WorldState, seller: TeamData, buyer: TeamData) -> void:
	var buyer_coin: float = float(buyer.resources.get("coin", 0))
	if buyer_coin <= 0.0: return
	var s_leader = state.persons.get(seller.leader_id)
	var commerce: float = float(s_leader.skills.get("商業", 0.0)) if s_leader else 0.0
	# (1) seller 商隊優先賣 inventory（買低賣高賺差價）
	if seller.tags.has(TeamData.TAG_MERCHANT):
		var inv_copy: Array = seller.merchant_inventory.duplicate()
		for item in inv_copy:
			if int(item.get("bought_from", -1)) == buyer.team_id: continue
			var inv_bid: float = _local_value(buyer, item["grade"])
			if inv_bid <= float(item["bought_at"]): continue
			var inv_qty: int = mini(int(item["qty"]), int(buyer_coin / inv_bid))
			if inv_qty <= 0: continue
			buyer.resources[item["grade"]] = float(buyer.resources.get(item["grade"], 0)) + inv_qty
			buyer.resources["coin"]  = float(buyer.resources.get("coin", 0)) - inv_qty * inv_bid
			seller.resources["coin"] = float(seller.resources.get("coin", 0)) + inv_qty * inv_bid
			item["qty"] = int(item["qty"]) - inv_qty
			buyer_coin -= inv_qty * inv_bid
		seller.merchant_inventory = seller.merchant_inventory.filter(
			func(it): return int(it.get("qty", 0)) > 0)
	# (2) 賣 surplus（保留最低儲備）
	for res in BASE_PRICE.keys():
		var stock: float = float(seller.resources.get(res, 0))
		var reserve: float = _calc_reserve(seller, res)
		var surplus: float = maxf(stock - reserve, 0.0)
		if surplus <= 0.0: continue
		var ask: float = _local_value(seller, res) * (1.0 - commerce * 0.1)
		var bid: float = _local_value(buyer, res)
		if ask <= 0.0 or ask >= bid: continue
		var qty: int = mini(int(surplus), int(buyer_coin / ask))
		if qty <= 0: continue
		_execute_transfer(seller, buyer, res, qty, ask)
		buyer_coin -= qty * ask
		# 買方若是商隊 → 物品移到 inventory（之後高價賣出）
		if buyer.tags.has(TeamData.TAG_MERCHANT):
			buyer.resources[res] = float(buyer.resources.get(res, 0)) - qty
			buyer.merchant_inventory.append({
				"grade": res, "qty": qty, "bought_at": ask, "bought_from": seller.team_id
			})

func _grow_commerce_skill(state: WorldState, team: TeamData) -> void:
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		var charm: float  = float(p.attributes.get("魅力", 0.5)) * p.get_attribute_mult("魅力")
		var will: float   = float(p.attributes.get("毅力", 0.5)) * p.get_attribute_mult("毅力")
		var growth: float = 0.003 * charm * (0.5 + will * 0.5) * p.get_skill_mult("商業")  # TEST VALUE
		SkillSystem.cap_add(p, "商業", growth)

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
	var actual_armed: int  = _combat.calc_armed(state, tgt)
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

# ──────── 玩家直接呼叫接口（繞過 current_task 檢查）────────

# 供 PlayerCommandSystem 呼叫：不需要 seller 有 TASK_TRADE
# 先嘗試 target 賣 player 買；若無成交再試 player 賣 target 買
# 返回 { "ok": bool, "msg": String }
func resolve_trade_direct(state: WorldState, initiator_id: int, target_id: int) -> Dictionary:
	var pt: TeamData  = state.teams.get(initiator_id)
	var tgt: TeamData = state.teams.get(target_id)
	if pt == null or tgt == null:
		return { "ok": false, "msg": "隊伍不存在" }
	# 雙向結算（target 賣 initiator 買 + initiator 賣 target 買）
	var tgt_coin_before: float = float(tgt.resources.get("coin", 0.0))
	var pt_coin_before: float  = float(pt.resources.get("coin", 0.0))
	_attempt_trade_direction(state, tgt, pt)
	_attempt_trade_direction(state, pt, tgt)
	if float(tgt.resources.get("coin", 0.0)) != tgt_coin_before \
			or float(pt.resources.get("coin", 0.0)) != pt_coin_before:
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

# ──────── 援助請求 ────────

func _resolve_aid_request(state: WorldState, beggar_id: int, target_id: int) -> Dictionary:
	var beggar: TeamData = state.teams.get(beggar_id)
	var target: TeamData = state.teams.get(target_id)
	if beggar == null or target == null:
		return { "ok": false, "msg": "對象不存在" }
	# 玩家 target → forced event
	if target.leader_id == state.player_id and state.player_id != -1:
		state.player_forced_event = {
			"from_id": beggar_id,
			"action": "aid_request",
			"beggar_food": float(beggar.resources.get("food", 0)),
			"beggar_pop": beggar.population,
		}
		state.player_forced_event_id = "aid_%d_%d" % [beggar_id, state.world.current_tick]
		return { "ok": true, "pending": true, "msg": "等玩家回應" }
	# NPC 自決
	var target_leader: PersonData = state.persons.get(target.leader_id)
	var beggar_leader: PersonData = state.persons.get(beggar.leader_id)
	if target_leader == null or beggar_leader == null:
		return { "ok": false, "msg": "leader 缺失" }
	var honor: float = float(target_leader.values.get("義氣", 0.5))
	var greed: float = float(target_leader.values.get("貪婪", 0.5))
	var rep: float   = float(target.known_reputations.get(beggar_id, 0.5))
	var annoyance: float = _count_recent_begs(target_leader, beggar_id) * 0.2
	var give_score: float = honor + rep - greed * 0.5 - annoyance
	# 需求 + 乞丐是否將餓死（人性底線判定）
	var need: float = float(beggar.population) * 2.4 * 3.0 \
		- float(beggar.resources.get("food", 0))
	var beggar_starving: bool = float(beggar.resources.get("food", 0)) \
		< float(beggar.population) * 2.4
	var mercy_amount: float = float(beggar.population) * 2.4   # 1 天份
	# 慷慨光譜：留存(reserve)與給予比例(give_fraction)由個性兩極決定（取代 flat AID_RESERVE_DAYS）
	# 守財奴(高貪低義) hoard→1 → reserve 近 60 天、give_fraction≈0；聖人(高義低貪) → reserve 2 天、可動 reserve
	var hoard: float = greed - honor                           # [-1,1]
	var reserve_days: float = lerpf(2.0, 60.0, (hoard + 1.0) / 2.0)
	var target_food: float = float(target.resources.get("food", 0))
	var reserve: float = float(target.population) * reserve_days * 2.4
	var give_fraction: float = clampf(honor - greed * 0.5 + rep * 0.3 - annoyance, 0.0, 1.2)
	var surplus: float = maxf(target_food - reserve, 0.0)
	var give: float = minf(need, surplus * give_fraction)
	# 人性底線：算出 give≤0，但乞丐將餓死且施主非真禽獸(honor>0.1)、未被反覆煩擾 → 給最低 1 天份
	if give <= 0.0 and beggar_starving and honor > 0.1 and annoyance < 0.4:
		give = minf(need, mercy_amount)
	# 吝嗇拒絕（give_score 低且無人性底線可救）
	if give_score < 0.3 and give <= 0.0:
		_msg.emit_message(state, "aid_refused",
			"Team%d 拒絕援助 Team%d" % [target_id, beggar_id], target,
			{ "origin": str(target_id), "target": str(beggar_id) })
		beggar.update_reputation(target_id, -0.1)
		_npc_ai.write_memory(beggar_leader, "rejected_aid", target_id,
			state.world.current_tick, 0.5)
		_npc_ai.write_memory(target_leader, "begged_at_me", beggar_id,
			state.world.current_tick, 0.3)
		_clear_aid_task(beggar)
		return { "ok": true, "accepted": false, "msg": "拒絕" }
	# 有給予意願但 reserve 吃光 surplus → 無餘糧
	if give <= 0.0:
		_msg.emit_message(state, "aid_refused",
			"Team%d 無餘糧 Team%d" % [target_id, beggar_id], target,
			{ "origin": str(target_id), "target": str(beggar_id) })
		_clear_aid_task(beggar)
		return { "ok": true, "accepted": false, "msg": "無餘糧" }
	target.resources["food"] = target_food - give
	beggar.resources["food"] = float(beggar.resources.get("food", 0)) + give
	_msg.emit_message(state, "aid_given",
		"Team%d 援助 Team%d %.0f 食物" % [target_id, beggar_id, give], target,
		{ "origin": str(target_id), "target": str(beggar_id), "amount": "%.0f" % give })
	beggar.update_reputation(target_id, 0.15)
	var intensity: float = clampf(give / maxf(need, 1.0), 0.1, 1.0)
	_npc_ai.write_memory(beggar_leader, "benefactor", target_id,
		state.world.current_tick, intensity)
	_npc_ai.write_memory(target_leader, "begged_at_me", beggar_id,
		state.world.current_tick, 0.2)
	_clear_aid_task(beggar)
	return { "ok": true, "accepted": true, "amount": give, "msg": "獲援助" }

func _count_recent_begs(leader: PersonData, beggar_id: int) -> int:
	var count: int = 0
	for m in leader.memory:
		if not (m is Dictionary): continue
		if m.get("type") == "begged_at_me" and m.get("subject_id") == beggar_id:
			count += 1
	return count

# 近期被同一 collector 特別稅次數（連續加徵厭煩疊加）
func _count_recent_special_tax(leader: PersonData, collector_id: int) -> int:
	if leader == null:
		return 0
	var count: int = 0
	for m in leader.memory:
		if not (m is Dictionary): continue
		if m.get("type") == "special_taxed" and m.get("subject_id") == collector_id:
			count += 1
	return count

func _clear_aid_task(beggar: TeamData) -> void:
	beggar.combat_target = -1
	if beggar.previous_task != "" and beggar.previous_task != TeamData.TASK_IDLE:
		# 恢復 survival 前的原 task（就地轉換，move_target 保留）
		TaskArbiter.transition(beggar, beggar.previous_task, TaskArbiter.PRIO_DISPATCH)
	else:
		TaskArbiter.release(beggar)
	beggar.previous_task = ""

# ──────── 安頓（invite_settle）執行 ────────

func _execute_settlement(state: WorldState, team_id: int, outpost_pos: Vector2i, faction_id: int) -> void:
	var t: TeamData = state.teams.get(team_id)
	if t == null: return
	t.tile_pos = outpost_pos
	if not t.tags.has(TeamData.TAG_PRODUCE):
		t.tags.append(TeamData.TAG_PRODUCE)
	t.tags.erase("流亡")
	t.faction_id = faction_id
	TaskArbiter.transition(t, "生產", TaskArbiter.PRIO_AMBIENT)
	t.move_target = Vector2i(-1, -1)
	# 加入 faction
	if faction_id != -1 and state.factions.has(faction_id):
		var f: FactionData = state.factions[faction_id]
		if not f.member_team_ids.has(team_id):
			f.member_team_ids.append(team_id)
	# 若該 outpost 已有同 faction PRODUCE team → 嘗試合併
	var existing: int = _find_existing_resident(state, outpost_pos, team_id, faction_id)
	if existing != -1:
		var fai := FactionAISystem.new()
		var cap: int = fai._outpost_pop_cap(state, outpost_pos)
		var et: TeamData = state.teams.get(existing)
		if et != null and et.population + t.population <= cap:
			SubteamSystem.new().merge_teams(state, existing, team_id, t.named_members)

func _find_existing_resident(state: WorldState, pos: Vector2i, exclude_id: int, faction_id: int = -2) -> int:
	for tid in state.teams:
		if tid == exclude_id: continue
		var t: TeamData = state.teams[tid]
		if t.tile_pos == pos and t.tags.has(TeamData.TAG_PRODUCE):
			if faction_id != -2 and t.faction_id != faction_id: continue
			return tid
	return -1

func _convert_to_resident(state: WorldState, subteam: TeamData) -> void:
	if not subteam.tags.has(TeamData.TAG_PRODUCE):
		subteam.tags.append(TeamData.TAG_PRODUCE)
	subteam.tags.erase(TeamData.TAG_SUBTEAM)
	subteam.tags.erase("流亡")
	TaskArbiter.transition(subteam, "生產", TaskArbiter.PRIO_AMBIENT)
	subteam.parent_team_id = -1
	print("[Settle] Team%d 安頓於 (%d,%d) 變居民" % [
		subteam.team_id, subteam.tile_pos.x, subteam.tile_pos.y])
	# 流民變居民後，若同 tile 有 SUBTEAM+PRODUCE 子隊（暫派駐居民），觸發回母團
	# 註：try_merge_back 可能因母團太遠失敗，則子隊留 outpost 與流民共處
	for tid in state.teams:
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if t.tile_pos != subteam.tile_pos: continue
		if t.team_id == subteam.team_id: continue
		if TeamData.TAG_SUBTEAM in t.tags and "生產" in t.tags:
			SubteamSystem.new().try_merge_back(state, t.team_id)

# ──────── 安撫（pacify）────────

func _resolve_pacify(state: WorldState, pacifier: TeamData, village: TeamData) -> void:
	for pid in ([village.leader_id] as Array) + village.named_members:
		var p = state.persons.get(pid)
		if p:
			p.stress = maxf(p.stress - 0.05, 0.0)
			p.loyalty = minf(p.loyalty + 0.02, 1.0)
	village.unrest_turns = maxi(village.unrest_turns - 1, 0)
