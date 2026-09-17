extends SceneTree
# @bed-kind: acceptance
# slice: 錨定性讓情報保鮮（HOW spec 2026-09-17-stale-position-goes-to-scout-pool-HOW.md §6.4 六格）
#
# ★★★一句話：**被相信駐紮著的目標，它的舊座標掉價慢；遊團掉價快。零新 belief 欄位。**
#
# ★★【這一票最容易踩的坑，而它有自己的一格】（6-c）：
#   `BeliefSystem.appearance()` 在回 activity 之前**自己先過 `BELIEF_STALE_TICKS`**
#   ⇒ 你想拿來判斷「它是不是駐紮」的那個欄位，**在第三天跟著位置一起變成 UNKNOWN**
#   ⇒ ★**錨定性會在最需要它的那一刻剛好不在**。所以呼叫端讀的是 `best_estimate()`（它本身不過期）。
#
# ★【誠實限】6-a/6-b/6-c/6-f 是 fixture 級（證明式子與三態分得開），
#   ★★6-d 是**原始碼 diff 格**（證明我沒有從後門鬆開攻擊門），
#   ★★★6-e 才是世界級（證明世界裡**兩種行為都真的發生**）—— 前四格全綠而 6-e 紅 ＝ 裝好了沒接電。
#
# env：BED_DAYS（6-e 的天數，預設 3）／BED_SEED（預設 1337）／BED_CONFIG（預設 warring_states）

var _fails: int = 0
var _undec: int = 0

func _initialize() -> void:
	_run()
	print("-- 量測完成；[FAIL] 數 ＝ %d｜[不可判] 數 ＝ %d --" % [_fails, _undec])
	print("[TEST-SUITE-COMPLETE]")
	quit(1 if _fails > 0 else 0)

# ★【不可判】＝ 這一格宣稱要驗的東西，**這一次執行沒有去驗** ⇒ 留著、標明、而且不算綠。
func _undecidable(cell: String, claim: String, why: String, how: String) -> void:
	_undec += 1
	push_error("[不可判] %s：%s" % [cell, claim])
	print("  [不可判] %s ——" % cell)
	print("       宣稱：%s" % claim)
	print("       為什麼這次驗不了：%s" % why)
	print("       怎麼驗：%s" % how)

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fails += 1
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
	print("[TREE] HEAD=%s scripts-dirty=%d（%s）" % [
		sha, dirty, "clean" if dirty == 0 else "★dirty：跟別份輸出比對前先確認同 commit"])

func _mk_team(state: WorldState, tid: int, fid: int, lid: int, pos: Vector2i, pop: int) -> void:
	var t := TeamData.new()
	t.team_id = tid; t.faction_id = fid; t.leader_id = lid; t.tile_pos = pos
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", pop)
	var p := PersonData.new(); p.id = lid; p.values = {"慎重": 0.5, "貪婪": 0.5}
	state.persons[lid] = p
	state.teams[tid] = t

# ★一個目標、一個年齡、一種 activity ⇒ 回它的偵查候選價值。
#   ★★`activity` 傳空字串 ＝ **這則 claim 根本沒有 activity 欄位**（6-f 要的那一態）。
func _value_of(age_ticks: int, activity: String) -> float:
	var day: int = WorldState.TICKS_PER_DAY
	var s := MeasureBedHelper.arm_and_new()
	s.world.current_tick = 100 * day
	_mk_team(s, 1, 1, 100, Vector2i(0, 0), 10)
	_mk_team(s, 41, 2, 141, Vector2i(9, 9), 8)
	var fields: Dictionary = {"tile_pos": Vector2i(5, 5), "population_est": 8.0}
	if activity != "": fields["activity"] = activity
	var keep: int = s.world.current_tick
	s.world.current_tick = 100 * day - age_ticks
	BeliefSystem.record_claim(s, 1, 41, 1, "親見", fields, 1.0, false)
	s.world.current_tick = keep
	return float(DecisionContext.pick_recon_target(s, s.teams[1])["value"])

# ★同一組 fixture，但問的是 `appearance()` 今天怎麼回答 —— 6-c 的前提驗證用。
func _appearance_of(age_ticks: int, activity: String) -> Dictionary:
	var day: int = WorldState.TICKS_PER_DAY
	var s := MeasureBedHelper.arm_and_new()
	s.world.current_tick = 100 * day
	_mk_team(s, 1, 1, 100, Vector2i(0, 0), 10)
	_mk_team(s, 41, 2, 141, Vector2i(9, 9), 8)
	var fields: Dictionary = {"tile_pos": Vector2i(5, 5), "population_est": 8.0, "activity": activity}
	var keep: int = s.world.current_tick
	s.world.current_tick = 100 * day - age_ticks
	BeliefSystem.record_claim(s, 1, 41, 1, "親見", fields, 1.0, false)
	s.world.current_tick = keep
	return BeliefSystem.appearance(s, 1, 41)

func _run() -> void:
	print("=== 錨定性讓情報保鮮 驗收（spec §6.4）===")
	_bed_self_check_tree()
	var day: int = WorldState.TICKS_PER_DAY
	print("[常數] BELIEF_STALE_TICKS=%d（%.1f 天）｜基準旅行者=%.2f tiles/day｜最慢=%.2f tiles/day" % [
		BeliefSystem.BELIEF_STALE_TICKS, float(BeliefSystem.BELIEF_STALE_TICKS) / float(day),
		MovementSystem.baseline_tiles_per_day(), MovementSystem.slowest_tiles_per_day()])

	# ── 6-a：同齡兩個目標，錨定的顯著高 ──
	var v_settled: float = _value_of(5 * day, BeliefSystem.ACT_SETTLED)
	var v_moving: float = _value_of(5 * day, BeliefSystem.ACT_MOVING)
	print("\n6-a｜同樣 5 天：believed 駐紮 value=%.4f／believed 移動中 value=%.4f（比值 %.2f×）" % [
		v_settled, v_moving, v_settled / maxf(v_moving, 0.000001)])
	_ok(v_settled > v_moving,
		"6-a ★**同齡之下，被相信駐紮的目標其舊座標更值錢**（樣本 2／母體 2）")
	_ok(v_settled / maxf(v_moving, 0.000001) > 2.0,
		"6-a-b ★**而且差距顯著（>2×）**｜★相等 ⇒ 錨定分檔沒有接上（這正是反向那一半）")
	# ★★★判準是「有沒有理由留在那裡」不是「這一刻動沒動」（systems 裁 2026-09-17）
	#   ⇒ `BUILDING` 與 `SETTLED` **同一條慢線**；`IDLE` 與 `MOVING` **同一條快線**。
	#   ★★下面第二列是**守衛**：`IDLE` 一旦被偷偷算成錨定，它就會紅。
	var v_building: float = _value_of(5 * day, BeliefSystem.ACT_BUILDING)
	var v_idle: float = _value_of(5 * day, BeliefSystem.ACT_IDLE)
	print("6-a-c｜同樣 5 天：工地中=%.6f（駐紮=%.6f）｜靜止=%.6f（移動中=%.6f）" % [
		v_building, v_settled, v_idle, v_moving])
	_ok(absf(v_building - v_settled) < 0.000001,
		"6-a-c ★**`BUILDING` 與 `SETTLED` 逐字同值**（工地綁死在那一格 ⇒ 同樣是留下來的理由）")
	_ok(absf(v_idle - v_moving) < 0.000001,
		"6-a-d ★★**守衛：`IDLE` 與 `MOVING` 逐字同值**（＝ IDLE 沒有被偷偷算進錨定）"
		+ "｜★★★`IDLE` 只說【上一步沒動】，而 belief 的 activity 凍在觀察當下"
		+ " ⇒ 拿它當錨會**隨年齡越錯越多**，方向與本票要的訊號相反")

	# ── 6-b：錨定也單調遞減、也永不為 0 ──
	var a5: float = _value_of(5 * day, BeliefSystem.ACT_SETTLED)
	var a50: float = _value_of(50 * day, BeliefSystem.ACT_SETTLED)
	var a500: float = _value_of(500 * day, BeliefSystem.ACT_SETTLED)
	print("6-b｜錨定目標：5 天=%.6f／50 天=%.6f／500 天=%.8f" % [a5, a50, a500])
	_ok(a5 > a50 and a50 > a500, "6-b-a ★**錨定的也單調遞減**（★駐紮的隊會拔營）")
	_ok(a500 > 0.0,
		"6-b-b ★★**而且永不為 0** ⇒ 沒有「不過期」這一檔"
		+ "｜★★★歸零／不過期 ⇒ 那則 belief 變成**不可證偽**，永遠掉不到會被重新偵查的價值")

	# ── 6-c：錨定性本身是舊的也讀得到（★這格守的是「有沒有走錯那條路」）──
	var old_age: int = BeliefSystem.BELIEF_STALE_TICKS + 7 * day
	var app: Dictionary = _appearance_of(old_age, BeliefSystem.ACT_SETTLED)
	var c_settled: float = _value_of(old_age, BeliefSystem.ACT_SETTLED)
	var c_moving: float = _value_of(old_age, BeliefSystem.ACT_MOVING)
	print("6-c｜claim 已 %.1f 天（> 過期線）｜`appearance()` 今天回 activity=%s state=%s｜" % [
		float(old_age) / float(day), String(app.get("activity", "?")), String(app.get("state", "?"))]
		+ "而偵查價值：駐紮=%.6f／移動=%.6f" % [c_settled, c_moving])
	_ok(String(app.get("activity", "")) == BeliefSystem.ACT_UNKNOWN,
		"6-c-前提 ★**這個坑是真的**：同一則 claim 經 `appearance()` 今天回 `%s`（state=%s）" % [
			String(app.get("activity", "?")), String(app.get("state", "?"))]
		+ "｜★前提不成立 ⇒ 下一句證不到東西")
	_ok(c_settled > c_moving,
		"6-c ★★**過期的 activity 仍然讀得到、仍然走慢線**"
		+ "｜★★★誤用 `appearance()` ⇒ 回 UNKNOWN ⇒ 退回快線 ⇒ 這一句會紅")

	# ── 6-f：從未觀察過 activity ⇒ 走快線（default-pass 守衛）──
	var f_none: float = _value_of(5 * day, "")
	print("6-f｜claim **沒有 activity 欄位**（從未觀察到）value=%.6f｜對照：移動中=%.6f、駐紮=%.6f" % [
		f_none, v_moving, v_settled])
	_ok(absf(f_none - v_moving) < 0.000001,
		"6-f ★**「沒看過」＝ 快線**（與 believed 移動中逐字同值）")
	_ok(f_none < v_settled,
		"6-f-b ★★**而且它不等於錨定**｜★寫成 `.get(\"activity\", ACT_SETTLED)` ⇒ 這一句會紅"
		+ "（那會讓「沒看過」變成「看過它駐紮」＝ §1a 明文禁的 default-pass）")

	_cell_d_gates_verbatim()
	_cell_e_world()

# ── 6-d：兩道門 ＋ 那條全域線逐字未改 ──
func _cell_d_gates_verbatim() -> void:
	print("\n— 6-d：兩道門與 `BELIEF_STALE_TICKS` 逐字未改 —")
	var fai: String = FileAccess.get_file_as_string("res://scripts/simulation/faction_ai_system.gd")
	var bel: String = FileAccess.get_file_as_string("res://scripts/simulation/belief_system.gd")
	var head: int = fai.find("func _find_weakest_prey")
	var body: String = ""
	if head != -1:
		var tail: int = fai.find("\nfunc ", head + 10)
		body = fai.substr(head, (tail - head) if tail != -1 else 2000)
	_ok(head != -1, "6-d-前提 找得到 `_find_weakest_prey`")
	_ok(body.contains("if not BeliefSystem.has_belief(state, team.team_id, tid): continue"),
		"6-d-a ★掠奪第一道門逐字未改")
	_ok(body.contains("if not PathSystem.estimate_catch_up(state, team, tid, true).reachable: continue"),
		"6-d-b ★掠奪第二道門逐字未改")
	_ok(fai.contains("if prey_pos_gate == Vector2i(-1, -1):"), "6-d-c ★攻擊側那道門逐字未改")
	# ★★★這一條才是本票最容易從後門鬆開的東西：全域過期線。
	#   ★它有 30+ 個生產呼叫點（攻擊/外交/加入/求助/威脅/movement），動它＝一次鬆開全部。
	_ok(bel.contains("const BELIEF_STALE_TICKS: int = WorldState.TICKS_PER_DAY * 3"),
		"6-d-d ★★**全域過期線 `BELIEF_STALE_TICKS` 逐字未改**"
		+ "｜★★★把錨定性做在這條線上 ⇒ 駐紮目標的舊座標會**直接通過攻擊門** ＝ spec §2 擋下的隔空作用")
	# ★`appearance()` 的過期分支也要在（它有既有消費者靠這個行為）
	_ok(bel.contains("return {\"activity\": ACT_UNKNOWN, \"tags\": [], \"in_combat\": false, \"state\": \"stale\"}"),
		"6-d-e ★`appearance()` 的過期行為逐字未改（它唯一的生產消費者靠的正是這個）")

# ── 6-e：世界級 —— 兩種行為都真的發生 ──
func _cell_e_world() -> void:
	# ★★★同前一票的作法：世界級那一段要跑 warring_states（10 天 ~40 分鐘），
	#   不放進每輪都要跑的閘 —— ★而【跳過】會讓它與「驗過且通過」在畫面上一模一樣
	#   ⇒ 標成【不可判】＋ expect 釘住 1。
	if OS.get_environment("BED_WORLD") == "0":
		_undecidable("6-e（世界級）",
			"世界裡錨定與無錨兩種行為都發生，且【在位置已過期的區間裡】兩種都出現",
			"本次以 BED_WORLD=0 執行（世界級那一段 ~40 分鐘，不適合每輪都跑）",
			"BED_WORLD=1 BED_DAYS=10 GODOT_TIMEOUT=3000 單獨跑一次；交件貼數時標【床的 commit】")
		return
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 3
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	print("\n— 6-e：世界級（config=%s days=%d seed=%d）—" % [cfg, days, seed_val])
	seed(seed_val)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(st, no_player)
	var anch: int = int(Probe.counts.get("recon.anchored", 0))
	var unanch: int = int(Probe.counts.get("recon.unanchored", 0))
	var elig: int = int(Probe.counts.get("recon.eligible", 0))
	var stale: int = int(Probe.counts.get("recon.eligible.stale_pos", 0))
	var a_stale: int = int(Probe.counts.get("recon.anchored.stale", 0))
	var u_stale: int = int(Probe.counts.get("recon.unanchored.stale", 0))
	print("6-e｜母體（偵查候選評估次數）=%d｜錨定=%d／無錨=%d｜其中位置已過期=%d" % [elig, anch, unanch, stale])
	print("     ★交叉（本票真正改變行為的區間）：錨定∧過期=%d／無錨∧過期=%d" % [a_stale, u_stale])
	# ★六檔 activity 的分佈（★即使我們不用 IDLE，那個數字也要在 —— 下次有人問，查得到）
	var acts: Array = [BeliefSystem.ACT_COMBAT, BeliefSystem.ACT_MOVING, BeliefSystem.ACT_BUILDING,
		BeliefSystem.ACT_SETTLED, BeliefSystem.ACT_IDLE, BeliefSystem.ACT_UNKNOWN, "no_field"]
	var parts: Array = []
	var act_sum: int = 0
	for a in acts:
		var n: int = int(Probe.counts.get("recon.act." + String(a), 0))
		act_sum += n
		parts.append("%s=%d" % [String(a), n])
	print("     ★activity 分佈：%s｜合計=%d" % [" ／ ".join(parts), act_sum])
	_ok(act_sum == elig,
		"6-e-e ★**分桶加總 ＝ 母體**（%d ＝ %d）｜★不等 ⇒ 有第七種 activity 沒有桶，而它現在正被靜默歸成無錨" % [
			act_sum, elig])
	_ok(elig > 0,
		"6-e-母體 ★母體非 0（=%d）｜★★母體塌陷 ⇒ 下面兩句的綠與紅都不算數" % elig)
	_ok(anch > 0,
		"6-e-a ★**世界裡真的有【被相信駐紮】的偵查目標**（樣本 %d／母體 %d）" % [anch, elig]
		+ "｜★為 0 ⇒ 錨定那一檔在世界裡從不觸發＝裝好了沒接電")
	_ok(unanch > 0,
		"6-e-b ★**也真的有無錨的**（樣本 %d／母體 %d）★兩種行為都要有，只有一種 ⇒ 沒有分化" % [unanch, elig])
	_ok(anch + unanch == elig,
		"6-e-c ★**兩檔加起來等於母體**（%d + %d ＝ %d）｜★不等 ⇒ 有第三條路徑沒有被計數到" % [
			anch, unanch, elig])
	# ★★★這一句才是「對照落在修法真正改變行為的區間上」：
	#   ★情報還新鮮的窗口裡，錨定與無錨的差別小到沒有意義 ——
	#     **綠在那裡拿到，等於沒有驗到本票。**
	_ok(a_stale > 0 and u_stale > 0,
		"6-e-d ★★★**交叉格**：位置【已過期】的目標裡，錨定與無錨**兩種都出現**"
		+ "（錨定∧過期=%d／無錨∧過期=%d）" % [a_stale, u_stale]
		+ "｜★任一為 0 ⇒ 窗口沒有涵蓋本票要改變的區間，這一格的綠不算數（拉長 BED_DAYS 再跑）")
