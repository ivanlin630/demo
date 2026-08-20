extends SceneTree
# 訂單簿 tap 驗收（確定性小床、秒級、不需長 run）：
# ①order.placed（含分型）②order.replaced（同隊同 kind 同 res 舊單未清就再掛＝重掛 churn 硬證據）
# ③order.filled（qty 歸零）④order.abandoned（逾時，附 sample 帶 order_id/壽命）
# ⑤order_id 全域遞增且不撞（存 state 非 static）⑥created_tick 有值。

var _fail := 0
func _ok(c: bool, m: String) -> void:
	if c: print("  PASS ", m)
	else: _fail += 1; print("  FAIL ", m)

func _initialize() -> void:
	_run(); quit()

func _mk() -> Array:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	s.world.current_tick = 1000
	var t := HexTileData.new(); t.tile_id = 0; t.tile_pos = Vector2i(0,0); t.terrain = "plains"
	s.world.tiles[0] = t
	var team := TeamData.new(); team.team_id = 1; team.tile_pos = Vector2i(0,0); team.faction_id = -1
	team.resources = {"food": 50.0, "coin": 100.0}
	s.teams[1] = team
	var ldr := PersonData.new(); ldr.id = 9; ldr.team_id = 1; s.persons[9] = ldr; team.leader_id = 9
	return [s, team]

func _run() -> void:
	print("=== orderbook tap test ===")
	Probe.enabled = true; Probe.reset()
	var w := _mk(); var s: WorldState = w[0]; var team: TeamData = w[1]
	var os_ := OrderSystem.new()
	# ① placed + id 遞增 + created_tick
	var id1: int = os_.post_order(s, team, "buy", "tools", 5)
	var id2: int = os_.post_order(s, team, "sell", "food", 3)
	_ok(int(Probe.counts.get("order.placed", 0)) == 2, "order.placed=2")
	_ok(int(Probe.counts.get("order.placed.buy_tools", 0)) == 1, "分型 tap（placed.buy_tools）")
	_ok(id2 == id1 + 1 and id1 >= 1, "order_id 全域遞增且不重號（%d→%d、存 state 非 static）" % [id1, id2])
	_ok(int(team.active_orders[0].get("created_tick", -1)) == 1000, "created_tick 有值（壽命起算）")
	# ② replaced：同隊同 kind 同 res 舊單未清就再掛
	os_.post_order(s, team, "buy", "tools", 2)
	_ok(int(Probe.counts.get("order.replaced", 0)) == 1, "★order.replaced=1（重掛 churn 硬證據）")
	_ok(int(Probe.counts.get("order.replaced.buy_tools", 0)) == 1, "分型 tap（replaced.buy_tools）")
	# ③ filled：settle 把 buy 單沖滿（資源增量 → 買單成交）
	var before: Dictionary = {"tools": float(team.resources.get("tools", 0))}
	team.resources["tools"] = 10.0        # 到貨 10（兩張 buy 單共 7）
	var _p: bool = os_.settle_orders(team, before, s.world.current_tick)
	_ok(int(Probe.counts.get("order.filled", 0)) >= 1, "★order.filled=%d（qty 歸零完成）" % int(Probe.counts.get("order.filled", 0)))
	# ④ abandoned：時間推過 expire → tick_team_orders 清並記 sample
	Probe.reset()
	var w2 := _mk(); var s2: WorldState = w2[0]; var t2: TeamData = w2[1]
	var os2 := OrderSystem.new()
	os2.post_order(s2, t2, "buy", "material", 4)
	s2.world.current_tick += OrderSystem.ORDER_LIFETIME + 1
	os2.tick_team_orders(s2, t2)
	_ok(int(Probe.counts.get("order.abandoned", 0)) >= 1, "★order.abandoned=%d（逾時未成交）" % int(Probe.counts.get("order.abandoned", 0)))
	var samples: Array = Probe.samples.get("order.abandoned.sample", [])
	_ok(not samples.is_empty() and int((samples[0] as Dictionary).get("order_id", -1)) >= 1,
		"abandoned sample 帶 order_id/壽命（%s）" % (str(samples[0]) if not samples.is_empty() else "無"))
	Probe.enabled = false
	if _fail == 0: print("ALL PASS")
	else: print("FAILS=%d" % _fail)
