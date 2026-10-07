extends SceneTree
# @bed-kind: invariant
# ══ 票 T：疲勞回復綁活動不綁任務名＋「休息」成為選項 ══════════════════════════════════════════════
# spec：`docs/superpowers/specs/2026-10-06-ticket-t-fatigue-recovers-by-activity-HOW.md` §2
#
# ★病：回復只在 TASK_REST，而 TASK_REST 全站零寫入者 ⇒ 51 隊 30 天疲勞單調到 1.0（量測員坐實）
# ★修：SimRunner.fatigue_exertion() 一支分類（移動／戰鬥／執行即耗力的任務 ⇒ 累積；其餘 ⇒ 回復）＋「休息」選項＋玩家休息
# 格：P1 每隊都會降｜P2 地板（疲勞 ≥ 1.0，速度 ×0.3）隊·小時比例 ≤ 修前紅基線｜P3 移動過的 pass 不得回復
#     P4 駐守一夜必降（佈置）＋反向（同一隊標成移動過 ⇒ 必升）｜P5 分類窮盡｜P6 休息被選過＋驅力隨疲勞升｜P8 新啟用讀者的 tap

const CFG: String = "res://config/default.json"
const SEED: int = 1337
const DAYS: int = 30
# ★P2 紅基線（只准變少）：修前（origin/main `acb53274e`）同一個世界、同一個量法量的
#   ⇒ 地板隊·小時 ÷ 全部隊·小時（排除野獸隊）
const FLOOR_RATIO_BASELINE: float = 0.6225   # 修前實測：地板 9909／全部 15917（origin/main acb53274e，同量法、同 seed）

var _errors: int = 0
var _cells_ran: Array = []
const EXPECTED_CELLS: Array = ["P1", "P2", "P3", "P4", "P5", "P6", "P8", "P9", "P10", "P11", "P13"]


func _initialize() -> void:
	print("=== fatigue_by_activity：疲勞回復綁活動＋休息選項 ===")
	_p4_garrison_night()
	_p10_construction_by_stamina()
	_p11_one_curve()
	_p13_dodge()
	_p_world()
	var missing: Array = []
	for c in EXPECTED_CELLS:
		if not _cells_ran.has(String(c)):
			missing.append(String(c))
	_check("★到場點名：%d／%d（缺：%s）" % [_cells_ran.size(), EXPECTED_CELLS.size(), str(missing)], missing.is_empty())
	print("\n=== fatigue_by_activity DONE === errors: %d" % _errors)
	quit(1 if _errors > 0 else 0)


func _check(msg: String, cond: bool) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_errors += 1
		push_error("[FAIL] " + msg)


# ══ P4：駐守一夜必降（佈置；直呼同一支疲勞 pass）＋反向：同一隊每 pass 都標成移動過 ⇒ 必升 ════════════
func _p4_garrison_night() -> void:
	print("\n── P4 駐守一夜：沒移動、沒戰鬥、任務不耗力 ⇒ 疲勞必降 ──")
	seed(SEED)
	var st: WorldState = MeasureBedHelper.arm_and_setup(CFG, true)
	var runner := SimRunner.new()
	var ids: Array = st.teams.keys()
	ids.sort()
	var t: TeamData = st.teams[ids[0]]
	var night_passes: int = 12   # 一夜 ＝ 12 小時 ＝ 12 個疲勞 pass（每 pass 一小時）
	var out: Array = []
	for marked in [false, true]:
		t.fatigue = 0.8
		t.current_task = TeamData.TASK_HOLD
		t.combat_target = -1
		var before: float = t.fatigue
		var cls: Array = []
		for _i in range(night_passes):
			t.moved_since_fatigue = marked
			cls.append(SimRunner.fatigue_exertion(st, t))
			runner._step6d_fatigue(st, [t.team_id], WorldState.TICKS_PER_HOUR)
		out.append([before, t.fatigue, cls])
		print("   Team%d 守城、%s ⇒ 疲勞 %.3f → %.3f｜分類 %s" % [t.team_id, "每 pass 標成移動過" if marked else "沒移動",
			before, t.fatigue, str(cls.slice(0, 3))])
	_check("P4 駐守一夜（沒移動）⇒ 疲勞下降（%.3f → %.3f）" % [out[0][0], out[0][1]], float(out[0][1]) < float(out[0][0]))
	_check("P4【反向】同一隊每 pass 標成移動過 ⇒ 疲勞上升（%.3f → %.3f）" % [out[1][0], out[1][1]], float(out[1][1]) > float(out[1][0]))
	_cells_ran.append("P4")


# ══ 30 天世界：P1／P2／P3／P5／P6／P8 ════════════════════════════════════════════════════════════
func _p_world() -> void:
	print("\n── 30 天世界（default seed %d）──" % SEED)
	seed(SEED)
	var st: WorldState = MeasureBedHelper.arm_and_setup(CFG, false)
	var runner := SimRunner.new()
	var first_seen: Dictionary = {}
	var decreased: Dictionary = {}
	var last_f: Dictionary = {}
	var pos_at_pass: Dictionary = {}
	var pass_n: Dictionary = {}
	var prev_task: Dictionary = {}
	var p3_bad: Array = []
	var rest_choices: Array = []   # [tid, tick, fatigue]
	var task_hist: Dictionary = {}   # tid → {task: 小時數}
	var moved_or_fought: Dictionary = {}   # ★§6③：曾移動或曾戰鬥的隊（P1 只判這些）
	var last_pos: Dictionary = {}
	var ever_pos: Dictionary = {}    # 疲勞曾經 > 0 的隊
	var floor_n: int = 0
	var all_n: int = 0
	var ticks: int = DAYS * WorldState.TICKS_PER_DAY
	for _i in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
		var now: int = st.world.current_tick
		for tid in st.teams:
			var t: TeamData = st.teams[tid]
			if t.beast_kind != "":
				continue
			if not first_seen.has(tid):
				first_seen[tid] = now
			var f: float = t.fatigue
			if f > 0.0:
				ever_pos[tid] = true
			if (last_pos.has(tid) and last_pos[tid] != t.tile_pos) or t.combat_target != -1:
				moved_or_fought[tid] = true
			last_pos[tid] = t.tile_pos
			if last_f.has(tid) and f < float(last_f[tid]):
				decreased[tid] = true
			# ★P3 以【疲勞 pass】為單位（不是以「疲勞有變」為單位）：
			#   第一版用「上次變動的位置」—— 疲勞卡在 1.0 時移動的 pass 不會改值 ⇒ 位置沒更新 ⇒ 停下來回復時被誤判（實測 2 筆）
			#   ⇒ pass 的發生用既有的逐隊執行計數（sysexec.fatigue.byteam.NNNN）偵測
			var pc: int = int(Probe.counts.get("sysexec.fatigue.byteam.%04d" % int(tid), 0))
			if pc != int(pass_n.get(tid, 0)):
				if last_f.has(tid) and f < float(last_f[tid]) and pos_at_pass.has(tid) and pos_at_pass[tid] != t.tile_pos and p3_bad.size() < 20:
					p3_bad.append("Team%d t%d：上一個疲勞 pass 在 %s、這一個在 %s 而疲勞降了" % [int(tid), now, str(pos_at_pass[tid]), str(t.tile_pos)])
				pos_at_pass[tid] = t.tile_pos
				pass_n[tid] = pc
			last_f[tid] = f
			if t.current_task == TeamData.TASK_REST and String(prev_task.get(tid, "")) != TeamData.TASK_REST:
				rest_choices.append([int(tid), now, f])
			prev_task[tid] = t.current_task
			if now % WorldState.TICKS_PER_HOUR == 0:
				var th: Dictionary = task_hist.get(tid, {})
				th[t.current_task] = int(th.get(t.current_task, 0)) + 1
				task_hist[tid] = th
				all_n += 1
				if f >= 1.0:
					floor_n += 1
	# ── P1
	print("\n── P1 每隊 30 天內疲勞至少降一次 ──")
	var pop: Array = []
	for tid in first_seen:
		if st.teams.has(tid) and ticks - int(first_seen[tid]) >= WorldState.TICKS_PER_DAY:
			pop.append(int(tid))
	pop.sort()
	# ★從頭到尾疲勞都是 0 的隊沒有東西可降（實測 Team49 偵查 55 小時、疲勞 0.00）⇒ 不在「必須降過」的母體裡，另印
	var zero_all: Array = pop.filter(func(x): return not ever_pos.has(x))
	pop = pop.filter(func(x): return ever_pos.has(x))
	if not zero_all.is_empty():
		print("   從頭到尾疲勞 0（沒東西可降，不判）：%s" % str(zero_all))
	var never: Array = pop.filter(func(x): return not decreased.has(x))
	print("   母體（活到最後、在場 ≥ 1 天、非野獸）%d 隊｜降過 %d｜沒降過 %s" % [pop.size(), pop.size() - never.size(), str(never)])
	for x in never:
		var tx: TeamData = st.teams[x]
		var fdays: float = ResourceSystem.effective_food(st, tx) / maxf(float(tx.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
		print("   沒降過 Team%d：疲勞 %.2f｜曾移動或戰鬥 %s｜糧撐 %.1f 天｜任務小時數 %s" % [x, tx.fatigue, str(moved_or_fought.has(x)), fdays, str(task_hist.get(x, {}))])
	# ★§6③：只判「會移動或會戰鬥」的隊；整月原地（施工／覓食持求生優先序）的隊印出、不判（等 WHAT）
	# ★2026-10-07（戰鬥區第二輪改了 RNG ⇒ 世界變了）：Team34（流亡隊、活 65 小時都在覓食走動）、Team35（運輸子隊、53 小時都在運輸）
	#   在世上的每一個 pass 都在出力 ⇒ 照機制本來就不會降 ⇒ 母體再收一刀：疲勞 > 0 時有過不出力 pass 的隊
	#   （探針 fatigue.restpass_pos.byteam；而「真的降了沒」照舊由本床逐 tick 取樣判，不讀探針）
	var had_rest: Callable = func(x): return int(Probe.counts.get("fatigue.restpass_pos.byteam.%04d" % int(x), 0)) > 0
	var judged_never: Array = never.filter(func(x): return moved_or_fought.has(x) and had_rest.call(x))
	var spared: Array = never.filter(func(x): return not moved_or_fought.has(x))
	var never_rested: Array = never.filter(func(x): return moved_or_fought.has(x) and not had_rest.call(x))
	print("   判（曾移動或戰鬥、且疲勞 > 0 時停下來過）而沒降過：%s｜印出不判（整月原地）：%s｜印出不判（一刻都沒停過）：%s" % [
		str(judged_never), str(spared), str(never_rested)])
	for x in [0, 1, 3]:
		if st.teams.has(x):
			print("   §7 施工隊 Team%d：休息被選 %d 次" % [x, rest_choices.filter(func(r): return int(r[0]) == x).size()])
	_check("★母體地板：≥ 1 隊（%d）" % pop.size(), pop.size() >= 1)
	_check("P1 會移動或戰鬥的隊都至少降過一次（沒降過 %d：%s）" % [judged_never.size(), str(judged_never)], judged_never.is_empty())
	_cells_ran.append("P1")
	# ── P2
	print("\n── P2 地板（疲勞 ≥ 1.0）隊·小時比例 ──")
	var ratio: float = float(floor_n) / maxf(1.0, float(all_n))
	print("   地板 %d／全部 %d ＝ %.4f｜紅基線（修前）%.4f" % [floor_n, all_n, ratio, FLOOR_RATIO_BASELINE])
	_check("P2 地板比例 ≤ 修前紅基線（%.4f ≤ %.4f）" % [ratio, FLOOR_RATIO_BASELINE], FLOOR_RATIO_BASELINE >= 0.0 and ratio <= FLOOR_RATIO_BASELINE)
	_cells_ran.append("P2")
	# ── P3
	print("\n── P3 移動過的 pass 不得回復 ──")
	for b in p3_bad.slice(0, 8):
		print("   ✗ " + String(b))
	_check("P3 疲勞降的那一刻，上一次疲勞變動之後沒有移動過（違反 %d）" % p3_bad.size(), p3_bad.is_empty())
	_cells_ran.append("P3")
	# ── P5
	print("\n── P5 分類窮盡：每隊每 pass 恰落一類 ──")
	var n_pass: int = int(Probe.counts.get("fatigue.pass.n", 0))
	var by: Dictionary = {}
	var sum: int = 0
	for c in ["moved", "combat", "task", "rest"]:
		by[c] = int(Probe.counts.get("fatigue.class." + c, 0))
		sum += int(by[c])
	print("   pass %d｜分類 %s｜Σ %d" % [n_pass, str(by), sum])
	_check("★母體地板：pass ≥ 1（%d）且耗力與不耗力兩邊都有" % n_pass,
		n_pass >= 1 and int(by["rest"]) >= 1 and int(by["moved"]) + int(by["combat"]) + int(by["task"]) >= 1)
	_check("P5 Σ 分類 ＝ pass 數（%d ＝ %d）" % [sum, n_pass], sum == n_pass)
	_cells_ran.append("P5")
	# ── P6
	print("\n── P6 休息被選過，且驅力隨疲勞升 ──")
	var buckets: Dictionary = {"≤0.5": 0, "0.5–0.9": 0, "≥0.9": 0}
	for r in rest_choices:
		var f: float = float(r[2])
		buckets["≤0.5" if f <= 0.5 else ("0.5–0.9" if f < 0.9 else "≥0.9")] += 1
	print("   休息被選 %d 次（換到休息那一刻的疲勞級距 %s）｜前幾筆 %s" % [rest_choices.size(), str(buckets), str(rest_choices.slice(0, 5))])
	var ctx := DecisionContext.new()
	var drive: Array = []
	for x in [0.2, 0.5, 0.8, 1.0]:
		ctx.fatigue = x
		drive.append(DecisionTerms.eval("rest_drive", ctx, "休息"))
	print("   驅力（rest_drive）在疲勞 0.2／0.5／0.8／1.0 ＝ %s｜權重（求生欲 .5 慎重 .5）＝ %.2f" % [str(drive),
		DecisionTerms.weight("rest", {"求生欲": 0.5, "慎重": 0.5})])
	var mono: bool = true
	for i in range(1, drive.size()):
		if float(drive[i]) <= float(drive[i - 1]):
			mono = false
	_check("P6 驅力隨疲勞嚴格上升", mono)
	# ★0 次時要回報「為什麼」⇒ 引擎既有的 applicable-but-lost 診斷（decision_engine diag.<opt>.*）
	var dn: int = int(Probe.counts.get("diag.休息.appl_n", 0))
	if dn > 0:
		print("   「休息」可選卻輸 %d 次｜平均 coeff %.3f（<0.5 被壓 %d 次）｜平均主層急迫度 %.3f｜平均自己 util %.4f｜平均贏家 util %.4f" % [dn,
			float(Probe.amounts.get("diag.休息.coeff_sum", 0.0)) / dn, int(Probe.counts.get("diag.休息.coeff_pressed", 0)),
			float(Probe.amounts.get("diag.休息.mainurg_sum", 0.0)) / dn, float(Probe.amounts.get("diag.休息.ownutil_sum", 0.0)) / dn,
			float(Probe.amounts.get("diag.休息.winutil_sum", 0.0)) / dn])
	else:
		print("   「休息」可選卻輸 0 次（★它可能根本沒進候選 —— 看 diag 前綴）")
	var rest_keys: Array = []
	for k in Probe.counts:
		if String(k).contains("休息") or String(k).contains(TeamData.TASK_REST):
			rest_keys.append("%s=%d" % [String(k), int(Probe.counts[k])])
	rest_keys.sort()
	print("   含「休息」的計數：%s" % str(rest_keys))
	_check("P6 30 天內「休息」至少被選中一次（%d）—— 0 次不加門檻，要回報" % rest_choices.size(), rest_choices.size() >= 1)
	_cells_ran.append("P6")
	# ── P8
	print("\n── P8 新啟用的讀者（npc_ai_system `_goal_task_delta` 逃離戰爭 × TASK_REST）──")
	var p8: int = int(Probe.counts.get("goal.escape_war.rest_plus", 0))
	print("   因 TASK_REST 給出 +0.005 的次數 ＝ %d（tap 在、數字印出；不判多少）" % p8)
	_cells_ran.append("P8")
	# ── P9（spec §5）
	print("
── P9 疲勞 ≥ 0.8 且糧撐 > 5 天的隊·pass：贏家前 5 名 ──")
	var p9n: int = int(Probe.counts.get("fatigue.tired_fed.n", 0))
	var wins: Array = []
	for k in Probe.counts:
		if String(k).begins_with("fatigue.tired_fed.winner."):
			wins.append([String(k).trim_prefix("fatigue.tired_fed.winner."), int(Probe.counts[k])])
	wins.sort_custom(func(a, b): return int(a[1]) > int(b[1]))
	print("   隊·pass %d｜前 5：%s" % [p9n, str(wins.slice(0, 5))])
	var top5: Array = wins.slice(0, 5).map(func(x): return String(x[0]))
	_check("★P9 母體地板：疲勞高而吃飽的隊·pass ≥ 1（%d）" % p9n, p9n >= 1)
	_check("P9 「休息」進前 5（%s）" % str(top5), top5.has("休息"))
	_cells_ran.append("P9")


# ══ P10（§7，藍圖點名）：同一支隊、同一件工程 —— 疲勞 0 vs 1.0 施工一天的進度差；休息到疲勞降下後進度回升 ════════
func _p10_construction_by_stamina() -> void:
	print("\n── P10 施工進度 × 體力係數（同隊同工程，一天 24 個施工 pass）──")
	seed(SEED)
	var st: WorldState = MeasureBedHelper.arm_and_setup(CFG, true)
	var ids: Array = st.teams.keys()
	ids.sort()
	var t: TeamData = st.teams[ids[0]]
	var tile: HexTileData = st.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
	var os := OutpostSystem.new()
	var runner := SimRunner.new()
	var out: Array = []
	for f in [0.0, 1.0, -1.0]:
		if f >= 0.0:
			t.fatigue = f
		else:
			# 休息：從累垮開始、只走不耗力的疲勞 pass（同一支 _step6d_fatigue）直到降到 0.5 以下
			t.fatigue = 1.0
			t.current_task = TeamData.TASK_REST
			var n_rest: int = 0
			while t.fatigue > 0.5 and n_rest < 200:
				t.moved_since_fatigue = false
				runner._step6d_fatigue(st, [t.team_id], WorldState.TICKS_PER_HOUR)
				n_rest += 1
			print("   休息 %d 個 pass ⇒ 疲勞 %.3f" % [n_rest, t.fatigue])
		t.current_task = TeamData.TASK_BUILD
		tile.construction_target = {}
		tile.construction_ticks_left = 1000000
		var before: int = tile.construction_ticks_left
		for _i in range(24):
			os._tick_construction(st, tile)
		out.append([t.fatigue, before - tile.construction_ticks_left])
	print("   Team%d（人口 %d）：疲勞 %.2f ⇒ 一天進度 %d｜疲勞 %.2f ⇒ %d｜休息後疲勞 %.2f ⇒ %d" % [t.team_id, t.population,
		out[0][0], out[0][1], out[1][0], out[1][1], out[2][0], out[2][1]])
	_check("P10 累垮施工一天的進度 < 精神好時（%d < %d）" % [out[1][1], out[0][1]], int(out[1][1]) < int(out[0][1]))
	_check("P10 休息到疲勞降下後進度回升（%d > %d）" % [out[2][1], out[1][1]], int(out[2][1]) > int(out[1][1]))
	_cells_ran.append("P10")


# ══ P11（§7）：三條疲勞曲線收成一條 ⇒ simulation 裡疲勞的乘式只剩 stamina_factor 一處定義 ═════════════════════
func _p11_one_curve() -> void:
	print("\n── P11 疲勞乘式只剩一處定義 ──")
	var re := RegEx.new()
	re.compile("1\\.0 - [a-z_.]*fatigue|fatigue \\* 0\\.4")
	var hits: Array = []
	for f in _gd_files("res://scripts/simulation"):
		var i: int = 0
		for l in FileAccess.get_file_as_string(f).split("\n"):
			i += 1
			var code: String = String(l).split("#")[0]
			if re.search(code) != null:
				hits.append("%s:%d" % [String(f).trim_prefix("res://scripts/"), i])
	print("   命中 %s" % str(hits))
	_check("P11 疲勞乘式只剩一處、而且在 sim_runner.gd（%d 處）" % hits.size(), hits.size() == 1 and String(hits[0]).begins_with("simulation/sim_runner.gd"))
	_cells_ran.append("P11")


static func _gd_files(root: String) -> Array:
	var out: Array = []
	var d := DirAccess.open(root)
	if d == null:
		return out
	for f in d.get_files():
		if String(f).ends_with(".gd"):
			out.append(root + "/" + String(f))
	for sub in d.get_directories():
		out.append_array(_gd_files(root + "/" + String(sub)))
	return out


# ══ P13（§7）：累垮的單位開戰不能閃避；疲勞 0.5 的單位能 ══════════════════════════════════════════════════
func _p13_dodge() -> void:
	print("\n── P13 閃避門檻從體力係數導出 ──")
	seed(SEED)
	var st: WorldState = MeasureBedHelper.arm_and_setup(CFG, true)
	var ids: Array = st.teams.keys()
	ids.sort()
	var t: TeamData = st.teams[ids[0]]
	var es := EncounterSystem.new()
	var rows: Array = []
	for f in [1.0, 0.5]:
		t.fatigue = f
		var u: Dictionary = es._create_anon_unit(t, Vector2i.ZERO)
		var stam: float = float(u.get("stamina", 0.0))
		# ★同 encounter_system 閃避那一行的判斷式（嚴格大於門檻）
		rows.append([f, stam, stam > EncounterSystem.MIN_STAMINA_TO_DODGE])
	print("   門檻 %.2f｜疲勞 1.0 ⇒ 開場體力 %.2f、能閃避 %s｜疲勞 0.5 ⇒ %.2f、能閃避 %s" % [EncounterSystem.MIN_STAMINA_TO_DODGE,
		rows[0][1], str(rows[0][2]), rows[1][1], str(rows[1][2])])
	_check("P13 累垮不能閃避、疲勞 0.5 能", not bool(rows[0][2]) and bool(rows[1][2]))
	_cells_ran.append("P13")
