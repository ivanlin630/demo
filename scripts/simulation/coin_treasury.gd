class_name CoinTreasury

# ★F2 ②結構首刀（純程序 code-move、零 logic 改）：treasury 域 5 函式自 faction_ai_system 逐字搬入靜態模組。
# 介面 3 entry：consider_extraction / collect_member_tax / extract_treasury（+ coin_need / extract_buffer static 可直呼）。
# ★零反向耦合：5 函式全呼已模組化外部（AnonTreasuryBank/ResourceBank/LoyaltyBank/UnrestBank/TradeValuation/
#   NeedOracle/ResourceSystem/DecisionTerms/Probe）、不回呼 faction_ai。instance→static 為結構搬移非 logic 改（全函式零 instance state）。

const COIN_NEED_CAP: float = 500.0        # TEST VALUE — coin_need clamp 上限防爆
const EXTRACT_BUFFER_MIN: float = 5.0     # TEST VALUE — 貪婪 leader extract 後留 treasury 下限（>0=非清空）
const EXTRACT_BUFFER_MAX: float = 30.0    # TEST VALUE — 慎重 leader 留厚 buffer 上限
# ★★★團內稅分軌（用戶 TG 2026-09-05；spec 2026-09-05-income-tax-split-HOW §2）——
#   ★匿名半邊＝抽【積蓄】（`consider_extraction`/`extract_treasury`，need-driven 池取用）⇒ 零改動
#   ★★具名半邊＝抽【所得】：由 `salary_system` 在發薪當下【源扣繳】
#   ★★★而舊的 `collect_member_tax`（月抽 `person.coin` 存量）**整支退場** ——
#     ★退場的不只是一支函式：★★它同時是「把成員【既有存量】拉回團庫」的救急管道，
#     ★★★而那條路是【用戶法的直接後果】刻意死掉的，不是副作用（見 spec §5b 禁令）。
const INCOME_TAX_K: float   = 0.6    # TEST VALUE — 貪婪→稅率係數（沿用同形舊值 MEMBER_TAX_K）
const INCOME_TAX_K2: float  = 0.2    # TEST VALUE — 慎重→減稅係數（沿用 MEMBER_TAX_K2）
const INCOME_TAX_MAX: float = 0.7    # TEST VALUE — 上限（沿用 MEMBER_TAX_MAX）
# ★下界改 0.0（原 `MEMBER_TAX_MIN`＝0.15 保底稅退場）——
#   ★★理由：保底稅存在是因為【月抽存量】一年只有 12 次機會；
#   ★★★而所得稅【隨每次發薪】發生（`SALARY_INTERVAL`＝7 日 ⇒ 4.3 倍機會）⇒ 不需要保底。
# ★而 `PERSONAL_COIN_FLOOR`（留個人燃料不收乾）也退場：
#   ★★它是【存量稅】才需要的護欄；所得稅按【流量】抽，★★★結構上碰不到既有積蓄
#   ⇒ 天然退場，不是拔掉保護。

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
# ★★★`collect_member_tax` 已於 2026-09-05 整支移除（團內稅分軌）——
#   ★它抽的是 `person.coin` 的【存量】，而新規則抽【所得】（發薪源扣繳）。
#   ★★而【不要因為 `team.coin=0` 卡死就把它加回來】：spec §5b 是硬禁令 ——
#     ★★★不得新增「當 `team.coin < X` 時直接抽 named 成員 `p.coin`」這一類路徑
#       （無論掛在 salary／extraction／trade 哪一支，也無論條件寫得多嚴）。
#   ★而 `unified_commerce_test.gd` 有一條【反向斷言】守著這件事。
