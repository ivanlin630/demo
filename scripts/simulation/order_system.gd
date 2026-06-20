class_name OrderSystem

const ORDER_LIFETIME: int = 5 * WorldState.TICKS_PER_DAY    # 訂單壽命
const ORDER_POST_CADENCE: int = 12 * WorldState.TICKS_PER_HOUR
const SURPLUS_RESERVE_MULT: float = 2.0   # 超過 reserve×此 = 餘 → 發賣盤

const _ORDER_ELIGIBLE_RES: Array = ["goods", "weapon_melee_low", "weapon_ranged_low", "material", "ore_iron", "ore_steel", "food"]

const SHORTAGE_QTY: float = 3.0   # TEST VALUE：低於此視為短缺,發買單
const MERCHANT_MAX_RANGE: int = 20

# WS-1：糧倉「滿」信號門檻 = food cap × 此比例。糧倉 > 門檻 → 發 food sell 單
# （滿了→賣決策 fire；鐵則：cap 須改變 NPC 決策）。TEST VALUE。
const FOOD_SELL_RESERVE_RATIO: float = 0.5   # 賣到剩 cap×此（保留半倉自用）

var _msg := SimMessageSystem.new()

# 發訂單：權威存發起隊 active_orders + emit message 傳播副本。回 order_id。
func post_order(state: WorldState, team: TeamData, kind: String, res: String, qty: int) -> int:
	if qty <= 0:
		return -1
	var oid: int = state.global_messages.size()   # 借全域 message id 空間，唯一
	var expire: int = state.world.current_tick + ORDER_LIFETIME
	team.active_orders.append({
		"order_id": oid, "kind": kind, "res": res,
		"qty_remaining": qty, "expire_tick": expire,
	})
	var desc: String = "Team%d %s %s ×%d" % [team.team_id, ("徵" if kind == "buy" else "售"), res, qty]
	# WS-2：訂單會合 pos route 到下單隊最近自家 outpost 市集（固定點，非隨隊移動的舊 snapshot）。
	# active_orders 內部記帳不變；只改傳播副本的會合 pos。
	_msg.emit_message(state, "order_" + kind, desc, team, {
		"order_id": oid, "res": res, "qty": qty,
		"origin_team": team.team_id, "origin_pos": _market_pos(state, team),
		"expire_tick": expire,
	})
	print("[Order] Team%d %s %s ×%d (oid=%d)" % [team.team_id, kind, res, qty, oid])
	Probe.bump("g1.order_placed")
	return oid

# cadence：過期清理 + 餘量發賣盤（買單短缺驅動完整化 = G1c/G1d）。
func tick_team_orders(state: WorldState, team: TeamData) -> void:
	# 1. 過期清理
	var kept: Array = []
	for o in team.active_orders:
		if int(o["expire_tick"]) > state.world.current_tick:
			kept.append(o)
	team.active_orders = kept
	# 2. 餘量發賣盤（囤量遠超自用 → 餘 → 賣；TEST VALUE 門檻）
	for res in _ORDER_ELIGIBLE_RES:
		if res == "food":
			# WS-1：food 對定居隊在糧倉（非 team.resources）→ 糧倉「滿」信號發 sell。
			_tick_food_granary_sell(state, team)
			continue
		var qty: float = float(team.resources.get(res, 0))
		if qty < 20.0:
			continue
		if _has_active(team, "sell", res):
			continue
		post_order(state, team, "sell", res, int(qty * 0.5))
	# 3. 短缺發買單（缺料/缺武器 → 徵）
	for res in _ORDER_ELIGIBLE_RES:
		if float(team.resources.get(res, 0)) >= SHORTAGE_QTY:
			continue
		if _has_active(team, "buy", res):
			continue
		# 僅對 team「該有」的資源發買單（proxy：武力隊徵武器/料；避免亂徵）TEST VALUE
		if res in ["weapon_melee_low", "weapon_ranged_low", "material", "ore_iron", "ore_steel"]:
			post_order(state, team, "buy", res, int(SHORTAGE_QTY * 2))
			Probe.bump("g1.shortage_buy")

# WS-1：定居隊糧倉「滿」信號 → 發 food sell 單（cap 改變 NPC 決策；鐵則）。
# 讀自家 outpost public_storage food；> cap×reserve → 賣超量的一半（保留半倉自用）。
func _tick_food_granary_sell(state: WorldState, team: TeamData) -> void:
	if _has_active(team, "sell", "food"):
		return
	var tid: int = team.tile_pos.x * 1000 + team.tile_pos.y
	var tile: HexTileData = state.world.tiles.get(tid)
	if tile == null or tile.outpost_level == 0 or tile.outpost_owner != team.team_id:
		return   # 非定居隊（無自家糧倉）→ 不發 food 賣盤
	var granary: float = float(tile.public_storage.get("food", 0))
	var cap: float = OutpostSystem.new()._get_storage_cap(tile, "food")
	var reserve: float = cap * FOOD_SELL_RESERVE_RATIO
	if granary <= reserve:
		return   # 未滿門檻 → 自用，不賣
	var sell_qty: int = int((granary - reserve) * 0.5)
	if sell_qty <= 0:
		return
	post_order(state, team, "sell", "food", sell_qty)

func _has_active(team: TeamData, kind: String, res: String) -> bool:
	for o in team.active_orders:
		if o["kind"] == kind and o["res"] == res:
			return true
	return false

# 讀自隊收到的買單（team_known 的 order_buy message；殘缺=可失真副本）。
func received_buy_orders(state: WorldState, team: TeamData) -> Array:
	var out: Array = []
	for m in state.team_known.get(team.team_id, []):
		if m.type != "order_buy": continue
		out.append({
			"res": m.params.get("res", ""), "qty": m.params.get("qty", 0),
			"origin_team": m.params.get("origin_team", -1),
			"pos": m.params.get("origin_pos", Vector2i.ZERO),
			"order_id": m.params.get("order_id", -1), "distorted": m.is_distorted,
		})
	return out

# 讀自隊收到的賣盤（team_known 的 order_sell message；殘缺=可失真副本）。
func received_sell_orders(state: WorldState, team: TeamData) -> Array:
	var out: Array = []
	for m in state.team_known.get(team.team_id, []):
		if m.type != "order_sell": continue
		out.append({
			"res": m.params.get("res", ""), "qty": m.params.get("qty", 0),
			"origin_team": m.params.get("origin_team", -1),
			"pos": m.params.get("origin_pos", Vector2i.ZERO),
			"order_id": m.params.get("order_id", -1), "distorted": m.is_distorted,
		})
	return out

# 套利挑單：sell盤(便宜買)/buy單(高價賣) 取 local_value 差最大者（殘缺情報，讀 received）。
func best_arbitrage_order(state: WorldState, merchant: TeamData) -> Dictionary:
	var best: Dictionary = {}
	var best_score: float = 0.0   # 僅正套利
	for o in received_sell_orders(state, merchant):
		if o["origin_team"] == merchant.team_id: continue
		if _hex_dist(merchant.tile_pos, o["pos"]) > MERCHANT_MAX_RANGE: continue
		var gain: float = TradeValuation.local_value(merchant, o["res"]) * float(o["qty"]) * 0.1   # proxy：自評值高→值得搬回
		if gain > best_score:
			best_score = gain; best = {"kind": "sell", "res": o["res"], "qty": o["qty"], "pos": o["pos"], "origin_team": o["origin_team"], "order_id": o["order_id"]}
	for o in received_buy_orders(state, merchant):
		if o["origin_team"] == merchant.team_id: continue
		if _hex_dist(merchant.tile_pos, o["pos"]) > MERCHANT_MAX_RANGE: continue
		var stock: float = float(merchant.resources.get(o["res"], 0))
		if stock <= 0.0: continue   # 沒貨可賣給買單
		var gain2: float = TradeValuation.local_value(merchant, o["res"]) * minf(stock, float(o["qty"])) * 0.1
		if gain2 > best_score:
			best_score = gain2; best = {"kind": "buy", "res": o["res"], "qty": o["qty"], "pos": o["pos"], "origin_team": o["origin_team"], "order_id": o["order_id"]}
	return best

# 履約結算：按窗內 res 淨持有變化沖 active_orders（純記帳，不碰 resources）。
# before = 交易窗前各 res 持有快照。回 progressed（任一單 qty 有減）。
func settle_orders(team: TeamData, before: Dictionary, _tick: int) -> bool:
	var progressed: bool = false
	# 各 res 的 delta 池（一池只沖該 res 同向單，FIFO）
	var pool: Dictionary = {}
	for o in team.active_orders:
		var res: String = o["res"]
		if not pool.has(res):
			pool[res] = float(team.resources.get(res, 0)) - float(before.get(res, 0))
		var avail: float = pool[res]
		var want: int = int(o["qty_remaining"])
		var filled: int = 0
		if o["kind"] == "buy" and avail > 0.0:
			filled = clampi(int(round(avail)), 0, want)
			pool[res] = avail - float(filled)
		elif o["kind"] == "sell" and avail < 0.0:
			filled = clampi(int(round(-avail)), 0, want)
			pool[res] = avail + float(filled)
		if filled > 0:
			o["qty_remaining"] = want - filled
			progressed = true
	# 移除填滿單 + bump
	var kept: Array = []
	for o in team.active_orders:
		if int(o["qty_remaining"]) <= 0:
			Probe.bump("g1.order_fulfilled")
		else:
			kept.append(o)
	team.active_orders = kept
	return progressed

# WS-2：訂單會合市集 pos = 下單隊最近自家 outpost tile（固定會合點，商隊去得到、人在那）。
# god-view scan = 下單隊「自家」outpost，屬自知資訊（非偷看他隊）。無 outpost → fallback team.tile_pos。
func _market_pos(state: WorldState, team: TeamData) -> Vector2i:
	var best_pos: Vector2i = team.tile_pos
	var best_d: int = 1 << 30
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_owner != team.team_id or tile.outpost_level <= 0:
			continue
		var d: int = _hex_dist(team.tile_pos, tile.tile_pos)
		if d < best_d:
			best_d = d
			best_pos = tile.tile_pos
	return best_pos

func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	return int((abs(a.x - b.x) + abs(a.y - b.y) + abs(a.x + a.y - b.x - b.y)) / 2)
