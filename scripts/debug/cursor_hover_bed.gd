extends SceneTree
# @bed-kind: acceptance
# slice: 游標即選中（spec 2026-10-14-cursor-hover-shows-known-detail-HOW：側欄明細跟游標走、格脈絡在來源過知識閘）
# ★格：
#   C1  （修前紅）管道送 w、不送 enter ⇒ 側欄「游標處明細: (q,r)」座標＝_cursor
#   C2  游標移到沒去過的格 ⇒「沒去過」；記得的格 ⇒ 地形＋「糧量：未記錄」；視野內 ⇒ 糧量數字（三態都從游標移動得到）
#   C3  游標移到一格有已知隊伍 ⇒ 明細列出該隊；同一格頂部「游標處」一行與側欄明細的隊伍集合相同（同源）
#   C4  主畫面按 Enter ⇒ 程式仍在、畫面不變（結果行亦不變）；鍵列無「Enter」
#   C5  （修前紅）remembered 格零真值：附身隊走過 X 後離開、之後一支附身隊沒見過的隊被放上 X
#       ⇒ 側欄不列它；payload 層 location_context.occupants 不含它、visibility_state＝remembered、無 food
#   C5b 陰性對照：unvisited 格、belief 在那格沒有隊、真值放一支隊 ⇒ occupants 空、visibility_state＝hidden
#   C5c visible 格 ⇒ 真值隊列出、food 有值（閘沒有把看得見的也擋掉）
#   PERF 隊數最多的世界（default.json）量一次游標移動的單幀成本（只印，不判；寫進交件信）
# 負對照（交件信列）：明細讀只在 Enter 時更新的變數 ⇒ C1 紅｜快照請求不送游標 ⇒ C3 紅｜來源拿掉知識閘 ⇒ C5 紅

const EXPECTED: Array = ["C1", "C2", "C3", "C4", "C5", "C5b", "C5c", "PERF"]
var _errors: int = 0
var _present: Dictionary = {}

func _initialize() -> void:
	print("=== cursor_hover：游標即選中＋格脈絡知識閘 ===")
	var node = await _make_ui()
	_c1(node)
	_c2(node)
	_c3(node)
	await _c4(node)
	_c5(node)
	_perf(node)
	get_root().remove_child(node)
	node.free()
	await process_frame
	var miss: Array = []
	for c in EXPECTED:
		if not _present.has(c):
			miss.append(c)
	if not miss.is_empty():
		_check("到場點名缺 %s" % str(miss), false)
	print("=== cursor_hover DONE === 到場 %d／%d errors: %d" % [_present.size(), EXPECTED.size(), _errors])
	quit(1 if _errors > 0 else 0)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

func _make_ui() -> Node:
	seed(20261014)
	var scene: PackedScene = load("res://scenes/TextUI.tscn")
	var node = scene.instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	return node

func _key(node, key: int) -> void:
	var ev := InputEventKey.new()
	ev.keycode = key
	ev.pressed = true
	node._input(ev)

# 游標走到 target：只按 WASD（真的鍵盤路徑；_move_cursor 每一步都 _refresh）
#   ★地圖有缺角（is_valid_tile 擋）⇒ 先在有效格上用 WASD 四向做 BFS 找鍵序，再逐鍵按
const _STEPS: Array = [[KEY_W, Vector2i(0, -1)], [KEY_S, Vector2i(0, 1)], [KEY_A, Vector2i(-1, 0)], [KEY_D, Vector2i(1, 0)]]
func _walk(node, target: Vector2i) -> void:
	var start: Vector2i = node._cursor
	var prev: Dictionary = {start: null}
	var q: Array = [start]
	while not q.is_empty() and not prev.has(target):
		var c: Vector2i = q.pop_front()
		for st in _STEPS:
			var n: Vector2i = c + (st[1] as Vector2i)
			if prev.has(n) or not node._bridge.is_valid_tile(n.x, n.y):
				continue
			prev[n] = [c, st[0]]
			q.append(n)
	if not prev.has(target):
		_check("走得到 %s（從 %s）" % [str(target), str(start)], false)
		return
	var keys: Array = []
	var at: Vector2i = target
	while prev[at] != null:
		keys.push_front(prev[at][1])
		at = prev[at][0]
	for k in keys:
		_key(node, k)
	if node._cursor != target:
		_check("游標按鍵後停在 %s（要 %s）" % [str(node._cursor), str(target)], false)

static func _hex(a: Vector2i, b: Vector2i) -> int:
	return PlayerQueryApi._hex(a, b)

func _st(node) -> WorldState:
	return node._bridge.get_state()

func _vr(node) -> int:
	var st: WorldState = _st(node)
	return VisionSystem.vision_range(st, st.teams[st.get_player_team_id()], node._bridge.get_vision_mult())

# 側欄明細區塊（標頭那行起，到下一條分隔線或空行）
static func _detail(side: String) -> Array:
	var out: Array = []
	var on: bool = false
	for l in side.split("\n"):
		if l.begins_with(TextUiMain.HOVER_DETAIL_HEAD):
			on = true
			out.append(l)
			continue
		if on:
			if l.strip_edges() == "" or l.begins_with("────"):
				break
			out.append(l)
	return out

static func _team_ids(s: String) -> Array:
	var re := RegEx.create_from_string("Team([0-9]+)")
	var out: Array = []
	for m in re.search_all(s):
		var id: int = int(m.get_string(1))
		if not out.has(id):
			out.append(id)
	out.sort()
	return out

func _side(node) -> String:
	return String(node._state_label.text)

func _top(node) -> String:
	for l in String(node._screen_label.text).split("\n"):
		if l.contains("游標處 ("):
			return l
	return ""

func _lc(node) -> Dictionary:
	return node._cached_snapshot.get("location_context", {})

# 走過 x 再回來：附身隊真的站上去、收一次腳下記憶（BeliefSystem.harvest_tile_known 同一支）
func _visit(node, x: Vector2i) -> void:
	var st: WorldState = _st(node)
	var pt: TeamData = st.teams[st.get_player_team_id()]
	var home: Vector2i = pt.tile_pos
	pt.tile_pos = x
	BeliefSystem.harvest_tile_known(st, pt)
	pt.tile_pos = home

# 離家 d 格、在圖上、沒記憶的格
func _tile_at(node, dmin: int, need_unknown: bool) -> Vector2i:
	var st: WorldState = _st(node)
	var ptid: int = st.get_player_team_id()
	var home: Vector2i = st.teams[ptid].tile_pos
	var known: Dictionary = st.team_tile_known.get(ptid, {})
	var keys: Array = st.world.tiles.keys()
	keys.sort()
	for k in keys:
		var t: HexTileData = st.world.tiles[k]
		if _hex(t.tile_pos, home) < dmin or _hex(t.tile_pos, home) > dmin + 2:
			continue
		if need_unknown and known.has(k):
			continue
		if not PlayerQueryApi.tile_knowledge(st, t.tile_pos, node._bridge.get_vision_mult()).get("teams", []).is_empty():
			continue
		return t.tile_pos
	return Vector2i(-1, -1)

# 一支附身隊對它沒有任何 claim 的活隊（belief 不可能把它放在任何格）
func _stranger(node, exclude: Array) -> int:
	var st: WorldState = _st(node)
	var ptid: int = st.get_player_team_id()
	var ids: Array = st.teams.keys()
	ids.sort()
	for tid in ids:
		if int(tid) == ptid or exclude.has(int(tid)) or not st.is_live_team(int(tid)):
			continue
		if BeliefSystem.best_claim(st, ptid, int(tid)).is_empty():
			return int(tid)
	return -1


# ── C1 ───────────────────────────────────────────────────────────────────────
func _c1(node) -> void:
	print("\n── C1 送 w、不送 enter ⇒ 明細座標＝游標 ──")
	var c0: Vector2i = node._cursor
	_key(node, KEY_W)
	var d: Array = _detail(_side(node))
	var want: String = TextUiMain.HOVER_DETAIL_HEAD + "(%d,%d)" % [node._cursor.x, node._cursor.y]
	print("   游標 %s → %s｜明細首行「%s」" % [str(c0), str(node._cursor), str(d[0]) if not d.is_empty() else "（沒有明細）"])
	_check("C1 母體地板：游標真的動了", node._cursor != c0)
	_check("C1 明細首行座標＝游標「%s」" % want, not d.is_empty() and String(d[0]).begins_with(want))
	_present["C1"] = true


# ── C2 ───────────────────────────────────────────────────────────────────────
func _c2(node) -> void:
	print("\n── C2 三態都從游標移動得到 ──")
	var st: WorldState = _st(node)
	var home: Vector2i = st.teams[st.get_player_team_id()].tile_pos
	var vr: int = _vr(node)
	var far: Vector2i = _tile_at(node, vr + 3, true)
	# 記得的格：另找一格（離「沒去過」那格超過視野——走過時腳下視野會把鄰格也記住），走過再回來
	var mem: Vector2i = Vector2i(-1, -1)
	var cands: Array = []
	for k in st.world.tiles:
		var t: HexTileData = st.world.tiles[k]
		var dd: int = _hex(t.tile_pos, home)
		if dd >= vr + 3 and dd <= vr + 5 and _hex(t.tile_pos, far) > vr + 2 and not st.team_tile_known.get(st.get_player_team_id(), {}).has(k):
			cands.append(t.tile_pos)
	cands.sort()
	mem = cands[0] if not cands.is_empty() else Vector2i(-1, -1)
	_check("C2 母體地板：找得到沒去過的格 %s 與另一格 %s" % [str(far), str(mem)], far != Vector2i(-1, -1) and mem != Vector2i(-1, -1))
	_visit(node, mem)
	_walk(node, far)
	var d1: Array = _detail(_side(node))
	_walk(node, mem)
	var d2: Array = _detail(_side(node))
	_walk(node, home)
	var d3: Array = _detail(_side(node))
	print("   沒去過 %s：%s\n   記得 %s：%s\n   腳下 %s：%s" % [str(far), str(d1), str(mem), str(d2), str(home), str(d3)])
	_check("C2 沒去過 ⇒「沒去過」", not d1.is_empty() and String(d1[0]).contains("沒去過"))
	_check("C2 記得的格 ⇒ 地形＋「糧量：未記錄」", d2.size() >= 2 and not String(d2[0]).contains("沒去過") and String(d2[1]).contains("糧量：未記錄"))
	_check("C2 視野內 ⇒ 糧量數字", d3.size() >= 2 and RegEx.create_from_string("食:[0-9]").search(String(d3[1])) != null)
	_present["C2"] = true


# ── C3 ───────────────────────────────────────────────────────────────────────
func _c3(node) -> void:
	print("\n── C3 有已知隊伍的格：明細列出、頂部一行同一組隊 ──")
	var st: WorldState = _st(node)
	var ptid: int = st.get_player_team_id()
	var home: Vector2i = st.teams[ptid].tile_pos
	# 一支別的隊放到家旁一格（視野內）⇒ 看得到；同一格再放一支「記得在那裡」的隊（belief 記錄，不在真值那格）
	var x: Vector2i = home + Vector2i(1, 0) if _st(node).world.tiles.has((home.x + 1) * 1000 + home.y) else home + Vector2i(-1, 0)
	var a: int = _stranger(node, [])
	st.teams[a].tile_pos = x
	var b: int = _stranger(node, [a])
	BeliefSystem.record_claim(st, ptid, b, ptid, "親見", {"tile_pos": x, "last_tick": st.world.current_tick}, 1.0, false)
	var far: Vector2i = _tile_at(node, _vr(node) + 3, true)
	st.teams[b].tile_pos = far
	_walk(node, x)
	var top_ids: Array = _team_ids(_top(node))
	var det: Array = _detail(_side(node))
	var det_ids: Array = _team_ids("\n".join(PackedStringArray(det)))
	print("   格 %s｜看得到 Team%d、記得 Team%d｜頂部「%s」\n   明細 %s" % [str(x), a, b, _top(node), str(det)])
	_check("C3 明細列出看得到的 Team%d" % a, det_ids.has(a))
	_check("C3 明細列出記得在那格的 Team%d" % b, det_ids.has(b))
	_check("C3 頂部與明細隊伍集合相同（頂部 %s／明細 %s）" % [str(top_ids), str(det_ids)], top_ids == det_ids and not top_ids.is_empty())
	_present["C3"] = true


# ── C4 ───────────────────────────────────────────────────────────────────────
func _c4(node) -> void:
	print("\n── C4 主畫面 Enter 不再綁 ──")
	var before: String = String(node._screen_label.text)
	var fb0: String = String(node._feedback_line.text)
	_key(node, KEY_ENTER)
	await process_frame
	var after: String = String(node._screen_label.text)
	var keys: String = node._keymap_now("main")
	print("   鍵列：%s" % keys)
	_check("C4 程式仍在（節點有效）", is_instance_valid(node) and node.is_inside_tree())
	_check("C4 按 Enter 前後畫面相同", before == after)
	_check("C4 結果行不變", String(node._feedback_line.text) == fb0)
	_check("C4 鍵列無「Enter」", not keys.contains("Enter"))
	_present["C4"] = true


# ── C5／C5b／C5c ─────────────────────────────────────────────────────────────
func _c5(node) -> void:
	print("\n── C5 零真值（remembered）／C5b unvisited／C5c visible ──")
	var st: WorldState = _st(node)
	var ptid: int = st.get_player_team_id()
	var home: Vector2i = st.teams[ptid].tile_pos
	var vr: int = _vr(node)
	# C5：走過 X 再離開；之後一支沒見過的隊被放上 X
	var cands: Array = []
	for k in st.world.tiles:
		var t: HexTileData = st.world.tiles[k]
		var dd: int = _hex(t.tile_pos, home)
		if dd >= vr + 3 and dd <= vr + 5 and not st.team_tile_known.get(ptid, {}).has(k) \
				and PlayerQueryApi.tile_knowledge(st, t.tile_pos, node._bridge.get_vision_mult()).get("teams", []).is_empty():
			cands.append(t.tile_pos)
	cands.sort()
	_check("C5 母體地板：候選格 %d 格（離家 vr+3..vr+5、沒去過、belief 沒有隊）" % cands.size(), cands.size() >= 2)
	if cands.size() < 2:
		return
	var x: Vector2i = cands[0]
	# U：離 X 超過視野（走過 X 時腳下視野會把鄰格也記住 ⇒ 太近的 U 就不是 unvisited 了）
	var u: Vector2i = Vector2i(-1, -1)
	for c in cands:
		if _hex(c, x) > vr + 2:
			u = c
	_check("C5b 母體地板：找得到離 X 超過視野的格 %s" % str(u), u != Vector2i(-1, -1))
	_visit(node, x)
	var n: int = _stranger(node, [])
	st.teams[n].tile_pos = x
	_walk(node, x)
	var lc: Dictionary = _lc(node)
	var occ_ids: Array = []
	for o in lc.get("occupants", []):
		occ_ids.append(int(o["team_id"]))
	var det: Array = _detail(_side(node))
	print("   X=%s（離家 %d、視野 %d）｜真值放 Team%d｜payload visibility=%s occupants=%s food鍵=%s\n   明細 %s" % [str(x),
		_hex(x, home), vr, n, str(lc.get("visibility_state")), str(occ_ids), str(lc.has("food")), str(det)])
	_check("C5 母體地板：Team%d 真的站在 X" % n, st.teams[n].tile_pos == x)
	_check("C5 payload 的格＝X", int(lc.get("tile", {}).get("q", -1)) == x.x and int(lc.get("tile", {}).get("r", -1)) == x.y)
	_check("C5 payload visibility_state＝remembered", String(lc.get("visibility_state", "")) == "remembered")
	_check("C5 payload occupants 不含 Team%d" % n, not occ_ids.has(n))
	_check("C5 payload 無 food 欄", not lc.has("food"))
	_check("C5 側欄明細不列 Team%d" % n, not _team_ids("\n".join(PackedStringArray(det))).has(n))
	_present["C5"] = true
	# C5b：unvisited、belief 那格沒有隊、真值放一支
	var m: int = _stranger(node, [n])
	st.teams[m].tile_pos = u
	_walk(node, u)
	var lb: Dictionary = _lc(node)
	print("   U=%s｜真值放 Team%d｜payload visibility=%s occupants=%s" % [str(u), m, str(lb.get("visibility_state")), str(lb.get("occupants"))])
	_check("C5b payload occupants 空", (lb.get("occupants", [null]) as Array).is_empty())
	_check("C5b payload visibility_state＝hidden", String(lb.get("visibility_state", "")) == "hidden")
	_present["C5b"] = true
	# C5c：visible 格（家旁一格）放一支隊 ⇒ 真值列出、food 有值
	var v: Vector2i = home + Vector2i(0, 1) if st.world.tiles.has(home.x * 1000 + home.y + 1) else home + Vector2i(0, -1)
	var w: int = _stranger(node, [n, m])
	st.teams[w].tile_pos = v
	_walk(node, v)
	var lv: Dictionary = _lc(node)
	var v_ids: Array = []
	for o in lv.get("occupants", []):
		v_ids.append(int(o["team_id"]))
	print("   V=%s｜真值放 Team%d｜payload visibility=%s occupants=%s food=%s" % [str(v), w, str(lv.get("visibility_state")), str(v_ids), str(lv.get("food"))])
	_check("C5c payload visibility_state＝visible", String(lv.get("visibility_state", "")) == "visible")
	_check("C5c payload occupants 含 Team%d" % w, v_ids.has(w))
	_check("C5c payload food 有值", lv.has("food"))
	_present["C5c"] = true


# ── PERF ─────────────────────────────────────────────────────────────────────
func _perf(node) -> void:
	print("\n── PERF 一次游標移動的單幀成本 ──")
	var st: WorldState = _st(node)
	var live: int = 0
	for tid in st.teams:
		if st.is_live_team(int(tid)): live += 1
	var ts: Array = []
	var keys: Array = [KEY_D, KEY_D, KEY_S, KEY_S, KEY_A, KEY_A, KEY_W, KEY_W]
	for i in range(5):
		for k in keys:
			var t0: int = Time.get_ticks_usec()
			_key(node, k)
			ts.append(Time.get_ticks_usec() - t0)
	ts.sort()
	var tot: int = 0
	for t in ts: tot += int(t)
	print("   活隊 %d、總隊 %d｜%d 次移動｜中位 %.2f ms｜平均 %.2f ms｜最大 %.2f ms" % [live, st.teams.size(), ts.size(),
		float(ts[ts.size() / 2]) / 1000.0, float(tot) / ts.size() / 1000.0, float(ts.back()) / 1000.0])
	_present["PERF"] = true
