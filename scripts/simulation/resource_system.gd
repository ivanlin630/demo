class_name ResourceSystem

const FOOD_PER_PERSON_PER_DAY: float = 2.4   # TEST VALUE — 2.4食物/人/天（原 0.1×24）
const FOOD_PER_MOUNT_PER_DAY: float = 0.5    # TEST VALUE — 草料 0.5食物/馬/天

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

func collect_resources(state: WorldState, team_ids: Array) -> void:
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
			_collect_from_tile(state, team, tile, 2.0, pop_mult, prod_skill, eng_skill, gained)
			for neighbor in _get_adjacent_tiles(state, team.tile_pos):
				_collect_from_tile(state, team, neighbor, 0.5, pop_mult, prod_skill, eng_skill, gained)
		else:
			var outpost_mult: float = [1.0, 1.4][tile.outpost_level - 1]
			_collect_from_tile(state, team, tile, outpost_mult, pop_mult, prod_skill, eng_skill, gained)

		_apply_normal_tax(state, team, tile, gained)

func regenerate_tiles(state: WorldState) -> void:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		var rates = REGEN_RATE.get(tile.terrain, { "food": 2.0, "material": 1.0 })
		# food 再生受 harvest_factor 調節（季節性植物生長）
		var food_regen: float = float(rates["food"]) * tile.harvest_factor
		tile.resources["food"] = minf(
			float(tile.resources.get("food", 0)) + food_regen,
			float(tile.resource_cap.get("food", 0))
		)
		var mat_regen: float = float(rates["material"])
		tile.resources["material"] = minf(
			float(tile.resources.get("material", 0)) + mat_regen,
			float(tile.resource_cap.get("material", 0))
		)
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
			team.resources["food"] = maxf(0.0, float(team.resources.get("food", 0)) - mount_food)
		# 馴馬（horses）草料：×0.5/day，馴馬不騎 → 不受 effective（pop）限制
		var horses_n: float = float(team.resources.get("horses", 0))
		if horses_n > 0.0:
			var horse_food: float = horses_n * FOOD_PER_MOUNT_PER_DAY * day_fraction
			team.resources["food"] = maxf(0.0, float(team.resources.get("food", 0)) - horse_food)
		var total_pop: int = team.population + team.minor_population
		var food_needed: float = float(total_pop) * FOOD_PER_PERSON_PER_DAY * day_fraction
		var food_available: float = float(team.resources.get("food", 0))

		if food_available >= food_needed:
			team.resources["food"] = food_available - food_needed
			_update_person_needs(state, tid, "food", 1.0, day_fraction)
			team.famine_days = 0.0   # 吃飽 → 斷糧計時歸零
		else:
			team.resources["food"] = 0.0
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

# grace 期後每日餓死：先死 minor，minor 耗盡才死 anon。
# cadence 多次/日 → 用 famine_days 跨整數日偵測，只在跨日當次結算（避免重複殺）。
func _apply_famine_attrition(state: WorldState, team: TeamData, day_fraction: float) -> void:
	if int(team.famine_days) == int(team.famine_days - day_fraction):
		return   # 未跨整數日，不結算
	if team.minor_population > 0:
		var md: int = ceili(float(team.minor_population) * FAMINE_MINOR_DEATH_RATE)
		md = mini(md, team.minor_population)
		team.minor_population -= md
		print("[Famine] Team%d 餓死 minor %d (famine=%.0f天)" % [team.team_id, md, team.famine_days])
		return
	var anon_total: int = AnonTierSystem.total_pop(team)
	if anon_total > 0:
		var ad: int = maxi(ceili(float(anon_total) * FAMINE_ANON_DEATH_RATE), 1)
		var killed: Dictionary = AnonTierSystem.kill_random(team, ad, "famine")
		var actually: int = 0
		for t in killed:
			actually += killed[t]
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
		prod_skill: float, eng_skill: float, gained: Dictionary = {}) -> void:
	for res in src_tile.resources.keys():
		if res == "wild_horses" or res == "wild_game":
			continue   # 活物不走 generic 採集（野馬日捕在 HarvestSystem；野味走 HuntSystem）
		var current: float = float(src_tile.resources.get(res, 0))
		if current <= 0.0:
			continue
		var gain: float = src_tile.productivity * current * COLLECT_RATE
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
		if res in PUBLIC_RESOURCES:
			# 礦進自家 outpost 公庫
			var dst_tile: HexTileData = state.world.tiles.get(_pos_to_tile_id(team.tile_pos))
			if dst_tile != null and dst_tile.outpost_level > 0:
				var cap: float = OutpostSystem.new()._get_storage_cap(dst_tile, res)
				var stored: float = float(dst_tile.public_storage.get(res, 0))
				dst_tile.public_storage[res] = minf(stored + gain, cap)
			else:
				# 無 outpost fallback 進 team
				team.resources[res] = float(team.resources.get(res, 0)) + gain
		else:
			team.resources[res] = float(team.resources.get(res, 0)) + gain
			gained[res] = float(gained.get(res, 0)) + gain   # 私產所得 → 一般稅基數
		# 從 tile 扣除（food/material 最終由 regenerate_tiles 補回；ore/gem 有限）
		src_tile.resources[res] = maxf(current - gain, 0.0)

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
		team.resources[res] = float(team.resources.get(res, 0)) - actual
		tile.public_storage[res] = cur + actual
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
		team.unrest_turns += 1

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
				person.loyalty = maxf(person.loyalty - 0.02, 0.0)
			else:
				person.fear = maxf(person.fear - 0.02, 0.0)
			# 個人飢餓累積（斷糧越深累積越快；吃飽則回復）
			if value < FAMINE_SATISFACTION_THRESHOLD:
				person.hunger = minf(person.hunger + HUNGER_GAIN_PER_DAY * day_fraction
					* (FAMINE_SATISFACTION_THRESHOLD - value) / FAMINE_SATISFACTION_THRESHOLD, 1.0)
			else:
				person.hunger = maxf(person.hunger - HUNGER_RECOVER_PER_DAY * day_fraction, 0.0)

func _pos_to_tile_id(pos: Vector2i) -> int:
	return pos.x * 1000 + pos.y
