extends SceneTree
# gen4_checkup_registry_ledger_bed：世代4 30日全面體檢——③佃農有沒有家(登記錨)
#   ④帳能不能對上(不變量+coin) + 故事稽核(specimen全隊dump)
# ★①戰爭打不打得起來/②信使送達 由現成acceptance床(herald_journey_bed.gd)覆蓋，本床不重複。
# ★市場窗由economic_window_4cell_bed.gd覆蓋，本床不重複。
# ③用新登記API(登記錨④a，非舊is_resident_static站位判定)：
#   work_outpost != Vector2i(-1,-1) ＝ 已登記；is_registered_resident(team) ＝ 讀者判定
# ④InvariantAudit.check(state)開場+收場各驗一次(應為空)；CoinAudit.total前後對帳(觀察量,非恆等式)
# ★世代紀律：只引世代4讀數(跑在c6c9704ac之後)——本床跑的就是這個commit之後的世界
# 用法：BED_CONFIG(default warring_states.json) BED_DAYS(default 30) BED_SEED(default 1337) BED_SPECIMEN(default 1)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	var specimen_on: bool = (OS.get_environment("BED_SPECIMEN") if OS.has_environment("BED_SPECIMEN") else "1") == "1"
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	print("=== gen4_checkup_registry_ledger_bed(世代4)：config=%s days=%d seed=%d ===" % [cfg, days, seed_val])
	print("★測於commit=%s（c6c9704ac之後，世代4）" % _short_head())

	# ④開場守恆檢查
	var violations0: Array = InvariantAudit.check(state)
	var coin0: float = CoinAudit.total(state)
	print("\n④開場不變量檢查：%s" % ("PASS(空)" if violations0.is_empty() else "★FAIL: " + str(violations0)))
	print("④開場CoinAudit.total=%.2f" % coin0)

	if specimen_on:
		var all_ids: Array[int] = []
		for tid in state.teams: all_ids.append(int(tid))
		state.specimen_team_ids = all_ids
		SpecimenTracer.reset()
		SpecimenTracer.enabled = true
		print("[specimen] 全隊取樣team_ids=%d支" % all_ids.size())

	var snapshot_days: Array = [1, 10, 20, 30]
	var si: int = 0
	var snapshot_ticks: Array = []
	for d in snapshot_days: snapshot_ticks.append(d * WorldState.TICKS_PER_DAY)

	for tick in range(ticks + 1):
		if si < snapshot_ticks.size() and tick == snapshot_ticks[si]:
			_snapshot_registry(state, int(snapshot_days[si]), tick)
			si += 1
		if tick < ticks:
			runner.advance_tick(state, no_player)

	# ④收場守恆檢查
	var violations1: Array = InvariantAudit.check(state)
	var coin1: float = CoinAudit.total(state)
	print("\n④收場(day%d)不變量檢查：%s" % [days, "PASS(空)" if violations1.is_empty() else "★FAIL: " + str(violations1)])
	print("④收場CoinAudit.total=%.2f　變化=%.2f(★觀察量非恆等式——30天內合法生產/消費/轉移會改變它，" % [coin1, coin1 - coin0])
	print("  非本卷推導完整coin flow公式，只記錄變化幅度供跨卷比較)")

	if specimen_on:
		var specimen_path: String = "docs/measurements/2026-09-12-gen4-checkup.specimen.jsonl"
		SpecimenTracer.flush()
		SpecimenTracer.write_jsonl(specimen_path)
		print("\n=== 故事稽核specimen落地：%s ===" % specimen_path)
		print("全隊取樣，供QA逐條讀jsonl判motive→action→outcome，本床只負責produce，不代為判讀因果")

	print("\n★fp=%s" % StateFingerprint.compute(state))
	print("=== gen4_checkup_registry_ledger_bed DONE ===")

func _short_head() -> String:
	return "見卷面header的[TREE]行(godot.ps1自動印，本床不重複讀git)"

func _snapshot_registry(state: WorldState, day: int, tick: int) -> void:
	var total: int = state.teams.size()
	var registered: int = 0
	var resident_reader: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.work_outpost != Vector2i(-1, -1): registered += 1
		if state.is_registered_resident(t): resident_reader += 1
	print("\n--- [SNAPSHOT day=%d tick=%d] ③登記錨(佃農有沒有家) ---" % [day, tick])
	print("  總隊數=%d　已登記(work_outpost!=(-1,-1))=%d(%.1f%%)　is_registered_resident讀者判定=%d(%.1f%%)" % [
		total, registered, 100.0 * float(registered) / float(total),
		resident_reader, 100.0 * float(resident_reader) / float(total)])
	print("  ★累計auto_register_stub觸發=%d(★④b上線後應趨於0)　登記了但人不在=%d" % [
		int(Probe.counts.get("registry.auto_register_stub", 0)),
		int(Probe.counts.get("registry.resident.away", 0))])
