extends SceneTree
# ★施工漏斗 ①②段的【非零證據 + 對帳】床（systems 派 2026-08-26）。
#   ★判準三條（他寫死的）：①每段都要有分母 ②`fp` 不變 ③每顆 counter 至少非零過一次，
#     ★恆 0 的要講明是【掛錯位置】還是【那條路不可達】——本床把兩者分開印，不替它選。
#   ★★對帳式：`四個分支相加 == delegate.entry`（★分支計數自帶稽核，不必人眼相信）。
# env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / PERF_OUT

const STAGE1: Array = ["funnel.cand.emitted", "funnel.decide.total",
	"funnel.decide.winner_cand", "funnel.decide.winner_static"]
const RANK_BUCKETS: Array = ["funnel.cand.best_rank.0_won", "funnel.cand.best_rank.1_2",
	"funnel.cand.best_rank.3_5", "funnel.cand.best_rank.6plus"]
const BRANCHES: Array = ["funnel.delegate.branch_convoy", "funnel.delegate.branch_build",
	"funnel.delegate.branch_facility", "funnel.delegate.branch_generic"]
const GATES: Array = ["funnel.build_gate.busy_subteam", "funnel.build_gate.tile_occupied",
	"funnel.build_gate.cost", "funnel.build_gate.no_advisor", "funnel.build_gate.pop",
	"funnel.build_gate.food_bridge", "funnel.build_gate.subteam_dispatch",
	"funnel.build_gate.dispatched"]
const STAGE2_OUTCOME: Array = ["delegate.build_ok", "delegate.build_fail",
	"funnel.delegate.facility_ok", "funnel.delegate.facility_fail",
	"funnel.delegate.generic_ok", "funnel.delegate.generic_fail",
	"funnel.delegate.generic_drop_no_advisor"]

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "30"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	var out_path: String = _env("PERF_OUT", "")
	print("=== 施工漏斗 ①② 非零證據：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	var lines: Array = []
	lines.append("[%s day %d seed %d] teams=%d" % [cfg, days, sd, state.teams.size()])
	lines.append("--- ①段 candidate → winner（★每格都有分母）---")
	for k in STAGE1:
		lines.append("  %-34s = %d" % [String(k), _c(String(k))])
	var _tot: int = _c("funnel.decide.total")
	var _wc: int = _c("funnel.decide.winner_cand")
	if _tot > 0:
		lines.append("  ⇒ candidate 贏得 argmax 的比例 = %.1f%%（%d / %d）" % [100.0 * _wc / _tot, _wc, _tot])
	lines.append("  ★贏不了時排第幾（bucket）：")
	var _rank_sum: int = 0
	for k2 in RANK_BUCKETS:
		var v: int = _c(String(k2))
		_rank_sum += v
		lines.append("      %-38s = %d" % [String(k2), v])
	lines.append("      （四桶合計 = %d ＝ 有 candidate 參與的決策次數）" % _rank_sum)
	for k3 in Probe.counts.keys():
		if String(k3).begins_with("funnel.cand.by_goal."):
			lines.append("      %-38s = %d" % [String(k3), int(Probe.counts[k3])])
	lines.append("--- ②段 delegate 路由（★對帳：四分支相加 == entry）---")
	var entry: int = _c("delegate.entry")
	var bsum: int = 0
	for k4 in BRANCHES:
		var v4: int = _c(String(k4))
		bsum += v4
		lines.append("  %-34s = %d" % [String(k4), v4])
	lines.append("  %-34s = %d" % ["delegate.entry（分母）", entry])
	lines.append("  ⇒ ★對帳：四分支合計 %d vs entry %d ⇒ %s" % [bsum, entry,
		"✅一致" if bsum == entry else "❌不一致（有分支沒被計到，或有 early-return 在分支之前）"])
	lines.append("  各分支結果：")
	for k5 in STAGE2_OUTCOME:
		lines.append("      %-38s = %d" % [String(k5), _c(String(k5))])
	# ★★非零證據判讀（★恆 0 的兩種可能【不替它選】）
	lines.append("--- ★非零證據（判準③）---")
	var zeros: Array = []
	for k6 in (STAGE1 + RANK_BUCKETS + BRANCHES + STAGE2_OUTCOME + GATES):
		if _c(String(k6)) == 0:
			zeros.append(String(k6))
	if zeros.is_empty():
		lines.append("  ★全部 counter 皆非零 ⇒ 每一顆都至少被走到一次")
	else:
		lines.append("  ★以下 counter 在本輪為 0（%d 顆）——★兩種可能，這裡不替它選：" % zeros.size())
		for z in zeros:
			lines.append("      %s" % String(z))
		lines.append("  (a) 掛錯位置（那段 code 有跑但 counter 沒接到）")
		lines.append("  (b) 那條路在這張床上不可達（例：無 convoy 需求／無 facility 委派）")
		lines.append("  ★分辨法：看它【同段的分母】—— 分母非零而它為 0 ⇒ 偏向 (b)；分母也是 0 ⇒ 先查 (a)")
	# ★③④段：dispatch 前掉在【哪一道閘】——★七道閘 ＋ 成功端，相加必須 == attempt。
	#   ★★這一段的價值不是「失敗幾次」（那本來就有），是【失敗在哪裡】：
	#     「已經有子隊在蓋」與「資源不夠」在外面長得一樣（都是 return false），處置卻完全相反。
	lines.append("--- ③④段 build dispatch 的七道閘（★對帳：七閘＋成功 == attempt）---")
	var att: int = _c("dispatch_builder.attempt")
	var gsum: int = 0
	for kg in GATES:
		var vg: int = _c(String(kg))
		gsum += vg
		lines.append("  %-40s = %d" % [String(kg), vg])
	for kg2 in Probe.counts.keys():
		if String(kg2).begins_with("funnel.build_gate.cost."):
			lines.append("      %-36s = %d" % [String(kg2), int(Probe.counts[kg2])])
	lines.append("  %-40s = %d" % ["dispatch_builder.attempt（分母）", att])
	lines.append("  ⇒ ★對帳：七閘＋成功 %d vs attempt %d ⇒ %s" % [gsum, att,
		"✅一致" if gsum == att else "❌不一致（有 return 路徑沒被計到）"])
	# ★★★死水兩欄的最小形式（systems 2026-08-26）：為了回答問題而加的欄位，
	#   要證明它【問得出】那個問題——不是「加了欄位但永遠只有一筆」。
	lines.append("--- ★`tick`/`team` 欄位的實例證明（同 tick 同 team 多 candidate）---")
	var ids: Array = Probe.samples.get("funnel.cand.identity", []) as Array
	var by_key: Dictionary = {}
	for smp in ids:
		var kk: String = "%d|%d" % [int(smp.get("tick", -1)), int(smp.get("team", -1))]
		if not by_key.has(kk): by_key[kk] = []
		(by_key[kk] as Array).append(smp)
	var multi: int = 0
	var example: Array = []
	for k7 in by_key:
		if (by_key[k7] as Array).size() > 1:
			multi += 1
			if example.is_empty(): example = by_key[k7] as Array
	lines.append("  樣本 %d 筆 → (tick,team) 組合 %d 個，其中【同組多 candidate】= %d 組" % [ids.size(), by_key.size(), multi])
	if example.is_empty():
		lines.append("  ★★零實例 ⇒ 這兩欄在本輪【回答不了它們被加進來要回答的問題】（照原樣報，不美化）")
	else:
		lines.append("  ★實例（原始樣本，未加工）：")
		for e in example:
			lines.append("      %s" % str(e))
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== 施工漏斗 ①② DONE ===")

func _c(k: String) -> int:
	return int(Probe.counts.get(k, 0))

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
