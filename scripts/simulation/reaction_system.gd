class_name ReactionSystem

const GOAL_CHECK_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時
const BREED_BASE_CHANCE: float = 0.15   # TEST VALUE
# R2 flow-not-stock：生育 gate 讀持續淨食物流盈餘（食物/天），非 stale 滿倉 stock。
# 門檻 ≈ 半人份日餐 → 有真盈餘養新口才生（爆倉不再驅動）。TEST VALUE，bed 校。
const BREED_FLOW_MIN: float = 1.2   # TEST VALUE — 生育所需日均淨食物盈餘

var _npc_ai: NpcAiSystem

func _init() -> void:
	_npc_ai = NpcAiSystem.new()

func evaluate_all(state: WorldState, team_ids: Array, skill_sys: Object = null) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null:
			continue
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
			var reaction: String = _evaluate_person(state, person, team)
			if reaction != "none":
				_apply_reaction(state, person, team, reaction)
				if skill_sys != null:
					skill_sys.on_reaction(person, reaction)
			# 生命事件（獨立於行動反應，可並行）
			for ev in _evaluate_life_events(state, person, team):
				_apply_life_event(state, person, team, ev)
			match reaction:
				"P2_produce": morale_acc += 1.0; morale_n += 1
				"N4_shirk":   morale_acc -= 1.0; morale_n += 1
				"none":       pass
				_:            morale_n += 1   # 其他 reaction 中性計入
		if morale_n > 0:
			var target_morale: float = clampf(1.0 + (morale_acc / float(morale_n)) * 0.5, 0.5, 1.5)
			team.work_morale = clampf(lerpf(team.work_morale, target_morale, 0.1), 0.5, 1.5)
		# 序7 reaction 溶入：bridge panic-flee try_set 撕除 → 集體恐慌現由引擎 survival option
		# 驅動（ctx.team_panic → threat_pressure → FLEE，faction_ai 主 rank/threat 路派發，PRIO 語意保）。
		# 個體反應 apply（下方 _apply_reaction/_apply_life_event）= consequence scaffolding，全不動。

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

func _evaluate_person(state: WorldState, person: PersonData, team: TeamData) -> String:
	var scores: Dictionary = {
		"P1_comply":  _score_comply(person, team),
		"P2_produce": _score_produce(person, team),
		"P4_expand":  _score_expand(state, person, team),
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
	if Probe.enabled: Probe.bump("reaction." + best)   # winner 反應計數（序7 觀測空白補）
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

func _score_expand(state: WorldState, p: PersonData, t: TeamData) -> float:
	# 統一食物：擴張 surplus gate 讀 coherent 食物(私產+自家糧倉)，非私產 silo (econ-food-unify)
	var food: float = ResourceSystem.effective_food(state, t)
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
func _evaluate_life_events(state: WorldState, p: PersonData, t: TeamData) -> Array:
	var events: Array = []
	var safe: bool = float(p.needs.get("safety", 1.0)) > 0.7
	var fed: bool = float(p.needs.get("food", 1.0)) > 0.7
	# R2 flow-not-stock：生育讀持續淨食物流盈餘，非 stale 滿倉 → 爆倉不再驅動成長。
	# 覓食/爆倉 net~0 → 不生；賣特產換糧 net>0（致富 intent 驅動）→ 才長。
	var surplus_ok: bool = t.food_flow_avg > BREED_FLOW_MIN
	var cap: int = maxi(1, int(t.population * 0.25))
	if safe and fed and surplus_ok and t.minor_population < cap:
		var balance: float = _breed_balance(t, p.sex)   # 全單性→0→不繁衍
		if balance <= 0.0:
			return events
		var chance: float = (BREED_BASE_CHANCE + float(p.skills.get("醫療", 0.0)) * 0.1) * balance
		if randf() < chance:
			events.append("P5_breed")
			if Probe.enabled: Probe.bump("reaction.breed")
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
				state.remove_member(team, person.id)   # 離隊：erase + team_id=-1
				if Probe.enabled: Probe.bump("death.defect_leave")
				_spawn_exile_or_join(state, person, team.tile_pos)
			elif person.id == team.leader_id:
				# leader 留下，實際走的是 anon（kill_random 移 anon 桶）；population getter 自動反映
				if _anon_actually_left(team, "flee"):
					if Probe.enabled: Probe.bump("death.defect_leave")
			# 非 named/leader（anon 無個體）→ 無 cohort 來源可動，population getter 不變
		"N2_riot":
			UnrestBank.add(team, 1, "reaction")
		"N3_defect":
			if team.population <= 1 and person.id == team.leader_id:
				return   # solo leader 無從叛逃自己
			LoyaltyBank.set_baseline(person, 0.0, "defect")
			if team.named_members.has(person.id):
				state.remove_member(team, person.id)   # 離隊：erase + team_id=-1
				if Probe.enabled: Probe.bump("death.defect_leave")
				_spawn_exile_or_join(state, person, team.tile_pos)
			elif person.id == team.leader_id:
				if _anon_actually_left(team, "defect"):   # 走的是 anon；population getter 自動反映
					if Probe.enabled: Probe.bump("death.defect_leave")
			# 非 named/leader（anon 無個體）→ 無 cohort 來源可動，population getter 不變
		"N4_shirk":
			ResourceBank.remove(team, "food", 1.0, "shirk")
		"N5_extort":
			var money: float = float(team.resources.get("coin", 0))
			var steal: float = minf(money, 5.0)
			ResourceBank.add(team, "coin", -steal, "extort")
			ResourceBank.adjust_person_coin(person, steal, "extort")   # 守恆：偷進私囊

	_maybe_write_memory(person, reaction, state.world.current_tick)

	if reaction != person.last_reaction:
		print("[Tick %d] Person %d (%s/team%d) → %s | stress=%.2f loyalty=%.2f" % [
			state.world.current_tick, person.id, person.role, person.team_id,
			reaction, person.stress, person.loyalty])
	person.last_reaction = reaction

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
		state.add_member(t, person.id)   # 入隊：append + team_id 回指
		return
	var ot := TeamData.new()
	ot.team_id = _next_team_id(state)
	ot.tile_pos = pos
	state.set_team_faction(ot, -1)   # S11 chokepoint（fresh team，no-op；單寫者一致）
	state.set_team_tags(ot, ["流亡"], "solo_exile")
	ot.current_task = TeamData.TASK_IDLE   # 新 team 建立豁免：直接賦值 + priority 0
	ot.task_priority = 0
	ot.leader_id = person.id
	person.team_id = ot.team_id
	person.role = "leader"
	state.create_team(ot)   # S9 chokepoint：註冊 + known/discovered init
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
