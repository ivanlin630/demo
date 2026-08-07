extends SceneTree

# 買糧 measure-first（藍圖 ruling 2026-06-26 §2「先量現在餓著的商隊路過市集到底買不買」）。
# 問題：求生取食 options 有 返家/覓食/搶/投靠/紮營/乞食，但「買糧」不是求生選項（搶 yes 買 no）。
# 量：餓商隊（有 coin、鄰市集售糧、無家無弱獵物）→ 引擎選什麼？是否有「取得食物@市集」路徑勝出。
# 純量測，不改邏輯。

func _initialize() -> void:
	_run(); quit()

func _new_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	return s

func _tile(s: WorldState, pos: Vector2i) -> HexTileData:
	var key: int = pos.x * 1000 + pos.y
	if not s.world.tiles.has(key):
		var t := HexTileData.new(); t.tile_pos = pos; t.terrain = "plains"
		s.world.tiles[key] = t
	return s.world.tiles[key]

func _fill(s: WorldState, r: int) -> void:
	for x in range(-r, r + 1):
		for y in range(-r, r + 1):
			_tile(s, Vector2i(x, y))

func _seed(team: TeamData, n: int) -> void:
	var named: int = team.named_members.size() + (1 if team.leader_id != -1 else 0)
	if n - named > 0:
		AnonCohort.add(team.anon_cohorts, "平民", "healthy", n - named)

func _run() -> void:
	print("=== buyfood measure: 餓商隊買不買糧 ===")
	var s := _new_state()
	_fill(s, 4)
	var fai := FactionAISystem.new()

	# 餓商隊：有 coin、無 home outpost、無弱獵物、pop>15（排覓食）→ 看絕境選什麼。
	var m := TeamData.new(); m.team_id = 0; m.tile_pos = Vector2i(0, 0)
	m.faction_id = -1
	m.tags = [TeamData.TAG_MERCHANT]
	var ldr := PersonData.new(); ldr.id = 1; ldr.team_id = 0
	ldr.values = {"貪婪": 0.7, "好戰": 0.2, "殘忍": 0.1, "野心": 0.4}
	ldr.loyalty = 0.5
	s.persons[1] = ldr; m.leader_id = 1
	_seed(m, 20)   # pop>FORAGE_VIABLE_POP(15) → 覓食不 applicable
	m.resources = {"food": 5.0, "coin": 500.0, "goods": 5.0}   # food_days≈5/(20*0.x)<3 絕境、有錢可買
	s.teams[0] = m

	# 鄰格市集 outpost（售糧）：放 food sell order 在 tile market board。
	var mkt_pos := Vector2i(1, 0)
	var mkt := _tile(s, mkt_pos)
	mkt.outpost_level = 2; mkt.outpost_owner = 99
	mkt.public_storage = {"food": 5000.0}
	# 市集 outpost 隊（賣糧者）
	var seller := TeamData.new(); seller.team_id = 99; seller.tile_pos = mkt_pos
	seller.faction_id = -1
	var s_ldr := PersonData.new(); s_ldr.id = 990; s_ldr.team_id = 99
	s.persons[990] = s_ldr; seller.leader_id = 990
	_seed(seller, 10); seller.resources = {"food": 5000.0, "coin": 100.0}
	s.teams[99] = seller
	s.team_discovered[0] = [99]

	# 量：餓商隊 context + applicable options + 各 util + 引擎決策
	var ctx := DecisionContext.gather(s, m)
	print("\n--- 餓商隊 context ---")
	print("  food_days=%.2f has_home=%s has_weak_prey=%s is_merchant=%s has_arb=%s has_goods=%s coin=%.0f" % [
		ctx.food_days, ctx.has_home_outpost, ctx.has_weak_prey, ctx.is_merchant,
		ctx.has_arb, ctx.has_goods, float(m.resources.get("coin", 0))])

	print("\n--- applicable options + util ---")
	var applic: Array = DecisionOptions.applicable(ctx)
	for opt in applic:
		var u: float = 0.0
		for tw in DecisionOptions.terms_of(opt):
			u += DecisionTerms.weight(tw[1], ctx.leader_values) * DecisionTerms.eval(tw[0], ctx, opt)
		print("  %-10s util=%.2f" % [opt, u])

	var ranked: Array = DecisionEngine.rank(s, m)
	print("\n--- 引擎排序 ---")
	print("  rank = %s" % str(ranked))
	print("  首選 = %s" % (ranked[0] if ranked.size() > 0 else "(空)"))

	# 跑實際 dispatch
	fai._decide_unified(s, m)
	print("\n--- 實際決策 ---")
	print("  task = %s（看是否取食@市集 vs 搶/覓/返家/idle）" % m.current_task)
	print("\n結論：survival options 清單 = %s" % str(DecisionOptions.options_in_set("survival")))
	print("  → 「買糧@市集」是否在內 / 是否勝出？")
	print("=== buyfood measure DONE ===")
