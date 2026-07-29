class_name ResourceSystem

const FOOD_PER_PERSON_PER_DAY: float = 0.8   # TEST VALUE — R1 張力校準：供給÷24 後配降耗
# （原 2.4 配 24× 供給 bug；R1 修 cadence 後穩態食物 income≈regen[plains 8/forest 3 per day]，
#  0.8 使 plains op1 養小鎮微盈餘[繁榮]、forest op1 微赤[苟活須交易]、赤字溫和不成餓死潮）
# 讀B：覓食 = 苟活地板。覓食來源食物淨貢獻上限 = 幾日餬口（超額不 bank、不耗 wild_game）。
const FORAGE_FLOOR_DAYS: float = 5.0         # TEST VALUE — 覓食淨貢獻上限=幾日餬口（1.5→5 苟活韌性；<建國7天門）
const WILD_GAME_REGEN_PER_DAY: float = 0.15  # TEST VALUE — 獵物慢繁殖回補（月級，上限夾 resource_cap）
const FOOD_PER_MOUNT_PER_DAY: float = 0.5    # TEST VALUE — 草料 0.5食物/馬/天
const PROVISION_DAYS: float = 10.0           # TEST VALUE — 旅途乾糧天數（自家 outpost 補 carried buffer）
# R2 flow-not-stock：日均淨食物流 EMA 平滑窗（天）。cadence 無關（α=day_fraction/window）。
const FLOW_WINDOW_DAYS: float = 5.0          # TEST VALUE — 食物流平滑窗

# 採集係數：每次 collect 取 tile 池的比例（馬爾薩斯 tune R1: 0.01→0.05 —
# 池常駐 cap，遠區村 income ≈ cap×rate×mults×2.4次/日，0.01 時 7/day << burn 28.8）
const COLLECT_RATE: float = 0.05

const PUBLIC_RESOURCES: Array = ["ore_gold", "ore_silver", "ore_iron", "ore_steel", "mounts", "horses"]

# 一般稅：採集所得（私產）按 tax_rate 自動撥腳下 tile owner 公庫。
# ore/製造成品已直接進公庫，不重複課；只課進私產的 food/material/goods。
const NORMAL_TAX_RES: Array = ["food", "material", "goods"]

# ── 飢餓致死鏈（2026-06-13 famine-death spec）──
const FAMINE_SATISFACTION_THRESHOLD: float = 0.3   # 食物滿足度低於此 → 斷糧
const FAMINE_GRACE_DAYS: int = 7                    # 寬限期：grace 內不致死（避免開局滅團潮）
const FAMINE_MINOR_DEATH_RATE: float = 0.10         # grace 後每日餓死 minor 比例
const FAMINE_ANON_DEATH_RATE: float = 0.05          # minor 耗盡後每日餓死 anon 比例
# 個人飢餓累積（named 用，跟人走不跟團）
const HUNGER_GAIN_PER_DAY: float = 0.05
const HUNGER_RECOVER_PER_DAY: float = 0.1

# TEST VALUES — 平衡期需調整
const REGEN_RATE: Dictionary = {
	"plains":   { "food": 8.0,  "material": 0.5  },
	"forest":   { "food": 3.0,  "material": 12.0 },
	"mountain": { "food": 0.5,  "material": 2.0  },
}

# hex 軸座標六方向
const HEX_DIRS: Array = [
	Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1),
	Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1),
]

func collect_resources(state: WorldState, team_ids: Array, cadence_ticks: int = WorldState.TICKS_PER_DAY) -> void:
	# R1：harvest 與 consumption 同 cadence 基準（day_fraction）。修 24× 不對稱 bug（供給每小時全速）。
	var day_fraction: float = float(cadence_ticks) / float(WorldState.TICKS_PER_DAY)
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var tile_id: int   = _pos_to_tile_id(team.tile_pos)
		if not state.world.tiles.has(tile_id):
			continue
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_level == 0:
			# 無據點隊零被動食物；食物唯一來源 = 狩獵（小獵物 + 野獸）
			if int(tile.resources.get("wild_game", 0)) > 0:
				HuntSystem.new().hunt_small_game(state, team, tile, false)   # 被動小獵
			continue

		var pop_mult: float  = clampf(sqrt(float(team.population) / 5.0), 0.5, 2.0)
		var leader           = state.persons.get(team.leader_id)
		var prod_skill: float = float(leader.skills.get("生產", 0.0)) if leader else 0.0
		var eng_skill: float  = float(leader.skills.get("工程", 0.0)) if leader else 0.0

		# 本格+鄰格採集所得聚合（私產部分），用於課一般稅（稅進站立 tile 公庫）
		var gained: Dictionary = {}
		if tile.outpost_level == 3:
			_collect_from_tile(state, team, tile, 2.0, pop_mult, prod_skill, eng_skill, gained, day_fraction)
			for neighbor in _get_adjacent_tiles(state, team.tile_pos):
				_collect_from_tile(state, team, neighbor, 0.5, pop_mult, prod_skill, eng_skill, gained, day_fraction)
		else:
			var outpost_mult: float = [1.0, 1.4][tile.outpost_level - 1]
			_collect_from_tile(state, team, tile, outpost_mult, pop_mult, prod_skill, eng_skill, gained, day_fraction)

		_apply_normal_tax(state, team, tile, gained)

func regenerate_tiles(state: WorldState, cadence_ticks: int = WorldState.TICKS_PER_DAY) -> void:
	# R1：food regen 乘 day_fraction（與 consumption 同 cadence 基準）→ REGEN_RATE 值成真 per-day
	# （forest 3/day marginal，不再秘密×24）。material regen 不縮放（pool cap-bound，harvest ÷24 才是節流）。
	var day_fraction: float = float(cadence_ticks) / float(WorldState.TICKS_PER_DAY)
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		var rates = REGEN_RATE.get(tile.terrain, { "food": 2.0, "material": 1.0 })
		# food 再生受 harvest_factor 調節（季節性植物生長）
		var food_regen: float = float(rates["food"]) * tile.harvest_factor * day_fraction
		TileBank.pool_set(tile, "food", minf(
			float(tile.resources.get("food", 0)) + food_regen,
			float(tile.resource_cap.get("food", 0))
		), "regen_food")
		var mat_regen: float = float(rates["material"])
		TileBank.pool_set(tile, "material", minf(
			float(tile.resources.get("material", 0)) + mat_regen,
			float(tile.resource_cap.get("material", 0))
		), "regen_material")
		# wild_game 慢繁殖回補（獵物採乾後再生，上限夾 resource_cap 不破稀有度）
		var wg_cap: float = float(tile.resource_cap.get("wild_game", 0))
		if wg_cap > 0.0:
			var wg_cur: float = float(tile.resources.get("wild_game", 0))
			if wg_cur < wg_cap:
				var wg_regen: float = WILD_GAME_REGEN_PER_DAY * day_fraction
				TileBank.pool_set(tile, "wild_game",
					minf(wg_cur + wg_regen, wg_cap), "regen_wildgame")
		# ore / gem 不再生

func resolve_consumption(state: WorldState, team_ids: Array, cadence_ticks: int) -> void:
	var day_fraction: float = float(cadence_ticks) / float(WorldState.TICKS_PER_DAY)
	var ms := MovementSystem.new()
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		# mount 吃糧（草料）：effective_mounts × 0.5/day
		var em: int = ms.get_effective_mounts(team)
		if em > 0:
			var mount_food: float = float(em) * FOOD_PER_MOUNT_PER_DAY * day_fraction
			ResourceBank.remove(team, "food", mount_food, "mount_feed")
		# 馴馬（horses）草料：×0.5/day，馴馬不騎 → 不受 effective（pop）限制
		var horses_n: float = float(team.resources.get("horses", 0))
		if horses_n > 0.0:
			var horse_food: float = horses_n * FOOD_PER_MOUNT_PER_DAY * day_fraction
			ResourceBank.remove(team, "food", horse_food, "horse_feed")
		var total_pop: int = team.population + team.minor_population
		var food_needed: float = float(total_pop) * FOOD_PER_PERSON_PER_DAY * day_fraction
		# WS-1：定居隊 food 在自家糧倉（public_storage）。消耗從「team.resources + 自家糧倉」
		# 合併池提領（先 team 後糧倉）→ food 在哪都不誤餓。消耗是 sink，從哪扣都守恆。
		var granary: HexTileData = own_granary_tile(state, team)
		var team_food: float = float(team.resources.get("food", 0))
		var granary_food: float = float(granary.public_storage.get("food", 0)) if granary != null else 0.0
		var food_available: float = team_food + granary_food

		if food_available >= food_needed:
			# 先扣 team.resources，不足再扣糧倉
			var from_team: float = minf(team_food, food_needed)
			ResourceBank.set_amt(team, "food", team_food - from_team, "eat_team")
			var rem: float = food_needed - from_team
			if rem > 0.0 and granary != null:
				TileBank.set_amt(granary, "food", granary_food - rem, "eat_granary")
			_update_person_needs(state, tid, "food", 1.0, day_fraction)
			team.famine_days = 0.0   # 吃飽 → 斷糧計時歸零
		else:
			# 池耗盡：team 與糧倉 food 都歸零
			ResourceBank.set_amt(team, "food", 0.0, "eat_depleted")
			if granary != null:
				TileBank.set_amt(granary, "food", 0.0, "eat_granary_depleted")
			var satisfaction: float = food_available / food_needed if food_needed > 0.0 else 0.0
			_update_person_needs(state, tid, "food", satisfaction, day_fraction)
			# 團級斷糧累積 + grace 後 minor/anon 耗損
			if satisfaction < FAMINE_SATISFACTION_THRESHOLD:
				team.famine_days += day_fraction
				if team.famine_days > float(FAMINE_GRACE_DAYS):
					_apply_famine_attrition(state, team, day_fraction)
			else:
				team.famine_days = 0.0
			# G-04：玩家食物告急通知
			if state.player_id != -1:
				var pp: PersonData = state.persons.get(state.player_id)
				if pp != null and pp.team_id == tid and satisfaction < 0.3:
					var already: bool = false
					for a in state.player_alerts:
						if a["type"] == "food_critical": already = true; break
					if not already:
						state.player_alerts.append({
							"type": "food_critical",
							"tick": state.world.current_tick,
							"data": { "needs_ratio": satisfaction }
						})

			# 飢餓徵用：food < 1 天份 + treasury > 0 → 應急抽公庫換 coin
			var food_after: float = float(team.resources.get("food", 0))
			if food_after < float(team.population) * FOOD_PER_PERSON_PER_DAY \
					and team.anon_treasury > 0.0:
				FactionAISystem.new()._extract_treasury(state, team, 0.3, "飢餓緊急")

		# WS-2d 旅途乾糧：隊在自家 outpost → 從糧倉補 carried food 到 buffer（出門帶著走，
		# 不被糧倉拴住）。糧倉→team 同隊轉移(守恆)。buffer 小(N天份)不破囤糧 cap。
		# 真絕境(糧倉空)→avail=0→無糧可補→carried 不變→仍正確進 survival。
		var gtile: HexTileData = own_granary_tile(state, team)
		if gtile != null:
			var buffer: float = float(team.population + team.minor_population) \
				* FOOD_PER_PERSON_PER_DAY * PROVISION_DAYS
			var carried: float = float(team.resources.get("food", 0))
			var need: float = buffer - carried
			if need > 0.0:
				var avail: float = float(gtile.public_storage.get("food", 0))
				var move: float = minf(need, avail)
				ResourceBank.set_amt(team, "food", carried + move, "provision_carry")
				TileBank.set_amt(gtile, "food", avail - move, "provision_granary_out")

		# R2：本 cadence 末更新食物流訊號（income − consumption 的日均 EMA）。
		_update_food_flow(state, team, day_fraction)
		# ★糧流感知 Slice A：每日 cadence 末算 runway 快取（harvest-only 內生 inflow−burn）→ persist safe_ratio 讀。
		FoodFlow.update(state, team)

# R2 flow-not-stock：日均淨食物流 EMA。net = effective_food(末) − 上次取樣；除 day_fraction → 日率；
# α=day_fraction/FLOW_WINDOW_DAYS → 時間常數平滑（near/far cadence 無關）。首取樣只 seed 不計流。
# 離開自家糧倉 → effective_food 跌（糧倉不計）→ 一次負脈衝壓低 flow → 偏向不成長（安全方向，
# 絕不假陽性成長）；重新定居後 EMA 於窗內回復。移動隊本不是成長候選（生育須安定+盈餘）。
func _update_food_flow(state: WorldState, team: TeamData, day_fraction: float) -> void:
	if day_fraction <= 0.0:
		return
	var post_food: float = effective_food(state, team)
	if team.food_flow_last < 0.0:
		team.food_flow_last = post_food   # 首取樣 seed，不計流
		return
	var daily_rate: float = (post_food - team.food_flow_last) / day_fraction
	var alpha: float = clampf(day_fraction / FLOW_WINDOW_DAYS, 0.0, 1.0)
	team.food_flow_avg += alpha * (daily_rate - team.food_flow_avg)
	team.food_flow_last = post_food

# grace 期後每日餓死：先死 minor，minor 耗盡才死 anon。
# cadence 多次/日 → 用 famine_days 跨整數日偵測，只在跨日當次結算（避免重複殺）。
func _apply_famine_attrition(state: WorldState, team: TeamData, day_fraction: float) -> void:
	if int(team.famine_days) == int(team.famine_days - day_fraction):
		return   # 未跨整數日，不結算
	if team.minor_population > 0:
		var md: int = ceili(float(team.minor_population) * FAMINE_MINOR_DEATH_RATE)
		md = mini(md, team.minor_population)
		team.minor_population -= md
		if Probe.enabled: Probe.bump("death.starve_minor", md)
		print("[Famine] Team%d 餓死 minor %d (famine=%.0f天)" % [team.team_id, md, team.famine_days])
		return
	var anon_total: int = AnonTierSystem.total_pop(team)
	if anon_total > 0:
		var ad: int = maxi(ceili(float(anon_total) * FAMINE_ANON_DEATH_RATE), 1)
		var killed: Dictionary = AnonTierSystem.kill_random(team, ad, "famine")
		var actually: int = 0
		for t in killed:
			actually += killed[t]
		if Probe.enabled: Probe.bump("death.starve_anon", actually)
		print("[Famine] Team%d 餓死 anon %d (famine=%.0f天)" % [team.team_id, actually, team.famine_days])

# 日邊界：覓食累積彙整成 episode（只玩家隊發訊息，其餘僅歸零防 spam）。回傳產生的訊息文字陣列（供測試/UI）。
func flush_forage_episodes(state: WorldState, team_ids: Array) -> Array:
	var out: Array = []
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var got: float = float(team.forage_today)
		team.forage_today = 0.0
		if got <= 0.0:
			continue
		var is_player: bool = false
		var leader = state.persons.get(team.leader_id)
		if leader != null and leader.id == state.player_id:
			is_player = true
		if is_player:
			out.append("覓食所得 +%d 糧" % int(round(got)))
	return out

func _collect_from_tile(state: WorldState, team: TeamData, src_tile: HexTileData,
		outpost_mult: float, pop_mult: float,
		prod_skill: float, eng_skill: float, gained: Dictionary = {},
		day_fraction: float = 1.0) -> void:
	for res in src_tile.resources.keys():
		if res == "wild_horses" or res == "wild_game":
			continue   # 活物不走 generic 採集（野馬日捕在 HarvestSystem；野味走 HuntSystem）
		var current: float = float(src_tile.resources.get(res, 0))
		if current <= 0.0:
			continue
		# R1：harvest 乘 day_fraction（與 consumption 同 cadence 基準，修 24× 供給不對稱）
		var gain: float = src_tile.productivity * current * COLLECT_RATE * day_fraction
		gain *= outpost_mult * pop_mult
		gain *= team.work_morale
		match res:
			"food":
				gain *= (1.0 + float(src_tile.farming_level) * 0.5)
				gain *= (1.0 + prod_skill * 0.3)
				gain *= src_tile.harvest_factor
			"material":
				gain *= (1.0 + eng_skill * 0.3)
			"ore_gold", "ore_silver":
				gain *= (1.0 + eng_skill * 0.5)
		if res in PUBLIC_RESOURCES or res == "food":
			# 礦/主糧進腳下 outpost 公庫（糧倉），over-cap drop = sink。
			# food 進糧倉 = 等義「自己存自己村庫」（採集者即 owner→自存村庫），
			# 故 food 不入 gained → 不再走一般稅 split（避免重複入庫）。
			var dst_tile: HexTileData = state.world.tiles.get(_pos_to_tile_id(team.tile_pos))
			if dst_tile != null and dst_tile.outpost_level > 0:
				# S5：第二 sink 記帳——自然資源 over-cap 是 legit 倉容上限(落自然池會撞 regen cap-clamp 故不落地)，補 tap 使可觀測。
					var _dep: float = TileBank.deposit(dst_tile, res, gain, "harvest_intake_vault")   # capped，over-cap = legit 倉滿
					if gain - _dep > 0.001:
						Probe.bump("harvest.vault_overflow_drop")   # S5 tap：糧倉滿溢出可觀測(S5 閘對此資源不假)
			else:
				# 無 outpost fallback 進 team（小隊；food 仍記 gained 供一般稅）
				ResourceBank.add(team, res, gain, "harvest_intake")
				if res == "food":
					gained[res] = float(gained.get(res, 0)) + gain
		else:
			# WS-3：移動無 outpost 隊 intake 受 carry 空間硬限（超額留 tile = conservation-safe）。
			# weight 0 的 res（mounts/wagons）→ carry_space_for_res 回大數 → 不誤限。
			var space_qty: int = MovementSystem.new().carry_space_for_res(team, res)
			gain = minf(gain, float(space_qty))
			if gain <= 0.0:
				continue   # 滿載不採 → 留 tile，tile 不扣
			ResourceBank.add(team, res, gain, "harvest_carry")
			gained[res] = float(gained.get(res, 0)) + gain   # 私產所得 → 一般稅基數
		# 從 tile 扣除（food/material 最終由 regenerate_tiles 補回；ore/gem 有限）
		TileBank.pool_set(src_tile, res, maxf(current - gain, 0.0), "harvest_deplete")

# 一般稅：採集所得按 owner tax_rate 撥腳下 tile 公庫（守恆轉移：私產減=公庫增）。
# 公庫滿 cap → 多的留採集者私產（不溢出）。稅率 = tile owner 的 tax_rate；
# 採集者即 owner（自立村）→ 自己存自己村庫。
func _apply_normal_tax(state: WorldState, team: TeamData, tile: HexTileData,
		gained: Dictionary) -> void:
	if tile.outpost_level == 0:
		return
	var owner: TeamData = state.teams.get(tile.outpost_owner)
	var rate: float = float(owner.tax_rate) if owner != null else float(team.tax_rate)
	if rate <= 0.0:
		return
	var os := OutpostSystem.new()
	for res in NORMAL_TAX_RES:
		var g: float = float(gained.get(res, 0))
		if g <= 0.0:
			continue
		var tax: float = g * rate
		var cap: float = os._get_storage_cap(tile, res)
		var cur: float = float(tile.public_storage.get(res, 0))
		var space: float = maxf(cap - cur, 0.0)
		var actual: float = minf(tax, space)          # cap 滿 → 多的留私產
		if actual <= 0.0:
			continue
		ResourceBank.add(team, res, -actual, "normal_tax")
		TileBank.set_amt(tile, res, cur + actual, "normal_tax_vault")
	_apply_chronic_tax_unrest(state, team, rate)

# 一般稅慢性不滿：tax_rate 超容忍閾值 → 居民 leader/named stress 緩增；超久 → unrest_turns。
# tolerance = 0.3 + 順從×0.2 + 義氣×0.1 − 野心×0.2（個性決定，非硬編）
func _apply_chronic_tax_unrest(state: WorldState, team: TeamData, rate: float) -> void:
	var lp: PersonData = state.persons.get(team.leader_id)
	if lp == null:
		return
	var submit: float = float(lp.values.get("順從", 0.5))
	var honor_v: float = float(lp.values.get("義氣", 0.5))
	var amb: float = float(lp.values.get("野心", 0.5))
	var tolerance: float = 0.3 + submit * 0.2 + honor_v * 0.1 - amb * 0.2
	if rate <= tolerance:
		return
	var p_stress: float = (rate - tolerance) * 0.02
	var targets: Array = []
	if team.leader_id != -1:
		targets.append(team.leader_id)
	targets.append_array(team.named_members)
	for pid in targets:
		var p: PersonData = state.persons.get(pid)
		if p == null:
			continue
		p.stress = minf(p.stress + p_stress, 1.0)
	# 慢性累積：leader 長期高壓 → 緩升 unrest（暴政自毀的下行通道）
	if lp.stress > 0.7:
		UnrestBank.add(team, 1, "famine")

func _get_adjacent_tiles(state: WorldState, center: Vector2i) -> Array:
	var result: Array = []
	for d in HEX_DIRS:
		var nid: int = _pos_to_tile_id(center + d)
		if state.world.tiles.has(nid):
			result.append(state.world.tiles[nid])
	return result

func _update_person_needs(state: WorldState, team_id: int, need: String, value: float,
		day_fraction: float = 0.0) -> void:
	for pid in state.persons:
		var person: PersonData = state.persons[pid]
		if person.team_id != team_id:
			continue
		person.needs[need] = value
		if value < 0.5:
			person.stress = minf(person.stress + (0.5 - value) * 0.2, 1.0)
		else:
			person.stress = maxf(person.stress - 0.05, 0.0)
		if need == "food":
			if value < 0.3:
				person.fear    = minf(person.fear + 0.05, 1.0)
				LoyaltyBank.adjust(person, -0.02, "hunger")
			else:
				person.fear = maxf(person.fear - 0.02, 0.0)
			# 個人飢餓累積（斷糧越深累積越快；吃飽則回復）
			if value < FAMINE_SATISFACTION_THRESHOLD:
				person.hunger = minf(person.hunger + HUNGER_GAIN_PER_DAY * day_fraction
					* (FAMINE_SATISFACTION_THRESHOLD - value) / FAMINE_SATISFACTION_THRESHOLD, 1.0)
			else:
				person.hunger = maxf(person.hunger - HUNGER_RECOVER_PER_DAY * day_fraction, 0.0)

# WS-1：team 站在自家 outpost tile → 回該 tile（糧倉）；否則 null。
# 消耗合併池 + WS-2c effective_food 決策讀者共用。static：accessor 與決策讀者皆免實例。
static func own_granary_tile(state: WorldState, team: TeamData) -> HexTileData:
	var tile: HexTileData = state.world.tiles.get(_pos_to_tile_id(team.tile_pos))
	if tile != null and tile.outpost_level > 0 and tile.outpost_owner == team.team_id:
		return tile
	return null

# WS-2c：本隊「有效糧」= 私產 food + 自家糧倉 food（決策讀者單源；消耗扣除走 resolve_consumption）。
# WS-1 把定居隊 food 搬進糧倉(team.resources food=0)只改了消耗，漏改決策讀者 →
# 定居隊/商隊 AI 誤判餓。決策讀者（survival/trade/ambition gate）一律經此。
# 讀B：覓食 subsistence buffer = pop × 食/人/日 × FORAGE_FLOOR_DAYS。覓食來源食物 net-bank 上限。
# 只封覓食（team.resources food）非 granary → 定居隊繁榮不受誤傷。hunt_system 累積前查此。
static func _forage_subsist_buffer(team: TeamData) -> float:
	return float(team.population) * FOOD_PER_PERSON_PER_DAY * FORAGE_FLOOR_DAYS

# 統一持有 accessor（unified-commerce M4，收 supply-seam）：本隊「有效持有」= 私產 + 自家糧倉公庫。
# 決策/掛單/估值全讀此（team.resources 誤判定居隊糧倉貨為短缺）。effective_food = 此的 food 特化別名。
static func effective_holding(state: WorldState, team: TeamData, res: String) -> float:
	var g: HexTileData = own_granary_tile(state, team)
	var gs: float = float(g.public_storage.get(res, 0)) if g != null else 0.0
	return float(team.resources.get(res, 0)) + gs

static func effective_food(state: WorldState, team: TeamData) -> float:
	return effective_holding(state, team, "food")

# 統一花費（M4，去 absorb/spill dance）：扣自家糧倉公庫優先，餘扣 team.resources。無透支，回實際扣量。
# 決策-執行語意對稱：讀 effective_holding、扣 spend_holding，storage-aware 一致。
static func spend_holding(state: WorldState, team: TeamData, res: String, qty: float) -> float:
	if qty <= 0.0:
		return 0.0
	var remain: float = qty
	var g: HexTileData = own_granary_tile(state, team)
	if g != null:
		var gs: float = float(g.public_storage.get(res, 0))
		var take_g: float = minf(gs, remain)
		if take_g > 0.0:
			TileBank.set_amt(g, res, gs - take_g, "spend_holding_storage")
			remain -= take_g
	if remain > 0.0:
		var tr: float = float(team.resources.get(res, 0))
		var take_t: float = minf(tr, remain)
		if take_t > 0.0:
			ResourceBank.set_amt(team, res, tr - take_t, "spend_holding_team")
			remain -= take_t
	return qty - remain

static func _pos_to_tile_id(pos: Vector2i) -> int:
	return pos.x * 1000 + pos.y
