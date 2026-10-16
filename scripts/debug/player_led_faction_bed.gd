extends SceneTree
# @bed-kind: acceptance
# slice: 你領導的勢力不自動定目標＋收編要告訴你（spec 2026-10-15-player-led-faction-no-ai-goals-and-subjugate-tells-HOW）
# ★格（修前紅除註明）：
#   F1  玩家當盟主 30 天：勢力 goals 恆空、intent 恆空；對照 NPC 勢力 goals 非空 >0 次
#   F1b 玩家設目標 ⇒ goals＝[override] 恆定 30 天；成員 faction_stakes 讀不讀得到它＝只印現況（已知缺陷：詞彙沒有讀者，見 known_issues）
#   F2  徵收率 30 天恆 0.10；玩家按 [B] 設 30 ⇒ 0.30（修前已綠：唯一寫者本來就是玩家指令）
#   F3  以玩家盟主隊為 sender 的勢力名義外交入口 0 次；對照 NPC 盟主 >0
#   F4a 附身成為盟主、成員帶著指派 ⇒ STRATEGIC_INTERVAL 內清空（實際機制＝每小時那一圈）
#   F4b NPC 盟主死、繼位給玩家隊 ⇒ succeed_or_disband_faction 那一次呼叫就清空
#   F4c NPC 隊帶指派入玩家勢力 ⇒ set_team_faction 當下清空
#   F5  十支盟主側入口對玩家盟主隊 0 次；對照 NPC 盟主 >0（不足的那支印「不可判」，不湊）
#   F5b 獨立附身隊：十支 0 次
#   F5c NPC 勢力裡紮根的玩家成員隊：據點 owner 30 天不變（佈置先證明 AI 會遷：遷值 > 門檻、對照村真的遷了）
#   F6  玩家勢力兩支 NPC 成員照常想事（last_decision_tick 有前進、任務有變化）
#   F7  玩家隊當 NPC 勢力成員、背叛驅力過硬門檻 ⇒ 30 天仍在；對照同條件 NPC 成員走了
#   S1  列＝做：無統領 ⇒ 標「要有統領才能收編」、按下 ok=false、勢力數不變；敗方屬別勢力 ⇒ 標「已屬勢力」；有統領 ⇒ 成功
#   S1b 做後驗：收編沒有真的發生 ⇒ 回「收編沒有成功」
#   S2  事件：成立勢力／加入你的勢力兩句、subjects 含敗方、推進停在它；盟友收編 ⇒ 旁觀句、不停；NPC 對 NPC／玩家是敗方 ⇒ describe 句
#   S3  敵對帳：攻擊過的 TeamX 被收編 ⇒ 出帳（is_hostile=false、交換 honest）；之後背叛 → 攻擊 ⇒ 重新標
#   S4a／S4b／S4c 三條投降（遭遇中求降／戰中投降／預備遭遇投降）被接受但門關著（勝方無統領）⇒ 不回成功句、玩家 faction_id 不變（修前紅）
#   S4  真實投降（預備遭遇那條）、門開著 ⇒ 玩家進勝方勢力、佇列恰一則「你臣服於…」、推進停在它
#   P1  面板：玩家領導 ⇒「目標：無（等你下令）」＋「還沒做的盟主動作」、無「AI 目標」；玩家當成員 ⇒「勢力目標」
# ★世界：explicit 小世界（GameSetup explicit 模式）——佈置可控、30 天跑得完；P1 用真畫面 TextUI。
# ★負對照：BED_ONLY 跑子集（見 docs/measurements/2026-10-16-player-led-faction/）。

const EXPECTED: Array = ["F1", "F1b", "F2", "F3", "F4a", "F4b", "F4c", "F5", "F5b", "F5c", "F6", "F7", "S1", "S1b", "S2", "S3", "S4a", "S4b", "S4c", "S4", "P1"]
const SEED: int = 20261015
const DAYS: int = 30
const SIDE: Array = ["promote", "herald", "scout", "distribute", "holding", "migrant", "invest", "relocate_order", "self_relocate", "contact"]
var _errors: int = 0
var _present: Dictionary = {}
var _only: Dictionary = {}

func _on(fn: String) -> bool:
	return _only.is_empty() or _only.has(fn)

func _initialize() -> void:
	print("=== player_led_faction：你領導的勢力不自動定目標＋收編要告訴你 ===")
	var only: String = OS.get_environment("BED_ONLY")
	if only != "":
		for f in only.split(","):
			_only[String(f).strip_edges()] = true
		print("★★★BED_ONLY=%s：只跑子集，這一輪不能當驗收" % only)
	if _on("_world_a"): _world_a()
	if _on("_world_b"): _world_b()
	if _on("_world_c"): _world_c()
	if _on("_f4b"): _f4b()
	if _on("_s1"): _s1()
	if _on("_s2"): _s2()
	if _on("_s3"): _s3()
	if _on("_s4"): _s4()
	if _on("_p1"): await _p1()
	var miss: Array = []
	for c in EXPECTED:
		if not _present.has(c):
			miss.append(c)
	if not miss.is_empty() and _only.is_empty():
		_check("到場點名缺 %s" % str(miss), false)
	print("=== player_led_faction DONE === 到場 %d／%d errors: %d" % [_present.size(), EXPECTED.size(), _errors])
	quit(1 if _errors > 0 else 0)

func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)

func _cell(c: String) -> void:
	_present[c] = true

# ── 佈置 ─────────────────────────────────────────────────────────────────────
# 一支 explicit 隊。outpost_terrain 非空 ⇒ 腳下有自家據點（紮根）。
static func _team(id: int, pos: Vector2i, pop: int, fid: int, leader: bool, vals: Dictionary,
		skills: Dictionary = {}, outpost_terrain: String = "", tags: Array = []) -> Dictionary:
	var d: Dictionary = {"id": id, "name": "T%d" % id, "tile_pos": [pos.x, pos.y], "population": pop,
		"tags": tags, "faction_id": fid, "is_faction_leader": leader, "anon_tiers": {"平民": pop - 1},
		"resources": {"food": 20000.0, "coin": 200.0, "material": 400.0},
		"leader": {"name": "L%d" % id, "skills": skills, "values": vals}}
	if outpost_terrain != "":
		d["outpost"] = {"type": "civilian", "level": 1, "terrain": outpost_terrain, "tile_food_init": 5000}
	return d

func _mk(teams: Array, player_tid: int) -> WorldState:
	seed(SEED)
	var cfg: Dictionary = {"seed": SEED, "mode": "explicit", "max_ticks": 100000,
		"map": {"radius": 16, "resource_richness": 5}, "teams": teams}
	if player_tid != -1:
		cfg["player"] = {"team_id": player_tid}
	return MeasureBedHelper.arm_and_setup(cfg, false)

func _run(st: WorldState, ticks: int, each: Callable = Callable()) -> void:
	var runner := SimRunner.new()
	var end_tick: int = st.world.current_tick + ticks
	while st.world.current_tick < end_tick:
		runner.advance_tick(st, Vector2i(-1, -1))
		if each.is_valid():
			each.call()

static func _c(k: String) -> int:
	return int(Probe.counts.get(k, 0))

# 十支：玩家側 0、對照側 >0（不足 ⇒ 不可判）
func _side_cells(tag: String, need_npc: bool) -> bool:
	var ok: bool = true
	for k in SIDE:
		var pc: int = _c("side.call.%s.pc" % k)
		var npc: int = _c("side.call.%s.npc" % k)
		print("    %s side.call.%s：pc=%d npc=%d" % [tag, k, pc, npc])
		if pc != 0:
			ok = false
		if need_npc and npc == 0:
			print("    ★%s 的 %s 對照 npc=0 ⇒ 這一支不可判（不湊）" % [tag, k])
	return ok

# ── 世界 A：玩家當盟主、兩支 NPC 成員；對照 NPC 盟主勢力 ───────────────────────
func _world_a() -> void:
	print("\n── 世界 A：玩家當盟主 30 天（F1 F2 F3 F4a F4c F5 F6），再 30 天設目標（F1b）──")
	var bold: Dictionary = {"慎重": 0.05, "野心": 0.8, "好戰": 0.6, "求生欲": 0.5, "義氣": 0.5}
	var st: WorldState = _mk([
		# ★玩家盟主用跟對照勢力同一組大膽人格：AI 一接手就會產 goals ⇒ F1 的「goals 恆空」那一半才分辨得出（n1 血證：慎重 0.5 的人格 AI 本來就產空 goals）
		_team(0, Vector2i(8, 8), 10, 1, true, bold, {"統領": 0.8}, "plains", ["統領"]),
		_team(1, Vector2i(10, 8), 8, 1, false, {"慎重": 0.5}, {}, "plains"),
		_team(2, Vector2i(8, 11), 8, -1, false, {"慎重": 0.5}, {}, "plains"),
		_team(3, Vector2i(-8, -6), 12, 2, true, bold, {"統領": 0.8}, "plains", ["統領"]),
		_team(4, Vector2i(-6, -6), 8, 2, false, {"慎重": 0.5}, {}, "plains"),
		_team(5, Vector2i(-8, -4), 8, 2, false, {"慎重": 0.5}, {}, "plains"),
		_team(6, Vector2i(-4, -8), 6, -1, false, {"慎重": 0.5}, {}, "plains"),
		_team(7, Vector2i(4, 4), 6, -1, false, {"慎重": 0.5}, {}, "plains"),
	], 0)
	var pt: TeamData = st.teams[0]
	var pf = st.factions[pt.faction_id]
	var cf = st.factions[(st.teams[3] as TeamData).faction_id]
	_check("佈置：玩家隊是附身盟主（player_controlled）、勢力是玩家領導", pt.player_controlled and st.is_player_led(pf) and not st.is_player_led(cf))
	# F4c：NPC 隊帶指派入玩家勢力 ⇒ 當下清空
	var m2: TeamData = st.teams[2]
	m2.strategic_assignments = {77: Vector2i(1, 1)}
	st.set_team_faction(m2, pf.faction_id, WorldState.JOIN_SETUP)
	_check("F4c NPC 隊帶指派入玩家勢力 ⇒ set_team_faction 當下清空（剩 %s）" % str(m2.strategic_assignments), m2.strategic_assignments.is_empty())
	_cell("F4c")
	# F4a：成員身上留著指派（附身成為盟主前的殘單）⇒ STRATEGIC_INTERVAL 內清空
	var m1: TeamData = st.teams[1]
	m1.strategic_assignments = {77: Vector2i(1, 1)}
	var t0: int = st.world.current_tick
	var cleared_at: Array = [-1]
	var ticks: Array = [0, 0, 0, 0]   # 玩家領導 tick 數、goals 非空、intent 非空、徵收率≠0.10
	var cf_goal_ticks: Array = [0]
	var cf_assign_ticks: Array = [0]
	var mem: Dictionary = {1: {"dec": 0, "task": 0, "ldt": m1.last_decision_tick, "ct": m1.current_task},
		2: {"dec": 0, "task": 0, "ldt": m2.last_decision_tick, "ct": m2.current_task}}
	var sample := func() -> void:
		if cleared_at[0] == -1 and m1.strategic_assignments.is_empty():
			cleared_at[0] = st.world.current_tick
		if st.is_player_led(pf):
			ticks[0] += 1
			if not pf.goals.is_empty(): ticks[1] += 1
			if not (pf.intent is Dictionary and pf.intent.is_empty()): ticks[2] += 1
			if absf(pf.tribute_rate - 0.10) > 0.0001: ticks[3] += 1
		if not cf.goals.is_empty(): cf_goal_ticks[0] += 1
		for tid in cf.member_team_ids:
			var ct: TeamData = st.teams.get(tid)
			if ct != null and tid != cf.leader_team_id and not ct.strategic_assignments.is_empty():
				cf_assign_ticks[0] += 1
		for tid in mem:
			var t: TeamData = st.teams.get(tid)
			if t == null: continue
			if t.last_decision_tick != int(mem[tid]["ldt"]):
				mem[tid]["dec"] += 1; mem[tid]["ldt"] = t.last_decision_tick
			if t.current_task != String(mem[tid]["ct"]):
				mem[tid]["task"] += 1; mem[tid]["ct"] = t.current_task
	_run(st, DAYS * WorldState.TICKS_PER_DAY, sample)
	var total: int = DAYS * WorldState.TICKS_PER_DAY
	print("    玩家領導 tick %d／%d｜goals 非空 %d｜intent 非空 %d｜徵收率≠0.10 %d｜對照 goals 非空 %d｜對照成員有指派 %d" % [
		ticks[0], total, ticks[1], ticks[2], ticks[3], cf_goal_ticks[0], cf_assign_ticks[0]])
	print("    probe：faction.goals_rebuild_player_led=%d strategic.clear_player_led=%d diplo.skip_player_controlled=%d side.skip_player_controlled=%d" % [
		_c("faction.goals_rebuild_player_led"), _c("strategic.clear_player_led"), _c("diplo.skip_player_controlled"), _c("side.skip_player_controlled")])
	var whole: bool = ticks[0] == total
	_check("佈置：30 天全程是玩家領導（%d／%d）" % [ticks[0], total], whole)
	_check("F1 玩家勢力 goals 恆空（非空 %d tick）、intent 恆空（非空 %d tick）；對照 NPC 勢力 goals 非空 %d tick >0" % [ticks[1], ticks[2], cf_goal_ticks[0]],
		whole and ticks[1] == 0 and ticks[2] == 0 and cf_goal_ticks[0] > 0)
	_cell("F1")
	_check("F4a 成員殘留指派在 STRATEGIC_INTERVAL（%d tick）內清空（實際 %d tick 後）" % [StrategicAiSystem.STRATEGIC_INTERVAL, cleared_at[0] - t0],
		cleared_at[0] != -1 and cleared_at[0] - t0 <= StrategicAiSystem.STRATEGIC_INTERVAL)
	if cf_assign_ticks[0] == 0:
		print("    ★F4a 對照：NPC 勢力成員 30 天沒有指派 ⇒ 對照這一半不可判（不湊）")
	_cell("F4a")
	var pc_dip: int = _c("dip.proactive_call.pc")
	var npc_dip: int = _c("dip.proactive_call.npc")
	_check("F3 以玩家盟主隊為 sender 的勢力外交入口 %d 次＝0；對照 NPC 盟主 %d 次 >0" % [pc_dip, npc_dip], pc_dip == 0 and npc_dip > 0)
	_cell("F3")
	_check("F5 十支對玩家盟主隊 0 次", _side_cells("F5", true))
	_cell("F5")
	_check("F6 玩家勢力兩支 NPC 成員照常想事（想事次數 %d／%d、任務變化 %d／%d）" % [mem[1]["dec"], mem[2]["dec"], mem[1]["task"], mem[2]["task"]],
		int(mem[1]["dec"]) > 0 and int(mem[2]["dec"]) > 0 and int(mem[1]["task"]) + int(mem[2]["task"]) > 0)
	_cell("F6")
	# F2：30 天恆 0.10；玩家按 [B] 設 30 ⇒ 0.30
	var cmd := PlayerCommandSystem.new()
	st.player_state["tribute_rate_input"] = 0.30
	var r2: Dictionary = cmd.execute_action(st, -1, "set_tribute_rate")
	_check("F2 徵收率 30 天恆 0.10（偏離 %d tick）；玩家設 30 ⇒ %.2f（%s）" % [ticks[3], pf.tribute_rate, str(r2)],
		ticks[3] == 0 and absf(pf.tribute_rate - 0.30) < 0.0001)
	_cell("F2")
	# F1b：玩家設「徵收」⇒ goals＝["徵收"] 恆定 30 天，成員 faction_stakes 讀得到（spec player-faction-goal：詞換成引擎詞，原本只印不判那半改成真斷言）
	st.player_state["faction_goal_input"] = "徵收"
	var rg: Dictionary = cmd.execute_action(st, -1, "set_faction_goal")
	# ★設下去到下一次每小時重建之間 goals 還是舊值（_rebuild_goals 每勢力每小時）⇒ 從第一次到位起算「恆定」，到位本身要在一小時內
	var off: Array = [0, 0, -1]   # 到位後偏離 tick、到位後 tick 數、到位 tick
	var tg0: int = st.world.current_tick
	var sample_b := func() -> void:
		if st.is_player_led(pf):
			if off[2] == -1 and pf.goals == ["徵收"]: off[2] = st.world.current_tick
			if off[2] != -1:
				off[1] += 1
				if pf.goals != ["徵收"]: off[0] += 1
	_run(st, DAYS * WorldState.TICKS_PER_DAY, sample_b)
	var stakes: Array = DecisionContext.gather(st, m1).faction_stakes
	print("    F1b 成員 faction_stakes＝%s" % str(stakes))
	_check("F1b 玩家設「徵收」（%s）⇒ %d tick 後到位（≤ 一小時）、之後 goals＝[徵收] 恆定（偏離 %d／%d tick）、成員 faction_stakes 讀到它" % [str(rg), off[2] - tg0, off[0], off[1]],
		off[2] != -1 and off[2] - tg0 <= WorldState.TICKS_PER_HOUR and off[1] >= DAYS * WorldState.TICKS_PER_DAY - WorldState.TICKS_PER_HOUR and off[0] == 0
		and stakes.has("徵收"))
	_cell("F1b")

# ── 世界 B：玩家隊是 NPC 勢力裡紮根的成員（F5c、F7）─────────────────────────────
func _world_b() -> void:
	print("\n── 世界 B：玩家隊當 NPC 勢力成員、紮在山地據點 30 天（F5c F7）──")
	var traitor: Dictionary = {"野心": 1.0, "信義": 0.0, "義氣": 0.0, "慎重": 0.5, "求生欲": 0.6}
	var loyal: Dictionary = {"野心": 0.0, "信義": 1.0, "義氣": 1.0, "慎重": 0.5, "求生欲": 0.7}
	var st: WorldState = _mk([
		_team(0, Vector2i(8, 8), 3, 1, true, {"慎重": 0.5}, {"統領": 0.9}, "plains", ["統領"]),
		_team(1, Vector2i(12, 8), 12, 1, false, traitor, {}, "mountain"),     # 玩家
		_team(2, Vector2i(8, 12), 12, 1, false, traitor, {}, ""),             # 對照：背叛（不紮根）
		_team(3, Vector2i(10, 10), 5, 1, false, loyal, {}, "mountain"),       # 對照：自願遷（忠、不背叛）
	], 1)
	var pt: TeamData = st.teams[1]
	var fid: int = pt.faction_id
	var lord: TeamData = st.teams[0]
	for tid in [0, 1, 2, 3]:
		st.snapshot_faction_member(tid, st.world.current_tick)   # 讓成員知道盟主的人口（背叛評估讀 known_member_states）
	var ptile: HexTileData = st.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	var ct3: TeamData = st.teams[3]
	var ctile: HexTileData = st.world.tiles.get(ct3.tile_pos.x * 1000 + ct3.tile_pos.y)
	print("    對照村 Team3 在 %s、格 %s" % [str(ct3.tile_pos), "有" if ctile != null else "無"])
	_check("佈置：玩家隊附身、非盟主、腳下是自家山地據點；盟主不是玩家", pt.player_controlled and lord.team_id == st.factions[fid].leader_team_id
		and ptile != null and ptile.outpost_owner == pt.team_id and ptile.terrain == "mountain")
	# ★佈置先證明 AI 會遷：玩家這一村的遷值 > 門檻（與 _try_self_relocate 同算式）
	var fai := FactionAISystem.new()
	var est := VillageEstimate.make(ptile.terrain, ptile.outpost_level, ptile.farming_level, pt.population)
	var best: Dictionary = fai._best_relocate_target(st, fid, pt, est, PersistStrength.compute(st, pt))
	print("    玩家村遷值 %.2f（門檻 %.2f）→ %s" % [float(best["value"]), FactionAISystem.RELOCATE_THRESHOLD, str(best["pos"])])
	var a_bt: Dictionary = DiplomaticAiSystem.new().betrayal_assessment(st, pt, lord)
	print("    玩家隊背叛驅力 %.2f（硬門檻 %.2f）would=%s" % [float(a_bt["driver"]), DiplomaticAiSystem.BETRAY_DRIVE_HARD, str(a_bt["would_betray"])])
	var owner_changes: Array = [0]
	var sample := func() -> void:
		if ptile.outpost_owner != pt.team_id: owner_changes[0] += 1
	_run(st, DAYS * WorldState.TICKS_PER_DAY, sample)
	var ctl_moved: bool = ctile.outpost_owner != 3
	print("    對照村（Team3，山地、忠）據點 owner 現為 %d；relocate.self=%d" % [ctile.outpost_owner, _c("relocate.self")])
	_check("F5c 玩家村據點 owner 30 天不變（變動 %d tick）；佈置成立＝遷值 %.2f > 門檻、對照村真的棄了據點（%s）" % [owner_changes[0], float(best["value"]), str(ctl_moved)],
		owner_changes[0] == 0 and float(best["value"]) > FactionAISystem.RELOCATE_THRESHOLD and ctl_moved)
	_check("F5c 十支對 NPC 勢力裡的玩家成員隊 0 次", _side_cells("F5c", false))
	_cell("F5c")
	var t2: TeamData = st.teams.get(2)
	var ctl_left: bool = t2 == null or t2.faction_id != fid
	print("    背叛：faction.leave.betrayal=%d betray.skip_player_controlled=%d｜對照 Team2 faction=%d" % [
		_c("faction.leave.betrayal"), _c("betray.skip_player_controlled"), t2.faction_id if t2 != null else -99])
	_check("F7 玩家隊（驅力 %.2f ≥ 硬門檻）30 天仍在勢力%d（現 %d）；對照同條件 NPC 成員走了（%s）" % [float(a_bt["driver"]), fid, pt.faction_id, str(ctl_left)],
		pt.faction_id == fid and float(a_bt["driver"]) >= DiplomaticAiSystem.BETRAY_DRIVE_HARD and ctl_left)
	_cell("F7")

# ── 世界 C：獨立附身隊（F5b）─────────────────────────────────────────────────
func _world_c() -> void:
	print("\n── 世界 C：獨立附身隊 30 天（F5b）──")
	var st: WorldState = _mk([
		_team(0, Vector2i(8, 8), 10, -1, false, {"慎重": 0.5}, {"統領": 0.8}, "plains", ["統領"]),
		_team(1, Vector2i(-8, -6), 10, 1, true, {"慎重": 0.2}, {"統領": 0.8}, "plains", ["統領"]),
		_team(2, Vector2i(-6, -6), 8, 1, false, {"慎重": 0.5}, {}, "plains"),
	], 0)
	var pt: TeamData = st.teams[0]
	_check("佈置：玩家隊附身、獨立", pt.player_controlled and pt.faction_id == -1)
	_run(st, DAYS * WorldState.TICKS_PER_DAY)
	_check("F5b 十支對獨立附身隊 0 次", _side_cells("F5b", true))
	_cell("F5b")

# ── F4b：繼位交給玩家隊 ⇒ 那一次呼叫就清 ──────────────────────────────────────
func _f4b() -> void:
	print("\n── F4b：NPC 盟主死、繼位給玩家隊 ──")
	var st: WorldState = _mk([
		_team(0, Vector2i(8, 8), 6, 1, true, {"慎重": 0.5}, {"統領": 0.2}, "plains", ["統領"]),
		_team(1, Vector2i(10, 8), 10, 1, false, {"慎重": 0.5}, {"統領": 0.9}, "plains"),   # 玩家：統領最高 ⇒ 繼位
		_team(2, Vector2i(8, 10), 8, 1, false, {"慎重": 0.5}, {"統領": 0.1}, "plains"),
	], 1)
	var f = st.factions[(st.teams[0] as TeamData).faction_id]
	(st.teams[2] as TeamData).strategic_assignments = {77: Vector2i(1, 1)}
	(st.teams[1] as TeamData).strategic_assignments = {-1: Vector2i(2, 2)}
	st.succeed_or_disband_faction(f.faction_id, 0)
	var left: int = (st.teams[2] as TeamData).strategic_assignments.size() + (st.teams[1] as TeamData).strategic_assignments.size()
	_check("F4b 繼位給玩家隊（新盟主 Team%d、玩家領導=%s）⇒ 同一次呼叫清空成員指派（剩 %d 筆）" % [f.leader_team_id, str(st.is_player_led(f)), left],
		f.leader_team_id == 1 and st.is_player_led(f) and left == 0)
	_cell("F4b")

# ── 收編：S1／S1b ─────────────────────────────────────────────────────────────
class NoopInteraction extends InteractionSystem:
	func subjugate_team(_state: WorldState, _winner_id: int, _loser_id: int) -> void:
		pass

func _s_world() -> WorldState:
	return _mk([
		_team(0, Vector2i(8, 8), 10, -1, false, {"慎重": 0.5}, {}, "plains", []),       # 玩家（無統領）
		_team(1, Vector2i(8, 8), 4, -1, false, {"慎重": 0.5}, {}, ""),                  # 敗方：獨立
		_team(2, Vector2i(-8, -6), 8, 1, true, {"慎重": 0.5}, {"統領": 0.8}, "plains", ["統領"]),
		_team(3, Vector2i(8, 8), 4, 1, false, {"慎重": 0.5}, {}, ""),                   # 敗方：屬別勢力
		_team(4, Vector2i(8, 8), 4, -1, false, {"慎重": 0.5}, {}, ""),
		_team(5, Vector2i(9, 8), 6, -1, false, {"慎重": 0.5}, {}, "", ["統領"]),       # 盟友候選
		_team(6, Vector2i(9, 8), 3, -1, false, {"慎重": 0.5}, {}, ""),
	], 0)

static func _won(st: WorldState, loser: int) -> void:
	st.last_encounter_result = {"winner_id": st.get_player_team_id(), "loser_id": loser, "can_subjugate": true, "loot_pool": {}}

func _s1() -> void:
	print("\n── S1／S1b：收編列＝做 ──")
	var st: WorldState = _s_world()
	var cmd := PlayerCommandSystem.new()
	var pt: TeamData = st.teams[0]
	var nf: int = st.factions.size()
	_won(st, 1)
	var pre: Dictionary = cmd.precheck_subjugate_enemy(st, pt)
	var hint: String = load("res://scripts/ui/encounter_view.gd")._post_combat_hint(st.last_encounter_result, PlayerCommandSystem.subjugate_block_now(st))
	var r: Dictionary = cmd.execute_action(st, -1, "subjugate_enemy")
	_check("S1 無統領：precheck 理由「%s」、選單「%s」照列並標理由、按下 %s、勢力數 %d→%d" % [String(pre.get("reason", "")), hint, str(r), nf, st.factions.size()],
		String(pre.get("reason", "")) == "要有統領才能收編" and hint.contains("[J]收編敗者（要有統領才能收編）")
		and not bool(r.get("ok", true)) and st.factions.size() == nf and (st.teams[1] as TeamData).faction_id == -1)
	_won(st, 3)
	var pre3: Dictionary = cmd.precheck_subjugate_enemy(st, pt)
	_check("S1 敗方屬別勢力：理由「%s」" % String(pre3.get("reason", "")), String(pre3.get("reason", "")).contains("已屬勢力"))
	st.add_tag(pt, "統領", "bed")
	_won(st, 1)
	var r_ok: Dictionary = cmd.execute_action(st, -1, "subjugate_enemy")
	_check("S1 有統領：成功（%s）、敗方進玩家勢力" % str(r_ok),
		bool(r_ok.get("ok", false)) and pt.faction_id != -1 and (st.teams[1] as TeamData).faction_id == pt.faction_id)
	_cell("S1")
	# S1b：收編沒有真的發生（換成什麼都不做的 InteractionSystem）⇒ 做後驗回「收編沒有成功」
	cmd._interaction = NoopInteraction.new()
	_won(st, 4)
	var r_b: Dictionary = cmd.execute_action(st, -1, "subjugate_enemy")
	_check("S1b 收編沒發生 ⇒ %s" % str(r_b), not bool(r_b.get("ok", true)) and String(r_b.get("msg", "")) == "收編沒有成功")
	_cell("S1b")

# ── S2：事件 ─────────────────────────────────────────────────────────────────
static func _last_ev(st: WorldState, kind: String) -> Dictionary:
	for i in range(st.player_events.size() - 1, -1, -1):
		var e: Dictionary = st.player_events[i]
		if String(e.get("kind", "")) == kind:
			return e
	return {}

func _s2() -> void:
	print("\n── S2：收編事件 ──")
	var st: WorldState = _s_world()
	var cmd := PlayerCommandSystem.new()
	var pt: TeamData = st.teams[0]
	st.add_tag(pt, "統領", "bed")
	var seq0: int = st.player_event_seq
	_won(st, 1)
	cmd.execute_action(st, -1, "subjugate_enemy")
	var e1: Dictionary = _last_ev(st, "subjugate")
	var stop1: Dictionary = WorldEvents.stop_event_since(st, seq0)
	var want1: String = "你收編了 Team1，成立勢力%d，你是領袖" % pt.faction_id
	_check("S2 成立勢力：玩家佇列一則「%s」、subjects %s 含敗方、推進停在它（%s）" % [String(e1.get("text", "")), str(e1.get("subjects", [])), String(stop1.get("kind", ""))],
		String(e1.get("text", "")) == want1 and (e1.get("subjects", []) as Array).has(1) and String(stop1.get("kind", "")) == "subjugate")
	var seq1: int = st.player_event_seq
	_won(st, 4)
	cmd.execute_action(st, -1, "subjugate_enemy")
	var e2: Dictionary = _last_ev(st, "subjugate")
	_check("S2 已有勢力：「%s」" % String(e2.get("text", "")),
		int(e2.get("seq", 0)) > seq1 and String(e2.get("text", "")) == "你收編了 Team4，它加入你的勢力%d" % pt.faction_id)
	# 盟友收編別人 ⇒ 進玩家佇列、旁觀句、不停
	var ally: TeamData = st.teams[5]
	st.set_team_faction(ally, pt.faction_id, WorldState.JOIN_SETUP)
	var seq2: int = st.player_event_seq
	NpcCombatSystem.new().subjugate_team(st, 5, 6)
	var e3: Dictionary = _last_ev(st, "subjugate")
	var stop3: Dictionary = WorldEvents.stop_event_since(st, seq2)
	_check("S2 盟友收編：進玩家佇列「%s」、不停（停點 %s）" % [String(e3.get("text", "")), str(stop3)],
		int(e3.get("seq", 0)) > seq2 and String(e3.get("text", "")) == "Team6 臣服於 Team5，加入勢力%d" % pt.faction_id and stop3.is_empty())
	# NPC 對 NPC（玩家佇列本來就收不到）／玩家是敗方（投降被接受）⇒ 只斷言 describe 純函式
	var d_npc: String = WorldEvents.describe(st, "subjugate", [2, 3], {"founded": false, "faction": 9, "winner": 2, "loser": 3})
	var d_lose: String = WorldEvents.describe(st, "subjugate", [2, 0], {"founded": false, "faction": 9, "winner": 2, "loser": 0})
	_check("S2 describe：NPC 對 NPC「%s」、玩家是敗方「%s」" % [d_npc, d_lose],
		d_npc == "Team3 臣服於 Team2，加入勢力9" and d_lose == "你臣服於 Team2，加入勢力9")
	_cell("S2")

# ── S3：敵對帳跟著勢力走 ───────────────────────────────────────────────────────
func _s3() -> void:
	print("\n── S3：敵對帳 ──")
	var st: WorldState = _s_world()
	var cmd := PlayerCommandSystem.new()
	var pt: TeamData = st.teams[0]
	st.add_tag(pt, "統領", "bed")
	var x: TeamData = st.teams[1]
	if not (st.team_discovered.get(0, []) as Array).has(1):
		if not st.team_discovered.has(0): st.team_discovered[0] = []
		st.team_discovered[0].append(1)
	st.player_hostile_teams.append(1)   # ★先攻擊過 TeamX：與攻擊那個寫者（player_command_system 攻擊路徑）同一個寫法
	var msg := SimMessageSystem.new()
	_won(st, 1)
	var r: Dictionary = cmd.execute_action(st, -1, "subjugate_enemy")
	var vis: Dictionary = {}
	for row in PlayerApiMapper.map_visible_teams_render(st, 0):
		if int(row.get("team_id", -1)) == 1: vis = row
	var mode: String = msg._decide_exchange_mode(st, pt, x)
	print("    probe hostile.erase_on_join.subjugate=%d" % _c("hostile.erase_on_join.subjugate"))
	_check("S3 收編 TeamX（%s）⇒ 出帳（hostile 有 X=%s）、地圖 is_hostile=%s、同格交換＝%s" % [str(r.get("ok", false)), str(st.player_hostile_teams.has(1)), str(vis.get("is_hostile", "?")), mode],
		bool(r.get("ok", false)) and not st.player_hostile_teams.has(1) and vis.has("is_hostile") and not bool(vis["is_hostile"]) and mode == "honest")
	# 之後 TeamX 背叛 ⇒ 背叛本身不標；再攻擊（player_pre_encounter 空）⇒ 重新標
	st.clear_team_faction(x, WorldState.LEAVE_BETRAYAL)
	var after_betray: bool = st.player_hostile_teams.has(1)
	st.player_pre_encounter = {}
	x.combat_target = 0
	x.tile_pos = pt.tile_pos
	InteractionSystem.new()._try_interact(st, 1, 0)
	_check("S3 背叛後不標（%s）、攻擊後重新標（%s）" % [str(after_betray), str(st.player_hostile_teams.has(1))],
		not after_betray and st.player_hostile_teams.has(1))
	_cell("S3")

# ── S4：玩家投降被接受之後（systems 裁 2026-10-16 (乙)）──────────────────────────
#   ★對方接不接受由人格秤（handle_diplomacy_message）；這裡測的是【接受之後說什麼】⇒ 換成必接受的外交系統
class AcceptAll extends DiplomaticAiSystem:
	func handle_diplomacy_message(_state: WorldState, _self_team: TeamData, _sender_team: TeamData, _action: String, _gift: Dictionary = {}) -> String:
		return "accept"

func _s4() -> void:
	print("
── S4：投降被接受之後 ──")
	var cases: Array = [["S4a", "offer_surrender"], ["S4b", "surrender_in_encounter"], ["S4c", "surrender_pre_encounter"]]
	for c in cases:
		var st: WorldState = _s_world()
		var cmd := PlayerCommandSystem.new()
		cmd._diplomatic = AcceptAll.new()
		var pt: TeamData = st.teams[0]
		var foe: TeamData = st.teams[4]   # 獨立、無統領 ⇒ 門關著
		foe.tile_pos = pt.tile_pos
		if String(c[1]) == "surrender_pre_encounter":
			st.player_pre_encounter = {"attacker_id": 4, "defender_id": 0}
		else:
			st.encounter_active = true
			st.encounter_attacker_id = 4
			st.encounter_defender_id = 0
			st.player_pending_targets = [4]
		var r: Dictionary = cmd.execute_action(st, 4, String(c[1]))
		_check("%s %s 被接受、勝方無統領 ⇒ %s；玩家 faction_id %d" % [c[0], c[1], str(r), pt.faction_id],
			not bool(r.get("ok", true)) and String(r.get("msg", "")).contains("要有統領才能收編") and pt.faction_id == -1)
		_cell(String(c[0]))
	var st2: WorldState = _s_world()
	var cmd2 := PlayerCommandSystem.new()
	cmd2._diplomatic = AcceptAll.new()
	var pt2: TeamData = st2.teams[0]
	var foe2: TeamData = st2.teams[5]   # 有統領
	foe2.tile_pos = pt2.tile_pos
	st2.player_pre_encounter = {"attacker_id": 5, "defender_id": 0}
	var seq0: int = st2.player_event_seq
	var r2: Dictionary = cmd2.execute_action(st2, 5, "surrender_pre_encounter")
	var evs: Array = []
	for e in st2.player_events:
		if int(e.get("seq", 0)) > seq0 and String(e.get("kind", "")) == "subjugate":
			evs.append(e)
	var stop: Dictionary = WorldEvents.stop_event_since(st2, seq0)
	var want: String = "你臣服於 Team5，加入勢力%d" % foe2.faction_id
	_check("S4 真實投降成功（%s）⇒ 進勝方勢力（%d＝%d）、佇列恰一則（%d）「%s」、停在 %s" % [str(r2), pt2.faction_id, foe2.faction_id, evs.size(),
		String(evs[0].get("text", "")) if not evs.is_empty() else "", String(stop.get("kind", ""))],
		bool(r2.get("ok", false)) and pt2.faction_id != -1 and pt2.faction_id == foe2.faction_id and evs.size() == 1
		and String(evs[0].get("text", "")) == want and String(stop.get("kind", "")) == "subjugate")
	_cell("S4")

# ── P1：面板（真畫面 TextUI）──────────────────────────────────────────────────
func _p1() -> void:
	print("\n── P1：勢力面板 ──")
	seed(1337)
	var node = load("res://scenes/TextUI.tscn").instantiate()
	get_root().add_child(node)
	await process_frame
	await process_frame
	var st: WorldState = node._bridge.get_state()
	var ptid: int = st.get_player_team_id()
	var pt: TeamData = st.teams[ptid]
	if pt.faction_id != -1:
		st.set_team_faction(pt, -1, WorldState.LEAVE_PLAYER)
	var other: TeamData = null
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if tid != ptid and t.faction_id == -1 and t.parent_team_id == -1 and t.beast_kind == "" and t.leader_id != -1:
			other = t
			break
	var fid: int = st.create_faction(ptid)
	if other != null:
		st.set_team_faction(other, fid, WorldState.JOIN_SETUP)
	node._faction_mode = true
	var s: String = node._build_faction_str()
	print(s)
	_check("P1 玩家領導：「目標：無（等你下令）」、「還沒做的盟主動作」、不含「AI 目標」",
		s.contains("目標：無（等你下令）") and s.contains("還沒做的盟主動作：") and not s.contains("AI 目標"))
	# 玩家當成員：盟主換成那支 NPC 隊
	if other != null:
		st.factions[fid].leader_team_id = other.team_id
	var s2: String = node._build_faction_str()
	print(s2)
	_check("P1 玩家當成員：印「勢力目標」、不印「玩家目標」、不列還沒做", other != null and s2.contains("勢力目標：") and not s2.contains("玩家目標") and not s2.contains("還沒做的盟主動作"))
	node.queue_free()
	await process_frame
	_cell("P1")
