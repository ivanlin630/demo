extends SceneTree
# @bed-kind: invariant
# ══ A4「目的地屬任務」：任務換手時 move_target 由新任務重給或清空，禁沿用 ════════════════════════
# spec：`docs/superpowers/specs/2026-10-06-a4-a-target-belongs-to-its-task-HOW.md` §2
#
# 格：P1 陽性對照：fp 那個世界（warring_states、seed 20260922、無玩家）t65 Team26 就地開工升級 workshop
#        ⇒ 換手那一刻 move_target ∈ {(22,4), (-1,-1)}；再推幾 tick 它還站在工地 (22,4)
#        ★修前：它帶著前一段的 (20,6)（一格沒有工程的地）走離工地 ⇒ 必紅
#     P2 不變量：Probe 開跑一段，每一次換手（try_set／transition／release）**回傳那一刻**取樣
#        move_target ＝ 那一次給的值（TaskArbiter._note_handoff 計 handoff.<path>.ok／.bad）
#        ⇒ .bad 三條全 0；母體地板：transition／try_set 兩條各自 ok ≥ 1
#     P3 反向掃：`current_task = ` 的直接寫入（非 ==）在 scripts/simulation 的命中，跟 task_arbiter.gd 註解裡那份
#        窮盡結論對照（寫入路只有 try_set／release／transition 三條＋新隊建立豁免＋recruit_tutorial）

const CFG: String = "warring_states"
const SEED: int = 20260922
const P1_TEAM: int = 26
const P1_TICK: int = 65
const P1_SITE: Vector2i = Vector2i(22, 4)
const P2_TICKS: int = 3000

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P1", "P2", "P3"]


func _initialize() -> void:
	print("=== task_target_handoff：目的地屬任務 ===")
	_p1_team26()
	_p2_every_handoff()
	_p3_direct_writes()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)], missing.is_empty())
	print("\n=== task_target_handoff DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


func _p1_team26() -> void:
	print("\n── P1 Team26 t65：就地開工時不得帶著舊目的地 ──")
	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % CFG, true)
	Probe.enabled = false
	Probe.reset()
	var runner := SimRunner.new()
	var before_task: String = ""
	var mt_at: Vector2i = Vector2i(-9, -9)
	var task_at: String = ""
	while ws.world.current_tick < P1_TICK:
		var t: TeamData = ws.teams.get(P1_TEAM)
		before_task = String(t.current_task) if t != null else ""
		runner.advance_tick(ws, Vector2i(-1, -1))
	var t26: TeamData = ws.teams.get(P1_TEAM)
	_check("★母體地板：Team%d 存在" % P1_TEAM, t26 != null)
	if t26 == null:
		_cells_ran.append("P1")
		return
	mt_at = t26.move_target
	task_at = String(t26.current_task)
	var site: HexTileData = ws.world.tiles.get(P1_SITE.x * 1000 + P1_SITE.y)
	print("   t%d Team%d：%s → %s｜pos=%s｜move_target=%s｜工地 %s ct=%s target=%s" % [ws.world.current_tick, P1_TEAM,
		before_task, task_at, str(t26.tile_pos), str(mt_at), str(P1_SITE),
		str(site.construction_team_id) if site != null else "-", str(site.construction_target) if site != null else "-"])
	_check("★★母體地板：t%d Team%d 真的換成建設、工地在腳下 %s（ct ＝ %d）" % [P1_TICK, P1_TEAM, str(P1_SITE), P1_TEAM],
		task_at == TeamData.TASK_BUILD and t26.tile_pos == P1_SITE and site != null and site.construction_team_id == P1_TEAM)
	_check("★★★P1 換手後 move_target ∈ {%s, (-1,-1)}（%s）" % [str(P1_SITE), str(mt_at)],
		mt_at == P1_SITE or mt_at == Vector2i(-1, -1))
	for _i in range(30):
		runner.advance_tick(ws, Vector2i(-1, -1))
	print("   再推 30 tick：pos=%s｜task=%s" % [str(t26.tile_pos), str(t26.current_task)])
	_check("★★P1 沒有走離工地（pos 仍是 %s）" % str(P1_SITE), t26.tile_pos == P1_SITE)
	_cells_ran.append("P1")


func _p2_every_handoff() -> void:
	print("\n── P2 每一次換手回傳那一刻：move_target ＝ 那一次給的值 ──")
	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % CFG, true)
	var runner := SimRunner.new()
	for _i in range(P2_TICKS):
		runner.advance_tick(ws, Vector2i(-1, -1))
	var rows: Array = []
	for path in ["try_set", "transition", "release"]:
		var ok: int = int(Probe.counts.get("handoff.%s.ok" % path, 0))
		var bad: int = int(Probe.counts.get("handoff.%s.bad" % path, 0))
		rows.append([path, ok, bad])
		print("   %-10s ok %d｜bad %d" % [path, ok, bad])
	var bads: Array = Probe.samples.get("handoff.bad", [])
	if not bads.is_empty():
		print("   壞的取樣：%s" % str(bads.slice(0, 5)))
	_check("★母體地板：try_set 換手 ≥ 1（%d）" % int(rows[0][1] + rows[0][2]), int(rows[0][1]) + int(rows[0][2]) >= 1)
	_check("★母體地板：transition 換手 ≥ 1（%d）" % int(rows[1][1] + rows[1][2]), int(rows[1][1]) + int(rows[1][2]) >= 1)
	for r in rows:
		_check("★★★P2 %s 的 bad ＝ 0（%d）" % [String(r[0]), int(r[2])], int(r[2]) == 0)
	_cells_ran.append("P2")


func _p3_direct_writes() -> void:
	print("\n── P3 `current_task = ` 的直接寫入（反向掃，scripts/simulation）──")
	var hits: Array = []
	var dir := DirAccess.open("res://scripts/simulation")
	var files: Array = dir.get_files()
	for sub in dir.get_directories():
		for f2 in DirAccess.open("res://scripts/simulation/" + String(sub)).get_files():
			files.append(String(sub) + "/" + String(f2))
	for f in files:
		if not String(f).ends_with(".gd"):
			continue
		var text: String = FileAccess.get_file_as_string("res://scripts/simulation/" + String(f))
		var i: int = 0
		for l in text.split("\n"):
			i += 1
			var code: String = l.split("#")[0]
			if code.contains("current_task = ") and not code.contains("current_task == "):
				hits.append("%s:%d" % [f, i])
	print("   命中 %d：%s" % [hits.size(), str(hits)])
	var outside: Array = hits.filter(func(h): return not String(h).begins_with("task_arbiter.gd"))
	print("   task_arbiter.gd 以外 %d：%s" % [outside.size(), str(outside)])
	_check("★母體地板：真的掃到寫入（%d）" % hits.size(), hits.size() >= 1)
	_cells_ran.append("P3")
