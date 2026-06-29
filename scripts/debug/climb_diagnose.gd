extends SceneTree

# (a) 核心 measure：攀爬動力卡點（藍圖 2026-06-29「instrument 能人一生，找爬到哪階卡，別猜」）。
# 攀爬鏈 rung：SURVIVE0→ACCUMULATE1→EXPAND2→STATE3(立國)→HEGEMON4(稱霸)。
# 量：戰國 seed 起手「能人」(leader 野心≥0.6+統領≥0.4)的 1yr 軌跡——rung/pop/material/coin/established/存亡。
# 找卡點：累積(pop/material 漲不漲)/rung 轉換(rung 升不升)/途中死/founder 不了。純量測。

func _initialize() -> void:
	_run(); quit()

func _is_capable(state: WorldState, team: TeamData) -> bool:
	var lp: PersonData = state.persons.get(team.leader_id)
	if lp == null: return false
	return float(lp.values.get("野心", 0.0)) >= 0.6 and float(lp.skills.get("統領", 0.0)) >= 0.4

func _snap(state: WorldState, tid: int) -> Dictionary:
	var t: TeamData = state.teams.get(tid)
	if t == null: return {"alive": false}
	return {
		"alive": true, "rung": t.ambition_rung, "arch": t.ambition_archetype,
		"pop": t.population, "mat": int(t.resources.get("material", 0)),
		"coin": int(t.resources.get("coin", 0)), "fid": t.faction_id,
		"est": state.factions.has(t.faction_id) and state.factions[t.faction_id].is_established,
	}

func _run() -> void:
	print("=== climb diagnose: 能人攀爬卡點 (a) ===")
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty(): print("[FAIL] config"); return
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)

	# 起手能人（leader 野心≥0.6+統領≥0.4）
	var capable: Array = []
	for tid in state.teams:
		if _is_capable(state, state.teams[tid]):
			capable.append(tid)
	print("[climb] 起手能人隊 = %d / %d teams" % [capable.size(), state.teams.size()])
	var max_rung: Dictionary = {}   # tid → 史上最高 rung
	var t0: Dictionary = {}
	for tid in capable:
		t0[tid] = _snap(state, tid)
		max_rung[tid] = int(t0[tid].get("rung", 0))
		print("  能人 T%d: rung=%d arch=%s pop=%d mat=%d coin=%d" % [
			tid, t0[tid]["rung"], t0[tid]["arch"], t0[tid]["pop"], t0[tid]["mat"], t0[tid]["coin"]])

	# 跑 12 月，月取樣能人軌跡
	for month in range(12):
		for _t in range(240 * 30):
			runner.advance_tick(state, no_player)
			if state.encounter_active and state.encounter_tick > 800:
				runner._encounter_system.resolve_encounter_end(state, "draw")
		var alive_n: int = 0; var est_n: int = 0; var rung_sum: int = 0
		for tid in capable:
			var s: Dictionary = _snap(state, tid)
			if s["alive"]:
				alive_n += 1; rung_sum += int(s["rung"])
				max_rung[tid] = maxi(max_rung[tid], int(s["rung"]))
				if s["est"]: est_n += 1
		print("[climb] 月%d: 能人存活=%d/%d established=%d 平均rung=%.1f" % [
			month + 1, alive_n, capable.size(), est_n,
			float(rung_sum) / maxf(alive_n, 1)])

	# 收尾：每能人最高 rung + 結局 + 卡點分布
	print("\n[climb] === 能人結局（最高 rung + 存亡）===")
	var rung_hist: Dictionary = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0}
	var died: int = 0
	for tid in capable:
		var s: Dictionary = _snap(state, tid)
		var mr: int = max_rung[tid]
		rung_hist[mr] = int(rung_hist.get(mr, 0)) + 1
		if not s["alive"]: died += 1
		var t0s: Dictionary = t0[tid]
		print("  T%d: 最高rung=%d 結局=%s | t0 pop=%d→%s mat=%d→%s" % [
			tid, mr, ("活" if s["alive"] else "死/併"),
			t0s["pop"], (str(s["pop"]) if s["alive"] else "-"),
			t0s["mat"], (str(s["mat"]) if s["alive"] else "-")])
	print("\n[climb] 能人最高 rung 分布（卡點）：rung0=%d rung1=%d rung2=%d rung3立國=%d rung4稱霸=%d；途中死/併=%d" % [
		rung_hist[0], rung_hist[1], rung_hist[2], rung_hist[3], rung_hist[4], died])
	print("=== climb diagnose DONE ===")
