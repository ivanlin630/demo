extends SceneTree

# ★資訊網 2機制問題診斷（systems dispatch 2026-08-04、measure-first、只交真值別下修結論）。
# (a) convoy-lifecycle 5/6 沒送達：逐站 tap 每個 distribute relief convoy 全生命（spawn→tick→travel→arrive→deliver / 或 culled）。
# (b) T1 死因：T1 全程 task 序 + pop 變化 + 有無派 herald（detach anon）。
# ★純觀測：seed()+inline advance_tick（合法世界設置，同 peaceful_economy_bed._print_team_stories），每 tick 只 READ state（零 randf、零 sim-code 改）。
# 重現 #6 同床：peaceful_economy config seed 70730 6mo。

const CONFIG_PATH := "res://config/peaceful_economy.json"
const SEED: int = 70730
const MONTHS: int = 6
const OUT_PATH := "res://docs/measurements/2026-08-04-convoy-lifecycle-t1death-diagnostic.json"

func _initialize() -> void:
	print("=== convoy-lifecycle + T1 死因 診斷（seed=%d %d月、純觀測）===" % [SEED, MONTHS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_MONTH * MONTHS

	var life: Dictionary = {}          # porter_id → 生命站表
	var t1: Dictionary = {             # T1(team_id=1) 追蹤
		"tasks": [], "pop_daily": [], "letter_dispatched": false, "letter_tick": -1,
		"death_tick": -1, "last_task": "", "last_pop": -1, "min_pop": 1<<30, "alive_at_end": false,
	}
	var t1_last_task: String = "<init>"
	var seen_prev: Dictionary = {}

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		var cur_tick: int = state.world.current_tick

		# ── (a) distribute convoy 逐站 ──
		var seen_now: Dictionary = {}
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			if t.current_task != TeamData.TASK_CONVOY: continue
			if String(t.task_extra_data.get("convoy_kind", "")) != "distribute": continue
			seen_now[tid] = true
			if not life.has(tid):
				life[tid] = {
					"porter": tid, "spawn_tick": cur_tick, "leader_id": t.leader_id, "pop": t.population,
					"home": str(t.task_extra_data.get("home_pos", Vector2i(-1,-1))),
					"market": str(t.task_extra_data.get("market_pos", Vector2i(-1,-1))),
					"cargo_res": String(t.task_extra_data.get("cargo_res", "")),
					"cargo_start": float(t.task_extra_data.get("cargo_qty", 0.0)),
					"phases": {}, "arrived": false, "cargo_min": 1e18,
					"last_tile": "", "last_move_target": "", "last_phase": "", "last_seen_tick": cur_tick,
					"fate": "?", "gone_tick": -1,
				}
			var L: Dictionary = life[tid]
			var ph: String = String(t.task_extra_data.get("convoy_phase", "OUTBOUND"))
			L["phases"][ph] = int(L["phases"].get(ph, 0)) + 1
			if ph == "RETURN" or ph == "DELIVER": L["arrived"] = true
			var cres: String = String(L["cargo_res"])
			L["cargo_min"] = minf(float(L["cargo_min"]), float(t.resources.get(cres, 0.0)))
			L["last_tile"] = str(t.tile_pos)
			L["last_move_target"] = str(t.move_target)
			L["last_phase"] = ph
			L["last_seen_tick"] = cur_tick
			# arrive 判定：OUTBOUND 且 move_target 已消（抵 market）
			if ph == "OUTBOUND" and t.move_target == Vector2i(-1, -1): L["arrived"] = true

		# 消失偵測：上 tick 見、本 tick 不見 → gone（記最後站）
		for pid in life:
			if seen_prev.has(pid) and not seen_now.has(pid) and int(life[pid]["gone_tick"]) == -1:
				life[pid]["gone_tick"] = cur_tick
		seen_prev = seen_now

		# ── (b) T1 追蹤 ──
		if state.teams.has(1):
			var T1: TeamData = state.teams[1]
			t1["alive_at_end"] = true
			if T1.current_task != t1_last_task:
				(t1["tasks"] as Array).append({"tick": cur_tick, "task": T1.current_task})
				t1_last_task = T1.current_task
			t1["last_task"] = T1.current_task
			t1["last_pop"] = T1.population
			t1["min_pop"] = mini(int(t1["min_pop"]), T1.population)
			if cur_tick % WorldState.TICKS_PER_DAY == 0:
				(t1["pop_daily"] as Array).append({"day": cur_tick / WorldState.TICKS_PER_DAY, "pop": T1.population,
					"food": snappedf(ResourceSystem.effective_food(state, T1), 0.1), "task": T1.current_task})
			# T1 派 letter?（in_transit_letters origin=1）
			for letter in state.in_transit_letters:
				if int(letter.get("origin_team_id", -1)) == 1 and not bool(t1["letter_dispatched"]):
					t1["letter_dispatched"] = true; t1["letter_tick"] = cur_tick
		else:
			if int(t1["death_tick"]) == -1 and (t1["last_pop"] as int) >= 0:
				t1["death_tick"] = cur_tick
			t1["alive_at_end"] = false

	# ── 每 convoy fate 歸類 ──
	for pid in life:
		var L: Dictionary = life[pid]
		var reached_return_home: bool = String(L["last_phase"]) == "RETURN" and String(L["last_move_target"]) == "(-1, -1)"
		var delivered: bool = float(L["cargo_min"]) < float(L["cargo_start"]) - 0.5   # cargo 掉了=有 deposit
		if int(L["gone_tick"]) == -1:
			L["fate"] = "STILL_ALIVE_AT_END(" + String(L["last_phase"]) + ")"
		elif bool(L["arrived"]) and delivered:
			L["fate"] = "DELIVERED_then_gone"
		elif bool(L["arrived"]) and not delivered:
			L["fate"] = "ARRIVED_but_NODELIVER(bail)"
		elif String(L["last_phase"]) == "RETURN":
			L["fate"] = "RETURN_merged(no_deliver?)"
		else:
			L["fate"] = "GONE_mid_OUTBOUND(culled/dead 疑黑洞)"

	# ── dump ──
	print("\n───── (a) distribute convoy 逐站表（共 %d 個 porter）─────" % life.size())
	print("  distribute.dispatch=%d convoy.deliver(arrive)=%d convoy.deliver_settled=%d distribute.deliver(settle)=%d food_delivered=%.1f" % [
		int(Probe.counts.get("distribute.dispatch",0)), int(Probe.counts.get("convoy.deliver",0)),
		int(Probe.counts.get("convoy.deliver_settled",0)), int(Probe.counts.get("distribute.deliver",0)),
		float(Probe.amounts.get("distribute.food_delivered",0.0))])
	var bail_keys: Array = []
	for k in Probe.counts:
		if String(k).begins_with("convoy.deliver_bail_"): bail_keys.append(k)
	for k in bail_keys:
		print("  %s=%d" % [k, int(Probe.counts[k])])
	var pids: Array = life.keys(); pids.sort()
	for pid in pids:
		var L: Dictionary = life[pid]
		print("  porter%d spawn@%d ldr=%d pop=%d home%s→market%s cargo=%s×%.0f | phases=%s arrived=%s cargo_min=%.0f last=(%s mt%s ph%s) gone@%d → ★%s" % [
			pid, int(L["spawn_tick"]), int(L["leader_id"]), int(L["pop"]), L["home"], L["market"],
			L["cargo_res"], float(L["cargo_start"]), str(L["phases"]), str(L["arrived"]), float(L["cargo_min"]),
			L["last_tile"], L["last_move_target"], L["last_phase"], int(L["gone_tick"]), L["fate"]])

	print("\n───── (b) T1 死因 ─────")
	print("  alive_at_end=%s death_tick=%d(day %d) last_task=%s last_pop=%d min_pop=%d" % [
		str(t1["alive_at_end"]), int(t1["death_tick"]), int(t1["death_tick"])/WorldState.TICKS_PER_DAY,
		String(t1["last_task"]), int(t1["last_pop"]), int(t1["min_pop"])])
	print("  T1 派 letter(herald detach anon)? %s @tick %d" % [str(t1["letter_dispatched"]), int(t1["letter_tick"])])
	print("  T1 task 序: %s" % str(t1["tasks"]))
	print("  T1 pop/food 逐日: %s" % str(t1["pop_daily"]))

	# JSON 落地
	var dump: Dictionary = {
		"diagnostic": "convoy-lifecycle 5/6 + T1 死因（measure-first、只交真值）",
		"bed": "convoy_t1_diag_bed (peaceful_economy config seed 70730 6mo inline、純觀測)",
		"probe": {
			"distribute.dispatch": int(Probe.counts.get("distribute.dispatch",0)),
			"convoy.deliver_arrive": int(Probe.counts.get("convoy.deliver",0)),
			"convoy.deliver_settled": int(Probe.counts.get("convoy.deliver_settled",0)),
			"distribute.deliver_settle": int(Probe.counts.get("distribute.deliver",0)),
			"distribute.food_delivered": float(Probe.amounts.get("distribute.food_delivered",0.0)),
		},
		"convoy_life": life,
		"t1": t1,
	}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	print("=== DONE ===")
	quit()
