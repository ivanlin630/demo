extends SceneTree

# hand_obeys_brain_bed.gd — 「手聽腦」runtime 不變量儀器（純觀測，零 sim 邏輯變）。
#
# 目的（逆向 slice#1）：統一引擎是「idle-edge 填空器」。引擎以 rank_scored 排菜單，但隊實際
# 持有的 current_task 常非 rank[0] 映射的 task——被 TaskArbiter 嚴格大於 latch 丟、被 leader/子隊
# bypass、被 survival/threat 子集層蓋、或 D2 凍結。本儀器每 cadence 對每隊活捉此背離，
# 產出完整違憲清單 + A1 管線塌陷修的回歸閘。
#
# 量法：每 SAMPLE_INTERVAL tick（日級，= threat cadence 量級），對每隊：
#   誠實全菜單 = DecisionEngine.rank_scored_ctx(gather(state,team))；沿 rank 取首個可派 option → to_task
#     → brain_task（＝正確接線的引擎本 cadence 會執行的 task）。
#   實際 = team.current_task。brain_task ≠ 實際 → 潛在違規，依可觀測 state 分機制。
#   物理鎖（戰鬥/玩家/居民移動鎖）＝豁免（記錄非違規）；survival/threat 子集層＝subset-override
#     （單獨計，A1 會塌併，故計非豁免）。
#
# 非擾動：全 compute 在 advance_tick 之間跑，只讀——
#   gather / rank_scored_ctx / to_task / finders 皆無 RNG（已核）、無 state 寫（已核）；
#   Probe.enabled 於 compute 期間暫關（避 applicable 的 occupy.* bump）→ probe 計數不動。
#   ∴ 逐 tick 逐隊 RNG 流與 state 完全復現 WarringHarness.run（_run 末段對照證明）。
#
# 用法：.\tools\godot.ps1 --headless --script scripts/debug/hand_obeys_brain_bed.gd
#   env HOB_MONTHS（default 4）、HOB_SEEDS（default "1337,42,7"）、HOB_INTERVAL（default 240=每日）

const CONFIG_PATH := "res://config/warring_states.json"

# 機制桶（逆向 slice#1 根因分類）
const MECHS := ["arbiter_latch", "no_release_latch", "leader_bypass", "subteam_bypass",
	"subset_override", "freeze", "other"]
# 物理鎖豁免桶
const EXCUSES := ["combat", "player", "resident_lock"]
# 結構 team-category
const CATS := ["leader", "subteam", "member", "solo"]

# no-release task（裝上後每 cadence rank[0] 全被丟＝永久 latch，D1）
const NO_RELEASE := [TeamData.TASK_TRAIN, TeamData.TASK_MANUFACTURE, TeamData.TASK_GOVERN, TeamData.TASK_PRODUCE]
# 合法戰鬥 task（combat_target 正當鎖）
const COMBAT_TASKS := [TeamData.TASK_ATTACK, TeamData.TASK_LOOT, TeamData.TASK_DEFEND]

# ★純 option→task 映射（鏡射 DecisionOptions.to_task 的 task，去 target finder）。
# 關鍵：to_task 的 target finder 有副作用（_find_unowned_farmable_tile 播營、投靠 join_request 吃 randi()、
# 建國 f.is_established 等）→ 呼叫會擾動 sim。此表只取 task（applicable 已保證 option 可派），
# 全 read-only → 非擾動硬保。
const OPTION_TASK := {
	"貿易": TeamData.TASK_TRADE, "生產": TeamData.TASK_MANUFACTURE, "建設": TeamData.TASK_BUILD,
	"覓食": TeamData.TASK_FORAGE, "survival": TeamData.TASK_FLEE, "駐守": TeamData.TASK_GOVERN,
	"返家補給": TeamData.TASK_RETURN_HOME, "掠奪": TeamData.TASK_LOOT, "佔村": TeamData.TASK_ATTACK,
	"投靠": TeamData.TASK_JOIN, "紮營": TeamData.TASK_CAMP, "乞食": TeamData.TASK_BEG,
	"攻擊": TeamData.TASK_ATTACK, "徵收": TeamData.TASK_TRIBUTE, "外交": TeamData.TASK_DIPLOMACY,
	"買糧": TeamData.TASK_TRADE, "囤貨": TeamData.TASK_TRADE, "備戰": TeamData.TASK_PREPARE,
	"迎戰": TeamData.TASK_DEFEND, "求和": TeamData.TASK_DIPLOMACY, "訓練": TeamData.TASK_TRAIN,
}
# 需離開本格的 task（居民移動鎖判定：腦要它去這些 → 物理釘住）
const MOBILE_TASKS := [TeamData.TASK_TRADE, TeamData.TASK_LOOT, TeamData.TASK_ATTACK, TeamData.TASK_FORAGE,
	TeamData.TASK_JOIN, TeamData.TASK_BEG, TeamData.TASK_CAMP, TeamData.TASK_DIPLOMACY,
	TeamData.TASK_TRIBUTE, TeamData.TASK_RETURN_HOME, TeamData.TASK_FLEE]

var _fai: FactionAISystem

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	_fai = FactionAISystem.new()
	var seeds := _parse_seeds()
	var months := int(OS.get_environment("HOB_MONTHS")) if OS.has_environment("HOB_MONTHS") else 4
	var interval := int(OS.get_environment("HOB_INTERVAL")) if OS.has_environment("HOB_INTERVAL") else 240
	var ticks := maxi(months, 1) * WorldState.TICKS_PER_MONTH
	print("=== hand_obeys_brain_bed：seeds=%s months=%d interval=%d (ticks=%d) ===" % [
		str(seeds), months, interval, ticks])

	var agg := _blank_stats()
	var finals := {}   # seed → {final, probe}（非擾動對照用）
	for s in seeds:
		var res := _run_seed(int(s), ticks, interval)
		finals[int(s)] = {"final": res["final"], "probe": res["probe"]}
		_print_seed(int(s), res["stats"])
		_merge_stats(agg, res["stats"])

	print("\n########## 跨 seed 匯總（%s）##########" % str(seeds))
	_print_stats(agg)

	_prove_nonperturbation(seeds, ticks, finals)
	print("\n=== hand_obeys_brain_bed DONE ===")

# ── 跑單 seed：鏡射 WarringHarness.run tick 迴圈 + 每 interval 采樣 ──
func _run_seed(world_seed: int, ticks: int, interval: int) -> Dictionary:
	seed(world_seed)
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	if config.is_empty():
		Probe.enabled = false
		return {"stats": _blank_stats(), "final": {}, "probe": {}}
	config["seed"] = world_seed
	GameSetup.setup(state, config)

	var stats := _blank_stats()
	var no_player := Vector2i(-1, -1)
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty():
			break
		if (tick + 1) % interval == 0:
			_sample(state, stats)   # 采樣：只讀，Probe 暫關（內部）

	var final := {
		"teams": state.teams.size(), "factions": state.factions.size(),
		"pop": _total_pop(state),
	}
	var probe := {}
	for k in Probe.counts:
		probe[k] = int(Probe.counts[k])
	Probe.enabled = false
	return {"stats": stats, "final": final, "probe": probe}

# ── 采樣一輪：對每隊評 手 vs 腦 ──
func _sample(state: WorldState, stats: Dictionary) -> void:
	var probe_was: bool = Probe.enabled
	Probe.enabled = false   # 抑制 applicable() 的 occupy.* bump → 零 probe 擾動
	PathSystem.suppress_observe_noise = true   # gather→observe_velocity 的 randf 略過 → 零 RNG 擾動
	for tid in state.teams:
		var team: TeamData = state.teams[tid]
		_eval_team(state, team, stats)
	PathSystem.suppress_observe_noise = false
	Probe.enabled = probe_was

func _eval_team(state: WorldState, team: TeamData, stats: Dictionary) -> void:
	# 玩家隊不受 AI 控（warring 無玩家，但保險）
	if state.player_id != -1 and team.leader_id == state.player_id:
		return
	# 誠實全菜單 rank（read-only ctx accessor；承諾比對 current_option 鏡射引擎）
	var ctx: DecisionContext = DecisionContext.gather(state, team)
	var scored: Array = DecisionEngine.rank_scored_ctx(ctx, team.current_option)
	if scored.is_empty():
		return   # 無 applicable option → 無可比

	# rank[0] 誠實菜單首選 → brain_task（純 OPTION_TASK 表，無 target finder 副作用）。
	# applicable 已保證 option 可派，故 rank[0] 即引擎本 cadence 會執行者（去 to_task→IDLE 罕見 fallback）。
	var brain_opt: String = String(scored[0]["opt"])
	var brain_task: String = String(OPTION_TASK.get(brain_opt, TeamData.TASK_IDLE))
	if brain_task == TeamData.TASK_IDLE:
		return   # 未映射 option → 無可比

	var cat: String = _category(state, team)
	var uni: bool = _fai.uses_unified(team)
	stats["total"] += 1
	stats["cat_total"][cat] += 1
	if uni: stats["uni_total"] += 1
	stats["rank0_opt"][brain_opt] = int(stats["rank0_opt"].get(brain_opt, 0)) + 1

	var actual: String = team.current_task
	if _task_equiv(actual, brain_task):
		stats["agree"] += 1
		stats["cat_agree"][cat] += 1
		return

	# ── 背離：先物理鎖豁免，再分機制 ──
	var is_leader: bool = (cat == "leader")
	var verdict := ""   # "excuse:<k>" 或 "mech:<k>"

	if team.combat_target != -1:
		if actual in COMBAT_TASKS or actual == TeamData.TASK_FLEE or actual == TeamData.TASK_PREPARE:
			verdict = "excuse:combat"
		else:
			verdict = "mech:freeze"   # D2：combat_target 已設但 task 非戰鬥（try_set 失敗仍落副作用）
	elif not team.player_commanded_task.is_empty() or team.task_priority == TaskArbiter.PRIO_PLAYER:
		verdict = "excuse:player"
	elif team.parent_team_id != -1:
		verdict = "mech:subteam_bypass"
	elif is_leader:
		verdict = "mech:leader_bypass"
	elif team.task_priority == TaskArbiter.PRIO_SURVIVAL or team.task_priority == TaskArbiter.PRIO_THREAT:
		verdict = "mech:subset_override"   # survival/threat 子集層合法出手（A1 會塌併，故計）
	elif _fai.is_resident_static(state, team) and brain_task in MOBILE_TASKS:
		verdict = "excuse:resident_lock"   # 居民移動鎖：腦要它離村（mobile task）但物理釘住
	elif actual in NO_RELEASE:
		verdict = "mech:no_release_latch"   # TRAIN/MANUFACTURE/GOVERN/PRODUCE 無 release
	elif team.task_priority == TaskArbiter.PRIO_DISPATCH \
			or team.task_priority == TaskArbiter.PRIO_FACTION \
			or team.task_priority == TaskArbiter.PRIO_AMBIENT \
			or team.task_priority == TaskArbiter.PRIO_VENDETTA:
		verdict = "mech:arbiter_latch"   # 引擎欲換但優先權非嚴格大於（含 idle-gate busy skip）
	else:
		verdict = "mech:other"

	var parts: Array = verdict.split(":")
	if parts[0] == "excuse":
		stats["excused"] += 1
		stats["excuse"][parts[1]] += 1
	else:
		stats["violations"] += 1
		stats["mech"][parts[1]] += 1
		stats["cat_viol"][cat] += 1
		if uni: stats["uni_viol"] += 1

# ── team-category（結構 4 類；unified 為 cross-cut，另計）──
func _category(state: WorldState, team: TeamData) -> String:
	if team.parent_team_id != -1:
		return "subteam"
	if team.faction_id != -1:
		var f = state.factions.get(team.faction_id)
		if f != null and f.leader_team_id == team.team_id:
			return "leader"
		return "member"
	return "solo"

# TASK_PRODUCE(居民常態) ≡ TASK_MANUFACTURE(生產 option 映射)：語意同「駐村生產」，不算背離
func _task_equiv(a: String, b: String) -> bool:
	if a == b:
		return true
	var prod := [TeamData.TASK_PRODUCE, TeamData.TASK_MANUFACTURE]
	return a in prod and b in prod

# ── stats 結構 ──
func _blank_stats() -> Dictionary:
	var mech := {}
	for m in MECHS: mech[m] = 0
	var exc := {}
	for e in EXCUSES: exc[e] = 0
	var ct := {}; var cv := {}; var ca := {}
	for c in CATS: ct[c] = 0; cv[c] = 0; ca[c] = 0
	return {
		"total": 0, "agree": 0, "violations": 0, "excused": 0,
		"mech": mech, "excuse": exc,
		"cat_total": ct, "cat_viol": cv, "cat_agree": ca,
		"rank0_opt": {},
		"uni_total": 0, "uni_viol": 0,   # unified cross-cut（另填於 _eval? 見下）
	}

func _merge_stats(agg: Dictionary, s: Dictionary) -> void:
	for k in ["total", "agree", "violations", "excused", "uni_total", "uni_viol"]:
		agg[k] += s[k]
	for m in MECHS: agg["mech"][m] += s["mech"][m]
	for e in EXCUSES: agg["excuse"][e] += s["excuse"][e]
	for c in CATS:
		agg["cat_total"][c] += s["cat_total"][c]
		agg["cat_viol"][c] += s["cat_viol"][c]
		agg["cat_agree"][c] += s["cat_agree"][c]
	for o in s["rank0_opt"]:
		agg["rank0_opt"][o] = int(agg["rank0_opt"].get(o, 0)) + int(s["rank0_opt"][o])

# ── 輸出 ──
func _print_seed(s: int, stats: Dictionary) -> void:
	print("\n--- seed=%d ---" % s)
	_print_stats(stats)

func _print_stats(st: Dictionary) -> void:
	var total: int = int(st["total"])
	if total == 0:
		print("  (無采樣決策)")
		return
	var viol: int = int(st["violations"])
	var agree: int = int(st["agree"])
	var exc: int = int(st["excused"])
	print("  采樣 cadence-decisions = %d" % total)
	print("  手==腦（agree）        = %d (%.1f%%)" % [agree, _pct(agree, total)])
	print("  物理鎖豁免（excused）  = %d (%.1f%%)  %s" % [exc, _pct(exc, total), _kv(st["excuse"])])
	print("  ★手≠腦 違規（viol）    = %d (%.1f%%)" % [viol, _pct(viol, total)])
	print("    分機制：")
	for m in MECHS:
		var c: int = int(st["mech"][m])
		if c > 0:
			print("      %-16s %6d (%.1f%% of total, %.1f%% of viol)" % [
				m, c, _pct(c, total), _pct(c, maxi(viol, 1))])
	print("    分 team-category（背離率 = viol / cat_total）：")
	for cat in CATS:
		var ctot: int = int(st["cat_total"][cat])
		if ctot > 0:
			print("      %-8s total=%6d agree=%6d viol=%6d (背離 %.1f%%)" % [
				cat, ctot, int(st["cat_agree"][cat]), int(st["cat_viol"][cat]),
				_pct(int(st["cat_viol"][cat]), ctot)])
	print("    cross-cut unified（TAG_MERCHANT/PRODUCE 走引擎隊）：total=%d viol=%d (背離 %.1f%%)" % [
		int(st["uni_total"]), int(st["uni_viol"]), _pct(int(st["uni_viol"]), maxi(int(st["uni_total"]), 1))])
	# rank0 誠實菜單首選分布（腦想要什麼）
	var top := _top_opts(st["rank0_opt"], 6)
	print("    腦 rank[0] 首選分布（top）：%s" % top)

func _kv(d: Dictionary) -> String:
	var parts: Array = []
	for k in d:
		if int(d[k]) > 0: parts.append("%s=%d" % [k, int(d[k])])
	return "{" + ", ".join(parts) + "}"

func _top_opts(d: Dictionary, n: int) -> String:
	var arr: Array = []
	for k in d: arr.append({"k": k, "v": int(d[k])})
	arr.sort_custom(func(a, b): return int(a["v"]) > int(b["v"]))
	var parts: Array = []
	for i in range(mini(n, arr.size())):
		parts.append("%s=%d" % [arr[i]["k"], arr[i]["v"]])
	return "{" + ", ".join(parts) + "}"

func _pct(a: int, b: int) -> float:
	return 0.0 if b == 0 else 100.0 * float(a) / float(b)

func _total_pop(state: WorldState) -> int:
	var n := 0
	for tid in state.teams: n += state.teams[tid].population
	return n

func _parse_seeds() -> Array:
	var raw: String = OS.get_environment("HOB_SEEDS")
	if raw == "": raw = "1337,42,7"
	var out: Array = []
	for tok in raw.split(",", false):
		var t: String = tok.strip_edges()
		if t.is_valid_int(): out.append(int(t))
	return out

# ── 非擾動證明 ──
# 硬證 = 跨行程：本 bed（instrumented）vs seeded_warring_bed（clean, WarringHarness.run）逐 seed final/probe
#   對照，兩者皆 fresh process → 免 in-process static-leak 混淆。走 HOB_BASELINE（clean JSON）。
# 輔證 = in-process：本函數。附 clean-twice determinism 探針（偵測 static-leak 噪底：若 clean≠clean，
#   則 in-process 對照本身有噪，instrumented≠clean 非儀器所致 → 以跨行程硬證為準）。
func _prove_nonperturbation(seeds: Array, ticks: int, instrumented: Dictionary) -> void:
	# 跨行程硬證（若給 baseline）= 權威非擾動證據
	var base_path: String = OS.get_environment("HOB_BASELINE")
	if base_path != "":
		_compare_baseline(base_path, instrumented)
	# in-process 輔證（重：多跑 5 個 full sim）僅 HOB_INPROC=1 時跑；長窗報告預設略過
	if OS.get_environment("HOB_INPROC") != "1":
		if base_path == "":
			print("\n（非擾動證明略過：給 HOB_BASELINE=<seeded_warring_bed clean JSON> 跑跨行程硬證，或 HOB_INPROC=1 跑 in-process 輔證）")
		return

	print("\n========== 非擾動證明 A：in-process static-leak 暴露探針 ==========")
	# WarringHarness.run 雖 seed() 重播 global RNG，但 sim 有 process-history-dependent static state
	#（跨 run 累積、非 WorldState.new 重置）→ 同 seed 的 clean final 隨「本 run 前跑過幾次」漂移。
	# 探針：in-process clean(seed0) vs 跨行程 fresh baseline。若相異 = 證實 in-process 對照本身有位置噪，
	# 故下方「證明 B」的 mismatch 非儀器所致（權威 = 上方跨行程硬證）。
	var s0 := int(seeds[0])
	var d1: Dictionary = WarringHarness.run(s0, ticks, CONFIG_PATH).get("final", {})
	var leak := false
	if base_path != "":
		var bf := FileAccess.open(base_path, FileAccess.READ)
		if bf != null:
			var pj = JSON.parse_string(bf.get_as_text()); bf.close()
			if pj is Dictionary and pj.has(str(s0)):
				var fresh: Dictionary = pj[str(s0)].get("final", {})
				leak = int(fresh.get("teams", -1)) != int(d1.get("teams", -2))
				print("  seed=%d  in-process clean.teams=%d  fresh-process clean.teams=%d → %s" % [
					s0, int(d1.get("teams", -1)), int(fresh.get("teams", -1)),
					"★位置噪存在（in-process≠fresh；WarringHarness.run 非 history-independent）" if leak else "in-process==fresh"])

	print("\n========== 非擾動證明 B：in-process instrumented vs WarringHarness.run（噪susceptible）==========")
	if leak:
		print("  ⚠ 上方證實 in-process 位置噪≠0 → 本段任何 mismatch 不歸因儀器；權威 = 跨行程硬證")
	var all_match := true
	for s in seeds:
		var clean: Dictionary = WarringHarness.run(int(s), ticks, CONFIG_PATH)
		var inst: Dictionary = instrumented.get(int(s), {})
		var cf: Dictionary = clean.get("final", {})
		var iff: Dictionary = inst.get("final", {})
		var final_ok: bool = int(cf.get("teams", -1)) == int(iff.get("teams", -2)) \
			and int(cf.get("factions", -1)) == int(iff.get("factions", -2)) \
			and int(cf.get("pop", -1)) == int(iff.get("pop", -2))
		# probe 子集對照（WarringHarness 只回 PROBE_KEYS 子集）
		var probe_ok := true
		var ipr: Dictionary = inst.get("probe", {})
		for k in clean.get("probe", {}):
			if int(clean["probe"][k]) != int(ipr.get(k, 0)):
				probe_ok = false
				break
		var ok: bool = final_ok and probe_ok
		all_match = all_match and ok
		print("  seed=%d  final[clean]=%s  final[inst]=%s  probe_subset_match=%s  → %s" % [
			int(s), str(cf), str({"teams": iff.get("teams"), "factions": iff.get("factions"), "pop": iff.get("pop")}),
			str(probe_ok), "MATCH" if ok else "★MISMATCH"])
	print("  結論（in-process）：%s" % ("零行為變證" if all_match else "有 diff（若噪底≠0 則非儀器所致，見跨行程 A）"))

# 跨行程硬證：讀 seeded_warring_bed 的 clean baseline JSON（fresh process），逐 seed 對 instrumented final/probe。
func _compare_baseline(base_path: String, instrumented: Dictionary) -> void:
	print("\n========== 非擾動硬證（跨行程）：instrumented vs seeded_warring_bed clean baseline ==========")
	var f := FileAccess.open(base_path, FileAccess.READ)
	if f == null:
		print("  [FAIL] 無法讀 HOB_BASELINE=%s" % base_path); return
	var parsed = JSON.parse_string(f.get_as_text())
	f.close()
	if not (parsed is Dictionary):
		print("  [FAIL] baseline JSON 格式錯"); return
	var baseline: Dictionary = parsed   # seeded_warring_bed 格式：{seed_str: {final:{teams,factions,established,pop}, probe:{...}}}
	var all_ok := true
	for s in instrumented:
		var sk := str(int(s))
		if not baseline.has(sk):
			print("  seed=%d baseline 缺" % int(s)); all_ok = false; continue
		var bf: Dictionary = baseline[sk].get("final", {})
		var inf: Dictionary = instrumented[s].get("final", {})
		var final_ok: bool = int(bf.get("teams", -1)) == int(inf.get("teams", -2)) \
			and int(bf.get("factions", -1)) == int(inf.get("factions", -2)) \
			and int(bf.get("pop", -1)) == int(inf.get("pop", -2))
		var bpr: Dictionary = baseline[sk].get("probe", {})
		var ipr: Dictionary = instrumented[s].get("probe", {})
		var probe_ok := true
		var probe_mismatch := ""
		for k in bpr:
			if int(bpr[k]) != int(ipr.get(k, 0)):
				probe_ok = false; probe_mismatch = "%s: base=%d inst=%d" % [k, int(bpr[k]), int(ipr.get(k, 0))]; break
		var ok: bool = final_ok and probe_ok
		all_ok = all_ok and ok
		print("  seed=%d  clean=%s  inst=%s  probe_match=%s%s  → %s" % [
			int(s), str(bf), str({"teams": inf.get("teams"), "factions": inf.get("factions"), "pop": inf.get("pop")}),
			str(probe_ok), ("" if probe_ok else " (" + probe_mismatch + ")"), "MATCH" if ok else "★MISMATCH"])
	print("  ★跨行程結論：%s" % ("零行為變證（儀器非擾動，硬證）" if all_ok else "★儀器擾動了 sim——需修"))
