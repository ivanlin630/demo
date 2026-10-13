extends SceneTree
# @bed-kind: acceptance
# 勒索拿到 0（或近 0）不得說「完成」（spec 2026-10-13-extortion-zero-take-HOW；藍圖裁 43817c7d1 最小單位 0.1）
#   X1  床直接設目標庫存，造 gained 四形態：全空／全近零（<0.05）／混合／全可顯示 ⇒ 全空與全近零說「對方已經沒有東西可給」，
#       四種都不含「完成」「+0.0」「少量資源」
#   X2  結果句列出的每一項＝兩隊資源差經同一格式器；資源面板與結果句同一格式（一位小數）
#   X4  接受一次 ⇒ 被勒索方領袖 memory 恰多一筆 "tributed"；累計 ≥ FEUD_MIN ⇒ feud 邊形成
#   X5  事件行含勒索方、目標、結果；玩家為被勒索方時結果行含被拿走的量
#   X6  連續勒索同一隊：印每次 score／affinity／feud／threshold（量測；score 不降 ⇒ 交 systems）
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/extortion_zero_take_bed.gd

const SEED: int = 1337
const BAD_WORDS: Array = ["完成", "+0.0", "少量資源"]

var _errors: int = 0


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	print("=== extortion_zero_take：結果句看格式後的量，不說「完成」 ===")
	_x1_x2_four_forms()
	await _x2_panel()
	_x4_memory_feud()
	_x5_event_lines()
	_x6_brake_series()
	print("=== extortion_zero_take DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _world() -> WorldState:
	seed(SEED)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	return st


func _two_npcs(st: WorldState) -> Array:
	var out: Array = []
	var ids: Array = st.teams.keys()
	ids.sort()
	for tid in ids:
		var t: TeamData = st.teams[tid]
		if int(tid) != st.get_player_team_id() and t.beast_kind == "" and t.leader_id != -1:
			out.append(t)
		if out.size() == 2:
			break
	return out


func _set_stock(t: TeamData, stock: Dictionary) -> void:
	for res in ["food", "material", "goods", "coin"]:
		ResourceBank.set_amt(t, res, float(stock.get(res, 0.0)), "bed_seed")


func _x1_x2_four_forms() -> void:
	print("\n── X1／X2 gained 四形態 ──")
	var forms: Array = [
		["全空", {}, true],
		["全近零", {"food": 0.1, "coin": 0.1}, true],
		["混合", {"food": 12.0, "coin": 0.1}, false],
		["全可顯示", {"food": 12.0, "coin": 4.0}, false],
	]
	for f in forms:
		var st: WorldState = _world()
		var ab: Array = _two_npcs(st)
		var atk: TeamData = ab[0]
		var def: TeamData = ab[1]
		_set_stock(def, f[1])
		_set_stock(atk, {})
		var before: Dictionary = {}
		for res in ["food", "material", "goods", "coin"]:
			before[res] = float(atk.resources.get(res, 0.0))
		var r: Dictionary = InteractionSystem.new().resolve_extortion_direct(st, atk.team_id, def.team_id)
		var msg: String = String(r.get("msg", ""))
		var bad: Array = BAD_WORDS.filter(func(w): return msg.contains(w))
		print("   %-6s ⇒「%s」" % [f[0], msg])
		_check("X1 %s：不含「完成」「+0.0」「少量資源」" % f[0], bad.is_empty())
		if bool(f[2]):
			_check("X1 %s ⇒「對方已經沒有東西可給」" % f[0], msg == "對方已經沒有東西可給")
		else:
			var diff: Dictionary = {}
			for res in ["food", "material", "goods", "coin"]:
				diff[res] = float(atk.resources.get(res, 0.0)) - float(before[res])
			var want: String = "勒索到：" + ResourceFormat.list(diff)
			_check("X2 %s：結果句＝兩隊資源差經同一格式器（%s）" % [f[0], want], msg == want)


func _x2_panel() -> void:
	print("\n── X2 資源面板與結果句同一格式（一位小數）──")
	seed(SEED)
	var node: Node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	var st: WorldState = node._bridge.get_state()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	ResourceBank.set_amt(pt, "food", 49.37, "bed_seed")
	ResourceBank.set_amt(pt, "coin", 2085.0, "bed_seed")
	node._refresh()
	var lines: Array = node._build_economy_lines(node._cached_snapshot.get("controlled_team", {}))
	var row: String = ""
	for l in lines:
		if String(l).contains("食:"):
			row = String(l)
	print("   面板：「%s」" % row)
	_check("X2 面板食／幣按 0.1、一位小數（%s／%s）" % [ResourceFormat.panel(49.37), ResourceFormat.panel(2085.0)],
		row.contains("食:" + ResourceFormat.panel(49.37)) and row.contains("幣:" + ResourceFormat.panel(2085.0)) and ResourceFormat.panel(49.37) == "49.4")
	node.queue_free()
	await process_frame


func _tributed_count(p: PersonData, subject: int) -> int:
	var n: int = 0
	for m in p.memory:
		var md: Dictionary = m
		if String(md.get("type", "")) == "tributed" and int(md.get("subject_id", -1)) == subject:
			n += 1
	return n


func _x4_memory_feud() -> void:
	print("\n── X4 接受一次 ⇒ memory 恰多一筆 tributed；累計過 FEUD_MIN ⇒ feud 邊 ──")
	var st: WorldState = _world()
	var ab: Array = _two_npcs(st)
	var atk: TeamData = ab[0]
	var def: TeamData = ab[1]
	var vl: PersonData = st.persons.get(def.leader_id)
	_set_stock(def, {"food": 100.0, "coin": 100.0})
	var n0: int = _tributed_count(vl, atk.leader_id)
	InteractionSystem.new().resolve_extortion_direct(st, atk.team_id, def.team_id)
	var n1: int = _tributed_count(vl, atk.leader_id)
	print("   tributed 筆數 %d → %d" % [n0, n1])
	_check("X4 接受一次 ⇒ 被勒索方領袖 memory 恰多一筆 tributed（不重複補記）", n1 - n0 == 1)
	var feud: float = 0.0
	var times: int = 1
	while feud <= 0.0 and times < 20:
		_set_stock(def, {"food": 100.0, "coin": 100.0})
		InteractionSystem.new().resolve_extortion_direct(st, atk.team_id, def.team_id)
		times += 1
		feud = DiplomaticAiSystem._edge_intensity_to(vl.relation_edges, "feud", atk.leader_id)
	print("   連續勒索 %d 次後 feud 強度 %.2f（FEUD_MIN %.2f）" % [times, feud, NpcAiSystem.FEUD_MIN])
	_check("X4 累計 ≥ FEUD_MIN ⇒ feud 邊形成", feud > 0.0)


func _x5_event_lines() -> void:
	print("\n── X5 事件行與玩家被勒索的結果行 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	var npc: TeamData = _two_npcs(st)[0]
	_set_stock(npc, {"food": 12.0})
	var seq0: int = st.player_event_seq
	InteractionSystem.new()._resolve_extortion(st, ptid, npc.team_id)
	var line: String = ""
	for e in st.player_events:
		var d: Dictionary = e
		if int(d.get("seq", 0)) > seq0 and String(d.get("kind", "")) == "extortion":
			line = String(d.get("text", ""))
	print("   玩家勒索 Team%d ⇒ 事件行「%s」" % [npc.team_id, line])
	_check("X5 事件行含勒索方、目標、結果", line.contains("Team%d" % ptid) and line.contains("Team%d" % npc.team_id) and line.contains("拿到 食 3.0"))
	_set_stock(npc, {})
	seq0 = st.player_event_seq
	InteractionSystem.new()._resolve_extortion(st, ptid, npc.team_id)
	var line2: String = ""
	for e in st.player_events:
		var d2: Dictionary = e
		if int(d2.get("seq", 0)) > seq0 and String(d2.get("kind", "")) == "extortion":
			line2 = String(d2.get("text", ""))
	_check("X5 對方空了 ⇒ 事件行「對方已無可取」", line2.contains("對方已無可取"))
	_set_stock(pt, {"food": 20.0, "coin": 8.0})
	var r: Dictionary = PlayerCommandSystem.new()._pay_extortion(st, npc.team_id)
	print("   玩家被 Team%d 勒索 ⇒「%s」" % [npc.team_id, r.get("msg", "")])
	_check("X5 玩家為被勒索方 ⇒ 結果行含被拿走的量", String(r.get("msg", "")).contains("食 5.0") and String(r.get("msg", "")).contains("幣 2.0"))


func _x6_brake_series() -> void:
	print("\n── X6 連續勒索同一隊：score／affinity／feud／threshold 數列（量測）──")
	var st: WorldState = _world()
	var ab: Array = _two_npcs(st)
	var atk: TeamData = ab[0]
	var def: TeamData = ab[1]
	var series: Array = []
	for i in range(10):
		var ev: Dictionary = DiplomaticAiSystem.tribute_eval(st, def, atk, 0.5)
		var vl: PersonData = st.persons.get(def.leader_id)
		series.append("%d: score %.3f aff %.3f feud %.2f thr %.2f %s" % [i + 1, float(ev.get("score", 0.0)),
			float(vl.relations.get(atk.leader_id, 0.0)), DiplomaticAiSystem._edge_intensity_to(vl.relation_edges, "feud", atk.leader_id),
			DiplomaticAiSystem.TRIBUTE_ACCEPT_THRESHOLD, "接受" if bool(ev.get("accept", false)) else "拒"])
		_set_stock(def, {"food": 100.0, "coin": 100.0})
		InteractionSystem.new().resolve_extortion_direct(st, atk.team_id, def.team_id)
	for s in series:
		print("   " + String(s))
	var first: float = float(String(series[0]).split("score ")[1].split(" ")[0])
	var last: float = float(String(series[series.size() - 1]).split("score ")[1].split(" ")[0])
	print("   ⇒ score %.3f → %.3f（%s）" % [first, last, "有降" if last < first else "★沒有降 ⇒ 交 systems"])
