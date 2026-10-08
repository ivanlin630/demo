extends SceneTree
# @bed-kind: invariant
# slice: 票 #9 地圖記憶＋地圖上的 god-view 漏（spec 2026-09-29-map-memory-and-godview-leak-HOW；裁甲 0995cbbe2：據點型別記在 belief）
#
# P3  全程移動不停（派工要求先跑）⇒ 走過再離開的每一格都在 team_tile_known[玩家]（★母體地板：size 非 0）
# P1  發現過但此刻在視野外的隊 ⇒ 地圖不得畫在它的 live 位置
# P2  belief 過期 ⇒ 那支隊不畫（絕不退回 live）
# P4  renderer 檔裡不留「explored = in_vision」與 TODO
# P7  一個畫面同時有 @／隊伍字母／據點圖示／x?／大寫／小寫／?（母體地板：每一種各至少一格）
# P7b 同一格看得到的隊＋已知據點 ⇒ 印隊伍字母
# P7c 隊伍出視野、belief 未過期 ⇒ 字母變 x? 且畫在 belief_pos（不是 live）
# P7e 隊伍字母表不含 f m p；23 支以上的代號裡也沒有
# P8  圖例含五層與三種據點圖示
# P9  每格仍是 4 字元（每一列＝縮排＋(2R+1)×4）
# P9b renderer 檔內 `outpost_` 出現 0 次（據點只經 overlay 進來）
# P10 過期由 sim 決定：claim 年齡 0.9×BELIEF_STALE_TICKS ⇒ 畫；1.1× ⇒ 不畫（renderer 不自己算過期）
# P11 失真 claim ⇒ 畫在失真位置、不畫真位置；游標處標「聽說」
# P12 子隊在外、沒回報 ⇒ 它看過的格在玩家地圖上仍是 ?
# P13 玩家隊有高偵查 ⇒ 大寫區變大（半徑跟 VisionSystem.vision_range 走；母體地板：兩個半徑不相等）
# T   每一筆已知據點都帶 type（裁甲：不寫後備圖示）
# ★修前不存在的函式用 Script.call 動態呼 ⇒ 修前紅在格上
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/map_memory_bed.gd

var _errors: int = 0
const DAYS: int = 6
const R_SCRIPT: Script = preload("res://scripts/ui/text_map_renderer.gd")


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _initialize() -> void:
	print("=== #9 地圖記憶 ===")
	_p3_full_movement()
	_render_cells()
	_static_cells()
	print("\n=== map_memory DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


# 「字母?」＝記得的隊（兩個字、第二個是 ?）——單獨一個 ? 是「沒去過」，不能算進來
static func _is_x(g: String) -> bool:
	return g.length() == 2 and g.ends_with("?") and g[0] != "?"


static func _hex(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x
	var dy: int = b.y - a.y
	return (absi(dx) + absi(dx + dy) + absi(dy)) / 2


func _world() -> WorldState:
	seed(20261008)
	var st: WorldState = MeasureBedHelper.arm_and_new()
	GameSetup.setup(st, GameSetup.load_config("res://config/warring_states.json"))
	return st


func _p3_full_movement() -> void:
	print("\n── P3 全程移動不停：走過再離開的格都記得 ──")
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var cs := PlayerCommandSystem.new()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	var keys: Array = st.world.tiles.keys()
	keys.sort()
	var visited: Dictionary = {}
	var last_pos: Vector2i = pt.tile_pos
	var legs: int = 0
	var idle_ticks: int = 0
	for _i in range(DAYS * WorldState.TICKS_PER_DAY):
		if pt.move_target == Vector2i(-1, -1) or pt.move_target == pt.tile_pos:
			var best: Vector2i = pt.tile_pos
			var bd: int = -1
			for k in keys:
				var p := Vector2i(int(k) / 1000, int(k) % 1000)
				var d: int = _hex(p, pt.tile_pos)
				if d > bd and not visited.has(int(k)):
					bd = d
					best = p
			cs.move_to(st, best)
			legs += 1
		if pt.move_target == Vector2i(-1, -1):
			idle_ticks += 1
		runner.advance_tick(st, pt.tile_pos)
		if not st.teams.has(ptid):
			break
		if pt.tile_pos != last_pos:
			visited[last_pos.x * 1000 + last_pos.y] = true
			last_pos = pt.tile_pos
	var known: Dictionary = st.team_tile_known.get(ptid, {})
	var miss: Array = []
	for k2 in visited.keys():
		if not known.has(k2):
			miss.append(Vector2i(int(k2) / 1000, int(k2) % 1000))
	print("   %d 天、%d 段路、沒有目標的 tick %d｜走過再離開的格 %d｜team_tile_known[玩家] %d 格｜走過卻沒記得 %d：%s" % [
		DAYS, legs, idle_ticks, visited.size(), known.size(), miss.size(), str(miss.slice(0, 10))])
	_check("★P3 母體地板：玩家真的一路在走（走過再離開的格 ≥ 10）", visited.size() >= 10)
	_check("★P3 段 1 前提：team_tile_known[玩家] 非空（%d）" % known.size(), known.size() > 0)
	_check("P3 全程移動：走過再離開的每一格都記得（漏 %d）" % miss.size(), miss.is_empty() and visited.size() >= 10)
	# T：每一筆已知據點都帶 type（裁甲）
	var recs: Array = BeliefSystem.known_outposts(st, ptid)
	var no_type: int = 0
	for r in recs:
		if String(r.get("type", "")) == "":
			no_type += 1
	print("   玩家已知據點 %d 筆，沒帶 type 的 %d" % [recs.size(), no_type])
	_check("★T 母體地板：走了 6 天，已知據點 ≥ 1", recs.size() >= 1)
	_check("T 每一筆已知據點都帶 type（不寫後備圖示）", no_type == 0 and recs.size() >= 1)


# ══ 地圖格的讀法：由 map_extent 推每格在字串裡的位置 ══════════════════════════════════════
static func _glyph_at(map_str: String, ext: Dictionary, pos: Vector2i) -> String:
	var c: Vector2i = ext["center"]
	var r: int = int(ext["radius"])
	var dr: int = pos.y - c.y
	var dq: int = pos.x - c.x
	if absi(dr) > r or absi(dq) > r:
		return ""
	var rows: PackedStringArray = map_str.split("\n")
	var line: String = rows[dr + r]
	var start: int = 2 * (dr + r) + (dq + r) * 4
	if start + 4 > line.length():
		return ""
	return line.substr(start, 4).replace("[", "").replace("]", "").strip_edges()


func _render(st: WorldState, ptid: int, cursor: Vector2i, vmult: float = 1.0) -> String:
	return String(R_SCRIPT.call("render", st, ptid, cursor, vmult)) if _arity("render") >= 4 \
		else String(R_SCRIPT.call("render", st, ptid, cursor))


static func _arity(fn: String) -> int:
	for m in R_SCRIPT.get_script_method_list():
		if String(m.get("name", "")) == fn:
			return (m.get("args", []) as Array).size()
	return -1


static func _claim(st: WorldState, obs: int, tgt: int, pos: Vector2i, last_tick: int, source_type: String, distorted: bool) -> void:
	var intel: Dictionary = st.team_intel.get(obs, {})
	intel[tgt] = [{"value": {"tile_pos": pos, "last_tick": last_tick, "population_est": 5.0}, "source_id": -1,
		"source_type": source_type, "tick": last_tick, "credibility": 1.0, "distorted": distorted}]
	st.team_intel[obs] = intel


func _render_cells() -> void:
	print("\n── 地圖各層（P1／P2／P7／P7b／P7c／P9／P10／P11／P12）──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	var ext: Dictionary = TextMapRenderer.map_extent(st)
	var vr: int = VisionSystem.vision_range(st, pt, 1.0)
	var ids: Array = st.teams.keys()
	ids.sort()
	var other: TeamData = null
	var other2: TeamData = null
	for k in ids:
		if int(k) != ptid and st.teams[k].leader_id != -1:
			if other == null:
				other = st.teams[k]
			elif other2 == null:
				other2 = st.teams[k]
	_check("★母體地板：有兩支別的隊", other != null and other2 != null)
	if other == null or other2 == null:
		return
	var far: Vector2i = Vector2i(-1, -1)
	var far2: Vector2i = Vector2i(-1, -1)
	var tkeys: Array = st.world.tiles.keys()
	tkeys.sort()
	for k2 in tkeys:
		var p := Vector2i(int(k2) / 1000, int(k2) % 1000)
		if _hex(p, pt.tile_pos) > vr + 3:
			if far == Vector2i(-1, -1):
				far = p
			elif far2 == Vector2i(-1, -1) and _hex(p, far) > 2:
				far2 = p
	# P1：發現過、在視野外、沒有 belief ⇒ live 位置不得畫
	other.tile_pos = far
	var disc: Array = st.team_discovered.get(ptid, [])
	if not disc.has(other.team_id):
		disc.append(other.team_id)
	st.team_discovered[ptid] = disc
	st.team_intel.get(ptid, {}).erase(other.team_id)
	st.rebuild_team_tile_index()
	var m1: String = _render(st, ptid, Vector2i(-99, -99))
	var g_far: String = _glyph_at(m1, ext, far)
	print("   P1 發現過、視野外（距 %d > 半徑 %d）、沒有 belief ⇒ live 位置那一格印「%s」" % [_hex(far, pt.tile_pos), vr, g_far])
	_check("★P1 母體地板：真的發現過、真的在視野外", disc.has(other.team_id) and _hex(far, pt.tile_pos) > vr)
	_check("P1 live 位置不畫那支隊（不是字母、不是數字）", g_far.length() == 1 and not g_far.is_valid_int() and g_far in ["?", "p", "f", "m", "P", "F", "M", "^", "#", "$"])
	# P2／P10：belief 過期 ⇒ 不畫；0.9×STALE ⇒ 畫
	var now: int = st.world.current_tick
	var stale: int = BeliefSystem.BELIEF_STALE_TICKS
	st.world.current_tick = now + stale * 2
	_claim(st, ptid, other.team_id, far2, st.world.current_tick - int(stale * 1.1), "親見", false)
	var m2: String = _render(st, ptid, Vector2i(-99, -99))
	var g2: String = _glyph_at(m2, ext, far2)
	_claim(st, ptid, other.team_id, far2, st.world.current_tick - int(stale * 0.9), "親見", false)
	var m3: String = _render(st, ptid, Vector2i(-99, -99))
	var g3: String = _glyph_at(m3, ext, far2)
	var g3_live: String = _glyph_at(m3, ext, far)
	print("   P2／P10 belief 在 %s：年齡 1.1×過期線 ⇒「%s」｜0.9× ⇒「%s」（live %s ⇒「%s」）" % [str(far2), g2, g3, str(far), g3_live])
	_check("P2 belief 過期 ⇒ 那一格不畫那支隊", not _is_x(g2))
	_check("P10／P7c 未過期 ⇒ 畫成「字母?」在 belief 位置", _is_x(g3))
	_check("P7c 同時 live 位置不畫它", not _is_x(g3_live) and not g3_live.is_valid_int())
	# P11：失真 claim ⇒ 畫在失真位置
	_claim(st, ptid, other.team_id, far2, st.world.current_tick - 10, "傳聞", true)
	var m4: String = _render(st, ptid, Vector2i(-99, -99))
	var k4: Dictionary = PlayerQueryApi.tile_knowledge(st, far2)
	var heard: bool = false
	for t in k4.get("teams", []):
		if int(t.get("id", -1)) == other.team_id and bool(t.get("heard", false)):
			heard = true
	print("   P11 失真 claim 在 %s ⇒ 那一格「%s」｜live「%s」｜游標處 聽說=%s" % [str(far2), _glyph_at(m4, ext, far2), _glyph_at(m4, ext, far), str(heard)])
	_check("P11 失真 claim ⇒ 畫在失真位置、不畫真位置", _is_x(_glyph_at(m4, ext, far2)) and not _is_x(_glyph_at(m4, ext, far)))
	_check("P11 游標處把那一筆標成聽說", heard)
	# P7／P7b：看得到的隊（旁邊一格）＋已知據點（同一格）＋記得的地形＋沒去過
	var nb: Vector2i = pt.tile_pos + Vector2i(1, 0)
	other2.tile_pos = nb
	st.rebuild_team_tile_index()
	var known: Dictionary = st.team_tile_known.get(ptid, {})
	known[nb.x * 1000 + nb.y] = {"outpost": {"owner_id": other2.team_id, "level": 1, "last_tick": st.world.current_tick, "type": "civilian"}}
	var op2: Vector2i = pt.tile_pos + Vector2i(0, 1)
	known[op2.x * 1000 + op2.y] = {"outpost": {"owner_id": other2.team_id, "level": 1, "last_tick": st.world.current_tick, "type": "military"}}
	var rem: Vector2i = far + Vector2i(1, 0) if st.world.tiles.has((far.x + 1) * 1000 + far.y) else far + Vector2i(-1, 0)
	known[rem.x * 1000 + rem.y] = true
	st.team_tile_known[ptid] = known
	var m5: String = _render(st, ptid, Vector2i(-99, -99))
	var g_nb: String = _glyph_at(m5, ext, nb)
	var g_op: String = _glyph_at(m5, ext, op2)
	var g_rem: String = _glyph_at(m5, ext, rem)
	print("   P7b 旁邊一格（看得到的隊＋已知據點）⇒「%s」｜已知營 %s ⇒「%s」｜記得的格 ⇒「%s」" % [g_nb, str(op2), g_op, g_rem])
	_check("P7b 同格看得到的隊＋已知據點 ⇒ 印隊伍字母", g_nb.length() == 1 and g_nb >= "a" and g_nb <= "z")
	_check("P7 已知營畫 #（型別來自 belief）", g_op == "#")
	_check("P7 記得的格印小寫地形", g_rem.length() == 1 and g_rem in ["p", "f", "m"])
	# ★逐層一列（名稱, 這一幀有沒有）——印出來給人讀，判決看第二欄
	var kinds: Array = [
		["@", m5.contains("@")],
		["?", m5.contains("?")],
		["隊伍字母", g_nb >= "a" and g_nb <= "z"],
		["據點圖示", g_op == "#"],
		["字母?", _is_x(_glyph_at(m5, ext, far2))],
		["大寫地形", RegEx.create_from_string("[PFM] ").search(m5) != null],
		["小寫地形", g_rem in ["p", "f", "m"]],
	]
	print("   P7 這一幀各層：%s" % str(kinds))
	_check("P7 五層同一幀都分得開（每一種至少一格）", kinds.all(func(x): return bool(x[1])))
	# P9：每格 4 字元
	var c: Vector2i = ext["center"]
	var rr: int = int(ext["radius"])
	var bad_w: int = 0
	var rows5: PackedStringArray = m5.split("\n")
	for i5 in range(rows5.size()):
		if rows5[i5].length() != 2 * i5 + (2 * rr + 1) * 4:
			bad_w += 1
	_check("P9 每一列＝縮排＋(2R+1)×4（格寬不變；不合 %d 列）" % bad_w, bad_w == 0)
	# P12：子隊在外沒回報 ⇒ 它看過的格對玩家仍是 ?
	var sub_known: Dictionary = {}
	var hidden: Vector2i = far2 + Vector2i(0, 1) if st.world.tiles.has(far2.x * 1000 + far2.y + 1) else far2
	sub_known[hidden.x * 1000 + hidden.y] = true
	st.team_tile_known[other2.team_id] = sub_known
	other2.parent_team_id = ptid
	known.erase(hidden.x * 1000 + hidden.y)
	var m6: String = _render(st, ptid, Vector2i(-99, -99))
	print("   P12 子隊看過 %s（沒回報）⇒ 玩家地圖「%s」" % [str(hidden), _glyph_at(m6, ext, hidden)])
	_check("P12 子隊沒回報 ⇒ 那一格仍是 ?", _glyph_at(m6, ext, hidden) == "?" or _is_x(_glyph_at(m6, ext, hidden)))
	# P13：高偵查 ⇒ 大寫區變大
	var leader: PersonData = st.persons.get(pt.leader_id)
	var base_r: int = VisionSystem.vision_range(st, pt, 1.0)
	var m7a: String = _render(st, ptid, Vector2i(-99, -99))
	leader.skills["偵查"] = 1.0
	for mid in pt.named_members:
		var pp: PersonData = st.persons.get(mid)
		if pp != null:
			pp.skills["偵查"] = 1.0
	var high_r: int = VisionSystem.vision_range(st, pt, 1.0)
	var m7b: String = _render(st, ptid, Vector2i(-99, -99))
	var up_a: int = RegEx.create_from_string("[PFM]").search_all(m7a).size()
	var up_b: int = RegEx.create_from_string("[PFM]").search_all(m7b).size()
	print("   P13 vision_range 基底 %d ⇒ 大寫 %d 格｜高偵查 %d ⇒ 大寫 %d 格" % [base_r, up_a, high_r, up_b])
	_check("★P13 母體地板：兩個半徑真的不同", high_r > base_r)
	_check("P13 高偵查 ⇒ 大寫區變大", up_b > up_a)


func _static_cells() -> void:
	print("\n── 靜態格（P4／P7e／P8／P9b）──")
	var src: String = FileAccess.get_file_as_string("res://scripts/ui/text_map_renderer.gd")
	_check("P4 renderer 不留「explored = in_vision」", not src.contains("explored: bool = in_vision"))
	_check("P4 renderer 不留 TODO", not src.contains("TODO"))
	_check("P9b renderer 檔內 `outpost_` 出現 0 次（%d）" % src.count("outpost_"), src.count("outpost_") == 0)
	var cm: Dictionary = R_SCRIPT.get_script_constant_map()
	var letters: String = String(cm.get("TEAM_LETTERS", ""))
	print("   隊伍字母表：「%s」（%d 個）" % [letters, letters.length()])
	_check("P7e 隊伍字母表不含 f m p、23 個", letters.length() == 23 and not letters.contains("f") and not letters.contains("m") and not letters.contains("p"))
	var legend: String = String(cm.get("LEGEND", ""))
	print("   圖例：「%s」" % legend)
	var need: Array = ["@", "a", "^", "#", "$", "a?", "P", "p", "?"]
	var miss: Array = need.filter(func(x): return not legend.contains(String(x)))
	_check("P8 圖例含五層與三種據點圖示（缺 %s）" % str(miss), legend != "" and miss.is_empty())
