class_name InteractionSystem

# ──────── 貿易常數 ────────
# 估值表 BASE_PRICE / TARGET_PER_POP / SURVIVAL_GOODS 已移至 TradeValuation（單一真值源）。
# 本檔估值改 delegate TradeValuation.local_value；表引用走 TradeValuation.BASE_PRICE 等。
const FOOD_RESERVE_TICKS: float = TradeValuation.FOOD_RESERVE_TICKS   # 單一源 → TradeValuation
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
		if arrived.current_task == TeamData.TASK_ESCORT:
			continue
		# 空間索引：同格查取代全掃。live 復驗 has + tile_pos 保零行為變（容 mid-loop erase）。
		for other_id in state.teams_on_tile(arrived.tile_pos):
			if other_id == arrived_id:
				continue
			if not state.teams.has(other_id):
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
		if moved.current_task == TeamData.TASK_ESCORT:
			continue
		# 空間索引：同格查取代全掃。live 復驗 has + tile_pos 保零行為變（容 mid-loop erase）。
		for other_id in state.teams_on_tile(moved.tile_pos):
			if other_id == moved_id:
				continue
			if not state.teams.has(other_id):
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
		ResourceBank.set_amt(team, "food", food_avail - food_used, "readiness_food")
		var resource_factor: float = 0.3 + 0.7 * (food_used / maxf(food_needed, 0.001))
		var leader = state.persons.get(team.leader_id)
		var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
		var excess: float = clampf((cmd - 0.8) / 0.2, 0.0, 1.0)
		var recovery: float = READINESS_RECOVERY_BASE * (1.0 + excess * 0.5)
		state.set_readiness(team, minf(team.readiness + recovery * morale_factor * resource_factor, 1.0), "recovery")

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
	# 死路探針（純觀測，no-op unless Probe.enabled）：NPC-NPC BEG/JOIN 生命週期。
	# 此點在 player 分支之後 → 恆 NPC-NPC。dispatch = 到達核心互動的 BEG/JOIN 隊。
	if a.current_task == TeamData.TASK_BEG or b.current_task == TeamData.TASK_BEG:
		Probe.bump("beg.dispatch")
	if a.current_task == TeamData.TASK_JOIN or b.current_task == TeamData.TASK_JOIN:
		Probe.bump("join.dispatch")
	# attack→combat 漏斗探針（純觀測）：攻擊姿態隊到達同格 = 接觸事件。
	# reached = 到達可開打（combat_target==-1，下方 276 branch 會 start_combat）；
	# blocked_ct = 到達但 combat_target 已設 → 197 早退擋掉開打（路徑 B 凍死副作用）。
	if Probe.enabled:
		var a_atk: bool = a.current_task == TeamData.TASK_ATTACK or a.current_task == TeamData.TASK_LOOT
		var b_atk: bool = b.current_task == TeamData.TASK_ATTACK or b.current_task == TeamData.TASK_LOOT
		if a_atk or b_atk:
			if a.combat_target != -1 or b.combat_target != -1:
				Probe.bump("atk.blocked_ct_197")   # 同格但 combat_target 早退擋開打
			else:
				Probe.bump("atk.reached")           # 同格可開打（→ 276 branch）
	if a.combat_target != -1 or b.combat_target != -1:
		# 197 早退先於 247 BEG resolver。BEG/JOIN 恆設 combat_target → 恆走此路 → resolver 死路。
		if a.current_task == TeamData.TASK_BEG or b.current_task == TeamData.TASK_BEG:
			Probe.bump("beg.early_return_197")
		if a.current_task == TeamData.TASK_JOIN or b.current_task == TeamData.TASK_JOIN:
			Probe.bump("join.arrived_no_handler")
		return
	# 貿易：跨勢力均可，優先於外交/攻擊判斷
	if a.current_task == TeamData.TASK_TRADE or b.current_task == TeamData.TASK_TRADE:
		_resolve_market(state, a, b)
		return
	# 社交 resolver（BEG/JOIN）置於 same_faction 塊之前：aid/強鄰 finder 多偏好同 faction 對象
	# （_find_aid_target same_faction +1000），若置後 → same_faction 塊 early-return 吃掉 → 死路。
	# 社交跨/同 faction 均可 resolve（同 TRADE 跨勢力語意）。social_target 對上才 resolve。
	if a.current_task == TeamData.TASK_BEG and a.social_target == id_b:
		Probe.bump("beg.resolve")   # 死路探針：到此=NPC-NPC resolver 實呼（player 分支已提早 return）
		_resolve_aid_request(state, id_a, id_b)
		return
	if b.current_task == TeamData.TASK_BEG and b.social_target == id_a:
		Probe.bump("beg.resolve")
		_resolve_aid_request(state, id_b, id_a)
		return
	# JOIN resolver（新 handler）：投靠者全併入強鄰（複用 merge_teams full absorb，pop 守恆）。
	if a.current_task == TeamData.TASK_JOIN and a.social_target == id_b:
		_resolve_join(state, id_a, id_b)
		return
	if b.current_task == TeamData.TASK_JOIN and b.social_target == id_a:
		_resolve_join(state, id_b, id_a)
		return
	var same_faction: bool = a.faction_id != -1 and a.faction_id == b.faction_id
	if same_faction:
		if a.current_task == TeamData.TASK_TRIBUTE:
			_resolve_tribute(state, id_a, id_b)
		elif b.current_task == TeamData.TASK_TRIBUTE:
			_resolve_tribute(state, id_b, id_a)
		elif a.current_task == TeamData.TASK_HERALD and a.order_target_id == id_b:
			_deliver_order(state, id_a, id_b)
		elif b.current_task == TeamData.TASK_HERALD and b.order_target_id == id_a:
			_deliver_order(state, id_b, id_a)
		elif a.current_task == TeamData.TASK_IDLE and b.current_task == TeamData.TASK_IDLE:
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
		elif a.current_task == TeamData.TASK_SETTLE:
			var tile: HexTileData = state.world.tiles.get(a.tile_pos.x * 1000 + a.tile_pos.y)
			if tile and tile.outpost_owner != -1:
				var o: TeamData = state.teams.get(tile.outpost_owner)
				if o and o.faction_id == a.faction_id:
					_convert_to_resident(state, a)
		elif b.current_task == TeamData.TASK_SETTLE:
			var tile2: HexTileData = state.world.tiles.get(b.tile_pos.x * 1000 + b.tile_pos.y)
			if tile2 and tile2.outpost_owner != -1:
				var o2: TeamData = state.teams.get(tile2.outpost_owner)
				if o2 and o2.faction_id == b.faction_id:
					_convert_to_resident(state, b)
		elif a.current_task == TeamData.TASK_PACIFY and b.tags.has(TeamData.TAG_PRODUCE):
			_resolve_pacify(state, a, b)
		elif b.current_task == TeamData.TASK_PACIFY and a.tags.has(TeamData.TAG_PRODUCE):
			_resolve_pacify(state, b, a)
		return
	# ②a 信使外交送達：envoy（HERALD + envoy_proposal）遇 order_target → 委派 belief resolver。
	# 信使 faction 恆 ≠ target（建國兩獨立 or 母隊招募）→ 不入上方 same_faction herald 分支。
	if a.current_task == TeamData.TASK_HERALD and a.task_reason == "envoy_proposal" and a.order_target_id == id_b:
		_deliver_envoy_proposal(state, id_a, id_b)
		return
	if b.current_task == TeamData.TASK_HERALD and b.task_reason == "envoy_proposal" and b.order_target_id == id_a:
		_deliver_envoy_proposal(state, id_b, id_a)
		return
	if a.current_task == TeamData.TASK_DIPLOMACY:
		_try_diplomacy(state, id_a, id_b)
		return
	if b.current_task == TeamData.TASK_DIPLOMACY:
		_try_diplomacy(state, id_b, id_a)
		return
	if a.current_task == TeamData.TASK_ATTACK:
		_combat.start_combat(state, id_a, id_b)
	elif b.current_task == TeamData.TASK_ATTACK:
		_combat.start_combat(state, id_b, id_a)
	elif a.current_task == TeamData.TASK_LOOT and a.readiness >= COMBAT_THRESHOLD:
		# F-I2：屈服判斷統一走 DiplomaticAiSystem.tribute_accept（同格勒索=兵臨城下 threat=raider readiness）
		if DiplomaticAiSystem.tribute_accept(state, b, a, a.readiness):
			_probe_raid(state, a, b, "extort")
			_resolve_extortion(state, id_a, id_b)
		elif _should_attack(state, id_a, id_b):
			_probe_raid(state, a, b, "combat")
			_combat.start_combat(state, id_a, id_b)
		else:
			_probe_raid(state, a, b, "noop")
	elif b.current_task == TeamData.TASK_LOOT and b.readiness >= COMBAT_THRESHOLD:
		if DiplomaticAiSystem.tribute_accept(state, a, b, b.readiness):
			_probe_raid(state, b, a, "extort")
			_resolve_extortion(state, id_b, id_a)
		elif _should_attack(state, id_b, id_a):
			_probe_raid(state, b, a, "combat")
			_combat.start_combat(state, id_b, id_a)
		else:
			_probe_raid(state, b, a, "noop")

# ──────── 決策函式 ────────

func _should_attack(state: WorldState, atk_id: int, def_id: int) -> bool:
	var atk: TeamData = state.teams[atk_id]
	var leader: PersonData = state.persons.get(atk.leader_id)
	if leader == null:
		return false
	# F-I7 belief-gate：無情報 → 保守不攻（G3-E「無估 fallback=不行動」，不偷看真值）
	if not BeliefSystem.has_belief(state, atk_id, def_id):
		return false
	var ambition: float  = float(leader.values.get("野心", 0.5))
	var caution: float   = float(leader.values.get("慎重", 0.5))
	var greed: float     = float(leader.values.get("貪婪", 0.5))
	var martial: float   = float(leader.values.get("好戰", 0.5))
	# F-I7：對方實力讀 believed armed_est（tier2 偽裝/虛張在此咬），退 pop_est；自身讀真 armed
	var bel: Dictionary = BeliefSystem.best_estimate(state, atk_id, def_id)
	var own_armed: float = maxf(float(_combat.calc_armed(state, atk)), 1.0)
	var def_est: float = float(bel.get("armed_est", bel.get("population_est", own_armed)))
	var str_ratio: float = own_armed / maxf(def_est, 1.0)
	var score: float = ambition * 0.3 + martial * 0.3 + greed * 0.2 + (str_ratio - 1.0) * 0.2 - caution * 0.5
	return score > 0.0


func _resolve_extortion(state: WorldState, atk_id: int, def_id: int) -> Dictionary:
	var atk: TeamData = state.teams[atk_id]
	var def: TeamData = state.teams[def_id]
	var gained: Dictionary = {}
	for res in ["food", "material", "goods", "coin"]:
		var tribute: float = float(def.resources.get(res, 0)) * TRIBUTE_RATE
		if tribute > 0.0:
			ResourceBank.add(atk, res, tribute, "extort_in")
			ResourceBank.add(def, res, -tribute, "extort_out")
			gained[res] = tribute
	_msg.emit_message(state, "extortion",
		"Team %d 向 Team %d 收過路費" % [atk_id, def_id], atk,
		{ "origin": str(atk_id), "target": str(def_id) })
	print("[Extort] Team%d 勒索 Team%d，Team%d 妥協給付" % [atk_id, def_id, def_id])
	return gained

# Task1 measure（純觀測，佔村 spec）：raid（TASK_LOOT）解決分佈探針。
# extort（無戰）/ combat_at_outpost（落點村格 → capture 可翻）/ combat_open_field（開闊地 → capture no-op）/ noop（想搶未成）。
# + prey residency：resident 村隊（TAG_PRODUCE 且站自家 outpost）vs 流浪隊 → 驗「追擊撞開闊地=capture 永 no-op」假說。
func _probe_raid(state: WorldState, raider: TeamData, prey: TeamData, mode: String) -> void:
	if not Probe.enabled: return
	Probe.bump("raid.resolve")
	var tile: HexTileData = state.world.tiles.get(prey.tile_pos.x * 1000 + prey.tile_pos.y)
	var at_outpost: bool = tile != null and tile.outpost_level > 0
	match mode:
		"extort": Probe.bump("raid.extort")
		"combat": Probe.bump("raid.combat_at_outpost" if at_outpost else "raid.combat_open_field")
		"noop":   Probe.bump("raid.loot_noresolve")
	var prey_resident: bool = prey.tags.has(TeamData.TAG_PRODUCE) and tile != null \
		and tile.outpost_owner == prey.team_id
	Probe.bump("raid.prey_resident" if prey_resident else "raid.prey_wanderer")

# ──────── 勢力互動 ────────

func subjugate_team(state: WorldState, winner_id: int, loser_id: int) -> void:
	_combat.subjugate_team(state, winner_id, loser_id)

# F-I1 統一：接受判定退役 god-view team_strength 公式，一律委派 handle_diplomacy_message
# （belief+人格，單一 judge）。同格偶遇談判 = 送達管道之一，決策公式與信使送達同源。
# faction 招募/建國動作由 _form_alliance 完成（handle_diplomacy_message accept 內呼）。
func _try_diplomacy(state: WorldState, initiator_id: int, target_id: int) -> void:
	var initiator: TeamData = state.teams[initiator_id]
	var target: TeamData    = state.teams[target_id]
	if initiator.faction_id != -1 and initiator.faction_id == target.faction_id:
		return
	if state.persons.get(target.leader_id) == null:
		return
	var resp: String = DiplomaticAiSystem.new().handle_diplomacy_message(
		state, target, initiator, "propose_alliance")
	if resp != "accept":
		# 拒 → 發起方 cooldown（防同對象連發），不成盟
		initiator.diplomacy_reject_cooldown[target_id] = \
			state.world.current_tick + DiplomaticAiSystem.REJECT_COOLDOWN
		return
	# accept：faction 動作（create_faction/招募）已由 _form_alliance 完成。release + 訊息（telemetry）。
	TaskArbiter.release(initiator)
	_msg.emit_message(state, "diplomacy",
		TextBank.fmt("diplomacy", "honest", {
			"origin": str(initiator_id), "target": str(target_id)
		}),
		initiator,
		{ "origin": str(initiator_id), "target": str(target_id), "faction": str(target.faction_id) })
	print("[Faction] Team%d 外交 Team%d accept → 勢力%d" % [initiator_id, target_id, target.faction_id])

# ②a 信使送達：envoy 遇 target → 委派 belief resolver（同 judge，與同格偶遇同源）。
# 冗餘去重：母隊 pending_proposal 為權威，proposal_id 首達生效、後到 no-op。送達後信使歸隊。
func _deliver_envoy_proposal(state: WorldState, envoy_id: int, target_id: int) -> void:
	var envoy: TeamData = state.teams[envoy_id]
	var target: TeamData = state.teams[target_id]
	var mother: TeamData = state.teams.get(envoy.parent_team_id)
	var carried_pid: String = String(envoy.task_extra_data.get("proposal_id", ""))
	# 去重：母隊消失 / pending 已清（他騎首達）/ proposal_id 不符 → no-op，信使歸隊
	if mother == null or mother.pending_proposal.is_empty() \
			or String(mother.pending_proposal.get("proposal_id", "")) != carried_pid:
		_recall_envoy_home(state, envoy)
		return
	if state.persons.get(target.leader_id) == null:
		_recall_envoy_home(state, envoy)
		return
	Probe.bump("envoy.delivered")
	# 誘因結盟：禮隨提案送達（權威存母隊 pending_proposal.gift，發起時已扣）。
	# 決策委派 belief judge（禮值入 score→雪中送炭推過門檻；accept 內 _form_alliance 完成 create_faction）。
	# 禮轉移目標（守恆:發起扣=送達收）——accept/reject 皆轉（拒者白得=亂世，reject 不退禮，最小 slice 無口碑鉤）。
	# 信使死/timeout=禮沉沒（pending 清時已扣不退，不走此路）。冗餘去重（line 396）保證只轉一次。
	var gift: Dictionary = mother.pending_proposal.get("gift", {})
	var resp: String = DiplomaticAiSystem.new().handle_diplomacy_message(
		state, target, mother, "propose_alliance", gift)
	for res in gift:
		var amt: float = float(gift[res])
		if amt > 0.0:
			ResourceBank.add(target, res, amt, "alliance_gift")
			Probe.bump("envoy.gift_delivered")
	if resp == "accept":
		Probe.bump("envoy.accept")
		print("[Envoy] Team%d 提案送達 Team%d → accept（發起 Team%d）" % [
			envoy_id, target_id, mother.team_id])
	else:
		Probe.bump("envoy.reject")
		mother.diplomacy_reject_cooldown[target_id] = \
			state.world.current_tick + DiplomaticAiSystem.REJECT_COOLDOWN
		print("[Envoy] Team%d 提案送達 Team%d → reject" % [envoy_id, target_id])
	mother.pending_proposal = {}   # 消費提案（首達生效，後到騎 no-op）
	_recall_envoy_home(state, envoy)

# 信使送達/落空後歸隊：釋放 task + 朝母隊移動（到母格 process_on_arrival try_merge_back 併回）。
func _recall_envoy_home(state: WorldState, envoy: TeamData) -> void:
	TaskArbiter.release(envoy)
	envoy.task_reason = "envoy_recall"
	envoy.order_target_id = -1
	var parent: TeamData = state.teams.get(envoy.parent_team_id)
	if parent != null:
		envoy.move_target = parent.tile_pos
	else:
		state.detach_subteam(envoy)            # 母隊已亡 → 脫離成獨立（非 zombie）
		state.remove_tag(envoy, TeamData.TAG_SUBTEAM, "envoy_orphan")

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
			ResourceBank.set_amt(payer, res, stock - take, "raid_out")
			ResourceBank.add(collector, res, take, "raid_in")
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
			LoyaltyBank.adjust(p, -loyalty_loss, "extort")
			p.fear    = minf(p.fear    + fear_gain,    1.0)
		if rate > 0.5:
			UnrestBank.add(payer, 1, "tax")
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
	# S6 施工子隊豁免：建造/升級/擴建子隊是 collector 自己的派遣隊，不得逆向抽稅
	var _BUILDER_TASKS: Array = [TeamData.TASK_CONSTRUCT, TeamData.TASK_BUILD,
		TeamData.TASK_UPGRADE, TeamData.TASK_EXPAND]
	if payer.tags.has(TeamData.TAG_SUBTEAM) and payer.parent_team_id == collector_id \
			and payer.current_task in _BUILDER_TASKS:
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
		ResourceBank.add(payer, res, -amount, "tribute_out")
		ResourceBank.add(collector, res, amount, "tribute_in")
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
	var order: String = messenger.order_task if messenger.order_task != "" else TeamData.TASK_IDLE
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

# 公開存取（DTO 估值用）：估值單一源 TradeValuation，trade_session DTO 經此取單價
func local_value(team: TeamData, res: String) -> float:
	return TradeValuation.local_value(team, res)

# ──────── 雙向 market 結算（取代舊 _resolve_trade）────────

func _calc_reserve(team: TeamData, res: String) -> float:
	# 留底邏輯收進 TradeValuation.reserve（單一源），NPC + 玩家路徑同用。
	return TradeValuation.reserve(team, res)

func _execute_transfer(seller: TeamData, buyer: TeamData, res: String, qty: int, price: float) -> void:
	ResourceBank.add(seller, res, -qty, "trade_goods_out")
	ResourceBank.add(buyer, res, qty, "trade_goods_in")
	ResourceBank.add(buyer, "coin", -(qty * price), "trade_coin_out")
	ResourceBank.add(seller, "coin", qty * price, "trade_coin_in")

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
		ResourceBank.set_amt(team, res, team_amount + public_amount, "borrow_public")
		TileBank.set_amt(tile, res, 0.0, "borrow_public_out")   # MOVE 出公庫（避免雙重存在，spill_back 再分流回去）
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
			TileBank.set_amt(tile, res, stored + deposit, "spill_back")
			ResourceBank.set_amt(team, res, orig + (diff - deposit), "spill_back")
		else:
			# team 賣掉超過借出的公庫量（連自家底貨也動了）→ 公庫歸零，team 保留實際剩餘（不憑空生）
			TileBank.set_amt(tile, res, maxf(stored + diff, 0.0), "spill_back_overdraw")
			ResourceBank.set_amt(team, res, current, "spill_back_overdraw")

func _resolve_market(state: WorldState, a: TeamData, b: TeamData) -> void:
	# 漏斗站5/6探針（純觀測）：TRADE 隊同格會合分類（到點 vs 途中被截胡）
	if Probe.enabled:
		for _pt in [a, b]:
			if _pt.current_task == TeamData.TASK_TRADE:
				Probe.bump("trade.meet")
				if _pt.move_target != Vector2i(-1, -1) and _pt.tile_pos != _pt.move_target:
					Probe.bump("trade.meet_midroute")
	var a_original: Dictionary = _absorb_public_storage(state, a)
	var b_original: Dictionary = _absorb_public_storage(state, b)
	var a_coin_before: float = float(a.resources.get("coin", 0))
	# 履約：交易窗前快照各隊 active_order 涉及的 res 持有（窗內 = 私有+吸入公庫 = 完整持有）
	var a_before: Dictionary = _snapshot_order_res(a)
	var b_before: Dictionary = _snapshot_order_res(b)
	_attempt_trade_direction(state, a, b)
	_attempt_trade_direction(state, b, a)
	_attempt_barter(state, a, b)   # 缺幣互補：以物易物（coin 換完後）
	# 履約結算（spillback 前，team.resources 仍 = 完整持有）
	var _os := OrderSystem.new()
	var a_prog: bool = _os.settle_orders(a, a_before, state.world.current_tick)
	var b_prog: bool = _os.settle_orders(b, b_before, state.world.current_tick)
	if (a_prog and b.tags.has(TeamData.TAG_MERCHANT)) or (b_prog and a.tags.has(TeamData.TAG_MERCHANT)):
		Probe.bump("g1.arb_hit")
	var _dealt: bool = absf(float(a.resources.get("coin", 0)) - a_coin_before) > 0.001
	if _dealt:
		print("[Market] Team%d <-> Team%d 成交（公庫接入）" % [a.team_id, b.team_id])
		# 漏斗站6探針：成交主體分流（商隊跑單 vs resident 互售）
		Probe.bump("trade.deal")
		if a.tags.has(TeamData.TAG_MERCHANT) or b.tags.has(TeamData.TAG_MERCHANT):
			Probe.bump("trade.deal_merchant")
		else:
			Probe.bump("trade.deal_resident")
	elif Probe.enabled and (a.current_task == TeamData.TASK_TRADE or b.current_task == TeamData.TASK_TRADE):
		Probe.bump("trade.meet_nodeal")   # 漏斗站6：會合但零成交（撲空/沒貨/價差不成）
	_spill_back_public_storage(state, a, a_original)
	_spill_back_public_storage(state, b, b_original)
	# 途中相遇=機會交易，交易完續程（不棄單）；到點（move_target 已清/同格）才 release 重評。
	# 舊行為任意同格相遇即 release → 商隊途中碰任何隊=棄單（漏斗 release_midroute 定罪）。
	# 續程仍有界：TRADE_TIMEOUT 6 日 + 高優先 task 可搶（latch 必 timeout 守住）。
	if a.current_task == TeamData.TASK_TRADE:
		if a.move_target == Vector2i(-1, -1) or a.tile_pos == a.move_target:
			Probe.bump("trade.release_at_dest")
			TaskArbiter.release(a)
		else:
			Probe.bump("trade.continue_midroute")   # 漏斗站5：機會交易後續程
	if b.current_task == TeamData.TASK_TRADE:
		if b.move_target == Vector2i(-1, -1) or b.tile_pos == b.move_target:
			Probe.bump("trade.release_at_dest")
			TaskArbiter.release(b)
		else:
			Probe.bump("trade.continue_midroute")

func _snapshot_order_res(team: TeamData) -> Dictionary:
	var snap: Dictionary = {}
	for o in team.active_orders:
		var res: String = o["res"]
		if not snap.has(res):
			snap[res] = float(team.resources.get(res, 0))
	return snap

func _attempt_trade_direction(state: WorldState, seller: TeamData, buyer: TeamData) -> void:
	var buyer_coin: float = float(buyer.resources.get("coin", 0))
	if buyer_coin <= 0.0: return
	var ms := MovementSystem.new()   # WS-3：buyer 進貨受 carry 空間限（throughput + 馬車 load-bearing）
	var s_leader = state.persons.get(seller.leader_id)
	var commerce: float = float(s_leader.skills.get("商業", 0.0)) if s_leader else 0.0
	# (1) seller 商隊優先賣 inventory（買低賣高賺差價）
	if seller.tags.has(TeamData.TAG_MERCHANT):
		var inv_copy: Array = seller.merchant_inventory.duplicate()
		for item in inv_copy:
			if int(item.get("bought_from", -1)) == buyer.team_id: continue
			var inv_bid: float = TradeValuation.local_value(buyer, item["grade"])
			if inv_bid <= float(item["bought_at"]): continue
			var inv_qty: int = mini(int(item["qty"]), int(buyer_coin / inv_bid))
			inv_qty = mini(inv_qty, ms.carry_space_for_res(buyer, item["grade"]))   # WS-3 carry 限
			if inv_qty <= 0: continue
			ResourceBank.add(buyer, item["grade"], inv_qty, "market_inv_in")
			ResourceBank.add(buyer, "coin", -(inv_qty * inv_bid), "market_inv_coin_out")
			ResourceBank.add(seller, "coin", inv_qty * inv_bid, "market_inv_coin_in")
			item["qty"] = int(item["qty"]) - inv_qty
			buyer_coin -= inv_qty * inv_bid
		seller.merchant_inventory = seller.merchant_inventory.filter(
			func(it): return int(it.get("qty", 0)) > 0)
	# (2) 賣 surplus（保留最低儲備）
	for res in TradeValuation.BASE_PRICE.keys():
		var stock: float = float(seller.resources.get(res, 0))
		var reserve: float = _calc_reserve(seller, res)
		var surplus: float = maxf(stock - reserve, 0.0)
		if surplus <= 0.0: continue
		var ask: float = TradeValuation.local_value(seller, res) * (1.0 - commerce * 0.1)
		var bid: float = TradeValuation.local_value(buyer, res)
		if ask <= 0.0 or ask >= bid: continue
		var qty: int = mini(int(surplus), int(buyer_coin / ask))
		qty = mini(qty, ms.carry_space_for_res(buyer, res))   # WS-3 carry 限（買方滿載即止買）
		if qty <= 0: continue
		_execute_transfer(seller, buyer, res, qty, ask)
		buyer_coin -= qty * ask
		# 買方若是商隊 → 物品移到 inventory（之後高價賣出）
		if buyer.tags.has(TeamData.TAG_MERCHANT):
			ResourceBank.add(buyer, res, -qty, "merchant_stock")
			buyer.merchant_inventory.append({
				"grade": res, "qty": qty, "bought_at": ask, "bought_from": seller.team_id
			})

# 以物易物：a 的 surplus(b 想要) ↔ b 的 surplus(a 想要)，按 local_value 等值互換。
# 處理缺幣團互補 surplus（coin 路徑換不了）。不碰 coin，coin_eq 守恆。
func _attempt_barter(state: WorldState, a: TeamData, b: TeamData) -> void:
	# a 可給的（a surplus 且 b 缺=b 想要）
	for give_res in TradeValuation.BASE_PRICE.keys():
		if give_res == "coin": continue
		var a_surplus: float = maxf(float(a.resources.get(give_res, 0)) - TradeValuation.reserve(a, give_res), 0.0)
		if a_surplus <= 0.0: continue
		# b 是否想要（b 對該 res 估值 > a 對該 res 估值,即 b 較缺）
		if TradeValuation.local_value(b, give_res) <= TradeValuation.local_value(a, give_res): continue
		# 找 b 能回付的（b surplus 且 a 想要）
		for pay_res in TradeValuation.BASE_PRICE.keys():
			if pay_res == "coin" or pay_res == give_res: continue
			var b_surplus: float = maxf(float(b.resources.get(pay_res, 0)) - TradeValuation.reserve(b, pay_res), 0.0)
			if b_surplus <= 0.0: continue
			if TradeValuation.local_value(a, pay_res) <= TradeValuation.local_value(b, pay_res): continue
			# 等值互換：以雙方各自估值算可換量,取較小值的一筆
			var give_val: float = TradeValuation.local_value(b, give_res)   # b 願付的單價
			var pay_val: float  = TradeValuation.local_value(a, pay_res)    # a 願收的單價
			var give_qty: int = int(minf(a_surplus, b_surplus * pay_val / maxf(give_val, 0.001)))
			if give_qty <= 0: continue
			var pay_qty: int = int(round(give_qty * give_val / maxf(pay_val, 0.001)))
			if pay_qty <= 0 or pay_qty > int(b_surplus): continue
			# 執行互換（不碰 coin）
			ResourceBank.add(a, give_res, -give_qty, "barter_give_out")
			ResourceBank.add(b, give_res, give_qty, "barter_give_in")
			ResourceBank.add(b, pay_res, -pay_qty, "barter_pay_out")
			ResourceBank.add(a, pay_res, pay_qty, "barter_pay_in")
			print("[Barter] Team%d %dx%s <-> Team%d %dx%s" % [a.team_id, give_qty, give_res, b.team_id, pay_qty, pay_res])
			Probe.bump("trade.barter_deal")   # 漏斗站6：以物易物成交（coin 路徑外）
			break   # 一個 give_res 換一筆即可,下個 give_res

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
	var snap: Dictionary = BeliefSystem.best_estimate(state, obs_id, tgt_id).duplicate()
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
	# F-I4：欺敵三塊（偽裝平民/虛張聲勢/謊稱勢力）收斂至 DistortionEngine（單一失真 owner）
	DistortionEngine.apply_observation_deception(state, snap, tgt, tgt_leader, actual_armed)
	# G3c-2 觀察吃技能：observer 戰術低 → 看不懂武裝 → armed_est 疊誤判（cred 仍 1.0）
	var obs_leader2: PersonData = state.persons.get((state.teams.get(obs_id) as TeamData).leader_id) if state.teams.has(obs_id) else null
	var tactic: float = float(obs_leader2.skills.get("戰術", 0.0)) if obs_leader2 else 0.0
	var armed_noise: float = BeliefSystem.observation_noise(0.0, tactic)
	snap["armed_est"] = maxi(0, roundi(float(snap["armed_est"]) * randf_range(1.0 - armed_noise, 1.0 + armed_noise)))
	var cred: float = BeliefSystem.source_credibility(state, obs_id, "親見", obs_id, 0)
	BeliefSystem.record_claim(state, obs_id, tgt_id, obs_id, "親見", snap, cred, false)

# 處決俘虜：呼叫者負責移除 NPC；此函數只結算目擊者 loyalty 懲罰
func execute_prisoner(state: WorldState, team_id: int) -> void:
	var team: TeamData = state.teams.get(team_id)
	if team == null: return
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		var yi_qi: float = float(p.values.get("義氣", 0.5))
		LoyaltyBank.adjust(p, -yi_qi * 0.08, "atrocity")
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
		# F-I2 統一公式（同格勒索=兵臨城下 threat=aggressor readiness）
		if not DiplomaticAiSystem.tribute_accept(state, to_t, from_t, from_t.readiness):
			print("[Extort] Team%d 拒絕勒索" % target_id)
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
	var need: float = float(beggar.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 3.0 \
		- float(beggar.resources.get("food", 0))
	var beggar_starving: bool = float(beggar.resources.get("food", 0)) \
		< float(beggar.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
	var mercy_amount: float = float(beggar.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY   # 1 天份
	# 慷慨光譜：留存(reserve)與給予比例(give_fraction)由個性兩極決定（取代 flat AID_RESERVE_DAYS）
	# 守財奴(高貪低義) hoard→1 → reserve 近 60 天、give_fraction≈0；聖人(高義低貪) → reserve 2 天、可動 reserve
	var hoard: float = greed - honor                           # [-1,1]
	var reserve_days: float = lerpf(2.0, 60.0, (hoard + 1.0) / 2.0)
	var target_food: float = float(target.resources.get("food", 0))
	var reserve: float = float(target.population) * reserve_days * ResourceSystem.FOOD_PER_PERSON_PER_DAY
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
		_clear_aid_task(state, beggar)
		return { "ok": true, "accepted": false, "msg": "拒絕" }
	# 有給予意願但 reserve 吃光 surplus → 無餘糧
	if give <= 0.0:
		_msg.emit_message(state, "aid_refused",
			"Team%d 無餘糧 Team%d" % [target_id, beggar_id], target,
			{ "origin": str(target_id), "target": str(beggar_id) })
		_clear_aid_task(state, beggar)
		return { "ok": true, "accepted": false, "msg": "無餘糧" }
	ResourceBank.set_amt(target, "food", target_food - give, "aid_out")
	ResourceBank.add(beggar, "food", give, "aid_in")
	_msg.emit_message(state, "aid_given",
		"Team%d 援助 Team%d %.0f 食物" % [target_id, beggar_id, give], target,
		{ "origin": str(target_id), "target": str(beggar_id), "amount": "%.0f" % give })
	beggar.update_reputation(target_id, 0.15)
	var intensity: float = clampf(give / maxf(need, 1.0), 0.1, 1.0)
	_npc_ai.write_memory(beggar_leader, "benefactor", target_id,
		state.world.current_tick, intensity)
	_npc_ai.write_memory(target_leader, "begged_at_me", beggar_id,
		state.world.current_tick, 0.2)
	_clear_aid_task(state, beggar)
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

# 投靠 resolver：joiner 全併入 host（複用既有 merge_teams full absorb，pop 守恆轉移）。
# host = joiner 的 social_target（強鄰）。joiner 完全併入後滅團（merge_teams 內走 erase_team）。
func _resolve_join(state: WorldState, joiner_id: int, host_id: int) -> void:
	var joiner: TeamData = state.teams.get(joiner_id)
	var host: TeamData = state.teams.get(host_id)
	if joiner == null or host == null:
		return
	Probe.bump("join.resolve")   # 死路探針：JOIN handler 實呼（前 62/66 靜默 fall-through）
	var all_npcs: Array = []
	if joiner.leader_id != -1: all_npcs.append(joiner.leader_id)
	all_npcs.append_array(joiner.named_members)
	SubteamSystem.new().merge_teams(state, host_id, joiner_id, all_npcs)

func _clear_aid_task(state: WorldState, beggar: TeamData) -> void:
	state.clear_social_target(beggar)
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
		state.add_tag(t, TeamData.TAG_PRODUCE, "settle")
	state.remove_tag(t, "流亡", "settle")
	state.set_team_faction(t, faction_id)   # 安頓入 faction（雙向同步）
	TaskArbiter.transition(t, "生產", TaskArbiter.PRIO_AMBIENT)
	t.move_target = Vector2i(-1, -1)
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
		state.add_tag(subteam, TeamData.TAG_PRODUCE, "convert_resident")
	state.remove_tag(subteam, TeamData.TAG_SUBTEAM, "convert_resident")
	state.remove_tag(subteam, "流亡", "convert_resident")
	TaskArbiter.transition(subteam, "生產", TaskArbiter.PRIO_AMBIENT)
	state.detach_subteam(subteam)   # 變居民脫離母團（雙向同步）
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
			LoyaltyBank.adjust(p, 0.02, "pacify")
	UnrestBank.reduce(village, 1, "pacify")
