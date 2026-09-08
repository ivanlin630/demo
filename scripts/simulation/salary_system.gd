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

# ★★★抽出來的【純讀】payroll 估算（systems spec 2026-09-08）。
#   病：`trade_valuation` 問「我需要多少 coin」時用的是 `pop × 10.0`（手抄常數），
#   而世界有真實的義務 payroll――領主要付薪水所以需要 coin，
#   而【賣貨決策看不見這件事】。
# ★公式逐字搬自 `tick()`（不重寫），且 `tick()` 改呼它
#   ⇒ 【只有一份公式】，不會分岔。
# ★★鐵則（systems）：本函數【禁寫任何世界狀態】―― 估值路徑寫世界
#   就是今天剛修掉的 gather 觀測純度缺陷。要快取也只能由
#   SalarySystem 在它自己的 advance 路徑寫，估值端只讀。
static func estimated_payroll(state: WorldState, team: TeamData) -> float:
	var is_player_team: bool = (team.leader_id == state.player_id and state.player_id != -1)
	var npc_salary_mult: float = 1.0
	if not is_player_team:
		var leader: PersonData = state.persons.get(team.leader_id)
		if leader != null:
			var honor: float = (float(leader.values.get("義氣", 0.5)) 				+ float(leader.values.get("信義", 0.5))) / 2.0
			var greed: float = float(leader.values.get("貧婪", 0.5))
			npc_salary_mult = clampf(1.0 + (honor - greed * 0.5) * 0.4, 0.7, 1.3)
	var named_payroll: float = 0.0
	for pid in team.named_members:
		var p0: PersonData = state.persons.get(pid)
		if p0 == null: continue
		if _has_master_memory(p0, team.leader_id): continue
		named_payroll += (p0.salary if is_player_team else _calc_fair_salary(p0) * npc_salary_mult)
	var _leader_greed: float = 0.5
	var _leader_prudence: float = 0.5
	var _lead0: PersonData = state.persons.get(team.leader_id)
	if _lead0 != null:
		_leader_greed = float(_lead0.values.get("貧婪", 0.5))
		_leader_prudence = float(_lead0.values.get("慎重", 0.5))
	var _rate0: float = clampf(
		_leader_greed * CoinTreasury.INCOME_TAX_K - _leader_prudence * CoinTreasury.INCOME_TAX_K2,
		0.0, CoinTreasury.INCOME_TAX_MAX)
	named_payroll *= (1.0 - _rate0)
	return named_payroll + AnonTierSystem.total_wage(team)

static func _calc_fair_salary(p: PersonData) -> float:
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
		# ★★★驗收①要的是【每隊幾次】不是合計 —— 合計把「每隊都領到 4 次」與
		#   「少數幾隊領很多次、多數一次都沒有」壓成同一個數字。
		Probe.bump("salary.byteam.%04d" % team.team_id)
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
	# ★公式已抽成 `estimated_payroll()`（估值端也要讀同一份）
	#   ⇒ 這裡呼它，而不是留一份複製品―― 兩份公式一定會分岔。
	var payroll: float = estimated_payroll(state, team)
	# ★★★下游還要用到這兩個局部（:183 用 `_rate0` 算稅後淨額、:235 用 `anon_total` 發匿名薪）
	#   ⇒ 抽函數時不能連它們一起拿掉。
	#   ★而我拿掉了，而它的表現形式是【卡住】不是【錯誤訊息】：
	#     Godot 對載入失敗彈阻斷對話框（連 --headless 也彈）⇒ 燒到逆時。
	#     今天第三次碰到同一個形狀（data_test / 全掃 / 這裡）。
	var _lead1: PersonData = state.persons.get(team.leader_id)
	var _rate0: float = clampf(
		(float(_lead1.values.get("貧婪", 0.5)) if _lead1 != null else 0.5) * CoinTreasury.INCOME_TAX_K
		- (float(_lead1.values.get("慎重", 0.5)) if _lead1 != null else 0.5) * CoinTreasury.INCOME_TAX_K2,
		0.0, CoinTreasury.INCOME_TAX_MAX)
	var anon_total: float = AnonTierSystem.total_wage(team)
	var coin_avail: float = maxf(float(team.resources.get("coin", 0)), 0.0)
	var budget_ratio: float = 1.0
	if payroll > 0.0 and coin_avail < payroll:
		budget_ratio = coin_avail / payroll
	# ★★★§2②：【付不出】與【不肯付】是兩件事，而舊 code 把它們合成一個 `ratio`。
	#   ★而判準【不用發明】――它們本來就是兩個變數：
	#     (a) `budget_ratio < 1` ⇒ 手上錢不夠【付不出】
	#     (b) `p.salary < fair` 而 `budget_ratio == 1` ⇒ 付得起卻定低薪【不肯付】
	#   ★★而舊 code 對 (a) 扣满額忠誠 ⇒ 【地理被定罪】：
	#     無幣村每 7 天被判一次「苛待部下」，永動。
	#   ★★★而【付不出】不是惡意：它該有別的戴述（士氣/敘事），不是忠誠懲罰。
	var _can_pay: bool = budget_ratio >= 1.0
	var _payday: int = state.world.current_tick / SALARY_INTERVAL
	var _person_paid: int = 0
	var _loy_up: int = 0
	var _loy_down: int = 0
	var _willful: int = 0   # ★【付得起卻定低薪】的人數 ―― unrest 該跟這個走，不跟 `budget_ratio` 走
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
		# ★★★R² (b)：【不肯付】的軸要鍵在 `p.salary / fair`，不是 `budget_ratio`。
		#   ★兩者在 `budget_ratio == 1` 時數值相同 ⇒ 這個改動對現有兩格綠是【no-op】
		#     ⇒ ★★所以它【必須】配一個新的陽性對照，否則沒人知道軸換了。
		#   ★★★而換軸的理由是【玩家領主】：NPC 的 `p.salary` 由 `fair × npc_salary_mult` 寫入，
		#     而玩家隊的 `p.salary` 是玩家自訂、不經過 mult。
		#     ⇒ 若把軸鍵在 mult，【玩家故意定零薪】會被靕默豁免。
		var wage_ratio: float = p.salary / maxf(fair, 0.01)
		ResourceBank.remove(team, "coin", net, "salary_named")
		ResourceBank.adjust_person_coin(p, net, "salary_named")
		_person_paid += 1
		_coin_out += net
		if Probe.enabled:
			Probe.bump("incometax.withheld")
			Probe.add_amount("incometax.amount", paid - net)
			Probe.add_amount("incometax.gross", paid)
		# ★★★兩個軸是【獨立】的，而我上一版用 if/elif 把它們串成互斥：
		#   ★工資軸：`wage_ratio = p.salary / fair` ⇒ 領主【選】了多少薪水
		#   ★★預算軸：`budget_ratio` ⇒ 領主【付得出】多少
		#   ⇒ ratio = wage_ratio × budget_ratio ―― 兩個因子，而舊 code 只看乘積。
		# ★★★上一版的 `elif _can_pay and wage_ratio < 1.0` 是【恒真項】：
		#   進到 elif 時已知 ratio < 1；_can_pay ⇒ budget_ratio == 1 ⇒ ratio == wage_ratio
		#   ⇒ wage_ratio < 1 被蕴涵 ⇒ 分支條件逐字等價，★軸根本沒換。
		#   ⇒ ★★而後果是【貪婪領主 + 窮村】照樣免罰：它 _can_pay=false ⇒ 落進 else。
		# ⇒ ★★★改成【兩個獨立判斷】，而懲罰只算【故意的那一段】：
		#   罰幅 = (1 − wage_ratio)，不是 (1 − ratio) ―― 後者把【沒錢】那一段也算進去了。
		if ratio >= 1.0:
			if Probe.enabled: Probe.bump("salary.reason.paid_full")
			LoyaltyBank.adjust(p, (ratio - 1.0) * OVERPAY_BONUS, "overpay", MAX_LOYALTY)
			_loy_up += 1
			var intensity: float = clampf((ratio - 1.0) * 0.5, 0.05, 0.8)  # TEST VALUE
			_npc_ai.write_memory(p, "kindness", team.leader_id,
				state.world.current_tick, intensity)
		else:
			# ①工資軸：定低薪 ⇒ 罰（★不問付不付得出）
			if wage_ratio < 1.0:
				LoyaltyBank.adjust(p, -(1.0 - wage_ratio) * SALARY_LOYALTY_PENALTY, "underpay")
				_loy_down += 1
				_willful += 1
				if Probe.enabled: Probe.bump("salary.reason.underpaid_willful")
			# ②預算軸：付不出 ⇒ 【不罰】，但仍然記錄
			#   ★不罰 ≠ 沒發生；而兩個軸可以【同時】成立（貪婪領主的窮村）。
			if budget_ratio < 1.0 and Probe.enabled:
				Probe.bump("salary.reason.unpayable_local")
				Probe.add_amount("salary.reason.unpayable_shortfall", 1.0 - budget_ratio)
			# ★★兩軸都不成立卻 ratio<1 ⇒ 不可能（ratio = wage×budget），留一格防們候
			if wage_ratio >= 1.0 and budget_ratio >= 1.0 and Probe.enabled:
				Probe.bump("salary.reason.IMPOSSIBLE_ratio_lt1")
	var anon_paid: float = anon_total * budget_ratio
	ResourceBank.remove(team, "coin", anon_paid, "salary_anon")
	AnonTreasuryBank.deposit(team, anon_paid, "salary")   # 匿名薪水沉澱公庫（非消失）
	if Probe.enabled:
		# ★★★逐【發薪日】記（R² 要求：不要窗期聚合）——
		#   ★`SALARY_INTERVAL` 全域同步無 stagger ⇒ 尖峰落在同一天，而聚合會把它平均掉。
		Probe.bump("salary.payday.%04d.paid" % _payday)
		# ★★★§2③ unrest：它本來挂在 `budget_ratio < 1.0`（付不出）上――
	#   ★而那是【同一把刀的另一半】：只改忠誠不改這裡，無幣村會繼續被冤枉，
	#     只是換了一個欄位，而卷面會看起來「修好了」。
	#   ★★現在它跟【不肯付的人數】走，不跟 `budget_ratio` 走。
	#   ★★★而我第一版把 `if not _can_pay:` 寫在 `if budget_ratio < 1.0:` 裡面――
	#     那裡 `_can_pay` 恒為 false，於是 `else` 是【死分支】、而「不肯付」根本不會進來。
	#     ★一個永遠跑不到的分支看起來與【有處理】一模一樣。
	if _willful > 0:
		UnrestBank.add(team, 1, "salary")
		if Probe.enabled: Probe.bump("salary.unrest.willful")
	elif budget_ratio < 1.0:
		if Probe.enabled: Probe.bump("salary.unrest.suppressed_unpayable")   # ★本來會加、現在不加
	if budget_ratio < 1.0:
		print("[Salary] Team%d 減薪 %.0f%%（本地無幣，不計懲罰）" % [team.team_id, (1.0 - budget_ratio) * 100.0])
	print("[Salary] Team%d 薪水結算 coin=%.1f" % [team.team_id, float(team.resources.get("coin", 0))])

static func _has_master_memory(p: PersonData, leader_id: int) -> bool:
	for m in p.memory:
		if m.get("type") == "master" and m.get("subject_id") == leader_id:
			return true
	return false
