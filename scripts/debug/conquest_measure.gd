extends SceneTree

# 征服名vs實 measure（measure-first，spec 2026-07-01-conquest-name-vs-deed）。
# 純觀測：warring seed（好戰隊多）跑 → 量「想=征服」的獨立隊在 _decide_unified 實際 winner
# 分布（掠奪 vs prosperity vs other）+ 掠奪達 conquest(capture) 率 + util 排序根。
# 不驅動 player、不改 state。修按數據另 spec，不在本 harness。

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	print("=== 征服名vs實 measure（掠奪 vs prosperity-attack）===")
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty():
		print("[FAIL] config 載入失敗"); Probe.enabled = false; return
	GameSetup.setup(state, config)
	# 好戰放大：把獨立隊 leader 好戰/野心拉高（warring seed 已多好戰，此處確保征服 intent 有量）。
	# 純測試佈局（authored premise，不改世界模型）。
	var _boosted: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if t.faction_id != -1 or t.parent_team_id != -1: continue
		var lp: PersonData = state.persons.get(t.leader_id)
		if lp == null: continue
		lp.values["好戰"] = maxf(float(lp.values.get("好戰", 0.5)), 0.75)
		lp.values["野心"] = maxf(float(lp.values.get("野心", 0.5)), 0.7)
		_boosted += 1
	# measure cap：夠獨立隊爬野心階 + belief 鋪開觸 prosperity，不需跑滿 2 年（可 override）。
	var max_ticks: int = mini(int(config.get("max_ticks", 172800)), 240 * 60)
	print("[measure] max_ticks=%d teams=%d factions=%d 好戰獨立 boost=%d" % [
		max_ticks, state.teams.size(), state.factions.size(), _boosted])

	var no_player := Vector2i(-1, -1)
	for tick in range(max_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if (tick + 1) % (240 * 30) == 0:
			print("[measure] 月%d tick=%d teams=%d conq.intent=%d winner_loot=%d prosp_reached=%d" % [
				(tick + 1) / (240 * 30), tick + 1, state.teams.size(),
				int(Probe.counts.get("conq.intent", 0)),
				int(Probe.counts.get("conq.winner_loot", 0)),
				int(Probe.counts.get("conq.prosperity_reached", 0))])
		if state.teams.is_empty():
			print("[measure] 全滅 @ tick=%d" % (tick + 1)); break

	print("\n[measure] === 征服名實斷點量化 ===")
	# 名（想）：conq.intent 是 _decide_unified 見到 solo_intent=征服 的次數
	# 實（做）：winner_* 分布。掠奪搶排序 → winner_loot 佔多數 = 名實斷點。
	var keys := ["conq.declared", "conq.declared_unified", "conq.declared_nonunified",
		"conq.intent", "conq.winner_loot", "conq.winner_prosperity",
		"conq.winner_other", "conq.winner_none", "conq.prosperity_reached",
		"capture.total", "loot.achieved_capture", "capture.by_attack", "capture.by_other"]
	for k in keys:
		print("[measure] %-26s = %d" % [k, int(Probe.counts.get(k, 0))])
	print("[measure] %-26s peak= %.3f" % ["conq.loot_util", float(Probe.peaks.get("conq.loot_util", 0.0))])
	print("[measure] %-26s peak= %.3f" % ["conq.loot_lead", float(Probe.peaks.get("conq.loot_lead", 0.0))])
	Probe.summary()
	Probe.enabled = false
	print("=== 征服名vs實 measure DONE ===")
