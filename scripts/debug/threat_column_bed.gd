extends SceneTree
# @bed-kind: invariant
# ══ 威脅欄：附身隊【所知】的最急一句（＋頂列無值主張預設）══════════════════════════════
# spec：`docs/superpowers/specs/2026-10-06-threat-column-says-what-the-team-knows-HOW.md` §4
#
# ★★★本票最重要的一條是 H0：「沒有寫入者」與「寫入者判定沒有威脅」**不再同形**
#   ⇒ 寫入者（`PlayerApiMapper.map_threat_line`）永遠帶鍵；讀者（`text_ui_main.build_regions`）用 `has()` 判
#
# 格：P1 H0 三（四）態｜P2 god-view 對照（兩個方向）｜P3 優先序｜P4 N 從 vision_range 推導｜
#     P5 ②③一個迴圈（反向掃，母體印出來）｜P6 寬度｜P7 失敗出口｜P8 H0′ 頂列無值主張（含反向：真 0 天糧照印）
# ★④（勢力交戰）不做：狀態不存在 —— 理由寫在 `map_threat_line` 上方

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P1", "P2", "P3", "P4", "P5", "P6", "P7", "P8"]


func _initialize() -> void:
	print("=== threat_column：威脅欄說附身隊所知 ===")
	_run()


func _run() -> void:
	await _p1_reader_three_states()
	_p2_godview_both_directions()
	_p3_priority()
	_p4_n_from_vision_range()
	_p5_one_loop()
	_p6_width()
	_p7_failure_exit()
	await _p8_no_value_claims_without_team()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)],
		missing.is_empty())
	print("\n=== threat_column DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _mk_world() -> WorldState:
	seed(1337)
	var ws := WorldState.new()
	GameSetup.setup(ws, GameSetup.load_config("res://config/default.json"))
	return ws


func _ptid(ws: WorldState) -> int:
	return ws.persons[ws.player_id].team_id


# 讓附身隊**知道**某隊在某格（belief 寫入，與真值無關）
func _tell(ws: WorldState, obs: int, tgt: int, pos: Vector2i) -> void:
	BeliefSystem.record_claim(ws, obs, tgt, obs, "親見", {"tile_pos": pos, "population_est": 5.0}, 1.0, false)


# 讓附身隊**不知道**某隊（清掉它的 belief）
func _forget(ws: WorldState, obs: int, tgt: int) -> void:
	var intel: Dictionary = ws.team_intel.get(obs, {})
	intel.erase(tgt)


# 找一支不是附身隊、也不是野獸的隊
func _other_team(ws: WorldState, ptid: int) -> int:
	var ids: Array = ws.teams.keys()
	ids.sort()
	for k in ids:
		var t: TeamData = ws.teams[k]
		if int(k) != ptid and t.beast_kind == "":
			return int(k)
	return -1


func _n(ws: WorldState, pt: TeamData) -> int:
	return VisionSystem.vision_range(ws, pt, DayNightSystem.new().get_vision_mult(ws))


# ══ P1 H0：讀者把「沒有寫入者」與「寫入者說沒有」分開 ═══════════════════════════════
func _reader_threat(node, snap: Dictionary) -> String:
	node._cached_snapshot = snap
	return String((node.build_regions("待執行 0 道")["top"] as Dictionary).get("threat", "?"))


func _p1_reader_three_states() -> void:
	print("\n── P1 H0：三種狀態各自印出不同的字 ──")
	seed(1337)
	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	var a: String = _reader_threat(node, {})
	var b: String = _reader_threat(node, {"threat_line": "（無）"})
	var c: String = _reader_threat(node, {"threat_line": "Team7 敵對，最後所知 2 格"})
	# ★第四態：鍵在而值是空字串 —— 寫入者今天不會這樣寫，但它是 `has()` 與 `== ""` **唯一**分得開的輸入
	#   ⇒ 負對照（讀者改回 `== ""`）就紅在這一格
	var d: String = _reader_threat(node, {"threat_line": ""})
	print("   鍵不存在 ⇒「%s」｜寫入者明示（無）⇒「%s」｜一句 ⇒「%s」｜鍵在而空 ⇒「%s」" % [a, b, c, d])
	_check("★★★P1 鍵不存在 ⇒「尚未提供」", a == "尚未提供")
	_check("★★★P1 寫入者明示 ⇒ 照印「（無）」", b == "（無）")
	_check("★★★P1 寫入者一句 ⇒ 照印", c == "Team7 敵對，最後所知 2 格")
	_check("★★★P1 三態互不同形", a != b and b != c and a != c)
	_check("★★★★P1 鍵在而空 ⇒ **不得**印「尚未提供」（`has()` 判；`== \"\"` 判會在這裡同形）", d != "尚未提供")
	node.queue_free()
	await process_frame
	_cells_ran.append("P1")


# ══ P2 god-view 對照（兩個方向）═══════════════════════════════════════════════════
func _p2_godview_both_directions() -> void:
	print("\n── P2 真值有敵隊在 1 格、而附身隊不知道 ⇒ 必印（無）；讓它知道 ⇒ 必印那一句 ──")
	var ws: WorldState = _mk_world()
	var ptid: int = _ptid(ws)
	var pt: TeamData = ws.teams[ptid]
	var g: int = _other_team(ws, ptid)
	var gt: TeamData = ws.teams[g]
	gt.tile_pos = pt.tile_pos + Vector2i(1, 0)
	ws.player_hostile_teams.append(g)
	_forget(ws, ptid, g)
	var n: int = _n(ws, pt)
	var true_d: int = PlayerApiMapper._hex_d(pt.tile_pos, gt.tile_pos)
	print("   Team%d 真值距離 %d 格｜N ＝ %d｜附身隊有它的 belief ＝ %s" % [g, true_d, n,
		str(BeliefSystem.has_belief(ws, ptid, g))])
	_check("★★母體地板：真值那支敵隊真的在 ≤ N 格（%d ≤ %d）" % [true_d, n], true_d <= n)
	_check("★母體地板：附身隊真的沒有它的 belief", not BeliefSystem.has_belief(ws, ptid, g))
	var line0: String = PlayerApiMapper.map_threat_line(ws)
	print("   不知道 ⇒「%s」" % line0)
	_check("★★★★P2 不知道 ⇒ 不得提到 Team%d（%s）" % [g, line0], not line0.contains("Team%d " % g))
	_check("★★★★P2 不知道 ⇒ 必印「（無）」", line0 == "（無）")
	# ★★★反向：同一佈置讓 belief 有它 ⇒ 必印那一句（否則上面那條恆真）
	_tell(ws, ptid, g, gt.tile_pos)
	var line1: String = PlayerApiMapper.map_threat_line(ws)
	print("   知道 ⇒「%s」" % line1)
	_check("★★★★P2【反向】知道 ⇒ 必印「Team%d 敵對，最後所知 1 格」" % g,
		line1 == "Team%d 敵對，最後所知 1 格" % g)
	_cells_ran.append("P2")


# ══ P3 優先序 ════════════════════════════════════════════════════════════════════
func _p3_priority() -> void:
	print("\n── P3 優先序：②先於③、①先於② ──")
	var ws: WorldState = _mk_world()
	var ptid: int = _ptid(ws)
	var pt: TeamData = ws.teams[ptid]
	var bid: int = BeastSystem.new().build_beast_team(ws, "boar", pt.tile_pos + Vector2i(0, 1))
	_tell(ws, ptid, bid, pt.tile_pos + Vector2i(0, 1))
	var only_beast: String = PlayerApiMapper.map_threat_line(ws)
	print("   只有③ ⇒「%s」" % only_beast)
	_check("★母體地板：只有野獸時印③（含「野豬」）", only_beast.contains("野豬"))
	var g: int = _other_team(ws, ptid)
	ws.player_hostile_teams.append(g)
	_tell(ws, ptid, g, pt.tile_pos + Vector2i(2, 0))
	var both: String = PlayerApiMapper.map_threat_line(ws)
	print("   ②＋③ ⇒「%s」" % both)
	_check("★★★P3 ②＋③ ⇒ 印②（敵隊先於野獸，即使野獸更近）", both.begins_with("Team%d 敵對" % g))
	ws.encounter_active = true
	ws.encounter_attacker_id = ptid
	ws.encounter_defender_id = bid
	var fight: String = PlayerApiMapper.map_threat_line(ws)
	print("   ①＋② ⇒「%s」" % fight)
	_check("★★★P3 ①＋② ⇒ 印①「交戰中：野豬」", fight == "交戰中：野豬")
	# ★①的判準是「我是不是這場戰的一方」：別人的戰不算
	ws.encounter_attacker_id = g
	ws.encounter_defender_id = bid
	var others: String = PlayerApiMapper.map_threat_line(ws)
	print("   別人的戰 ⇒「%s」" % others)
	_check("★★P3【反向】不是戰的一方 ⇒ 不印①", not others.begins_with("交戰中"))
	_cells_ran.append("P3")


# ══ P4 N 從 vision_range 推導（晝夜改變 N ⇒ 同一距離的敵隊進出那一句）═════════════════
func _p4_n_from_vision_range() -> void:
	print("\n── P4 N 不寫死：白天看得到、夜晚看不到同一距離的敵隊 ──")
	var ws: WorldState = _mk_world()
	var ptid: int = _ptid(ws)
	var pt: TeamData = ws.teams[ptid]
	var dn := DayNightSystem.new()
	var day_tick: int = -1
	var night_tick: int = -1
	for h in range(WorldState.TICKS_PER_DAY):
		ws.world.current_tick = h
		var per: String = dn.get_time_period(ws)
		if per == "day" and day_tick == -1: day_tick = h
		if per == "night" and night_tick == -1: night_tick = h
	ws.world.current_tick = day_tick
	var n_day: int = _n(ws, pt)
	ws.world.current_tick = night_tick
	var n_night: int = _n(ws, pt)
	print("   白天 tick %d ⇒ N＝%d｜夜晚 tick %d ⇒ N＝%d" % [day_tick, n_day, night_tick, n_night])
	_check("★母體地板：夜晚的 N 真的比白天小（%d < %d）" % [n_night, n_day], n_night < n_day)
	var g: int = _other_team(ws, ptid)
	ws.player_hostile_teams.append(g)
	ws.world.current_tick = day_tick
	_tell(ws, ptid, g, pt.tile_pos + Vector2i(n_day, 0))
	var at_day: String = PlayerApiMapper.map_threat_line(ws)
	ws.world.current_tick = night_tick
	var at_night: String = PlayerApiMapper.map_threat_line(ws)
	print("   距離 %d 格：白天 ⇒「%s」｜夜晚 ⇒「%s」" % [n_day, at_day, at_night])
	_check("★★★P4 白天（N＝%d）⇒ 那一句在" % n_day, at_day.begins_with("Team%d 敵對" % g))
	_check("★★★P4 夜晚（N＝%d）⇒ 那一句不在" % n_night, at_night == "（無）")
	_cells_ran.append("P4")


# ══ P5 ②③一個迴圈（反向掃，母體印出來）══════════════════════════════════════════════
static func _func_body(text: String, fname: String) -> String:
	var ls: PackedStringArray = text.split("\n")
	var out: PackedStringArray = []
	var inside: bool = false
	for l in ls:
		if l.begins_with("static func " + fname + "(") or l.begins_with("func " + fname + "("):
			inside = true
			continue
		if inside and (l.begins_with("static func ") or l.begins_with("func ") or l.begins_with("const ")):
			break
		if inside:
			out.append(l)
	return "\n".join(out)


static func _code_hits(body: String, needle: String) -> int:
	var n: int = 0
	for l in body.split("\n"):
		var code: String = l.split("#")[0]
		if code.contains(needle):
			n += 1
	return n


func _p5_one_loop() -> void:
	print("\n── P5 ②③ 是同一條 best_estimate 迴圈 ──")
	var text: String = FileAccess.get_file_as_string("res://scripts/simulation/player_api_mapper.gd")
	var body: String = _func_body(text, "map_threat_line")
	var body_lines: int = body.split("\n").size()
	_check("★母體地板：切到 map_threat_line 的函式體（%d 行）" % body_lines, body_lines > 20)
	var be: int = _code_hits(body, "best_estimate(")
	print("   函式體內呼叫 best_estimate 的非註解行 ＝ %d" % be)
	_check("★★★P5 產生者裡呼叫 best_estimate 的地方 ＝ 1", be == 1)
	# ★反向掃：全 scripts/simulation 與 scripts/ui 裡**寫** "threat_line" 鍵的地方（母體印出來）
	var writers: Array = []
	for dir_path in ["res://scripts/simulation", "res://scripts/ui"]:
		var dir := DirAccess.open(dir_path)
		for f in dir.get_files():
			if not String(f).ends_with(".gd"):
				continue
			var t: String = FileAccess.get_file_as_string(dir_path + "/" + String(f))
			var i: int = 0
			for l in t.split("\n"):
				i += 1
				var code: String = l.split("#")[0]
				if code.contains("[\"threat_line\"] =") or code.contains("\"threat_line\":"):
					writers.append("%s:%d" % [f, i])
	print("   寫 threat_line 鍵的地方（母體）＝ %s" % str(writers))
	_check("★★P5 反向掃：寫那個鍵的地方都在 mapper／query 組裝（%d 處）" % writers.size(),
		writers.size() >= 1 and writers.all(func(w): return String(w).begins_with("player_api_mapper.gd") or String(w).begins_with("player_query_api.gd")))
	# ★反向對照：同一個計數器在合成兩次呼叫的字串上必須回 2
	_check("★★【反向對照】合成兩次呼叫 ⇒ 計數 2",
		_code_hits("\tvar a = BeliefSystem.best_estimate(s, 1, 2)\n\tvar b = BeliefSystem.best_estimate(s, 1, 3)\n\t# best_estimate( 註解不算", "best_estimate(") == 2)
	_cells_ran.append("P5")


# ══ P6 寬度 ══════════════════════════════════════════════════════════════════════
func _p6_width() -> void:
	print("\n── P6 最長那一句在頂列被 clip 而不撐破 COLS ──")
	var longest: String = "Team99999 敵對，最後所知 99 格"
	var row: String = TextUiView.top_row({"clock": "999 天 23:59", "team_name": "Team99999", "pop": "9999",
		"home": "(999,999)", "food": "999.9 天", "threat": longest, "pending": "99 道"})
	var w: int = TextUiLayout.display_width(row)
	print("   %s（display width %d／COLS %d）" % [row, w, TextUiLayout.COLS])
	_check("★★P6 頂列 ≤ COLS（%d）" % w, w <= TextUiLayout.COLS)
	_cells_ran.append("P6")


# ══ P7 失敗出口 ═══════════════════════════════════════════════════════════════════
func _p7_failure_exit() -> void:
	print("\n── P7 snapshot 走失敗出口時 threat_line 有定義 ──")
	var ws: WorldState = _mk_world()
	var ptid: int = _ptid(ws)
	var pt: TeamData = ws.teams[ptid]
	ws.remove_member(pt, ws.player_id, false)
	ws.persons.erase(ws.player_id)
	var r: Dictionary = PlayerQueryApi.new().get_player_snapshot(ws, {})
	var snap: Dictionary = (r.get("data", {}) as Dictionary).get("snapshot", {})
	print("   ok=%s code=%s｜snapshot 鍵 ＝ %s｜threat_line ＝「%s」" % [str(r.get("ok")), str(r.get("code")),
		str(snap.keys()), str(snap.get("threat_line", "<不存在>"))])
	_check("★母體地板：真的走失敗出口（ok ＝ false）", not bool(r.get("ok", true)))
	_check("★★★P7 失敗出口也帶 threat_line 鍵", snap.has("threat_line"))
	_check("★★★P7 而它是佔位符「—」（附身者沒有隊 ＝ 不知道）", String(snap.get("threat_line", "")) == "—")
	_cells_ran.append("P7")


# ══ P8 H0′：附身者沒有隊 ⇒ 頂列無值主張；★反向：有隊而真 0 天糧 ⇒ 照印 ══════════════════
func _top_row_after(setup: Callable) -> Array:
	seed(1337)
	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	setup.call(node._bridge.get_state())
	node._refresh()
	var top: String = String(String(node._screen_label.text).split("\n")[0])
	var ct_empty: bool = (node._cached_snapshot.get("controlled_team", {}) as Dictionary).is_empty()
	node.queue_free()
	await process_frame
	return [top, ct_empty]


func _p8_no_value_claims_without_team() -> void:
	print("\n── P8 附身者沒有隊 ⇒ 家／糧撐／威脅印「—」；有隊而 0 天糧 ⇒ 照印 ──")
	var dead: Array = await _top_row_after(func(ws: WorldState) -> void:
		var pt: TeamData = ws.teams[ws.persons[ws.player_id].team_id]
		ws.remove_member(pt, ws.player_id, false)
		ws.persons.erase(ws.player_id))
	var top0: String = String(dead[0])
	print("   無隊：%s" % top0)
	_check("★★母體地板：render 那一刻 `ct.is_empty()` 真的為真", bool(dead[1]))
	for bad in ["糧撐 0.0 天", "家：（無）", "威脅：（無）"]:
		_check("★★★P8 無隊 ⇒ 頂列**不得**出現「%s」" % bad, not top0.contains(bad))
	for good in ["家：—", "糧撐 —", "威脅：—"]:
		_check("★★★P8 無隊 ⇒ 頂列印佔位符「%s」" % good, top0.contains(good))
	var starving: Array = await _top_row_after(func(ws: WorldState) -> void:
		var pt: TeamData = ws.teams[ws.persons[ws.player_id].team_id]
		ResourceBank.set_amt(pt, "food", 0.0, "bed_fixture"))
	var top1: String = String(starving[0])
	print("   有隊而 0 天糧：%s" % top1)
	_check("★母體地板：這一屏真的有隊（ct 非空）", not bool(starving[1]))
	_check("★★★★P8【反向】有隊而真的 0 天糧 ⇒ **必須**印「糧撐 0.0 天」（真警報不准被吃掉）",
		top1.contains("糧撐 0.0 天"))
	_cells_ran.append("P8")
