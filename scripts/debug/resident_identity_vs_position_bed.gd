extends SceneTree
# resident_identity_vs_position_bed：把「身分」與「位置」分開數(systems修正票)。
# ★上一卷(lord-belief-coverage)量到配對母體恆0-1,但is_resident_static同時要求
#   【身分TAG_PRODUCE】＋【此刻站在自家/同勢力outpost上】——分不出是(a)村莊沒出生
#   還是(b)居民不在家。本床同一輪快照分開列四個數：
#   ①TAG_PRODUCE隊數(身分) ②其中此刻在自家outpost上的隊數(=is_resident_static)
#   ③=①-②(有身分但不在家) ④累計settle/convert_resident授予次數+uprising_exile移除次數
# ★④是累計量，用driver_ledger(interaction_system.gd:1651/1678/faction_ai_system.gd:7038
#   的add_tag/remove_tag reason)——★先把cap調大避免60天窗撞環形緩衝溢出(known_issues
#   血證：cap=4096會讓「0筆」變成「被丟掉」不是「沒發生」)，結束時仍檢查dropped計數誠實報。
# ★沿用上一卷的窗(60天/5次快照day10/20/30/45/60)以便可比。
# 用法：BED_CONFIG BED_SEED(default 1337)

const SNAPSHOT_DAYS: Array = [10, 20, 30, 45, 60]

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	# ★調大driver_ledger cap避免60天窗環形緩衝溢出(known_issues血證)
	WorldState.driver_ledger_enabled = true
	WorldState.driver_ledger_cap = 500000

	var snapshot_ticks: Array = []
	for d in SNAPSHOT_DAYS: snapshot_ticks.append(int(d) * WorldState.TICKS_PER_DAY)
	var max_tick: int = snapshot_ticks[snapshot_ticks.size() - 1]

	print("=== resident_identity_vs_position_bed: config=%s seed=%d snapshot_days=%s ===" % [cfg, seed_val, str(SNAPSHOT_DAYS)])

	var si: int = 0
	for tick in range(max_tick + 1):
		if si < snapshot_ticks.size() and tick == snapshot_ticks[si]:
			_snapshot(state, int(SNAPSHOT_DAYS[si]), tick)
			si += 1
		runner.advance_tick(state, no_player)
		if tick % 10000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d teams=%d driver_ledger.size=%d dropped累計=%d" % [
				tick, state.teams.size(), WorldState.driver_ledger.size(), WorldState.driver_ledger_dropped])

	# ④累計量：settle/convert_resident授予 + uprising_exile移除——掃driver_ledger
	print("\n=== ④累計授予/移除次數(窗=%d天，掃driver_ledger) ===" % SNAPSHOT_DAYS[SNAPSHOT_DAYS.size() - 1])
	print("★driver_ledger現存筆數=%d　★★累計被丟棄筆數=%d(%s)" % [
		WorldState.driver_ledger.size(), WorldState.driver_ledger_dropped,
		"0=沒溢出，以下計數可信" if WorldState.driver_ledger_dropped == 0 else "★★★有溢出!以下計數是【下限】非真值，因為cap即使調大也可能不夠"])
	var settle_count: int = 0
	var convert_count: int = 0
	var exile_count: int = 0
	for entry in WorldState.driver_ledger:
		if String(entry.get("field", "")) != "tags": continue
		var reason: String = String(entry.get("reason", ""))
		if reason == "settle" and float(entry.get("delta", 0.0)) > 0.0: settle_count += 1
		elif reason == "convert_resident" and float(entry.get("delta", 0.0)) > 0.0: convert_count += 1
		elif reason == "uprising_exile" and float(entry.get("delta", 0.0)) < 0.0: exile_count += 1
	print("  settle授予次數=%d　convert_resident授予次數=%d　uprising_exile移除次數=%d" % [settle_count, convert_count, exile_count])
	if settle_count == 0 and convert_count == 0:
		print("  ★★★連『變成居民』這件事都幾乎沒發生過⇒答案推向【村莊沒出生】，且更硬")

	print("\n=== resident_identity_vs_position_bed DONE ===")

func _snapshot(state: WorldState, day: int, tick: int) -> void:
	var produce_teams: Array = []
	var resident_teams: Array = []
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.tags.has(TeamData.TAG_PRODUCE):
			produce_teams.append(t.team_id)
			if FactionAISystem.is_resident_static(state, t):
				resident_teams.append(t.team_id)

	print("\n--- [SNAPSHOT day=%d tick=%d] ---" % [day, tick])
	print("①有TAG_PRODUCE的隊數(身分)=%d" % produce_teams.size())
	print("②其中此刻站在自家/同勢力outpost上的隊數(is_resident_static)=%d" % resident_teams.size())
	print("③=①-②【有身分但不在家】的隊數=%d" % (produce_teams.size() - resident_teams.size()))
	if produce_teams.is_empty():
		print("  ★①本身=0⇒本次快照無法區分(a)/(b)，兩者在這一刻都成立(沒有身分自然也沒有位置)")
	elif produce_teams.size() == resident_teams.size():
		print("  ★③=0⇒這一刻所有有身分的隊都在家，沒有『居民不在家』的情況")
	else:
		print("  不在家的隊id：%s" % str(_diff(produce_teams, resident_teams)))

func _diff(a: Array, b: Array) -> Array:
	var out: Array = []
	for x in a:
		if not b.has(x): out.append(x)
	return out
