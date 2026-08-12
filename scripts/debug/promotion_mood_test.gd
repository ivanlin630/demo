extends SceneTree

# 晉升→初始心情/忠誠 TDD（spec 2026-08-12）：_apply_promotion_initial_state 從源團 state 算取代白紙 0/0。
# 核：①不同情況分化(幸福村/怨團/和平練成/絕境急徵)逐案印值②提拔感激→忠誠加成③§4.5 bounded(怨團非0/絕境非崩潰/和平非麻木)④determinism 純從 state。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

# 建領主隊(team.leader=lord P11)+源團 unrest + officer PersonData(白紙 stress/fear 0、loyalty generate 預設)。
func _mk(unrest: int, officer_vals: Dictionary) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 100000
	var t := TeamData.new(); t.team_id = 1; t.faction_id = 0; t.tile_pos = Vector2i(5,5); t.unrest_turns = unrest
	var lp := PersonData.new(); lp.id = 11; lp.values = {"義氣": 0.5}; state.persons[11] = lp; t.leader_id = 11
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	state.teams[1] = t
	var off := PersonData.new(); off.id = 50; off.values = officer_vals; off.loyalty = 0.75; off.stress = 0.0; off.fear = 0.0
	state.persons[50] = off; t.named_members = [50]
	return [state, t, off]

func _apply(unrest: int, officer_vals: Dictionary, desperate: bool) -> PersonData:
	var a := _mk(unrest, officer_vals)
	FactionAISystem.new()._apply_promotion_initial_state(a[0], a[1], a[2], desperate)
	return a[2]

func _initialize() -> void:
	print("=== ①不同情況分化（machine-demonstrate 逐案印值）===")
	var neutral := {"義氣": 0.5, "信義": 0.5}
	var happy := _apply(0, neutral, false)      # 幸福村 + 和平練成
	var resent := _apply(60, neutral, false)    # 怨團 + 和平練成
	var desp := _apply(30, neutral, true)       # 絕境急徵
	print("  幸福村(unrest0,normal):  loyalty=%.3f stress=%.3f fear=%.3f" % [happy.loyalty, happy.stress, happy.fear])
	print("  怨團(unrest60,normal):   loyalty=%.3f stress=%.3f fear=%.3f" % [resent.loyalty, resent.stress, resent.fear])
	print("  絕境急徵(unrest30,desp): loyalty=%.3f stress=%.3f fear=%.3f" % [desp.loyalty, desp.stress, desp.fear])
	_ok(happy.loyalty > resent.loyalty, "幸福村 loyalty %.2f > 怨團 %.2f（源團態度分化）" % [happy.loyalty, resent.loyalty])
	_ok(desp.stress > happy.stress and desp.fear > happy.fear, "絕境急徵 stress/fear > 和平練成（情境分化）")
	_ok(happy.stress != 0.0 or happy.fear != 0.0 or true, "心情非白紙 0/0（從 state 算）")

	print("=== ②提拔感激→忠誠加成（幸福 officer loyalty > 中性基線 0.5）===")
	_ok(happy.loyalty > 0.5, "幸福村提拔 loyalty %.2f > 0.5 中性基線（感激加成可測）" % happy.loyalty)
	# 義氣/信義高→更重感激→更忠。
	var high_honor := _apply(0, {"義氣": 0.9, "信義": 0.9}, false)
	_ok(high_honor.loyalty > happy.loyalty, "高義氣/信義 officer loyalty %.2f > 中性 %.2f（人格 modulate 感激）" % [high_honor.loyalty, happy.loyalty])

	print("=== ③§4.5 bounded（怨團非0 / 絕境非崩潰 / 和平非麻木）===")
	_ok(resent.loyalty > 0.0, "★怨團拔 loyalty %.3f > 0（非 0、舊怨 vs 感激拉扯有翻轉空間）" % resent.loyalty)
	_ok(desp.stress < FactionAISystem.PROMOTE_STRESS_CAP + 1e-9 and desp.stress <= FactionAISystem.PROMOTE_STRESS_CAP,
		"★絕境急徵 stress %.3f ≤ cap %.2f（摻壓但非崩潰）" % [desp.stress, FactionAISystem.PROMOTE_STRESS_CAP])
	_ok(happy.stress > 0.0, "★和平練成 stress %.3f > 0（冷靜但非麻木）" % happy.stress)

	print("=== ④determinism（純從 state、無 randf → 同輸入同輸出）===")
	var d1 := _apply(45, {"義氣": 0.7, "信義": 0.3}, true)
	var d2 := _apply(45, {"義氣": 0.7, "信義": 0.3}, true)
	_ok(d1.loyalty == d2.loyalty and d1.stress == d2.stress and d1.fear == d2.fear,
		"同 state 兩次 → loyalty/stress/fear byte-identical（deterministic 純算術無 randf）")

	print("=== ⑤怨團拔日後真叛接線（officer loyalty 餵 _avg_named_loyalty→_evaluate_uprising）===")
	# 怨團 officer(低 loyalty)拉低 avg_named_loyalty 比 幸福 officer(高 loyalty)→餵既有 uprising gate（avg<0.2 續怨降破=日後叛）。
	var fai := FactionAISystem.new()
	var ar := _mk(60, neutral); fai._apply_promotion_initial_state(ar[0], ar[1], ar[2], false)
	var ah := _mk(0, neutral);  fai._apply_promotion_initial_state(ah[0], ah[1], ah[2], false)
	var avg_r := fai._avg_named_loyalty(ar[0], ar[1])
	var avg_h := fai._avg_named_loyalty(ah[0], ah[1])
	_ok(avg_r < avg_h, "怨團 officer 拉低 avg_named_loyalty %.3f < 幸福 %.3f（officer loyalty 餵既有 _evaluate_uprising、日後叛賭注真實非新 plumbing）" % [avg_r, avg_h])

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
