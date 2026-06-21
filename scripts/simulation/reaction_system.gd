class_name ReactionSystem

const GOAL_CHECK_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時
const BREED_BASE_CHANCE: float = 0.15   # TEST VALUE

var _npc_ai: NpcAiSystem

func _init() -> void:
	_npc_ai = NpcAiSystem.new()

func evaluate_all(state: WorldState, team_ids: Array, skill_sys: Object = null) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null:
			continue
		var flee_count: int = 0
		var morale_acc: float = 0.0
		var morale_n: int = 0
		for pid in state.persons:
			var person: PersonData = state.persons[pid]
			if person.team_id != tid:
				continue
			if state.world.current_tick % GOAL_CHECK_INTERVAL == 0:
				_update_goals(person)
				var alignment: float = _npc_ai.check_goal_alignment(person, team.current_task)
				LoyaltyBank.adjust(person, alignment, "goal_alignment")
			var reaction: String = _evaluate_person(person, team)
			if reaction != "none":
				_apply_reaction(state, person, team, reaction)
				if skill_sys != null:
					skill_sys.on_reaction(person, reaction)
			# 生命事件（獨立於行動反應，可並行）
			for ev in _evaluate_life_events(person, team):
				_apply_life_event(state, person, team, ev)
			if reaction == "N1_flee":
				flee_count += 1
			match reaction:
				"P2_produce": morale_acc += 1.0; morale_n += 1
				"N4_shirk":   morale_acc -= 1.0; morale_n += 1
				"none":       pass
				_:            morale_n += 1   # 其他 reaction 中性計入
		if morale_n > 0:
			var target_morale: float = clampf(1.0 + (morale_acc / float(morale_n)) * 0.5, 0.5, 1.5)
			team.work_morale = clampf(lerpf(team.work_morale, target_morale, 0.1), 0.5, 1.5)
		if flee_count > 0 and float(flee_count) / maxf(team.population, 1) >= 0.3 \
				and team.leader_id != state.player_id:   # 玩家主隊直接控,不被恐慌劫持 task
			if team.current_task not in [TeamData.TASK_FLEE, TeamData.TASK_ESCORT]:
				var threat_id: int = _find_top_threat(state, team)
				if threat_id != -1:
					var threat: TeamData = state.teams[threat_id]
					# 恐慌逃跑 = PRIO_THREAT (70)：蓋不動 survival (80) → ping-pong 結構性消失
					if TaskArbiter.try_set(state, team, TeamData.TASK_FLEE,
							_flee_target_simple(state, team, threat),
							TaskArbiter.PRIO_THREAT, "bridge_panic"):
						print("[ReactionBridge] Team%d 逃跑（%d/%d 人）← threat Team%d" % [
							tid, flee_count, team.population, threat_id])
				# 無威脅 → 不劫持 task（內心恐慌但無處可逃）

# 主動攻擊戰敗 → named 成員忠誠降、leader 壓力升（無硬性 cooldown，純 reaction）
func on_attack_defeat(state: WorldState, team_id: int, pop_loss_ratio: float) -> void:
	var team: TeamData = state.teams.get(team_id)
	if team == null: return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var honor: float = float(leader.values.get("義氣", 0.5))
	var faith: float = float(leader.values.get("信義", 0.5))
	var caution: float = float(leader.values.get("慎重", 0.5))
	var loyalty_delta: float = -0.1 * (honor + faith) / 2.0
	var stress_delta: float = 0.2 * caution
	if pop_loss_ratio > 0.3:
		loyalty_delta *= 2.0
		stress_delta *= 1.5
	for pid in team.named_members:
		var p: PersonData = state.persons.get(int(pid))
		if p == null: continue
		LoyaltyBank.adjust(p, loyalty_delta, "attack_defeat")
	leader.stress = clampf(leader.stress + stress_delta, 0.0, 1.0)
	print("[AttackDefeat] Team%d 戰敗 loss=%.2f loyalty_d=%.3f stress_d=%.3f" % [
		team_id, pop_loss_ratio, loyalty_delta, stress_delta])

func _has_goal_type(person: PersonData, type: String) -> bool:
	for g in person.goals:
		if g is Dictionary and g.get("type", "") == type:
			return true
	return false

func _erase_goal_type(person: PersonData, type: String) -> void:
	for i in range(person.goals.size() - 1, -1, -1):
		var g = person.goals[i]
		if g is Dictionary and g.get("type", "") == type:
			person.goals.remove_at(i)

func _update_goals(person: PersonData) -> void:
	var ambition: float = float(person.values.get("野心", 0.5))
	var survival: float = float(person.values.get("求生欲", 0.5))
	var greed: float = float(person.values.get("貪婪", 0.5))
	var loyalty_val: float = float(person.values.get("義氣", 0.5))

	if ambition > 0.7 and not _has_goal_type(person, "domination"):
		person.goals.append({ "type": "domination", "target_id": -1, "active": true })
	if survival > 0.7 and person.stress > 0.5 and not _has_goal_type(person, "wealth"):
		person.goals.append({ "type": "wealth", "target_id": -1, "active": true })
	if greed > 0.7 and not _has_goal_type(person, "wealth"):
		person.goals.append({ "type": "wealth", "target_id": -1, "active": true })
	if loyalty_val > 0.7:
		_erase_goal_type(person, "escape_war")
		_erase_goal_type(person, "revenge")

func _evaluate_person(person: PersonData, team: TeamData) -> String:
	var scores: Dictionary = {
		"P1_comply":  _score_comply(person, team),
		"P2_produce": _score_produce(person, team),
		"P4_expand":  _score_expand(person, team),
		"N1_flee":    _score_flee(person, team),
		"N2_riot":    _score_riot(person, team),
		"N3_defect":  _score_defect(person, team),
		"N4_shirk":   _score_shirk(person, team),
		"N5_extort":  _score_extort(person, team),
		"none":       0.2,
	}
	for key in scores:
		scores[key] = float(scores[key]) + _goal_bonus(person, key)

	var best: String = "none"
	var best_score: float = 0.0
	for key in scores:
		var s: float = float(scores[key])
		if s > best_score:
			best_score = s
			best = key
	return best

func _goal_bonus(person: PersonData, reaction: String) -> float:
	var bonus: float = 0.0
	for goal in person.goals:
		if not (goal is Dictionary):
			continue
		var gtype: String = goal.get("type", "")
		match gtype:
			"escape_war", "wealth":
				if reaction == "N1_flee": bonus += 0.2
			"domination":
				if reaction == "P4_expand": bonus += 0.35
			"revenge":
				if reaction in ["N2_riot", "N3_defect"]: bonus += 0.2
	return bonus

func _score_comply(p: PersonData, _t: TeamData) -> float:
	var base: float = p.loyalty * (1.0 - p.stress) * 0.8
	base += float(p.values.get("義氣", 0.5)) * 0.2
	base -= float(p.values.get("野心", 0.5)) * 0.1
	return base

func _score_produce(p: PersonData, t: TeamData) -> float:
	var food_ok: bool = float(p.needs.get("food", 1.0)) > 0.6
	var active: bool = food_ok and p.stress < 0.4 \
		and (t.tags.has("生產") or t.current_task == TeamData.TASK_PRODUCE)
	var base: float = 0.6 if active else 0.1
	base += float(p.skills.get("生產", 0.0)) * 0.4
	base += float(p.values.get("慎重", 0.5)) * 0.1
	return base

func _score_expand(p: PersonData, t: TeamData) -> float:
	var food: float = float(t.resources.get("food", 0))
	var base: float = 0.55 if (food > 100.0 and p.stress < 0.3 and t.tags.has("統領")) else 0.05
	base += float(p.skills.get("統領", 0.0)) * 0.3
	base += float(p.values.get("野心", 0.5)) * 0.3
	base += float(p.skills.get("戰術", 0.0)) * 0.2
	return base

func _score_breed(p: PersonData, t: TeamData) -> float:
	var safe: bool = float(p.needs.get("safety", 1.0)) > 0.7
	var fed: bool = float(p.needs.get("food", 1.0)) > 0.7
	var minor_cap: int = int(t.population * 0.2)
	var base: float = 0.4 if (safe and fed and t.minor_population < minor_cap) else 0.0
	base += float(p.skills.get("醫療", 0.0)) * 0.1
	return base

# 兩性平衡因子(0..1)：全單性→0(不繁衍);越平衡越高。
# anon 用 team.anon_female_ratio 估男女數;named 性別取不到 state.persons(本系統簽名 (p,t) 無 state)，
# 退而用 breeder 自身 sex 近似計入一方(approximation;系統可後續改簽名傳 state 精修)。
func _breed_balance(team: TeamData, breeder_sex: String = "") -> float:
	var anon_total: int = AnonTierSystem.total_pop(team)
	var m: float = float(anon_total) * (1.0 - team.anon_female_ratio)
	var f: float = float(anon_total) * team.anon_female_ratio
	if breeder_sex == "male":
		m += 1.0
	elif breeder_sex == "female":
		f += 1.0
	if minf(m, f) <= 0.0:
		return 0.0
	return minf(m, f) / maxf((m + f) / 2.0, 1.0)

# 生命事件層（與行動反應並行，winner-take-all 不適用）
func _evaluate_life_events(p: PersonData, t: TeamData) -> Array:
	var events: Array = []
	var safe: bool = float(p.needs.get("safety", 1.0)) > 0.7
	var fed: bool = float(p.needs.get("food", 1.0)) > 0.7
	var surplus_ok: bool = float(t.resources.get("food", 0)) \
		> float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY * 7.0
	var cap: int = maxi(1, int(t.population * 0.25))
	if safe and fed and surplus_ok and t.minor_population < cap:
		var balance: float = _breed_balance(t, p.sex)   # 全單性→0→不繁衍
		if balance <= 0.0:
			return events
		var chance: float = (BREED_BASE_CHANCE + float(p.skills.get("醫療", 0.0)) * 0.1) * balance
		if randf() < chance:
			events.append("P5_breed")
	return events

func _apply_life_event(_state: WorldState, _person: PersonData, team: TeamData, ev: String) -> void:
	match ev:
		"P5_breed":
			team.minor_population += 1

func _score_flee(p: PersonData, _t: TeamData) -> float:
	var base: float = p.stress * (1.0 - p.loyalty) * 0.9
	base += float(p.values.get("求生欲", 0.5)) * 0.3
	base += float(p.skills.get("求生", 0.0)) * 0.2
	base -= float(p.values.get("慎重", 0.5)) * 0.05
	return base

func _score_riot(p: PersonData, _t: TeamData) -> float:
	var base: float = p.stress * p.fear * 0.85
	base += float(p.skills.get("戰鬥", 0.0)) * 0.2
	base += float(p.values.get("殘忍", 0.5)) * 0.15
	base -= float(p.values.get("慎重", 0.5)) * 0.2
	return base

func _score_defect(p: PersonData, _t: TeamData) -> float:
	var base: float = p.stress * (1.0 - p.loyalty) * p.fear * 0.7
	base += float(p.skills.get("計謀", 0.0)) * 0.2
	base -= float(p.values.get("義氣", 0.5)) * 0.15
	base -= float(p.values.get("慎重", 0.5)) * 0.15
	return base

func _score_shirk(p: PersonData, _t: TeamData) -> float:
	var base: float = p.stress * (1.0 - p.loyalty) * 0.5
	base -= float(p.values.get("慎重", 0.5)) * 0.05
	return base

func _score_extort(p: PersonData, _t: TeamData) -> float:
	var boldness: float = 1.0 - p.fear
	var base: float = p.stress * boldness * (1.0 - p.loyalty) * 0.6
	base += float(p.skills.get("商業", 0.0)) * 0.2
	base += float(p.values.get("貪婪", 0.5)) * 0.3
	base += float(p.values.get("殘忍", 0.5)) * 0.15
	base -= float(p.values.get("慎重", 0.5)) * 0.25
	return base

func _apply_reaction(state: WorldState, person: PersonData, team: TeamData, reaction: String) -> void:
	match reaction:
		"P1_comply":
			LoyaltyBank.adjust(person, 0.01, "comply")
		"P2_produce":
			pass   # 效果改由 work_morale 係數體現（evaluate_all 統計）
		"P4_expand":
			UnrestBank.reduce(team, 1, "recover")
		"N1_flee":
			if team.population <= 1 and person.id == team.leader_id:
				return   # solo 無處可逃：不變化、stress 不洩壓（持續高壓餵 N2/N3）
			person.stress = maxf(person.stress - 0.3, 0.0)
			if team.named_members.has(person.id):
				team.named_members.erase(person.id)
				person.team_id = -1
				_spawn_exile_or_join(state, person, team.tile_pos)
			elif person.id == team.leader_id:
				# leader 留下，實際走的是 anon（kill_random 移 anon 桶）；population getter 自動反映
				_anon_actually_left(team, "flee")
			# 非 named/leader（anon 無個體）→ 無 cohort 來源可動，population getter 不變
		"N2_riot":
			UnrestBank.add(team, 1, "reaction")
		"N3_defect":
			if team.population <= 1 and person.id == team.leader_id:
				return   # solo leader 無從叛逃自己
			LoyaltyBank.set_baseline(person, 0.0, "defect")
			if team.named_members.has(person.id):
				team.named_members.erase(person.id)
				person.team_id = -1
				_spawn_exile_or_join(state, person, team.tile_pos)
			elif person.id == team.leader_id:
				_anon_actually_left(team, "defect")   # 走的是 anon；population getter 自動反映
			# 非 named/leader（anon 無個體）→ 無 cohort 來源可動，population getter 不變
		"N4_shirk":
			var f: float = float(team.resources.get("food", 0))
			team.resources["food"] = maxf(f - 1.0, 0.0)
		"N5_extort":
			var money: float = float(team.resources.get("coin", 0))
			var steal: float = minf(money, 5.0)
			team.resources["coin"] = money - steal
			person.coin += steal   # 守恆：偷進私囊

	_maybe_write_memory(person, reaction, state.world.current_tick)

	if reaction != person.last_reaction:
		print("[Tick %d] Person %d (%s/team%d) → %s | stress=%.2f loyalty=%.2f" % [
			state.world.current_tick, person.id, person.role, person.team_id,
			reaction, person.stress, person.loyalty])
	person.last_reaction = reaction

func _find_top_threat(state: WorldState, team: TeamData) -> int:
	var best_id: int = -1
	var best: float = ThreatAssessment.THREAT_BASE_THRESHOLD
	for tid in state.team_discovered.get(team.team_id, []):
		var other: TeamData = state.teams.get(tid)
		if other == null: continue
		var s: float = ThreatAssessment.score(state, team, other)
		if s > best:
			best = s
			best_id = tid
	return best_id

# 朝威脅反方向 3 hex（in-map check；仿 faction_ai._flee_target）
func _flee_target_simple(state: WorldState, team: TeamData, threat: TeamData) -> Vector2i:
	var dir: Vector2i = team.tile_pos - threat.tile_pos
	var pos: Vector2i = team.tile_pos + Vector2i(signi(dir.x), signi(dir.y)) * 3
	if state.world.tiles.has(pos.x * 1000 + pos.y):
		return pos
	return team.tile_pos

# leader 流失 anon：kill_random 實際有殺到人才回 true（anon=0 時無人可走）
func _anon_actually_left(team: TeamData, source: String) -> bool:
	var killed: Dictionary = AnonTierSystem.kill_random(team, 1, source)
	for tier in killed:
		if int(killed[tier]) > 0:
			return true
	return false

# 離團者去處：同格流亡 team 加入，否則自立 1 人流亡 team
func _spawn_exile_or_join(state: WorldState, person: PersonData, pos: Vector2i) -> void:
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tile_pos != pos: continue
		if not ("流亡" in t.tags): continue
		t.named_members.append(person.id)
		person.team_id = t.team_id
		return
	var ot := TeamData.new()
	ot.team_id = _next_team_id(state)
	ot.tile_pos = pos
	ot.faction_id = -1
	ot.tags = ["流亡"]
	ot.current_task = TeamData.TASK_IDLE   # 新 team 建立豁免：直接賦值 + priority 0
	ot.task_priority = 0
	ot.leader_id = person.id
	person.team_id = ot.team_id
	person.role = "leader"
	state.teams[ot.team_id] = ot
	state.team_known[ot.team_id] = []
	state.team_discovered[ot.team_id] = []
	print("[Reaction] Person%d 離團自立流亡 Team%d at (%d,%d)" % [
		person.id, ot.team_id, pos.x, pos.y])

func _next_team_id(state: WorldState) -> int:
	var max_id: int = -1
	for tid in state.teams:
		if tid > max_id: max_id = tid
	return max_id + 1

func _maybe_write_memory(person: PersonData, reaction: String, tick: int) -> void:
	if reaction in ["none", "P1_comply", "P2_produce"]:
		return
	var intensity: String = "minor"
	if reaction in ["N2_riot", "N3_defect"]:
		intensity = "significant"
	elif reaction == "N1_flee":
		intensity = "traumatic"
	person.memory.append({ "event_id": tick, "intensity": intensity, "reaction": reaction })
