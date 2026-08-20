extends SceneTree
# convoy RETURN 腿【守恆】量測床（★evidence-only，systems dispatch 2026-08-21）。
# 問題不是「為什麼不回家」，是【貨款與剩貨去哪了】：porter 脫離 CONVOY 後身上的 coin/貨若沒回母隊
# ＝守恆破口（會污染所有經濟推論）。
#
# 作法：純 bed 端逐 tick 觀測（零 production 改）：
#   ①偵測新 porter（current_task==TASK_CONVOY 且 parent!=-1）→ 記 dispatch tick、母隊、當下雙方資源
#   ②每 tick 追蹤：porter 脫離 CONVOY 的【那一刻】記 tick/新 task/convoy_phase/身上所有資源
#   ③porter 消失那一刻：用 convoy.return 計數差分判【歸建】vs【滅團】
#   ④結尾：下場分佈 + 殘留 coin/貨總量（依下場分類）+ 母隊資源變化
# env：LW_CONFIG（peaceful_economy）、LW_MONTHS(1)、ADHOC_DAYS(覆寫天數)、PERF_SEED(1337)、PERF_OUT(sidecar)

var _rec: Dictionary = {}          # porter_id → 記錄
var _last_return: int = 0

func _initialize() -> void:
	_run(); quit()

func _snap(t: TeamData) -> Dictionary:
	var out: Dictionary = {}
	for k in t.resources:
		var v: float = float(t.resources[k])
		if absf(v) > 0.001: out[k] = v
	return out

func _sum(d: Dictionary, keys: Array) -> float:
	var s: float = 0.0
	for k in keys:
		s += float(d.get(k, 0))
	return s

func _run() -> void:
	var cfg_name: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var months: int = int(OS.get_environment("LW_MONTHS")) if OS.get_environment("LW_MONTHS") != "" else 1
	var days_env: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 0
	var seed_v: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	var ticks: int = (days_env * WorldState.TICKS_PER_DAY) if days_env > 0 else (maxi(months, 1) * WorldState.TICKS_PER_MONTH)
	print("=== convoy RETURN 守恆床：config=%s ticks=%d seed=%d ===" % [cfg_name, ticks, seed_v])

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

	SpecimenDumpHelper.setup_from_env(state)   # ★長跑硬規則：附 specimen trace 送 QA 故事稽核

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
	if spec_path == "": spec_path = "docs/measurements/convoy-return-closure-%s.specimen.jsonl" % cfg_name
	SpecimenDumpHelper.dump(state, spec_path)
	Probe.enabled = false
	print("=== convoy RETURN 守恆床 DONE ===")

# 逐 tick 觀測：新 porter / 脫離 CONVOY / 消失（歸建 vs 滅團）
func _observe(state: WorldState) -> void:
	var now: int = state.world.current_tick
	var ret_now: int = int(Probe.counts.get("convoy.return", 0))
	var returned_this_tick: int = ret_now - _last_return
	_last_return = ret_now

	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.parent_team_id == -1:
			continue
		if t.current_task == TeamData.TASK_CONVOY and not _rec.has(tid):
			var parent: TeamData = state.teams.get(t.parent_team_id)
			_rec[tid] = {
				"parent": t.parent_team_id, "dispatch_tick": now,
				"porter_at_dispatch": _snap(t),
				"parent_at_dispatch": _snap(parent) if parent != null else {},
				"left_tick": -1, "left_task": "", "left_phase": "", "left_res": {},
				"fate": "in_flight", "end_res": {},
			}

	for pid in _rec:
		var r: Dictionary = _rec[pid]
		if r["fate"] != "in_flight" and r["fate"] != "left_convoy":
			continue
		var p: TeamData = state.teams.get(pid)
		if p == null:
			# 消失：這 tick 有 convoy.return → 歸建；否則滅團/其他移除
			r["fate"] = "merged_home" if returned_this_tick > 0 else "erased"
			r["end_tick"] = now
			if returned_this_tick > 0: returned_this_tick -= 1
			continue
		if p.current_task != TeamData.TASK_CONVOY and r["left_tick"] == -1:
			var xd: Dictionary = p.task_extra_data if p.task_extra_data is Dictionary else {}
			r["left_tick"] = now
			r["left_task"] = p.current_task
			r["left_phase"] = String(xd.get("convoy_phase", "?"))
			r["left_res"] = _snap(p)
			r["fate"] = "left_convoy"

func _report(cfg: String, state: WorldState, day: int, out_path: String) -> void:
	var lines: Array = []
	lines.append("[%s day %d] teams=%d porters_tracked=%d" % [cfg, day, state.teams.size(), _rec.size()])
	lines.append("  convoy: dispatch=%d attempt=%d deliver=%d settled=%d return=%d" % [
		int(Probe.counts.get("convoy.dispatch", 0)), int(Probe.counts.get("convoy.dispatch_attempt", 0)),
		int(Probe.counts.get("convoy.deliver", 0)), int(Probe.counts.get("convoy.deliver_settled", 0)),
		int(Probe.counts.get("convoy.return", 0))])
	for k in Probe.counts.keys():
		var ks: String = String(k)
		if ks == "persist.hold" or ks == "convoy.rehome" or ks == "convoy.dispatch_attempt" 				or ks == "convoy.drop.inflight_convoy" or ks.begins_with("convoy.stranded"):
			lines.append("  %-46s = %d" % [ks, int(Probe.counts[k])])
	var fates: Dictionary = {}
	var residual: Dictionary = {}     # fate → {res → 量}
	var VAL_KEYS: Array = ["coin", "food", "material", "goods", "gem", "tools"]
	for pid in _rec:
		var r: Dictionary = _rec[pid]
		var f: String = String(r["fate"])
		# 存活者用當下資源、已消失者用脫離當下（沒脫離就直接消失＝歸建/滅團，無殘留可言）
		var alive: TeamData = state.teams.get(pid)
		if alive != null:
			r["end_res"] = _snap(alive)
			if f == "left_convoy": f = "ghost_alive"
			elif f == "in_flight": f = "still_convoy"
		fates[f] = int(fates.get(f, 0)) + 1
		var res_now: Dictionary = r["end_res"] if not (r["end_res"] as Dictionary).is_empty() else r["left_res"]
		if f == "ghost_alive" or f == "still_convoy" or (f == "erased" and not (r["left_res"] as Dictionary).is_empty()):
			var acc: Dictionary = residual.get(f, {})
			for k in VAL_KEYS:
				var v: float = float((res_now as Dictionary).get(k, 0))
				if v > 0.001: acc[k] = float(acc.get(k, 0)) + v
			residual[f] = acc
	lines.append("  下場分佈：%s" % str(fates))
	lines.append("  ★殘留（未回母隊、還在 porter 身上）：%s" % str(residual))
	# 逐隻明細（少量、值得逐隻看）
	for pid in _rec:
		var r: Dictionary = _rec[pid]
		var par: TeamData = state.teams.get(int(r["parent"]))
		var par_now: Dictionary = _snap(par) if par != null else {}
		var par_vault: Dictionary = {}
		if par != null:
			var ht: HexTileData = state.world.tiles.get(par.tile_pos.x * 1000 + par.tile_pos.y)
			if ht != null and ht.outpost_owner == par.team_id:
				for k in ht.public_storage:
					if float(ht.public_storage[k]) > 0.001: par_vault[k] = float(ht.public_storage[k])
		lines.append("   porter=%d parent=%s dispatch@%d 出發帶=%s ｜脫離@%s task=%s phase=%s 身上=%s ｜結局=%s 現持=%s" % [
			pid, str(r["parent"]), int(r["dispatch_tick"]), str(r["porter_at_dispatch"]),
			str(r["left_tick"]), str(r["left_task"]), str(r["left_phase"]), str(r["left_res"]),
			str(r["fate"]), str(r["end_res"])])
		if r.has("end_tick"):
			var dt: int = int(r["end_tick"]) - int(r["dispatch_tick"])
			lines.append("     ★結案 tick=%d（出發後 %d tick = %.1f 日）" % [
				int(r["end_tick"]), dt, float(dt) / float(WorldState.TICKS_PER_DAY)])
		lines.append("     母隊 %s：dispatch 當下=%s ｜現在=%s ｜現在公庫=%s" % [
			str(r["parent"]), str(r["parent_at_dispatch"]), str(par_now), str(par_vault)])
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f2 := FileAccess.open(out_path, FileAccess.WRITE)
		if f2 != null:
			f2.store_string(text + "\n"); f2.close()
