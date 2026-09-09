extends SceneTree
# @bed-kind: acceptance
# slice: 查詢面交本體普查（systems 2026-09-10 §③）
#
# ★問題：還有沒有別的查詢動詞把【引擎狀態的本體】交出去？（get_decision_snapshot 已抓到一支）
# ★★而我【不沿用上游的 static pattern】—— 它認不得五種寫法（先存變數／巢狀／迴圈 append／
#   mapper 轉手兩層／值來自別的模組）。★★★所以改用【runtime 識別】：
#     ①先把 state 走一遍，記下每個容器的大小（path → size）
#     ②呼叫動詞，把回傳值裡【每一個容器】都戳一下（dict 加鍵／array 加長）
#     ③再走一遍 state：★有任何一個容器的大小變了 ⇒ 那個容器就是【本體】，而且我知道它在哪
#     ④還原，並驗證真的還原了
#   ⇒ 這個方法【不管那個容器是怎麼被放進回傳值的】—— 五種寫法一視同仁。
#
# 誠實限（寫在最前面）：
#   ①Packed* 是【值型別】⇒ 它們永遠是副本，本法對它們沒有鑑別力（也不需要）。
#   ②回傳 error envelope 的動詞【等於沒被測到】—— 逐支具名印出來，不算綠。
#   ③走訪有深度上限（DEPTH）⇒ 超過深度的容器不在母體裡，這是已知的涵蓋率缺口。

const DEPTH: int = 6
const SENTINEL: String = "__body_probe__"

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 3
var _hits_total: int = 0

func _initialize() -> void:
	print("=== 查詢面交本體普查 ===")
	_test_detector_positive_control()
	_census()
	_test_restore()
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d BODY_HITS=%d" % [_sections, EXPECT_SECTIONS, _fails, _hits_total])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

# ── 世界 ────────────────────────────────────────────────────────────────
func _mk() -> WorldState:
	seed(4242)
	var st := WorldState.new()
	st.world = WorldData.new()
	st.world.current_tick = 2880
	for i in range(3):
		var tile := HexTileData.new()
		tile.tile_id = i * 1000 + i
		tile.tile_pos = Vector2i(i, i)
		tile.terrain = "plains"
		st.world.tiles[tile.tile_id] = tile
	for tid in [3, 4]:
		var t := TeamData.new()
		t.team_id = tid
		t.tile_pos = Vector2i(1, 1)
		t.resources["food"] = 120.0
		t.resources["coin"] = 30.0
		AnonTierSystem.add_anon(t, "平民", 5)
		var ldr := PersonData.new()
		ldr.id = tid * 10
		ldr.team_id = tid
		ldr.person_name = "領袖%d" % tid
		st.persons[ldr.id] = ldr
		t.leader_id = ldr.id
		st.teams[tid] = t
	st.player_id = 30
	st.team_discovered[3] = [4]
	DecisionContext.gather(st, st.teams[3], true)
	return st

# ── 走訪：state 裡每個容器的 path → size ────────────────────────────────
var _state_objs: Dictionary = {}   # ★state 裡【走得到】的物件 instance_id 集合

func _index(state: WorldState) -> Dictionary:
	var out: Dictionary = {}
	var seen: Dictionary = {}
	_walk_obj(state, "state", out, seen, 0)
	_state_objs = seen
	return out

func _walk_obj(o: Object, path: String, out: Dictionary, seen: Dictionary, d: int) -> void:
	if o == null or d > DEPTH:
		return
	var iid: int = o.get_instance_id()
	if seen.has(iid):
		return
	seen[iid] = path
	for p in o.get_property_list():
		if int(p.get("usage", 0)) & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		var v = o.get(String(p["name"]))
		_walk_val(v, path + "." + String(p["name"]), out, seen, d + 1)

func _walk_val(v, path: String, out: Dictionary, seen: Dictionary, d: int) -> void:
	if d > DEPTH:
		return
	if v is Dictionary:
		out[path] = (v as Dictionary).size()
		for k in (v as Dictionary).keys():
			_walk_val((v as Dictionary)[k], "%s[%s]" % [path, str(k)], out, seen, d + 1)
	elif v is Array:
		out[path] = (v as Array).size()
		var i: int = 0
		for e in (v as Array):
			_walk_val(e, "%s[%d]" % [path, i], out, seen, d + 1)
			i += 1
	elif v is Object:
		_walk_obj(v as Object, path, out, seen, d)

# ── 戳：回傳值裡每一個容器 ──────────────────────────────────────────────
var _objs_found: Array = []

func _poke(v, d: int, poked: Array) -> void:
	if d > DEPTH:
		return
	# ★物件在 GDScript 裡【永遠是參考】⇒ 回傳值裡出現任何一個引擎物件，
	#   它【定義上就是本體】—— 這一類不用戳也不用比大小，看到就記名。
	if v is Object and not (v is Callable):
		var o: Object = v
		var nm: String = o.get_class()
		if o.get_script() != null:
			nm = String(o.get_script().resource_path.get_file())
		# ★★而【物件是參考】與【它是引擎的】是兩件事：新 make 出來的 struct 交出去無害，
		#   ★★★真正的本體是【state 走得到的那一顆】—— 用 instance_id 分開，不要一律喊紅。
		if _state_objs.has(o.get_instance_id()):
			# ★具名到【它在 state 的哪裡】——「有一顆本體」與「本體是 team.ctx_snapshot 裡那顆」
			#   對修的人是兩種資訊量。
			_objs_found.append("★本體 %s ＠ %s" % [nm, String(_state_objs[o.get_instance_id()])])
		else:
			_objs_found.append("新建 " + nm)
		return
	if v is Dictionary:
		var dict: Dictionary = v
		for k in dict.keys():
			_poke(dict[k], d + 1, poked)
		dict[SENTINEL] = 1
		poked.append(dict)
	elif v is Array:
		var arr: Array = v
		for e in arr:
			_poke(e, d + 1, poked)
		arr.resize(arr.size() + 1)
		poked.append(arr)

func _unpoke(poked: Array) -> void:
	for c in poked:
		if c is Dictionary:
			(c as Dictionary).erase(SENTINEL)
		elif c is Array:
			var a: Array = c
			a.resize(maxi(a.size() - 1, 0))

func _diff(before: Dictionary, after: Dictionary) -> Array:
	var hits: Array = []
	for k in before:
		if after.has(k) and int(after[k]) != int(before[k]):
			hits.append("%s（%d → %d）" % [k, int(before[k]), int(after[k])])
	return hits

# ── ① 陽性對照：偵測器抓不抓得到一個【真的】本體 ──────────────────────
func _test_detector_positive_control() -> void:
	print("-- ① 陽性對照：偵測器認不認得本體（★用真缺陷的形狀：直接把 ctx_snapshot 交出去）--")
	var st := _mk()
	var before: Dictionary = _index(st)
	# ★這就是 get_decision_snapshot 修掉之前的那個形狀
	var faux: Dictionary = {"data": {"fields": st.teams[3].ctx_snapshot}}
	var poked: Array = []
	_poke(faux, 0, poked)
	var hits: Array = _diff(before, _index(st))
	_unpoke(poked)
	print("    命中：%s" % str(hits.slice(0, 2)))
	_ok(hits.size() > 0, "①偽動詞交出 ctx_snapshot 本體 ⇒ 偵測器【具名】抓到（%d 處）" % hits.size())
	# ★對照的另一半：交副本 ⇒ 不得亂紅
	var st2 := _mk()
	var before2: Dictionary = _index(st2)
	var good: Dictionary = {"data": {"fields": st2.teams[3].ctx_snapshot.duplicate(true)}}
	var poked2: Array = []
	_poke(good, 0, poked2)
	var hits2: Array = _diff(before2, _index(st2))
	_unpoke(poked2)
	_ok(hits2.is_empty(), "①★另一半：交 duplicate 副本 ⇒ 零命中（不會亂紅）")
	_sections += 1

# ── ② 普查：逐支公開動詞 ────────────────────────────────────────────────
func _census() -> void:
	print("-- ② 逐支公開查詢動詞（★母體＝player_query_api 公開面 ＋ observer_query_api query_*）--")
	var q := PlayerQueryApi.new()
	var calls: Array = [
		["player.get_player_snapshot",      func(s): return q.get_player_snapshot(s, {})],
		["player.get_team_details",         func(s): return q.get_team_details(s, 3)],
		["player.get_member_details",       func(s): return q.get_member_details(s, 3, 30)],
		["player.get_location_context",     func(s): return q.get_location_context(s, 1, 1)],
		["player.get_trade_preview",        func(s): return q.get_trade_preview(s, 4)],
		["player.get_trade_direct_preview", func(s): return q.get_trade_direct_preview(s, 4)],
		["player.get_trade_session",        func(s): return q.get_trade_session(s, 4)],
		["player.get_available_actions",    func(s): return q.get_available_actions(s, {})],
		["player.pt_tile_self",             func(s): return q.pt_tile_self(s, 3)],
		["player.get_and_clear_alerts",     func(s): return q.get_and_clear_alerts(s)],
		["player.query_faction_panel",      func(s): return q.query_faction_panel(s)],
		["player.get_storage_panel",        func(s): return q.get_storage_panel(s)],
		["player.query_outpost_panel",      func(s): return q.query_outpost_panel(s)],
		["player.query_subteam_panel",      func(s): return q.query_subteam_panel(s)],
		["player.get_event_stream",         func(s): return q.get_event_stream(s, 5)],
		["player.get_world_clock",          func(s): return q.get_world_clock(s)],
		["player.get_status_line",          func(s): return q.get_status_line(s)],
		["player.get_decision_snapshot",    func(s): return q.get_decision_snapshot(s)],
		["observer.query_all_teams",        func(s): return ObserverQueryApi.query_all_teams(s)],
		["observer.query_team",             func(s): return ObserverQueryApi.query_team(s, 3)],
		["observer.query_map_teams",        func(s): return ObserverQueryApi.query_map_teams(s)],
		["observer.query_map_tiles",        func(s): return ObserverQueryApi.query_map_tiles(s)],
		["observer.query_outpost",          func(s): return ObserverQueryApi.query_outpost(s, Vector2i(1, 1))],
		["observer.query_all_outposts",     func(s): return ObserverQueryApi.query_all_outposts(s)],
	]
	var n_err: int = 0
	var errs: Array = []
	for c in calls:
		var vname: String = String(c[0])
		var st2 := _mk()
		var before: Dictionary = _index(st2)
		var r = (c[1] as Callable).call(st2)
		var poked: Array = []
		_poke(r, 0, poked)
		var hits: Array = _diff(before, _index(st2))
		_unpoke(poked)
		var containers: int = poked.size()
		var objs: Array = _objs_found.duplicate()
		_objs_found.clear()
		var note: String = ""
		if r is Dictionary and (r as Dictionary).has("ok") and not bool((r as Dictionary)["ok"]):
			n_err += 1
			errs.append(vname)
			note = "  ★error envelope：這一支【等於沒被測到】"
		var bodies: Array = []
		for o in objs:
			if String(o).begins_with("★本體"):
				bodies.append(o)
		if not bodies.is_empty():
			objs = bodies
			_hits_total += bodies.size()
			print("  %-38s 容器 %3d｜★★交出【state 走得到的物件】%d 個（物件是參考⇒改它就改世界）：%s%s" % [vname, containers, objs.size(), str(objs.slice(0, 3)), note])
		elif hits.is_empty():
			var extra: String = ("（另有 %d 個新建物件，非本體）" % objs.size()) if not objs.is_empty() else ""
			print("  %-38s 容器 %3d｜副本%s%s" % [vname, containers, extra, note])
		else:
			_hits_total += hits.size()
			print("  %-38s 容器 %3d｜★★本體 %d 處：%s%s" % [vname, containers, hits.size(), str(hits.slice(0, 3)), note])
	print("  ── 未被真正測到（error envelope）%d 支：%s" % [n_err, str(errs)])
	_ok(true, "②普查跑完 %d 支（★本格不判紅綠：清單本身就是產出）" % calls.size())
	_ok(n_err < calls.size(), "②★至少有動詞真的回了資料（否則整份普查沒有鑑別力）")
	_sections += 1

# ── ③ 還原驗證（★戳完必須還原，否則這支床自己就是污染源）──────────────
func _test_restore() -> void:
	print("-- ③ 還原驗證（★觀測器不得留下痕跡）--")
	var st := _mk()
	var before: Dictionary = _index(st)
	var q := PlayerQueryApi.new()
	var poked: Array = []
	_poke(q.get_decision_snapshot(st), 0, poked)
	_poke(q.get_player_snapshot(st, {}), 0, poked)
	_unpoke(poked)
	var after: Dictionary = _index(st)
	var diffs: Array = _diff(before, after)
	_ok(diffs.is_empty(), "③戳完還原 ⇒ state 每個容器大小都回到原值（%d 個容器在監看）" % before.size())
	_sections += 1
