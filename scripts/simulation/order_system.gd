class_name OrderSystem

# TIER: n/a — 語意時長非節律（某事多久算過期，不是多久評一次）
const ORDER_LIFETIME: int = 5 * WorldState.TICKS_PER_DAY    # 訂單壽命
# TIER: unmigrated(b) — S3 只搬七支，本顆待 S5+
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
	# ★訂單簿 tap：專用全域遞增 id（原本借 global_messages.size()＝訊息一被裁剪就會重複發號）。
	var oid: int = state.next_order_id
	state.next_order_id += 1
	var expire: int = state.world.current_tick + ORDER_LIFETIME
	# ★replaced tap：同隊同 kind 同 res 的舊單還沒清就再掛＝重掛 churn 的硬證據
	#（取代原本靠 qty_remaining 不減反增的推測）。
	for _o in team.active_orders:
		if String(_o.get("kind", "")) == kind and String(_o.get("res", "")) == res:
			Probe.bump("order.replaced")
			Probe.bump("order.replaced.%s_%s" % [kind, res])
			break
	team.active_orders.append({
		"order_id": oid, "kind": kind, "res": res,
		# ★★★B-v0 ⑧：escrow 支撐的賣單【必須排除在 settle_orders 的 delta 反推之外】。
		#   ★`settle_orders` 是【從副作用反推】：`pool[res] = 現在存量 − before`，
		#     而 escrow 是【掛單當下一次扣光】⇒ 下一次 settle 會看到 avail = −qty
		#     ⇒ ★★【整單被判成交，而一件都還沒賣掉】（對稱失敗：後續真實成交完全偵測不到）。
		#   ⇒ ★★★通則：【兩種記帳方式不能同時管同一張單】——
		#     一種【從副作用反推】、一種【事件權威】；混用 ⇒ 重複計數 或 全盲。
		#   ★而這個旗標在 `post_order` 這裡先寫 false，由 `_register_on_board` 押成功後改 true
		#     —— 因為【只有那裡知道 tile 存不存在】（漫遊隊沒有自家市集 ⇒ 押不了）。
		"escrowed": false,
		"qty_remaining": qty, "expire_tick": expire,
		"created_tick": state.world.current_tick,   # ★壽命起算（QA 讀故事可直接看「同一張單卡了幾天」）
	})
	# ★自報價（board-declared-price）：在【掛單這一刻】用既有公式算一次，之後凍結。
	#   賣＝ask_price（local_value × 人格化折扣）；買＝local_value（買方內部估值就是它的 bid）。
	#   ★零新公式、零新常數 —— 只是【算的時刻】從撮合當下提前到掛單當下。
	var _leader = state.persons.get(team.leader_id)
	var _commerce: float = float(_leader.skills.get("商業", 0.0)) if _leader else 0.0
	var declared_price: float = (
		TradeValuation.ask_price(team, res, _commerce, TradeValuation.leader_vals(state, team), state)
		if kind == "sell"
		else TradeValuation.local_value(team, res, state))
	Probe.add_amount("board.declared_price.sum", declared_price)
	Probe.bump("board.declared_price.n")
	if declared_price == 0.0:
		Probe.bump("board.declared_price.zero_quote")   # ★分辨用：真實報價落到 0（⑩ 拆 clamp 後會發生）
	var desc: String = "Team%d %s %s ×%d" % [team.team_id, ("徵" if kind == "buy" else "售"), res, qty]
	# WS-2：訂單會合 pos route 到下單隊最近自家 outpost 市集（固定點，非隨隊移動的舊 snapshot）。
	# active_orders 內部記帳不變；只改傳播副本的會合 pos。
	_msg.emit_message(state, "order_" + kind, desc, team, {
		"order_id": oid, "res": res, "qty": qty,
		"origin_team": team.team_id, "origin_pos": _market_pos(state, team),
		"expire_tick": expire, "price": declared_price,
	})
	# WS-2b：登錄市集看板（破可見性死鎖）。在 _market_pos 對應的市集 outpost tile 上掛一筆 board entry，
	# 與 active_orders 同資料。隊抵達該 tile 才親讀得到（firsthand honest）。
	# 無自家市集 tile（漫遊隊，_market_pos == team.tile_pos 且該 tile 非自家 outpost）→ 不登錄，回退既有碰面傳播。
	_register_on_board(state, team, oid, kind, res, qty, expire, declared_price)
	print("[Order] Team%d %s %s ×%d (oid=%d)" % [team.team_id, kind, res, qty, oid])
	Probe.bump("g1.order_placed")
	Probe.bump("order.placed")
	Probe.bump("order.placed.%s_%s" % [kind, res])
	Probe.bump("trade.post_" + kind)   # 漏斗站1：張貼 buy/sell 分流（純觀測）
	return oid

# WS-2b：把訂單登錄到發起隊最近自家市集 outpost tile 的看板（可見性鏡像）。
func _register_on_board(state: WorldState, team: TeamData, oid: int, kind: String, res: String, qty: int, expire: int, price: float) -> void:
	# ★合併註（2026-09-07）：main 側加了 `price` 參數（board-declared-price），
	#   而 B-v0 側加了 consign 分流。★★兩者不衝突：一個改【掛在哪塊板】、一個改【entry 帶什麼】。
	# ★★★★B-v0 ①掛單權 ＝【到場】（非 owner-only）：板是據點的公共設施。
	#   ★★★而我第一版【只做了 ②escrow 沒做 ①】，結果是【escrow 打在完全相反的母體上】：
	#     舊 `_register_on_board` 只在【自家市集】登錄 ⇒ 板上【全部都是 owner 自己的單】
	#     ⇒ 我對所有 sell 單押貨 ⇒ ★把【自家櫃檯】的貨從 `team.resources` 扣走，
	#       而櫃檯賣的是 `public_storage` ⇒ ★★owner 的櫃檯【直接停擺】（unified-commerce 5 紅）。
	#   ⇒ ★★★通則：【②沒有正確的母體，直到 ①存在】—— 兩件事不是獨立的，
	#     而「先做看起來獨立的那一半」會把機制打在錯的那群人身上。
	#
	# ★寄賣 ＝ 站在【別人的】市集上掛單 ⇒ 押貨（紅線：貨與錢都不得瞬移）
	# ★★自家櫃檯 ＝ 站在自家市集掛單 ⇒ 【不押】（賣的是 public_storage，錢進自己口袋，不涉紅線）
	var here_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
	var here: HexTileData = state.world.tiles.get(here_id)
	var consign: bool = here != null and here.outpost_level > 0 		and here.outpost_owner >= 0 and here.outpost_owner != team.team_id
	var tile: HexTileData = null
	if consign:
		tile = here
		if Probe.enabled: Probe.bump("mkt.post.consign")
	else:
		var mpos: Vector2i = _market_pos(state, team)
		tile = state.world.tiles.get(mpos.x * 1000 + mpos.y)
		# 僅在「自家市集 outpost」掛單；漫遊隊（無 outpost → _market_pos 回隊位、該 tile 非自家 outpost）不登錄。
		if tile == null or tile.outpost_level <= 0 or tile.outpost_owner != team.team_id:
			return
		if Probe.enabled: Probe.bump("mkt.post.own_counter")
	if tile == null:
		return
	# ★★★B-v0 ②押貨 escrow：掛【賣】單即【交貨入市場保管】——
	#   ★而它改變了權威關係：板上真的有貨 ⇒ 權威從 `active_orders` 移到 tile（見 tile_data 註解）。
	#   ★★買單押錢那半【本 slice 不做】（systems 的砍法優先序：買單押錢半邊後補）。
	var escrowed: bool = false
	if kind == "sell" and consign:   # ★只有【寄賣】才押貨；自家櫃檯不押（見上）
		var moved: float = ResourceBank.remove(team, res, float(qty), "escrow_post")
		if moved > 0.0:
			tile.market_escrow[oid] = {"res": res, "qty": moved,
				"owner_team": team.team_id, "since_tick": state.world.current_tick}
			escrowed = true
			if Probe.enabled:
				Probe.bump("mkt.escrow.post")
				Probe.add_amount("mkt.escrow.qty", moved)
			# ★★★而【押不到整單】要被看見：`remove()` 有 clampf 保底 ⇒ 存量不足時只押到有的部分
			#   ⇒ 若不記，「押了 5 件」與「想押 10 件只押到 5」印出來一樣。
			if moved < float(qty) and Probe.enabled:
				Probe.bump("mkt.escrow.partial")
				Probe.add_amount("mkt.escrow.short", float(qty) - moved)
		elif Probe.enabled:
			Probe.bump("mkt.escrow.nothing")   # ★存量 0 ⇒ 一件都押不到（★單仍掛，而板上沒貨）
	tile.market_orders.append({
		"order_id": oid, "kind": kind, "res": res, "escrowed": escrowed,
		"qty_remaining": qty, "origin_team": team.team_id, "expire_tick": expire,
		# ★資訊網 S-prop：origin_tick(age→decay) + strength + relayed 旗（本隊原生單 relayed=false、由 _sync_board 權威維護）。
		"origin_tick": state.world.current_tick, "strength": 1.0, "relayed": false,
		"price": price,   # ★掛單那一刻凍結；要改價＝撤單重掛（不就地改）
	})
	# ★★★把 escrow 結果【寫回賣家自己的存根】—— settle_orders 的排除規則讀的是這個旗標。
	#   ★而它必須在這裡寫：只有這裡知道 tile 存不存在（漫遊隊沒有自家市集 ⇒ 押不了 ⇒ 旗標維持 false
	#   ⇒ ★★那種單【仍然走舊的 delta 反推】，而那是對的：它沒有 escrow，delta 就是它唯一的證據）。
	if escrowed:
		for _ao in team.active_orders:
			if int(_ao.get("order_id", -1)) == oid:
				_ao["escrowed"] = true
				# ★★★連【哪塊 tile】一起記：到期退貨要找回那批貨，
				#   而【掃全圖 tile】既貴又會在 tile 被回收時静默漏掉。
				_ao["escrow_tile"] = tile.tile_pos.x * 1000 + tile.tile_pos.y
				break
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
		else:
			# ★abandoned tap：逾時未成交（帶 order_id + 壽命，事後可串）
			Probe.bump("order.abandoned")
			# ★★★B-v0 §2：到期退貨是【同一條紅線、換一個方向】――
			#   賣家不在場，貨【不得】直接回到他的 resources，否則就是【貨物瞬移】。
			#   ⇒ 落【待領貨帳】，與待領款共用同一個 pending_claims 結構。
			#   ★而這裡【不】把 escrow 直接刪掉：刪掉 = 貨消失，而守恆會在 audit 裡紅。
			if bool(o.get("escrowed", false)):
				var _etid: int = int(o.get("escrow_tile", -1))
				var _etile: HexTileData = state.world.tiles.get(_etid)
				if _etile == null:
					Probe.bump("mkt.escrow.expire_tile_gone")   # ★tile 消失（降級/回收）⇒ 貨沒有落地點，要看得見
				else:
					var _e: Dictionary = _etile.market_escrow.get(int(o["order_id"]), {})
					var _q: float = float(_e.get("qty", 0.0))
					if _q > 0.0:
						InteractionSystem.add_pending_claim(_etile, "goods", String(_e.get("res", "")), _q,
							int(_e.get("owner_team", -1)), state.world.current_tick)
						_etile.market_escrow.erase(int(o["order_id"]))
						if Probe.enabled:
							Probe.bump("mkt.escrow.expire_to_claim")
							Probe.add_amount("mkt.escrow.expire_qty", _q)
					else:
						Probe.bump("mkt.escrow.expire_empty")   # ★已全部賣掉（正常）
			# ★執行失敗反饋鐵律 T4 示範接線：買單到期沒人填 ＝ 執行失敗，不准靜默丟棄。
			# 記隊層失敗記憶 → 下輪「買糧/買料」（＝依賴市場供貨的決策）折價；TTL 用 ORDER_LIFETIME
			# ＝該動作的自然重試週期（相對錨定，不新增全域絕對天數常數）。
			# ★劣勢非失效：市場這次沒送到，不代表計畫不可行 → 只折價、不升 T0 喚醒（spec §T3）。
			if String(o.get("kind", "")) == "buy":
				FailureMemory.record(state, team, "買單", String(o.get("res", "")),
					ORDER_LIFETIME, "order_abandoned_buy")
			if Probe.enabled:
				Probe.bump_sample("order.abandoned.sample", {
					"order_id": int(o.get("order_id", -1)), "team": team.team_id,
					"kind": String(o.get("kind", "")), "res": String(o.get("res", "")),
					"qty_rem": int(o.get("qty_remaining", 0)),
					"age_ticks": state.world.current_tick - int(o.get("created_tick", 0)),
				}, 16)
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
			"price": float(m.params.get("price", -1.0)),   # ★自報價（-1.0 ＝這則消息沒帶到）
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
			"price": float(m.params.get("price", -1.0)),   # ★自報價（-1.0 ＝這則消息沒帶到）
		})
	return out

# WS-2b：抵達市集 outpost tile → 親讀看板（firsthand honest）。
# 把該 tile market_orders 中**非自己**的單，轉成 honest（is_distorted=false）order_buy/order_sell
# message 注入自己的 team_known（去重 by order_id；origin_pos = 市集 tile）。
# 親眼讀公開看板 = 同 vision 親見真值（守 G3：物理在場才得；轉述他隊仍走既有 propagate 失真，零改）。
# 隊不在 outpost tile（無在場）→ 讀不到（禁全域/無在場可見）。
# ★★MUTATES —— 名字說 read_、回傳 void，而它是【完整 mutator】：
#   ①:246 state.team_known[team.team_id] = []（缺 key 時建）
#   ②prune tile.market_orders 裡過期/decay 殆盡的 relayed entry（真的從看板上刪）
#   ③把讀到的 entry 寫進 state.team_known（本函式的主要作用）
#   ⇒ ★在觀測路徑上呼叫它 ＝ 觀測會改世界（本函式目前只被 tick step 呼叫，見掃描結果）。
func read_market_board(state: WorldState, team: TeamData) -> void:
	var tid: int = team.tile_pos.x * 1000 + team.tile_pos.y
	var tile: HexTileData = state.world.tiles.get(tid)
	if tile == null or tile.outpost_level <= 0:
		return   # 不在市集 outpost → 無在場可見
	Probe.bump("g1.market_arrive")   # WS-2b 觀測：隊抵達市集 outpost（讀看板的前提）
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
			# ★★★這一格是 spec §2 沒列到的第 4 站：價格從 entry 換載體到 message。
			#   漏掉它，下游 :316 的 relay deposit 就【沒有東西可抄】—— 而那格看起來有寫。
			# ★預設 -1.0 而非 0.0：0.0 是【真的零價】(charity／⑩ 深過剩)，
			#   而【欄位不存在】是另一件事。用 0.0 當預設 ⇒ 一張沒帶價的單會變成【免費】——
			#   ★★那是把「不知道」靜默地變成「白送」，而下游分不出來。
			"price": float(e.get("price", -1.0)),
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
			"price": float(m.params.get("price", -1.0)),   # ★同上：-1.0 ＝【沒帶到價】，0.0 ＝【價就是零】
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
		# ★§0：套利的正解＝【捕獲剩餘】，不是【自評值高】。
		#   舊式子 local_value × qty 是 proxy：它對【要花多少錢】完全盲。
		#   ★★而在 ⑥ 拆掉 clamp 之後，那個盲點會真的呍人：
		#     商隊自己就有貨→local_value→0 ⇒ gain→0 ⇒ 【一張單都不選】。
		#   ★★★而 ask 現在帶得到了（board-declared-price）⇒ 可以真算剩餘。
		var _ask: float = float(o.get("price", -1.0))
		var _mine: float = TradeValuation.local_value(merchant, o["res"], state)
		var gain: float
		if _ask >= 0.0:
			gain = (_mine - _ask) * float(o["qty"])
			if Probe.enabled: Probe.bump("trade.arb_surplus.sell")
		else:
			gain = _mine * float(o["qty"])   # 舊 proxy（這則消息沒帶價）
			if Probe.enabled: Probe.bump("trade.arb_proxy.sell")
		# ★★★⑩ 的 zero-gain tap（token `ten-zero-gain-reach`）――保留，而它的意義在新公式下【更強】：
		#   舊公式下 gain<=0 只能發生在【自評值 0】；
		#   ★新公式下它還含【他開的價高於我的估值】――那才是真正的【不值得買】。
		if Probe.enabled and gain <= 0.0:
			Probe.bump("trade.arb_kill_zero_gain")
			Probe.bump("trade.arb_kill_zero_gain." + String(o["res"]))
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
		var _bid: float = float(o.get("price", -1.0))
		var _mine2: float = TradeValuation.local_value(merchant, o["res"], state)
		var _q2: float = minf(stock, float(o["qty"]))
		var gain2: float
		if _bid >= 0.0:
			gain2 = (_bid - _mine2) * _q2   # ★卖掉手上的貨，賺的是【他出的價 − 我自己的估值】
			if Probe.enabled: Probe.bump("trade.arb_surplus.buy")
		else:
			gain2 = _mine2 * _q2
			if Probe.enabled: Probe.bump("trade.arb_proxy.buy")
		if gain2 > best_score:
			best_score = gain2; best = {"kind": "buy", "res": o["res"], "qty": o["qty"], "pos": o["pos"], "origin_team": o["origin_team"], "order_id": o["order_id"]}
	if not best.is_empty():
		Probe.bump("trade.arb_pick")   # 漏斗站3：選中非空
	return best

# 履約結算：按窗內 res 淨持有變化沖 active_orders（純記帳，不碰 resources）。
# before = 交易窗前各 res 持有快照。回 progressed（任一單 qty 有減）。
# ★★★★escrow 對帳（systems 追問：權威搬家之後【誰負責發現存根與實貨分歧】）——
#   ★`mkt.escrow.partial` 抓的是【發生的那一刻】，而分歧是【持續狀態】：
#     ★★一個沒有對帳不變量的權威搬家，分歧會【靜默累積】。
#   ⇒ 三種分歧【分開記】，因為處置不同：
#     `escrow_orphan` 實貨在市場、而賣家存根不見了 ⇒ 貨【永遠沒有人來領】
#     `stub_orphan`   存根說 escrowed、而市場沒有那批貨 ⇒ 賣家【以為自己還有貨在賣】
#     `qty_mismatch`  兩邊都在但數量不同 ⇒ ★★★誰對？—— 而權威在 tile（見 tile_data 註解）
#   ★回 {orphan_escrow, orphan_stub, qty_mismatch, checked}；★★`checked` 是母體：
#     它 0 的時候上面三個 0 【不是「沒有分歧」】，是【沒有東西可比】。
static func audit_escrow(state: WorldState) -> Dictionary:
	var r: Dictionary = {"orphan_escrow": 0, "orphan_stub": 0, "qty_mismatch": 0, "checked": 0}
	var stub: Dictionary = {}          # oid → qty_remaining（所有標了 escrowed 的存根）
	for tid in state.teams:
		for o in state.teams[tid].active_orders:
			if bool(o.get("escrowed", false)):
				stub[int(o.get("order_id", -1))] = int(o.get("qty_remaining", 0))
	var seen: Dictionary = {}
	for tile_id in state.world.tiles:   # gate-ok: 審計函式（audit_escrow）――純觀測、不在決策路徑上，且守恆對帳本來就要全量母體
		var tile: HexTileData = state.world.tiles[tile_id]
		for oid in tile.market_escrow:
			r["checked"] += 1
			seen[int(oid)] = true
			if not stub.has(int(oid)):
				r["orphan_escrow"] += 1
				continue
			if absf(float(tile.market_escrow[oid].get("qty", 0.0)) - float(stub[int(oid)])) > 0.01:
				r["qty_mismatch"] += 1
	for oid2 in stub:
		if not seen.has(int(oid2)):
			r["orphan_stub"] += 1
			r["checked"] += 1
	return r

func settle_orders(team: TeamData, before: Dictionary, _tick: int) -> bool:
	var progressed: bool = false
	# 各 res 的 delta 池（一池只沖該 res 同向單，FIFO）
	var pool: Dictionary = {}
	for o in team.active_orders:
		if bool(o.get("escrowed", false)):
			# ★★★事件權威單：它的 fill 只認【市場撮合事件】，不認資源 delta（見 post_order 註解）。
			if Probe.enabled:
				Probe.bump("order.settle_skip_escrowed")
			continue
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
			Probe.bump("order.filled")   # ★filled tap（qty 歸零完成）
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
