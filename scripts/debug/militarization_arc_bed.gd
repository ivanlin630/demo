extends SceneTree

# ═══════════════════════════════════════════════════════════════════════════
# 武裝化→征服 弧 觀測床（militarization → conquest arc diagnostic）
#
# 為什麼存在：aggregate 征服探針（winner_prosperity / combat_decisive）皆量測假象
# （數未達支、實戰走 retreat→_try_subjugate、探針沒量那條）→ 一直在鬼影上診斷。
# 本床 **不信那些 counter**，改逐窗（月）直接看隊「實際在做什麼 + 武裝多少 + 誠實漏斗」。
#
# 純觀測、零 sim 行為變：
#   時序 pass 只讀 RNG-free state（current_task / current_option / _calc_own_armed / intent /
#   capture.total 探針 delta）→ 不消費全域 RNG（gather() 會經 estimate_catch_up→observe_velocity
#   →randf() 擾動 RNG 流，故時序窗內一律不 gather）。
#   「為何不打」util dump 只在跑完 loop 之後 gather（無後續 tick 可被擾動）。
#   ARC_VERIFY=1 → 另跑一趟乾淨 WarringHarness.run 對照 capture.total/final，證零擾動。
#
# 用法（env）：
#   ARC_SEEDS   逗號 seed 集，default "1337,42,7"（沿用 warring 種）
#   ARC_MONTHS  跑幾月，default 6（6-12 看征服弧；每月=7200 tick）
#   ARC_WHY_N   「為何不打」抽樣隊數，default 6
#   ARC_VERIFY  =1 → 跑零擾動對照證明（2× 時間）
# ═══════════════════════════════════════════════════════════════════════════

const SEEDS_DEFAULT: Array = [1337, 42, 7]
const ATTACK_OPTS: Array = ["攻擊", "掠奪", "佔村"]
const ATTACK_TASKS: Array = ["攻擊", "掠奪"]   # TASK_ATTACK / TASK_LOOT（佔村→TASK_ATTACK）
const VIABLE_ARMED_RATIO: float = 0.3          # 鏡射 terms.gd（capability factor 飽和點）

# current_task → 顯示活動類別
const TASK_CAT: Dictionary = {
	"訓練": "train", "生產": "produce", "製造": "produce", "貿易": "trade",
	"建設": "build", "建造": "build", "升級": "build", "擴建": "build",
	"掠奪": "loot", "攻擊": "attack",
	"迎戰": "military", "備戰": "military", "守城": "military", "巡邏": "military",
	"治理": "govern", "逃跑": "flee", "覓食": "forage",
	"外交": "diplo", "信使": "diplo", "偵查": "diplo", "徵收": "tribute",
	"投靠": "seek_aid", "乞食": "seek_aid",
	"紮營": "settle", "安頓": "settle", "遷徙": "settle",
	"return_home": "logistics", "護衛": "logistics",
	"idle": "idle", "rest": "idle",
}
const CAT_ORDER: Array = ["train", "produce", "trade", "build", "military", "attack",
	"loot", "govern", "forage", "diplo", "tribute", "settle", "seek_aid",
	"logistics", "flee", "idle", "other"]

func _initialize() -> void:
	_run()
	quit()

func _run() -> void:
	var seeds: Array = _parse_seeds()
	var months: int = int(OS.get_environment("ARC_MONTHS")) if OS.has_environment("ARC_MONTHS") else 6
	var why_n: int = int(OS.get_environment("ARC_WHY_N")) if OS.has_environment("ARC_WHY_N") else 6
	var do_verify: bool = OS.get_environment("ARC_VERIFY") == "1"
	var ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	print("═══ militarization_arc_bed  seeds=%s months=%d (ticks=%d) why_n=%d verify=%s ═══" % [
		str(seeds), months, ticks, why_n, str(do_verify)])

	var all_windows: Array = []   # 跨 seed 聚合用
	for s in seeds:
		var r: Dictionary = _run_seed(int(s), ticks, why_n)
		if r.is_empty():
			print("[FAIL] seed=%d 空（config?）" % int(s)); continue
		_print_seed_report(int(s), r)
		for w in r["windows"]:
			all_windows.append(w)
		if do_verify:
			_verify_nonperturb(int(s), ticks, r)

	_print_aggregate(all_windows, months)
	print("═══ militarization_arc_bed DONE ═══")

func _parse_seeds() -> Array:
	var raw: String = OS.get_environment("ARC_SEEDS")
	if raw == "":
		return SEEDS_DEFAULT
	var out: Array = []
	for tok in raw.split(",", false):
		var t: String = tok.strip_edges()
		if t.is_valid_int(): out.append(int(t))
	return out if not out.is_empty() else SEEDS_DEFAULT

# ── 單 seed 跑：時序 pass（RNG-free 觀測）+ 收尾 why dump ──
func _run_seed(world_seed: int, ticks: int, why_n: int) -> Dictionary:
	seed(world_seed)                # 播全域 RNG（runtime randf/randi）
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty():
		Probe.enabled = false
		return {}
	config["seed"] = world_seed     # 播 setup RNG（同 seed 同世界）
	GameSetup.setup(state, config)

	var no_player := Vector2i(-1, -1)
	var windows: Array = []
	var prev_capture: int = 0
	var extinct: bool = false
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			var cap_now: int = int(Probe.counts.get("capture.total", 0))
			windows.append(_window_snapshot((tick + 1) / WorldState.TICKS_PER_MONTH, state, cap_now - prev_capture))
			prev_capture = cap_now
		if state.teams.is_empty():
			extinct = true
			break

	# 收尾 why dump（loop 已結束 → gather 消費 RNG 不擾動任何後續）
	var why: Array = _why_not_dump(state, why_n)
	var out: Dictionary = {
		"seed": world_seed,
		"windows": windows,
		"why": why,
		"extinct": extinct,
		"final_teams": state.teams.size(),
		"final_pop": _total_pop(state),
		"capture_total": int(Probe.counts.get("capture.total", 0)),
	}
	Probe.enabled = false
	return out

# ── 逐窗 RNG-free 快照：活動分布 / 武裝化 / 誠實漏斗 ──
func _window_snapshot(month: int, state: WorldState, cap_delta: int) -> Dictionary:
	var cats: Dictionary = {}
	for c in CAT_ORDER: cats[c] = 0
	var armed_ratios: Array = []
	var fa := FactionAISystem.new()
	# 誠實漏斗
	var f_want: int = 0        # intent=征服
	var f_committed: int = 0   # 且 current_option ∈ 攻擊/掠奪/佔村
	var f_executing: int = 0   # 且 current_task ∈ TASK_ATTACK/TASK_LOOT
	var team_ct: int = 0

	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t == null: continue
		team_ct += 1
		# 活動分布
		var cat: String = TASK_CAT.get(t.current_task, "other")
		cats[cat] = int(cats[cat]) + 1
		# 武裝化（RNG-free）
		var pop: int = maxi(t.population, 1)
		armed_ratios.append(float(fa._calc_own_armed(state, t)) / float(pop))
		# 漏斗（intent + current_option/current_task 皆 RNG-free 讀）
		if _wants_conquest(state, t):
			f_want += 1
			if t.current_option in ATTACK_OPTS: f_committed += 1
			if t.current_task in ATTACK_TASKS: f_executing += 1

	armed_ratios.sort()
	var mean_armed: float = 0.0
	for a in armed_ratios: mean_armed += a
	mean_armed = mean_armed / maxf(float(armed_ratios.size()), 1.0)
	var viable: int = 0
	for a in armed_ratios:
		if a >= VIABLE_ARMED_RATIO: viable += 1
	var med: float = armed_ratios[armed_ratios.size() / 2] if not armed_ratios.is_empty() else 0.0
	var amax: float = armed_ratios[armed_ratios.size() - 1] if not armed_ratios.is_empty() else 0.0

	return {
		"month": month, "teams": team_ct,
		"cats": cats,
		"armed_mean": mean_armed, "armed_med": med, "armed_max": amax,
		"armed_viable": viable,
		"f_want": f_want, "f_committed": f_committed, "f_executing": f_executing,
		"captures": cap_delta,
	}

# team 想不想征服（RNG-free）：solo=solo_intent / faction leader=f.intent / member=faction 攻擊 driver
func _wants_conquest(state: WorldState, t: TeamData) -> bool:
	if t.faction_id == -1:
		return FactionAISystem._solo_type(t) == "征服"
	var f = state.factions.get(t.faction_id)
	if f == null: return false
	if f.leader_team_id == t.team_id and f.intent is Dictionary:
		return String(f.intent.get("type", "")) == "征服"
	# member：faction 有攻擊令且其 intent=征服（鏡射 faction_ai _mconq 判定）
	var drv: Dictionary = f.goal_drivers.get("攻擊", {}) if f.goal_drivers is Dictionary else {}
	return String(drv.get("intent", "")) == "征服"

# ── 收尾 why dump：抽樣「想征服但沒committed攻擊」的隊，gather+rank 出 util 綁定原因 ──
func _why_not_dump(state: WorldState, n: int) -> Array:
	var out: Array = []
	for tid in state.teams:
		if out.size() >= n: break
		var t: TeamData = state.teams[tid]
		if t == null: continue
		if not _wants_conquest(state, t): continue
		if t.current_option in ATTACK_OPTS: continue   # 已在打的不列（要看沒打的）
		# gather（loop 已結束，RNG 擾動無害）
		var ctx: DecisionContext = DecisionContext.gather(state, t)
		var scored: Array = DecisionEngine.rank_scored_ctx(ctx, t.current_option)
		var top3: Array = []
		var atk_util = null
		var atk_present: bool = false
		for i in range(scored.size()):
			var e: Dictionary = scored[i]
			if i < 3: top3.append({"opt": e["opt"], "u": float(e["u"])})
			if e["opt"] in ATTACK_OPTS:
				atk_present = true
				if atk_util == null: atk_util = float(e["u"])
		out.append({
			"tid": t.team_id, "fid": t.faction_id, "pop": t.population,
			"cur_opt": t.current_option, "cur_task": t.current_task,
			"self_armed": ctx.self_armed_ratio,
			"readiness": ctx.readiness, "readiness_thr": ctx.readiness_thr_eff,
			"has_weak_prey": ctx.has_weak_prey, "prosperity_prey": ctx.prosperity_prey_id,
			"intent_target": ctx.intent_target,
			"atk_present": atk_present, "atk_util": atk_util,
			"top3": top3,
		})
	return out

# ── 零擾動對照：另跑乾淨 WarringHarness.run（無時序觀測），比 capture.total/final ──
func _verify_nonperturb(world_seed: int, ticks: int, observed: Dictionary) -> void:
	var clean: Dictionary = WarringHarness.run(world_seed, ticks)
	if clean.is_empty():
		print("[verify seed=%d] baseline 空，跳過" % world_seed); return
	var c_cap: int = int(clean["probe"].get("capture.total", 0))
	var c_teams: int = int(clean["final"]["teams"])
	var c_pop: int = int(clean["final"]["pop"])
	var ok: bool = c_cap == observed["capture_total"] and c_teams == observed["final_teams"] \
		and c_pop == observed["final_pop"]
	print("[verify seed=%d] %s  觀測(cap=%d teams=%d pop=%d) vs 乾淨(cap=%d teams=%d pop=%d)" % [
		world_seed, "PASS 零擾動" if ok else "FAIL 有擾動!",
		int(observed["capture_total"]), int(observed["final_teams"]), int(observed["final_pop"]),
		c_cap, c_teams, c_pop])

# ─────────── 列印 ───────────

func _print_seed_report(s: int, r: Dictionary) -> void:
	print("\n┌──────── seed=%d  final_teams=%d final_pop=%d capture.total=%d%s ────────" % [
		s, int(r["final_teams"]), int(r["final_pop"]), int(r["capture_total"]),
		"  [全滅]" if r["extinct"] else ""])

	# 1) 活動分布時序（每列一月，欄=類別 %）
	print("│ [活動分布 %／月]  (fleet-wide primary activity distribution)")
	var hdr: String = "│   月  隊數"
	for c in CAT_ORDER: hdr += "  %-8s" % c
	print(hdr)
	for w in r["windows"]:
		var line: String = "│   %2s  %4d" % [str(w["month"]), int(w["teams"])]
		var tot: float = maxf(float(w["teams"]), 1.0)
		for c in CAT_ORDER:
			var pct: float = 100.0 * float(w["cats"][c]) / tot
			line += "  %7.1f" % pct if pct >= 0.05 else "        ."
		print(line)

	# 2) 武裝化趨勢
	print("│ [武裝化趨勢]  self_armed = armed/pop  (viable = 比例≥%.2f)" % VIABLE_ARMED_RATIO)
	print("│   月   mean   median    max   #viable/隊")
	for w in r["windows"]:
		print("│   %2s   %.3f   %.3f   %.3f    %d/%d" % [
			str(w["month"]), float(w["armed_mean"]), float(w["armed_med"]),
			float(w["armed_max"]), int(w["armed_viable"]), int(w["teams"])])

	# 3) 誠實漏斗
	print("│ [誠實征服漏斗]  想征服 → committed攻擊option → 執行攻擊task → 本月捕獲(capture.total delta)")
	print("│   月   想征服  committed  執行  捕獲")
	for w in r["windows"]:
		print("│   %2s    %4d     %4d     %4d   %4d" % [
			str(w["month"]), int(w["f_want"]), int(w["f_committed"]),
			int(w["f_executing"]), int(w["captures"])])

	# 4) 為何不打
	print("│ [為何不打 — 收尾快照抽樣，想征服但沒 committed 攻擊]")
	if r["why"].is_empty():
		print("│   (無此類隊：沒有想征服卻沒打的隊)")
	for d in r["why"]:
		var t3: String = ""
		for o in d["top3"]: t3 += "%s=%.2f " % [o["opt"], o["u"]]
		var atk: String = ("攻擊util=%.2f" % float(d["atk_util"])) if d["atk_present"] else "攻擊option未applicable"
		print("│   T%d fid=%d pop=%d cur=[opt=%s task=%s]" % [
			int(d["tid"]), int(d["fid"]), int(d["pop"]), d["cur_opt"], d["cur_task"]])
		print("│      self_armed=%.3f readiness=%.3f thr=%.3f has_weak_prey=%s prosp_prey=%d intent_tgt=%d" % [
			float(d["self_armed"]), float(d["readiness"]), float(d["readiness_thr"]),
			str(d["has_weak_prey"]), int(d["prosperity_prey"]), int(d["intent_target"])])
		print("│      top3: %s | %s" % [t3.strip_edges(), atk])
	print("└─────────────────────────────────────────────")

func _print_aggregate(all_windows: Array, months: int) -> void:
	if all_windows.is_empty(): return
	print("\n╔══════ 跨 seed 聚合（per-month，seeds 平均）══════")
	# 按 month 聚合
	var by_month: Dictionary = {}
	for w in all_windows:
		var m: int = int(w["month"])
		if not by_month.has(m): by_month[m] = []
		by_month[m].append(w)
	var months_sorted: Array = by_month.keys(); months_sorted.sort()
	print("║ 月 | armed_mean %viable | 想征服 committed 執行 捕獲 | top活動")
	for m in months_sorted:
		var ws: Array = by_month[m]
		var n: float = float(ws.size())
		var arm: float = 0.0; var via: float = 0.0
		var want: float = 0.0; var comm: float = 0.0; var exe: float = 0.0; var cap: float = 0.0
		var cat_sum: Dictionary = {}
		for c in CAT_ORDER: cat_sum[c] = 0.0
		for w in ws:
			arm += float(w["armed_mean"])
			via += 100.0 * float(w["armed_viable"]) / maxf(float(w["teams"]), 1.0)
			want += float(w["f_want"]); comm += float(w["f_committed"])
			exe += float(w["f_executing"]); cap += float(w["captures"])
			for c in CAT_ORDER:
				cat_sum[c] += 100.0 * float(w["cats"][c]) / maxf(float(w["teams"]), 1.0)
		# top3 活動
		var pairs: Array = []
		for c in CAT_ORDER: pairs.append([c, cat_sum[c] / n])
		pairs.sort_custom(func(a, b): return a[1] > b[1])
		var top: String = ""
		for i in range(mini(3, pairs.size())): top += "%s=%.0f%% " % [pairs[i][0], pairs[i][1]]
		print("║ %2d | %.3f  %4.1f%%    | %5.1f  %5.1f  %5.1f  %5.1f | %s" % [
			m, arm / n, via / n, want / n, comm / n, exe / n, cap / n, top.strip_edges()])
	print("╚═══════════════════════════════════════════════")

func _total_pop(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams: n += state.teams[tid].population
	return n
