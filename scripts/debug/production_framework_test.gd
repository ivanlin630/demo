extends SceneTree

# 統一生產框架 v2 TDD（feat/production-framework）
# spec: docs/superpowers/specs/2026-07-16-unified-production-framework.md
# S1 製造 precondition 規則 + no-op tap。S2 survival-crush + granary seam。S3 means-end 獨立隊。S4 de-patch。

var _fail: int = 0

func _initialize() -> void:
	_test_s1_has_facility_gate()
	_test_s1_produce_applicable()
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

func _mk_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 0
	return s

# 據點 tile（可設 manufacturing_level 等製造設施）。
func _mk_tile(s: WorldState, pos: Vector2i, owner: int, workshop: int = 0) -> HexTileData:
	var t := HexTileData.new()
	t.tile_pos = pos; t.outpost_level = 1; t.outpost_owner = owner; t.outpost_type = "civilian"
	t.manufacturing_level = workshop
	s.world.tiles[pos.x * 1000 + pos.y] = t
	return t

func _mk_team(s: WorldState, tid: int, pos: Vector2i) -> TeamData:
	var t := TeamData.new(); t.team_id = tid; t.tile_pos = pos
	var ldr := PersonData.new(); ldr.id = tid * 10; s.persons[ldr.id] = ldr; t.leader_id = ldr.id
	t.named_members.append(tid * 10 + 1)
	s.teams[tid] = t
	return t

# ── S1：has_manufacturing_facility 規則（本格製造設施 + 生產權）──
func _test_s1_has_facility_gate() -> void:
	print("--- S1：has_manufacturing_facility 規則 ---")
	var s := _mk_state()
	var team := _mk_team(s, 1, Vector2i(0, 0))
	# 無設施 outpost → false
	_mk_tile(s, Vector2i(0, 0), 1, 0)
	_ok(not FactionAISystem.has_manufacturing_facility(s, team), "無製造設施→false（A2 補缺，不選製造空轉）")
	# 有 workshop → true
	s.world.tiles[0].manufacturing_level = 1
	_ok(FactionAISystem.has_manufacturing_facility(s, team), "有 workshop→true（可製造）")
	# 別團 outpost 非同 faction → false（無生產權）
	var s2 := _mk_state()
	var t2 := _mk_team(s2, 1, Vector2i(0, 0)); t2.faction_id = -1
	_mk_tile(s2, Vector2i(0, 0), 99, 1)   # owner=99 別團, 有 workshop
	_ok(not FactionAISystem.has_manufacturing_facility(s2, t2), "別團 outpost 無生產權→false")

# ── S1：「生產」applicable 補 precondition（無設施→濾 + kill probe）──
func _test_s1_produce_applicable() -> void:
	print("--- S1：生產 applicable precondition ---")
	Probe.enabled = true; Probe.reset()
	var s := _mk_state()
	var team := _mk_team(s, 1, Vector2i(0, 0))
	_mk_tile(s, Vector2i(0, 0), 1, 0)   # 有據點無設施
	var ctx := DecisionContext.gather(s, team)
	_ok(ctx.has_own_outpost, "has_own_outpost=true（有據點）")
	_ok(not ctx.has_manufacturing_facility, "has_manufacturing_facility=false（無設施）")
	var opts: Array = DecisionOptions.applicable(ctx)
	_ok(not ("生產" in opts), "★無設施→「生產」被濾（不空轉 no-op）")
	_ok("駐守" in opts, "「駐守」仍 applicable（只需據點）")
	_ok(int(Probe.counts.get("produce.appl_kill_nofacility", 0)) > 0, "★kill probe 動（A2 主病可觀測=%d）" % int(Probe.counts.get("produce.appl_kill_nofacility", 0)))
	# 有設施 → 生產 applicable
	s.world.tiles[0].manufacturing_level = 1
	var ctx2 := DecisionContext.gather(s, team)
	var opts2: Array = DecisionOptions.applicable(ctx2)
	_ok("生產" in opts2, "有設施→「生產」applicable")
	Probe.enabled = false
