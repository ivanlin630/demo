class_name SalarySystem

# TIER: unmigrated(b) — S3 只搬七支，本顆待 S5+
const SALARY_INTERVAL: int = WorldState.TICKS_PER_DAY * 7   # 1週/次
const SALARY_PER_SKILL_POINT: float = 2.0   # TEST VALUE
const OVERPAY_BONUS: float     = 0.02  # TEST VALUE
const SALARY_LOYALTY_PENALTY: float = 0.03  # TEST VALUE
const MAX_LOYALTY: float       = 0.95

var _npc_ai: NpcAiSystem

func _init() -> void:
	_npc_ai = NpcAiSystem.new()

func tick(state: WorldState, team_ids: Array) -> void:
	if state.world.current_tick % SALARY_INTERVAL != 0:
		return
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null: continue
		_pay_salary(state, team)

func _calc_fair_salary(p: PersonData) -> float:
	var total: float = 0.0
	for v in p.skills.values():
		total += float(v)
	return total * SALARY_PER_SKILL_POINT

func _pay_salary(state: WorldState, team: TeamData) -> void:
	# 居民 PRODUCE team 不走薪資系統（村民自食其力，村長非家臣）
	if team.tags.has(TeamData.TAG_PRODUCE):
		return
	var is_player_team: bool = (team.leader_id == state.player_id and state.player_id != -1)
	# NPC team: 每次發薪依 leader 個性同步薪資（慷慨/吝嗇 leader 隊伍動態不同）
	var npc_salary_mult: float = 1.0
	if not is_player_team:
		var leader: PersonData = state.persons.get(team.leader_id)
		if leader != null:
			var honor: float = (float(leader.values.get("義氣", 0.5)) \
				+ float(leader.values.get("信義", 0.5))) / 2.0
			var greed: float = float(leader.values.get("貪婪", 0.5))
			npc_salary_mult = clampf(1.0 + (honor - greed * 0.5) * 0.4, 0.7, 1.3)
	# ── 量入為出：估總 payroll，coin 不足 → 全員按比例減薪（leader 主動緊縮，非賴帳）──
	var named_payroll: float = 0.0
	for pid in team.named_members:
		var p0: PersonData = state.persons.get(pid)
		if p0 == null: continue
		if _has_master_memory(p0, team.leader_id): continue
		named_payroll += (p0.salary if is_player_team else _calc_fair_salary(p0) * npc_salary_mult)
	# ★★★量入為出估的是【團真的要流出多少 coin】⇒ named 那半要乘 `(1 - rate)`（spec §2 判斷②）
	#   ★用 gross 估會【明明付得起卻減薪】；★★而 anon 不課稅所以不乘。
	#   ★★★代價（spec 自標）：「減薪」次數會下降 —— 那是【行為差異】，要被印出來。
	var _leader_greed: float = 0.5
	var _leader_prudence: float = 0.5
	var _lead0: PersonData = state.persons.get(team.leader_id)
	if _lead0 != null:
		_leader_greed = float(_lead0.values.get("貪婪", 0.5))
		_leader_prudence = float(_lead0.values.get("慎重", 0.5))
	var _rate0: float = clampf(
		_leader_greed * CoinTreasury.INCOME_TAX_K - _leader_prudence * CoinTreasury.INCOME_TAX_K2,
		0.0, CoinTreasury.INCOME_TAX_MAX)
	named_payroll *= (1.0 - _rate0)
	var anon_total: float = AnonTierSystem.total_wage(team)
	var payroll: float = named_payroll + anon_total
	var coin_avail: float = maxf(float(team.resources.get("coin", 0)), 0.0)
	var budget_ratio: float = 1.0
	if payroll > 0.0 and coin_avail < payroll:
		budget_ratio = coin_avail / payroll
	for pid in team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		if _has_master_memory(p, team.leader_id): continue
		var fair: float = _calc_fair_salary(p)
		# NPC team: 每輪同步薪資（隨技能成長 / leader 個性），player team 保留玩家自訂值
		if not is_player_team:
			p.salary = fair * npc_salary_mult
		var paid: float = p.salary * budget_ratio
		# ★★★所得稅【源扣繳】（spec 2026-09-05-income-tax-split §2B）——
		#   ★稅額【從未離開團庫】：team 只淨支出 `net`，而不是「先付再抽回來」
		#     ⇒ ★★守恆上是【少流出】不是【新增憑空 coin】（`CoinAudit` 應為 0）
		#   ★★人格同形：貪婪↑稅率↑／慎重↑稅率↓ —— 沿用舊 `MEMBER_TAX_*` 的同一組係數，
		#     ★★★而下界改 0.0（保底稅退場：所得稅隨每次發薪發生，不需要保底）
		#   ★★★用【同一個 `_rate0`】不重算：★兩處各算一次會 drift，
		#     而「量入為出用的稅率」與「實際扣的稅率」不一致 ⇒ 減薪判斷會跟實付對不上。
		var net: float = paid * (1.0 - _rate0)
		# ★忠誠 ratio 讀【名義】(gross) 不讀實發（spec §2 判斷①）——
		#   ★★那條軸問的是「領主給不給得起／肯不肯給」，不是稅；
		#   ★★★苛稅→離心該是【另一條具名的】戲，混進 underpay 懲罰＝一個數字扛兩個意思。
		var ratio: float = paid / maxf(fair, 0.01)
		ResourceBank.remove(team, "coin", net, "salary_named")
		ResourceBank.adjust_person_coin(p, net, "salary_named")
		if Probe.enabled:
			Probe.bump("incometax.withheld")
			Probe.add_amount("incometax.amount", paid - net)
			Probe.add_amount("incometax.gross", paid)
		if ratio >= 1.0:
			LoyaltyBank.adjust(p, (ratio - 1.0) * OVERPAY_BONUS, "overpay", MAX_LOYALTY)
			var intensity: float = clampf((ratio - 1.0) * 0.5, 0.05, 0.8)  # TEST VALUE
			_npc_ai.write_memory(p, "kindness", team.leader_id,
				state.world.current_tick, intensity)
		else:
			LoyaltyBank.adjust(p, -(1.0 - ratio) * SALARY_LOYALTY_PENALTY, "underpay")
	var anon_paid: float = anon_total * budget_ratio
	ResourceBank.remove(team, "coin", anon_paid, "salary_anon")
	AnonTreasuryBank.deposit(team, anon_paid, "salary")   # 匿名薪水沉澱公庫（非消失）
	if budget_ratio < 1.0:
		UnrestBank.add(team, 1, "salary")
		print("[Salary] Team%d 減薪 %.0f%%（coin 不足）" % [team.team_id, (1.0 - budget_ratio) * 100.0])
	print("[Salary] Team%d 薪水結算 coin=%.1f" % [team.team_id, float(team.resources.get("coin", 0))])

func _has_master_memory(p: PersonData, leader_id: int) -> bool:
	for m in p.memory:
		if m.get("type") == "master" and m.get("subject_id") == leader_id:
			return true
	return false
