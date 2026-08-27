extends SceneTree
# @observe-pure
# ★★★S4b 驗收床：七支 cadence 的【事件瞬醒】覆蓋對帳（7×30 = 210 格，+ INDEP_INFRA/INTENT 共 270）。
#
# ★兩軌【都要】，因為它們回答的不是同一個問題：
#   靜態軌：這支閘【有沒有把某個 kind 排除掉】？（＝③「預設全通、例外要寫理由」的機械檢查）
#   執行軌：注一發 burst 進去，這支【當 tick 真的醒了嗎】？（＝behavioural evidence）
#   ★★只有靜態＝「我寫了 code」不是「它會動」；只有執行＝證不了【沒有漏掉哪個 kind】。
#
# ★★★執行軌有一個【結構性上限】，先講在前面不藏：
#   閘裡【沒有 kind 判斷】——is_pending 只問「這隊這 tick 有沒有被標記」，不問是誰標的。
#   ⇒ 執行軌【無法】把 kind A 的醒和 kind B 的醒分開。它能證的是「醒得起來」，
#     ★而「每個 kind 都能叫醒」是靠靜態軌（沒有任何 kind 被排除）+ emit 的 subjects 都是隊 id。
#   ⇒ 所以陰性對照必須印：不注射時本來就會醒幾次（production 自己在 emit）。
#     ★★★沒有這一欄，B 相的每一格都是【恆綠】——那不是覆蓋，是恆真式。
#
# ★★★★「0」要分三種，不准混：
#   no_actor      = 這床根本沒有這種 actor（儀器沒開）
#   NOT_WOKEN     = 有 actor、也注射了、就是沒醒（★真訊號，要人判）
#   ambiguous_due = 醒了但本 tick 本來就到期 ⇒ 記 both，★不記給事件（不灌 T0 的水）

const SUPPORTS: Array = [
	{"k": "GOAL",           "scope": "person", "core": true},
	{"k": "LADDER",         "scope": "team",   "core": true},
	{"k": "STRATEGIC",      "scope": "faction","core": true},
	{"k": "ALLIANCE",       "scope": "faction","core": true},
	{"k": "BETRAY",         "scope": "faction","core": true},
	{"k": "INFRA",          "scope": "faction","core": true},
	{"k": "FACTION_UPDATE", "scope": "faction","core": true},
	{"k": "INDEP_INFRA",    "scope": "indep",  "core": false},
	{"k": "INTENT",         "scope": "faction","core": false},
]

func _initialize() -> void:
	_run(); quit()

func _mk_world(cfg: String) -> WorldState:
	seed(1337)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/%s.json" % cfg))
	# 拆玩家特權（照 exam_12mo_bed._strip_player 既有形狀）
	if st.player_id != -1:
		st.player_id = -1
		st.player_forced_event = {}
		st.player_forced_event_id = ""
		st.player_pending_targets = []
		st.player_hostile_teams = []
		st.player_pre_encounter = {}
		st.player_state = {}
	return st

func _run() -> void:
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	var warm: int = int(OS.get_environment("BED_WARM")) if OS.has_environment("BED_WARM") else WorldState.TICKS_PER_DAY * 5
	var kinds: Array = WorldEvents.all_kinds()
	# ★BED_KINDS_LIMIT：只跑前 N 個 kind。★用途【限定】於「既有 tap 的行為佐證」那一問
	#   （那一問不需要 30 個 kind，一個 burst 就答完）——★★覆蓋對帳【不准】用它，
	#   否則 210 格會變成「我只跑了前 N 格」而輸出看起來一模一樣。
	var klimit: int = int(OS.get_environment("BED_KINDS_LIMIT")) if OS.has_environment("BED_KINDS_LIMIT") else 0
	if klimit > 0 and klimit < kinds.size():
		kinds = kinds.slice(0, klimit)
	var out: Array = []
	var state := _mk_world(cfg)
	var runner := SimRunner.new()
	Probe.reset(); Probe.enabled = true

	# ── A 相：正常跑 warm tick ⇒ 死水三欄（event / both / cadence）──
	var dead: bool = false
	for _t in range(warm):
		var r: String = runner.advance_tick(state, Vector2i(-1, -1))
		if r == "game_over" or r == "awaiting_heir":
			dead = true; break
	var colA: Dictionary = {}
	for s in SUPPORTS:
		var k: String = String(s["k"])
		colA[k] = {
			"event":   int(Probe.counts.get("reeval.event." + k, 0)),
			"both":    int(Probe.counts.get("reeval.both." + k, 0)),
			"cadence": int(Probe.counts.get("reeval.cadence." + k, 0)),
		}
	# actor 母體（區分 no_actor 與 NOT_WOKEN 的唯一依據）
	var n_person: int = state.persons.size()
	var n_fac: int = state.factions.size()
	var n_team: int = state.teams.size()
	var n_indep: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id == -1 and t.parent_team_id == -1 and t.beast_kind == "":
			n_indep += 1
	var actor_n: Dictionary = {"person": n_person, "team": n_team, "faction": n_fac, "indep": n_indep}

	# ── 窗長：★1 tick 的窗是【錯的】，這是實測打回來的（第一版 262/270 NOT_WOKEN）──
	#   ★根因：宿主 pass 粒度（LOD／各 loop 的走訪節奏）⇒ 任一 tick 只有一小部分 actor 被走到。
	#     「那 tick 沒被走到」跟「醒不了」長得一模一樣，而它們是【兩件事】。
	#   ⇒ 窗長取 NEAR_CADENCE（一小時），窗內【每 tick 都重新 emit】維持 pending。
	var win: int = int(OS.get_environment("BED_WIN")) if OS.has_environment("BED_WIN") else WorldState.TICKS_PER_HOUR

	# ── ★★★既有 tap 那一欄（票明文要求：behavioural evidence 用【既有】reeval.event，不加新 tap）──
	#   `reeval.event`（無後綴）是 faction_ai:3213 `_should_reeval` 本來就有的那顆，量的是
	#   【決策支（_decide_unified）】的事件瞬醒 —— 它在這一刀之前就存在、這一刀沒碰它。
	#   ★它跟我加的 `reeval.event.<支>` 是【兩件事】：那七支本來一個喚醒路徑都沒有，
	#     沒有既有 tap 可以重用；而死水【分支別】三欄也非有後綴不可。
	#   ⇒ 這一欄的用途：用一顆【完全沒被我動過】的儀器獨立佐證「注 burst ⇒ 當 tick 真的醒」。
	var legacy_ctrl: int = 0
	var legacy_burst: int = 0

	# ── C 相：陰性對照（不注射，同樣窗長）★沒有這欄，B 相恆綠 ──
	var ctrl: Dictionary = {}
	var ctrl_ran: Dictionary = {}
	for s2 in SUPPORTS: ctrl[String(s2["k"])] = 0; ctrl_ran[String(s2["k"])] = 0
	Probe.reset(); Probe.enabled = true
	for _c in range(win):
		runner.advance_tick(state, Vector2i(-1, -1))
	for s3 in SUPPORTS:
		var k3: String = String(s3["k"])
		ctrl[k3] = int(Probe.counts.get("reeval.event." + k3, 0))
		ctrl_ran[k3] = int(Probe.counts.get("reeval.event." + k3, 0)) 			+ int(Probe.counts.get("reeval.both." + k3, 0)) + int(Probe.counts.get("reeval.cadence." + k3, 0))

	legacy_ctrl = int(Probe.counts.get("reeval.event", 0))

	# ── B 相：逐 kind 注 burst 到【全部隊】，窗內每 tick 重注，跑 win tick ──
	var cells: Dictionary = {}   # kind -> support -> bucket
	for kind in kinds:
		Probe.reset(); Probe.enabled = true
		for _w in range(win):
			WorldEvents.emit(state, String(kind), state.teams.keys())
			runner.advance_tick(state, Vector2i(-1, -1))
		var row: Dictionary = {}
		for s4 in SUPPORTS:
			var k4: String = String(s4["k"])
			var ev: int = int(Probe.counts.get("reeval.event." + k4, 0))
			var bo: int = int(Probe.counts.get("reeval.both." + k4, 0))
			var ca: int = int(Probe.counts.get("reeval.cadence." + k4, 0))
			var have: int = int(actor_n.get(String(s4["scope"]), 0))
			var b: String
			if ev > 0: b = "woken"
			elif bo > 0: b = "ambiguous_due"
			elif have == 0: b = "no_actor"
			elif ev + bo + ca == 0: b = "no_run"          # ★這支整個窗都沒被走訪 ⇒ 儀器沒開，不是醒不了
			else: b = "NOT_WOKEN"                          # ★有跑、有 actor、有 pending，就是沒醒 ⇒ 真訊號
			row[k4] = {"bucket": b, "event": ev, "both": bo}
		legacy_burst += int(Probe.counts.get("reeval.event", 0))
		cells[String(kind)] = row

	# ── 靜態軌：閘裡有沒有 kind 判斷（③的機械檢查）──
	var gate_files: Array = ["res://scripts/simulation/faction_ai_system.gd",
		"res://scripts/simulation/strategic_ai_system.gd", "res://scripts/simulation/reaction_system.gd"]
	var filter_hits: Array = []
	for gf in gate_files:
		var f := FileAccess.open(String(gf), FileAccess.READ)
		if f == null: continue
		var ln: int = 0
		while not f.eof_reached():
			var line: String = f.get_line(); ln += 1
			var code: String = line
			var h: int = code.find("#")
			if h != -1: code = code.substr(0, h)
			if code.find("is_pending") == -1: continue
			# ★這一行有 is_pending：它有沒有【同時】提到某個 kind 字面量？
			for kk in kinds:
				if code.find("\"" + String(kk) + "\"") != -1:
					filter_hits.append("%s:%d %s" % [String(gf).replace("res://", ""), ln, String(kk)])
		f.close()

	# ── 印 + 落地 ──
	out.append("# S4b 事件瞬醒覆蓋對帳｜cfg=%s warm=%d tick%s" % [cfg, warm, "  ★世界提早終止" if dead else ""])
	out.append("# actor 母體：person=%d team=%d faction=%d indep=%d" % [n_person, n_team, n_fac, n_indep])
	out.append("#")
	out.append("## ① 死水三欄（A 相 %d tick 正常跑；三欄互斥、相加 = 該支 fire 次數）" % warm)
	out.append("# 支別 | event(純事件提早) | both(事件+本來就到期) | cadence(純週期) | 合計")
	print("\n=== S4b 覆蓋對帳｜cfg=%s ===" % cfg)
	print("actor 母體：person=%d team=%d faction=%d indep=%d" % [n_person, n_team, n_fac, n_indep])
	print("\n① 死水三欄（A 相 %d tick）" % warm)
	print("   %-16s %10s %10s %10s %10s" % ["支別", "event", "both", "cadence", "合計"])
	for s5 in SUPPORTS:
		var k5: String = String(s5["k"])
		var d: Dictionary = colA[k5]
		var tot: int = int(d["event"]) + int(d["both"]) + int(d["cadence"])
		print("   %-16s %10d %10d %10d %10d" % [k5, int(d["event"]), int(d["both"]), int(d["cadence"]), tot])
		out.append("%s|%d|%d|%d|%d" % [k5, int(d["event"]), int(d["both"]), int(d["cadence"]), tot])

	out.append("#")
	out.append("## ② 陰性對照（C 相 %d tick，不注射）：production 自己 emit 造成的 event 醒次數" % win)
	out.append("# ★『該窗共 fire』是分母：它 =0 代表這支整個窗沒被走訪（no_run），不是沒醒")
	print("\n② 陰性對照（不注射，窗長 %d tick）——★B 相要對著這欄讀" % win)
	print("   %-16s %10s %12s" % ["支別", "event", "該窗共 fire"])
	for s6 in SUPPORTS:
		var k6: String = String(s6["k"])
		print("   %-16s %10d %12d" % [k6, int(ctrl[k6]), int(ctrl_ran[k6])])
		out.append("ctrl|%s|%d|%d" % [k6, int(ctrl[k6]), int(ctrl_ran[k6])])

	out.append("#")
	out.append("## ②b 既有 tap（reeval.event，無後綴＝_should_reeval 的決策支，這一刀沒碰過它）")
	out.append("# 對照(不注射,%d tick)=%d ｜ 注射(%d kind × %d tick)=%d" % [win, legacy_ctrl, kinds.size(), win, legacy_burst])
	print("
②b 既有 tap reeval.event（★沒加新儀器的獨立佐證）：對照=%d ｜ 注射=%d" % [legacy_ctrl, legacy_burst])

	out.append("#")
	out.append("## ③ 靜態：閘上有沒有 kind 過濾（例外必須寫理由）")
	out.append("# is_pending 那幾行提到 kind 字面量的次數 = %d" % filter_hits.size())
	for fh in filter_hits: out.append("filter|%s" % fh)
	print("\n③ 靜態：閘上的 kind 過濾 = %d 處 %s" % [filter_hits.size(),
		"⇒ 預設全通、零例外" if filter_hits.is_empty() else "★有例外，逐條要有寫下的理由"])

	out.append("#")
	out.append("## ④ %d 格（9 支 × %d kind）；★核心 7 支 = %d 格單獨對帳%s"
		% [9 * kinds.size(), kinds.size(), 7 * kinds.size(),
		"  ★★★BED_KINDS_LIMIT 生效 ⇒ 這【不是】完整覆蓋對帳" if kinds.size() < WorldEvents.all_kinds().size() else ""])
	out.append("# 欄位：kind|support|bucket|event|both")
	var tally: Dictionary = {}
	var tally_core: Dictionary = {}
	for kind2 in kinds:
		for s7 in SUPPORTS:
			var k7: String = String(s7["k"])
			var c: Dictionary = (cells[String(kind2)] as Dictionary)[k7]
			var b2: String = String(c["bucket"])
			tally[b2] = int(tally.get(b2, 0)) + 1
			if bool(s7["core"]): tally_core[b2] = int(tally_core.get(b2, 0)) + 1
			out.append("%s|%s|%s|%d|%d" % [String(kind2), k7, b2, int(c["event"]), int(c["both"])])
	var keys: Array = tally.keys(); keys.sort()
	var sum_all: int = 0
	var sum_core: int = 0
	print("\n④ 覆蓋對帳")
	print("   %-16s %8s %8s" % ["bucket", "全 270", "核心 210"])
	for k8 in keys:
		print("   %-16s %8d %8d" % [String(k8), int(tally[k8]), int(tally_core.get(k8, 0))])
		out.append("# %-16s 全=%d 核心=%d" % [String(k8), int(tally[k8]), int(tally_core.get(k8, 0))])
		sum_all += int(tally[k8]); sum_core += int(tally_core.get(k8, 0))
	print("   %-16s %8d %8d" % ["合計", sum_all, sum_core])
	out.append("# %-16s 全=%d 核心=%d" % ["合計", sum_all, sum_core])
	var nw: int = int(tally_core.get("NOT_WOKEN", 0))
	var na: int = int(tally_core.get("no_actor", 0))
	var nr: int = int(tally_core.get("no_run", 0))
	var verdict: String = "★PASS：核心 210 格全部有處置，NOT_WOKEN=0" if (nw == 0 and sum_core == 210) \
		else "★FAIL：NOT_WOKEN=%d 合計=%d（應為 210）" % [nw, sum_core]
	print("   %s%s" % [verdict, "  ★no_actor=%d / no_run=%d ⇒ 那幾格是【儀器沒開】不是【醒不了】" % [na, nr] if (na + nr) > 0 else ""])
	out.append("# %s" % verdict)

	var path: String = OS.get_environment("S4B_OUT") if OS.has_environment("S4B_OUT") \
		else "docs/measurements/2026-08-28-s4b-wake-coverage-%s.txt" % cfg
	var wf := FileAccess.open(path, FileAccess.WRITE)
	if wf != null:
		wf.store_string("\n".join(PackedStringArray(out)) + "\n"); wf.close()
		print("\n落地：%s" % path)
	print("=== s4b_wake_coverage DONE ===")
