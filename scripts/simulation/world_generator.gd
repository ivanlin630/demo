const TERRAIN_WEIGHTS: Dictionary = { "plains": 50, "forest": 30, "mountain": 20 }
# world-gen variety §1：據點評分 scatter（棄 key-order 貪婪）。TEST VALUE，measurer 校準。
const W_RES: float = 1.0          # 資源價值權重（聚落貼資源）
const W_STRAT: float = 0.4        # 戰略因子權重（鄰格資源多樣=補給腹地）
const WILD_GAME_W: float = 0.05   # wild_game 併入資源價值係數
const SCATTER_NOISE: float = 0.35 # ★位置熵護欄：score×(1±noise) 每 seed 有機散布,非純 argmax

const RESOURCE_PROFILE: Dictionary = {
	"plains":   { "food": [100, 300], "material": [5,  20]  },   # 農業為主
	"forest":   { "food": [20,   80], "material": [80, 220] },   # 木材為主
	"mountain": { "food": [5,    20], "material": [30, 100] },   # 礦產為主
}

const PRODUCTIVITY_RANGE: Dictionary = {
	"plains":   [0.9, 1.3],
	"forest":   [0.7, 1.1],
	"mountain": [0.5, 0.9],
}

const ORE_GOLD_CHANCE:   float = 0.12
const ORE_SILVER_CHANCE: float = 0.25
const GEM_CHANCE:        float = 0.05
const ORE_IRON_MOUNTAIN_CHANCE: float = 0.30
const ORE_IRON_PLAINS_CHANCE:   float = 0.05
const WILD_HORSE_PLAINS_CHANCE: float = 0.01
const WILD_HORSE_FOREST_CHANCE: float = 0.005
const HERB_FOREST_CHANCE: float = 0.30      # TEST VALUE
const HERB_RICH_CHANCE: float = 0.05        # 藥草林（先 roll rich 再 roll 一般）TEST VALUE
# ★老熟林（forest 高產材料點）：形狀比照上面兩層 herb roll。
#   ★量級錨【算出來的，不是挑的】：herb rich 中值 15 ÷ normal 中值 4 ＝ 3.75×
#     ⇒ forest material normal `[80,220]` 中值 150 × 3.75 ＝ 562.5 ⇒ 區間取 [450,675]（中值 562.5）。
#   ★★用同一個比例而不是同一個數字：兩者量綱不同（株數 vs 木材量），能搬的是【倍率】。
const OLD_GROWTH_CHANCE: float = 0.05     # TEST VALUE — 比照 HERB_RICH_CHANCE（同為「稀有高產點」）
const OLD_GROWTH_MATERIAL_MIN: int = 450    # TEST VALUE — 見上：normal 中值 ×3.75 的區間下界
const OLD_GROWTH_MATERIAL_MAX: int = 675    # TEST VALUE — 同上，上界
const WILD_HORSE_RICH_CHANCE: float = 0.03  # 野馬草原 TEST VALUE
const WILD_GAME_PLAINS_CHANCE: float = 0.20   # TEST VALUE — 平原帶獵物機率
const WILD_GAME_FOREST_CHANCE: float = 0.30   # TEST VALUE — 森林獵物更多
const WILD_GAME_MIN: int = 2
const WILD_GAME_MAX: int = 6
const PREDATOR_FOREST_CHANCE: float = 0.12   # TEST VALUE — 森林帶猛獸機率
const PREDATOR_MOUNTAIN_CHANCE: float = 0.15 # TEST VALUE — 山地猛獸更多
const PREDATOR_MAX: int = 2

# 產馬帶（strategic 不對稱地基：戰馬集中一「帶」而非均撒 → 中原缺馬 vs 邊地產馬）。
# resource_cap["mounts"] = 良質牧地標記（stable 直接繁育戰馬,見 OutpostSystem.produce_stable_day）。
# 另撒「一般」wild_horses(1-3,無 resource_cap)= 純 AI 建馬廄誘因訊號（faction_ai stable
# 需求偏好讀 `_nearby_resource(wild_horses)>0`）→ 驅 NPC 於帶內建 stable → breed path 有機會醒。
# 訊號量刻意 <4 = 非富點,不入 resource_cap → 不擾「野馬草原 ~3%」稀有度不變量。全 TEST VALUE。
const HORSE_BAND_HALF_WIDTH: int = 2         # 產馬帶半寬（tile_pos.x 欄）
const HORSE_BAND_DENSITY: float = 0.55       # 帶內 plains 成產馬地機率
const HORSE_BAND_CAP_MIN: int = 6            # resource_cap["mounts"] 下限
const HORSE_BAND_CAP_MAX: int = 12           # resource_cap["mounts"] 上限
const HORSE_BAND_SIGNAL_WILD_MIN: int = 1    # 帶內建廄誘因訊號 wild_horses 下限（<4 = 非富點）
const HORSE_BAND_SIGNAL_WILD_MAX: int = 3    # 上限

func generate(state: WorldState, config: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	if config.get("seed", -1) == -1:
		rng.randomize()
	else:
		rng.seed = int(config.get("seed", 0))
	var radius: int = config.get("radius", 4)
	var mult: float = float(config.get("resource_multiplier", 1.0))
	for qx in range(-radius, radius + 1):
		for ry in range(-radius, radius + 1):
			if _hex_dist(Vector2i(qx, ry), Vector2i.ZERO) > radius:
				continue
			var ox: int = qx + radius
			var oy: int = ry + radius
			var tile = load("res://scripts/data/tile_data.gd").new()
			tile.tile_id  = ox * 1000 + oy
			tile.tile_pos = Vector2i(ox, oy)
			tile.terrain  = _random_terrain(rng)
			_apply_resources(tile, rng, mult)
			state.world.tiles[tile.tile_id] = tile
	# S1 礦脈保證：全圖無金礦 tile 時，挑一座山地注入（消小圖 RNG 槓龜，保 mint 魂有燃料）
	_ensure_min_ore(state.world.tiles, rng, "ore_gold", 5, 30, mult)
	# 猛獸保證：全圖零猛獸時挑一座森林/山地注入（消小圖 RNG 槓龜，形狀比照上面的礦脈保證）
	_ensure_min_predator(state.world.tiles, rng)
	# 產馬帶：集中一「帶」撒戰略牧地（在 per-tile rng 流之後 draw → 不擾既有 seeded 期望）
	_apply_horse_band(state.world.tiles, rng, radius, mult)

func _apply_resources(tile, rng: RandomNumberGenerator, mult: float = 1.0) -> void:
	tile.resources = {}
	var profile: Dictionary = RESOURCE_PROFILE[tile.terrain]
	for res in profile:
		var r: Array = profile[res]
		tile.resources[res] = int(rng.randi_range(r[0], r[1]) * mult)
	var prod_r: Array = PRODUCTIVITY_RANGE[tile.terrain]
	tile.productivity = rng.randf_range(prod_r[0], prod_r[1])
	if tile.terrain == "mountain":
		if rng.randf() < ORE_GOLD_CHANCE:
			tile.resources["ore_gold"] = int(rng.randi_range(5, 30) * mult)
		elif rng.randf() < ORE_SILVER_CHANCE:
			tile.resources["ore_silver"] = int(rng.randi_range(10, 60) * mult)
		if rng.randf() < GEM_CHANCE:
			tile.resources["gem"] = int(rng.randi_range(1, 8) * mult)
		if rng.randf() < ORE_IRON_MOUNTAIN_CHANCE:
			tile.resources["ore_iron"] = int(rng.randi_range(50, 150) * mult)
	elif tile.terrain == "plains":
		if rng.randf() < ORE_IRON_PLAINS_CHANCE:
			tile.resources["ore_iron"] = int(rng.randi_range(20, 60) * mult)
	# herb：森林 30% 帶 2-6；藥草林（高產點）5% 帶 10-20。計入 resource_cap（月再生上限 = 初始值）
	if tile.terrain == "forest":
		if rng.randf() < HERB_RICH_CHANCE:
			tile.resources["herb"] = rng.randi_range(10, 20)
		elif rng.randf() < HERB_FOREST_CHANCE:
			tile.resources["herb"] = rng.randi_range(2, 6)
	# 老熟林（高產點）：森林 5% 材料覆寫為 450-675。同上計入 resource_cap（月再生上限 = 初始值）
	# ★★★`OLD_GROWTH_CHANCE > 0.0 and` 這個短路是【必須的】，不是防呆：
	#   `rng.randf() < 0.0` 仍然【消耗一次 RNG】（只是恆假）⇒ seeded 序列整條往後平移
	#   ⇒ 下游每一格的生成都會變 ⇒ ★「比例設 0」就不再等於「沒有這張票」，
	#     而驗收③（對照組 fp 逐位元相同）正是靠那個等式。
	if tile.terrain == "forest" and OLD_GROWTH_CHANCE > 0.0 and rng.randf() < OLD_GROWTH_CHANCE:
		tile.resources["material"] = int(rng.randi_range(OLD_GROWTH_MATERIAL_MIN, OLD_GROWTH_MATERIAL_MAX) * mult)
	tile.resource_cap = tile.resources.duplicate()
	# 野馬：平原 1% 1-2 隻 / 森林 0.5% 1 隻（活物不被 generic collect 採集，再生由 HarvestSystem 處理）
	# 野馬草原（高產點）：平原 3% 帶 4-8，resource_cap["wild_horses"]=8 標記富點（僅供再生 cap 判定）
	match tile.terrain:
		"plains":
			if rng.randf() < WILD_HORSE_RICH_CHANCE:
				tile.resources["wild_horses"] = rng.randi_range(4, 8)
				tile.resource_cap["wild_horses"] = 8
			elif rng.randf() < WILD_HORSE_PLAINS_CHANCE:
				tile.resources["wild_horses"] = rng.randi_range(1, 2)
		"forest":
			if rng.randf() < WILD_HORSE_FOREST_CHANCE:
				tile.resources["wild_horses"] = 1
	# 野味（鹿/兔/豬）：平原/森林帶可獵小獵物，計入 resource_cap（月再生上限）
	match tile.terrain:
		"plains":
			if rng.randf() < WILD_GAME_PLAINS_CHANCE:
				tile.resources["wild_game"] = rng.randi_range(WILD_GAME_MIN, WILD_GAME_MAX)
		"forest":
			if rng.randf() < WILD_GAME_FOREST_CHANCE:
				tile.resources["wild_game"] = rng.randi_range(WILD_GAME_MIN, WILD_GAME_MAX)
	if int(tile.resources.get("wild_game", 0)) > 0:
		tile.resource_cap["wild_game"] = int(tile.resources["wild_game"])
	# 猛獸（熊/野豬/狼群）：森林/山地帶 predator_density，計入 resource_cap（月再生上限）
	match tile.terrain:
		"forest":
			if rng.randf() < PREDATOR_FOREST_CHANCE:
				tile.resources["predator_density"] = rng.randi_range(1, PREDATOR_MAX)
		"mountain":
			if rng.randf() < PREDATOR_MOUNTAIN_CHANCE:
				tile.resources["predator_density"] = rng.randi_range(1, PREDATOR_MAX)
	if int(tile.resources.get("predator_density", 0)) > 0:
		tile.resource_cap["predator_density"] = int(tile.resources["predator_density"])

# S1 礦脈保證：全圖無 res tile 時挑一座山地注入（消小圖 RNG 槓龜）# TEST VALUE
func _ensure_min_ore(tiles_ref: Dictionary, rng: RandomNumberGenerator, res: String, lo: int, hi: int, mult: float) -> void:
	var mountains: Array = []
	for tid in tiles_ref:
		var t = tiles_ref[tid]
		if t.terrain == "mountain": mountains.append(t)
		if float(t.resources.get(res, 0)) > 0.0: return   # 已有，不動
	if mountains.is_empty(): return   # 無山地（極端小圖）→ 跳過
	var pick = mountains[rng.randi() % mountains.size()]
	var amt: float = float(rng.randi_range(lo, hi)) * mult
	pick.resources[res] = amt
	pick.resource_cap[res] = amt

# ★猛獸保證（systems 裁定 2026-08-26）——與上面 `_ensure_min_ore` 是【同一個形狀】：
#   ★病：`predator_density` 是機率灑點，母體小的圖會槓龜。實測掃 40 個 seed，
#     整圖零猛獸的有 1 個（2.5%），而 `headless_test.gd:2232` 寫死的 seed 11 正好是那一個
#     ⇒ 那個 assert 斷的是一件 97.5% 的機率事件（`docs/measurements/2026-08-26-predator-seed-fragility.txt`）。
#   ★★礦脈早就有這個保證、猛獸沒有 ⇒ **同型只做了一半**，補齊而已，不是新機制。
#   ★★★注意 rng：已有猛獸就【提前 return，一次 draw 都不耗】
#     ⇒ 正常世界的 seeded 序列【完全不動】，只有槓龜的圖才會走到 draw。
func _ensure_min_predator(tiles_ref: Dictionary, rng: RandomNumberGenerator) -> void:
	var hosts: Array = []
	for tid in tiles_ref:
		var t = tiles_ref[tid]
		if t.terrain == "forest" or t.terrain == "mountain": hosts.append(t)
		if int(t.resources.get("predator_density", 0)) > 0: return   # 已有，不動（且不耗 rng）
	if hosts.is_empty(): return   # 無森林也無山地（極端小圖）→ 跳過
	var pick = hosts[rng.randi() % hosts.size()]
	var amt: int = rng.randi_range(1, PREDATOR_MAX)
	pick.resources["predator_density"] = amt
	pick.resource_cap["predator_density"] = amt

# 產馬帶：挑一條 tile_pos.x 帶（seeded），帶內 plains 依密度撒 resource_cap["mounts"] + wild_horses。
# 集中成帶 = 戰略不對稱地基（非均撒）。至少保底一格（極端 RNG 全 miss 時補一格，保 slice 有源）。
func _apply_horse_band(tiles_ref: Dictionary, rng: RandomNumberGenerator, radius: int, mult: float) -> void:
	# tile_pos.x ∈ [0, 2*radius]；帶心避開邊緣（留半寬）
	var span: int = 2 * radius
	var lo: int = mini(HORSE_BAND_HALF_WIDTH, span)
	var hi: int = maxi(span - HORSE_BAND_HALF_WIDTH, lo)
	var center: int = rng.randi_range(lo, hi)
	var seeded: Array = []
	var plains_in_band: Array = []
	for tid in tiles_ref:
		var t = tiles_ref[tid]
		if t.terrain != "plains": continue
		if absi(int(t.tile_pos.x) - center) > HORSE_BAND_HALF_WIDTH: continue
		plains_in_band.append(t)
		if rng.randf() >= HORSE_BAND_DENSITY: continue
		_seed_horse_tile(t, rng, mult)
		seeded.append(t)
	# 保底：帶內有 plains 但 RNG 全 miss → 撒一格（產馬帶必有源）
	if seeded.is_empty() and not plains_in_band.is_empty():
		_seed_horse_tile(plains_in_band[rng.randi() % plains_in_band.size()], rng, mult)

func _seed_horse_tile(t, rng: RandomNumberGenerator, mult: float) -> void:
	t.resource_cap["mounts"] = int(rng.randi_range(HORSE_BAND_CAP_MIN, HORSE_BAND_CAP_MAX) * mult)
	# 建廄誘因訊號：僅在 tile 無既有 wild_horses 時撒「一般」量（保留既有富點,不入 resource_cap）
	if int(t.resources.get("wild_horses", 0)) == 0:
		t.resources["wild_horses"] = rng.randi_range(HORSE_BAND_SIGNAL_WILD_MIN, HORSE_BAND_SIGNAL_WILD_MAX)

func _random_terrain(rng: RandomNumberGenerator) -> String:
	var roll: int = rng.randi_range(0, 99)
	var acc: int = 0
	for t in TERRAIN_WEIGHTS:
		acc += TERRAIN_WEIGHTS[t]
		if roll < acc:
			return t
	return "plains"

# world-gen variety §1：評分 + seeded 熵散布（棄 key-order 貪婪；rng 全 seeded=per-seed determinism）。
# 高分區(貼資源+腹地)優先，score×rng 噪聲=每 seed 有機不同、非格狀 re-regularize。min_sep 硬保。
func pick_start_positions(state: WorldState, n: int, min_sep: int, rng: RandomNumberGenerator) -> Array:
	_build_terrain_norms(state)   # ★顯式重建：同一個 instance 換了世界不吃舊快取
	var scored: Array = []
	for tid in state.world.tiles:
		var tile = state.world.tiles[tid]
		var pos := Vector2i(tid / 1000, tid % 1000)
		var s: float = _tile_start_score(state, tile, pos) * (1.0 + rng.randf_range(-SCATTER_NOISE, SCATTER_NOISE))
		scored.append({ "pos": pos, "score": s })
	scored.sort_custom(func(a, b): return a["score"] > b["score"])   # 高分優先（噪聲已擾）
	var chosen: Array = []
	for e in scored:
		var ok := true
		for c in chosen:
			if _hex_dist(e["pos"], c) < min_sep:
				ok = false
				break
		if ok:
			chosen.append(e["pos"])
		if chosen.size() >= n:
			break
	return chosen

# 據點起點評分：資源價值(terrain 產能+wild_game) × W_RES + 戰略(鄰格資源和=補給腹地) × W_STRAT。
# §3 fallback 用：純評分（無 rng 噪聲）全 tile 位置降序。deterministic（同 seed 同序）。
func scored_positions_pure(state: WorldState) -> Array:
	_build_terrain_norms(state)   # ★同上：對照組入口也要看得見富點，否則兩個入口的世界觀不同
	var scored: Array = []
	for tid in state.world.tiles:
		var tile = state.world.tiles[tid]
		var pos := Vector2i(tid / 1000, tid % 1000)
		scored.append({ "pos": pos, "score": _tile_start_score(state, tile, pos) })
	scored.sort_custom(func(a, b): return a["score"] > b["score"])
	var out: Array = []
	for e in scored:
		out.append(e["pos"])
	return out

func _tile_start_score(state: WorldState, tile, pos: Vector2i) -> float:
	# ★backstop：常態基準沒建起來時 `rich` 恆 0 ⇒ 富點又變回隱形，而且【安靜】。
	#   兩個入口都會顯式重建（避免同一個 instance 換了世界還吃舊快取），這裡只兜住漏網的呼叫點。
	if _terrain_norm.is_empty():
		_build_terrain_norms(state)
	var res_val: float = _tile_res_value(tile)
	var strat: float = 0.0
	for d in ResourceSystem.HEX_DIRS:
		var ntid: int = (pos.x + d.x) * 1000 + (pos.y + d.y)
		var nt = state.world.tiles.get(ntid)
		if nt != null:
			strat += _tile_res_value(nt)
	return res_val * W_RES + strat * W_STRAT

func _tile_res_value(tile) -> float:
	var rates: Dictionary = ResourceSystem.REGEN_RATE.get(tile.terrain, { "food": 2.0, "material": 1.0 })
	var base: float = float(rates.get("food", 0.0)) + float(rates.get("material", 0.0)) \
		+ float(tile.resources.get("wild_game", 0)) * WILD_GAME_W
	# ★富點可見性：只加【超出這張圖同地形常態的那一份】——常態格 ≈ 不變（見 _build_terrain_norms）
	var norms: Dictionary = _terrain_norm.get(tile.terrain, {})
	var rich: float = 0.0
	for res in norms:
		rich += _stock_to_daily(float(tile.resources.get(res, 0)) - float(norms[res]))
	return base + rich

# ★★★富點可見性（systems 裁定 2026-08-26）——修的是一個【內部不一致】，不是新增偏好：
#   原本 `_tile_res_value` 只讀【地形再生常數】＋`wild_game` 這一種 tile 實際資源
#   ⇒ 一座 material 648 的老熟林，跟旁邊一座普通森林【分數完全一樣】
#   ⇒ 沒有人會為了它設點；而不站上去就採不到（`resource_system.gd:95-103`：L1 只採腳下、鄰格要 L3）
#   ⇒ ★實測：8 座老熟林跑 30 天 material 全部 Δ+0（`docs/measurements/2026-08-26-old-growth-reach.txt`）。
#
# ★常態基準【讀這張圖自己的中位數】，★不手抄 `RESOURCE_PROFILE` 的區間常數：
#   ①`resource_multiplier` 自動消掉 —— 手抄常數的話，mult≠1 的圖會【每一格都看起來很富】
#   ②中位數對「5% 富點」穩健（少數極端值拉不動中位數）
#   ③這是「讀自身狀態」而非手抄物理量（估算器血統②禁手抄）
#
# ★★為什麼算【超出常態的那一份】而不是整份存量：
#   整份存量下去 ⇒ 平原（food 存量中值 200）與森林（material 中值 150）會被重新排序
#   ⇒ ★那是【新增一個地形偏好】，正是這張票說不要做的事。
#   只算超額 ⇒ 普通格幾乎不動、富點才跳出來 ⇒ ★這才是「看見富點」。
var _terrain_norm: Dictionary = {}   # terrain -> { res -> 這張圖同地形的中位數 }

func _build_terrain_norms(state: WorldState) -> void:
	_terrain_norm.clear()
	var by_terrain: Dictionary = {}
	for tid in state.world.tiles:
		var t = state.world.tiles[tid]
		var bucket: Dictionary = by_terrain.get(t.terrain, {})
		for res in RESOURCE_PROFILE.get(t.terrain, {}):
			var arr: Array = bucket.get(res, [])
			arr.append(float(t.resources.get(res, 0)))
			bucket[res] = arr
		by_terrain[t.terrain] = bucket
	for terr in by_terrain:
		var norms: Dictionary = {}
		var per_res: Dictionary = by_terrain[terr]
		for res2 in per_res:
			var vals: Array = per_res[res2]
			vals.sort()
			norms[res2] = float(vals[vals.size() / 2]) if not vals.is_empty() else 0.0
		_terrain_norm[terr] = norms

# ★存量 → 日流的換算，用【專案既有的那把尺】(`DiscountedFlow`)，★不新增係數：
#   現成存量 S 的現值就是 S；一條日流 f 的現值是 `pv(f, δ, H)`
#   ⇒ 與 S 等值的日流 ＝ `S / pv(1, δ, H)`。
# ★δ 取【中性人格】(`delta_of({})` ⇒ 慎重 0.5) —— 產生器是替【不特定的人】挑地，沒有人格可讀。
# ★★H 沿用 `DiscountedFlow.HORIZON_DAYS`（＝ `MarginalEconomy.PLANNING_HORIZON_DAYS`）——同樣不新增常數。
static func _stock_to_daily(stock_excess: float) -> float:
	if stock_excess <= 0.0:
		return 0.0
	var d: float = DiscountedFlow.delta_of({})
	return stock_excess / maxf(DiscountedFlow.pv(1.0, d, DiscountedFlow.HORIZON_DAYS), 0.001)

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	var dx := b.x - a.x
	var dy := b.y - a.y
	return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
