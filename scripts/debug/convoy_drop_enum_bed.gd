extends SceneTree
# convoy dispatch-drop 結構列舉床（★evidence-only，systems dispatch 2026-08-21）。
# 跑一段真實 run → 報：①_dispatch_convoy 七個原本靜默 return false 各掉多少 + attempt 總數
# ②上游對照：decision.opt_chosen.deliver_* / diag.deliver_*.appl_n / convoy.route.delegate_entered.*
#   → 若「被選 N 次」而 attempt 遠少於 N，斷點在「選中→呼叫 _dispatch_convoy」之間（更上游）。
# 純觀測，零 sim 邏輯改。
# env：LW_CONFIG（預設 peaceful_economy）、LW_MONTHS（預設 1）、PERF_SEED（1337）、PERF_OUT（sidecar）

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg_name: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var months: int = int(OS.get_environment("LW_MONTHS")) if OS.get_environment("LW_MONTHS") != "" else 1
	var seed_v: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	var ticks: int = maxi(months, 1) * WorldState.TICKS_PER_MONTH
	print("=== convoy drop enum：config=%s months=%d seed=%d ===" % [cfg_name, months, seed_v])

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

	# ★長跑硬規則（用戶 2026-07-22）：附 specimen trace → 送 QA 故事稽核，才可下 behavior 因果結論。
	SpecimenDumpHelper.setup_from_env(state)

	var no_player := Vector2i(-1, -1)
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % (WorldState.TICKS_PER_DAY * 5) == 0:
			_report(cfg_name, int((tick + 1) / WorldState.TICKS_PER_DAY), state, out_path, false)
		if state.teams.is_empty():
			print("[bed] 全滅 @tick=%d" % tick); break
	_report(cfg_name, int(ticks / WorldState.TICKS_PER_DAY), state, out_path, true)
	var spec_path: String = OS.get_environment("SPECIMEN_OUT")
	if spec_path == "": spec_path = "docs/measurements/convoy-drop-enum-%s.specimen.jsonl" % cfg_name
	SpecimenDumpHelper.dump(state, spec_path)
	Probe.enabled = false
	print("=== convoy drop enum DONE ===")

const DROPS: Array = [
	"convoy.drop.0_dispatched", "convoy.drop.1_no_target", "convoy.drop.2_parent_pop",
	"convoy.drop.3_cargo_empty", "convoy.drop.4_inflight_convoy", "convoy.drop.5_load_lt1",
	"convoy.drop.6_no_advisor", "convoy.drop.7_subteam_fail",
]

func _report(cfg: String, day: int, state: WorldState, out_path: String, final: bool) -> void:
	var lines: Array = []
	lines.append("[%s day %d] teams=%d" % [cfg, day, state.teams.size()])
	var attempt: int = int(Probe.counts.get("convoy.dispatch_attempt", 0))
	lines.append("convoy.dispatch_attempt = %d" % attempt)
	for k in DROPS:
		var v: int = int(Probe.counts.get(k, 0))
		lines.append("  %-32s = %6d  (%.1f%%)" % [k, v, 100.0 * float(v) / maxf(float(attempt), 1.0)])
	# kind 分流 + 上游對照 + seek_market
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks.begins_with("convoy.attempt_kind.") or ks.begins_with("convoy.route.") \
				or ks.begins_with("decision.opt_chosen.deliver") or ks.begins_with("diag.deliver") \
				or ks.begins_with("merchant.") or ks == "g1.seek_market" or ks == "g1.arb_attempt" \
				or ks.begins_with("convoy.") and not ks.begins_with("convoy.drop."):
			lines.append("  %-40s = %d" % [ks, int(Probe.counts[k])])
	# ★throttle 持有者現況：誰佔著「一隊一 convoy」的位子、卡在哪個 phase、卡多久
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.current_task != TeamData.TASK_CONVOY:
			continue
		var xd: Dictionary = t.task_extra_data if t.task_extra_data is Dictionary else {}
		lines.append("  [in-flight] porter=%d parent=%d phase=%s kind=%s cargo=%s qty=%.1f pos=(%d,%d) market=%s pop=%d" % [
			tid, t.parent_team_id, String(xd.get("convoy_phase", "?")), String(xd.get("convoy_kind", "?")),
			String(xd.get("cargo_res", "?")), float(xd.get("cargo_qty", 0.0)),
			t.tile_pos.x, t.tile_pos.y, str(xd.get("market_pos", Vector2i(-1, -1))), t.population])
	# ★派出去的 porter 後來怎麼了（convoy.return=0 但也不在 TASK_CONVOY → 去哪了）
	for tid in state.teams:
		var st: TeamData = state.teams[tid]
		if st.parent_team_id == -1:
			continue
		lines.append("  [subteam] id=%d parent=%d task=%s pop=%d pos=(%d,%d) tags=%s" % [
			tid, st.parent_team_id, st.current_task, st.population,
			st.tile_pos.x, st.tile_pos.y, str(st.tags)])
	var text: String = "\n".join(PackedStringArray(lines))
	if true:   # 每 5 日快照都印（要看 throttle 佔用的時間分佈）
		print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
