extends SceneTree
# @bed-kind: acceptance
# slice: 佔村掃改讀 known_outposts（systems 派工 2026-09-18；`market-ads` 的前置）
#
# ★★★病灶與前兩支姊妹 site 逐字同形：
#   閘用 `team_tile_known`（只問「**我有沒有見過這塊地**」）⇒ 閘過之後**直接 live 讀**
#   `tile.outpost_level`／`tile.outpost_owner` ⇒ 憲法 §1a：belief 閘只授權「要不要評估」，
#   ★★**不授權讀它的 live 值**。
#
# ★★★而這一支【現在就要修】的理由不是原則，是下一票的具體後果：
#   `market-ads` 會讓 relay 把**更多 tile** 寫進 `team_tile_known`
#   ⇒ 只問存在的閘會放行 ⇒ ★**一則【交易】訊息會變成一條【軍事】資訊的通道**。
#
# ★【誠實限】格 a 的「只有 market 子記錄的地」目前**還沒有生產者**（`market-ads` 未落地）
#   ⇒ ★★那一格的 fixture 是**手工寫的子記錄**（我標明了）——
#   ★★★**它守的是「當那個生產者出現時，這條路已經是關的」**，而不是「現在有人在寫它」。

var _fail: int = 0
const EXPECTED_CELLS: Array = ["a", "b", "c"]
var _cells_ran: Array = []

func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func noop() -> void:
	pass

func _selftest_gate(cell: String) -> Object:
	if OS.get_environment("BED_SELFTEST_DIE") != cell:
		return self
	print("[SELFTEST] ★故意讓 `%s` 這一格在中途死掉" % cell)
	return null

func _roll_call_missing() -> Array:
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): missing.append(c)
	if not missing.is_empty():
		print("[roll-call] ❌ ★**有格沒有跑完**：%s —— 執行期錯誤會靜默中止一支 func，而那看起來像綠" % str(missing))
	return missing

func _initialize() -> void:
	_run()
	var _miss: Array = _roll_call_missing()
	print("-- 量測完成；[FAIL] 數 ＝ %d｜到場點名 %d／%d --" % [
		_fail + _miss.size(), _cells_ran.size(), EXPECTED_CELLS.size()])
	print("[TEST-SUITE-COMPLETE]")
	quit(1 if (_fail + _miss.size()) > 0 else 0)

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fail += 1
		push_error("[FAIL] %s" % msg)

func _bed_self_check_tree() -> void:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], out)
	var sha: String = (out[0] as String).strip_edges() if not out.is_empty() else "UNKNOWN"
	out.clear()
	OS.execute("git", ["status", "--porcelain", "--", "scripts/"], out)
	var dirty: int = 0
	if not out.is_empty():
		for l in (out[0] as String).split("\n"):
			if l.strip_edges() != "": dirty += 1
	print("[TREE] HEAD=%s scripts-dirty=%d（%s）" % [sha, dirty, "clean" if dirty == 0 else "★dirty"])

# ── fixture：強觀察者（可據可勝）＋ 弱村（站在自家 outpost 上）──
func _mk_world(village_pos: Vector2i) -> WorldState:
	var s := MeasureBedHelper.arm_and_new()
	s.world.current_tick = 10 * WorldState.TICKS_PER_DAY
	for x in range(0, 10):
		for y in range(0, 10):
			var t := HexTileData.new()
			t.tile_pos = Vector2i(x, y); t.terrain = "plains"
			s.world.tiles[x * 1000 + y] = t
	var vt: HexTileData = s.world.tiles[village_pos.x * 1000 + village_pos.y]
	vt.outpost_owner = 2
	vt.outpost_level = 1
	# 觀察者：人多、武裝足（`_calc_own_armed` 走 armed_anon_ratio）
	var me := TeamData.new()
	me.team_id = 1; me.faction_id = 1; me.leader_id = 100; me.tile_pos = Vector2i(0, 0)
	AnonCohort.add(me.anon_cohorts, "平民", "healthy", 20)
	me.armed_anon_ratio = 1.0
	var lead := PersonData.new(); lead.id = 100; lead.values = {"慎重": 0.5}
	s.persons[100] = lead; s.teams[1] = me
	# 弱村：人少、站在自己的 outpost 上
	var vil := TeamData.new()
	vil.team_id = 2; vil.faction_id = 2; vil.leader_id = 200; vil.tile_pos = village_pos
	AnonCohort.add(vil.anon_cohorts, "平民", "healthy", 3)
	var vlead := PersonData.new(); vlead.id = 200; vlead.values = {}
	s.persons[200] = vlead; s.teams[2] = vil
	s.team_discovered[1] = [2]
	BeliefSystem.record_claim(s, 1, 2, 1, "親見",
		{"tile_pos": village_pos, "population_est": 3.0}, 1.0, false)
	return s

func _run() -> void:
	print("=== 佔村掃改讀 known_outposts 驗收 ===")
	_bed_self_check_tree()
	_cell_b_seen_village_still_selected()
	_cell_a_market_only_tile_rejected()
	_cell_c_dont_touch_the_others()

# ── b：看過的敵據點【仍然】進候選（★先跑它：它同時是 a 的對照組）──
func _cell_b_seen_village_still_selected() -> void:
	_selftest_gate("b").noop()
	var s := _mk_world(Vector2i(1, 0))     # ★城就在隔壁 ⇒ harvest 看得到、eta 也夠近
	BeliefSystem.harvest_tile_known(s, s.teams[1])
	var ops: Array = BeliefSystem.known_outposts(s, 1)
	var fai := FactionAISystem.new()
	var target: int = fai._find_occupy_target(s, s.teams[1])
	print("b｜親眼走過那座城（已知據點 %d 筆）⇒ 佔村目標 = %d" % [ops.size(), target])
	_ok(ops.size() == 1 and int(ops[0]["owner_id"]) == 2,
		"b-前提 ★harvest **真的**寫下了據點子記錄（owner=2）—— ★前提不成立的話下一句證不到東西")
	_ok(target == 2,
		"b ★**看過的敵據點仍然進候選**（樣本 1／母體 1）｜★不進 ⇒ 我修過頭了")
	_cell("b")

# ── a：只有 market 子記錄的地【不進】候選 ──
func _cell_a_market_only_tile_rejected() -> void:
	_selftest_gate("a").noop()
	# ★★★【城要放在視野外】（2026-09-18 實測，我第一版踩的）——
	#   ★`_find_occupy_target` 自己第一行就 `harvest_tile_known()` ⇒ ★★**它會用【真實觀察】覆蓋我手塞的 store**
	#   ⇒ 城若在隔壁（視野內），harvest 會把真的據點子記錄寫回去 ⇒ 這一格量到的是【harvest】不是【我的 fixture】。
	#   ⇒ ★★★所以城放在 (5,0)：**距離 5 ＞ VISION_RADIUS 3（看不到）**，
	#     而 eta 仍在 `OCCUPY_ETA_MAX` 內（走得到）⇒ 只有「知不知道那裡有城」這一個變因在動。
	var s := _mk_world(Vector2i(5, 0))
	# ★★這一格的 fixture 是【手工寫的子記錄】——**因為那個生產者（`market-ads`）還沒落地**。
	#   ★我不假裝它已經存在：手工寫的是「未來那個寫入端會寫成什麼樣」的最小形狀，
	#   ★★而這一格守的是【當它出現時，這條路已經是關的】。
	#   ★★★同時它也是「見過這塊地、但沒看過城」那一類的代表（relay 只寫 key 也是同一格）。
	s.team_tile_known[1] = {
		5 * 1000 + 0: {"market": {"last_tick": s.world.current_tick, "board_size": 3}},
	}
	var ops: Array = BeliefSystem.known_outposts(s, 1)
	var fai := FactionAISystem.new()
	var target: int = fai._find_occupy_target(s, s.teams[1])
	print("a｜那塊地只有 market 子記錄（已知據點 %d 筆）⇒ 佔村目標 = %d" % [ops.size(), target])
	_ok(ops.is_empty(),
		"a-前提 ★`known_outposts()` **不把 market 子記錄當據點**（%d 筆）" % ops.size())
	_ok(target == -1,
		"a ★★**只有 market 子記錄的地不進佔村候選**（樣本 0／母體 1）"
		+ "｜★★★進了 ⇒ 一則【交易】訊息變成一條【軍事】資訊的通道")
	_cell("a")

# ── c：不要修錯東西（★內容錨，不用行號）──
func _cell_c_dont_touch_the_others() -> void:
	_selftest_gate("c").noop()
	print("\n— c：別修錯東西（原始碼內容錨）—")
	var gr: String = FileAccess.get_file_as_string("res://scripts/simulation/decision/goal_resolver.gd")
	_ok(gr.contains("if t == null or (terrain != \"\" and t.terrain != terrain):"),
		"c-① ★`goal_resolver.find_nearest_known_tile` 逐字未改（它閘後讀的是 `terrain`，**地形不會變**）")
	var dc: String = FileAccess.get_file_as_string("res://scripts/simulation/decision/decision_context.gd")
	var anchors: Array = [
		"if _btile != null and _btile.outpost_owner == team.team_id and _btile.outpost_level > 0:",
		"and _uf.camp_level == 1 and _uf.outpost_level",
		"if _uf.outpost_level != 0: Probe.bump(\"cansettle.false.5_already_outpost\")",
		"var _home_now := VillageEstimate.make(_home.terrain, _home.outpost_level, _home.farming_level",
		"var _home_after := VillageEstimate.make(_home.terrain, _home.outpost_level, _home.farming_level",
		"maxi(_ptile.outpost_level if _ptile != null else 1, 1), 0, team.population))",
	]
	var hit: int = 0
	for a in anchors:
		if dc.contains(a): hit += 1
		else: print("     ★沒找到錨：%s" % a.substr(0, 60))
	print("c｜`gather()` 自家錨 %d／%d 仍在" % [hit, anchors.size()])
	_ok(hit == 6 and anchors.size() == 6,
		"c-② ★★`gather()` 的自家據點讀取【6 處】逐字未改"
		+ "｜★★★分母寫死 6（來自 spec §5）而不是 `anchors.size()` —— **自己跟自己比的守衛不是守衛**")
	_cell("c")
