extends SceneTree

# Observer inspect 擴充 query 層 headless 驗（read-only，純 static）。
# 驗 query_team.resources_nonzero / query_outpost（civilian+military+無主 null guard）/ 非據點格 {}。

var _pass: int = 0
var _fail: int = 0

func _check(cond: bool, msg: String) -> void:
	if cond:
		_pass += 1
	else:
		_fail += 1
		print("  [FAIL] ", msg)

func _tid_key(pos: Vector2i) -> int:
	return pos.x * 1000 + pos.y

func _make_tile(pos: Vector2i, otype: String, olevel: int, owner: int) -> HexTileData:
	var t := HexTileData.new()
	t.tile_pos = pos
	t.tile_id = _tid_key(pos)
	t.outpost_type = otype
	t.outpost_level = olevel
	t.outpost_owner = owner
	if otype == "military":
		t.weaponsmith_level = 2
		t.smelter_level = 1
		t.garrison = [101, 102]
	else:
		t.farming_level = 3
		t.mint_level = 1
		t.garrison = []
	t.resources = {"food": 40.0, "material": 15, "ore_iron": 3}
	t.resource_cap = {"food": 100.0, "material": 50}
	return t

func _initialize() -> void:
	print("=== observer_inspect_test ===")
	var state := WorldState.new()

	# ── team：多資源 ──
	var team := TeamData.new()
	team.team_id = 5
	team.leader_id = -1
	team.faction_id = 7
	team.resources = {
		"food": 120.0, "coin": 30, "material": 8, "goods": 4,
		"gem": 0, "ore_iron": 2, "weapon_melee_low": 5, "mounts": 0,
	}
	state.teams[5] = team

	# owner team for military outpost（隸屬 faction 7）
	var owner_team := TeamData.new()
	owner_team.team_id = 9
	owner_team.leader_id = -1
	owner_team.faction_id = 7
	state.teams[9] = owner_team

	# ── tiles ──
	var civ_pos := Vector2i(3, 4)
	var mil_pos := Vector2i(6, 2)
	var ownerless_pos := Vector2i(1, 1)
	var empty_pos := Vector2i(8, 8)
	state.world.tiles[_tid_key(civ_pos)] = _make_tile(civ_pos, "civilian", 2, 5)
	state.world.tiles[_tid_key(mil_pos)] = _make_tile(mil_pos, "military", 3, 9)
	state.world.tiles[_tid_key(ownerless_pos)] = _make_tile(ownerless_pos, "civilian", 1, -1)  # 無主
	var empty := HexTileData.new()
	empty.tile_pos = empty_pos
	empty.tile_id = _tid_key(empty_pos)
	state.world.tiles[_tid_key(empty_pos)] = empty   # 非據點格

	# ── 1. query_team.resources_nonzero ──
	var d: Dictionary = ObserverQueryApi.query_team(state, 5)
	var rn: Dictionary = d.get("resources_nonzero", {})
	_check(rn.has("material") and int(rn["material"]) == 8, "team nonzero material=8")
	_check(rn.has("weapon_melee_low"), "team nonzero weapon_melee_low present")
	_check(not rn.has("gem"), "team zero gem excluded")
	_check(not rn.has("mounts"), "team zero mounts excluded")
	_check(rn.has("food"), "team food in nonzero (render 端排除,DTO 全露)")

	# ── 2. query_outpost civilian ──
	var civ: Dictionary = ObserverQueryApi.query_outpost(state, civ_pos)
	_check(not civ.is_empty(), "civilian outpost non-empty")
	_check(str(civ.get("outpost_type", "")) == "civilian", "civ type")
	_check(int(civ.get("outpost_level", 0)) == 2, "civ level=2")
	_check(int(civ.get("owner_team_id", -99)) == 5, "civ owner_team_id=5")
	_check(str(civ.get("owner_team", "")) != "" and str(civ.get("owner_team", "")) != "（無主）", "civ owner_team labeled")
	_check(str(civ.get("owner_faction", "")) != "", "civ owner_faction non-empty (fid=7)")
	_check(civ.get("resources_nonzero", {}).has("ore_iron"), "civ resources_nonzero ore_iron")
	# facilities_nonzero (civ: farming=3, mint=1)
	var civ_fac: Dictionary = civ.get("facilities_nonzero", {})
	_check(int(civ_fac.get("farming", -1)) == 3, "civ facilities farming=3")
	_check(int(civ_fac.get("mint", -1)) == 1, "civ facilities mint=1")
	_check(not civ_fac.has("weaponsmith"), "civ facilities no weaponsmith")
	_check(not civ.has("weaponsmith_level"), "weaponsmith_level 單欄已移除 (併 facilities)")

	# ── 3. query_outpost military（garrison + facilities）──
	var mil: Dictionary = ObserverQueryApi.query_outpost(state, mil_pos)
	_check(str(mil.get("outpost_type", "")) == "military", "mil type")
	_check(int(mil.get("garrison", -1)) == 2, "mil garrison=2")
	var mil_fac: Dictionary = mil.get("facilities_nonzero", {})
	_check(int(mil_fac.get("weaponsmith", -1)) == 2, "mil facilities weaponsmith=2")
	_check(int(mil_fac.get("smeltery", -1)) == 1, "mil facilities smeltery=1")
	_check(int(mil.get("owner_team_id", -99)) == 9, "mil owner=9")

	# ── 4. 無主據點 owner=-1：null guard 不炸 ──
	var orphan: Dictionary = ObserverQueryApi.query_outpost(state, ownerless_pos)
	_check(not orphan.is_empty(), "ownerless outpost non-empty (not crash)")
	_check(int(orphan.get("owner_team_id", -99)) == -1, "ownerless owner_team_id=-1")
	_check(str(orphan.get("owner_team", "")) == "（無主）", "ownerless owner_team=（無主）")
	_check(str(orphan.get("owner_faction", "x")) == "", "ownerless owner_faction empty (guard)")

	# ── 5. 非據點格 → {} ──
	var e1: Dictionary = ObserverQueryApi.query_outpost(state, empty_pos)
	_check(e1.is_empty(), "non-outpost tile → {}")
	var e2: Dictionary = ObserverQueryApi.query_outpost(state, Vector2i(99, 99))
	_check(e2.is_empty(), "off-map tile (null tile) → {} (no crash)")

	# ── 5b. query_all_outposts（3 據點：civ/mil/無主，非據點格不入）──
	var all_op: Array = ObserverQueryApi.query_all_outposts(state)
	_check(all_op.size() == 3, "query_all_outposts 3 據點 (empty tile 不入)")
	var has_mil: bool = false
	var has_civ_facilities: bool = false
	for o in all_op:
		if str(o["outpost_type"]) == "military":
			has_mil = true
		if (o["tile_pos"] as Vector2i) == civ_pos:
			has_civ_facilities = int(o["facility_count"]) == 2   # farming+mint
	_check(has_mil, "list 含 military")
	_check(has_civ_facilities, "list civ facility_count=2")

	# ── 6. res_label 中文 ──
	_check(ObserverQueryApi.res_label("ore_iron") == "鐵礦", "res_label ore_iron=鐵礦")
	_check(ObserverQueryApi.res_label("unknown_key") == "unknown_key", "res_label unknown 原樣")

	print("=== observer_inspect_test: PASS=%d FAIL=%d ===" % [_pass, _fail])
	if _fail == 0:
		print("[OBSERVER-INSPECT-TEST] ALL PASS")
	else:
		print("[OBSERVER-INSPECT-TEST] FAILED")
	quit()
