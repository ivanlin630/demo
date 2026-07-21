extends SceneTree

# facility-scoring weaponsmith 納武器 demand TDD（spec 2026-07-21-facility-scoring-weaponsmith-demand）。
# 根:weaponsmith deficit 舊只看 armed_ratio(自衛)無視武器市場 demand→軍火路走不了。
# 修:兩路 max(self_defense 留 / market=_generic_res_deficit(武器,demand)×_commercial_inclination(人格穿秤))。
# ★DRY:_generic_res_deficit 共用 A 類分支+weaponsmith market(禁各算)。無 RNG。

var _fail: int = 0

func _initialize() -> void:
	_test_commercial_inclination()   # ① _commercial_inclination 人格穿秤(貪婪+商業技能)
	_test_market_drives_weaponsmith()# ② ★市場 demand 驅建(即使自衛足)——修根,load-bearing
	_test_self_defense_path()        # ③ 武裝不足+militaristic→self_defense 驅
	_test_all_low_zero()             # ④ 自衛足+武器足+低商業→deficit 0
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  [PASS] %s" % msg)
	else:
		_fail += 1
		print("  [FAIL] %s" % msg)

# 造 weaponsmith 隊：armed_ratio / 武器庫存 / leader(貪婪,好戰,商業skill) / archetype
func _mk(armed_ratio: float, weapons: float, greed: float, martial: float, commerce: float, force: bool) -> Array:
	var state := WorldState.new(); state.world = WorldData.new()
	var t := TeamData.new(); t.team_id = 1; t.tile_pos = Vector2i(0, 0)
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 10)   # pop 10 → weapon need_keep=pop×TARGET(1.0/0.8)
	t.armed_anon_ratio = armed_ratio
	t.resources = {"weapon_melee_low": weapons, "weapon_ranged_low": weapons}
	t.ambition_archetype = AmbitionLadder.ARCHETYPE_FORCE if force else AmbitionLadder.ARCHETYPE_TRADE
	var l := PersonData.new(); l.id = 10
	l.values = {"貪婪": greed, "好戰": martial}
	l.skills = {"商業": commerce}
	state.persons[10] = l; t.leader_id = 10
	state.teams[1] = t
	var tile := HexTileData.new(); tile.tile_pos = Vector2i(0, 0)
	return [state, t, tile, l.values]

# ① _commercial_inclination：高貪婪+高商業→高;低→低（人格穿秤非 flat）
func _test_commercial_inclination() -> void:
	print("--- ① _commercial_inclination 人格穿秤 ---")
	var fai := FactionAISystem.new()
	var hi: Array = _mk(1.0, 0.0, 0.9, 0.5, 0.8, false)
	var lo: Array = _mk(1.0, 0.0, 0.1, 0.5, 0.0, false)
	var ci_hi: float = fai._commercial_inclination(hi[0], hi[1], hi[3])
	var ci_lo: float = fai._commercial_inclination(lo[0], lo[1], lo[3])
	_ok(ci_hi > ci_lo, "高貪婪+高商業 → inclination 高於低者（%.2f > %.2f）" % [ci_hi, ci_lo])
	_ok(ci_hi > 0.5 and ci_lo < 0.2, "高者>0.5 低者<0.2（人格分兩端）")

# ② ★市場 demand 驅建：自衛足(armed 1.0→self_defense 0)但 0 武器+高商業→deficit>0（market 路徑）
func _test_market_drives_weaponsmith() -> void:
	print("--- ② ★市場 demand 驅建(自衛足亦建)——修根 ---")
	var w: Array = _mk(1.0, 0.0, 0.9, 0.3, 0.8, false)   # armed 足→self_defense 0;0 武器+高商業→market 驅
	var d: float = FactionAISystem.new()._deficit_weaponsmith(w[0], w[1], w[2], w[3])
	_ok(d > 0.0, "自衛足(armed1.0)但武器市場 demand 高×高商業 → deficit>0（軍火商路，舊=0，got %.2f）" % d)

# ③ 武裝不足+militaristic → self_defense 驅（武器庫足→market 0，隔離 self_defense）
func _test_self_defense_path() -> void:
	print("--- ③ self_defense 路徑 ---")
	var w: Array = _mk(0.0, 100.0, 0.1, 0.9, 0.0, true)   # 未武裝+militant;武器庫足→market 0;低商業
	var d: float = FactionAISystem.new()._deficit_weaponsmith(w[0], w[1], w[2], w[3])
	_ok(d > 0.0, "未武裝(armed0)+militaristic → self_defense 驅建（got %.2f）" % d)

# ④ 自衛足+武器足+低商業 → deficit 0（兩路徑皆低）
func _test_all_low_zero() -> void:
	print("--- ④ 兩路徑皆低→deficit 0 ---")
	var w: Array = _mk(1.0, 100.0, 0.1, 0.1, 0.0, false)   # armed 足→self_defense 0;武器足→market 0;低商業
	var d: float = FactionAISystem.new()._deficit_weaponsmith(w[0], w[1], w[2], w[3])
	_ok(d < 0.05, "自衛足+武器足+低商業 → deficit≈0（got %.2f）" % d)
