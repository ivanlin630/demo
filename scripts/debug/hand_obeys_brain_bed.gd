extends SceneTree

# hand_obeys_brain_bed.gd — 「手聽腦」單點同-tick 不變量 bed（純觀測，零 sim 邏輯變）。
#
# ★重建（2026-07-07）：舊版量「每 240 tick 重算 rank_scored[0] vs current_task 分桶算率」當閘壞——
#   三漏洞：①腦模型只 rank_scored 比真引擎（4 subset weigh）窄 → subset 模型差誤記違規；
#   ②rank 采樣當下重算、task 上 cadence 設 → 執行中誤判（subteam 86% 大半此）；③跨版本 aggregate=噪音
#  （A1c 沒碰 arbiter 卻 latch 270→198 純世界分岔）。→ 當「跨修率比閘」無效。
#
# 新法 = 單點同-tick 探針（HandBrainProbe）：掛在引擎真正敲定決策那一刻（_decide_unified／非-unified solo
#   dispatch），呼叫 try_set 的同一 tick、同一 state，比「腦這次實際敲定的 winner task」vs「手 try_set 後
#   持有的 current_task」。零延遲、零重算。輸出=**同一次跑內的違規事件清單**（哪隊/哪 tick/腦選啥/手做啥/
#   被哪機制攔）+ 分機制計數。同 seed 同 code 逐事件確定性復現（本 bed 末段 determinism 硬證）。
#
# 分機制（見 HandBrainProbe doc）：
#   arbiter_latch / side_effect_freeze / subset_fallthrough / other（引擎單點不變量）
#   + leader_bypass / subteam_bypass（A2 scope，繞引擎手寫 dispatch 結構計數）
#
# 非擾動：HandBrainProbe.capture/note 只讀 + append 自家 static；零 state 寫、零 RNG。enabled=false →
#   early-return byte-identical。本 bed 末段：①determinism（同 seed 兩跑逐事件相同）②vs WarringHarness clean final。
#
# 用法：.\tools\godot.ps1 --headless --script scripts/debug/hand_obeys_brain_bed.gd
#   env HOB_SEEDS（default "1337"）、HOB_MONTHS（default 1）、HOB_DUMP（default 40 = 印前 N 事件）

const CONFIG_PATH := "res://config/warring_states.json"

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seeds := _parse_seeds()
	var months := int(OS.get_environment("HOB_MONTHS")) if OS.has_environment("HOB_MONTHS") else 1
	var ticks := maxi(months, 1) * WorldState.TICKS_PER_MONTH
	var dump_n := int(OS.get_environment("HOB_DUMP")) if OS.has_environment("HOB_DUMP") else 40
	print("=== hand_obeys_brain_bed（單點同-tick 不變量）：seeds=%s months=%d (ticks=%d) ===" % [
		str(seeds), months, ticks])

	var results := {}   # seed → {snap, final}
	for s in seeds:
		var res := _run_seed(int(s), ticks)
		results[int(s)] = res
		_print_seed(int(s), res["snap"], dump_n)

	if seeds.size() > 1:
		print("\n########## 跨 seed 匯總 ##########")
		_print_agg(seeds, results)

	_prove_determinism(int(seeds[0]), ticks)
	_prove_nonperturbation(seeds, ticks, results)
	print("\n=== hand_obeys_brain_bed DONE ===")

# ── 跑單 seed：鏡射 WarringHarness.run tick 迴圈 + HandBrainProbe 掛在引擎 dispatch 點 ──
func _run_seed(world_seed: int, ticks: int) -> Dictionary:
	seed(world_seed)
	Probe.enabled = true; Probe.reset()          # 引擎自身 probe 照跑（byte-identical）
	HandBrainProbe.enabled = true; HandBrainProbe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	if config.is_empty():
		HandBrainProbe.enabled = false; Probe.enabled = false
		return {"snap": {}, "final": {}}
	config["seed"] = world_seed
	GameSetup.setup(state, config)

	var no_player := Vector2i(-1, -1)
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty():
			break

	var final := {
		"teams": state.teams.size(), "factions": state.factions.size(), "pop": _total_pop(state),
	}
	var snap := HandBrainProbe.snapshot()
	HandBrainProbe.enabled = false; Probe.enabled = false
	return {"snap": snap, "final": final}

# ── 輸出：單點違規事件清單 + 分機制計數 ──
func _print_seed(s: int, snap: Dictionary, dump_n: int) -> void:
	print("\n--- seed=%d ---" % s)
	if snap.is_empty():
		print("  (config 載入失敗)"); return
	var dec: int = int(snap["decisions"])
	var obey: int = int(snap["obeys"])
	var exc: int = int(snap["excused"])
	var viol: int = int(snap["violations"])
	print("  引擎 dispatch 決策點 = %d  %s" % [dec, _kv(snap["src_dec"])])
	print("  手==腦（obey）        = %d (%.1f%%)" % [obey, _pct(obey, dec)])
	print("  豁免（excused）       = %d (%.1f%%)  %s" % [exc, _pct(exc, dec), _kv(snap["excuse"])])
	print("  ★手≠腦 違規（viol）   = %d (%.1f%%)" % [viol, _pct(viol, dec)])
	print("    分機制（引擎單點不變量）：")
	for m in HandBrainProbe.MECHS:
		var c: int = int(snap["mech"].get(m, 0))
		if c > 0:
			print("      %-18s %6d (%.1f%% of dec, %.1f%% of viol)" % [m, c, _pct(c, dec), _pct(c, maxi(viol, 1))])
	print("    分 src（背離率 = viol/dec）：%s" % _src_rates(snap))
	var bp: Dictionary = snap["bypass"]
	print("    繞引擎 dispatch（A2 scope，結構計數，非本 tick 不變量）：leader_bypass=%d subteam_bypass=%d" % [
		int(bp.get("leader", 0)), int(bp.get("subteam", 0))])
	print("    腦 rank[0] 首選分布（top）：%s" % _top(snap["rank0_hist"], 6))
	if not snap["fallthrough_hist"].is_empty():
		print("    fallthrough 時被跳的 rank[0]：%s" % _top(snap["fallthrough_hist"], 6))
	# 單點違規事件清單（前 dump_n 筆；同 seed 同 code 逐事件確定性）
	var evs: Array = snap["events"]
	var viol_evs: Array = []
	for e in evs:
		if String(e.get("src", "")) != "bypass": viol_evs.append(e)
	print("    ── 單點違規事件清單（共 %d，印前 %d）──" % [viol_evs.size(), mini(dump_n, viol_evs.size())])
	for i in range(mini(dump_n, viol_evs.size())):
		var e: Dictionary = viol_evs[i]
		print("      tick=%-5d T%-4d [%s/%s] %-18s 腦=%s(%s) 手=%s set_ok=%s prio=%d ct=%d" % [
			int(e["tick"]), int(e["team_id"]), e["cat"], e["src"], e["mech"],
			e["rank0_opt"], e["winner_opt"], e["result_task"], str(e["set_ok"]), int(e["prio"]), int(e["ct"])])

func _src_rates(snap: Dictionary) -> String:
	var parts: Array = []
	for src in snap["src_dec"]:
		var d: int = int(snap["src_dec"][src])
		var v: int = int(snap["src_viol"].get(src, 0))
		parts.append("%s=%d/%d(%.1f%%)" % [src, v, d, _pct(v, d)])
	return ", ".join(parts)

func _print_agg(seeds: Array, results: Dictionary) -> void:
	var dec := 0; var obey := 0; var exc := 0; var viol := 0
	var mech := {}
	for m in HandBrainProbe.MECHS: mech[m] = 0
	var bp := {"leader": 0, "subteam": 0}
	for s in seeds:
		var snap: Dictionary = results[int(s)]["snap"]
		if snap.is_empty(): continue
		dec += int(snap["decisions"]); obey += int(snap["obeys"])
		exc += int(snap["excused"]); viol += int(snap["violations"])
		for m in HandBrainProbe.MECHS: mech[m] += int(snap["mech"].get(m, 0))
		bp["leader"] += int(snap["bypass"].get("leader", 0))
		bp["subteam"] += int(snap["bypass"].get("subteam", 0))
	print("  決策點=%d obey=%d(%.1f%%) excused=%d viol=%d(%.1f%%)" % [
		dec, obey, _pct(obey, dec), exc, viol, _pct(viol, dec)])
	for m in HandBrainProbe.MECHS:
		if int(mech[m]) > 0:
			print("    %-18s %6d (%.1f%% of dec)" % [m, int(mech[m]), _pct(int(mech[m]), dec)])
	print("    繞引擎：leader_bypass=%d subteam_bypass=%d" % [int(bp["leader"]), int(bp["subteam"])])

# ── determinism 硬證：同 seed 兩跑逐事件相同（deliverable #2 要求）──
func _prove_determinism(s: int, ticks: int) -> void:
	print("\n========== determinism 硬證（同 seed 兩跑逐事件相同）==========")
	var a: Dictionary = _run_seed(s, ticks)["snap"]
	var b: Dictionary = _run_seed(s, ticks)["snap"]
	var ok: bool = int(a.get("decisions", -1)) == int(b.get("decisions", -2)) \
		and int(a.get("violations", -1)) == int(b.get("violations", -2)) \
		and int((a.get("events", []) as Array).size()) == int((b.get("events", []) as Array).size())
	if ok:
		var ea: Array = a["events"]; var eb: Array = b["events"]
		for i in range(ea.size()):
			if str(ea[i]) != str(eb[i]): ok = false; break
	print("  seed=%d  run1(dec=%d viol=%d ev=%d) vs run2(dec=%d viol=%d ev=%d) → %s" % [
		s, int(a.get("decisions", -1)), int(a.get("violations", -1)), a.get("events", []).size(),
		int(b.get("decisions", -1)), int(b.get("violations", -1)), b.get("events", []).size(),
		"★逐事件確定性 PASS" if ok else "★MISMATCH（非確定性）"])

# ── 非擾動：instrumented final vs WarringHarness.run clean final（probe OFF，hooks early-return）──
# 結構硬保 = HandBrainProbe 只讀 + append 自家 static，零 state 寫零 RNG → 不可能擾動。此為經驗對照。
func _prove_nonperturbation(seeds: Array, ticks: int, results: Dictionary) -> void:
	print("\n========== 非擾動（instrumented vs WarringHarness clean final）==========")
	print("  （HandBrainProbe 結構上純讀無寫無 RNG → 硬保非擾動；下為經驗對照）")
	for s in seeds:
		var clean: Dictionary = WarringHarness.run(int(s), ticks, CONFIG_PATH).get("final", {})
		var inst: Dictionary = results[int(s)]["final"]
		var ok: bool = int(clean.get("teams", -1)) == int(inst.get("teams", -2)) \
			and int(clean.get("factions", -1)) == int(inst.get("factions", -2)) \
			and int(clean.get("pop", -1)) == int(inst.get("pop", -2))
		print("  seed=%d  clean=%s  inst=%s → %s" % [int(s), str(clean), str(inst),
			"MATCH（非擾動）" if ok else "★MISMATCH（in-process 位置噪或擾動，見 determinism 段）"])

# ── helpers ──
func _total_pop(state: WorldState) -> int:
	var n := 0
	for tid in state.teams: n += state.teams[tid].population
	return n

func _pct(a: int, b: int) -> float:
	return 0.0 if b == 0 else 100.0 * float(a) / float(b)

func _kv(d: Dictionary) -> String:
	var parts: Array = []
	for k in d:
		if int(d[k]) > 0: parts.append("%s=%d" % [k, int(d[k])])
	return "{" + ", ".join(parts) + "}"

func _top(d: Dictionary, n: int) -> String:
	var arr: Array = []
	for k in d: arr.append({"k": k, "v": int(d[k])})
	arr.sort_custom(func(a, b): return int(a["v"]) > int(b["v"]))
	var parts: Array = []
	for i in range(mini(n, arr.size())):
		parts.append("%s=%d" % [arr[i]["k"], arr[i]["v"]])
	return "{" + ", ".join(parts) + "}"

func _parse_seeds() -> Array:
	var raw: String = OS.get_environment("HOB_SEEDS")
	if raw == "": raw = "1337"
	var out: Array = []
	for tok in raw.split(",", false):
		var t: String = tok.strip_edges()
		if t.is_valid_int(): out.append(int(t))
	if out.is_empty(): out = [1337]
	return out
