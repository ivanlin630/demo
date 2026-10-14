extends SceneTree
# @bed-kind: invariant
# 多格移動走一格就停（spec 2026-10-13-multi-hop-move-stops-after-first-tile-HOW）＋不變量 #12（附身隊決策層不得寫）
#   P1  play.py 同一重現（seed 1337：x w w m ＋ x×12 ＋ l；原串的 enter 只承擔「選格」，游標即選中票拿掉）⇒ 最終在 (9,0)、事件流有「抵達 (9,0)」、沒有「抵達 (10,2)」
#   P5c 同一輪：抵達後 task＝idle、priority 0
#   P2  下令到兩格外 ⇒ 走到；途中不印抵達、到了恰一筆
#   P3  下令到不可達格（六鄰格移出地圖）⇒ 結果行「無法抵達」、move_target 沒被寫
#   P4  途中取消 ⇒ 事件流「停下：取消了移動」
#   P5d 行進中再按 M 到別格 ⇒ 換目標、結果行說開始走向新格｜休息中下 M ⇒ 換成行進
#   P5e AI 路徑對附身隊呼 release()（預設來源）⇒ 行進與目的地不變
#   P5b 抗命：附身隊的玩家令被 DISPATCH 挑戰 ⇒ 不換手、不加 stress｜反向：非附身隊照舊會抗命
#   P5g 行進途中佈置飢荒、跑威脅評估 ⇒ crisis_released_task 沒被寫、玩家重按 M 照樣成功
#   P5f 寫者重現（診斷床兩種走法）⇒ 附身隊 try_set:unified＝0（改前 1）
#   P7  下令後閒置 24 小時：task／move_target 的寫入只准是抵達那一對
#   P5／P8 30 天真世界、玩家附身：附身隊 task／move_target 的 allowlist 外寫入＝0（逐筆印）；每 tick 漂移校驗＝一致
#   P8①–④ 注入：玩家所在隊被併／玩家被邀入他隊與被逐出／玩家戰死而隊還在（窗口內仍附身、AI 寫入被擋）／possess 再 unpossess
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/multi_hop_move_bed.gd

const SEED: int = 1337
const REPRO_KEYS: Array = ["x", "w", "w", "m", "x", "x", "x", "x", "x", "x", "x", "x", "x", "x", "x", "x", "l"]
# ★allowlist（P5／P7）：附身隊 task／move_target 的合法寫入來源
const ALLOWED_SRC: Array = ["arbiter.try_set:player_move", "arbiter.try_set:player_rest", "arbiter.try_set:player_settle",
	"arbiter.release:arrival", "arbiter.release:player_cancel", "arbiter.release:path_broken", "arbiter.release:construction_done"]

var _errors: int = 0


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS: " + label)
	else:
		_errors += 1
		push_error("[FAIL] " + label)


func _initialize() -> void:
	print("=== multi_hop_move：玩家移動是一筆 arbiter 佔用；附身隊只收玩家與事件 ===")
	await _p1_repro()
	await _p2_two_hex()
	await _p3_unreachable()
	await _p4_cancel()
	await _p5d_rechain()
	_p5e_p5b_p5g()
	await _p5f_writer()
	await _p7_idle_24h()
	if OS.get_environment("MHM_SKIP_30D") == "1":
		print("
── P5／P8 30 天：MHM_SKIP_30D=1 跳過（只給負對照省時；交件與註冊表都不設）──")
	else:
		_p5_p8_30days()
	_p8_injections()
	print("=== multi_hop_move DONE === errors: %d" % _errors)
	TeamData.mt_watch_tid = -9999
	quit(1 if _errors > 0 else 0)


# ── 共用 ────────────────────────────────────────────────────────────────────
func _ui() -> Node:
	seed(SEED)
	var node: Node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	node._refresh()
	node._bridge._state.set_player_forced_event({}, "")
	return node


func _drop(node: Node) -> void:
	node.queue_free()
	await process_frame


func _press(node: Node, k: String) -> void:
	await PlayerRepl.press_on(node, PlayerRepl.keycode_for(k))


static func _msgs(node: Node) -> Array:
	var out: Array = []
	for e in node._events:
		out.append(String((e as Dictionary).get("msg", "")) if e is Dictionary else String(e))
	return out


static func _count_prefix(msgs: Array, prefix: String) -> int:
	var n: int = 0
	for m in msgs:
		if String(m).begins_with(prefix):
			n += 1
	return n


static func _pt(node: Node) -> TeamData:
	var st: WorldState = node._bridge._state
	return st.teams.get(st.get_player_team_id())


static func _hexd(a: Vector2i, b: Vector2i) -> int:
	var dx: int = b.x - a.x
	var dy: int = b.y - a.y
	return (absi(dx) + absi(dx + dy) + absi(dy)) / 2


# 找一格：與 from 距離＝d、在地圖上
static func _tile_at_dist(st: WorldState, from: Vector2i, d: int) -> Vector2i:
	var ks: Array = st.world.tiles.keys()
	ks.sort()
	for k in ks:
		var p := Vector2i(int(k) / 1000, int(k) % 1000)
		if _hexd(from, p) == d:
			return p
	return Vector2i(-1, -1)


# ── P1／P5c ──────────────────────────────────────────────────────────────────
func _p1_repro() -> void:
	print("\n── P1／P5c 藍圖重現：多格移動走完全程 ──")
	var node: Node = await _ui()
	for k in REPRO_KEYS:
		await _press(node, k)
	var pt: TeamData = _pt(node)
	var ms: Array = _msgs(node)
	print("   最終位置 %s｜task %s＠%d｜抵達事件：%s" % [str(pt.tile_pos), pt.current_task, pt.task_priority,
		str(ms.filter(func(m): return String(m).begins_with("抵達") or String(m).begins_with("停下")))])
	_check("P1 最終在 (9,0)", pt.tile_pos == Vector2i(9, 0))
	_check("P1 事件流有「抵達 (9,0)」", _has_arrive(ms, Vector2i(9, 0)))
	_check("P1 沒有「抵達 (10,2)」", not _has_arrive(ms, Vector2i(10, 2)))
	_check("P5c 抵達後 task＝idle、priority 0", pt.current_task == TeamData.TASK_IDLE and pt.task_priority == 0)
	await _drop(node)


# ── P2 ───────────────────────────────────────────────────────────────────────
func _p2_two_hex() -> void:
	print("\n── P2 兩格外的可達格：走到；途中不印抵達 ──")
	var node: Node = await _ui()
	await _press(node, "x")
	var st: WorldState = node._bridge._state
	var pt: TeamData = _pt(node)
	var tgt: Vector2i = _tile_at_dist(st, pt.tile_pos, 2)
	node._cursor = tgt
	await _press(node, "m")
	var early: int = 0
	for i in range(48):
		if pt.tile_pos == tgt:
			break
		await _press(node, "x")
		if pt.tile_pos != tgt:
			early += _count_prefix(_msgs(node), "抵達")
	var ms: Array = _msgs(node)
	print("   目標 %s｜最終 %s｜途中抵達 %d｜抵達筆數 %d" % [str(tgt), str(pt.tile_pos), early, _count_prefix(ms, "抵達")])
	_check("★P2 母體地板：目標真的在兩格外", tgt != Vector2i(-1, -1))
	_check("P2 走到目標", pt.tile_pos == tgt)
	_check("P2 途中沒有印抵達", early == 0)
	_check("P2 到了恰一筆「抵達 %s」" % str(tgt), _count_prefix(ms, "抵達") == 1 and _has_arrive(ms, tgt))
	await _drop(node)


# ── P3 ───────────────────────────────────────────────────────────────────────
func _p3_unreachable() -> void:
	print("\n── P3 不可達格：下令即拒、目的地不被寫 ──")
	var node: Node = await _ui()
	var st: WorldState = node._bridge._state
	var pt: TeamData = _pt(node)
	var tgt: Vector2i = _tile_at_dist(st, pt.tile_pos, 3)
	# 佈置：目標的六鄰格移出地圖 ⇒ 它成了孤島
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
		var n: Vector2i = tgt + d
		st.world.tiles.erase(n.x * 1000 + n.y)
	# ★目標格設成已知（記得的格）：2026-10-13 起未知格不做可達預判（往迷霧走是探索，systems 裁 08e6f4899）
	var known: Dictionary = st.team_tile_known.get(pt.team_id, {})
	known[tgt.x * 1000 + tgt.y] = true
	st.team_tile_known[pt.team_id] = known
	node._cursor = tgt
	await _press(node, "m")
	var fb: String = String(node._feedback_line.text)
	print("   目標 %s｜結果行「%s」｜move_target %s｜task %s" % [str(tgt), fb, str(pt.move_target), pt.current_task])
	_check("P3 結果行說「無法抵達…沒有路」、不指名原因", fb.contains("無法抵達") and fb.contains("沒有路") and not fb.contains("被山"))
	_check("P3 move_target 沒被寫、task 不是行進", pt.move_target == Vector2i(-1, -1) and pt.current_task != TeamData.TASK_TRAVEL)
	await _drop(node)
	# P3b：同樣的孤島、但玩家沒去過也看不到 ⇒ 照樣下令（不預判、不洩露那格周圍的真地形）
	print("\n── P3b 沒去過的孤島：照樣下令 ──")
	node = await _ui()
	st = node._bridge._state
	pt = _pt(node)
	var far: Vector2i = _tile_at_dist(st, pt.tile_pos, 9)
	for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, -1), Vector2i(-1, 1)]:
		var n2: Vector2i = far + d
		st.world.tiles.erase(n2.x * 1000 + n2.y)
	var k2: Dictionary = PlayerQueryApi.tile_knowledge(st, far)
	node._cursor = far
	await _press(node, "m")
	var fb2: String = String(node._feedback_line.text)
	print("   目標 %s（%s）｜結果行「%s」｜task %s" % [str(far), String(k2.get("status", "")), fb2, pt.current_task])
	_check("★母體地板：那一格對玩家是沒去過", String(k2.get("status", "")) == "unvisited")
	_check("P3b 沒去過的孤島照樣下令（不說「沒有路」）", not fb2.contains("沒有路") and not fb2.contains("無法抵達"))
	await _drop(node)


# ── P4 ───────────────────────────────────────────────────────────────────────
func _p4_cancel() -> void:
	print("\n── P4 途中取消 ⇒ 事件流「停下：…」──")
	var node: Node = await _ui()
	var st: WorldState = node._bridge._state
	var pt: TeamData = _pt(node)
	node._cursor = _tile_at_dist(st, pt.tile_pos, 6)
	await _press(node, "m")
	await _press(node, "x")
	node._bridge.command_player("cancel_move", {})
	await _press(node, "x")
	var stops: Array = _msgs(node).filter(func(m): return String(m).begins_with("停下："))
	print("   停下事件：%s｜task %s｜move_target %s" % [str(stops), pt.current_task, str(pt.move_target)])
	_check("P4 事件流有「停下：取消了移動（停在…）」", stops.any(func(m): return String(m).begins_with("停下：取消了移動（停在 (")))
	_check("P4 取消後 task 不是行進", pt.current_task != TeamData.TASK_TRAVEL)
	await _drop(node)


# ── P5d ──────────────────────────────────────────────────────────────────────
func _p5d_rechain() -> void:
	print("\n── P5d 行進中再按 M 換目標｜休息中下 M 換成行進 ──")
	var node: Node = await _ui()
	var st: WorldState = node._bridge._state
	var pt: TeamData = _pt(node)
	var a: Vector2i = _tile_at_dist(st, pt.tile_pos, 6)
	node._cursor = a
	await _press(node, "m")
	await _press(node, "x")
	var b: Vector2i = Vector2i(-1, -1)
	for k in st.world.tiles.keys():
		var p := Vector2i(int(k) / 1000, int(k) % 1000)
		if _hexd(pt.tile_pos, p) == 5 and p != a:
			b = p
			break
	node._cursor = b
	await _press(node, "m")
	var fb: String = String(node._feedback_line.text)
	print("   A %s → B %s｜結果行「%s」｜move_target %s｜task %s" % [str(a), str(b), fb, str(pt.move_target), pt.current_task])
	_check("P5d 行進中再 M ⇒ 目的地換成新格、仍是行進", pt.move_target == b and pt.current_task == TeamData.TASK_TRAVEL)
	_check("P5d 結果行說開始走向新格", fb.contains("開始走向 (%d,%d)" % [b.x, b.y]))
	# 休息中下 M
	TaskArbiter.release(pt, "player_cancel")
	TaskArbiter.try_set(st, pt, TeamData.TASK_REST, Vector2i(-1, -1), TaskArbiter.PRIO_PLAYER, "player_rest")
	var rest_ok: bool = pt.current_task == TeamData.TASK_REST
	var r: Dictionary = PlayerCommandSystem.new().move_to(st, a)
	print("   休息中 M ⇒ %s｜task %s｜move_target %s" % [str(r), pt.current_task, str(pt.move_target)])
	_check("★P5d 母體地板：真的在休息", rest_ok)
	_check("P5d 休息中下 M ⇒ 換成行進", bool(r.get("ok", false)) and pt.current_task == TeamData.TASK_TRAVEL and pt.move_target == a)
	await _drop(node)


# ── P5e／P5b／P5g（arbiter 層，不走 UI）──────────────────────────────────────
func _world() -> WorldState:
	seed(SEED)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/default.json"))
	return st


func _p5e_p5b_p5g() -> void:
	print("\n── P5e release 守｜P5b 抗命｜P5g 飢荒不擋重按 M ──")
	var st: WorldState = _world()
	var pt: TeamData = st.teams[st.get_player_team_id()]
	_check("★母體地板：玩家隊 possessed＝真", pt.possessed)
	var far: Vector2i = _tile_at_dist(st, pt.tile_pos, 6)
	var cs := PlayerCommandSystem.new()
	cs.move_to(st, far)
	TaskArbiter.release(pt)   # ★AI 路徑的呼法（預設來源）
	print("   P5e release() 後 task %s＠%d｜move_target %s" % [pt.current_task, pt.task_priority, str(pt.move_target)])
	_check("P5e AI 路徑 release() ⇒ 行進與目的地不變", pt.current_task == TeamData.TASK_TRAVEL and pt.move_target == far)
	# P5b
	var leader: PersonData = st.persons.get(pt.leader_id)
	for kv in [["義氣", 0.0], ["信義", 0.0], ["貪婪", 1.0], ["野心", 1.0]]:
		leader.values[kv[0]] = kv[1]
	leader.loyalty = 0.0
	var s0: float = leader.stress
	var ok_p: bool = TaskArbiter.try_set(st, pt, TeamData.TASK_FORAGE, pt.tile_pos, TaskArbiter.PRIO_DISPATCH, "unified")
	print("   P5b 附身隊被 DISPATCH 挑戰 ⇒ try_set=%s｜task %s｜stress %.2f→%.2f" % [str(ok_p), pt.current_task, s0, leader.stress])
	_check("P5b 附身隊：不換手", not ok_p and pt.current_task == TeamData.TASK_TRAVEL)
	_check("P5b 附身隊：不加 stress", is_equal_approx(leader.stress, s0))
	var npc: TeamData = null
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if not t.possessed and t.leader_id != -1 and st.persons.has(t.leader_id) and t.beast_kind == "" and t.combat_target == -1:
			npc = t
			break
	var nl: PersonData = st.persons.get(npc.leader_id)
	for kv in [["義氣", 0.0], ["信義", 0.0], ["貪婪", 1.0], ["野心", 1.0]]:
		nl.values[kv[0]] = kv[1]
	nl.loyalty = 0.0
	TaskArbiter.release(npc)
	npc.crisis_released_task = ""
	TaskArbiter.try_set(st, npc, TeamData.TASK_REST, Vector2i(-1, -1), TaskArbiter.PRIO_PLAYER, "player_command")
	npc.persist_strength = 0.0
	var ok_n: bool = TaskArbiter.try_set(st, npc, TeamData.TASK_FORAGE, npc.tile_pos, TaskArbiter.PRIO_DISPATCH, "unified")
	print("   P5b 反向 非附身隊 Team%d ⇒ try_set=%s｜task %s｜reason %s" % [npc.team_id, str(ok_n), npc.current_task, npc.task_reason])
	_check("P5b 反向：非附身隊照舊會抗命", ok_n and npc.task_reason == "defy_unified")
	# P5g
	# ★佈置飢荒判定的三個條件（faction_ai _famine_crisis）：深餓、承諾滿 CRISIS_DAYS、承諾以來沒緩解
	pt.resources["food"] = 0.0
	pt.task_start_tick = st.world.current_tick - 10 * WorldState.TICKS_PER_DAY
	pt.crisis_committed_tick = pt.task_start_tick
	pt.crisis_committed_food = 0.0
	pt.threat_eval_next_tick = 0
	pt.crisis_released_task = ""
	var famine: bool = FactionAISystem.shared()._famine_crisis(st, pt)
	_check("★P5g 母體地板：飢荒判定真的成立", famine)
	FactionAISystem.shared()._evaluate_threat(st, pt)
	var again: Vector2i = _tile_at_dist(st, pt.tile_pos, 5)
	var r2: Dictionary = cs.move_to(st, again)
	print("   P5g 飢荒＋威脅評估後 crisis_released_task「%s」｜重按 M ⇒ %s｜move_target %s" % [pt.crisis_released_task, str(r2), str(pt.move_target)])
	_check("P5g crisis_released_task 沒被寫", pt.crisis_released_task == "")
	_check("P5g 重按 M 照樣成功", bool(r2.get("ok", false)) and pt.move_target == again and pt.current_task == TeamData.TASK_TRAVEL)


# ── P5f：診斷床兩種走法 ───────────────────────────────────────────────────────
func _p5f_writer() -> void:
	print("\n── P5f 寫者重現：附身隊 try_set:unified＝0（改前 1）──")
	for mode in ["藍圖那串鍵", "開場閒置 72 小時"]:
		var node: Node = await _ui()
		var ptid: int = node._bridge._state.get_player_team_id()
		TeamData.mt_watch_tid = ptid
		TeamData.mt_log.clear()
		var keys: Array = REPRO_KEYS if mode == "藍圖那串鍵" else []
		for k in keys:
			await _press(node, k)
		if keys.is_empty():
			for h in range(72):
				await _press(node, "x")
		var bad: Array = TeamData.mt_log.filter(func(e): return not (String(e["src"]) in ALLOWED_SRC) and String(e["src"]).begins_with("arbiter."))
		var uni: int = TeamData.mt_log.filter(func(e): return String(e["src"]) == "arbiter.try_set:unified").size()
		print("   %s：寫入 %d 筆｜try_set:unified %d｜arbiter 來源不在 allowlist %d %s" % [mode, TeamData.mt_log.size(), uni, bad.size(), str(bad)])
		_check("P5f %s：附身隊 try_set:unified＝0" % mode, uni == 0)
		_check("P5f %s：arbiter 寫入都在 allowlist" % mode, bad.is_empty())
		TeamData.mt_watch_tid = -9999
		await _drop(node)


# ── P7 ───────────────────────────────────────────────────────────────────────
func _p7_idle_24h() -> void:
	print("\n── P7 下令後閒置 24 小時：寫入只准是抵達那一對 ──")
	var node: Node = await _ui()
	var st: WorldState = node._bridge._state
	var pt: TeamData = _pt(node)
	node._cursor = _tile_at_dist(st, pt.tile_pos, 6)
	await _press(node, "m")
	TeamData.mt_watch_tid = pt.team_id
	TeamData.mt_log.clear()
	for h in range(24):
		await _press(node, "x")
	var bad: Array = []
	for e in TeamData.mt_log:
		var arrival_pair: bool = (String(e["src"]) == "arbiter.release:arrival") \
			or (String(e["field"]) == "move_target" and e["new"] == Vector2i(-1, -1) and String(e["task"]) == TeamData.TASK_TRAVEL)
		if not arrival_pair:
			bad.append(e)
	print("   24h 寫入 %d 筆｜不是抵達那一對 %d：%s｜最後 task %s move_target %s" % [TeamData.mt_log.size(), bad.size(), str(bad), pt.current_task, str(pt.move_target)])
	_check("P7 閒置 24h：沒有無解釋的 task／move_target 變化", bad.is_empty())
	TeamData.mt_watch_tid = -9999
	await _drop(node)


# ── P5／P8：30 天真世界 ───────────────────────────────────────────────────────
func _p5_p8_30days() -> void:
	print("\n── P5／P8 30 天、玩家附身：allowlist 外寫入＝0、每 tick 漂移一致 ──")
	var st: WorldState = _world()
	var runner := SimRunner.new()
	var ptid: int = st.get_player_team_id()
	TeamData.mt_watch_tid = ptid
	TeamData.mt_log.clear()
	var drift: Array = []
	var ticks: int = 30 * WorldState.TICKS_PER_DAY
	var froze: int = -1
	var enc: int = 0
	for i in range(ticks):
		var pt: TeamData = st.teams.get(st.get_player_team_id())
		var r: String = runner.advance_tick(st, pt.tile_pos if pt != null else Vector2i(-1, -1))
		if st.encounter_active:
			enc += 1
			runner._encounter_system.resolve_encounter_end(st, "draw")
		if r == "awaiting_heir":
			froze = st.world.current_tick
			break
		var why: String = st.check_possession_drift()
		if why != "":
			drift.append("tick %d：%s" % [st.world.current_tick, why])
	var bad: Array = TeamData.mt_log.filter(func(e): return not (String(e["src"]) in ALLOWED_SRC))
	print("   跑到 tick %d（遭遇 %d 次、凍結 %d）｜附身隊寫入 %d 筆｜allowlist 外 %d" % [st.world.current_tick, enc, froze, TeamData.mt_log.size(), bad.size()])
	for e in bad.slice(0, 20):
		print("      %s" % str(e))
	print("   漂移 %d 次 %s" % [drift.size(), str(drift.slice(0, 5))])
	_check("★P5 母體地板：真的跑了 ≥ 7 天", st.world.current_tick >= 7 * WorldState.TICKS_PER_DAY)
	_check("P5 附身隊 allowlist 外寫入＝0", bad.is_empty())
	_check("P8 每 tick possessed 與玩家一致（漂移 0）", drift.is_empty())
	TeamData.mt_watch_tid = -9999


# ── P8 注入四格 ───────────────────────────────────────────────────────────────
static func _possessed_ids(st: WorldState) -> Array:
	var out: Array = []
	for tid in st.teams:
		if (st.teams[tid] as TeamData).possessed:
			out.append(int(tid))
	return out


func _other_team(st: WorldState, not_id: int) -> TeamData:
	var ks: Array = st.teams.keys()
	ks.sort()
	for tid in ks:
		var t: TeamData = st.teams[tid]
		if int(tid) != not_id and t.beast_kind == "" and t.leader_id != -1 and st.persons.has(t.leader_id) and t.population > 0:
			return t
	return null


func _p8_injections() -> void:
	print("\n── P8 注入：每格拿掉對應 sync 必紅 ──")
	# ①玩家所在隊被吸收併隊（merge_teams 帶名單那一支 ＝ 原本直寫 p.team_id 的那一處）
	var st: WorldState = _world()
	var pid0: int = st.get_player_team_id()
	var other: TeamData = _other_team(st, pid0)
	SubteamSystem.new().merge_teams(st, other.team_id, pid0, [st.player_id], 0)
	print("   ① 併入 Team%d ⇒ 玩家在 Team%d｜possessed %s" % [other.team_id, st.persons[st.player_id].team_id, str(_possessed_ids(st))])
	_check("P8① 玩家所在隊被併 ⇒ possessed 跟到新隊", _possessed_ids(st) == [st.persons[st.player_id].team_id] and st.check_possession_drift() == "")
	# ②玩家被邀入他隊／被逐出
	st = _world()
	pid0 = st.get_player_team_id()
	other = _other_team(st, pid0)
	st.remove_member(st.teams[pid0], st.player_id, false)
	st.add_member(other, st.player_id)
	var in_ok: bool = _possessed_ids(st) == [other.team_id]
	st.remove_member(other, st.player_id)
	var out_ok: bool = _possessed_ids(st).is_empty()
	print("   ② 邀入 Team%d ⇒ %s｜逐出 ⇒ %s" % [other.team_id, str(in_ok), str(out_ok)])
	_check("P8② 被邀入他隊 ⇒ possessed 跟過去", in_ok)
	_check("P8② 被逐出 ⇒ 沒有 possessed 隊", out_ok)
	# ③玩家戰死而隊還在（同 npc_combat 那一段：出 named 不清 team_id、移出 persons）
	st = _world()
	pid0 = st.get_player_team_id()
	var pt: TeamData = st.teams[pid0]
	var dead: int = st.player_id
	st.remove_member(pt, dead, false)
	if pt.leader_id == dead:
		pt.leader_id = -1
	st.persons.erase(dead)
	st.sync_possession()   # ★窗口內任何一次 sync（例：第一個 tick 的補同步）都不得把附身拿掉
	var still: bool = pt.possessed
	var w_ok: bool = TaskArbiter.try_set(st, pt, TeamData.TASK_FORAGE, pt.tile_pos, TaskArbiter.PRIO_DISPATCH, "unified")
	print("   ③ 戰死窗口 ⇒ Team%d possessed=%s｜AI try_set=%s" % [pid0, str(still), str(w_ok)])
	_check("P8③ 戰死窗口內仍 possessed", still)
	_check("P8③ 窗口內 AI 寫入被擋", not w_ok)
	# ④possess 一支 NPC 隊再 unpossess
	st = _world()
	pid0 = st.get_player_team_id()
	other = _other_team(st, pid0)
	var api := PlayerCommandApi.new()
	api.possess(st, other.leader_id)
	var on_ok: bool = _possessed_ids(st) == [other.team_id]
	api.unpossess(st)
	var back_ok: bool = _possessed_ids(st) == [pid0]
	print("   ④ possess Team%d ⇒ %s｜unpossess ⇒ %s" % [other.team_id, str(on_ok), str(back_ok)])
	_check("P8④ possess 一支 NPC 隊 ⇒ possessed 換過去", on_ok)
	_check("P8④ unpossess ⇒ 回到原隊", back_ok)

# ★與 text_ui_main.gd 的抵達訊息同一個格式字串（不寫死單次字面值：value-key 閘的查表 key 要成對）
func _arrive_msg(p: Vector2i) -> String:
	return "抵達 (%d,%d)" % [p.x, p.y]

# ★抵達句後面接「（走了 N 分鐘）」（spec 2026-10-13-move-eta-same-ruler 改法 4）⇒ 比「抵達 (q,r)」整句或後接「（」
func _has_arrive(ms: Array, p: Vector2i) -> bool:
	for m in ms:
		if String(m) == _arrive_msg(p) or String(m).begins_with(_arrive_msg(p) + "（"):
			return true
	return false
