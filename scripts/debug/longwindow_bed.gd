extends SceneTree

# 長窗複利驗收 harness（純 debug/infra，零 sim 邏輯變）。
# R1 三帶「複利弧」= 時間序列真驗收：raid→糧→盈餘→更頻 raid→擴張。end-state tally 不夠 → 逐月曲線。
# seeded warring 長跑（同 WarringHarness seed 播 → 逐 tick 確定），三件事：
#   Task1  per-wolf 複利 timeline（代表隊 3-5 隻逐月 effective_food/food_flow/raid 派出/pop/rung/存活）
#          + 狼卡「可解 gate」乾等訊號（[GateWait]）。
#   Task2  assimilate 生命週期分流表（asm.* probe：completed vs interrupted → 裁② 慢 vs 結構性一眼分）。
#   Task3  tick 曲線（LW_PHASE=1 開 phase_timing）+ 全鏈漏斗一張表。
#
# 用法（env）：
#   LW_SEED    world seed（default 1337）
#   LW_MONTHS  跑幾月（default 6；1 月 = smoke；6-12 月長窗 → GODOT_TIMEOUT 拉大 + 背景跑）
#   LW_PHASE   =1 開 SimRunner 相位計時（spike tick 印 [PhaseSpike]/[FaiPhase] 相位拆解）

const RAID_TASKS: Array = [TeamData.TASK_ATTACK, TeamData.TASK_LOOT]
const WOLF_FOOD_FLOW_MAX: float = 0.5   # 狼餬口門檻：日均淨食物流 < 此 = 積累不起（餬口）
const GATE_WAIT_MONTHS: int = 2         # 連續 N 月「想 raid 未 raid + 有弱鄰」→ 標 [GateWait]

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var world_seed: int = int(OS.get_environment("LW_SEED")) if OS.has_environment("LW_SEED") else 1337
	var months: int = int(OS.get_environment("LW_MONTHS")) if OS.has_environment("LW_MONTHS") else 6
	var total_ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	var phase: bool = OS.get_environment("LW_PHASE") == "1"
	if phase:
		SimRunner.phase_timing = true
	print("=== longwindow_bed: seed=%d months=%d (ticks=%d) phase=%s ===" % [
		world_seed, months, total_ticks, str(phase)])

	seed(world_seed)   # 同 WarringHarness：播 global RNG（runtime bare randf/randi）→ 逐 tick 確定
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty():
		print("[FAIL] warring config 載入失敗"); Probe.enabled = false; return
	config["seed"] = world_seed
	GameSetup.setup(state, config)

	var wolves: Array = _pick_wolves(state)
	if wolves.is_empty():
		print("[WARN] 無代表隊可挑（config 無獨立隊？）")
	else:
		print("[bed] 代表隊 %d 隻：" % wolves.size())
		for w in wolves:
			print("   %s Team%d 野心=%.2f archetype=%s food_flow=%.2f food_days=%.1f pop=%d" % [
				w["role"], w["id"], w["ambition"], w["archetype"],
				w["food_flow0"], w["food_days0"], w["pop0"]])

	# 主迴路：逐 tick 推進 + per-wolf raid 抽樣 + tick 曲線 + captive 死亡分流
	var no_player := Vector2i(-1, -1)
	var dts: Array = []                    # 每 tick wall-time (us)
	var prev_gate: Dictionary = _gate_snapshot()   # 全域 gate 計數（月 delta 用）
	var prev_holders: Dictionary = _holder_captive_snapshot(state)   # holder→captive 總數（死亡分流）
	var asm_death: int = 0                 # holder 持 captive 時滅團（Task2 death 分流，需全域視角）

	for tick in range(total_ticks):
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(state, no_player)
		var dt: int = Time.get_ticks_usec() - t0
		dts.append(dt)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")

		# per-wolf raid 抽樣（task 上升沿 → raid 派出計數）
		for w in wolves:
			if not w["alive"]:
				continue
			var t: TeamData = state.teams.get(w["id"])
			if t == null:
				continue
			var cur: String = t.current_task
			if cur in RAID_TASKS and not (w["prev_task"] in RAID_TASKS):
				w["raid_month"] = int(w["raid_month"]) + 1
			w["prev_task"] = cur

		# 每日：captive 死亡分流（holder 持 captive 時消失 = interrupted_death）
		if (tick + 1) % WorldState.TICKS_PER_DAY == 0:
			var cur_holders: Dictionary = _holder_captive_snapshot(state)
			for hid in prev_holders:
				if not state.teams.has(hid):
					asm_death += 1   # holder 死時仍持 captive（未同化/散/逃）
			prev_holders = cur_holders

		# 月邊界：每狼快照 + gate delta + GateWait 評估
		if (tick + 1) % WorldState.TICKS_PER_MONTH == 0:
			var month: int = (tick + 1) / WorldState.TICKS_PER_MONTH
			var cur_gate: Dictionary = _gate_snapshot()
			var gate_delta: Dictionary = _dict_delta(prev_gate, cur_gate)
			prev_gate = cur_gate
			for w in wolves:
				_record_month(state, w, month, gate_delta)
			print("[bed] 月%d teams=%d pop=%d gate_delta=%s" % [
				month, state.teams.size(), _total_pop(state), str(gate_delta)])

		if state.teams.is_empty():
			print("[bed] tick=%d 全滅，提早結束" % tick)
			break

	# 交付：per-wolf 表 / asm 分流表 / 漏斗表 / tick 曲線 / GateWait
	_print_wolf_timelines(wolves)
	_print_gatewait(wolves)
	_print_asm_lifecycle(asm_death)
	_print_funnel(wolves)
	_print_tick_curve(dts)
	print("\n=== longwindow_bed DONE ===")
	Probe.enabled = false

# ────────── 代表隊挑選（harness 內挑，零 production 侵入）──────────
# 狼性餬口 ×2（FORCE + 野心高 + food_flow<0.5）/ 絕境 ×1（food_days 最低）/ 知足對照 ×1（SETTLE/TRADE）。
func _pick_wolves(state: WorldState) -> Array:
	var cands: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id != -1 or t.parent_team_id != -1 or t.leader_id == -1:
			continue
		var ldr: PersonData = state.persons.get(t.leader_id)
		if ldr == null:
			continue
		# archetype 於 setup 時尚未 derive（sim 跑時才填）→ 選擇當下由 leader values 現算（同 AmbitionLadder 源）
		var arche: String = t.ambition_archetype
		if arche == "":
			arche = AmbitionLadder.derive_archetype(ldr)
		cands.append({
			"id": tid,
			"ambition": float(ldr.values.get("野心", 0.5)),
			"archetype": arche,
			"food_flow": t.food_flow_avg,
			"food_days": _food_days(state, t),
			"pop": t.population,
		})
	if cands.is_empty():
		return []
	var picked: Dictionary = {}
	var wolves: Array = []

	# 狼餬口 ×2：FORCE，野心 desc；優先 food_flow<門檻
	var force: Array = cands.filter(func(c): return c["archetype"] == AmbitionLadder.ARCHETYPE_FORCE)
	force.sort_custom(func(a, b): return a["ambition"] > b["ambition"])
	var hungry: Array = force.filter(func(c): return c["food_flow"] < WOLF_FOOD_FLOW_MAX)
	var wolf_pool: Array = hungry if hungry.size() >= 2 else force
	for c in wolf_pool:
		if wolves.filter(func(w): return w["role"] == "狼餬口").size() >= 2:
			break
		if picked.has(c["id"]):
			continue
		picked[c["id"]] = true
		wolves.append(_mk_wolf(c, "狼餬口"))

	# 絕境 ×1：food_days 最低（未挑過）
	var by_food: Array = cands.filter(func(c): return not picked.has(c["id"]))
	by_food.sort_custom(func(a, b): return a["food_days"] < b["food_days"])
	if not by_food.is_empty():
		picked[by_food[0]["id"]] = true
		wolves.append(_mk_wolf(by_food[0], "絕境"))

	# 知足對照 ×1：SETTLE/TRADE archetype（未挑過），food_days 最高（最不餓）
	var settle: Array = cands.filter(func(c):
		return not picked.has(c["id"]) and c["archetype"] in [AmbitionLadder.ARCHETYPE_SETTLE, AmbitionLadder.ARCHETYPE_TRADE])
	settle.sort_custom(func(a, b): return a["food_days"] > b["food_days"])
	if not settle.is_empty():
		picked[settle[0]["id"]] = true
		wolves.append(_mk_wolf(settle[0], "知足"))

	return wolves

func _mk_wolf(c: Dictionary, role: String) -> Dictionary:
	return {
		"id": c["id"], "role": role,
		"ambition": c["ambition"], "archetype": c["archetype"],
		"food_flow0": c["food_flow"], "food_days0": c["food_days"], "pop0": c["pop"],
		"prev_task": "", "raid_month": 0, "alive": true,
		"death_month": -1, "timeline": [], "gate_wait_streak": 0, "gate_wait_max": 0,
	}

# ────────── 逐月每狼快照 ──────────
func _record_month(state: WorldState, w: Dictionary, month: int, gate_delta: Dictionary) -> void:
	var t: TeamData = state.teams.get(w["id"])
	if t == null:
		if w["alive"]:
			w["alive"] = false
			w["death_month"] = month
		w["timeline"].append({"month": month, "alive": false})
		w["raid_month"] = 0
		return
	var raid: int = int(w["raid_month"])
	var snap: Dictionary = {
		"month": month, "alive": true,
		"eff_food": ResourceSystem.effective_food(state, t),
		"food_flow": t.food_flow_avg,
		"raid": raid,
		"pop": t.population,
		"rung": t.ambition_rung,
		"faction_id": t.faction_id,
	}
	w["timeline"].append(snap)
	w["raid_month"] = 0

	# GateWait：FORCE+野心 想 raid 但本月 0 raid + 地圖有弱鄰（可解卻乾等）
	var wants_raid: bool = w["archetype"] == AmbitionLadder.ARCHETYPE_FORCE and float(w["ambition"]) >= 0.5
	if wants_raid and raid == 0 and _has_weak_neighbor(state, t):
		w["gate_wait_streak"] = int(w["gate_wait_streak"]) + 1
		w["gate_wait_max"] = maxi(int(w["gate_wait_max"]), int(w["gate_wait_streak"]))
		snap["gate_wait"] = true
		snap["gate_delta"] = gate_delta.duplicate()
	else:
		w["gate_wait_streak"] = 0

# 地圖有弱鄰（可解目標）：存在獨立活隊 pop 顯著低於自己（harness god-view，僅診斷）。
func _has_weak_neighbor(state: WorldState, t: TeamData) -> bool:
	var my_pop: int = t.population
	for tid in state.teams:
		if tid == t.team_id:
			continue
		var o: TeamData = state.teams[tid]
		if o.faction_id != -1 or o.parent_team_id != -1:
			continue
		if o.population > 0 and o.population < my_pop * 0.8:
			return true
	return false

# ────────── 輸出 ──────────
func _print_wolf_timelines(wolves: Array) -> void:
	if wolves.is_empty():
		return
	print("\n========== [Task1] per-wolf 複利月曲線（raid 頻率↑ + 糧積累↑ = 複利證據）==========")
	for w in wolves:
		print("--- %s Team%d（野心=%.2f archetype=%s）---" % [
			w["role"], w["id"], w["ambition"], w["archetype"]])
		print("   月 | eff_food | food_flow | raid | pop | rung | fid | 存活")
		for s in w["timeline"]:
			if not s.get("alive", false):
				print("   %2d |    —     |     —     |   — |   — |  —   |  —  | 死(月%d)" % [
					int(s["month"]), int(w["death_month"])])
				continue
			print("   %2d | %8.1f | %+9.2f | %4d | %3d |  %d   | %3d | %s" % [
				int(s["month"]), float(s["eff_food"]), float(s["food_flow"]),
				int(s["raid"]), int(s["pop"]), int(s["rung"]), int(s["faction_id"]),
				"是" + ("*卡" if s.get("gate_wait", false) else "")])
		if w["death_month"] < 0:
			var first: Dictionary = w["timeline"][0] if not w["timeline"].is_empty() else {}
			var last: Dictionary = w["timeline"][w["timeline"].size() - 1] if not w["timeline"].is_empty() else {}
			if first.get("alive", false) and last.get("alive", false):
				print("   → pop %d→%d（Δ%+d）food_flow %+.2f→%+.2f" % [
					int(first["pop"]), int(last["pop"]), int(last["pop"]) - int(first["pop"]),
					float(first["food_flow"]), float(last["food_flow"])])
	print("=================================================================================")

func _print_gatewait(wolves: Array) -> void:
	var flagged: Array = wolves.filter(func(w): return int(w["gate_wait_max"]) >= GATE_WAIT_MONTHS)
	if flagged.is_empty():
		print("\n[GateWait] 無狼連續 %d+ 月卡可解 gate（乾等訊號未觸）" % GATE_WAIT_MONTHS)
		return
	print("\n[GateWait] %d 隻狼連續 %d+ 月「想 raid 未 raid + 地圖有弱鄰」= 可解 gate 乾等（藍圖 ai-depth 觸發）：" % [
		flagged.size(), GATE_WAIT_MONTHS])
	for w in flagged:
		print("   %s Team%d 最長卡 %d 月（野心=%.2f archetype=%s）" % [
			w["role"], w["id"], int(w["gate_wait_max"]), w["ambition"], w["archetype"]])

func _print_asm_lifecycle(asm_death: int) -> void:
	var created: int = _c("asm.created")
	var completed: int = _c("asm.completed")
	var scatter: int = _c("asm.interrupted_scatter")
	var escaped: int = _c("asm.escaped")
	var released: int = _c("asm.released")
	var interrupted: int = scatter + escaped + released + asm_death
	print("\n========== [Task2] assimilate 生命週期分流表（裁② 慢 vs 結構性）==========")
	print("[asm] created=%d（起始 morale 均=%.3f）" % [
		created, _avg("asm.created_morale_sum", created)])
	print("[asm] completed=%d  interrupted=%d（scatter暴動=%d / escaped逃=%d / released釋放=%d / death滅團=%d）" % [
		completed, interrupted, scatter, escaped, released, asm_death])
	var dur_days: float = _avg("asm.completed_dur_sum", completed) / float(WorldState.TICKS_PER_DAY)
	print("[asm] completed 平均耗時=%.1f 天（morale 0→%.2f @ +%.3f/日 標稱≈%.0f 天）" % [
		dur_days, ManpowerSystem.ASSIM_T, ManpowerSystem.MORALE_KIND,
		ManpowerSystem.ASSIM_T / maxf(ManpowerSystem.MORALE_KIND, 0.0001)])
	if created == 0:
		print("[asm] 本窗零 captive created（無戰俘吸收；狼未打贏或未收編）→ 分流表空屬正常")
	elif interrupted > completed:
		print("[asm 裁②] interrupted 碾 completed → 結構性（同化鏈斷在中途：隊死/散/逃）")
	elif completed > 0 and dur_days > 40.0:
		print("[asm 裁②] completed 多但久（>40 天）→ 慢（cadence 太慢，非結構斷）")
	else:
		print("[asm 裁②] completed 為主且耗時合理 → 同化鏈通")
	print("========================================================================")

func _print_funnel(wolves: Array) -> void:
	print("\n========== [Task3] 全鏈漏斗表（intent→...→CONQUER 分布）==========")
	var intent: int = _c("conq.intent")
	var prosp: int = _c("conq.prosperity_reached")
	var combat: int = _c("conq.combat_entered")
	var cap_total: int = _c("capture.total")
	var cap_atk: int = _c("capture.by_attack")
	var asm_c: int = _c("asm.created")
	var asm_done: int = _c("asm.completed")
	var found: int = _c("g2.faction_found")
	var wolf_growth: int = _wolf_total_growth(wolves)
	print("[funnel] conq.intent              = %d" % intent)
	print("[funnel] → prosperity_reached     = %d  (%s of intent)" % [prosp, _rate(prosp, intent)])
	print("[funnel] → combat_entered         = %d  (%s of prosp)" % [combat, _rate(combat, prosp)])
	print("[funnel] → capture.total          = %d  (by_attack=%d, %s of combat)" % [cap_total, cap_atk, _rate(cap_total, combat)])
	print("[funnel] → assimilate created     = %d  (%s of capture)" % [asm_c, _rate(asm_c, cap_total)])
	print("[funnel] → assimilate completed   = %d  (%s of created)" % [asm_done, _rate(asm_done, asm_c)])
	print("[funnel] → wolf pop growth(Σ狼)   = %+d" % wolf_growth)
	print("[funnel] → found faction          = %d" % found)
	print("[funnel] CONQUER intent winner 分布: loot=%d prosp=%d other=%d none=%d" % [
		_c("conq.winner_loot"), _c("conq.winner_prosperity"),
		_c("conq.winner_other"), _c("conq.winner_none")])
	print("[funnel] surv.loot_dispatch=%d indep_atk_believed_owned=%d g1.arb_hit=%d" % [
		_c("surv.loot_dispatch"), _c("conq.indep_atk_believed_owned"), _c("g1.arb_hit")])
	print("=================================================================")

func _print_tick_curve(dts: Array) -> void:
	if dts.is_empty():
		print("\n[perf] 無 tick 資料"); return
	var sd: Array = dts.duplicate(); sd.sort()
	var n: int = sd.size()
	var median: int = sd[n / 2]
	var p99: int = sd[mini(int(n * 0.99), n - 1)]
	var max_dt: int = sd[n - 1]
	print("\n========== [Task3] tick 曲線（per-tick 成本有界不變量長跑驗）==========")
	print("[perf] ticks=%d median=%d us p99=%d us max=%d us (max/median=%.1fx)" % [
		n, median, p99, max_dt, float(max_dt) / maxf(float(median), 1.0)])
	# 殘餘 spike 頻率（known_issues 殘餘案佐證）：dt > 3×median
	var spike_thr: int = median * 3
	var spikes: int = 0
	for d in dts:
		if int(d) > spike_thr:
			spikes += 1
	print("[perf] spike ticks (dt>3×median=%d us) = %d（%.2f%% of ticks）" % [
		spike_thr, spikes, 100.0 * float(spikes) / float(n)])
	print("[perf] （LW_PHASE=1 時 spike tick 另印 [PhaseSpike]/[FaiPhase] 相位歸因）")
	print("======================================================================")

# ────────── helpers ──────────
func _c(key: String) -> int:
	return int(Probe.counts.get(key, 0))

func _avg(sum_key: String, count: int) -> float:
	if count <= 0:
		return 0.0
	return Probe.amount(sum_key) / float(count)

func _rate(num: int, den: int) -> String:
	if den <= 0:
		return "n/a"
	return "%.1f%%" % (100.0 * float(num) / float(den))

func _food_days(state: WorldState, t: TeamData) -> float:
	var burn: float = maxf(float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
	return ResourceSystem.effective_food(state, t) / burn

func _total_pop(state: WorldState) -> int:
	var n: int = 0
	for tid in state.teams:
		n += state.teams[tid].population
	return n

func _wolf_total_growth(wolves: Array) -> int:
	var g: int = 0
	for w in wolves:
		if w["timeline"].is_empty():
			continue
		var first: Dictionary = w["timeline"][0]
		var last: Dictionary = w["timeline"][w["timeline"].size() - 1]
		if first.get("alive", false) and last.get("alive", false):
			g += int(last["pop"]) - int(first["pop"])
	return g

# 全域 gate 計數快照（月 delta）
func _gate_snapshot() -> Dictionary:
	var keys: Array = [
		"prosp.gate_archetype", "prosp.gate_score", "prosp.gate_readiness",
		"prosp.gate_noprey", "prosp.gate_scout_defer",
		"indep.gate_fail_pop", "indep.gate_fail_food", "indep.gate_fail_busy", "indep.gate_fail_nopath",
	]
	var d: Dictionary = {}
	for k in keys:
		var v: int = _c(k)
		if v > 0:
			d[k] = v
	return d

func _holder_captive_snapshot(state: WorldState) -> Dictionary:
	var d: Dictionary = {}
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if not t.captive_groups.is_empty():
			d[tid] = AnonTierSystem.total_captives(t)
	return d

func _dict_delta(prev: Dictionary, cur: Dictionary) -> Dictionary:
	var d: Dictionary = {}
	for k in cur:
		var delta: int = int(cur[k]) - int(prev.get(k, 0))
		if delta != 0:
			d[k] = delta
	return d
