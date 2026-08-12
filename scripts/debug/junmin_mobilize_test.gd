extends SceneTree

# 军民混编 Slice B TDD（spec §3）：mobilized_fraction guns-vs-butter + charter 梯度 + finding④ labor_share≤1。
# 核：①威脅→動員升(labor 降)②和平解甲③團型梯度(軍團/後備/居民 base 不同)④labor_share≤1(分子分母同步分數化)⑤cache 觸重算。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 建 team(charter tag)+leader(好戰)+可選 belief-threat 敵。回 [state, team]。
func _mk(tags: Array, martial: float, with_threat: bool, pos: Vector2i = Vector2i(5,5)) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var t := TeamData.new(); t.team_id = 1; t.faction_id = 10; t.tile_pos = pos; t.tags = tags
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 10)
	var lp := PersonData.new(); lp.id = 11; lp.values = {"好戰": martial, "慎重": 0.5}; state.persons[11] = lp; t.leader_id = 11
	state.teams[1] = t
	if with_threat:
		var e := TeamData.new(); e.team_id = 2; e.faction_id = 20; e.tile_pos = pos + Vector2i(1,0)
		AnonCohort.add(e.anon_cohorts, "平民", "healthy", 10); state.teams[2] = e
		state.team_discovered[1] = [2]
		BeliefSystem.record_claim(state, 1, 2, 1, "親見", {"tile_pos": pos + Vector2i(1,0)}, 1.0, false)
	return [state, t]

func _mob(tags: Array, martial: float, with_threat: bool) -> float:
	var a := _mk(tags, martial, with_threat)
	FactionAISystem.new()._update_mobilization(a[1], a[0])
	return a[1].mobilized_fraction

func _initialize() -> void:
	var PROD := [TeamData.TAG_PRODUCE]; var MIL := [TeamData.TAG_MILITARY]
	var fai := FactionAISystem.new()

	print("=== ①威脅→動員升 + ②和平解甲（guns-vs-butter）===")
	var peace: float = _mob(PROD, 0.5, false)
	var war: float = _mob(PROD, 0.5, true)
	print("  居民團 peace mobilized=%.3f  war mobilized=%.3f" % [peace, war])
	_ok(war > peace, "威脅→動員升 %.3f>%.3f（民兵召集）" % [war, peace])
	_ok(peace <= 0.15, "和平居民團動員低 %.3f（解甲務農、base 低）" % peace)

	print("=== ③團型梯度（charter base 不同）===")
	var mil: float = _mob(MIL, 0.5, false); var res: float = _mob([], 0.5, false); var prod: float = _mob(PROD, 0.5, false)
	print("  base: 軍團=%.3f 後備=%.3f 居民=%.3f" % [mil, res, prod])
	_ok(mil > res and res > prod, "團型梯度：專業軍團 %.3f > 後備 %.3f > 居民團 %.3f（base 分化）" % [mil, res, prod])
	_ok(_mob(PROD, 0.9, false) > _mob(PROD, 0.1, false), "好戰 modulate：高好戰動員 > 低好戰")

	print("=== ④labor_pop 分數化 + finding④ labor_share≤1 ===")
	# 兩 PRODUCE 隊共址、各動員 0.5 → labor_pop = pop×0.5、labor_share 各 = 0.5pop/pool、Σ=1。
	var s := WorldState.new(); s.world = WorldData.new(); s.world.current_tick = 1000
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(9,9); s.world.tiles[9009] = tile
	var a := TeamData.new(); a.team_id = 1; a.tile_pos = Vector2i(9,9); a.tags = PROD; AnonCohort.add(a.anon_cohorts, "平民", "healthy", 10); a.mobilized_fraction = 0.5; s.teams[1] = a
	var b := TeamData.new(); b.team_id = 2; b.tile_pos = Vector2i(9,9); b.tags = PROD; AnonCohort.add(b.anon_cohorts, "平民", "healthy", 10); b.mobilized_fraction = 0.5; s.teams[2] = b
	var pool: float = LaborSystem.pool_of(s, tile)
	var share_a: float = LaborSystem.labor_pop(a) / pool
	var share_b: float = LaborSystem.labor_pop(b) / pool
	print("  pool=%.1f(=2×10×0.5) share_a=%.3f share_b=%.3f Σ=%.3f" % [pool, share_a, share_b, share_a + share_b])
	_ok(abs(pool - 10.0) < 1e-6, "pool 分數化 = Σ pop×(1−mob) = 10（2隊×10×0.5）")
	_ok(share_a <= 1.0 and share_b <= 1.0 and share_a + share_b <= 1.0 + 1e-6, "★labor_share≤1 且 Σ≤1（finding④：分子分母同步分數化、無膨脹）")
	# 全動員 → labor_pop 0 → pool floor 1（產出趨零=guns-vs-butter 極限）。
	a.mobilized_fraction = 1.0; b.mobilized_fraction = 1.0
	_ok(LaborSystem.labor_pop(a) == 0.0, "全動員 labor_pop=0（全當兵不下田）")

	print("=== ⑤finding③ 動員態變→labor cache 觸重算 ===")
	var c := _mk(PROD, 0.5, true)
	var cstate: WorldState = c[0]; var cteam: TeamData = c[1]
	var ctile := HexTileData.new(); ctile.tile_pos = Vector2i(5,5); cstate.world.tiles[5005] = ctile
	ctile.labor_eval_next_tick = 999999   # 假裝 cache fresh
	cteam.mobilized_fraction = 0.0   # 強制與 threat-driven frac 差 > EPS
	fai._update_mobilization(cteam, cstate)
	_ok(ctile.labor_eval_next_tick == 0, "動員態變 > EPS → labor_eval_next_tick 歸 0（cache 觸重算、finding③）")

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
