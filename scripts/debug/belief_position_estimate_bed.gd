extends SceneTree
# @bed-kind: acceptance
# slice: 位置 belief 的過期線物理化 Slice 1（造尺，不改任何既有讀者）
#
# ★★★這一票只做兩件事：
#   ①把【借用】拆掉：乞食記憶的 TTL 不再借 `BELIEF_STALE_TICKS`（值不變 ⇒ 行為不變）
#   ②加一支新介面 `BeliefSystem.position_estimate()`：回【事實 ＋ 年齡 ＋ 漂移】，判斷交呼叫端
#   ⇒ ★**既有讀者一個都不遷**（那是 Slice 2）⇒ 格 1-e：fp 與逐 tick 行為軌跡逐字相同。
#
# ★★造尺的票不准同時改世界 —— 否則「尺對不對」與「世界變好沒」會混在同一個 fp 裡。
#
# ★★★【格 1-e 為什麼不在這支床裡】：1-e 要的是【跨修法前後】的 fp 比較，
#   而**一支床只看得到自己這棵樹** —— 它沒辦法比另一棵樹。
#   ⇒ 那一格是**交件時的證據**，記在這裡讓下一個人查得到：
#     修法前 main `85b14055d`：fp=67c011dc430e2d69e3fc433f36f4c0b9｜逐 tick 軌跡=3796035139
#     本票樹            ：fp=67c011dc430e2d69e3fc433f36f4c0b9｜逐 tick 軌跡=3796035139
#     （warring_states／seed 1337／1200 tick，兩邊同一支臨時腳本）
#   ★同理 1-g（到場點名）在下面，而 1-e 不做成斷言 —— **釘一個歷史 fp 在常駐床裡會在**
#   **下一票合法改動世界時變成噪音**（systems 2026-09-18 對 1-h 講過同一件事）。

var _fail: int = 0
const EXPECTED_CELLS: Array = ["1-a", "1-b", "1-c", "1-d", "1-f", "1-h"]
var _cells_ran: Array = []

func _cell(name: String) -> void:
	if not _cells_ran.has(name):
		_cells_ran.append(name)

func noop() -> void:
	pass

func _selftest_gate(cell: String) -> Object:
	if OS.get_environment("BED_SELFTEST_DIE") != cell:
		return self
	print("[SELFTEST] ★故意讓 `%s` 這一格在中途死掉" % cell)
	return null

func _roll_call_missing() -> Array:
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(c): missing.append(c)
	if not missing.is_empty():
		print("[roll-call] ❌ ★**有格沒有跑完**：%s" % str(missing))
	return missing

func _initialize() -> void:
	_run()
	var _miss: Array = _roll_call_missing()
	print("-- 量測完成；[FAIL] 數 ＝ %d｜到場點名 %d／%d --" % [
		_fail + _miss.size(), _cells_ran.size(), EXPECTED_CELLS.size()])
	print("[TEST-SUITE-COMPLETE]")
	quit(1 if (_fail + _miss.size()) > 0 else 0)

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fail += 1
		push_error("[FAIL] %s" % msg)

func _bed_self_check_tree() -> void:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], out)
	var sha: String = (out[0] as String).strip_edges() if not out.is_empty() else "UNKNOWN"
	out.clear()
	OS.execute("git", ["status", "--porcelain", "--", "scripts/"], out)
	var dirty: int = 0
	if not out.is_empty():
		for l in (out[0] as String).split("\n"):
			if l.strip_edges() != "": dirty += 1
	print("[TREE] HEAD=%s scripts-dirty=%d（%s）" % [sha, dirty, "clean" if dirty == 0 else "★dirty"])

# ── fixture：一個觀察者、一個目標，目標的 belief 年齡由參數決定 ──
func _mk(age_ticks: int, anchored: bool) -> WorldState:
	var s := MeasureBedHelper.arm_and_new()
	s.world.current_tick = 40 * WorldState.TICKS_PER_DAY
	for x in range(0, 8):
		for y in range(0, 3):
			var t := HexTileData.new()
			t.tile_pos = Vector2i(x, y); t.terrain = "plains"
			s.world.tiles[x * 1000 + y] = t
	var me := TeamData.new()
	me.team_id = 1; me.faction_id = 1; me.leader_id = 100; me.tile_pos = Vector2i(0, 0)
	AnonCohort.add(me.anon_cohorts, "平民", "healthy", 6)
	var lead := PersonData.new(); lead.id = 100; lead.values = {}
	s.persons[100] = lead; s.teams[1] = me
	var tgt := TeamData.new()
	tgt.team_id = 2; tgt.faction_id = 2; tgt.leader_id = 200; tgt.tile_pos = Vector2i(5, 0)
	AnonCohort.add(tgt.anon_cohorts, "平民", "healthy", 6)
	var tl := PersonData.new(); tl.id = 200; tl.values = {}
	s.persons[200] = tl; s.teams[2] = tgt
	s.team_discovered[1] = [2]
	# ★★★錨定要寫進【belief 記錄的 activity 欄】，不是擺一個 live 的據點：
	#   `appearance()` 讀的是 `best_estimate()` 裡的 `activity`（＝觀察【當時】看到的樣子），
	#   ⇒ ★我第一版只在 live tile 上放據點 ⇒ `appearance()` 回 ACT_UNKNOWN ⇒ 兩檔沒有分化、1-b 當場紅。
	#   ★★而那個紅是【對的】：它證明這條路走的是 belief 不是 live（§1a 感知鐵律）。
	var claim_payload: Dictionary = {"tile_pos": Vector2i(5, 0), "population_est": 6.0}
	if anchored:
		var vt: HexTileData = s.world.tiles[5 * 1000 + 0]
		vt.outpost_owner = 2
		vt.outpost_level = 1
		claim_payload["activity"] = BeliefSystem.ACT_SETTLED
	var claim_tick: int = s.world.current_tick - age_ticks
	var saved: int = s.world.current_tick
	s.world.current_tick = claim_tick          # ★讓 claim 的 last_tick 落在過去
	BeliefSystem.record_claim(s, 1, 2, 1, "親見", claim_payload, 1.0, false)
	s.world.current_tick = saved
	return s

func _run() -> void:
	print("=== 位置 belief 過期線物理化 Slice 1 驗收（spec §5）===")
	_bed_self_check_tree()
	var day: int = WorldState.TICKS_PER_DAY

	# ── 1-a：規模數逐字印出來（★spec §1 要求：只寫結論不印數 ⇒ 紅）──
	_selftest_gate("1-a").noop()
	var base_spd: float = MovementSystem.baseline_tiles_per_day()
	var slow_spd: float = MovementSystem.slowest_tiles_per_day()
	var cur_line_days: float = float(BeliefSystem.BELIEF_STALE_TICKS) / float(day)
	var cur_drift: float = cur_line_days * base_spd
	print("[規模] TICKS_PER_DAY=%d｜基準旅行者=%.2f 格/日｜最慢那一端=%.2f 格/日" % [
		day, base_spd, slow_spd])
	print("[規模] 現行 BELIEF_STALE_TICKS=%d（%.1f 天）⇒ 容許漂移 ＝ %.1f 格（基準旅行者）" % [
		BeliefSystem.BELIEF_STALE_TICKS, cur_line_days, cur_drift])
	_ok(base_spd > slow_spd and slow_spd > 0.0,
		"1-a ★兩檔速度是【同一把尺的兩端】且**都 > 0**（基準 %.2f ＞ 最慢 %.2f ＞ 0）" % [base_spd, slow_spd]
		+ "｜★★最慢那端取 0 ⇒ 那則 belief 變成不可證偽，永遠掉不到會被重新偵查的價值")
	_ok(is_equal_approx(cur_drift, 18.0),
		"1-a-② ★現行 3 天線 ＝ **18 格**的可能漂移（算出來 %.1f）" % cur_drift
		+ "｜★★這個數就是 spec §1 用來打掉「移出那一格就算過期」那個判準的東西")
	_cell("1-a")

	# ── 1-c：★★★漂移係數的陽性對照（係數若為 0 ⇒ 這一格紅）──
	_selftest_gate("1-c").noop()
	print("\n— 1-c：漂移真的跟【年齡 × 速度】走 —")
	var e_fresh: Dictionary = BeliefSystem.position_estimate(_mk(0, false), 1, 2, 1.0)
	var e_1day: Dictionary = BeliefSystem.position_estimate(_mk(day, false), 1, 2, 1.0)
	var e_2day: Dictionary = BeliefSystem.position_estimate(_mk(2 * day, false), 1, 2, 1.0)
	print("   年齡 0／1天／2天 ⇒ 漂移 %.2f／%.2f／%.2f 格" % [
		float(e_fresh["drift_tiles"]), float(e_1day["drift_tiles"]), float(e_2day["drift_tiles"])])
	_ok(is_zero_approx(float(e_fresh["drift_tiles"])),
		"1-c-① ★剛看過 ⇒ 漂移 0（%.2f）" % float(e_fresh["drift_tiles"]))
	_ok(is_equal_approx(float(e_1day["drift_tiles"]), base_spd)
			and is_equal_approx(float(e_2day["drift_tiles"]), 2.0 * base_spd),
		"1-c-② ★★**漂移 ＝ 年齡 × 速度**（1 天 %.2f ＝ 基準 %.2f；2 天 %.2f ＝ 2×）" % [
			float(e_1day["drift_tiles"]), base_spd, float(e_2day["drift_tiles"])]
		+ "｜★★★**係數改 0 ⇒ 這一格當場紅**（那正是 spec §5 1-c 要的陽性對照）")
	_cell("1-c")

	# ── 1-b：兩檔速度真的分化（錨定走慢線）──
	_selftest_gate("1-b").noop()
	print("\n— 1-b：錨定 vs 無錨（兩檔，零新欄位）—")
	var e_anch: Dictionary = BeliefSystem.position_estimate(_mk(day, true), 1, 2, 1.0)
	var e_move: Dictionary = BeliefSystem.position_estimate(_mk(day, false), 1, 2, 1.0)
	print("   同樣 1 天：錨定漂移 %.2f 格｜無錨漂移 %.2f 格" % [
		float(e_anch["drift_tiles"]), float(e_move["drift_tiles"])])
	_ok(float(e_anch["drift_tiles"]) < float(e_move["drift_tiles"]),
		"1-b ★**被相信錨定的目標走慢線**（%.2f ＜ %.2f）" % [
			float(e_anch["drift_tiles"]), float(e_move["drift_tiles"])]
		+ "｜★★兩者相等 ⇒ 錨定那一檔沒有生效（讀不到 ACT_SETTLED）")
	_ok(is_equal_approx(float(e_anch["drift_tiles"]), slow_spd),
		"1-b-② ★錨定那檔走的是**最慢那一端**（%.2f ＝ %.2f）" % [
			float(e_anch["drift_tiles"]), slow_spd])
	_cell("1-b")

	# ── 1-d：`blind` 把「沒看過」與「過期」分開；且 `belief_pos()` 逐字未改 ──
	_selftest_gate("1-d").noop()
	print("\n— 1-d：沒看過 vs 過期（`belief_pos()` 把兩者都回 (-1,-1)）—")
	var s_never := _mk(0, false)
	s_never.team_tile_known[1] = {}
	s_never.team_intel[1] = {}
	var f2 = s_never.factions.get(2)
	var e_never: Dictionary = BeliefSystem.position_estimate(s_never, 1, 999, 1.0)
	var e_stale: Dictionary = BeliefSystem.position_estimate(_mk(30 * day, false), 1, 2, 1.0)
	print("   沒看過：pos=%s age=%d blind=%s" % [
		str(e_never["pos"]), int(e_never["age_ticks"]), str(e_never["blind"])])
	print("   看過但很舊：pos=%s age=%d drift=%.1f blind=%s" % [
		str(e_stale["pos"]), int(e_stale["age_ticks"]),
		float(e_stale["drift_tiles"]), str(e_stale["blind"])])
	_ok(e_never["pos"] == Vector2i(-1, -1) and int(e_never["age_ticks"]) == -1,
		"1-d-① ★**沒看過 ⇒ pos 空、age ＝ -1**")
	_ok(e_stale["pos"] != Vector2i(-1, -1) and bool(e_stale["blind"]),
		"1-d-② ★★**看過但太舊 ⇒ 位置仍然回得出來、而 `blind` ＝ true**"
		+ "｜★★★`belief_pos()` 把這兩種都回 (-1,-1)，而它們該做的事不同（沒看過 ⇒ 去偵查）")
	var bel_src: String = FileAccess.get_file_as_string("res://scripts/simulation/belief_system.gd")
	_ok(bel_src.contains("if bel.is_empty() or now - int(bel.get(\"last_tick\", 0)) > BELIEF_STALE_TICKS:"),
		"1-d-③ ★`belief_pos()` 的過期分支**逐字未改**（本票不遷讀者）")
	_ok(bel_src.contains("const BELIEF_STALE_TICKS: int = WorldState.TICKS_PER_DAY * 3"),
		"1-d-④ ★★`BELIEF_STALE_TICKS` 本身逐字未改（它的刪除要等讀者全遷完，spec §7）")
	_cell("1-d")

	# ── 1-f：(B) 借用已拆，而**值不變** ──
	_selftest_gate("1-f").noop()
	print("\n— 1-f：乞食記憶的 TTL 拆出來了，值不變 —")
	_ok(FailureMemory.AID_REFUSED_TTL_TICKS == BeliefSystem.BELIEF_STALE_TICKS,
		"1-f-① ★拆出來的常數**值與原借用值相同**（%d ＝ %d）⇒ 行為零改變" % [
			FailureMemory.AID_REFUSED_TTL_TICKS, BeliefSystem.BELIEF_STALE_TICKS]
		+ "｜★★而它們現在是**兩個獨立的數**：下一票動位置線不會再靜默改到乞食記憶")
	var n_borrow: int = 0
	for f in ["res://scripts/simulation/interaction_system.gd",
			"res://scripts/simulation/player_command_system.gd",
			"res://scripts/simulation/sim_runner.gd"]:
		var src: String = FileAccess.get_file_as_string(f)
		if src.contains("BeliefSystem.BELIEF_STALE_TICKS, \"aid_refused"): n_borrow += 1
	_ok(n_borrow == 0,
		"1-f-② ★★**三個呼叫端都不再借那條線**（仍在借的：%d 處）" % n_borrow
		+ "｜★分母 3 是我實際數出來的（spec 寫「四個實參」——第四個 `FailureMemory.record` 用的是 `ORDER_LIFETIME`）")
	_cell("1-f")

	# ── 1-h：★★★`tolerance_tiles` 沒有預設值（構造式檢查，不是讀原始碼）──
	_selftest_gate("1-h").noop()
	print("\n— 1-h：容忍度是【必填】—")
	var found: bool = false
	var defaults: int = -1
	var argc: int = -1
	# ★用 `load()` 拿 script 資源（`BeliefSystem.get_script()` 是實例方法，類別上不能直接叫）
	var bscript = load("res://scripts/simulation/belief_system.gd")
	for m in bscript.get_script_method_list():
		if String(m.get("name", "")) == "position_estimate":
			found = true
			argc = (m.get("args", []) as Array).size()
			defaults = (m.get("default_args", []) as Array).size()
			break
	_ok(found and argc == 4,
		"1-h-前提 ★找得到 `position_estimate` 且有 4 個參數（argc=%d）" % argc)
	_ok(defaults == 0,
		"1-h ★★★**它一個預設值都沒有**（default_args ＝ %d）⇒ **少傳容忍度＝跑不動**" % defaults
		+ "｜★>0 ⇒ 有人給了預設值 ⇒ 「忘了定尺」會變成靜默通過，"
		+ "★★而拆掉供給端硬切之後，那個靜默通過就是「拿 18 天前的位置去攻擊」")
	_cell("1-h")
