class_name HarvestSystem

# TIER: n/a — 曆法基底（單位定義），不是節律
const SEASON_LENGTH: int = WorldState.TICKS_PER_SEASON   # 1季 = 90天
const SEASON_BASE: Array  = [1.1, 1.5, 1.2, 0.3]      # 春夏秋冬
const SEASON_NAMES: Array = ["春", "夏", "秋", "冬"]

var _last_season: int = -1   # diff print：季節變化才印

# ★★★世界級排程的到期判斷（`modulo-same-shape-4`，2026-09-06；★systems 裁 (b)）——
#   ★取代裸 `current_tick % INTERVAL == 0`：那種寫法要求【恰好那一 tick 有人跑到】，
#     而本檔的 `tick_all` 只在 `tick % (TICKS_PER_DAY/4)` 被呼叫 ⇒ ★★安全與否取決於
#     【INTERVAL 是不是外層 cadence 的倍數】—— 那是算術巧合，不是機制。
#
# ★★★而【不加相位偏移】（不走 `CadenceStagger`）是 systems 的裁定，理由有兩層：
#   ①對比輪【正在跑】，它比的是兩顆固定 commit ⇒ 現在合一個【會改 fp】的東西進 main，
#     ③ 就移動了，而 measurer 已交出去的兩格會跟後面八格【不在同一個世界】。
#   ②★★就這張票本身：票②的病是【潛在脆弱性】，而加相位偏移【順手多做了一件事】
#     （四個 regen 去同批）—— ★★★那是【另一張票的好處】被夾帶進來，
#     而「一次改兩件事 ⇒ 歸因不了」是同一條規矩。（regen 去同批已具名成候選，不是丟掉。）
#
# ★等價性（★這是「fp 逐位元不變」的理由，不是願望）：
#   `next` 起始 0 ⇒ 第一次呼叫必 fire（等同舊制 `0 % INTERVAL == 0`）；
#   之後 `next = (current / cadence + 1) * cadence` ⇒ 落在【下一個 INTERVAL 邊界】
#   ⇒ ★INTERVAL 整除外層 cadence 時，fire 的 tick 集合【與舊制完全相同】
#   ⇒ ★★而不整除時（＝將來有人改外層 cadence），舊制【整段不 fire】、新制【到期後第一次補上】
#      —— 那正是這張票要買的東西。
static func _due(world: WorldData, next_tick: int, cadence: int) -> Array:
	# 回 [是否到期, 新的 next_tick]
	if world.current_tick < next_tick:
		return [false, next_tick]
	return [true, (world.current_tick / cadence + 1) * cadence]

func tick_all(state: WorldState) -> void:
	# ★S1b 白名單(c)：4 ＝【一年幾季】的曆法結構 ——
	#   ★分子已由 SEASON_LENGTH 導出（會隨根縮放），★★這個 4 不隨小時縮放：
	#   一年永遠四季，tick 密度改了它仍須是 4。
	var season: int  = (state.world.current_tick / SEASON_LENGTH) % 4
	# ★★★S5a（2026-09-01）：季節曲線取代 6h 亂擲。
	#   ★①刪 randf_range —— ★★舊寫法每 tile 獨立擲一次 ⇒ 同一 tick 相鄰兩格可以差 0.5，
	#     那不是「季節」，是雜訊；而它同時是 RNG 流的大戶。
	#   ★②base 改【平滑】：季內進度 t ∈ [0,1) 在【本季錨點】與【下季錨點】之間插值。
	#   ★★★不引入新魔術常數：只用既有的 SEASON_BASE 四個值 ＋ t（4 是「一年四季」的曆法結構）。
	#
	# ★★季界連續性（這是插值正確的字面量）：
	#     t → 1 時 base → SEASON_BASE[(s+1)%4]，而下一季 t = 0 時 base = SEASON_BASE[(s+1)%4]
	#   ⇒ 兩者【相等】⇒ 季界不跳變。
	#
	# ★★★錨點語意寫明（我做的選擇，不是 spec 指定的）：
	#   SEASON_BASE[s] 是【該季開始】的值，不是季中峰值 ——
	#   ⇒ 夏的 1.5 落在【夏季第一天】，而夏季末已經在往秋的 1.2 走。
	#   ★若要「峰值落在季中」，那是把錨點整體位移半季 —— ★★那是設計選擇，我沒有自己做。
	var t: float     = float(state.world.current_tick % SEASON_LENGTH) / float(SEASON_LENGTH)
	var base: float  = lerp(float(SEASON_BASE[season]), float(SEASON_BASE[(season + 1) % 4]), t)
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		# ★clamp 保留但【現在不會 binding】：插值落在 [0.3, 1.5] 內，而界是 [0.1, 2.0]。
		#   留著是因為它守的是【欄位契約】（tile_data.gd:8 標 0.1–2.0），不是這條計算。
		tile.harvest_factor = clampf(base, 0.1, 2.0)
	if season != _last_season:
		_last_season = season
		print("[Harvest] Tick%d 季節=%s base=%.1f" % [
			state.world.current_tick, SEASON_NAMES[season], base])
	_check_famine_warnings(state)
	_regen_wild_horses(state)
	_regen_wild_game(state)
	_regen_predator(state)
	_regen_herb(state)
	# 每日 outpost 鄰格 wild_horses 批採進公庫（tick_all 每 6 小時跑，日邊界才採）
	var _d0: Array = _due(state.world, state.world.harvest_daily_next_tick, WorldState.TICKS_PER_DAY)
	state.world.harvest_daily_next_tick = int(_d0[1])
	if bool(_d0[0]):
		_collect_wild_horses_by_outposts(state)
		_decay_l0_camps(state)

# ★settlement S2a：L0 營地棄置衰敗（每日、全 tile sweep 覆近+遠區、零 RNG）。有人 forage 者當日已
# 在 collect_resources reset camp_ticks_left→full；無人→此處遞減、<=0→camp_level=0（無廢墟、地圖自清）。
func _decay_l0_camps(state: WorldState) -> void:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.camp_level <= 0:
			continue
		tile.camp_ticks_left -= WorldState.TICKS_PER_DAY
		if tile.camp_ticks_left <= 0:
			# ★§4c 反饋（失敗掛點之一）：L0 營地被棄置到衰敗＝這塊地沒留住人 → 寫起建隊 leader 的
			# 選址記憶（隊已滅/leader 已亡則跳過＝人死沒人記得）。純讀 camp_team_id、零 RNG。
			var _founder: TeamData = state.teams.get(tile.camp_team_id) if tile.camp_team_id != -1 else null
			if _founder != null:
				SettlementMemory.record_site_outcome(state, _founder, tile, SettlementMemory.SITE_FAILED)
			tile.camp_level = 0
			if Probe.enabled: Probe.bump("camp.abandoned")   # ★gate3：蓋了就丟＝亂蓋的特徵
			tile.camp_ticks_left = 0
			tile.camp_team_id = -1
			OwnerCampIndex.invalidate()   # ★own-camp chokepoint②（清）：營地衰敗消失 ⇒ 姊妹索引失效

const WILD_HORSE_REGEN_CHANCE: float = 0.05   # 每月 5% chance +1（極慢）
const WILD_HORSE_TILE_CAP: int = 3
const WILD_HORSE_TILE_CAP_RICH: int = 8   # 野馬草原 cap（resource_cap["wild_horses"]>=4 標記富點）

# 每月（month 邊界）平原/森林 tile 5% 機率 +1 野馬，上限 cap（一般 3 / 野馬草原 8）
func _regen_wild_horses(state: WorldState) -> void:
	var _d: Array = _due(state.world, state.world.regen_horses_next_tick, WorldState.TICKS_PER_MONTH)
	state.world.regen_horses_next_tick = int(_d[1])
	if not bool(_d[0]):
		return
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.terrain != "plains" and tile.terrain != "forest":
			continue
		var cap: int = WILD_HORSE_TILE_CAP_RICH if int(tile.resource_cap.get("wild_horses", 0)) >= 4 else WILD_HORSE_TILE_CAP
		if int(tile.resources.get("wild_horses", 0)) >= cap:
			continue
		if randf() < WILD_HORSE_REGEN_CHANCE:
			TileBank.pool_set(tile, "wild_horses", int(tile.resources.get("wild_horses", 0)) + 1, "regen_wild_horses")

const WILD_GAME_REGEN_CHANCE: float = 0.30   # TEST VALUE — 每月增長機率（比野馬快，獵物繁殖快）

# 每月（month 邊界）平原/森林 tile 機率 +1 wild_game，上限 resource_cap["wild_game"]
func _regen_wild_game(state: WorldState) -> void:
	var _d: Array = _due(state.world, state.world.regen_game_next_tick, WorldState.TICKS_PER_MONTH)
	state.world.regen_game_next_tick = int(_d[1])
	if not bool(_d[0]):
		return
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		var cap: int = int(tile.resource_cap.get("wild_game", 0))
		if cap <= 0:
			continue
		var cur: int = int(tile.resources.get("wild_game", 0))
		if cur >= cap:
			continue
		if randf() < WILD_GAME_REGEN_CHANCE:
			TileBank.pool_set(tile, "wild_game", cur + 1, "regen_wild_game")

const PREDATOR_REGEN_CHANCE: float = 0.10   # TEST VALUE — 猛獸再生較慢（繁殖慢）

# 每月（month 邊界）森林/山地 tile 機率 +1 predator_density，上限 resource_cap["predator_density"]
func _regen_predator(state: WorldState) -> void:
	var _d: Array = _due(state.world, state.world.regen_predator_next_tick, WorldState.TICKS_PER_MONTH)
	state.world.regen_predator_next_tick = int(_d[1])
	if not bool(_d[0]):
		return
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.terrain != "forest" and tile.terrain != "mountain":
			continue
		var cap: int = int(tile.resource_cap.get("predator_density", 0))
		if cap <= 0:
			continue
		var cur: int = int(tile.resources.get("predator_density", 0))
		if cur >= cap:
			continue
		if randf() < PREDATOR_REGEN_CHANCE:
			TileBank.pool_set(tile, "predator_density", cur + 1, "regen_predator")

# 每月（month 邊界）herb +1 至 resource_cap["herb"]（生成初始值）
func _regen_herb(state: WorldState) -> void:
	var _d: Array = _due(state.world, state.world.regen_herb_next_tick, WorldState.TICKS_PER_MONTH)
	state.world.regen_herb_next_tick = int(_d[1])
	if not bool(_d[0]):
		return
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		var cap: int = int(tile.resource_cap.get("herb", 0))
		if cap <= 0:
			continue
		var cur: int = int(tile.resources.get("herb", 0))
		if cur < cap:
			TileBank.pool_set(tile, "herb", cur + 1, "regen_herb")

# hex 軸座標六方向
const HEX_DIRS: Array = [
	Vector2i(1, 0), Vector2i(-1, 0),
	Vector2i(0, 1), Vector2i(0, -1),
	Vector2i(1, -1), Vector2i(-1, 1),
]

# 每日：所有 outpost 對鄰格 wild_horses 捕獲進自家公庫 horses（馴馬，非戰馬）。
# 日捕上限：1 + stable_level（限 civilian 馬廄 = 馴馬設施加成），其餘 1。
func _collect_wild_horses_by_outposts(state: WorldState) -> void:
	var os := OutpostSystem.new()
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_owner == -1 or tile.outpost_level == 0:
			continue
		var daily_cap: int = 1
		if tile.outpost_type == "civilian":
			daily_cap += tile.stable_level
		var cap: float = os._get_storage_cap(tile, "horses")
		var stored: float = float(tile.public_storage.get("horses", 0))
		var caught: int = 0
		for d in HEX_DIRS:
			if caught >= daily_cap:
				break
			var npos: Vector2i = tile.tile_pos + d
			var ntile: HexTileData = state.world.tiles.get(npos.x * 1000 + npos.y)
			if ntile == null:
				continue
			var wh: int = int(ntile.resources.get("wild_horses", 0))
			if wh <= 0:
				continue
			var space: float = maxf(cap - stored, 0.0)
			var taken: int = mini(mini(wh, daily_cap - caught), int(space))
			if taken > 0:
				caught += taken
				stored += float(taken)
				TileBank.pool_set(ntile, "wild_horses", wh - taken, "harvest_horse_catch")
				TileBank.set_amt(tile, "horses", stored, "harvest_horse_store")
				print("[Horse] Outpost %s 捕野馬 +%d" % [str(tile.tile_pos), taken])

func _check_famine_warnings(state: WorldState) -> void:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.harvest_factor >= 0.5 or tile.outpost_level == 0 or tile.outpost_type != "civilian":
			continue
		var owner_team: TeamData = state.teams.get(tile.outpost_owner)
		if owner_team == null:
			continue
		SimMessageSystem.new().emit_message(state, "famine_warning",
			TextBank.fmt("famine_warning", "default", {"origin": str(owner_team.team_id), "harvest": "%.2f" % tile.harvest_factor}),
			owner_team,
			{"origin": str(owner_team.team_id), "tile_pos": tile.tile_pos, "harvest_factor": tile.harvest_factor})
