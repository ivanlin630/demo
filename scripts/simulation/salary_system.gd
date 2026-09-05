class_name SalarySystem

# TIER: unmigrated(b) — S3 只搬七支，本顆待 S5+
const SALARY_INTERVAL: int = WorldState.TICKS_PER_DAY * 7   # 1週/次
const SALARY_PER_SKILL_POINT: float = 2.0   # TEST VALUE
const OVERPAY_BONUS: float     = 0.02  # TEST VALUE
const SALARY_LOYALTY_PENALTY: float = 0.03  # TEST VALUE
const MAX_LOYALTY: float       = 0.95
# ★★★補發上限（⑦）：★不是行為旋鈕，是【失控保護】—— 正常情況 far pass 間隔 600 < 週期 10080
#   ⇒ 一次最多補 1 次；撞到上限代表資料壞了，而它會 warn + 記一格，不靜默。
const CATCHUP_MAX: int = 8

var _npc_ai: NpcAiSystem

func _init() -> void:
	_npc_ai = NpcAiSystem.new()

func tick(state: WorldState, team_ids: Array) -> void:
	# ★★★判別 tap（2026-09-05）：`_pay_salary` 進入次數量到 0，而【early-return 已經被我移除】
	#   ⇒ ★所以 0 的成因【不在 `_pay_salary` 裡】—— 它根本沒被呼叫。
	#   ★★三種可能共用同一個 0：①`tick` 沒被呼叫 ②modulo 從不命中 ③`team_ids` 是空的
	#   ⇒ ★★★三格分開記，否則我只能猜。
	if Probe.enabled:
		Probe.bump("salary.tick_called")
		# ★★★而我第一版寫 `%d % (bool)` —— ★GDScript 把 bool 格式成 "true"/"false" 不是 0/1
		#   ⇒ ★★key 變成 `.true`/`.false` 而讀者找 `.1`/`.0` ⇒ 兩格都印 0
		#   ⇒ ★★★而【792 次呼叫卻兩格都 0】對不起來 —— **是那個不平把儀器的毛病露出來的**
		# ★★★⑦ 之後【閘不再是 modulo】—— 原本那兩格（mod.hit／mod.miss）量的是舊閘，
		#   留著只會讓下一個人以為現在還靠 `% SALARY_INTERVAL` 決定發不發。
		#   ⇒ 改量【真正的新閘】：這一批裡有幾隊【到期】。
		var _due: int = 0
		for _tid0 in team_ids:
			var _t0: TeamData = state.teams.get(_tid0)
			if _t0 == null: continue
			if _t0.salary_eval_next_tick > 0 and state.world.current_tick >= _t0.salary_eval_next_tick:
				_due += 1
		Probe.bump("salary.tick.due.%03d" % clampi(_due, 0, 999))
		Probe.bump("salary.tick.batch.%03d" % clampi(team_ids.size(), 0, 999))
		# ★而 `team_ids` 空的時候要知道【世界上其實有幾隊】—— 否則分不出
		#   「世界沒隊了」與「這一批 LOD 批次是空的」（★⑦ 之前那正是唯一的病因）
		Probe.bump("salary.tick.world_teams.%03d" % clampi(state.teams.size(), 0, 999))
	# ★★★第⑦票（2026-09-05，憲法修復）：原本這裡是 `if current_tick % SALARY_INTERVAL != 0: return`
	#   —— ★而【精確 modulo】要求「恰好那一 tick 有一個 pass 跑到你」。
	#   far pass 每 FAR_ZONE_INTERVAL(600) 一次，10080k % 600 = 480k % 600，k=1..4 全非 0
	#   ⇒ ★★遠隊的前四個發薪日【整個落在相位縫裡】⇒ 不是少發，是一次都沒發。
	#   ⇒ ★★★改成【與 last_eval 比較】：事件在【到期後的第一個 pass】發生，
	#      而不是【只在恰好那一 tick 有 pass 時】發生 —— 這就是策略層那 23 個
	#      `CadenceStagger` 呼叫點免疫的原因（不是運氣好，是判準不同）。
	var now: int = state.world.current_tick
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null: continue
		# ★首次：不在第 0 個週期發薪（沒有工作過的那一週），只排下一次 ——
		#   ★★這讓 30 日窗的發薪次數維持 4 次（與修前【對得上的那幾隊】同步）。
		if team.salary_eval_next_tick <= 0:
			team.salary_eval_next_tick = CadenceStagger.next_tick(
				now, now, int(tid), SALARY_INTERVAL)
			continue
		if now < team.salary_eval_next_tick:
			continue
		# ★★★【補到期的次數】而不是「發現逾期就做一次」（spec §3 寫死）——
		#   ★否則長間隔的遠隊會被【結構性少做】，而那是同一種靜默失真的另一個面向。
		#   ★★下一次從【排定的那個 tick】往前推，不是從 `now` 重錨 ——
		#      從 `now` 重錨等於把逾期的那段【吃掉】。
		var _guard: int = 0
		while team.salary_eval_next_tick <= now and _guard < CATCHUP_MAX:
			_pay_salary(state, team)
			team.salary_eval_next_tick = CadenceStagger.next_tick(
				team.salary_eval_next_tick, team.salary_eval_next_tick,
				int(tid), SALARY_INTERVAL)
			_guard += 1
		if _guard >= CATCHUP_MAX:
			# ★★★上限存在就要【被看見】：靜默截斷會讓「補不完」長得像「補完了」。
			Probe.bump("salary.catchup_capped")
			push_warning("[SALARY] team=%d 補發次數撞上限 %d（tick=%d）" % [int(tid), CATCHUP_MAX, now])
			team.salary_eval_next_tick = CadenceStagger.next_tick(now, now, int(tid), SALARY_INTERVAL)

func _calc_fair_salary(p: PersonData) -> float:
	var total: float = 0.0
	for v in p.skills.values():
		total += float(v)
	return total * SALARY_PER_SKILL_POINT

func _pay_salary(state: WorldState, team: TeamData) -> void:
	# ★★★居民 PRODUCE 隊的 early-return 已移除（第⑥票 2026-09-05，R² CLEAN）——
	#   ★原註解寫「村民自食其力，村長非家臣」，而實測顯示它的後果是：
	#     ★★`peaceful_economy` 那張床 **12 隊 100% 帶 `TAG_PRODUCE`** ⇒ 本函式【從未跑到】
	#     （連收尾兩個【無條件】print 都 0 次）⇒ ★★★整條薪資軸在那個世界裡是死的。
	#   ★零新機制零新常數：只是讓居民隊也走同一條既有的發薪路。
	#   ★★而代價要被看見（R² 加的驗收）：`SALARY_INTERVAL` 是【全域同步、無 stagger】的
	#     ⇒ ★★★不滿/忠誠的變化會是【逐 7 日的尖峰】，而【窗期聚合會把它平均掉讀成噪音】
	#     ⇒ 所以卷面要【逐發薪日印】（day7／14／21…），不是印一個窗期總數。
	if Probe.enabled:
		Probe.bump("salary.pay_entry")
		Probe.bump("salary.pay_entry." + ("produce" if team.tags.has(TeamData.TAG_PRODUCE) else "other"))
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
	var _payday: int = state.world.current_tick / SALARY_INTERVAL
	var _person_paid: int = 0
	var _loy_up: int = 0
	var _loy_down: int = 0
	var _coin_out: float = 0.0
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
		_person_paid += 1
		_coin_out += net
		if Probe.enabled:
			Probe.bump("incometax.withheld")
			Probe.add_amount("incometax.amount", paid - net)
			Probe.add_amount("incometax.gross", paid)
		if ratio >= 1.0:
			LoyaltyBank.adjust(p, (ratio - 1.0) * OVERPAY_BONUS, "overpay", MAX_LOYALTY)
			_loy_up += 1
			var intensity: float = clampf((ratio - 1.0) * 0.5, 0.05, 0.8)  # TEST VALUE
			_npc_ai.write_memory(p, "kindness", team.leader_id,
				state.world.current_tick, intensity)
		else:
			LoyaltyBank.adjust(p, -(1.0 - ratio) * SALARY_LOYALTY_PENALTY, "underpay")
			_loy_down += 1
	var anon_paid: float = anon_total * budget_ratio
	ResourceBank.remove(team, "coin", anon_paid, "salary_anon")
	AnonTreasuryBank.deposit(team, anon_paid, "salary")   # 匿名薪水沉澱公庫（非消失）
	if Probe.enabled:
		# ★★★逐【發薪日】記（R² 要求：不要窗期聚合）——
		#   ★`SALARY_INTERVAL` 全域同步無 stagger ⇒ 尖峰落在同一天，而聚合會把它平均掉。
		Probe.bump("salary.payday.%04d.paid" % _payday)
		if budget_ratio < 1.0:
			Probe.bump("salary.payday.%04d.cut" % _payday)   # ★該發薪日有幾隊減薪
		# ★★★而【進入次數】不等於【真的發了錢】——
		#   `budget_ratio` 只在 `payroll > 0.0 and coin_avail < payroll` 才 < 1
		#   ⇒ ★`payroll == 0`（沒有具名成員／全被 master_memory 濾掉／anon 為 0）時
		#     budget_ratio 恆 1.0 ⇒ ★★「減薪 0」與「根本沒發過錢」【印出來長得一樣】
		#   ⇒ ★★★所以 payroll 的零/非零要自己一格，實際流出的 coin 也要自己一格。
		Probe.bump("salary.payday.%04d.%s" % [_payday,
			"payroll_pos" if payroll > 0.0 else "payroll_zero"])
		var _kind: String = "produce" if team.tags.has(TeamData.TAG_PRODUCE) else "other"
		Probe.bump("salary.payday.%04d.%s" % [_payday, _kind])
		# ★★★這一格才是【⑥ 到底有沒有效】的判準——
		#   ★「進入次數」與「payroll>0 的隊數」都【不分居民與非居民】
		#     ⇒ 居民隊可以全部都是 payroll==0，而合計看起來一樣漂亮。
		#   ★★而 ⑥ 的反事實是【現成的】：修前居民隊在 :31 就 return，付出恰好 0
		#     ⇒ ★★★居民隊這一格的 coin 流出【只要非 0，就是 ⑥ 造成的】，不需要另跑 A/B。
		if payroll > 0.0:
			Probe.bump("salary.payday.%04d.pos.%s" % [_payday, _kind])
		Probe.add_amount("salary.payday.%04d.coin_out.%s" % [_payday, _kind], _coin_out + anon_paid)
		Probe.add_amount("salary.payday.%04d.person_paid.%s" % [_payday, _kind], float(_person_paid))
		Probe.add_amount("salary.payday.%04d.person_paid" % _payday, float(_person_paid))
		Probe.add_amount("salary.payday.%04d.coin_out" % _payday, _coin_out + anon_paid)
		Probe.add_amount("salary.payday.%04d.loy_up" % _payday, float(_loy_up))
		Probe.add_amount("salary.payday.%04d.loy_down" % _payday, float(_loy_down))
		Probe.add_amount("salary.payday.%04d.unrest" % _payday, float(team.unrest_turns))
	if budget_ratio < 1.0:
		UnrestBank.add(team, 1, "salary")
		print("[Salary] Team%d 減薪 %.0f%%（coin 不足）" % [team.team_id, (1.0 - budget_ratio) * 100.0])
	print("[Salary] Team%d 薪水結算 coin=%.1f" % [team.team_id, float(team.resources.get("coin", 0))])

func _has_master_memory(p: PersonData, leader_id: int) -> bool:
	for m in p.memory:
		if m.get("type") == "master" and m.get("subject_id") == leader_id:
			return true
	return false
