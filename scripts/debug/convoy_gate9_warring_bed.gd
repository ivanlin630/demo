extends SceneTree
# ★gate9票(2026-08-21 systems補發)：warring_states世界找T3 stranded第一個真樣本。
# 跑法同convoy_return_conservation_bed(含2026-08-21多趟追蹤+fate分類修正)，另加
# stranded偵測(porter活著但parent_team_id變-1)+distance-to-parent逐筆記錄。
# 純bed端觀測，零production改。main已有merged convoy母刀(0c92cd96)，此輪不需t3-budget分支。

var _rec: Dictionary = {}          # porter_id → Array[trip 記錄]
var _last_return: int = 0
var _last_stranded: int = 0
var _stranded_log: Array = []      # 逐筆{porter,parent,tick,dist,reason}

func _initialize() -> void:
	_run(); quit()

func _snap(t: TeamData) -> Dictionary:
	var out: Dictionary = {}
	for k in t.resources:
		var v: float = float(t.resources[k])
		if absf(v) > 0.001: out[k] = v
	return out

func _run() -> void:
	var cfg_name: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "warring_states"
	var days_env: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 0
	var months: int = int(OS.get_environment("LW_MONTHS")) if OS.get_environment("LW_MONTHS") != "" else 1
	var seed_v: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	var ticks: int = (days_env * WorldState.TICKS_PER_DAY) if days_env > 0 else (maxi(months, 1) * WorldState.TICKS_PER_MONTH)
	print("=== gate9 warring convoy stranded床：config=%s ticks=%d seed=%d ===" % [cfg_name, ticks, seed_v])

	seed(seed_v)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg_name)
	if config.is_empty():
		print("[FAIL] config 載入失敗"); Probe.enabled = false; return
	config["seed"] = seed_v
	GameSetup.setup(state, config)

	SpecimenDumpHelper.setup_from_env(state)

	var no_player := Vector2i(-1, -1)
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		_observe(state)
		if (tick + 1) % (WorldState.TICKS_PER_DAY * 5) == 0:
			_report(cfg_name, state, int((tick + 1) / WorldState.TICKS_PER_DAY), out_path)
		if state.teams.is_empty():
			print("[bed] 全滅 @tick=%d" % tick); break
	_report(cfg_name, state, int(ticks / WorldState.TICKS_PER_DAY), out_path)
	var spec_path: String = OS.get_environment("SPECIMEN_OUT")
	if spec_path == "": spec_path = "docs/measurements/gate9-warring.specimen.jsonl"
	SpecimenDumpHelper.dump(state, spec_path)
	Probe.enabled = false
	print("=== gate9 warring convoy stranded床 DONE ===")

func _observe(state: WorldState) -> void:
	var now: int = state.world.current_tick
	var ret_now: int = int(Probe.counts.get("convoy.return", 0))
	var returned_this_tick: int = ret_now - _last_return
	_last_return = ret_now
	var stranded_now: int = int(Probe.counts.get("convoy.stranded", 0))
	var stranded_this_tick: int = stranded_now - _last_stranded
	_last_stranded = stranded_now

	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.parent_team_id == -1:
			continue
		var _trips: Array = _rec.get(tid, [])
		var _need_new_trip: bool = _trips.is_empty() or not (String(_trips[-1]["fate"]) in ["in_flight", "left_convoy"])
		if t.current_task == TeamData.TASK_CONVOY and _need_new_trip:
			var parent: TeamData = state.teams.get(t.parent_team_id)
			_trips.append({
				"parent": t.parent_team_id, "dispatch_tick": now,
				"porter_at_dispatch": _snap(t),
				"parent_at_dispatch": _snap(parent) if parent != null else {},
				"left_tick": -1, "left_task": "", "left_phase": "", "left_res": {},
				"fate": "in_flight", "end_res": {},
			})
			_rec[tid] = _trips

	# ★stranded偵測：porter仍活著,但parent_team_id這tick變成-1(且上個tick有紀錄有效parent)
	for pid in _rec:
		var trips: Array = _rec[pid]
		if trips.is_empty(): continue
		var r: Dictionary = trips[-1]
		if r["fate"] != "in_flight" and r["fate"] != "left_convoy":
			continue
		var p: TeamData = state.teams.get(pid)
		if p == null:
			if returned_this_tick > 0:
				var last_known_parent: int = int(r.get("last_parent_id", r["parent"]))
				if last_known_parent == int(r["parent"]):
					r["fate"] = "merged_home"
				else:
					r["fate"] = "merged_into_stranger"
					r["merged_into"] = last_known_parent
				returned_this_tick -= 1
			else:
				r["fate"] = "erased"
			r["end_tick"] = now
			continue
		# ★stranded轉獨立：porter活著但parent_team_id從有效值變-1
		if p.parent_team_id == -1 and int(r.get("last_parent_id", r["parent"])) != -1:
			var orig_parent_id: int = int(r["parent"])
			var orig_parent: TeamData = state.teams.get(orig_parent_id)
			var dist: int = -1
			if orig_parent != null:
				dist = FactionAISystem._hex_dist(p.tile_pos, orig_parent.tile_pos)
			r["fate"] = "stranded"
			r["stranded_dist"] = dist
			r["end_tick"] = now
			r["end_res"] = _snap(p)
			_stranded_log.append({"porter": pid, "parent": orig_parent_id, "tick": now, "dist": dist,
				"porter_pos": [p.tile_pos.x, p.tile_pos.y],
				"parent_pos": [orig_parent.tile_pos.x, orig_parent.tile_pos.y] if orig_parent != null else null,
				"dist_trend": (r.get("dist_hist", []) as Array).duplicate()})
			continue
		r["last_parent_id"] = p.parent_team_id
		# ★measurer temp tap(2026-08-21,systems票②趨勢非瞬時):每20 tick記{tick,dist,parent_pos}
		# 供stranded發生時回顧『距離是否收斂(即將抵達)vs持平(永恆尾隨)』+『母隊有無移動』。bound最近15筆。
		if now % 20 == 0 and int(r["parent"]) != -1:
			var _pp: TeamData = state.teams.get(int(r["parent"]))
			if _pp != null:
				var _dh: Array = r.get("dist_hist", [])
				_dh.append({"tick": now, "dist": FactionAISystem._hex_dist(p.tile_pos, _pp.tile_pos),
					"parent_pos": [_pp.tile_pos.x, _pp.tile_pos.y]})
				if _dh.size() > 15: _dh.pop_front()
				r["dist_hist"] = _dh
		if p.current_task != TeamData.TASK_CONVOY and r["left_tick"] == -1:
			var xd: Dictionary = p.task_extra_data if p.task_extra_data is Dictionary else {}
			r["left_tick"] = now
			r["left_task"] = p.current_task
			r["left_phase"] = String(xd.get("convoy_phase", "?"))
			r["left_res"] = _snap(p)
			r["fate"] = "left_convoy"

func _report(cfg: String, state: WorldState, day: int, out_path: String) -> void:
	var lines: Array = []
	var _all_trips: Array = []
	for _pid2 in _rec:
		for _tr in (_rec[_pid2] as Array):
			_all_trips.append([_pid2, _tr])
	lines.append("[%s day %d] teams=%d porters_tracked=%d trips_total=%d" % [cfg, day, state.teams.size(), _rec.size(), _all_trips.size()])
	lines.append("  convoy: dispatch=%d attempt=%d deliver=%d settled=%d return=%d stranded=%d" % [
		int(Probe.counts.get("convoy.dispatch", 0)), int(Probe.counts.get("convoy.dispatch_attempt", 0)),
		int(Probe.counts.get("convoy.deliver", 0)), int(Probe.counts.get("convoy.deliver_settled", 0)),
		int(Probe.counts.get("convoy.return", 0)), int(Probe.counts.get("convoy.stranded", 0))])
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks == "persist.hold" or ks == "convoy.rehome" or ks == "convoy.dispatch_attempt" \
			or ks == "convoy.drop.inflight_convoy" or ks.begins_with("convoy.stranded"):
			lines.append("  %-46s = %d" % [ks, int(Probe.counts[k])])
	var fates: Dictionary = {}
	for _pair in _all_trips:
		var r: Dictionary = _pair[1]
		var f: String = String(r["fate"])
		var alive: TeamData = state.teams.get(int(_pair[0]))
		if alive != null and f == "left_convoy": f = "ghost_alive(censored,未終局)"
		elif alive != null and f == "in_flight": f = "still_convoy(censored,未終局)"
		fates[f] = int(fates.get(f, 0)) + 1
	lines.append("  下場分佈：%s" % str(fates))
	lines.append("  ★★stranded逐筆(distance=當下porter與原parent hex距離,-1=parent已不存在無法算)：")
	for s in _stranded_log:
		lines.append("    %s" % str(s))
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f2 := FileAccess.open(out_path, FileAccess.WRITE)
		if f2 != null:
			f2.store_string(text + "\n"); f2.close()
