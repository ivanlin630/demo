extends SceneTree
# @bed-kind: acceptance
# slice: _farm_pot 單一真相源（含 dispatch 靶那一處）
#
# 驗收：①同源（兩個消費端都讀 OutpostSystem.terrain_allows；★成對對照：加回字面 mountain 必紅）
#   ②森林格歸位（_farm_pot 1.0 → 0.4）
#   ③選址往平原偏移（★只印不斷言：某 seed 下可能沒有新選址）
#   ④不爆炸（★印出 settle_site_quality 有變化的據點數 —— 爆炸半徑要看得見）

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 3
const OLD_MULT: float = 0.4

func _initialize() -> void:
	print("=== FARM POT SINGLE SOURCE ===")
	_test_single_predicate()
	_test_forest_demoted()
	_test_blast_radius()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

# 偵測器：一段原始碼裡有沒有【自己寫的可農地形清單】（＝第四個真相源）
func _has_own_farm_terrain_list(src: String) -> bool:
	for line in src.split("\n"):
		var l: String = String(line)
		if l.strip_edges().begins_with("#"):
			continue   # ★註解自成一欄：說明文字不算真相源
		var mentions_farm: bool = l.contains("_farm_pot") or l.contains("farmable") or l.contains("farming")
		var literal_terrain: bool = l.contains('== "mountain"') or l.contains('== "forest"') \
			or l.contains('!= "plains"') or l.contains('== "plains"')
		if mentions_farm and literal_terrain:
			return true
	return false

func _read(path: String) -> String:
	var f := FileAccess.open(path, FileAccess.READ)
	if f == null:
		return ""
	var s: String = f.get_as_text()
	f.close()
	return s

func _test_single_predicate() -> void:
	print("-- ① 同源：兩個消費端都讀同一個 predicate --")
	var files := {
		"decision_context.gd": "res://scripts/simulation/decision/decision_context.gd",
		"faction_ai_system.gd": "res://scripts/simulation/faction_ai_system.gd",
	}
	for name in files:
		var src: String = _read(String(files[name]))
		var reads: bool = src.contains('OutpostSystem.terrain_allows("farming"')
		var own: bool = _has_own_farm_terrain_list(src)
		print("    %-22s 讀 predicate=%s｜自寫地形清單=%s" % [name, str(reads), str(own)])
		_ok(reads, "①%s 讀 OutpostSystem.terrain_allows" % name)
		_ok(not own, "①%s 沒有自寫的可農地形清單（第四個真相源）" % name)
	# ★成對對照：故意把字面判斷加回去 ⇒ 偵測器必須抓到（否則這格是恆真）
	var fake: String = "\tvar _farm_pot: float = 0.4 if _site.terrain == \"mountain\" else 1.0\n"
	_ok(_has_own_farm_terrain_list(fake), "①對照：把字面 mountain 加回去 ⇒ 偵測器抓得到")
	_ok(not _has_own_farm_terrain_list("\t# 舊版寫 terrain == \"mountain\"（註解）\n"),
		"①對照：註解裡的同一句【不算】（註解自成一欄，否則說明文字會讓它恆紅）")
	_sections += 1

func _mk_site(terrain: String) -> Array:
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 5000
	var tile := HexTileData.new()
	tile.tile_id = 3003
	tile.tile_pos = Vector2i(3, 3)
	tile.terrain = terrain
	tile.productivity = 1.0
	tile.resources = { "food": 40.0, "material": 40.0 }
	tile.resource_cap = { "food": 200.0, "material": 200.0 }
	st.world.tiles[3003] = tile
	var t := TeamData.new()
	t.team_id = 4
	t.tile_pos = Vector2i(3, 3)
	AnonTierSystem.add_anon(t, "平民", 8)
	st.teams[4] = t
	return [st, t, tile]

func _test_forest_demoted() -> void:
	print("-- ② 森林格歸位（predicate 直接問）--")
	print("    terrain_allows(farming, plains)=%s｜forest=%s｜mountain=%s" % [
		str(OutpostSystem.terrain_allows("farming", "plains")),
		str(OutpostSystem.terrain_allows("farming", "forest")),
		str(OutpostSystem.terrain_allows("farming", "mountain"))])
	_ok(OutpostSystem.terrain_allows("farming", "plains"), "②平原可農")
	_ok(not OutpostSystem.terrain_allows("farming", "forest"), "②★森林【不可農】—— 舊版把它算成滿分")
	_ok(not OutpostSystem.terrain_allows("farming", "mountain"), "②山地不可農（與舊版一致）")
	# ★沒有 required_terrain 的設施照舊：任何地形都行
	_ok(OutpostSystem.terrain_allows("workshop", "forest"), "②沒有 required_terrain 的設施不受影響（workshop/forest）")
	_sections += 1

func _test_blast_radius() -> void:
	print("-- ③④ 真世界：選址分數與爆炸半徑（★只印不斷言）--")
	seed(1337)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json", true)
	var runner := SimRunner.new()
	for _t in range(WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, Vector2i(-1, -1))
	var by_terr := { "plains": 0, "forest": 0, "mountain": 0 }
	var affected: int = 0
	for tid in state.world.tiles:
		var t: HexTileData = state.world.tiles[tid]
		if t.outpost_level > 0:
			by_terr[t.terrain] = int(by_terr.get(t.terrain, 0)) + 1
			# ★爆炸半徑＝「這次改動會讓它的選址分數變動」的據點：非平原者才受 FARM_UNFIT_MULT 影響
			if not OutpostSystem.terrain_allows("farming", t.terrain):
				affected += 1
	print("    據點分布：plains %d｜forest %d｜mountain %d" % [
		int(by_terr["plains"]), int(by_terr["forest"]), int(by_terr["mountain"])])
	print("    ★爆炸半徑：%d 座據點所在地形【現在算不可農】（分數 ×%.1f）——"
		% [affected, OLD_MULT])
	print("      ★★而既有據點【不會被沒收】：本票只動【評分與派遣靶】，建址規則是上一票的事")
	var forest_farm: int = 0
	for tid2 in state.world.tiles:
		var t2: HexTileData = state.world.tiles[tid2]
		if t2.farming_level > 0 and t2.terrain != "plains":
			forest_farm += 1
	print("    ★既有的非平原農田：%d 座（★它們照常產出——產出端沒有地形條件）" % forest_farm)
	_ok(true, "③④已印（只印不斷言：選址偏移需要跨 seed／跨窗比較，本床不宣稱）")
	_sections += 1
