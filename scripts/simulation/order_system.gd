class_name OrderSystem

const ORDER_LIFETIME: int = 5 * WorldState.TICKS_PER_DAY    # 訂單壽命
const ORDER_POST_CADENCE: int = 12 * WorldState.TICKS_PER_HOUR

const _ORDER_ELIGIBLE_RES: Array = ["goods", "weapon_melee_low", "weapon_ranged_low", "material", "ore_iron", "ore_steel", "food", "mounts", "tools"]

# unified-commerce M5：MERCHANT_MAX_RANGE 單一源（原 faction_ai:2039 重複宣告收此）。
const MERCHANT_MAX_RANGE: int = 20
# unified-commerce M3：掛單門檻走 effective_holding + 人格化 reserve（TradeValuation.reserve）。
# 廢死常數 SURPLUS_RESERVE_MULT/SHORTAGE_QTY/FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS/FOOD_BUY_TARGET_DAYS/×0.5/20.0：
# 賣＝effective_holding−reserve>0 的餘量；買＝reserve−effective_holding>0 的缺口；food 走 food_security_target 統一。
const ORDER_POST_MIN: float = 1.0   # 掛單最小量（<此不值得掛）

# ★資訊網 S-prop（看板 relay hub、修 :79 dead-end）：訪客抵市集除讀外，也 deposit 自己 team_known 的 order
# copy 到看板→看板累積異地消息再輻射給後續訪客（載體=人流、延遲=訪問間隔、decay=board age）。守感知鐵律
# （物理抵 outpost_level>0 才 deposit/read）。★decay 錨既有公式（SimMessageSystem.TIME_DECAY_PER_TICK，非 invent）。
const BOARD_RELAY_CAP: int = 32          # per-board relayed entry 上限（perf/memory bound、非 fire-crank；FIFO 淘汰最舊）
const BOARD_RELAY_MIN_STRENGTH: float = 0.05   # relayed entry decay strength <此 → 清（鏡射 SimMessageSystem copy.strength<=0.05 skip）

# relayed board entry 的 age-decayed strength（錨 SimMessageSystem time_factor 公式：max(1−age×TIME_DECAY_PER_TICK,0.1)×deposit_strength）。
static func _board_entry_strength(state: WorldState, e: Dictionary) -> float:
	var age: int = state.world.current_tick - int(e.get("origin_tick", state.world.current_tick))
	var time_factor: float = maxf(1.0 - float(age) * SimMessageSystem.TIME_DECAY_PER_TICK, 0.1)
	return float(e.get("strength", 1.0)) * time_factor

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
	# WS-2b：登錄市集看板（破可見性死鎖）。在 _market_pos 對應的市集 outpost tile 上掛一筆 board entry，
	# 與 active_orders 同資料。隊抵達該 tile 才親讀得到（firsthand honest）。
	# 無自家市集 tile（漫遊隊，_market_pos == team.tile_pos 且該 tile 非自家 outpost）→ 不登錄，回退既有碰面傳播。
	_register_on_board(state, team, oid, kind, res, qty, expire)
	print("[Order] Team%d %s %s ×%d (oid=%d)" % [team.team_id, kind, res, qty, oid])
	Probe.bump("g1.order_placed")
	Probe.bump("trade.post_" + kind)   # 漏斗站1：張貼 buy/sell 分流（純觀測）
	return oid

# WS-2b：把訂單登錄到發起隊最近自家市集 outpost tile 的看板（可見性鏡像）。
func _register_on_board(state: WorldState, team: TeamData, oid: int, kind: String, res: String, qty: int, expire: int) -> void:
	var mpos: Vector2i = _market_pos(state, team)
	var tid: int = mpos.x * 1000 + mpos.y
	var tile: HexTileData = state.world.tiles.get(tid)
	# 僅在「自家市集 outpost」掛單；漫遊隊（無 outpost → _market_pos 回隊位、該 tile 非自家 outpost）不登錄。
	if tile == null or tile.outpost_level <= 0 or tile.outpost_owner != team.team_id:
		return
	tile.market_orders.append({
		"order_id": oid, "kind": kind, "res": res,
		"qty_remaining": qty, "origin_team": team.team_id, "expire_tick": expire,
		# ★資訊網 S-prop：origin_tick(age→decay) + strength + relayed 旗（本隊原生單 relayed=false、由 _sync_board 權威維護）。
		"origin_tick": state.world.current_tick, "strength": 1.0, "relayed": false,
	})
	Probe.bump("g1.board_register")

# WS-2b：把 team 在其市集 outpost tile 的看板 entry 與 active_orders（權威）對齊：
# 已過期/已滿足(qty_remaining≤0)/已不在 active_orders 的本隊 entry → 移除；存活的更新 qty_remaining。
# 他隊 entry 不動（由各自 tick_team_orders 維護）。
func _sync_board(state: WorldState, team: TeamData) -> void:
	var mpos: Vector2i = _market_pos(state, team)
	var tid: int = mpos.x * 1000 + mpos.y
	var tile: HexTileData = state.world.tiles.get(tid)
	if tile == null or tile.outpost_level <= 0 or tile.outpost_owner != team.team_id:
		return
	# 權威：oid → qty_remaining（仍存活的本隊單）
	var live: Dictionary = {}
	for o in team.active_orders:
		live[int(o["order_id"])] = int(o["qty_remaining"])
	var kept: Array = []
	for e in tile.market_orders:
		if int(e["origin_team"]) != team.team_id:
			kept.append(e)   # 他隊 entry：本隊不碰
			continue
		var eid: int = int(e["order_id"])
		if not live.has(eid):
			continue   # 過期/已從 active_orders 移除 → 看板清
		var rem: int = int(live[eid])
		if rem <= 0:
			continue   # 已滿足 → 看板清（不留幽靈）
		e["qty_remaining"] = rem
		kept.append(e)
	tile.market_orders = kept

# cadence：過期清理 + 餘量發賣盤（買單短缺驅動完整化 = G1c/G1d）。
func tick_team_orders(state: WorldState, team: TeamData) -> void:
	# 1. 過期清理
	var kept: Array = []
	for o in team.active_orders:
		if int(o["expire_tick"]) > state.world.current_tick:
			kept.append(o)
	team.active_orders = kept
	# WS-2b：同步市集看板（鏡像權威）——過期/已滿足/已消失單從看板清，避免商隊讀幽靈單撲空。
	_sync_board(state, team)
	# M3：掛單門檻走 effective_holding + 人格化 reserve（貪婪守/絕境鬆手，活命糧 floor）。
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	# 建造/施工隊不賣資源（背負建材上路，賣光→抵達建不了）
	var is_constructing: bool = team.current_task in [TeamData.TASK_CONSTRUCT, TeamData.TASK_BUILD, TeamData.TASK_UPGRADE, TeamData.TASK_EXPAND]
	# 2. 餘量發賣盤（effective_holding − 人格 reserve > 0 → 餘 → 賣）
	for res in _ORDER_ELIGIBLE_RES:
		if res == "food":
			_tick_food_granary_sell(state, team)   # food 走 food_security_target 統一
			continue
		if is_constructing:
			continue   # 施工隊保留建材，不賣
		if _has_active(team, "sell", res):
			continue
		var surplus: float = ResourceSystem.effective_holding(state, team, res) \
			- TradeValuation.reserve(team, res, lv, state)
		if surplus < ORDER_POST_MIN:
			continue
		post_order(state, team, "sell", res, int(surplus))
	# 3. 短缺發買單（人格 reserve − effective_holding > 0 → 缺 → 徵）
	for res in _ORDER_ELIGIBLE_RES:
		if res == "food":
			continue   # food 買單下方統一
		if _has_active(team, "buy", res):
			continue
		# 僅對 team「該有」的資源發買單（proxy：武力隊徵武器/料；避免亂徵）
		if res in ["weapon_melee_low", "weapon_ranged_low", "material", "ore_iron", "ore_steel", "tools"]:
			var shortfall: float = TradeValuation.reserve(team, res, lv, state) \
				- ResourceSystem.effective_holding(state, team, res)
			if shortfall < ORDER_POST_MIN:
				continue
			post_order(state, team, "buy", res, int(shortfall))
			Probe.bump("g1.shortage_buy")
	# food 買單：effective_food 低於人格安全存量目標(天) → 補到 target（統一 food_security_target，廢 FOOD_BUY_DAYS）
	if not _has_active(team, "buy", "food"):
		var burn: float = maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
		var fdays: float = ResourceSystem.effective_food(state, team) / burn
		var tgt_days: float = DecisionTerms.food_security_target(lv)
		if fdays < tgt_days:
			var need: int = int((tgt_days - fdays) * burn)
			if need > 0:
				post_order(state, team, "buy", "food", need)
				Probe.bump("g1.food_buy")

# M3：定居隊 food 賣盤——effective_food 超人格安全存量目標(food_security_target) → 賣餘量。
# 廢 FOOD_SELL_RESERVE_RATIO/cap×0.5：統一走人格 food reserve（不賣到自己餓，慎重領袖留更多）。
func _tick_food_granary_sell(state: WorldState, team: TeamData) -> void:
	if _has_active(team, "sell", "food"):
		return
	var tid: int = team.tile_pos.x * 1000 + team.tile_pos.y
	var tile: HexTileData = state.world.tiles.get(tid)
	if tile == null or tile.outpost_level == 0 or tile.outpost_owner != team.team_id:
		return   # 非定居隊（無自家糧倉）→ 不發 food 賣盤
	var lv: Dictionary = TradeValuation.leader_vals(state, team)
	var surplus: float = ResourceSystem.effective_food(state, team) \
		- TradeValuation.reserve(team, "food", lv, state)
	if surplus < ORDER_POST_MIN:
		return   # 未超人格安全存量 → 自用，不賣
	post_order(state, team, "sell", "food", int(surplus))

func _has_active(team: TeamData, kind: String, res: String) -> bool:
	for o in team.active_orders:
		if o["kind"] == kind and o["res"] == res:
			return true
	return false

# 讀自隊收到的買單（team_known 的 order_buy message；殘缺=可失真副本）。
# 不濾過期副本＝設計（G1d 撲空 emergent）：追舊單=有理由出門→到市集讀板撞活單。
# （漏斗 r3 實證：濾掉後 arb 崩 2.7%/0.4%、旅程消失、成交 15→6/5→0——別再加濾。）
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

# WS-2b：抵達市集 outpost tile → 親讀看板（firsthand honest）。
# 把該 tile market_orders 中**非自己**的單，轉成 honest（is_distorted=false）order_buy/order_sell
# message 注入自己的 team_known（去重 by order_id；origin_pos = 市集 tile）。
# 親眼讀公開看板 = 同 vision 親見真值（守 G3：物理在場才得；轉述他隊仍走既有 propagate 失真，零改）。
# 隊不在 outpost tile（無在場）→ 讀不到（禁全域/無在場可見）。
func read_market_board(state: WorldState, team: TeamData) -> void:
	var tid: int = team.tile_pos.x * 1000 + team.tile_pos.y
	var tile: HexTileData = state.world.tiles.get(tid)
	if tile == null or tile.outpost_level <= 0:
		return   # 不在市集 outpost → 無在場可見
	Probe.bump("g1.market_arrive")   # WS-2b 觀測：隊抵達市集 outpost（讀看板的前提）
	# ★L3 循環貿易：firsthand 讀板 → stamp last_read（staleness 歸零；未讀過的市集無條目=staleness MAX 探索未知）。
	if not state.team_market_last_read.has(team.team_id):
		state.team_market_last_read[team.team_id] = {}
	state.team_market_last_read[team.team_id][tid] = state.world.current_tick
	if not state.team_known.has(team.team_id):
		state.team_known[team.team_id] = []
	# ★S-prop step0：prune 過期/decay 殆盡的 relayed entry（本隊原生 entry 由 _sync_board 權威維護、此不碰）。
	var alive: Array = []
	for e in tile.market_orders:
		if bool(e.get("relayed", false)):
			if int(e.get("expire_tick", 0)) <= state.world.current_tick:
				Probe.bump("board.relay_prune"); continue
			if _board_entry_strength(state, e) < BOARD_RELAY_MIN_STRENGTH:
				Probe.bump("board.relay_prune"); continue
		alive.append(e)
	tile.market_orders = alive
	# 已知 order_id（去重）
	var known_ids: Dictionary = {}
	for m in state.team_known[team.team_id]:
		if m.type == "order_buy" or m.type == "order_sell":
			known_ids[int(m.params.get("order_id", -1))] = true
	# ★S-prop step1：讀看板（含他隊原生單 + 異地 relayed 消息）→ 進 team_known。relayed 帶 decayed strength（staleness）。
	for e in tile.market_orders:
		if int(e["origin_team"]) == team.team_id:
			continue   # 自己的單不讀
		var oid: int = int(e["order_id"])
		if known_ids.has(oid):
			continue   # 去重
		var is_relay: bool = bool(e.get("relayed", false))
		var msg := MessageData.new()
		msg.id = state.global_messages.size()
		msg.type = "order_" + String(e["kind"])
		msg.description = "[Board%s] Team%d %s %s ×%d" % ["-relay" if is_relay else "", int(e["origin_team"]), String(e["kind"]), String(e["res"]), int(e["qty_remaining"])]
		msg.source_pos = tile.tile_pos
		msg.origin_team_id = int(e["origin_team"])
		# relayed：保原 origin_tick（age 累積跨 relay hop→decay 真起作用）；原生單=firsthand now。
		msg.origin_tick = int(e.get("origin_tick", state.world.current_tick)) if is_relay else state.world.current_tick
		msg.strength = _board_entry_strength(state, e) if is_relay else 1.0
		msg.is_distorted = false   # 親讀公開看板 = honest（relay staleness 走 strength/age 非 distort）
		msg.params = {
			"order_id": oid, "res": e["res"], "qty": int(e["qty_remaining"]),
			"origin_team": int(e["origin_team"]), "origin_pos": e.get("origin_pos", tile.tile_pos),
			"expire_tick": int(e["expire_tick"]),
		}
		state.global_messages.append(msg)
		state.team_known[team.team_id].append(msg)
		known_ids[oid] = true
		Probe.bump("board.relay_read" if is_relay else "g1.board_read")
	# ★S-prop step2：deposit 訪客 team_known 的 order 消息 copy 到看板 → 累積異地消息再輻射（載體=人流）。
	_deposit_known_orders_to_board(state, team, tile)

# ★S-prop：訪客把自己 team_known 的 order_buy/order_sell 消息 deposit 為看板 relayed entry（異地消息中繼）。
# dedup by order_id（看板已有不重複）；cap BOARD_RELAY_CAP（FIFO 淘汰最舊 relayed）；帶 origin_tick(age)+strength(decay)。
# 守感知鐵律：只 deposit team 親知的單（team_known）、只在物理所在市集看板、relayed 帶 decay 會 stale。
func _deposit_known_orders_to_board(state: WorldState, team: TeamData, tile: HexTileData) -> void:
	var board_oids: Dictionary = {}
	for e in tile.market_orders:
		board_oids[int(e["order_id"])] = true
	for m in state.team_known.get(team.team_id, []):
		if m.type != "order_buy" and m.type != "order_sell":
			continue
		var oid: int = int(m.params.get("order_id", -1))
		if oid < 0 or board_oids.has(oid):
			continue   # 看板已有（他隊原生 or 已 relayed）→ 不重複
		if int(m.params.get("expire_tick", 0)) <= state.world.current_tick:
			continue   # 過期消息不中繼
		var cur_strength: float = float(m.strength)
		if cur_strength < BOARD_RELAY_MIN_STRENGTH:
			continue   # 訪客手上已 decay 殆盡的消息不值中繼
		tile.market_orders.append({
			"order_id": oid, "kind": String(m.type).trim_prefix("order_"),
			"res": String(m.params.get("res", "")), "qty_remaining": int(m.params.get("qty", 0)),
			"origin_team": int(m.params.get("origin_team", -1)), "expire_tick": int(m.params.get("expire_tick", 0)),
			"origin_tick": int(m.origin_tick), "strength": cur_strength, "relayed": true,
			"origin_pos": m.params.get("origin_pos", tile.tile_pos),
		})
		board_oids[oid] = true
		Probe.bump("board.relay_deposit")
	# cap：relayed entry 過多 → FIFO 淘汰最舊（原生單不淘）。
	var relayed_count: int = 0
	for e in tile.market_orders:
		if bool(e.get("relayed", false)): relayed_count += 1
	if relayed_count > BOARD_RELAY_CAP:
		var drop: int = relayed_count - BOARD_RELAY_CAP
		var kept: Array = []
		for e in tile.market_orders:
			if drop > 0 and bool(e.get("relayed", false)):
				drop -= 1; Probe.bump("board.relay_evict"); continue
			kept.append(e)
		tile.market_orders = kept

# 套利挑單：sell盤(便宜買)/buy單(高價賣) 取 local_value 差最大者（殘缺情報，讀 received）。
func best_arbitrage_order(state: WorldState, merchant: TeamData) -> Dictionary:
	Probe.bump("trade.arb_call")   # 漏斗站3：呼叫次數（含 DecisionContext has_arb 建構）
	var best: Dictionary = {}
	var best_score: float = 0.0   # 僅正套利
	for o in received_sell_orders(state, merchant):
		if o["origin_team"] == merchant.team_id: continue
		Probe.bump("trade.arb_sell_seen")
		if _hex_dist(merchant.tile_pos, o["pos"]) > MERCHANT_MAX_RANGE:
			Probe.bump("trade.arb_kill_range")
			continue
		# M5：廢 arb ×0.1 硬碼（相對排序不變，argmax 無關）。M4：估值讀 effective_holding。
		var gain: float = TradeValuation.local_value(merchant, o["res"], state) * float(o["qty"])   # proxy：自評值高→值得搬回
		if gain > best_score:
			best_score = gain; best = {"kind": "sell", "res": o["res"], "qty": o["qty"], "pos": o["pos"], "origin_team": o["origin_team"], "order_id": o["order_id"]}
	for o in received_buy_orders(state, merchant):
		if o["origin_team"] == merchant.team_id: continue
		Probe.bump("trade.arb_buy_seen")
		if _hex_dist(merchant.tile_pos, o["pos"]) > MERCHANT_MAX_RANGE:
			Probe.bump("trade.arb_kill_range")
			continue
		var stock: float = ResourceSystem.effective_holding(state, merchant, o["res"])
		if stock <= 0.0:
			Probe.bump("trade.arb_kill_nostock")   # 有買單無貨可賣
			continue
		var gain2: float = TradeValuation.local_value(merchant, o["res"], state) * minf(stock, float(o["qty"]))
		if gain2 > best_score:
			best_score = gain2; best = {"kind": "buy", "res": o["res"], "qty": o["qty"], "pos": o["pos"], "origin_team": o["origin_team"], "order_id": o["order_id"]}
	if not best.is_empty():
		Probe.bump("trade.arb_pick")   # 漏斗站3：選中非空
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
