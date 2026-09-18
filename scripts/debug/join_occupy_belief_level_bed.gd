extends SceneTree
# @bed-kind: acceptance
# slice: 求居／佔村的流量估算改讀 belief 的據點等級（systems 派工 2026-09-18）
#
# ★★★病灶（spec §0）：閘走 belief（`has_belief` ＋ `belief_pos` ＋ `population_est`）——**那半合法**——
#   ★而落地那一行 `state.world.tiles.get(<belief 位置>).outpost_level` 是 **live**。
#   ⇒ `outpost_level` **會變**（升級／拆除／被攻陷）⇒ 讀它等於知道**現在**，而我只該知道**當時**。
#   ★★而同一行讀的 `terrain` **不會變** ⇒ 那半是合法的，**不要一起修掉**（格 1-e 守這件事）。
#
# ★★【這支床怎麼避免「自己跟自己比」】：格 1-c 要證明「用的是【當時】的等級」，
#   而「當時 vs 現在」需要一個**會因等級不同而不同**的量 —— ★所以我不手抄公式去算期望值，
#   ★★改用**三個世界**、讓 **production 自己**生出兩個參考值：
#     W1：子記錄 level 1、live level 1  ⇒ flow_A
#     W3：子記錄 level 3、live level 3  ⇒ flow_B
#     WS：子記錄 level 1、live level 3  ⇒ flow_C（★城升級了，而我【沒再看過】）
#   ⇒ ★★★先斷言 **flow_A ≠ flow_B**（＝等級真的會改變估值，這一格才有鑑別力），
#     再斷言 **flow_C ＝ flow_A 且 flow_C ≠ flow_B**。
#     ★少了第一句，flow_C == flow_A 可能只是因為【等級根本不影響估值】——那會是一個假綠。

var _fail: int = 0
const EXPECTED_CELLS: Array = ["1-a", "1-b", "1-c", "1-d", "1-e", "1-f"]
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

# ── fixture ──────────────────────────────────────────────
const CITY: Vector2i = Vector2i(5, 0)     # ★★城放在【視野外】（距離 5 ＞ VISION_RADIUS 3）
#   ★而距離 5 是實測挑的：7 以上 `estimate_catch_up` 回 `too_far` ⇒ **兩個 id 都選不中** ⇒ 整支床空轉。
const OBS: Vector2i = Vector2i(0, 0)      #   —— reviewer 的保險：fixture 不會被 production 的 harvest 覆蓋

# ★★★【一個世界不能同時測兩條 flow】（實測逼出來的）：
#   `strong_neighbor` 要的是「**比我大**」（`pop_est > 我的 1.5 倍`），
#   而 `_find_occupy_target` 要的是「**比我弱**」（可據的弱村）
#   ⇒ ★同一支隊**不可能同時**是「值得投靠的強鄰」與「可以佔的弱村」
#   ⇒ ★★所以分兩種 fixture：`mode` ＝ "join"（對方大）／"occupy"（對方小、我方武裝）。
#   ★★★第一版我用同一個世界測兩條 ⇒ **兩個 id 都是 -1**，而那幾格【看起來是綠的】
#     —— 是我加的「前提」那幾格把它擋下來的。
func _mk_world(record_level: int, live_level: int, mode: String = "join") -> WorldState:
	var s := MeasureBedHelper.arm_and_new()
	s.world.current_tick = 10 * WorldState.TICKS_PER_DAY
	for x in range(0, 14):
		for y in range(0, 4):
			var t := HexTileData.new()
			t.tile_pos = Vector2i(x, y); t.terrain = "plains"
			s.world.tiles[x * 1000 + y] = t
	# 城（live 等級由參數決定）
	var ct: HexTileData = s.world.tiles[CITY.x * 1000 + CITY.y]
	ct.outpost_owner = 2
	ct.outpost_level = live_level
	# 觀察者（人少 ⇒ host 的 pop_est 容易過 1.5× 那道閘）
	var me := TeamData.new()
	me.team_id = 1; me.faction_id = 1; me.leader_id = 100; me.tile_pos = OBS
	AnonCohort.add(me.anon_cohorts, "平民", "healthy", 4 if mode == "join" else 20)
	if mode == "occupy":
		me.armed_anon_ratio = 1.0     # ★佔村要「打得動」
	var lead := PersonData.new(); lead.id = 100; lead.values = {"慎重": 0.5}
	s.persons[100] = lead; s.teams[1] = me
	# host／占領目標：同一支隊（住在城上），★不同 faction
	var host := TeamData.new()
	host.team_id = 2; host.faction_id = 2; host.leader_id = 200; host.tile_pos = CITY
	AnonCohort.add(host.anon_cohorts, "平民", "healthy", 20 if mode == "join" else 3)
	var hlead := PersonData.new(); hlead.id = 200; hlead.values = {}
	s.persons[200] = hlead; s.teams[2] = host
	s.team_discovered[1] = [2]
	# belief：位置與人口（★閘走的那一半，合法）
	BeliefSystem.record_claim(s, 1, 2, 1, "親見",
		{"tile_pos": CITY, "population_est": 20.0 if mode == "join" else 3.0}, 1.0, false)
	# ★據點子記錄：`record_level <= 0` ＝【我沒看過那座城】（1-a 的情形）
	if record_level > 0:
		s.team_tile_known[1] = {
			CITY.x * 1000 + CITY.y: {
				"outpost": {"owner_id": 2, "level": record_level,
					"last_tick": s.world.current_tick},
			},
		}
	else:
		s.team_tile_known[1] = {}
	return s

# 回 [join_host_flow, occupy_target_flow]；★同時把前提（兩個 id 有沒有選中）帶回來
func _flows_of(record_level: int, live_level: int, mode: String) -> Dictionary:
	return _flows(_mk_world(record_level, live_level, mode))

func _flows(s: WorldState) -> Dictionary:
	var c: DecisionContext = DecisionContext.gather(s, s.teams[1])
	return {
		"join": c.join_host_flow, "occupy": c.occupy_target_flow,
		"sn": c.strong_neighbor_id, "occ": c.occupy_target_id,
	}

func _run() -> void:
	print("=== 求居／佔村的流量估算改讀 belief 據點等級 驗收（spec §2）===")
	_bed_self_check_tree()

	# join 那條：對方【比我大】
	var w1: Dictionary = _flows_of(1, 1, "join")
	var w3: Dictionary = _flows_of(3, 3, "join")
	var ws: Dictionary = _flows_of(1, 3, "join")   # ★子記錄 1／live 3（城升級了，我沒再看過）
	var wn: Dictionary = _flows_of(0, 1, "join")   # ★沒有子記錄（見過隊、沒看過城）
	# occupy 那條：對方【比我弱】（★同一個世界測不了兩條，見 `_mk_world` 檔頭）
	var o1: Dictionary = _flows_of(1, 1, "occupy")
	var o3: Dictionary = _flows_of(3, 3, "occupy")
	var os_: Dictionary = _flows_of(1, 3, "occupy")
	var on_: Dictionary = _flows_of(0, 1, "occupy")

	print("[前提] strong_neighbor_id：W1=%d W3=%d WS=%d WN=%d｜occupy_target_id：W1=%d W3=%d WS=%d WN=%d" % [
		int(w1["sn"]), int(w3["sn"]), int(ws["sn"]), int(wn["sn"]),
		int(w1["occ"]), int(w3["occ"]), int(ws["occ"]), int(wn["occ"])])
	print("[流量] join：W1=%.4f W3=%.4f WS=%.4f WN=%.4f" % [
		float(w1["join"]), float(w3["join"]), float(ws["join"]), float(wn["join"])])
	print("[前提] occupy 世界的 occupy_target_id：O1=%d O3=%d OS=%d ON=%d" % [
		int(o1["occ"]), int(o3["occ"]), int(os_["occ"]), int(on_["occ"])])
	print("[流量] occupy：O1=%.4f O3=%.4f OS=%.4f ON=%.4f" % [
		float(o1["occupy"]), float(o3["occupy"]), float(os_["occupy"]), float(on_["occupy"])])

	# ── 1-a：見過那支隊、沒看過它的城 ⇒ 兩條 flow 都是 0（★不是用 live 估出來的數）──
	_selftest_gate("1-a").noop()
	_ok(int(wn["sn"]) == 2,
		"1-a-前提① ★`strong_neighbor_id` 真的選中了那支隊（%d）" % int(wn["sn"])
		+ "｜★★沒選中 ⇒ 下一句話【恆真】，那不是綠是空轉")
	_ok(is_zero_approx(float(wn["join"])),
		"1-a ★**見過隊、沒看過城 ⇒ `join_host_flow` ＝ 0**（%.4f）" % float(wn["join"])
		+ "｜★>0 ⇒ 它退回 live 了（§1a：unknown 一律不通過、禁 default-pass）")
	_cell("1-a")

	# ── 1-b：看過那座城 ⇒ 有值，而且是用子記錄的等級估的 ──
	_selftest_gate("1-b").noop()
	_ok(float(w1["join"]) > 0.0,
		"1-b ★**看過那座城 ⇒ `join_host_flow` 有值**（%.4f）" % float(w1["join"])
		+ "｜★為 0 ⇒ 我修過頭了（把合法的那一半也擋掉）")
	_cell("1-b")

	# ── 1-c：★★★「當時 vs 現在」的真對照 ──
	_selftest_gate("1-c").noop()
	print("\n— 1-c：城升級了，而我沒再看過 —")
	_ok(not is_equal_approx(float(w1["join"]), float(w3["join"])),
		"1-c-前提② ★★**等級真的會改變估值**（level1=%.4f ≠ level3=%.4f）" % [
			float(w1["join"]), float(w3["join"])]
		+ "｜★★★相等 ⇒ 下面那一句【恆真】：它會在「用當時」與「用現在」之下同樣綠")
	_ok(is_equal_approx(float(ws["join"]), float(w1["join"]))
			and not is_equal_approx(float(ws["join"]), float(w3["join"])),
		"1-c ★★**估值仍是【當時】那個等級**（WS=%.4f ＝ level1 的 %.4f，≠ live level3 的 %.4f）" % [
			float(ws["join"]), float(w1["join"]), float(w3["join"])]
		+ "｜★跟著升 ⇒ 它讀的是 live，本票沒生效")
	_cell("1-c")

	# ── 1-d：占領那條同樣三格 ──
	_selftest_gate("1-d").noop()
	print("\n— 1-d：`occupy_target_flow` 同樣三格 —")
	# ★★★【這一格的真相與 spec 寫的不一樣，我照實記】：
	#   spec 1-d 預期「沒看過城 ⇒ `occupy_target_flow` ＝ 0」由**本票**擋下來。
	#   ★實測：那個世界的 `occupy_target_id` 根本就是 **-1** ——
	#     因為**姊妹票（已 merged）**讓 `_find_occupy_target` 改讀 `known_outposts`
	#     ⇒ **沒有子記錄的城，連【候選】都進不去**。
	#   ⇒ ★★所以這條路上「flow ＝ 0」是【上游】保證的，**不是本票的功勞**；
	#     ★★★本票在占領這條路上真正改變的是 **1-d-③（等級用當時的）**。
	#   ⇒ 我把斷言寫成它**實際**保證的那件事，而不是把它調成看起來像本票的功勞。
	_ok(int(on_["occ"]) == -1,
		"1-d-① ★**沒看過那座城 ⇒ 連占領候選都不是**（id=%d）—— ★★這是【姊妹票】的保證，"
		% int(on_["occ"])
		+ "**不是本票的**；而 flow 因此 ＝ %.4f" % float(on_["occupy"]))
	_ok(is_zero_approx(float(on_["occupy"])),
		"1-d-①附 ★flow 確實是 0（%.4f）" % float(on_["occupy"]))
	_ok(int(o1["occ"]) == 2,
		"1-d-前提① ★**有子記錄的世界裡 `occupy_target_id` 有選中**（%d）" % int(o1["occ"])
		+ "｜★★沒選中 ⇒ 下面幾句【恆真】")
	_ok(float(o1["occupy"]) > 0.0,
		"1-d-② ★看過那座城 ⇒ 有值（%.4f）｜★為 0 ⇒ 修過頭" % float(o1["occupy"]))
	_ok(not is_equal_approx(float(o1["occupy"]), float(o3["occupy"])),
		"1-d-前提② ★★等級真的會改變占領估值（%.4f ≠ %.4f）" % [
			float(o1["occupy"]), float(o3["occupy"])])
	_ok(is_equal_approx(float(os_["occupy"]), float(o1["occupy"]))
			and not is_equal_approx(float(os_["occupy"]), float(o3["occupy"])),
		"1-d-③ ★★**占領估值仍是【當時】那個等級**（OS=%.4f ＝ %.4f ≠ %.4f）" % [
			float(os_["occupy"]), float(o1["occupy"]), float(o3["occupy"])])
	_cell("1-d")

	# ── 1-e：terrain 仍走 live（★不要修過頭）──
	_selftest_gate("1-e").noop()
	print("\n— 1-e／1-f：原始碼內容錨 —")
	var src: String = FileAccess.get_file_as_string("res://scripts/simulation/decision/decision_context.gd")
	var body: String = _strip_comments(src)
	_ok(body.contains("_htile.terrain") and body.contains("_vtile.terrain"),
		"1-e ★**`terrain` 仍然走 live、逐字未改**（兩處都在）"
		+ "｜★★地形不會變 ⇒ 那半合法；一起改掉＝修過頭")
	_ok(not body.contains("_htile.outpost_level") and not body.contains("_vtile.outpost_level"),
		"1-e-② ★★**那兩行不再 live 讀 `outpost_level`**（★先剝註解再比對："
		+ "我解釋這個病的註解逐字包含那個欄位名，而檢查器與被檢查物在同一個檔案裡）")
	_cell("1-e")

	# ── 1-f：自家 6 處讀取逐字未改（★內容錨，不用行號）──
	_selftest_gate("1-f").noop()
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
		if src.contains(a): hit += 1
		else: print("     ★沒找到錨：%s" % a.substr(0, 60))
	print("1-f｜自家錨 %d／%d 仍在" % [hit, anchors.size()])
	_ok(hit == 6 and anchors.size() == 6,
		"1-f ★**自家據點讀取【6 處】逐字未改**"
		+ "｜★★分母寫死 6（來自 spec §2 1-f）而不是 `anchors.size()` —— **自己跟自己比的守衛不是守衛**")
	_cell("1-f")

# ★剝掉註解再比對 —— ★★檢查器與被檢查物在同一個檔案裡時，「我寫的話」與「code 做的事」會混在一起
#   （同族血證：上一票我寫的說明註解逐字包含 `tile.outpost_owner`，把那一格判紅）。
func _strip_comments(src: String) -> String:
	var out: PackedStringArray = PackedStringArray()
	for line in src.split("\n"):
		var i: int = line.find("#")
		out.append(line if i < 0 else line.substr(0, i))
	return "\n".join(out)
