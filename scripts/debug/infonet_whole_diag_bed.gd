extends SceneTree

# 資訊網 whole 診斷床（measurer持久fixture，2026-08-04起persist，治reproducibility缺口）。
# 重現 RE-measure#6 的「資訊網whole獨立驗收床」（config/infonet_whole.json，同一份 fixture 全系列沿用）
# + implementer 的 convoy-lifecycle/T1死因診斷邏輯（同 convoy_t1_diag_bed.gd 手法，純觀測零 randf）。
# 工單 2026-08-04-systems-to-measurer-reproduce-6-bed-tap-convoy-t1.md：
#   (a) convoy-lifecycle 逐站表：distribute relief convoy 全生命（spawn→tick→travel→arrive→deliver / culled）。
#   (b) T1/T3 死因：task 序 + pop 變化 + 有無派 herald letter（detach anon）。
# ★純觀測：seed()+inline advance_tick（合法世界設置，同 peaceful_economy_bed._print_team_stories），
#   每 tick 只 READ state（零 randf、零 sim-code 改）。

const CONFIG_PATH := "res://config/infonet_whole.json"
const SEED: int = 1337
const DAYS: int = 60
const OUT_PATH := "res://docs/measurements/2026-08-04-infonet-whole-convoy-t1death-diagnostic.json"

func _initialize() -> void:
	print("=== 資訊網whole convoy-lifecycle + T1/T3死因 診斷（seed=%d %d天、純觀測）===" % [SEED, DAYS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var ticks: int = WorldState.TICKS_PER_DAY * DAYS

	var life: Dictionary = {}          # porter_id → 生命站表
	var residents: Dictionary = {
		1: _mk_resident_track(),
		3: _mk_resident_track(),
	}
	var last_task: Dictionary = {1: "<init>", 3: "<init>"}
	var seen_prev: Dictionary = {}

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
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
					"home": str(t.task_extra_data.get("home_pos", Vector2i(-1, -1))),
					"market": str(t.task_extra_data.get("market_pos", Vector2i(-1, -1))),
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
			if ph == "OUTBOUND" and t.move_target == Vector2i(-1, -1): L["arrived"] = true

		for pid in life:
			if seen_prev.has(pid) and not seen_now.has(pid) and int(life[pid]["gone_tick"]) == -1:
				life[pid]["gone_tick"] = cur_tick
		seen_prev = seen_now

		# ── (b) T1/T3 追蹤 ──
		for rid in [1, 3]:
			var R: Dictionary = residents[rid]
			if state.teams.has(rid):
				var T: TeamData = state.teams[rid]
				R["alive_at_end"] = true
				if T.current_task != last_task[rid]:
					(R["tasks"] as Array).append({"tick": cur_tick, "task": T.current_task})
					last_task[rid] = T.current_task
				R["last_task"] = T.current_task
				R["last_pop"] = T.population
				R["min_pop"] = mini(int(R["min_pop"]), T.population)
				if cur_tick % WorldState.TICKS_PER_DAY == 0:
					(R["pop_daily"] as Array).append({"day": cur_tick / WorldState.TICKS_PER_DAY, "pop": T.population,
						"food": snappedf(ResourceSystem.effective_food(state, T), 0.1), "task": T.current_task})
				for letter in state.in_transit_letters:
					if int(letter.get("origin_team_id", -1)) == rid and not bool(R["letter_dispatched"]):
						R["letter_dispatched"] = true; R["letter_tick"] = cur_tick
			else:
				if int(R["death_tick"]) == -1 and (R["last_pop"] as int) >= 0:
					R["death_tick"] = cur_tick
				R["alive_at_end"] = false

	# ── 每 convoy fate 歸類 ──
	for pid in life:
		var L: Dictionary = life[pid]
		var delivered: bool = float(L["cargo_min"]) < float(L["cargo_start"]) - 0.5
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
		int(Probe.counts.get("distribute.dispatch", 0)), int(Probe.counts.get("convoy.deliver", 0)),
		int(Probe.counts.get("convoy.deliver_settled", 0)), int(Probe.counts.get("distribute.deliver", 0)),
		float(Probe.amounts.get("distribute.food_delivered", 0.0))])
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

	for rid in [1, 3]:
		var R: Dictionary = residents[rid]
		print("\n───── (b) T%d 死因 ─────" % rid)
		print("  alive_at_end=%s death_tick=%d(day %d) last_task=%s last_pop=%d min_pop=%d" % [
			str(R["alive_at_end"]), int(R["death_tick"]), int(R["death_tick"]) / WorldState.TICKS_PER_DAY if int(R["death_tick"]) >= 0 else -1,
			String(R["last_task"]), int(R["last_pop"]), int(R["min_pop"])])
		print("  T%d 派 letter(herald detach anon)? %s @tick %d" % [rid, str(R["letter_dispatched"]), int(R["letter_tick"])])
		print("  T%d task 序: %s" % [rid, str(R["tasks"])])
		print("  T%d pop/food 逐日: %s" % [rid, str(R["pop_daily"])])

	# JSON 落地
	var dump: Dictionary = {
		"diagnostic": "資訊網whole convoy-lifecycle + T1/T3死因（measure-first、只交真值）",
		"bed": "infonet_whole_diag_bed (config/infonet_whole.json seed1337 60天inline、純觀測、fixture persist)",
		"probe": {
			"distribute.dispatch": int(Probe.counts.get("distribute.dispatch", 0)),
			"convoy.deliver_arrive": int(Probe.counts.get("convoy.deliver", 0)),
			"convoy.deliver_settled": int(Probe.counts.get("convoy.deliver_settled", 0)),
			"distribute.deliver_settle": int(Probe.counts.get("distribute.deliver", 0)),
			"distribute.food_delivered": float(Probe.amounts.get("distribute.food_delivered", 0.0)),
		},
		"convoy_life": life,
		"residents": residents,
	}
	var f := FileAccess.open(OUT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("\n[dump] → %s" % OUT_PATH)
	print("=== DONE ===")
	quit()

func _mk_resident_track() -> Dictionary:
	return {
		"tasks": [], "pop_daily": [], "letter_dispatched": false, "letter_tick": -1,
		"death_tick": -1, "last_task": "", "last_pop": -1, "min_pop": 1 << 30, "alive_at_end": false,
	}
