class_name ReactionSystem

const GOAL_CHECK_INTERVAL: int = 10 * WorldState.TICKS_PER_HOUR  # 每 10 小時
const MORALE_LERP: float = 0.1          # 每次 evaluate_all 呼叫的士氣收斂率（trials 補償用同一常數）
# ★生育＝per-capita 相對盈餘驅動的【連續速率】（取代舊「硬懸崖門檻 + 每次抽獎」）。
# BREED_BASE_RATE 反推（spec §7、用戶拍 pacing (B)「約一個月一個名額」）：
#   目標＝健康村（f ≈ 0.5，即 rel_surplus ≈ K = 0.15 ＝本世界前 10%）、5 名適齡成人 → 1 名額/30 日
#   births_per_day = BASE_RATE × f × eligible × persona_mult
#   → 1/30 = BASE_RATE × 0.5 × 5 × 1.0 → BASE_RATE = 0.0133（名額 / 適齡人·日）
const BREED_BASE_RATE: float = 0.0133
# K 錨在實測分布（spec §6）：peaceful d45 的 p90 = 0.148 取整 → 語意＝「本世界前 10% 健康的村」落在 f≈0.5。
# 飽和效果：r=0.15→f≈0.50 / r=0.5→f≈0.77 / r=2.7→f≈0.95 / r=12.7→f≈0.99（暴富村不爆生）。
const BREED_K: float = 0.15
# 醫療技能相對權重：沿用舊式 (BREED_BASE_CHANCE 0.15 + 醫療×0.1) 的比例＝0.1/0.15≈0.667，
# 改寫成乘法 persona_mult = (1 + 醫療×此值) × balance，維持既有人格語意不新增旋鈕。
const BREED_MEDIC_RATE: float = 0.667
const BREED_BASE_CHANCE: float = 0.15   # TEST VALUE（舊抽獎式殘留：已無 caller、保留供對照/回溯）
# R2 flow-not-stock：生育 gate 讀持續淨食物流盈餘（食物/天），非 stale 滿倉 stock。
# 門檻 ≈ 半人份日餐 → 有真盈餘養新口才生（爆倉不再驅動）。TEST VALUE，bed 校。
const BREED_FLOW_MIN: float = 1.2   # TEST VALUE — 生育所需日均淨食物盈餘

var _npc_ai: NpcAiSystem

func _init() -> void:
	_npc_ai = NpcAiSystem.new()

# ★trials（LOD 紅線修）：far pass 每次呼叫代表 trials 個 near 窗（cadence/NEAR_CADENCE=10）。
# ★判準＝【每次呼叫是否累積/抽獎】，不是【有沒有 RNG】：
#   補償對象＝每次呼叫累積一點的量（far 少跑 9/10 次 → 累積速度只剩 1/10＝降真實）——
#     ①work_morale 的重複 lerp（w_eff=1-(1-MORALE_LERP)^trials，精確等價）
#     ②skill_sys.on_reaction 的 XP 累加（跑 trials 次，保 MAX_SKILL 夾頂語意）
#     ③comply 的 loyalty +0.01（×trials）④riot/expand 的 unrest ±1（×trials）
#     ⑤breed 的抽獎（真·多次試驗 for-loop，禁單抽 1-(1-p)^n）
#   不補＝達標即發生一次的離散事件（flee/defect 離隊：條件持續下次照樣發生＝最多延遲，非降率）
#     與觸底飽和型（stress -= 0.3）。決定性 _score_*+argmax 選擇本身跑一次語意即正確。
func evaluate_all(state: WorldState, team_ids: Array, skill_sys: Object = null, trials: int = 1) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null:
			continue
		# ★生育：team-level 連續累積器（每隊每次 evaluate_all 一次；rate×真實Δt 本來就是正確降頻語意
		# → ★不吃 LOD trials，其餘累積型補償照舊）。
		_tick_breed(state, team)
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
				_apply_reaction(state, person, team, reaction, trials)
				if skill_sys != null:
					# ★每次呼叫累加技能 → 跑 trials 次（非 growth×trials；跑滿次才精確含 MAX_SKILL 夾頂語意）
					for _s in range(maxi(trials, 1)):
						skill_sys.on_reaction(person, reaction)
			# 生命事件（獨立於行動反應，可並行）
			for ev in _evaluate_life_events(state, person, team):   # ★breed 已移出（trials 不再餵 breed）
				_apply_life_event(state, person, team, ev)
			match reaction:
				"P2_produce": morale_acc += 1.0; morale_n += 1
				"N4_shirk":   morale_acc -= 1.0; morale_n += 1
				"none":       pass
				_:            morale_n += 1   # 其他 reaction 中性計入
		if morale_n > 0:
			var target_morale: float = clampf(1.0 + (morale_acc / float(morale_n)) * 0.5, 0.5, 1.5)
			# ★重複 lerp 的精確等價（固定 target）：w_eff = 1 − (1−0.1)^trials
			# far pass 若只 lerp 一次，收斂速度只剩 1/10；而 work_morale 直接乘進採集產出
			# （resource_system gain *= work_morale）＝世界級影響。
			var w_eff: float = 1.0 - pow(1.0 - MORALE_LERP, float(maxi(trials, 1)))
			team.work_morale = clampf(lerpf(team.work_morale, target_morale, w_eff), 0.5, 1.5)
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
	# Fix 1 person-reaction tap（內政盲點補）：specimen 隊成員反應進 timeline（誰/reaction/why driver）。
	SpecimenTracer.capture_reaction(state, person, team, best, {
		"loyalty": snappedf(person.loyalty, 0.01), "stress": snappedf(person.stress, 0.01),
	})
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
# ★生育已改為 team-level 連續累積器（見 _tick_breed）：不再逐人抽獎、不再有硬門檻懸崖。
# 本函式保留為其他「生命事件」的擴充點（目前無其他事件）。
func _evaluate_life_events(_state: WorldState, _p: PersonData, _t: TeamData, _trials: int = 1) -> Array:
	return []

# ★T1 度量：rel_surplus ＝ 相對盈餘（比例量）＝ 日均淨食物流 / 全隊日食耗。
# 比例量同時解掉兩個舊病：小村被【絕對門檻】封死、大團被【人均攤薄】。
static func breed_rel_surplus(t: TeamData) -> float:
	var need: float = maxf(float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	return t.food_flow_avg / need

# ★T2 速率形狀：f(r) = 0 (r<=0) / r/(r+K) (r>0)——連續、單調、飽和於 1、無懸崖。
static func breed_f(rel_surplus: float) -> float:
	if rel_surplus <= 0.0:
		return 0.0
	return rel_surplus / (rel_surplus + BREED_K)

# ★T3 累積器（每 evaluate_all 每隊一次）：progress += rate × eligible × elapsed_days；
# 跨過 1.0 就產一個 minor（受 cap 限制）。
# ★★elapsed_days 用 per-team 真實流逝（breed_progress_last_tick），★禁用呼叫情境的 cadence 常數當
#   elapsed——near/far 穿梭會重複累加（headless 不會踩、但有玩家遊玩是常態）。
# ★sentinel -1（未初始化）→ 首次評估只蓋戳記不累加＝冷啟動噴發結構上不可能。
func _tick_breed(state: WorldState, team: TeamData) -> void:
	var now: int = state.world.current_tick
	if team.breed_progress_last_tick < 0:
		team.breed_progress_last_tick = now   # 首次：只蓋戳記
		return
	var elapsed_days: float = float(now - team.breed_progress_last_tick) / float(WorldState.TICKS_PER_DAY)
	team.breed_progress_last_tick = now
	if elapsed_days <= 0.0:
		return
	var cap: int = maxi(1, int(team.population * 0.25))
	if team.minor_population >= cap:
		return   # 名額已滿：不累加（避免存滿一大桶後一次噴出）
	var f: float = breed_f(breed_rel_surplus(team))
	if f <= 0.0:
		return   # 相對盈餘 ≤ 0 → 世界窮就少生（(甲) 精神保留）
	# 適齡＝needs 達標的隊員；persona_mult 沿用既有 醫療 與 _breed_balance（兩性結構仍是先決）
	var daily: float = 0.0
	for pid in state.persons:
		var person: PersonData = state.persons[pid]
		if person.team_id != team.team_id:
			continue
		if float(person.needs.get("safety", 1.0)) <= 0.7 or float(person.needs.get("food", 1.0)) <= 0.7:
			continue
		var balance: float = _breed_balance(team, person.sex)
		if balance <= 0.0:
			continue
		daily += BREED_BASE_RATE * f * (1.0 + float(person.skills.get("醫療", 0.0)) * BREED_MEDIC_RATE) * balance
	if daily <= 0.0:
		return
	team.breed_progress += daily * elapsed_days
	if Probe.enabled:
		Probe.bump_sample("breed.rate_sample", {
			"team": team.team_id, "rel_surplus": snappedf(breed_rel_surplus(team), 0.001),
			"f": snappedf(f, 0.001), "daily_rate": snappedf(daily, 0.0001),
			"progress": snappedf(team.breed_progress, 0.001), "elapsed_days": snappedf(elapsed_days, 0.01),
		}, 24)
	while team.breed_progress >= 1.0 and team.minor_population < cap:
		team.minor_population += 1
		team.breed_progress -= 1.0
		if Probe.enabled:
			Probe.bump("breed.born")
			Probe.bump("reaction.breed")   # 既有 key 保留（下游/舊床仍讀）

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

# ★LOD trials 補償（addendum）：判準是【每次呼叫是否累積】，不是【有沒有 RNG】。
# far pass 少跑 9/10 次 → 每次呼叫累積一點的量若不補，累積速度只剩 1/10＝仍然降真實。
# 補：comply loyalty +0.01×trials、riot/expand unrest ±1×trials。
# ★不補（達標即發生一次、非每次累積）：N1_flee/N3_defect 離隊（條件持續下次照樣發生＝最多延遲
#   100 tick、非降率）、stress -= 0.3（觸底即止的飽和型）。
func _apply_reaction(state: WorldState, person: PersonData, team: TeamData, reaction: String, trials: int = 1) -> void:
	match reaction:
		"P1_comply":
			LoyaltyBank.adjust(person, 0.01 * float(maxi(trials, 1)), "comply")   # ★每次呼叫累積 → ×trials
		"P2_produce":
			pass   # 效果改由 work_morale 係數體現（evaluate_all 統計）
		"P4_expand":
			UnrestBank.reduce(team, maxi(trials, 1), "recover")   # ★每次呼叫累積 → ×trials
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
			UnrestBank.add(team, maxi(trials, 1), "reaction")   # ★每次呼叫累積 → ×trials
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
