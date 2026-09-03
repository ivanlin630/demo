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

var _rows_a: Array = []
var _rows_b: Array = []

func _initialize() -> void:
	print("=== 紮根控制場景床｜每腿母體 %d｜手構世界（非 seed） ===" % N_PER_LEG)
	Probe.enabled = true; Probe.reset()
	_run_leg(true)
	var probe_a: Dictionary = Probe.counts.duplicate(true)
	Probe.reset()
	_run_leg(false)
	var probe_b: Dictionary = Probe.counts.duplicate(true)
	Probe.enabled = false
	_report("腿 A：站在自家 L0 營地上 ＋ 已承諾紮根", _rows_a, probe_a, true)
	_report("腿 B：★不在★自家營地 ＋ 已承諾紮根", _rows_b, probe_b, false)
	print("★誠實限：①手構世界（非 organic）②單 tick 決策快照（腿 B 的『走回去』看的是【這一 tick 派了什麼】，")
	print("   ★★不是【走完全程】）③每隊人格/糧況已打散（見 _mk_team），但仍是【我造的分布】不是世界的分布")
	quit()

# ── 固定裝置 ──────────────────────────────────────────────────────────
func _mk_world() -> WorldState:
	var s := WorldState.new()
	s.world = WorldData.new()
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

func _rec(on_camp: bool, row: Dictionary) -> void:
	if on_camp: _rows_a.append(row)
	else: _rows_b.append(row)

# ── 報告 ──────────────────────────────────────────────────────────────
func _report(title: String, rows: Array, pc: Dictionary, is_leg_a: bool) -> void:
	print("")
	print("═══ %s ═══" % title)
	print("  母體（本腿建的隊數）= %d" % rows.size())
	print("  ── zhagen tap（引擎自己的計數，與上面的母體對帳）──")
	for k in ["zhagen.mother", "zhagen.applicable", "zhagen.not_applicable",
			"zhagen.false.can_settle_here", "zhagen.false.no_resume_site",
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
		print("  ★★★判讀（表寫在數字之前）：")
		print("     ①fire 且真 dispatch（task=建設）= %d / %d" % [built, rows.size()])
		print("     ②applicable 但沒贏 = %d（appl_lost）" % int(pc.get("zhagen.appl_lost", 0)))
		print("     ★③贏了但【沒】dispatch = %d（appl_won %d − 建設 %d）★手不聽腦，單獨記"
			% [maxi(won - built, 0), won, built])
		print("     ④若三者對不起來 ⇒ 原樣回報形狀，不歸類")
	else:
		print("  ★★★判讀（表寫在數字之前）：")
		print("     ①走回去（move_target == 自家營地）= %d / %d" % [moved_home, rows.size()])
		print("     ②不走回去、改做別的 = %d（見 current_option 分布）" % (rows.size() - moved_home - idle_n))
		print("     ③不走回去、也不做別的（IDLE）= %d ★又一個 IDLE latch 的話會出現在這裡" % idle_n)
		print("     ④若三者對不起來 ⇒ 原樣回報形狀，不歸類")
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
