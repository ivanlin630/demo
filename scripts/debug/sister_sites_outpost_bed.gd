extends SceneTree
# @bed-kind: acceptance
# slice: 兩支姊妹 site 改讀 known_outposts（HOW spec 2026-09-18-sister-sites-read-known-outposts-HOW.md §3）
#
# ★★★病灶逐字同形（前一票已在 `faction_ai` 上修掉第一支）：
#   閘用 `team_tile_known`（只問「有沒有見過這塊地」，★不分是誰的、上面有什麼）
#   ⇒ 閘過了之後**直接 live 讀** `tile.outpost_owner`／`outpost_level`
#   ⇒ ★★憲法 §1a：belief 閘只授權「要不要評估」，**不授權讀它的 live 值**。
#
# ★兩支：`strategic_ai_system._find_trade_partner`（商隊找交易對象）
#        `decision_context.gather`（產出隊找 host 據點）
#
# ★★【誠實限】1-a/1-b 是 fixture 級（證明門開對了）；1-c/1-d/1-e 是**原始碼逐字格**；
#   ★★★1-f 才是世界級（證明候選集在真世界裡**真的換了一批**）。
#
# env：BED_WORLD（=0 時 1-f 標【不可判】）／BED_DAYS（預設 10）／BED_SEED（預設 1337）

var _fail: int = 0
var _undec: int = 0

const EXPECTED_CELLS: Array = ["1-a", "1-b", "1-c", "1-d", "1-e", "1-f"]

# ★★★到場點名（要件③）：執行期錯誤只中止那一支 func，床照樣跑完、照樣印通過橫幅
#   ⇒ 每格自己的最後一行打卡，末尾對名單，少一格就把橫幅變 FAIL。
#   ★用法必須是 `_selftest_gate("格名").noop()` —— 死亡要發生在那一格自己的 frame 裡。
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
	print("-- 量測完成；[FAIL] 數 ＝ %d｜[不可判] 數 ＝ %d｜到場點名 %d／%d --" % [
		_fail + _miss.size(), _undec, _cells_ran.size(), EXPECTED_CELLS.size()])
	print("[TEST-SUITE-COMPLETE]")
	quit(1 if (_fail + _miss.size()) > 0 else 0)

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fail += 1
		push_error("[FAIL] %s" % msg)

func _undecidable(cell: String, claim: String, why: String, how: String) -> void:
	_undec += 1
	push_error("[不可判] %s：%s" % [cell, claim])
	print("  [不可判] %s ——\n       宣稱：%s\n       為什麼這次驗不了：%s\n       怎麼驗：%s" % [cell, claim, why, how])

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

# ── fixture ───────────────────────────────────────────────────
func _mk_tile(s: WorldState, pos: Vector2i, owner: int = -1, level: int = 0) -> void:
	var t := HexTileData.new()
	t.tile_pos = pos; t.terrain = "plains"; t.outpost_owner = owner; t.outpost_level = level
	s.world.tiles[pos.x * 1000 + pos.y] = t

func _mk_team(s: WorldState, tid: int, fid: int, lid: int, pos: Vector2i, pop: int, produce: bool = false) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid; t.faction_id = fid; t.leader_id = lid; t.tile_pos = pos
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop)
	if produce: t.tags.append(TeamData.TAG_PRODUCE)
	var p := PersonData.new(); p.id = lid; p.values = {"慎重": 0.5}
	s.persons[lid] = p; s.teams[tid] = t
	return t

# 觀察者站哪 ⇒ 決定它有沒有「親眼走過那座城」
func _mk_world(observer_pos: Vector2i, observer_produce: bool = false) -> WorldState:
	var s := MeasureBedHelper.arm_and_new()
	s.world.current_tick = 10 * WorldState.TICKS_PER_DAY
	for x in range(0, 12):
		for y in range(0, 12):
			_mk_tile(s, Vector2i(x, y))
	_mk_tile(s, Vector2i(5, 5), 2, 2)                      # ★城：主人 team 2
	_mk_team(s, 1, 1, 100, observer_pos, 8, observer_produce)   # 觀察者
	_mk_team(s, 2, 2, 200, Vector2i(11, 11), 8)            # 城主本人在很遠的地方
	_mk_team(s, 3, 2, 300, Vector2i(5, 5), 6, true)        # ★城裡的居民團（`_tile_has_resident` 要）
	return s

func _run() -> void:
	print("=== 兩支姊妹 site 改讀 known_outposts 驗收（spec §3）===")
	_bed_self_check_tree()
	_cell_1a()
	_cell_1b()
	_cell_1c_no_live_read()
	_cell_1d_dont_fix_the_wrong_one()
	_cell_1e_self_home_untouched()
	_cell_1f_world()

# ── 1-a：見過 owner、沒走過那座城 ⇒ 不在候選集（兩支各一格）──
func _cell_1a() -> void:
	_selftest_gate("1-a").noop()
	var sai := StrategicAiSystem.new()

	var s1 := _mk_world(Vector2i(0, 0))   # ★離城很遠 ⇒ 沒走過
	BeliefSystem.record_claim(s1, 1, 2, 1, "親見", {"tile_pos": Vector2i(11, 11), "population_est": 8.0}, 1.0, false)
	var partner: Dictionary = sai._find_trade_partner(s1, s1.teams[1])
	print("1-a-①｜商隊：對城主有 belief、沒走過那座城 ⇒ 交易對象 %s" % str(partner))
	_ok(BeliefSystem.belief_pos(s1, 1, 2) != Vector2i(-1, -1),
		"1-a-前提 ★**我對城主確實有情報**（舊版正是靠這個把城撈進來）")
	_ok(partner.is_empty(),
		"1-a-① ★**商隊那支：沒看過的城不進候選集**（樣本 1／母體 1）｜★退回 live ⇒ 它會在 ⇒ 紅")

	var s2 := _mk_world(Vector2i(0, 0), true)   # 產出隊、離城很遠
	BeliefSystem.record_claim(s2, 1, 2, 1, "親見", {"tile_pos": Vector2i(11, 11), "population_est": 8.0}, 1.0, false)
	var c2: DecisionContext = DecisionContext.gather(s2, s2.teams[1], false)
	print("1-a-②｜產出隊：同上 ⇒ shelter_host_id=%d" % c2.shelter_host_id)
	_ok(c2.shelter_host_id == -1,
		"1-a-② ★**求居那支：沒看過的城不會變成 host**（樣本 1／母體 1）")
	_cell("1-a")

# ── 1-b：走過城、沒見過 owner ⇒ 在候選集（★前一票量到的「知道得太少」那一半）──
func _cell_1b() -> void:
	_selftest_gate("1-b").noop()
	var sai := StrategicAiSystem.new()

	var s1 := _mk_world(Vector2i(5, 5))   # ★站在城上 ⇒ harvest 會寫下據點子記錄
	BeliefSystem.harvest_tile_known(s1, s1.teams[1])
	var partner: Dictionary = sai._find_trade_partner(s1, s1.teams[1])
	print("1-b-①｜商隊：走過城、對城主 belief=%s ⇒ 交易對象 %s" % [
		str(BeliefSystem.belief_pos(s1, 1, 2)), str(partner)])
	_ok(BeliefSystem.belief_pos(s1, 1, 2) == Vector2i(-1, -1),
		"1-b-前提 ★**我對城主【沒有】任何情報**（舊版正是因此把它丟掉）")
	_ok(int(partner.get("team_id", -1)) == 2 and partner.get("outpost_pos", Vector2i(-1, -1)) == Vector2i(5, 5),
		"1-b-① ★★**商隊那支：走過的城算數了**（樣本 1／母體 1）"
		+ "｜★★★舊版外圈是 `known_targets` ⇒ 這一類永遠進不了候選集")

	var s2 := _mk_world(Vector2i(5, 5), true)
	# ★`gather()` 自己【不】harvest（production 由別的路徑先 harvest）⇒ fixture 要自己補，
	#   ★★否則 store 恆空 ⇒ 這一格會拿到一個【與修法無關】的紅。
	BeliefSystem.harvest_tile_known(s2, s2.teams[1])
	var c2: DecisionContext = DecisionContext.gather(s2, s2.teams[1], false)
	print("1-b-②｜產出隊：走過城 ⇒ shelter_host_id=%d pos=%s" % [c2.shelter_host_id, str(c2.shelter_host_pos)])
	_ok(c2.shelter_host_id == 2 and c2.shelter_host_pos == Vector2i(5, 5),
		"1-b-② ★**求居那支：走過的城成為 host**（樣本 1／母體 1）")
	_cell("1-b")

# ── 1-c：兩支函式內不再 live 讀 outpost 欄位 ──
func _cell_1c_no_live_read() -> void:
	_selftest_gate("1-c").noop()
	print("\n— 1-c：零 god-view（原始碼）—")
	var sai: String = FileAccess.get_file_as_string("res://scripts/simulation/strategic_ai_system.gd")
	var body_t: String = _func_body(sai, "func _find_trade_partner(")
	_ok(body_t != "", "1-c-前提① 找得到 `_find_trade_partner`")
	var code_t: String = _strip_comments(body_t)   # ★剝註解：解釋這個病的那句話不算病
	_ok(not code_t.contains("tile.outpost_owner") and not code_t.contains("tile.outpost_level"),
		"1-c-① ★**商隊那支不再 live 讀 `tile.outpost_owner`／`outpost_level`**")
	_ok(body_t.contains("BeliefSystem.known_outposts("),
		"1-c-①b ★改讀具名介面 `known_outposts`")

	var dc: String = FileAccess.get_file_as_string("res://scripts/simulation/decision/decision_context.gd")
	var seg: String = _segment(dc, "if team.tags.has(TeamData.TAG_PRODUCE) and team.work_outpost == Vector2i(-1, -1):", 16)
	_ok(seg != "", "1-c-前提② 找得到求居那一段")
	var code_seg: String = _strip_comments(seg)
	_ok(not code_seg.contains("_t2.outpost_owner") and not code_seg.contains("_t2.outpost_level"),
		"1-c-② ★**求居那支不再 live 讀 tile 的 outpost 欄位**")
	_ok(seg.contains("BeliefSystem.known_outposts("),
		"1-c-②b ★改讀具名介面 `known_outposts`")
	_cell("1-c")

# ── 1-d：長得像卻【不是】病灶的那一支，逐字未改 ──
func _cell_1d_dont_fix_the_wrong_one() -> void:
	_selftest_gate("1-d").noop()
	print("\n— 1-d：`find_nearest_known_tile` 逐字未改（★守「別修錯東西」）—")
	var gr: String = FileAccess.get_file_as_string("res://scripts/simulation/decision/goal_resolver.gd")
	var body: String = _func_body(gr, "static func find_nearest_known_tile(")
	_ok(body != "", "1-d-前提 找得到 `find_nearest_known_tile`")
	_ok(body.contains("if t == null or (terrain != \"\" and t.terrain != terrain):"),
		"1-d ★★**它逐字未改**｜★它閘後讀的是 `t.terrain`，而**地形不會變** ⇒「當時」與「現在」同一個值"
		+ "｜★★★判準是【那個欄位會不會變】，不是【有沒有在閘後讀 live】")
	_ok(not body.contains("known_outposts"),
		"1-d-b ★**沒有被我順手「修」成讀據點知識**（它要的是地形不是據點）")
	_cell("1-d")

# ── 1-e：gather() 裡【真的是自家】的 6 處逐字未改（★用內容錨，不用行號）──
func _cell_1e_self_home_untouched() -> void:
	_selftest_gate("1-e").noop()
	print("\n— 1-e：自家據點讀取逐字未改（6 處，內容錨）—")
	var dc: String = FileAccess.get_file_as_string("res://scripts/simulation/decision/decision_context.gd")
	# ★spec 給的是行號，而行號在我這一票裡就已經漂了（我自己的編輯把後面往下推）
	#   ⇒ ★★用【內容】當錨（03_implementer 九條規矩之一）：行號會漂，這幾行的字不會。
	var anchors: Array = [
		"if _btile != null and _btile.outpost_owner == team.team_id and _btile.outpost_level > 0:",
		"if _uf.outpost_level != 0: Probe.bump(\"cansettle.false.5_already_outpost\")",
		"var _home_now := VillageEstimate.make(_home.terrain, _home.outpost_level, _home.farming_level",
		"var _home_after := VillageEstimate.make(_home.terrain, _home.outpost_level, _home.farming_level",
		"maxi(_ptile.outpost_level if _ptile != null else 1, 1), 0, team.population))",
	]
	var hit: int = 0
	for a in anchors:
		if dc.contains(a): hit += 1
		else: print("     ★沒找到錨：%s" % a.substr(0, 60))
	print("1-e｜自家錨 %d／%d 仍在" % [hit, anchors.size()])
	_ok(hit == anchors.size(),
		"1-e ★★**自家據點的讀取逐字未改**（讀 `team.tile_pos`／自家 `_home` ⇒ 合法，不是 god-view）"
		+ "｜★★★而 spec §5 自承：那份清單原本寫 8 處、實際 6 處，**另有 3 處是讀【別隊】live 值＝真違規**（已另開帳，不在本票）"
		+ "｜★「別動它」清單是【斷言】不是【豁免】")
	_cell("1-e")

# ── 1-f：世界級 ──
func _cell_1f_world() -> void:
	if OS.get_environment("BED_WORLD") == "0":
		_undecidable("1-f（世界級）",
			"兩支的候選集在真世界裡都換了一批（各印三個數）",
			"本次以 BED_WORLD=0 執行（世界級那段要跑 warring_states 10 天）",
			"BED_WORLD=1 BED_DAYS=10 GODOT_TIMEOUT=3000 單獨跑一次；貼數時標【床的 commit】")
		_cell("1-f")
		return
	_selftest_gate("1-f").noop()
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 10
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	print("\n— 1-f：世界級（warring_states days=%d seed=%d）—" % [days, seed_val])
	seed(seed_val)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json")
	var runner := SimRunner.new()
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, Vector2i(-1, -1))
	var sai := StrategicAiSystem.new()
	# ★★★【兩把尺，而第一把與迭代順序無關】（systems 裁 2026-09-18）——
	#   ★舊卷面只比【第一個回傳的 partner】，而兩版的迭代順序不同
	#     ⇒ ★★「只有舊版有 N」裡混了【順序差異】與【知識差異】，**而兩者要人做的事相反**
	#       （知識差異 ⇒ 世界真的變小，要 WHAT 裁；順序差異 ⇒ 我的尺在抖，換尺就好）。
	#   ⇒ ①**存在性**：每個觀察者「找不找得到【任何】交易對象」—— **不問是誰 ⇒ 順序改變不了它**
	#     ②**候選集合**：把兩版的【全部】合格對象各列一遍再取差集 —— **完整比較**
	var obs: int = 0
	var new_any: int = 0
	var old_any: int = 0
	var both_any: int = 0
	var neither: int = 0
	var set_only_new: int = 0
	var set_only_old: int = 0
	var set_common: int = 0
	var first_differs: int = 0
	for tid in st.teams:
		var team: TeamData = st.teams[tid]
		if team == null or team.leader_id == -1 or team.population <= 0: continue
		obs += 1
		var n: int = int(sai._find_trade_partner(st, team).get("team_id", -1))
		var o: int = int(_legacy_trade_partner(st, team).get("team_id", -1))
		if n != -1: new_any += 1
		if o != -1: old_any += 1
		if n != -1 and o != -1:
			both_any += 1
			if n != o: first_differs += 1
		if n == -1 and o == -1: neither += 1
		var sn: Array = _new_partner_set(st, team)
		var so: Array = _legacy_partner_set(st, team)
		for x in sn:
			if so.has(x): set_common += 1
			else: set_only_new += 1
		for x in so:
			if not sn.has(x): set_only_old += 1
	print("1-f-①【存在性，與順序無關】觀察者 %d 支｜新版找得到=%d／舊版找得到=%d／兩版都有=%d／兩版都沒有=%d" % [
		obs, new_any, old_any, both_any, neither])
	print("1-f-①b ★兩版都找得到、但【第一個】不同 = %d 支（★這就是舊卷面把順序差異混進去的那一塊）" % first_differs)
	print("1-f-②【候選集合，逐對象】只有新版 = %d／只有舊版 = %d／兩版都有 = %d" % [
		set_only_new, set_only_old, set_common])
	_ok(obs > 0, "1-f-母體 ★母體非 0（%d 支）" % obs)
	_ok(set_only_new + set_only_old > 0,
		"1-f ★**候選集真的換了一批**（集合層：只有新版 %d／只有舊版 %d／共有 %d）" % [
			set_only_new, set_only_old, set_common]
		+ "｜★全 0 ⇒ 兩版行為完全一樣 ⇒ 要解釋（這一票沒有改變任何事）")
	_cell("1-f")


# ★新版【全部】合格對象（把 `_find_trade_partner` 的 early-return 拿掉 ⇒ 集合而不是第一個）
func _new_partner_set(state: WorldState, trader: TeamData) -> Array:
	BeliefSystem.harvest_tile_known(state, trader)
	var out: Array = []
	var my_faction: FactionData = state.factions.get(trader.faction_id)
	for rec in BeliefSystem.known_outposts(state, trader.team_id):
		var tid: int = int(rec["owner_id"])
		if tid == -1 or tid == trader.team_id: continue
		if my_faction != null and my_faction.member_team_ids.has(tid): continue
		if state.teams.get(tid) == null: continue
		var pos: Vector2i = rec["tile_pos"]
		var tile: HexTileData = state.world.tiles.get(int(pos.x) * 1000 + int(pos.y))
		if tile == null: continue
		if not StrategicAiSystem.new()._tile_has_resident(state, tile): continue
		if not out.has(tid): out.append(tid)
	return out

# ★舊版【全部】合格對象（同樣拿掉 early-return）
func _legacy_partner_set(state: WorldState, trader: TeamData) -> Array:
	BeliefSystem.harvest_tile_known(state, trader)
	var out: Array = []
	var known_tiles: Dictionary = state.team_tile_known.get(trader.team_id, {})
	for tid in BeliefSystem.known_targets(state, trader.team_id):
		if tid == trader.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if t.faction_id != -1 and t.faction_id == trader.faction_id: continue
		for tile_id in known_tiles:
			var tile: HexTileData = state.world.tiles.get(tile_id)   # gate-ok: debug 對照基準（production 不走）
			if tile == null: continue
			if tile.outpost_owner != tid: continue
			if not StrategicAiSystem.new()._tile_has_resident(state, tile): continue
			if not out.has(tid): out.append(tid)
			break
	return out

# ★舊版 `_find_trade_partner` 的逐字複本（★只在這支床裡，當對照用；production 已不走這條）
func _legacy_trade_partner(state: WorldState, trader: TeamData) -> Dictionary:
	BeliefSystem.harvest_tile_known(state, trader)
	var known_tiles: Dictionary = state.team_tile_known.get(trader.team_id, {})
	for tid in BeliefSystem.known_targets(state, trader.team_id):
		if tid == trader.team_id: continue
		var t: TeamData = state.teams.get(tid)
		if t == null: continue
		if t.faction_id != -1 and t.faction_id == trader.faction_id: continue
		for tile_id in known_tiles:
			var tile: HexTileData = state.world.tiles.get(tile_id)   # gate-ok: debug 對照基準（production 不走）
			if tile == null: continue
			if tile.outpost_owner != tid: continue
			return { "team_id": tid, "outpost_pos": tile.tile_pos }
	return {}

# ★★★【檢查原始碼的格，必須先把註解剝掉】（2026-09-18 實測，我第一版踩了）——
#   ★我在那兩支函式裡寫了一段註解【解釋這個病】，而它逐字包含 `tile.outpost_owner`
#     ⇒ 「函式內不得出現 live 讀」那一格**被自己的解釋文字判紅**。
#   ★★這是同一族的第三次（前兩次：`src.find("func _verdict")` 命中自己那一行、
#     `MessageData.payload` 那次是欄位名錯）—— ★★★**檢查器與被檢查物在同一個檔案裡時，
#     「我寫的話」與「code 做的事」會混在一起**，而剝註解是最小的分離動作。
func _strip_comments(src: String) -> String:
	var out: String = ""
	for line in src.split("
"):
		var t: String = line.strip_edges()
		if t.begins_with("#"):
			continue
		out += line + "
"
	return out

func _func_body(src: String, header: String) -> String:
	var head: int = src.find(header)
	if head == -1: return ""
	var tail: int = src.find("\nfunc ", head + 10)
	var tail2: int = src.find("\nstatic func ", head + 10)
	if tail == -1 or (tail2 != -1 and tail2 < tail): tail = tail2
	return src.substr(head, (tail - head) if tail != -1 else src.length() - head)

func _segment(src: String, anchor: String, lines: int) -> String:
	var head: int = src.find(anchor)
	if head == -1: return ""
	var out: String = ""
	var pos: int = head
	for _i in range(lines):
		var nl: int = src.find("\n", pos)
		if nl == -1: break
		out += src.substr(pos, nl - pos + 1)
		pos = nl + 1
	return out
