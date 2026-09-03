extends SceneTree
# @observe-pure
# ★★★紮營→紮根 銜接：控制場景床（systems 派 2026-09-03，腿 B 由 blueprint 加）。
#
# ★為什麼是控制場景床而不是再加 seed（systems 的理由，抄在這裡免得下次又有人想加 seed）：
#   紮根 `applicable` 在 organic 世界一路只湊到【7 次】（1337=3／42=1／7=3）——
#   ★★而母體小的成因不是 seed 不夠，是【organic 世界很少產生那個情境】（要站在自家 L0 營地上）
#   ⇒ ★★★再加 seed ＝ 等運氣，而每顆 seed 的成本固定 ⇒ 期望報酬很差。
#   ⇒ 手構世界：情境用【造】的，母體要 30 就 30。
#
# ★兩腿（共用同一組固定裝置，只差【隊站在哪裡】）：
#   腿 A：站自家 L0 營地 ＋ 已承諾紮根 ⇒ 問【紮根該不該 fire】
#   腿 B：★不在★自家營地 ＋ 已承諾紮根 ⇒ 問【它會不會走回去】（means-end 直球）
#
# ★★判讀表是 systems 寫在數字之前的，原樣搬進來（★★★不在數字回來之後改）：
#   腿A ①fire 且真 dispatch ⇒ 銜接沒問題，下一題是「為什麼不站在營地上」
#       ②applicable 但沒贏     ⇒ 才輪到 util／排序（★同時 dump per-option util）
#       ③贏了但沒 dispatch     ⇒ 手不聽腦（★單獨記，不跟②混）
#       ④以上皆非              ⇒ 原樣回報形狀，不歸類
#   腿B ①走回去               ⇒ means-end 完整（量幾 tick 到／距離）
#       ②不走回去、改做別的     ⇒ 承諾在而人不回家＝手不聽腦（★記它改做了什麼）
#       ③不走回去、也不做別的   ⇒ 又一個 IDLE latch
#       ④以上皆非              ⇒ 原樣回報形狀，不歸類
#
# ★★★三條紀律：①禁猜（拿到分支名/數字前不提「大概是因為」）②母體與命中同印
#   ③`fp` 不比（手構世界本來就不在 organic 那條線上）

const N_PER_LEG: int = 30
const GRID: int = 24

# ★★★閘化（systems 2026-09-03）：這支床原本【只印數字、不斷言】——
#   ★而 systems 把它註冊成閘時，expect 寫了 `ALL PASS`，那是【照別的床的慣例猜的】
#   ⇒ ★★註冊後第一次跑就 no-verdict。★★★「跑了、exit 0、什麼都不斷言」正是 expect 機制要抓的東西。
#   ⇒ 補上斷言＋總結行。★斷言釘的是 own-camp 那一刀的驗收（腿A/B/C 各一條），
#     ★★而它們在控制世界裡是【由構造決定】的整數，不是統計量 ⇒ 釘死值而不是釘閾值。
var _fail: int = 0
var _rows_a: Array = []
var _rows_b: Array = []
var _rows_c: Array = []
var _stat: Dictionary = {}

func _initialize() -> void:
	print("=== 紮根控制場景床｜每腿母體 %d｜手構世界（非 seed） ===" % N_PER_LEG)
	Probe.enabled = true; Probe.reset()   # ★三腿各自重置；世界則由 arm_and_new() 建（arm 先於 setup）
	_run_leg(true)
	var probe_a: Dictionary = Probe.counts.duplicate(true)
	var samp_a: Dictionary = Probe.samples.duplicate(true)
	Probe.reset()
	_run_leg(false)
	var probe_b: Dictionary = Probe.counts.duplicate(true)
	var samp_b: Dictionary = Probe.samples.duplicate(true)
	Probe.enabled = false
	_report("腿 A：站在自家 L0 營地上 ＋ 已承諾紮根", _rows_a, probe_a, samp_a, true)
	_report("腿 B：★不在★自家營地 ＋ 已承諾紮根", _rows_b, probe_b, samp_b, false)
	Probe.enabled = true; Probe.reset()
	_run_leg_c()
	var probe_c: Dictionary = Probe.counts.duplicate(true)
	Probe.enabled = false
	_report_c(probe_c)
	_verdict()
	print(MeasureBedHelper.arm_order_report())   # ★自檢有值而沒人看得到＝等於沒有自檢
	print("★誠實限：①手構世界（非 organic）②單 tick 決策快照（腿 B 的『走回去』看的是【這一 tick 派了什麼】，")
	print("   ★★不是【走完全程】）③每隊人格/糧況已打散（見 _mk_team），但仍是【我造的分布】不是世界的分布")
	quit()

# ── 固定裝置 ──────────────────────────────────────────────────────────
func _mk_world() -> WorldState:
	# ★★★走 `MeasureBedHelper.arm_and_new()`（bed-arm 閘的兩支合法入口之一，給【手工組世界】的那支）
	#   ★不是為了過閘才改：閘要防的是「setup 之後才 arm ⇒ 那段世界的 tap 是盲的」，
	#   ★★而這張床本來就要靠 zhagen tap 的計數下判斷 ⇒ arm 早一步是它自己的需要。
	#   ★★★而【不走白名單】是刻意的：白名單的數字應該單向下降，新床不該把它推高。
	var s: WorldState = MeasureBedHelper.arm_and_new()
	s.world.current_tick = 100
	for x in range(GRID):
		for y in range(GRID):
			var t := HexTileData.new()
			t.tile_pos = Vector2i(x, y)
			t.terrain = "plains"
			t.resources = {"food": 20.0}
			t.resource_cap = {"food": 40.0}
			s.world.tiles[x * 1000 + y] = t
	return s

# ★人格與糧況【打散】—— ★★30 個複製人的母體其實是 1。
func _mk_team(s: WorldState, tid: int, pos: Vector2i) -> TeamData:
	var lead := PersonData.new()
	lead.id = tid * 10
	lead.person_name = "L%d" % tid
	lead.role = "leader"
	lead.team_id = tid
	lead.age = 30
	var i: int = tid % 6
	lead.values = {
		"慎重": 0.2 + 0.12 * float(i),
		"野心": 0.8 - 0.12 * float(i),
		"貪婪": 0.3 + 0.08 * float((i + 2) % 6),
		"好戰": 0.2 + 0.10 * float((i + 4) % 6),
		"忠誠": 0.5,
	}
	lead.skills = {"combat": 0.4, "farming": 0.5}
	s.persons[lead.id] = lead
	var t := TeamData.new()
	t.team_id = tid
	t.leader_id = lead.id
	t.tile_pos = pos
	t.faction_id = -1
	t.current_task = TeamData.TASK_IDLE
	t.survival_committed_option = "紮根"     # ★兩腿共同前提：承諾在
	AnonCohort.add(t.anon_cohorts, "平民", "healthy", 4 + (tid % 5))
	t.resources = {
		"food": 40.0 + 20.0 * float(tid % 5),   # 糧況打散（避免 30 隊同時瀕餓或同時飽）
		"material": 10.0 * float(tid % 4),
		"coin": 30.0,
	}
	s.teams[tid] = t
	return t

# ★L0 營地：`can_settle_here` 的六個子條件裡，這裡負責 camp_level==1 / outpost_level==0 / 無人施工
#   ★★`camp_team_id` 也照 production 設（`faction_ai_system.gd::establish_crude_camp:5811`）——
#     ★★★我第一版漏了它，而漏它會讓腿 B 的問題【變成我造的】而不是世界的。
#     ★誠實限：設了之後結果【逐數相同】（見交件），因為決策路徑上【零處】讀 camp_team_id
#       （全樹讀取點只有 `harvest_system.gd:60-67` 的衰敗歸屬）—— 但那是【查完才敢講】的，不是假設。
func _mk_camp(s: WorldState, pos: Vector2i, team_id: int) -> HexTileData:
	var tile: HexTileData = s.world.tiles[pos.x * 1000 + pos.y]
	tile.camp_level = 1
	tile.outpost_level = 0
	tile.construction_team_id = -1
	tile.camp_team_id = team_id
	tile.camp_ticks_left = ResourceSystem.L0_DECAY_DAYS * WorldState.TICKS_PER_DAY
	# ★★★直接寫 camp_team_id ＝【繞過 chokepoint】⇒ 姊妹索引不會知道 ⇒ 後面每一隊都查不到自己的營地。
	#   ★血證：第一版漏了這一行，30 隊裡只有第 1 隊拿得到 own_camp（索引在它那次查詢時建好就凍住了），
	#   ★★其餘 29 隊被我新加的『營地沒了就解承諾』誤判成營地消失 ⇒ 全部退回紮營
	#   ⇒ ★★★看起來像【修法沒生效】，其實是【床自己繞過了自己剛立的失效點】。
	OwnerCampIndex.invalidate()
	return tile

# ── 兩腿 ──────────────────────────────────────────────────────────────
func _run_leg(on_camp: bool) -> void:
	var s: WorldState = _mk_world()
	var ai := FactionAISystem.new()
	for k in range(N_PER_LEG):
		var tid: int = 1000 + k
		var camp_pos := Vector2i(2 + (k % 10) * 2, 2 + int(k / 10) * 2)
		var stand_pos: Vector2i = camp_pos if on_camp else camp_pos + Vector2i(2, 0)
		var team: TeamData = _mk_team(s, tid, stand_pos)
		_mk_camp(s, camp_pos, tid)
		team.decision_eval_next_tick = 0     # 讓 `_should_reeval` 不被 cadence 擋
		var before_task: String = team.current_task
		ai._decide_unified(s, team)
		_rec(on_camp, {
			"tid": tid,
			"camp": camp_pos,
			"stand": stand_pos,
			"before": before_task,
			"task": team.current_task,
			"option": team.current_option,
			"move_target": team.move_target,
			"committed": team.survival_committed_option,
			"corvee": team.corvee_site,
		})

# ── 腿 C：走到一半，營地被衰敗清掉 ⇒ ★必須【解承諾重秤】，不得卡在移動中 ──
#   ★這一腿問的不是「會不會走回去」（腿B 已答），是【對象消失之後會不會卡住】。
#   ★★走的必須是既有出口 `survival_committed_option = ""`（★★★禁死旗）。
func _run_leg_c() -> void:
	var s: WorldState = _mk_world()
	var ai := FactionAISystem.new()
	for k in range(N_PER_LEG):
		var tid: int = 3000 + k
		var camp_pos := Vector2i(2 + (k % 10) * 2, 2 + int(k / 10) * 2)
		var team: TeamData = _mk_team(s, tid, camp_pos + Vector2i(2, 0))
		_mk_camp(s, camp_pos, tid)
		team.decision_eval_next_tick = 0
		ai._decide_unified(s, team)                       # ①先讓它承諾＋出發
		var t1_task: String = team.current_task
		var t1_move: Vector2i = team.move_target
		var t1_committed: String = team.survival_committed_option
		# ②營地在半路被衰敗清掉（照 harvest_system 的做法：camp_level=0＋camp_team_id=-1＋失效索引）
		var camp: HexTileData = s.world.tiles[camp_pos.x * 1000 + camp_pos.y]
		camp.camp_level = 0
		camp.camp_ticks_left = 0
		camp.camp_team_id = -1
		OwnerCampIndex.invalidate()
		s.world.current_tick += 1
		team.decision_eval_next_tick = 0
		ai._decide_unified(s, team)                       # ③重評
		_rows_c.append({
			"tid": tid, "camp": camp_pos,
			"t1_task": t1_task, "t1_move": t1_move, "t1_committed": t1_committed,
			"t2_task": team.current_task, "t2_move": team.move_target,
			"t2_committed": team.survival_committed_option,
			"t2_option": team.current_option,
		})

func _report_c(pc: Dictionary) -> void:
	print("")
	print("═══ 腿 C：出發之後營地被衰敗清掉 ⇒ 必須解承諾重秤 ═══")
	print("  母體 = %d" % _rows_c.size())
	var t1_walk: int = 0
	var released: int = 0
	var still_committed_zhagen: int = 0
	var stuck_moving: int = 0
	var by_t2: Dictionary = {}
	for r in _rows_c:
		if r["t1_move"] == r["camp"]: t1_walk += 1
		if String(r["t2_committed"]) == "": released += 1
		if String(r["t2_committed"]) == "紮根": still_committed_zhagen += 1
		if r["t2_move"] == r["camp"]: stuck_moving += 1
		var k2: String = String(r["t2_task"]) if String(r["t2_task"]) != "" else "(空)"
		by_t2[k2] = int(by_t2.get(k2, 0)) + 1
	print("  ①第一步真的出發（t1 move_target == 舊營地）= %d / %d" % [t1_walk, _rows_c.size()])
	print("  ★②營地消失後【解承諾】（committed 變空或改別的）= %d / %d（仍是紮根 = %d）"
		% [_rows_c.size() - still_committed_zhagen, _rows_c.size(), still_committed_zhagen])
	print("     其中走既有出口（committed == \"\"）= %d｜tap survival.own_camp_lost_release = %d"
		% [released, int(pc.get("survival.own_camp_lost_release", 0))])
	_stat["c_start"] = t1_walk
	_stat["c_released"] = _rows_c.size() - still_committed_zhagen
	_stat["c_stuck"] = stuck_moving
	print("  ★★③【卡在移動中】（t2 仍指向已消失的營地）= %d / %d ★★★這一格必須是 0"
		% [stuck_moving, _rows_c.size()])
	print("  t2 current_task 分布：%s" % _fmt(by_t2))
	for i in range(mini(5, _rows_c.size())):
		var r: Dictionary = _rows_c[i]
		print("     t%d t1[task=%s move=%s com=%s] → t2[task=%s move=%s com=%s opt=%s]"
			% [int(r["tid"]), String(r["t1_task"]), str(r["t1_move"]), String(r["t1_committed"]),
				String(r["t2_task"]), str(r["t2_move"]), String(r["t2_committed"]), String(r["t2_option"])])

func _rec(on_camp: bool, row: Dictionary) -> void:
	if on_camp: _rows_a.append(row)
	else: _rows_b.append(row)

# ── 報告 ──────────────────────────────────────────────────────────────
func _report(title: String, rows: Array, pc: Dictionary, ps: Dictionary, is_leg_a: bool) -> void:
	print("")
	print("═══ %s ═══" % title)
	print("  母體（本腿建的隊數）= %d" % rows.size())
	print("  ── zhagen tap（引擎自己的計數，與上面的母體對帳）──")
	for k in ["zhagen.mother", "zhagen.applicable", "zhagen.not_applicable",
			"zhagen.false.can_settle_here", "zhagen.false.no_resume_site", "zhagen.false.no_own_camp",
			"zhagen.appl_won", "zhagen.appl_lost"]:
		print("     %-32s = %d" % [k, int(pc.get(k, 0))])
	var lost_to: Array = []
	for k in pc:
		if String(k).begins_with("zhagen.appl_lost_to."):
			lost_to.append("%s=%d" % [String(k).substr(20), int(pc[k])])
	lost_to.sort()
	print("     輸給誰：%s" % ("（無）" if lost_to.is_empty() else " ".join(PackedStringArray(lost_to))))
	# 派發結果分布
	var by_task: Dictionary = {}
	var by_opt: Dictionary = {}
	var moved_home: int = 0
	var idle_n: int = 0
	for r in rows:
		var tn: String = String(r["task"]) if String(r["task"]) != "" else "(空)"
		by_task[tn] = int(by_task.get(tn, 0)) + 1
		var o: String = String(r["option"])
		by_opt[o if o != "" else "(空)"] = int(by_opt.get(o if o != "" else "(空)", 0)) + 1
		if String(r["task"]) == TeamData.TASK_IDLE: idle_n += 1
		if r["move_target"] == r["camp"]: moved_home += 1
	print("  ── 派發結果（分母 = %d）──" % rows.size())
	print("     current_task 分布：%s" % _fmt(by_task))
	print("     current_option 分布：%s" % _fmt(by_opt))
	if is_leg_a:
		var built: int = int(by_task.get(TeamData.TASK_BUILD, 0))
		var won: int = int(pc.get("zhagen.appl_won", 0))
		_stat["a_built"] = built
		_stat["a_won"] = won
		print("  ★★★判讀（表寫在數字之前）：")
		print("     ①fire 且真 dispatch（task=建設）= %d / %d" % [built, rows.size()])
		print("     ②applicable 但沒贏 = %d（appl_lost）" % int(pc.get("zhagen.appl_lost", 0)))
		print("     ★③贏了但【沒】dispatch = %d（appl_won %d − 建設 %d）★手不聽腦，單獨記"
			% [maxi(won - built, 0), won, built])
		print("     ④若三者對不起來 ⇒ 原樣回報形狀，不歸類")
	else:
		_stat["b_home"] = moved_home
		_stat["b_idle"] = idle_n
		print("  ★★★判讀（表寫在數字之前）：")
		print("     ①走回去（move_target == 自家營地）= %d / %d" % [moved_home, rows.size()])
		print("     ②不走回去、改做別的 = %d（見 current_option 分布）" % (rows.size() - moved_home - idle_n))
		print("     ③不走回去、也不做別的（IDLE）= %d ★又一個 IDLE latch 的話會出現在這裡" % idle_n)
		print("     ④若三者對不起來 ⇒ 原樣回報形狀，不歸類")
	# ★輸的時候把 per-option util 印出來（★禁靜態斷言：先看真實分數再談修法）
	var lt: Array = ps.get("zhagen.lost_table", [])
	if lt is Array and not lt.is_empty():
		print("  ── ★紮根 applicable 卻輸掉時的 per-option util（前 3 筆，樣本 %d）──" % lt.size())
		for i in range(mini(3, lt.size())):
			var e: Dictionary = lt[i]
			var tbl: Array = e.get("table", [])
			var top: Array = []
			for j in range(mini(6, tbl.size())):
				top.append("%s=%.4f" % [String(tbl[j]["opt"]), float(tbl[j]["u"])])
			print("     t%d 經由[%s]支 applicable，贏家=%s｜%s"
				% [int(e.get("team", -1)), String(e.get("branch", "?")), String(e.get("winner", "?")),
					" ".join(PackedStringArray(top))])
	# 前 5 列原始資料（★不歸類，讓人自己看形狀）
	print("  ── 前 5 列原始（★不解讀）──")
	for i in range(mini(5, rows.size())):
		var r: Dictionary = rows[i]
		print("     t%d 站%s 營%s → task=%s opt=%s move=%s corvee=%s committed=%s"
			% [int(r["tid"]), str(r["stand"]), str(r["camp"]), String(r["task"]),
				str(r["option"]), str(r["move_target"]), str(r["corvee"]), str(r["committed"])])

func _fmt(d: Dictionary) -> String:
	var ks: Array = d.keys(); ks.sort()
	var parts: Array = []
	for k in ks: parts.append("%s=%d" % [String(k), int(d[k])])
	return " ".join(PackedStringArray(parts))

# ★★★總結行（runner 的 expect 讀這一行）。★沒有它的話，「跑了、exit 0、什麼都不斷言」
#   會被讀成通過 —— 而那正是 no-verdict 要擋的。
func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [PASS] %s" % msg)
	else: _fail += 1; print("  [FAIL] %s" % msg)

func _verdict() -> void:
	print("")
	print("--- ★回歸斷言（own-camp 那一刀的驗收，逐腿一條）---")
	_ok(int(_stat.get("a_won", -1)) == N_PER_LEG and int(_stat.get("a_built", -1)) == N_PER_LEG,
		"腿A：站自家營地 ⇒ 紮根贏 %d/%d 且真 dispatch %d/%d"
		% [int(_stat.get("a_won", -1)), N_PER_LEG, int(_stat.get("a_built", -1)), N_PER_LEG])
	_ok(int(_stat.get("b_home", -1)) == N_PER_LEG,
		"腿B：不在營地 ⇒ 走回去 %d/%d（★修前是 0/%d：原地重紮）"
		% [int(_stat.get("b_home", -1)), N_PER_LEG, N_PER_LEG])
	_ok(int(_stat.get("b_idle", -1)) == 0,
		"腿B：沒有 IDLE latch（idle=%d）" % int(_stat.get("b_idle", -1)))
	_ok(int(_stat.get("c_start", -1)) == N_PER_LEG,
		"腿C：第一步真的出發 %d/%d" % [int(_stat.get("c_start", -1)), N_PER_LEG])
	_ok(int(_stat.get("c_released", -1)) == N_PER_LEG,
		"腿C：營地消失後解承諾 %d/%d" % [int(_stat.get("c_released", -1)), N_PER_LEG])
	_ok(int(_stat.get("c_stuck", -1)) == 0,
		"腿C：★卡在移動中 = %d（必須 0）" % int(_stat.get("c_stuck", -1)))
	if _fail == 0:
		print("=== DONE === ALL PASS")
	else:
		print("=== DONE === %d FAIL" % _fail)
