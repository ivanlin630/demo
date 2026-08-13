extends SceneTree

# slice B4+B5 TDD（生存產出層）：B4 settle→labor cache 即刷(採糧非硬零)、B5 food need 隨飢餓升 bounded 兩象限。

var _fail: int = 0
func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _mk_team(food: float, anon: int) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var t := TeamData.new(); t.team_id = 1; t.faction_id = 0; t.tile_pos = Vector2i(5,5)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", anon)
	var lp := PersonData.new(); lp.id = 11; lp.values = {}; state.persons[11] = lp; t.leader_id = 11
	t.resources["food"] = food
	state.teams[1] = t
	return [state, t]

func _initialize() -> void:
	print("=== B4：settle/紮營落腳 → 同 tick labor cache 刷、採糧非硬零 ===")
	var a := _mk_team(0.0, 6)
	var state: WorldState = a[0]; var team: TeamData = a[1]
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(5,5); tile.terrain = "plains"
	tile.resources["food"] = 50.0; tile.resource_cap["food"] = 100.0
	tile.labor_eval_next_tick = 999999   # cache 假 fresh（若不刷則 gather:food 恆 0）
	state.world.tiles[5005] = tile
	var ok: bool = FactionAISystem.new().establish_crude_camp(state, team)
	_ok(ok, "establish_crude_camp 成功")
	_ok(LaborSystem.labor_mult(tile, "gather:food") > 0.0,
		"★同 tick labor_mult(gather:food)=%.3f>0（settle 即刷 cache、非等 3 天硬零）" % LaborSystem.labor_mult(tile, "gather:food"))

	print("=== B5：food need 隨飢餓升 bounded 兩象限（NeedOracle 單點）===")
	var lv := {}
	# 食飽：food_days≥5 → escalation=1 → need 不變。pop=6+leader=7、burn=7×0.8=5.6/day、food=5.6×6=33.6→food_days=6≥5。
	var fed := _mk_team(33.6, 6)
	var need_fed: float = NeedOracle.need_keep(fed[0], fed[1], "food", lv)
	# 瀕餓：food=0 → food_days=0 → need = base×(1+GAIN)。
	var starv := _mk_team(0.0, 6)
	var need_starv: float = NeedOracle.need_keep(starv[0], starv[1], "food", lv)
	# base 參考（食飽 escalation=1 → need_fed = base）。
	var pop: float = float((fed[1] as TeamData).population)
	var base_ref: float = ResourceSystem.FOOD_PER_PERSON_PER_DAY * pop * DecisionTerms.food_security_target(lv)
	print("  base=%.3f food(food_days≥5)=%.3f starv(food_days=0)=%.3f GAIN=%.1f" % [base_ref, need_fed, need_starv, NeedOracle.FAMINE_NEED_GAIN])
	_ok(abs(need_fed - base_ref) < 1e-3, "★食飽(food_days≥5)→ food need = base（escalation=1、不變、照舊採礦）")
	_ok(abs(need_starv - base_ref * (1.0 + NeedOracle.FAMINE_NEED_GAIN)) < 1e-2,
		"★瀕餓(food_days=0)→ food need = base×(1+GAIN)=%.3f（飢餓升需）" % (base_ref * (1.0 + NeedOracle.FAMINE_NEED_GAIN)))
	_ok(need_starv > need_fed, "飢餓 food need %.3f > 食飽 %.3f（→gather:food weight 升→rebalance 多分採糧）" % [need_starv, need_fed])
	# bounded 中間：food_days=2.5(半飽)→escalation=1+0.5×GAIN。
	var mid := _mk_team(14.0, 6)   # food_days=14/5.6≈2.5
	var need_mid: float = NeedOracle.need_keep(mid[0], mid[1], "food", lv)
	_ok(need_mid > need_fed and need_mid < need_starv, "半飽 need %.3f 介於（連續 escalation、bounded 非跳）" % need_mid)

	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()
