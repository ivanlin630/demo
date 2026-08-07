class_name CoinTreasury

# ★F2 ②結構首刀（純程序 code-move、零 logic 改）：treasury 域 5 函式自 faction_ai_system 逐字搬入靜態模組。
# 介面 3 entry：consider_extraction / collect_member_tax / extract_treasury（+ coin_need / extract_buffer static 可直呼）。
# ★零反向耦合：5 函式全呼已模組化外部（AnonTreasuryBank/ResourceBank/LoyaltyBank/UnrestBank/TradeValuation/
#   NeedOracle/ResourceSystem/DecisionTerms/Probe）、不回呼 faction_ai。instance→static 為結構搬移非 logic 改（全函式零 instance state）。

const COIN_NEED_CAP: float = 500.0        # TEST VALUE — coin_need clamp 上限防爆
const EXTRACT_BUFFER_MIN: float = 5.0     # TEST VALUE — 貪婪 leader extract 後留 treasury 下限（>0=非清空）
const EXTRACT_BUFFER_MAX: float = 30.0    # TEST VALUE — 慎重 leader 留厚 buffer 上限
const MEMBER_TAX_K: float        = 0.6    # TEST VALUE — 貪婪→稅率係數（單刀 0.3 太弱→強化）
const MEMBER_TAX_K2: float       = 0.2    # TEST VALUE — 慎重→減稅係數
const MEMBER_TAX_MIN: float      = 0.15   # TEST VALUE — 保底稅（連中性領袖也抽，全隊回補 coin 池）
const MEMBER_TAX_MAX: float      = 0.7    # TEST VALUE — 上限（貪婪深抽）
const PERSONAL_COIN_FLOOR: float = 2.0    # TEST VALUE — 留個人燃料不收乾（單刀 5.0 太保守→降）

static func extract_treasury(state: WorldState, team: TeamData, ratio: float, reason: String) -> void:
	if team.anon_treasury <= 0.0 or ratio <= 0.0: return
	ratio = clampf(ratio, 0.0, 1.0)
	var amt: float = team.anon_treasury * ratio
	if amt < 1.0: return   # 忽略可忽略額度，避免空徵用噪音 + 虛增 unrest
	AnonTreasuryBank.withdraw(team, amt, "extract")
	ResourceBank.add(team, "coin", amt, "extract_treasury")
	var is_emergency: bool = (reason == "飢餓緊急")
	var stress_pen: float = (0.05 if is_emergency else 0.15) * ratio
	var loyalty_pen: float = (0.02 if is_emergency else 0.08) * ratio
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p == null: continue
		p.stress = minf(p.stress + stress_pen, 1.0)
		LoyaltyBank.adjust(p, -loyalty_pen, "faction_strain")
	if not is_emergency:
		UnrestBank.add(team, 1, "faction")
	print("[Extract] Team%d 徵用 %.0f coin (%s)" % [team.team_id, amt, reason])

# ★extraction de-patch：coin_need 信號（means-end 延伸，reuse 既有 buy-intent 架構）。
# 隊真 coin-用途估算=要 spendable coin 才做得成的 buy-intent（material-buy 建設 + food-buy 食壓）。
# ★無遞迴：讀 material/food need（resource need，非 facility-output）→ 不回呼 coin/extraction（reviewer R² 驗）。
static func coin_need(state: WorldState, team: TeamData) -> float:
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var need: float = 0.0
	# ★material-hold ④：material-buy 對齊 afford×1.5 缺口（非只 need_keep shortfall）→ extraction 拉夠 coin 買足量
	# 到能 afford（cost×1.5）。cost=想蓋 facility 的 material build-need（_construction_facility_need）。
	var mat_cost: float = NeedOracle._construction_facility_need(state, team, "material", lv)
	if mat_cost > 0.0:
		var mat_afford_short: float = maxf(mat_cost * 1.5 \
			- ResourceSystem.effective_holding(state, team, "material"), 0.0)
		if mat_afford_short > 0.0:
			need += mat_afford_short * TradeValuation.local_value(team, "material", state)   # coin ≈ afford 缺料量 × 料價
	# food-buy（食壓）：food_days<DESPERATION → 需 coin 買糧
	var pop: float = maxf(float(team.population), 1.0)
	var eff_food: float = ResourceSystem.effective_food(state, team)
	var food_days: float = eff_food / (pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY)
	if food_days < DecisionTerms.DESPERATION_DAYS:
		var food_short: float = maxf(DecisionTerms.DESPERATION_DAYS * pop * ResourceSystem.FOOD_PER_PERSON_PER_DAY - eff_food, 0.0)
		need += food_short * TradeValuation.local_value(team, "food", state)   # coin ≈ 缺糧量 × 糧價
	return minf(need, COIN_NEED_CAP)

# ★persona buffer texture（extract 後留 treasury margin）：慎重↑留厚、貪婪↑留薄。
# ★下限 EXTRACT_BUFFER_MIN>0（reviewer R² 必補）：貪婪只降到正下限非 0=非清空 treasury（人格=補多夠用非抽不抽）。
static func extract_buffer(leader: PersonData) -> float:
	var prudence: float = float(leader.values.get("慎重", 0.5))
	return lerpf(EXTRACT_BUFFER_MIN, EXTRACT_BUFFER_MAX, prudence)

static func consider_extraction(state: WorldState, team: TeamData) -> void:
	if team.anon_treasury <= 0.0: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	if team.leader_id == state.player_id: return   # 玩家手動   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return   # gate-ok: guard early-return (null/player/combat/cadence/pos/empty，非決策閘)
	# ★de-patch:砍 flat `greed-prud×0.5>0.4` 死常數門檻 → need-driven（有真 coin-用途才取回自己 treasury coin）。
	var spendable: float = float(team.resources.get("coin", 0))
	var shortfall: float = coin_need(state, team) - spendable
	if shortfall <= 0.0: return   # gate-ok: guard: spendable 已夠→不亂徵(need-guard 非人格閘)
	# ★need 決定「抽不抽」(有真缺才抽);人格 buffer=texture「補到多夠用」(非清空 treasury)。
	var amt: float = minf(shortfall + extract_buffer(leader), team.anon_treasury)
	extract_treasury(state, team, amt / team.anon_treasury, "need_driven")

# unified-commerce coin combo（fold coin-B 成員稅回收，破 salary 單向枯竭補 team.coin 池）。
# 鏡射 _consider_extraction：月 cadence、玩家隊不自動、稅率掛領袖人格。★守恆：person.coin→team.coin 池間搬。
# ★tune 強（coin now load-bearing：買方要有錢買市場 ask ~3.4+）：rate 高/MIN 保底/FLOOR 低（TEST VALUE，measurer 校）。
static func collect_member_tax(state: WorldState, team: TeamData) -> void:
	if team.leader_id == state.player_id: return   # 玩家手動（同 extraction）
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var greed: float = float(leader.values.get("貪婪", 0.5))
	var prudence: float = float(leader.values.get("慎重", 0.5))
	var tax_rate: float = clampf(greed * MEMBER_TAX_K - prudence * MEMBER_TAX_K2, MEMBER_TAX_MIN, MEMBER_TAX_MAX)
	if tax_rate <= 0.0: return
	for pid in team.named_members:
		var p: PersonData = state.persons.get(int(pid))
		if p == null: continue
		var levy: float = minf(p.coin * tax_rate, p.coin - PERSONAL_COIN_FLOOR)   # 留 floor 不收乾
		if levy <= 0.0: continue
		ResourceBank.adjust_person_coin(p, -levy, "member_tax")   # 守恆 chokepoint：person.coin−
		ResourceBank.add(team, "coin", levy, "member_tax")        # team.coin+（池間搬，CoinAudit=0）
