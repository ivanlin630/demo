extends SceneTree
# @bed-kind: acceptance
# slice: C1 票① §5 資訊完整性對帳表
#
# ★母體不是「我們覺得玩家需要什麼」，是【引擎替這具身體讀了什麼】＝ DecisionContext 的 var 欄位。
# ★★兩個【各自可驗證】的斷言，不合成一份：
#   ①119 列 ctx 欄位 × 玩家讀不讀得到
#   ②§5 邊界文字明列、但【不對應任何 ctx 欄位】的項目（目前只有事件流）
#   ⇒ ★★★否則「①全綠」會被誤讀成「§5 邊界也綠了」。

const OUT_PATH: String = "res://docs/measurements/2026-09-10-c1-info-reconciliation.md"

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 2

func _initialize() -> void:
	print("=== C1 INFO RECONCILIATION ===")
	var rows: Array = _build_table()
	_write_file(rows)
	_test_section2()
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

func _ctx_fields() -> Array:
	# ★母體從【原始碼】抽（不是靠我列），這樣新增欄位會自動進表
	var f := FileAccess.open("res://scripts/simulation/decision/decision_context.gd", FileAccess.READ)
	if f == null:
		return []
	var src: String = f.get_as_text()
	f.close()
	var out: Array = []
	for line in src.split("\n"):
		var l: String = String(line)
		if not l.begins_with("var "):
			continue
		var name: String = l.substr(4).split(":")[0].split("=")[0].strip_edges()
		if name != "" and not (name in out):
			out.append(name)
	return out

# 玩家側可讀鍵集：把【公開查詢動詞】的輸出攤平成 key 集合
func _player_keys(state: WorldState) -> Dictionary:
	var q := PlayerQueryApi.new()
	var outs: Array = [
		q.get_player_snapshot(state, {}),
		q.get_available_actions(state, {}),
		q.query_faction_panel(state),
		q.get_storage_panel(state),
		q.query_outpost_panel(state),
		q.query_subteam_panel(state),
		q.get_event_stream(state, 5),
	]
	var pt: int = -1
	if state.player_id != -1 and state.persons.has(state.player_id):
		pt = int((state.persons[state.player_id] as PersonData).team_id)
	if pt != -1:
		outs.append(q.get_team_details(state, pt))
		outs.append(q.get_member_details(state, pt, state.player_id))
	var keys := {}
	for o in outs:
		_collect_keys(o, keys)
	return keys

func _collect_keys(v, keys: Dictionary) -> void:
	if v is Dictionary:
		for k in v:
			keys[String(k)] = true
			_collect_keys(v[k], keys)
	elif v is Array:
		for e in v:
			_collect_keys(e, keys)

func _build_table() -> Array:
	print("-- ① 119 列 ctx 欄位 × 玩家讀不讀得到 --")
	seed(1337)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/warring_states.json", false)
	# 附身到某支隊的 leader（★對帳要在【有玩家】的狀態下做）
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.leader_id != -1 and state.persons.has(t.leader_id):
			state.player_id = t.leader_id
			break
	var fields: Array = _ctx_fields()
	var keys: Dictionary = _player_keys(state)
	var rows: Array = []
	var blind: Array = []
	for name in fields:
		var reachable: bool = keys.has(String(name))
		rows.append({ "field": String(name), "reachable": reachable })
		if not reachable:
			blind.append(String(name))
	print("    ctx 欄位 %d｜玩家查詢輸出鍵 %d｜對得上 %d｜★盲格 %d" % [
		fields.size(), keys.size(), fields.size() - blind.size(), blind.size()])
	print("    盲格前 12：%s" % [", ".join(blind.slice(0, mini(12, blind.size())))])
	_ok(fields.size() > 100, "①母體抽得到（ctx 欄位 %d 個，spec 說 119）" % fields.size())
	_ok(true, "①表已建（盲格 %d —— ★這個數印在總結行，逐輪可比較）" % blind.size())
	_sections += 1
	return rows

func _write_file(rows: Array) -> void:
	var blind: int = 0
	for r in rows:
		if not bool((r as Dictionary)["reachable"]):
			blind += 1
	var buf: PackedStringArray = PackedStringArray()
	buf.append("# C1 票① 資訊完整性對帳表（機械產出，勿手改）")
	buf.append("")
	buf.append("★母體＝`decision_context.gd` 的 `var` 欄位（＝引擎替這具身體真的讀了什麼），")
	buf.append("不是「我們覺得玩家需要什麼」。★★比對面＝`player_query_api` 公開動詞輸出的鍵集。")
	buf.append("")
	buf.append("★★★比對規則的誠實限：**用欄位【名字】比對鍵名** ——")
	buf.append("⇒ 同一個量用不同名字端出來會被算成盲格（偽陰），而同名不同義會被算成看得到（偽陽）。")
	buf.append("⇒ 這張表回答的是「**有沒有一個同名的東西端出來**」，不是「**玩家看得懂那個值**」。")
	buf.append("")
	buf.append("## §1 ctx 欄位 × 玩家可讀（%d 列，盲格 %d）" % [rows.size(), blind])
	buf.append("")
	buf.append("| ctx 欄位 | 玩家讀得到 |")
	buf.append("|---|---|")
	for r in rows:
		var d: Dictionary = r
		buf.append("| `%s` | %s |" % [String(d["field"]), ("✔" if bool(d["reachable"]) else "★盲")])
	buf.append("")
	buf.append("## §2 §5 邊界明列、但【不對應任何 ctx 欄位】的項目")
	buf.append("")
	buf.append("★這一節【不是】§1 的子集：`decision_context` 全檔零筆 event／MessageData 命中")
	buf.append("⇒ 事件流【結構上不可能】出現在 §1 的列裡 —— 不是漏勾，是表的形狀容不下它。")
	buf.append("")
	buf.append("| 項目 | 來源函式 | agent 層接到了嗎 |")
	buf.append("|---|---|---|")
	buf.append("| 事件流 | `player_api_mapper.map_global_messages` | ✔ `player_query_api.get_event_stream`（本票補） |")
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f == null:
		_fails += 1
		push_error("[FAIL] 寫不出對帳表：%s" % OUT_PATH)
		return
	f.store_string("\n".join(buf) + "\n")
	f.close()
	print("    ★對帳表已落地：%s" % OUT_PATH)

func _test_section2() -> void:
	print("-- ② §5 邊界：事件流（★它結構上不在 §1 的表裡）--")
	var f := FileAccess.open("res://scripts/simulation/decision/decision_context.gd", FileAccess.READ)
	var src: String = f.get_as_text() if f != null else ""
	if f != null:
		f.close()
	var mentions: bool = src.contains("MessageData") or src.contains("global_messages")
	_ok(not mentions, "②decision_context 全檔零筆事件流命中 ⇒ 它不可能是 §1 的一列（表的形狀容不下）")
	# ★而事件流【已經接到 agent 層】——這是本票補的那支 wrapper
	var q := PlayerQueryApi.new()
	var st := WorldState.new()
	st.world = WorldData.new()
	var p := PersonData.new()
	p.id = 1
	st.persons[1] = p
	st.player_id = 1
	st.global_messages.append({ "description": "E1" })
	var r: Dictionary = q.get_event_stream(st, 3)
	_ok(bool(r.get("ok", false)) and (r.get("data", {}).get("events", []) as Array).size() == 1,
		"②事件流在 agent 層讀得到（本票補的 wrapper）")
	_sections += 1
