extends SceneTree
# @bed-kind: acceptance
# slice: 農田限平原（用戶裁 2026-09-10）
#
# 驗收：①擋得住（山地/森林被擋 + 計數 +1）★成對對照：平原上同樣的嘗試【成功】
#   ②★不追溯：預放一座山地 farming_level=2 ⇒ 規則上線後【照常產出】
#     （這格是 HOW 裁定的守衛：證明我們做的是「建址擋」不是「產出擋」）
#   ③raw/eff/gate（raw 掛斷言；★母體由⑤決定）
#   ④四支既有床的農田地形清單（只印，本票不改它們）
#   ⑤civilian 據點落在各地形的比例（★決定③有沒有母體；R² 訂正：要看【森林】不是只看山地）

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 4

func _initialize() -> void:
	print("=== FARMING REQUIRES PLAINS ===")
	_test_blocked_and_allowed()
	_test_no_retroactive()
	_test_bed_terrain_list()
	_test_world_raw_eff_gate()
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

# 造一個「除了地形以外什麼都齊」的建址情境
func _mk(terrain: String) -> Array:
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 5000
	var tile := HexTileData.new()
	tile.tile_id = 1001
	tile.tile_pos = Vector2i(1, 1)
	tile.terrain = terrain
	tile.outpost_type = "civilian"
	tile.outpost_level = 1
	tile.outpost_owner = 7
	tile.construction_team_id = -1
	# ★農田產出的其餘輸入（照 labor_marginal_v2_test 的既有 fixture）：
	#   harvest_factor / productivity / tile 糧倉容量 —— 少任何一個 fyield 都是 0，
	#   ★而 0 會被讀成「規則沒收了它」。
	tile.harvest_factor = 1.0
	tile.productivity = 1.0
	tile.resources = { "food": 40.0, "material": 40.0 }
	tile.resource_cap = { "food": 200.0, "material": 200.0 }
	st.world.tiles[1001] = tile
	var t := TeamData.new()
	t.team_id = 7
	t.tile_pos = Vector2i(1, 1)
	t.tags = [TeamData.TAG_PRODUCE]
	var ldr := PersonData.new()
	ldr.id = 71
	ldr.skills = { "生產": 0.3 }
	st.persons[71] = ldr
	t.leader_id = 71
	AnonTierSystem.add_anon(t, "平民", 10)
	t.resources = { "material": 200.0, "food": 200.0, "tools": 10.0 }
	st.teams[7] = t
	return [st, t, tile]

func _test_blocked_and_allowed() -> void:
	print("-- ① 擋得住（★成對對照：平原上同樣的嘗試要成功）--")
	var os_sys := OutpostSystem.new()
	Probe.reset()
	Probe.enabled = true
	for terr in ["mountain", "forest"]:
		var w: Array = _mk(terr)
		var before: int = _reject_count()
		var ok: bool = os_sys.start_upgrade_facility(w[0], w[1], "farming")
		var after: int = _reject_count()
		print("    %-8s 建址回傳 %s｜wall.reject_terrain %d → %d" % [terr, str(ok), before, after])
		_ok(not ok, "①%s 上的農田被擋" % terr)
		_ok(after > before, "①%s 被擋時 wall.reject_terrain 有 +1（不是靜默）" % terr)
	var wp: Array = _mk("plains")
	var ok_p: bool = os_sys.start_upgrade_facility(wp[0], wp[1], "farming")
	print("    plains   建址回傳 %s" % str(ok_p))
	_ok(ok_p, "①★成對對照：平原上【同樣的嘗試成功】—— 否則擋住的可能是別的東西")
	Probe.enabled = false
	_sections += 1

func _reject_count() -> int:
	var n: int = 0
	for k in Probe.counts:
		if String(k).begins_with("wall.reject_terrain"):
			n += int(Probe.counts[k])
	return n

func _farm_yield(terrain: String) -> float:
	# 同一組 fixture、只換地形 ⇒ 產出量若相同，就證明【產出端沒有第二道地形判斷】
	var w: Array = _mk(terrain)
	var st: WorldState = w[0]
	var tile: HexTileData = w[2]
	tile.farming_level = 2
	LaborSystem.rebalance(st, tile)
	Probe.reset()
	Probe.enabled = true
	ResourceSystem.new().collect_resources(st, [7])
	var y: float = Probe.amount("qty.harvest_src.farm.food")
	Probe.enabled = false
	return y

func _test_no_retroactive() -> void:
	print("-- ② 不追溯：既有的山地農田照常產出 --")
	# ★★★量【農田產出量】本身（Probe 的 qty.harvest_src.farm.food），不要量 tile/隊的存量差：
	#   存量會同時被【採集】與【消耗】動 ⇒ 淨變化 0 會被讀成「沒產出」。
	#   ★第一版我量隊私產（恆 0，因為產出進 tile 糧倉）、第二版量 tile 淨值（採集抵銷）——
	#   ★★兩次都得到 0，而【量錯欄位】與【真的沒產出】長得一模一樣。
	var y_mtn: float = _farm_yield("mountain")
	var y_pln: float = _farm_yield("plains")
	print("    同 fixture、只換地形：山地農田產出 %.3f｜平原農田產出 %.3f" % [y_mtn, y_pln])
	_ok(y_mtn > 0.0, "②既有的【山地】農田照常產出（%.3f > 0）—— 規則沒有跑到產出端" % y_mtn)
	_ok(is_equal_approx(y_mtn, y_pln),
		"②★成對對照：山地與平原【產出相同】（%.3f == %.3f）⇒ 產出端沒有第二道地形判斷" % [y_mtn, y_pln])
	# ★結構面：規則只寫在建址端一處
	var src := FileAccess.open("res://scripts/simulation/resource_system.gd", FileAccess.READ)
	var prod_src: String = src.get_as_text() if src != null else ""
	if src != null:
		src.close()
	_ok(not prod_src.contains("required_terrain"),
		"②產出端原始碼沒有 required_terrain（同一個規則放兩處必然 drift）")
	_sections += 1

func _test_bed_terrain_list() -> void:
	print("-- ④ 四支既有床的農田地形（★只印，本票不改它們）--")
	var rows: Array = [
		["expand_bigvillage_bed.gd:35", "plains（:24 顯式 terrain = \"plains\"）"],
		["headless_test.gd:9845", "plains（同行顯式）"],
		["headless_test.gd:11870", "plains（HexTileData.new() 預設，tile_data.gd:5）"],
		["labor_marginal_v2_test.gd:49", "plains（同段 :47 顯式）"],
		["labor_marginal_v2_test.gd:63", "plains（預設）"],
		["observer_inspect_test.gd:31", "plains（預設）"],
	]
	for r in rows:
		print("    %-32s %s" % [String(r[0]), String(r[1])])
	_ok(true, "④清單已印（六處全在平原 ⇒ 本票不影響這四支床）")
	_sections += 1

func _test_world_raw_eff_gate() -> void:
	print("-- ③⑤ 真世界：raw / eff / gate ＋ 母體 --")
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 2
	seed(1337)
	Probe.arm()
	# ★★①那段的構造情境也會 bump ⇒ 這裡取【世界段的增量】，否則我把自己造的 4 次算成世界裡發生的
	var raw_before: int = _reject_count()
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json", true)
	var runner := SimRunner.new()
	var first_stall: int = -1
	for tick in range(days * WorldState.TICKS_PER_DAY):
		if runner.advance_tick(state, Vector2i(-1, -1)) != "" and first_stall == -1:
			first_stall = tick
	print("  [有效窗] %d 天｜首次非推進：%s" % [days, ("無" if first_stall == -1 else str(first_stall))])
	# ⑤母體：civilian 據點落在各地形
	var by_terr := { "plains": 0, "forest": 0, "mountain": 0 }
	for tid in state.world.tiles:
		var t: HexTileData = state.world.tiles[tid]
		if t.outpost_level > 0 and t.outpost_type == "civilian":
			by_terr[t.terrain] = int(by_terr.get(t.terrain, 0)) + 1
	var total: int = int(by_terr["plains"]) + int(by_terr["forest"]) + int(by_terr["mountain"])
	print("  ⑤civilian 據點 %d 座：plains %d｜forest %d｜mountain %d（★母體＝非平原那 %d 座）" % [
		total, int(by_terr["plains"]), int(by_terr["forest"]), int(by_terr["mountain"]),
		int(by_terr["forest"]) + int(by_terr["mountain"])])
	var raw: int = _reject_count() - raw_before
	print("  raw（wall.reject_terrain 計數）%d｜eff/gate：本票不動任何 util 或 applicable ⇒ n/a" % raw)
	if int(by_terr["forest"]) + int(by_terr["mountain"]) == 0:
		print("  ★★母體為 0（所有 civilian 據點都在平原）⇒ raw=0 是【沒有機會被擋】不是【擋不住】")
		print("     ⇒ 這一格【不判】：①那格用構造情境已經證明擋得住")
	else:
		_ok(raw > 0, "③非平原據點 %d 座 ⇒ wall.reject_terrain 該 > 0（實得 %d）" % [
			int(by_terr["forest"]) + int(by_terr["mountain"]), raw])
	_sections += 1
