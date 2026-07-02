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

	# attack→combat 漏斗 census（harness 內算，零 production 侵入）：
	# 每 tick 掃攻擊姿態隊（task=ATTACK/LOOT），分 pursuing(ct==-1，追擊中) vs frozen(ct!=-1，
	# 設了 combat_target 但還沒開打 = 路徑 B 凍結副作用)，並累計到最近獨立隊的 hex 距離。
	# 平均距離高且不降 = 追不到（路徑 A）；frozen census 高 = 路徑 B 凍死。
	var census_ticks: int = 0
	var sum_pursuing: int = 0
	var sum_pursuing_atk: int = 0
	var sum_pursuing_loot: int = 0
	var sum_frozen: int = 0
	var sum_dist: int = 0
	var dist_n: int = 0
	# FORCE 獨立隊 rung 分布（潛在征服者卡在哪階）+ pop/food_flow 中位觀察
	var rung_hist: Dictionary = {0: 0, 1: 0, 2: 0, 3: 0, 4: 0}
	var force_indep_n: int = 0
	var force_pop_lt8: int = 0
	var force_flow_lt: int = 0
	var no_player := Vector2i(-1, -1)
	for tick in range(max_ticks):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		# 漏斗 census（每 30 tick 抽樣，省時）
		if tick % 30 == 0:
			census_ticks += 1
			var fai := FactionAISystem.new()
			for tid2 in state.teams:
				var t2: TeamData = state.teams[tid2]
				# FORCE 獨立隊 rung 分布（潛在征服者，看卡哪階 + pop/flow 是否達 EXPAND 門檻）
				if t2.faction_id == -1 and t2.parent_team_id == -1 \
						and t2.ambition_archetype == AmbitionLadder.ARCHETYPE_FORCE:
					force_indep_n += 1
					rung_hist[t2.ambition_rung] = int(rung_hist.get(t2.ambition_rung, 0)) + 1
					if t2.population < AmbitionLadder.EXPAND_MIN_POP: force_pop_lt8 += 1
					if t2.food_flow_avg < AmbitionLadder.ACCUMULATE_FLOW_MIN: force_flow_lt += 1
				if t2.current_task != TeamData.TASK_ATTACK and t2.current_task != TeamData.TASK_LOOT:
					continue
				if t2.combat_target != -1:
					sum_frozen += 1
				else:
					sum_pursuing += 1
					if t2.current_task == TeamData.TASK_ATTACK: sum_pursuing_atk += 1
					else: sum_pursuing_loot += 1
					var near_id: int = fai._nearest_independent(state, t2)
					if near_id != -1 and state.teams.has(near_id):
						sum_dist += fai._hex_dist(t2.tile_pos, state.teams[near_id].tile_pos)
						dist_n += 1
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
		# prosperity-attack dispatch gate ladder（93 intent 到底卡哪關才沒派出攻擊）
		"prosp.entered", "prosp.gate_archetype", "prosp.gate_score", "prosp.gate_readiness",
		"prosp.gate_noprey", "prosp.gate_scout_defer", "conq.prosperity_reached",
		"g3.scout_dispatch", "g3.scout_converge", "g3.scout_timeout",
		# attack→combat 接觸漏斗：到達同格(reached) vs 同格被 combat_target 早退擋(blocked_ct_197)
		"atk.reached", "atk.blocked_ct_197",
		# Task0 漏斗：攻擊→戰鬥→決勝/潰逃→吸收/不吸收
		"conq.combat_entered", "conq.combat_decisive", "conq.combat_retreat",
		"conq.win_absorbed", "conq.win_no_absorb",
		"conq.no_absorb_no_anon", "conq.no_absorb_rate_floor",
		"conq.retreat_captured", "conq.retreat_no_capture",
		"capture.total", "loot.achieved_capture", "capture.by_attack", "capture.by_other",
		# R1 驗收哨：絕境仍搏 + ③管住（獨立隊攻 believed-owned 應低）
		"surv.loot_dispatch", "conq.indep_atk_believed_owned"]
	for k in keys:
		print("[measure] %-26s = %d" % [k, int(Probe.counts.get(k, 0))])
	print("[measure] %-26s peak= %.3f" % ["conq.loot_util", float(Probe.peaks.get("conq.loot_util", 0.0))])
	print("[measure] %-26s peak= %.3f" % ["conq.loot_lead", float(Probe.peaks.get("conq.loot_lead", 0.0))])
	# 漏斗 census：追擊 vs 凍結 vs 平均追擊距離（定路徑 A 追不到 vs 路徑 B 凍死）
	print("\n[measure] === attack posture census（每 30 tick 抽樣，%d 樣本）===" % census_ticks)
	print("[measure] avg pursuing/tick = %.2f（追擊中,ct==-1）ATTACK=%.2f LOOT=%.2f" % [
		float(sum_pursuing) / maxf(census_ticks, 1),
		float(sum_pursuing_atk) / maxf(census_ticks, 1),
		float(sum_pursuing_loot) / maxf(census_ticks, 1)])
	print("[measure] avg frozen/tick   = %.2f（設了 combat_target 未開打=路徑B凍結）" % (float(sum_frozen) / maxf(census_ticks, 1)))
	print("[measure] avg 追擊距離        = %.2f hex（高且不降=追不到=路徑A）" % (float(sum_dist) / maxf(dist_n, 1)))
	print("[measure] FORCE獨立隊 rung 分布（樣本累計 %d）：survive=%d accum=%d expand=%d state=%d hegemon=%d" % [
		force_indep_n, int(rung_hist[0]), int(rung_hist[1]), int(rung_hist[2]), int(rung_hist[3]), int(rung_hist[4])])
	print("[measure]   其中 pop<8=%d (%.1f%%)  food_flow<0.5=%d (%.1f%%) ← EXPAND 兩門檻卡點" % [
		force_pop_lt8, 100.0 * force_pop_lt8 / maxf(force_indep_n, 1),
		force_flow_lt, 100.0 * force_flow_lt / maxf(force_indep_n, 1)])
	var intent_n: int = int(Probe.counts.get("conq.intent", 0))
	var reached_n: int = int(Probe.counts.get("atk.reached", 0))
	var combat_n: int = int(Probe.counts.get("conq.combat_entered", 0))
	print("[measure] 漏斗轉化率: intent=%d → reached=%d (%.1f%%) → combat=%d (reached的%.1f%%)" % [
		intent_n, reached_n, 100.0 * reached_n / maxf(intent_n, 1),
		combat_n, 100.0 * combat_n / maxf(reached_n, 1)])
	Probe.summary()
	Probe.enabled = false
	print("=== 征服名vs實 measure DONE ===")
