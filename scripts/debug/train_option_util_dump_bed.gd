extends SceneTree
# train_option_util_dump_bed：TASK_TRAIN為什麼贏不了(systems票，blueprint裁優先序)。
# ★第一件事不是量util，是拆「不被選」的兩個原因：
#   (a)applicable=false(閘擋掉)——讀production既有tap decision.opt_applicable.訓練
#      (decision_engine.gd:251，每次真決策、ctx.need_urgency齊備時才fire)
#   (b)offer了但util輸——同上，比對 decision.opt_chosen.訓練
# ★①的母體用production真決策產生的Probe聚合(非我自己重算)，忠於真決策節奏。
# ★②(若applicable佔比夠高才做)：組成逐項dump——用gather(state,team,false)【純讀】
#   (belief_system.gd已知坑：gather有副作用，advance=true才會動EWMA，本床固定false，
#   純觀測快照，非等同真決策當下ctx，卷面會標明這個差異)，直接呼叫production函式
#   DecisionOptions.REGISTRY["訓練"]["applicable"] + DecisionTerms.weight/eval +
#   DecisionEngine.rank_scored_ctx——不手抄任何公式。
# 用法：BED_CONFIG BED_DAYS(default 30) BED_SEED(default 1337)

const SAMPLE_CAP: int = 30

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 30
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	print("=== train_option_util_dump_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	var samples: Array = []   # bounded, ②組成逐項
	var applicable_snapshot_days: int = 0
	var total_snapshot_days: int = 0

	var applicable_fn: Callable = (DecisionOptions.REGISTRY["訓練"] as Dictionary)["applicable"]
	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		# ②組成dump降頻：每7天一次(非每天)+便宜前置濾(has_trainable proxy)才呼叫較重的gather，
		#   避免對全隊每天做一次完整gather+rank_scored_ctx(太貴，2天測試就撞180s)。
		#   ①的母體不靠這個迴圈——production決策cadence自己的Probe tap已經免費覆蓋。
		if tick % (1440 * 7) == 0 and samples.size() < SAMPLE_CAP:
			for tid in state.teams:
				var team: TeamData = state.teams[tid]
				if team.anon_cohorts.is_empty(): continue   # 便宜前置濾：has_trainable的必要條件
				var ctx: DecisionContext = DecisionContext.gather(state, team, false)
				total_snapshot_days += 1
				if not applicable_fn.call(ctx):
					continue
				applicable_snapshot_days += 1
				if samples.size() >= SAMPLE_CAP: continue
				# 組成逐項(TRAIN只有一項term：train_drive×train)——直呼production函式,不手抄公式
				var term_val: float = DecisionTerms.eval("train_drive", ctx, "訓練")
				var weight_val: float = DecisionTerms.weight("train", ctx.leader_values)
				var raw_contribution: float = term_val * weight_val
				# 當輪贏家(用同一份純讀ctx呼production rank_scored_ctx，不手抄排序邏輯)
				var scored: Array = DecisionEngine.rank_scored_ctx(ctx, team.current_option, state, team)
				var train_u: float = -1.0
				var winner_opt: String = ""
				var winner_u: float = -1.0
				for e in scored:
					if String(e["opt"]) == "訓練": train_u = float(e["u"])
				if not scored.is_empty():
					winner_opt = String(scored[0]["opt"])
					winner_u = float(scored[0]["u"])
				samples.append({
					"tick": tick, "team": team.team_id,
					"train_term_train_drive": term_val, "train_weight": weight_val,
					"train_raw_contribution": raw_contribution,
					"train_final_u(含coeff/boost/persist)": train_u,
					"winner_opt": winner_opt, "winner_u": winner_u,
					"gap(winner_u - train_u)": (winner_u - train_u) if train_u > -1.0 else null,
				})

	print("\n=== 結果(窗=%.2f天/%d ticks) ===" % [float(ticks) / float(WorldState.TICKS_PER_DAY), ticks])

	# ①母體先報：真決策(非快照)的applicable/chosen——用production既有tap
	var apply_calls: int = int(Probe.counts.get("decision.opt_applicable.訓練", 0))
	var chosen_calls: int = int(Probe.counts.get("decision.opt_chosen.訓練", 0))
	var total_decisions: int = 0
	for k in Probe.counts:
		if String(k).begins_with("decision.opt_chosen."):
			total_decisions += int(Probe.counts[k])
	print("①(a)真決策母體(production tap，非快照)：")
	print("  TRAIN出現在candidate陣列的決策輪次=%d / 有決策的總輪次=%d(%.2f%%)" % [
		apply_calls, total_decisions, (100.0 * float(apply_calls) / float(total_decisions)) if total_decisions > 0 else 0.0])
	print("  TRAIN被選中(贏)的輪次=%d / applicable輪次=%d(%s)" % [
		chosen_calls, apply_calls,
		("%.2f%%" % (100.0 * float(chosen_calls) / float(apply_calls))) if apply_calls > 0 else "★applicable母體=0，勝率不可判"])

	if apply_calls == 0:
		print("\n★★★applicable母體=0——TRAIN根本沒被offer過(問題在【閘】：ctx.has_trainable/archetype==FORCE/ambient_train_drive>0這三個條件本窗全程沒有同時成立過)。")
		print("★照票面規則：母體不足，這裡停手，不硬跑②的util組成dump（沒有applicable實例可dump）。")
	else:
		print("\n②組成逐項dump（★純讀快照，gather(advance=false)——非真決策當下ctx，僅供診斷參考，樣本數=%d，cap=%d）：" % [samples.size(), SAMPLE_CAP])
		print("  快照母體：%d次全隊×天快照中，%d次TRAIN applicable(%.2f%%)" % [
			total_snapshot_days, applicable_snapshot_days, 100.0 * float(applicable_snapshot_days) / float(total_snapshot_days) if total_snapshot_days > 0 else 0.0])
		for s in samples:
			print("  %s" % str(s))

		# genuine vs 機械壞 判別提示(照blueprint預註冊的分界，不代為下結論)
		if not samples.is_empty():
			var any_zero_contribution: bool = false
			for s in samples:
				if float(s["train_raw_contribution"]) <= 0.0001: any_zero_contribution = true
			print("\n★判別提示(照抄blueprint預註冊分界，本床不代為下結論)：")
			if any_zero_contribution:
				print("  ★★樣本中出現train_raw_contribution≈0的案例——需人工檢查是term(ambient_train_drive)恆0還是weight(戰意)恆0，")
				print("    若某一項【機械性】恆0/沒接線 ⇒ 落blueprint『機械壞』那個結局；若每項都是合理小值只是打不過贏家 ⇒ 落『genuine』結局。")
			else:
				print("  ★所有樣本train_raw_contribution>0——初步看不像【恆0/沒接線】那種機械壞，但仍需人工核對gap欄位是否『合理輸』。")

	print("=== train_option_util_dump_bed DONE ===")
