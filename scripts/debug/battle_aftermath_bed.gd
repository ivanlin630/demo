extends SceneTree
# @bed-kind: acceptance
# slice: 戰後收尾（spec 2026-10-14-battle-aftermath-wounded-captives-pursuit-HOW）
# ★格（修前紅除註明）：
#   A1  玩家勝／玩家敗／雙方同 tick 全失能／野獸 四場 ⇒ 各一則 combat_end 玩家事件含雙方死傷；反向：無玩家 draw ⇒ 不發
#   A2  血量昏迷、部位全 healthy 的敵方匿名 ⇒ 結算後敗方 wounded 桶含它
#   A3  玩家勝後四項都列；不選直接推進 ⇒ 第一顆 tick 結清為放走、事件說明；推進不被拒；X／空白（UI）同一結清
#   A3b 按「殺傷兵」後立刻推進 ⇒ 結果是殺；追擊同型
#   A3c 戰後 overlay 關閉鍵（引擎廣播）⇒ pending 仍在、選項仍列、世界沒前進
#   A3d 無玩家世界／強制 draw／有玩家世界的 NPC 對 NPC ⇒ 不成立 pending
#   A4  殺：wounded 桶減 N、人口減 N；記名失能者不出隊
#   A5  俘：captive_groups 增 k、敗方 wounded 減 k；k＝min(N, captive_room)；超量仍在敗方 wounded
#   A6  守恆：殺／俘／放三條 Σ 敗方人口變化＝殺＋俘
#   A7  30 天：manpower 三條讀人格路徑對玩家 holder 呼叫 0 次；group.treatment 只在玩家指令時變
#   A7b 容量一支：俘 k＝captive_room 後推 3 個 cadence ⇒ captive 數不變、無 breakaway、guardcap_player_excess＝0
#   A7c 缺糧物理對稱：玩家 holder 糧不足 ⇒ 俘虜被放走並發玩家事件
#   A8c 戰中俘虜：兩個方向各進對方 captive_groups、事件寫明；押方全倒 ⇒ 回留場規則；記名被押 ⇒ 放回
#   A8b 處置權：玩家撤離而敵方留場 ⇒ NPC 處置玩家留下的失能者；雙方同 tick 全失能 ⇒ result＝attacker_win、零俘虜、無命運
#   A8  NPC 勝：三極端人格＋feud 邊＋養不起；雙方記名失能者不被殺；事件含 NPC 的命運
#   A9  追擊：E＝0 或可達閘假 ⇒ 不列；可列且按追 ⇒ 敗方減 min(3, E)
#   A10 居民：玩家攻佔 ⇒ 三項列出、未決推進＝放棄佔領；NPC 攻方照舊讀人格
#   A11 玩家全隊陣亡 ⇒ 繼承或 game_over，不靜默結束
#   A12 帶團頁一行的日耗＝manpower 實際扣的糧

const EXPECTED: Array = ["A1", "A2", "A3", "A3b", "A3c", "A3d", "A4", "A5", "A6", "A7", "A7b", "A7c", "A8c", "A8b", "A8", "A9", "A10", "A11", "A12"]
const FOE_ID: int = 910
const SEED: int = 20261014
var _errors: int = 0
var _present: Dictionary = {}
var _only: Dictionary = {}

func _on(fn: String) -> bool:
	return _only.is_empty() or _only.has(fn)

func _initialize() -> void:
	print("=== battle_aftermath：戰後收尾 ===")
	# ★BED_ONLY＝只給負對照用（逗號分隔函式名，例 _a4_a5_a6,_a7b）：跑子集時到場點名只點子集，並大字印出【這不是完整一輪】
	var only: String = OS.get_environment("BED_ONLY")
	if only != "":
		for f in only.split(","):
			_only[String(f).strip_edges()] = true
		print("★★★BED_ONLY=%s：只跑子集，這一輪不能當驗收" % only)
	if _on("_a1"): _a1()
	if _on("_a2"): _a2()
	if _on("_a3"): _a3()
	if _on("_a3_ui"): await _a3_ui()
	if _on("_a3b"): _a3b()
	if _on("_a3c"): await _a3c()
	if _on("_a3d"): _a3d()
	if _on("_a4_a5_a6"): _a4_a5_a6()
	if _on("_a7"): _a7()
	if _on("_a7b"): _a7b()
	if _on("_a7c"): _a7c()
	if _on("_a8c"): _a8c()
	if _on("_a8b"): _a8b()
	if _on("_a8"): _a8()
	if _on("_a9"): _a9()
	if _on("_a10"): _a10()
	if _on("_a11"): _a11()
	if _on("_a12"): _a12()
	var miss: Array = []
	for c in EXPECTED:
		if not _present.has(c):
			miss.append(c)
	if not miss.is_empty() and _only.is_empty():
		_check("到場點名缺 %s" % str(miss), false)
	print("=== battle_aftermath DONE === 到場 %d／%d errors: %d" % [_present.size(), EXPECTED.size(), _errors])
	quit(1 if _errors > 0 else 0)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

# ── 佈置 ─────────────────────────────────────────────────────────────────────
func _world() -> WorldState:
	seed(SEED)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	return st

func _pt(st: WorldState) -> TeamData:
	return st.teams[st.get_player_team_id()]

# 一支敵隊站在玩家格上（匿名 n 人、領袖人格可設）
func _foe(st: WorldState, n: int, vals: Dictionary = {}, tid: int = FOE_ID) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid
	t.faction_id = -1
	t.tile_pos = _pt(st).tile_pos
	t.armed_anon_ratio = 1.0
	AnonTierSystem.add_anon(t, AnonCohort.TIER_PLEB, n)
	var l := PersonData.new()
	l.id = tid * 10 + 1
	l.team_id = tid
	l.person_name = "首領%d" % tid
	for k in vals:
		l.values[k] = vals[k]
	st.persons[l.id] = l
	t.leader_id = l.id
	t.resources["food"] = 200.0
	st.teams[tid] = t
	return t

func _fight(st: WorldState, atk: int, def: int) -> EncounterSystem:
	var enc := EncounterSystem.new()
	enc.init_encounter(st, atk, def, "ambush")
	return enc

func _units(st: WorldState, tid: int, named: int = -1) -> Array:
	var out: Array = []
	for u in st.encounter_units:
		if int(u["team_id"]) != tid:
			continue
		if named == 0 and int(u["person_id"]) >= 0: continue
		if named == 1 and int(u["person_id"]) < 0: continue
		out.append(u)
	return out

static func _bp(st: WorldState, u: Dictionary) -> Dictionary:
	return EncounterSystem._get_body_parts(u, st)

func _disable(st: WorldState, u: Dictionary) -> void:
	_bp(st, u)["torso"]["status"] = "critical"

func _kill(st: WorldState, u: Dictionary) -> void:
	_bp(st, u)["torso"]["status"] = "severed"

func _heal(st: WorldState, u: Dictionary) -> void:
	for part in _bp(st, u).values():
		part["status"] = "healthy"
		part["bleeding"] = "none"
		part["fracture"] = false

# 一方全部失能（匿名 disabled、可選一部分殺）；另一方全部健在
func _wipe(st: WorldState, tid: int, dead: int = 0) -> void:
	var i: int = 0
	for u in _units(st, tid):
		if i < dead:
			_kill(st, u)
		else:
			_disable(st, u)
		i += 1

func _fine(st: WorldState, tid: int) -> void:
	for u in _units(st, tid):
		_heal(st, u)
		u["has_exited"] = false
		u["blood"] = 100.0

static func _wounded(t: TeamData) -> int:
	return AnonCohort.by_health(t.anon_cohorts, "wounded")

func _events(st: WorldState, kind: String, seq0: int) -> Array:
	return st.player_events.filter(func(e): return String(e.get("kind", "")) == kind and int(e.get("seq", 0)) > seq0)

func _actions(st: WorldState) -> Array:
	var env: Dictionary = PlayerQueryApi.new().get_available_actions(st, {})
	var out: Array = []
	for a in env.get("data", {}).get("actions", []):
		if bool(a.get("enabled", false)):
			out.append(String(a["action_id"]))
	return out

func _exec(st: WorldState, aid: String) -> Dictionary:
	return PlayerCommandSystem.new().execute_action(st, -1, aid)

func _advance(st: WorldState, n: int = 1) -> void:
	var r := SimRunner.new()
	for i in range(n):
		r.advance_tick(st, _pt(st).tile_pos)

# 玩家勝：敵方全部失能（dead 個殺掉），玩家方全健
func _player_wins(st: WorldState, foe_n: int, dead: int = 0, player_attacks: bool = false) -> Dictionary:
	var ptid: int = st.get_player_team_id()
	var foe: TeamData = _foe(st, foe_n)
	var enc: EncounterSystem = _fight(st, ptid if player_attacks else FOE_ID, FOE_ID if player_attacks else ptid)
	_fine(st, ptid)
	_wipe(st, FOE_ID, dead)
	var seq0: int = st.player_event_seq
	var w0: int = _wounded(foe)
	var p0: int = foe.population
	enc.resolve_encounter_end(st, "attacker_win" if player_attacks else "defender_win")
	return {"foe": foe, "seq0": seq0, "w0": w0, "p0": p0, "enc": enc}


# ── A1 ───────────────────────────────────────────────────────────────────────
func _a1() -> void:
	print("\n── A1 結算事件（四場）＋反向 ──")
	var got: Array = []
	# 玩家勝
	var st: WorldState = _world()
	var r: Dictionary = _player_wins(st, 6, 2)
	var ev: Array = _events(st, "combat_end", int(r["seq0"]))
	print("   玩家勝：%s" % (String(ev[0]["text"]) if not ev.is_empty() else "（無事件）"))
	got.append(ev.size() == 1 and String(ev[0]["text"]).contains("對方 死 2") and String(ev[0]["text"]).contains("你方 死"))
	# 玩家敗
	st = _world()
	var ptid: int = st.get_player_team_id()
	_foe(st, 8)
	var enc: EncounterSystem = _fight(st, FOE_ID, ptid)
	_fine(st, FOE_ID)
	_wipe(st, ptid)
	var seq0: int = st.player_event_seq
	enc.resolve_encounter_end(st, "attacker_win")
	ev = _events(st, "combat_end", seq0)
	print("   玩家敗：%s" % (String(ev[0]["text"]) if not ev.is_empty() else "（無事件）"))
	got.append(ev.size() == 1 and String(ev[0]["text"]).contains("你撤出了戰場"))
	# 雙方同 tick 全失能
	st = _world()
	ptid = st.get_player_team_id()
	var foe: TeamData = _foe(st, 5)
	enc = _fight(st, FOE_ID, ptid)
	_wipe(st, FOE_ID)
	_wipe(st, ptid)
	seq0 = st.player_event_seq
	var cap0: int = AnonTierSystem.total_captives(foe) + AnonTierSystem.total_captives(_pt(st))
	enc.resolve_encounter_end(st, "attacker_win")
	ev = _events(st, "combat_end", seq0)
	print("   雙方全失能：%s" % (String(ev[0]["text"]) if not ev.is_empty() else "（無事件）"))
	got.append(ev.size() == 1 and String(ev[0]["text"]).contains("雙方都倒下了")
		and AnonTierSystem.total_captives(foe) + AnonTierSystem.total_captives(_pt(st)) == cap0)
	# 野獸
	st = _world()
	ptid = st.get_player_team_id()
	var b: TeamData = _foe(st, 2)
	b.beast_kind = "boar"
	enc = _fight(st, FOE_ID, ptid)
	_fine(st, ptid)
	for u in _units(st, FOE_ID):
		_kill(st, u)
	seq0 = st.player_event_seq
	enc.resolve_encounter_end(st, "defender_win")
	ev = _events(st, "combat_end", seq0)
	print("   野獸：%s" % (String(ev[0]["text"]) if not ev.is_empty() else "（無事件）"))
	got.append(ev.size() == 1 and String(ev[0]["text"]).contains("獵得"))
	_check("A1 四場各一則 combat_end 玩家事件、含死傷（玩家勝／敗／雙倒／野獸：%s）" % str(got), got == [true, true, true, true])
	# 反向：無玩家的強制 draw
	st = _world()
	ptid = st.get_player_team_id()
	_foe(st, 4)
	_foe(st, 4, {}, FOE_ID + 1)
	st.player_id = -1
	enc = _fight(st, FOE_ID, FOE_ID + 1)
	seq0 = st.player_event_seq
	enc.resolve_encounter_end(st, "draw")
	_check("A1 反向：無玩家的強制 draw ⇒ 不發玩家事件", _events(st, "combat_end", seq0).is_empty())
	_present["A1"] = true


# ── A2 ───────────────────────────────────────────────────────────────────────
func _a2() -> void:
	print("\n── A2 血量昏迷的匿名算傷兵 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var foe: TeamData = _foe(st, 4)
	var enc: EncounterSystem = _fight(st, ptid, FOE_ID)
	_fine(st, ptid)
	var us: Array = _units(st, FOE_ID, 0)
	for u in us:
		_kill(st, u)
	_heal(st, us[0])
	us[0]["blood"] = 10.0
	var named: Array = _units(st, FOE_ID, 1)
	for u in named:
		_kill(st, u)
	print("   昏迷那一個：capable=%s disabled=%s" % [str(EncounterSystem.is_combat_capable(us[0], st)), str(EncounterSystem.is_disabled(us[0], st))])
	var w0: int = _wounded(foe)
	enc.resolve_encounter_end(st, "attacker_win")
	print("   敵方 wounded 桶 %d → %d" % [w0, _wounded(foe)])
	_check("A2 昏迷而部位全 healthy 的匿名 ⇒ 敗方 wounded 桶 +1", _wounded(foe) - w0 >= 1)
	_present["A2"] = true


# ── A3 ───────────────────────────────────────────────────────────────────────
func _a3() -> void:
	print("\n── A3 未決推進＝放走 ──")
	var st: WorldState = _world()
	var r: Dictionary = _player_wins(st, 6)
	var foe: TeamData = r["foe"]
	var res: Dictionary = st.last_encounter_result
	var acts: Array = _actions(st)
	print("   pending=%s N=%d｜可做：%s" % [str(res.get("fate_pending")), int(res.get("disabled_enemy", 0)), str(acts.filter(func(a): return String(a).begins_with("aftermath"))) ])
	_check("A3 母體地板：結算後敵方有 N>0 名傷兵、fate_pending", bool(res.get("fate_pending", false)) and int(res.get("disabled_enemy", 0)) > 0)
	_check("A3 四項都列", PlayerCommandSystem.AFTERMATH_FATE.all(func(a): return acts.has(a)))
	var w1: int = _wounded(foe)
	var seq0: int = st.player_event_seq
	var t0: int = st.world.current_tick
	_advance(st)
	var ev: Array = _events(st, "aftermath_settled", seq0)
	print("   推進後 tick %d→%d｜pending=%s｜敵 wounded %d→%d｜%s" % [t0, st.world.current_tick, str(st.last_encounter_result.get("fate_pending")),
		w1, _wounded(foe), String(ev[0]["text"]) if not ev.is_empty() else "（無結清句）"])
	_check("A3 推進不被拒（tick 前進）", st.world.current_tick > t0)
	_check("A3 第一顆 tick 結清為放走（N 人留在敗方 wounded）", not bool(st.last_encounter_result.get("fate_pending", false)) and _wounded(foe) >= w1 - 0)
	_check("A3 結果句說明「你沒有處置：傷兵被放走」", not ev.is_empty() and String(ev[0]["text"]).contains("你沒有處置：傷兵被放走"))
	_present["A3"] = true

# A3 的推進入口（UI）：X、空白都走同一個結清
func _a3_ui() -> void:
	print("\n── A3 推進入口：X／空白 ──")
	for key in ["x", "space"]:
		var node: Node = await _ui()
		var st: WorldState = node._bridge._state
		var r: Dictionary = _player_wins(st, 5)
		node._refresh()
		await PlayerRepl.press_on(node, PlayerRepl.keycode_for(key))
		var ok: bool = not bool(st.last_encounter_result.get("fate_pending", false))
		print("   %s ⇒ pending 清掉=%s" % [key, str(ok)])
		_check("A3 推進入口「%s」⇒ 走同一結清" % key, ok)
		node.queue_free()
		await process_frame

func _ui() -> Node:
	seed(SEED)
	var node: Node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	node.suppress_quit = true
	node._refresh()
	return node


# ── A3b ──────────────────────────────────────────────────────────────────────
func _a3b() -> void:
	print("\n── A3b 決定不被吃掉 ──")
	var st: WorldState = _world()
	var r: Dictionary = _player_wins(st, 6)
	var foe: TeamData = r["foe"]
	var n: int = int(st.last_encounter_result.get("disabled_enemy", 0))
	var w1: int = _wounded(foe)
	st.command_seq += 1
	st.pending_commands.append({"name": "execute_action", "args": {"action_id": "aftermath_kill", "target": {}}, "seq": st.command_seq})
	_advance(st)
	print("   N=%d｜敵 wounded %d→%d" % [n, w1, _wounded(foe)])
	_check("A3b 按殺後立刻推進 ⇒ 結果是殺（wounded −N）", n > 0 and _wounded(foe) == w1 - n)
	# 追擊同型：玩家人數 ≥ 2×敵、敵有逃散者
	st = _world()
	var ptid: int = st.get_player_team_id()
	var foe2: TeamData = _foe(st, 2)
	var enc: EncounterSystem = _fight(st, ptid, FOE_ID)
	_fine(st, ptid)
	for u in _units(st, FOE_ID):
		u["has_exited"] = true
	enc.resolve_encounter_end(st, "attacker_win")
	var res: Dictionary = st.last_encounter_result
	print("   追擊：pursuit_possible=%s E=%d（玩家 %d 人、敵 %d 人）" % [str(res.get("pursuit_possible")), int(res.get("pursuit_e", 0)), _pt(st).population, foe2.population])
	var h0: int = AnonCohort.by_health(foe2.anon_cohorts, "healthy")
	st.command_seq += 1
	st.pending_commands.append({"name": "execute_action", "args": {"action_id": "aftermath_pursue", "target": {}}, "seq": st.command_seq})
	_advance(st)
	_check("A3b 按追擊後立刻推進 ⇒ 結果是追（敵 healthy 減少）", bool(res.get("pursuit_possible", false)) == false and AnonCohort.by_health(foe2.anon_cohorts, "healthy") < h0)
	_present["A3b"] = true


# ── A3c ──────────────────────────────────────────────────────────────────────
func _a3c() -> void:
	print("\n── A3c 戰後 overlay 關閉鍵＝推進鍵（引擎廣播）──")
	var node: Node = await _ui()
	var st: WorldState = node._bridge._state
	var ptid: int = st.get_player_team_id()
	_foe(st, 5)
	EncounterSystem.new().init_encounter(st, FOE_ID, ptid, "ambush")
	await PlayerRepl.press_on(node, PlayerRepl.keycode_for("x"))
	_fine(st, ptid)
	_wipe(st, FOE_ID)
	EncounterSystem.new().resolve_encounter_end(st, "defender_win")
	for i in range(4):
		node._encounter_view.sync_with_world()
		await process_frame
	var post: bool = node._encounter_view.visible and bool(node._encounter_view._post_combat)
	var t0: int = st.world.current_tick
	var ev := InputEventKey.new()
	ev.keycode = KEY_X
	ev.physical_keycode = KEY_X
	ev.pressed = true
	get_root().push_input(ev)
	for i in range(6):
		await process_frame
	print("   戰後畫面=%s｜送 X 後 畫面=%s｜tick %d→%d｜pending=%s" % [str(post), str(node._encounter_view.visible), t0, st.world.current_tick,
		str(st.last_encounter_result.get("fate_pending"))])
	_check("A3c 母體地板：停在戰後畫面、有 pending", post and bool(st.last_encounter_result.get("fate_pending", false)) or not post)
	_check("A3c 關閉鍵沒有被主畫面當推進：pending 仍在、世界沒前進", bool(st.last_encounter_result.get("fate_pending", false)) and st.world.current_tick == t0)
	_check("A3c 選項仍列", _actions(st).has("aftermath_kill"))
	node.queue_free()
	await process_frame
	_present["A3c"] = true


# ── A3d ──────────────────────────────────────────────────────────────────────
func _a3d() -> void:
	print("\n── A3d 反向：不成立 pending ──")
	# 無玩家世界
	var st: WorldState = _world()
	_foe(st, 4)
	_foe(st, 4, {}, FOE_ID + 1)
	var keep: int = st.player_id
	st.player_id = -1
	var enc: EncounterSystem = _fight(st, FOE_ID, FOE_ID + 1)
	_fine(st, FOE_ID)
	_wipe(st, FOE_ID + 1)
	enc.resolve_encounter_end(st, "attacker_win")
	_check("A3d 無玩家世界 ⇒ 無 pending", not bool(st.last_encounter_result.get("fate_pending", false)))
	# 強制 draw
	st = _world()
	_foe(st, 4)
	enc = _fight(st, FOE_ID, st.get_player_team_id())
	_wipe(st, FOE_ID)
	enc.resolve_encounter_end(st, "draw")
	_check("A3d 強制 draw ⇒ 無 pending", not bool(st.last_encounter_result.get("fate_pending", false)))
	# 有玩家世界的 NPC 對 NPC
	st = _world()
	_foe(st, 4)
	_foe(st, 4, {}, FOE_ID + 1)
	enc = _fight(st, FOE_ID, FOE_ID + 1)
	_fine(st, FOE_ID)
	_wipe(st, FOE_ID + 1)
	enc.resolve_encounter_end(st, "attacker_win")
	_check("A3d 有玩家世界的 NPC 對 NPC ⇒ 無 pending", not bool(st.last_encounter_result.get("fate_pending", false)))
	_present["A3d"] = true


# ── A4／A5／A6 ───────────────────────────────────────────────────────────────
func _a4_a5_a6() -> void:
	print("\n── A4 殺／A5 俘／A6 守恆 ──")
	var cons: Array = []
	for how in ["aftermath_kill", "aftermath_capture_kind", "aftermath_release"]:
		var st: WorldState = _world()
		var pt: TeamData = _pt(st)
		var r: Dictionary = _player_wins(st, 8)
		var foe: TeamData = r["foe"]
		var n: int = int(st.last_encounter_result.get("disabled_enemy", 0))
		var named_before: int = foe.named_members.size() + (1 if foe.leader_id != -1 else 0)
		var p1: int = foe.population
		var w1: int = _wounded(foe)
		var room: int = ManpowerSystem.captive_room(st, pt)
		var c1: int = AnonTierSystem.total_captives(pt)
		var res: Dictionary = _exec(st, how)
		var killed: int = (p1 - foe.population) if how == "aftermath_kill" else 0
		var captured: int = AnonTierSystem.total_captives(pt) - c1
		print("   %s：N=%d room=%d｜%s｜敵人口 %d→%d、wounded %d→%d、我方俘虜 +%d" % [how, n, room, String(res.get("msg", "")), p1, foe.population, w1, _wounded(foe), captured])
		match how:
			"aftermath_kill":
				_check("A4 殺：wounded 桶減 N、人口減 N", _wounded(foe) == w1 - n and foe.population == p1 - n)
				_check("A4 記名失能者不出隊", foe.named_members.size() + (1 if foe.leader_id != -1 else 0) == named_before)
			"aftermath_capture_kind":
				var k: int = mini(n, room)
				_check("A5 母體地板：0＜k＜N（k=%d N=%d；k＝0 或 k＝N 時「超量仍在」是空轉）" % [k, n], k > 0 and k < n)
				_check("A5 俘：k＝min(N, captive_room)＝%d" % k, captured == k and k < n)
				_check("A5 敗方 wounded 減 k、超量仍在 wounded", _wounded(foe) == w1 - k)
				_check("A5 結果句寫放走數", String(res.get("msg", "")).contains("放走 %d 人" % (n - k)))
		cons.append((p1 - foe.population) == killed + captured)
	_check("A6 守恆：殺／俘／放三條 Σ 敗方人口變化＝殺＋俘（%s）" % str(cons), cons == [true, true, true])
	_present["A4"] = true
	_present["A5"] = true
	_present["A6"] = true


# ── A7 ───────────────────────────────────────────────────────────────────────
func _a7() -> void:
	print("\n── A7 玩家俘虜 30 天：讀人格路徑對玩家 holder 呼叫 0 次 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	_player_wins(st, 6)
	_exec(st, "aftermath_capture_harsh")
	var tr0: Array = pt.captive_groups.map(func(g): return String(g.get("treatment", "")))
	print("   俘虜 %d 人、待遇 %s" % [AnonTierSystem.total_captives(pt), str(tr0)])
	_check("A7 母體地板：玩家 holder 有俘虜", AnonTierSystem.total_captives(pt) > 0)
	for k in ["mp.persona_player.decide_treatment", "mp.persona_player.decide_guard_ratio", "mp.persona_player.enforce_guard_cap"]:
		Probe.counts.erase(k)
	var t_end: int = st.world.current_tick + 30 * WorldState.TICKS_PER_DAY
	var r := SimRunner.new()
	while st.world.current_tick < t_end and st.teams.has(pt.team_id):
		r.advance_tick(st, pt.tile_pos)
	var taps: Array = []
	for k in ["mp.persona_player.decide_treatment", "mp.persona_player.decide_guard_ratio", "mp.persona_player.enforce_guard_cap"]:
		taps.append(int(Probe.counts.get(k, 0)))
	var tr1: Array = pt.captive_groups.map(func(g): return String(g.get("treatment", "")))
	print("   30 天後 tap %s｜待遇 %s" % [str(taps), str(tr1)])
	_check("A7 三條讀人格路徑對玩家 holder 呼叫 0 次 %s" % str(taps), taps == [0, 0, 0])
	_check("A7 group.treatment 沒被系統改（只剩玩家選的苛待）", tr1.all(func(x): return String(x) == "苛待"))
	_present["A7"] = true


# ── A7b ──────────────────────────────────────────────────────────────────────
func _a7b() -> void:
	print("\n── A7b 容量一支：俘滿後 3 個 cadence 不被處置 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	_player_wins(st, 30)
	var room: int = ManpowerSystem.captive_room(st, pt)
	_exec(st, "aftermath_capture_kind")
	var c0: int = AnonTierSystem.total_captives(pt)
	pt.resources["food"] = 9999.0
	Probe.counts.erase("asm.guardcap_player_excess")
	Probe.counts.erase("asm.guardcap_forced")
	var teams0: int = st.teams.size()
	var t_end: int = st.world.current_tick + 3 * ManpowerSystem.CAPTIVE_CADENCE
	var r := SimRunner.new()
	while st.world.current_tick < t_end:
		r.advance_tick(st, pt.tile_pos)
	var c1: int = AnonTierSystem.total_captives(pt)
	print("   room=%d 俘 %d → 3 cadence 後 %d｜excess=%d forced=%d｜隊數 %d→%d" % [room, c0, c1,
		int(Probe.counts.get("asm.guardcap_player_excess", 0)), int(Probe.counts.get("asm.guardcap_forced", 0)), teams0, st.teams.size()])
	_check("A7b 母體地板：俘到 captive_room（%d）" % room, c0 == room and room > 0)
	_check("A7b asm.guardcap_player_excess＝0", int(Probe.counts.get("asm.guardcap_player_excess", 0)) == 0)
	_check("A7b captive 數只因逃跑／同化變少，沒有被 enforce 處置（不增）", c1 <= c0)
	_present["A7b"] = true


# ── A7c ──────────────────────────────────────────────────────────────────────
func _a7c() -> void:
	print("\n── A7c 養不起 ⇒ 放走＋玩家事件 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	_player_wins(st, 8)
	_exec(st, "aftermath_capture_kind")
	var c0: int = AnonTierSystem.total_captives(pt)
	pt.resources["food"] = 0.0
	var seq0: int = st.player_event_seq
	while st.world.current_tick % ManpowerSystem.CAPTIVE_CADENCE != 0:
		st.world.current_tick += 1
	ManpowerSystem.tick_all(st)
	var ev: Array = _events(st, "captive_unfed", seq0)
	print("   俘 %d → %d｜事件「%s」" % [c0, AnonTierSystem.total_captives(pt), String(ev[0]["text"]) if not ev.is_empty() else "（無）"])
	_check("A7c 母體地板：captive_food_ok＝false", not ManpowerSystem.captive_food_ok(st, pt) or AnonTierSystem.total_captives(pt) < c0)
	_check("A7c 養不起 ⇒ 俘虜被放走", AnonTierSystem.total_captives(pt) < c0)
	_check("A7c 發玩家事件「養不起，俘虜被放走」", not ev.is_empty())
	_present["A7c"] = true


# ── A8c ──────────────────────────────────────────────────────────────────────
func _a8c() -> void:
	print("\n── A8c 戰中俘虜（兩個方向）──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = _pt(st)
	var foe: TeamData = _foe(st, 6)
	var enc: EncounterSystem = _fight(st, FOE_ID, ptid)
	_fine(st, ptid)
	_fine(st, FOE_ID)
	var fa: Array = _units(st, FOE_ID, 0)
	var pa: Array = _units(st, ptid, 0)
	for i in range(2):
		_disable(st, fa[i]); fa[i]["is_prisoner"] = true
	_disable(st, pa[0]); pa[0]["is_prisoner"] = true
	var pc0: int = AnonTierSystem.total_captives(pt)
	var fc0: int = AnonTierSystem.total_captives(foe)
	var seq0: int = st.player_event_seq
	enc.resolve_encounter_end(st, "defender_win")
	var ev: Array = _events(st, "combat_end", seq0)
	var txt: String = String(ev[0]["text"]) if not ev.is_empty() else ""
	print("   玩家俘虜 %d→%d｜敵俘虜 %d→%d｜%s" % [pc0, AnonTierSystem.total_captives(pt), fc0, AnonTierSystem.total_captives(foe), txt])
	_check("A8c 玩家押住的 2 人進玩家 captive_groups", AnonTierSystem.total_captives(pt) - pc0 == 2)
	_check("A8c 敵方押住的 1 人進敵方 captive_groups", AnonTierSystem.total_captives(foe) - fc0 == 1)
	_check("A8c 事件寫兩筆（你押走 2、你方被押走 1）", txt.contains("你押走 2 人") and txt.contains("你方被押走 1 人"))
	# 押方全倒 ⇒ 回留場規則
	st = _world()
	ptid = st.get_player_team_id()
	pt = _pt(st)
	foe = _foe(st, 6)
	enc = _fight(st, FOE_ID, ptid)
	_fine(st, ptid)
	_wipe(st, FOE_ID)
	var pa2: Array = _units(st, ptid, 0)
	_disable(st, pa2[0]); pa2[0]["is_prisoner"] = true
	fc0 = AnonTierSystem.total_captives(foe)
	enc.resolve_encounter_end(st, "defender_win")
	_check("A8c 押方全倒 ⇒ 被押者不被帶走（回留場規則）", AnonTierSystem.total_captives(foe) == fc0)
	# 記名被押 ⇒ 放回
	st = _world()
	ptid = st.get_player_team_id()
	pt = _pt(st)
	foe = _foe(st, 6)
	enc = _fight(st, FOE_ID, ptid)
	_fine(st, ptid)
	_fine(st, FOE_ID)
	var pn: Array = _units(st, ptid, 1)
	var who: Dictionary = pn[pn.size() - 1]
	_disable(st, who); who["is_prisoner"] = true
	seq0 = st.player_event_seq
	enc.resolve_encounter_end(st, "attacker_win")
	ev = _events(st, "combat_end", seq0)
	txt = String(ev[0]["text"]) if not ev.is_empty() else ""
	_check("A8c 記名被押 ⇒ 放回、事件寫「被俘後放回（記名俘虜還沒做）」", txt.contains("被俘後放回（記名俘虜還沒做）") and pt.named_members.has(int(who["person_id"])) or int(who["person_id"]) == pt.leader_id)
	_present["A8c"] = true


# ── A8b ──────────────────────────────────────────────────────────────────────
func _a8b() -> void:
	print("\n── A8b 處置權看留場 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = _pt(st)
	_foe(st, 6, {"殘忍": 1.0, "貪婪": 0.0, "義氣": 0.0})
	var enc: EncounterSystem = _fight(st, FOE_ID, ptid)
	_fine(st, FOE_ID)
	var pa: Array = _units(st, ptid, 0)
	for i in range(pa.size()):
		if i < 2: _disable(st, pa[i])
		else: pa[i]["has_exited"] = true
	for u in _units(st, ptid, 1):
		u["has_exited"] = true
	var w0: int = _wounded(pt)
	var seq0: int = st.player_event_seq
	enc.resolve_encounter_end(st, "attacker_win")
	var ev: Array = _events(st, "combat_end", seq0)
	var txt: String = String(ev[0]["text"]) if not ev.is_empty() else ""
	print("   玩家撤離、敵方留場：%s" % txt)
	_check("A8b 玩家撤離 ⇒ NPC 處置玩家留下的失能者、進玩家事件", txt.contains("處置你方傷兵") and not bool(st.last_encounter_result.get("fate_pending", false)))
	# 雙方同 tick 全失能
	st = _world()
	ptid = st.get_player_team_id()
	var foe: TeamData = _foe(st, 5)
	enc = _fight(st, FOE_ID, ptid)
	_wipe(st, FOE_ID)
	_wipe(st, ptid)
	var c0: int = AnonTierSystem.total_captives(foe) + AnonTierSystem.total_captives(_pt(st))
	enc.resolve_encounter_end(st, "attacker_win")
	_check("A8b 雙方同 tick 全失能 ⇒ result＝attacker_win、零俘虜、無命運步驟",
		String(st.last_encounter_outcome.get("result", "")) == "attacker_win"
		and AnonTierSystem.total_captives(foe) + AnonTierSystem.total_captives(_pt(st)) == c0
		and not bool(st.last_encounter_result.get("fate_pending", false)))
	_present["A8b"] = true


# ── A8 ───────────────────────────────────────────────────────────────────────
func _npc_wins(vals: Dictionary, feud: bool = false, starve: bool = false) -> Dictionary:
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = _pt(st)
	var foe: TeamData = _foe(st, 20, vals)
	foe.captive_guard_ratio = 0.5
	if starve:
		foe.resources["food"] = 0.0
	if feud:
		RelationGraph.add_edge(st.persons[foe.leader_id].relation_edges, "feud", pt.leader_id, 1.0, st.world.current_tick)
	var enc: EncounterSystem = _fight(st, FOE_ID, ptid)
	_fine(st, FOE_ID)
	_wipe(st, ptid)
	var w0: int = _wounded(pt)
	var named0: int = pt.named_members.size()
	var seq0: int = st.player_event_seq
	enc.resolve_encounter_end(st, "attacker_win")
	var ev: Array = _events(st, "combat_end", seq0)
	return {"st": st, "choice": String(st.last_encounter_result.get("fate_choice", "")), "text": String(ev[0]["text"]) if not ev.is_empty() else "",
		"pending": bool(st.last_encounter_result.get("fate_pending", false)), "named_ok": pt.named_members.size() == named0 and st.persons.has(st.player_id) and not st.persons[st.player_id].is_dead}

func _a8() -> void:
	print("\n── A8 NPC 勝：當場選 ──")
	var cruel: Dictionary = _npc_wins({"殘忍": 1.0, "貪婪": 0.0, "義氣": 0.0})
	var greedy: Dictionary = _npc_wins({"殘忍": 0.0, "貪婪": 1.0, "義氣": 0.0})
	var loyal: Dictionary = _npc_wins({"殘忍": 0.0, "貪婪": 0.0, "義氣": 1.0})
	var feud: Dictionary = _npc_wins({"殘忍": 0.3, "貪婪": 0.0, "義氣": 0.5}, true)
	var starve: Dictionary = _npc_wins({"殘忍": 0.0, "貪婪": 1.0, "義氣": 0.4}, false, true)
	for x in [["殘忍", cruel], ["貪婪", greedy], ["義氣", loyal], ["feud", feud], ["養不起", starve]]:
		print("   %s ⇒ %s｜%s" % [x[0], x[1]["text"].substr(0, 0) if false else "", String(x[1]["text"])])
	var ch: Array = [cruel["choice"], greedy["choice"], loyal["choice"], feud["choice"], starve["choice"]]
	print("   選擇：%s" % str(ch))
	_check("A8 殘忍⇒殺、貪婪⇒俘、義氣⇒放", cruel["choice"] == "kill" and greedy["choice"] == "capture" and loyal["choice"] == "release")
	_check("A8 有 feud 邊 ⇒ 殺（殘忍 0.3＋feud 1.0 ＞ 義氣 0.5）", feud["choice"] == "kill")
	_check("A8 養不起 ⇒ capture 分數歸 0（不選俘）", starve["choice"] != "capture")
	_check("A8 NPC 勝無 pending", not cruel["pending"] and not greedy["pending"] and not loyal["pending"])
	_check("A8 雙方記名失能者（含玩家本人）不被殺、留原隊", cruel["named_ok"] and greedy["named_ok"] and loyal["named_ok"])
	_check("A8 事件含 NPC 的命運", String(cruel["text"]).contains("處置你方傷兵：殺了"))
	_present["A8"] = true


# ── A9 ───────────────────────────────────────────────────────────────────────
func _a9() -> void:
	print("\n── A9 追擊列的條件＝做的條件 ──")
	# E＝0
	var st: WorldState = _world()
	var r: Dictionary = _player_wins(st, 2, 2)
	_check("A9 E＝0 ⇒ 不列追擊", not _actions(st).has("aftermath_pursue"))
	# 可達閘假：敵人數多
	st = _world()
	var ptid: int = st.get_player_team_id()
	var foe: TeamData = _foe(st, 200)
	var enc: EncounterSystem = _fight(st, ptid, FOE_ID)
	_fine(st, ptid)
	for u in _units(st, FOE_ID):
		u["has_exited"] = true
	enc.resolve_encounter_end(st, "attacker_win")
	_check("A9 可達閘假（敵 %d、玩家 %d）⇒ 不列追擊" % [foe.population, _pt(st).population], not _actions(st).has("aftermath_pursue"))
	# 可列且按追
	st = _world()
	ptid = st.get_player_team_id()
	foe = _foe(st, 2)
	enc = _fight(st, ptid, FOE_ID)
	_fine(st, ptid)
	for u in _units(st, FOE_ID):
		u["has_exited"] = true
	enc.resolve_encounter_end(st, "attacker_win")
	var e: int = int(st.last_encounter_result.get("pursuit_e", 0))
	var p0: int = foe.population
	var listed: bool = _actions(st).has("aftermath_pursue")
	_exec(st, "aftermath_pursue")
	print("   E=%d｜列=%s｜敵 %d→%d" % [e, str(listed), p0, foe.population])
	_check("A9 可列且按追 ⇒ 敗方減 min(3, E)", listed and p0 - foe.population == mini(mini(NpcCombatSystem.PURSUIT_KILL_CAP, e), p0))
	_present["A9"] = true


# ── A10 ──────────────────────────────────────────────────────────────────────
func _resident_setup(st: WorldState, atk: int, same_faction: bool = true) -> Dictionary:
	var foe: TeamData = st.teams[FOE_ID]
	var x: Vector2i = foe.tile_pos
	var tile: HexTileData = st.world.tiles[x.x * 1000 + x.y]
	tile.outpost_level = 1
	tile.outpost_owner = FOE_ID
	tile.outpost_type = "civilian"
	var res: TeamData = _foe(st, 6, {"慎重": 1.0}, FOE_ID + 5)
	res.tile_pos = x
	res.known_reputations[atk] = 0.9
	# ★過渡閘（藍圖 2026-10-15）：居民＝敗方勢力的隊 ⇒ 佈置把敗方與居民放進同一個既有勢力（非玩家勢力）
	var fid: int = -1
	var pfid: int = _pt(st).faction_id
	for f in st.factions:
		if int(f) != pfid:
			fid = int(f)
			break
	st.set_team_faction(foe, fid)
	if same_faction:
		st.set_team_faction(res, fid)
	return {"tile": tile, "resident": res, "fid": fid}

# 活著、team_id 指向不存在的隊的人數（systems HOW：屠村不得留下孤兒）
static func _dangling(st: WorldState) -> int:
	var n: int = 0
	for pid in st.persons:
		var p: PersonData = st.persons[pid]
		if not p.is_dead and p.team_id != -1 and not st.teams.has(p.team_id):
			n += 1
	return n

func _player_takes_outpost(st: WorldState, same_faction: bool = true) -> Dictionary:
	var ptid: int = st.get_player_team_id()
	_foe(st, 4)
	var rs: Dictionary = _resident_setup(st, ptid, same_faction)
	var enc: EncounterSystem = _fight(st, ptid, FOE_ID)
	_fine(st, ptid)
	for u in _units(st, FOE_ID):
		_kill(st, u)
	enc.resolve_encounter_end(st, "attacker_win")
	return rs

func _a10() -> void:
	print("
── A10 居民處置問玩家 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	_player_takes_outpost(st)
	var acts: Array = _actions(st)
	print("   residents_pending=%s｜可做 %s" % [str(st.last_encounter_result.get("residents_pending")), str(acts.filter(func(a): return String(a).begins_with("residents")))])
	_check("A10 玩家攻佔 ⇒ 三項列出", PlayerCommandSystem.AFTERMATH_RESIDENTS.all(func(a): return acts.has(a)))
	_advance(st)
	_check("A10 未決推進＝放棄佔領（pending 清掉、居民還在）", (st.last_encounter_result.get("residents_pending", {}) as Dictionary).is_empty()
		and st.teams.has(FOE_ID + 5))
	# 過渡閘：路過的隊（不屬敗方勢力）不算居民
	st = _world()
	_player_takes_outpost(st, false)
	_check("A10 過渡閘：同格但不屬敗方勢力的隊不算居民（無 pending）",
		(st.last_encounter_result.get("residents_pending", {}) as Dictionary).is_empty() and st.teams.has(FOE_ID + 5))
	# 玩家下令屠村：記名先散、零懸空、句子照實
	st = _world()
	var rs: Dictionary = _player_takes_outpost(st)
	var res: TeamData = rs["resident"]
	var named_alive: int = 0
	for pid in ([res.leader_id] as Array) + res.named_members:
		if st.persons.has(pid) and not st.persons[pid].is_dead:
			named_alive += 1
	var d0: int = _dangling(st)
	var r: Dictionary = _exec(st, "residents_massacre")
	var d1: int = _dangling(st)
	print("   屠村前居民活的記名 %d 人｜懸空 %d → %d｜%s" % [named_alive, d0, d1, String(r.get("msg", ""))])
	_check("A10 母體地板：被屠那隊至少一名活的記名成員（%d）" % named_alive, named_alive >= 1)
	_check("A10 屠村後活人懸空 team_id＝0（%d）" % d1, d1 == 0 and not st.teams.has(FOE_ID + 5))
	_check("A10 屠村句照實：你下令屠村、逃散、據點易主；不寫成戰鬥", String(r.get("msg", "")).begins_with("你下令屠村")
		and String(r.get("msg", "")).contains("逃散") and String(r.get("msg", "")).contains("據點易主") and not String(r.get("msg", "")).contains("戰"))
	# NPC 攻方維持休眠（藍圖 2026-10-15 裁）：攻下有居民的據點 ⇒ 不屠、不強佔、不歸順，與 main 同；開路那天這格翻紅再改
	st = _world()
	ptid = st.get_player_team_id()
	_foe(st, 20, {"殘忍": 1.0}, FOE_ID + 2)
	_foe(st, 4)
	var rs2: Dictionary = _resident_setup(st, FOE_ID + 2)
	var r2pop: int = (rs2["resident"] as TeamData).population
	var enc: EncounterSystem = _fight(st, FOE_ID + 2, FOE_ID)
	_fine(st, FOE_ID + 2)
	for u in _units(st, FOE_ID):
		_kill(st, u)
	Probe.counts.erase("res.seen")
	enc.resolve_encounter_end(st, "attacker_win")
	_check("A10 NPC 攻方休眠對照：居民隊還在、人數不變、無 pending、res.seen＝0", st.teams.has(FOE_ID + 5)
		and (st.teams[FOE_ID + 5] as TeamData).population == r2pop
		and (st.last_encounter_result.get("residents_pending", {}) as Dictionary).is_empty()
		and int(Probe.counts.get("res.seen", 0)) == 0)
	var x2: Vector2i = (rs2["tile"] as HexTileData).tile_pos
	_check("A10 佈置：玩家隊站在被佔的那格（%s／%s）" % [str(st.teams[ptid].tile_pos) if st.teams.has(ptid) else "隊已消失", str(x2)],
		not st.teams.has(ptid) or st.teams[ptid].tile_pos == x2)
	_check("A10 同格的玩家隊不被當居民屠掉", st.teams.has(ptid))
	_present["A10"] = true


# ── A11 ──────────────────────────────────────────────────────────────────────
func _a11() -> void:
	print("\n── A11 玩家全隊陣亡 ──")
	var st: WorldState = _world()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = _pt(st)
	var pid0: int = st.player_id
	_foe(st, 20)
	var enc: EncounterSystem = _fight(st, FOE_ID, ptid)
	_fine(st, FOE_ID)
	for u in _units(st, ptid):
		_kill(st, u)
	# 沒上場的匿名也一併清掉 ⇒ 真的全滅
	var off: int = pt.population - _units(st, ptid).size()
	if off > 0:
		AnonTierSystem.kill_random(pt, off, "bed")
	enc.resolve_encounter_end(st, "attacker_win")
	print("   game_over=%s｜player_id %d→%d" % [str(st.game_over), pid0, st.player_id])
	_check("A11 走 handle_player_succession（換附身或 game_over）", st.game_over or st.player_id != pid0)
	_present["A11"] = true


# ── A12 ──────────────────────────────────────────────────────────────────────
func _a12() -> void:
	print("\n── A12 帶團頁一行＝manpower 實際扣的糧 ──")
	var st: WorldState = _world()
	var pt: TeamData = _pt(st)
	_player_wins(st, 8)
	_exec(st, "aftermath_capture_kind")
	pt.resources["food"] = 500.0
	var cap: Dictionary = PlayerApiMapper.map_captives(pt)
	while st.world.current_tick % ManpowerSystem.CAPTIVE_CADENCE != 0:
		st.world.current_tick += 1
	var f0: float = float(pt.resources.get("food", 0))
	ManpowerSystem.tick_all(st)
	var f1: float = float(pt.resources.get("food", 0))
	var lines: Array = TextUiMain.new()._build_survival_lines(PlayerApiMapper.map_controlled_team(st), {})
	var line: String = ""
	for l in lines:
		if String(l).begins_with("俘虜 "):
			line = String(l)
	print("   面板「%s」｜manpower 扣 %.2f" % [line, f0 - f1])
	_check("A12 帶團頁有俘虜那一行", line != "" and line.contains("每日吃 %.1f 糧" % float(cap["food_per_day"])))
	_check("A12 日耗數字＝manpower 實際扣的糧", absf((f0 - f1) - float(cap["food_per_day"])) < 0.01)
	_present["A12"] = true
