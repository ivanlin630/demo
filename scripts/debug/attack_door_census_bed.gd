extends SceneTree
# attack_door_census_bed：強強互打——先數門,再談util(systems票)。
# ★第一格不是util分解,是【哪一道門開的】：攻擊option applicable=三道門之一
#   (options.gd:331-334)：①派系directive(faction_attack_target來自
#   _nearest_independent，decision_context.gd:729——近而非弱！唯一可能強強來源)
#   ②征服intent(intent_target來自_find_weakest_prey，永遠最弱)
#   ③血仇(feud_target_id，強度>=FEUD_ATTACK_MIN=0.5)
#   ④全關(三道門都沒開=沒進候選，跟「進了候選但輸掉」是兩個世界)
# 母體「強」＝軍力(armed)排序top5-8，不用population(那是量錯predicate的血證)。
#   armed算法=FactionAISystem._calc_own_armed(named武裝數+匿名×armed_anon_ratio)。
# ★只有真的存在強→強候選才做util分解——母體不足直接回報，不硬撐。
# ★不碰combat層(擊潰/追擊/殲滅率是另一件事)。
# 用法：BED_CONFIG BED_DAYS(default 30) BED_SEED(default 1337)

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
	var fa := FactionAISystem.new()

	print("=== attack_door_census_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	var door_faction: int = 0
	var door_conquest: int = 0
	var door_feud: int = 0
	var door_none: int = 0
	var total_snapshots: int = 0
	var conquest_ranks: Array = []       # ②征服門target在軍力排序裡第幾/共幾
	var faction_ranks: Array = []        # ③派系directive門target的軍力排序
	var faction_directive_targets: Array = []  # 逐次記錄(tick,team,target,target_rank,target_total)供人工核對
	var strong_vs_strong: Array = []     # ④只在真有強→強候選時才填

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % (1440 * 7) != 0: continue   # 每7天一次全隊快照(同train床的降頻理由)

		# 本次snapshot先算全隊armed排序(算一次,全隊共用)
		var armed_by_team: Dictionary = {}
		for tid in state.teams:
			armed_by_team[tid] = fa._calc_own_armed(state, state.teams[tid])
		var sorted_ids: Array = armed_by_team.keys()
		sorted_ids.sort_custom(func(a, b): return armed_by_team[a] > armed_by_team[b])
		var rank_of: Dictionary = {}
		for i in sorted_ids.size(): rank_of[sorted_ids[i]] = i + 1   # 1-indexed，armed高排前面
		var total_teams: int = sorted_ids.size()
		var strong_set: Dictionary = {}   # top5-8視總隊數比例，這裡固定取top8(或總數的15%取大)
		var strong_n: int = maxi(8, int(float(total_teams) * 0.15))
		for i in range(mini(strong_n, sorted_ids.size())): strong_set[sorted_ids[i]] = true

		for tid2 in state.teams:
			var team: TeamData = state.teams[tid2]
			var ctx: DecisionContext = DecisionContext.gather(state, team, false)
			total_snapshots += 1
			var f_open: bool = "攻擊" in ctx.faction_stakes and ctx.faction_attack_target != -1
			var c_open: bool = ctx.intent == "征服" and ctx.intent_target != -1
			var v_open: bool = ctx.strongest_feud >= DecisionOptions.FEUD_ATTACK_MIN and ctx.feud_target_id != -1
			if f_open: door_faction += 1
			if c_open: door_conquest += 1
			if v_open: door_feud += 1
			if not f_open and not c_open and not v_open: door_none += 1

			if c_open and rank_of.has(ctx.intent_target):
				conquest_ranks.append({"rank": rank_of[ctx.intent_target], "total": total_teams})
			if f_open and rank_of.has(ctx.faction_attack_target):
				var tr: int = rank_of[ctx.faction_attack_target]
				faction_ranks.append({"rank": tr, "total": total_teams})
				if faction_directive_targets.size() < 30:
					faction_directive_targets.append({"tick": tick, "team": team.team_id,
						"target": ctx.faction_attack_target, "target_armed_rank": tr, "total_teams": total_teams,
						"attacker_is_strong": strong_set.has(team.team_id), "target_is_strong": strong_set.has(ctx.faction_attack_target)})

			# ④強→強候選：任一道門開且attacker和target都在strong_set裡
			if strong_set.has(team.team_id):
				var target_id: int = -1
				if f_open: target_id = ctx.faction_attack_target
				elif c_open: target_id = ctx.intent_target
				elif v_open: target_id = ctx.feud_target_id
				if target_id != -1 and strong_set.has(target_id) and strong_vs_strong.size() < 30:
					strong_vs_strong.append({"tick": tick, "attacker": team.team_id, "target": target_id,
						"door": ("faction" if f_open else ("conquest" if c_open else "feud"))})

	print("\n=== 結果(窗=%.2f天/%d ticks，快照間隔=7天) ===" % [float(ticks) / float(WorldState.TICKS_PER_DAY), ticks])
	print("①哪一道門開(母體=%d次全隊快照，非互斥——一次快照可能多門同開)：" % total_snapshots)
	print("  faction_directive開=%d(%.2f%%)　征服intent開=%d(%.2f%%)　血仇開=%d(%.2f%%)　全關(沒進候選)=%d(%.2f%%)" % [
		door_faction, 100.0 * float(door_faction) / float(total_snapshots),
		door_conquest, 100.0 * float(door_conquest) / float(total_snapshots),
		door_feud, 100.0 * float(door_feud) / float(total_snapshots),
		door_none, 100.0 * float(door_none) / float(total_snapshots)])

	print("\n②征服門target的軍力排序(驗證『永遠最弱』的結構推論)：")
	if conquest_ranks.is_empty():
		print("  ★母體=0——本窗征服門從未開過(或target未進rank_of，見原始log核對)")
	else:
		var sum_pct: float = 0.0
		for r in conquest_ranks: sum_pct += float(r["rank"]) / float(r["total"])
		print("  母體=%d筆　平均排名百分位(1.0=最強/0.0=最弱方向，這裡用rank/total，越接近1越弱)=%.3f" % [
			conquest_ranks.size(), sum_pct / float(conquest_ranks.size())])
		var near_bottom: int = 0
		for r in conquest_ranks:
			if float(r["rank"]) / float(r["total"]) >= 0.7: near_bottom += 1
		print("  target排名在後30%%(弱者區)的比例=%.1f%% ⇒ %s" % [
			100.0 * float(near_bottom) / float(conquest_ranks.size()),
			"符合『永遠最弱』推論" if near_bottom == conquest_ranks.size() else "★推論不完全成立，有例外"])

	print("\n③派系directive門target的軍力排序(這條路沒查過，唯一可能強強來源)：")
	if faction_ranks.is_empty():
		print("  ★母體=0——本窗faction_directive門從未開過")
	else:
		var sum_pct2: float = 0.0
		for r in faction_ranks: sum_pct2 += float(r["rank"]) / float(r["total"])
		print("  母體=%d筆　平均排名百分位=%.3f" % [faction_ranks.size(), sum_pct2 / float(faction_ranks.size())])
		print("  逐次樣本(cap=30，含attacker/target是否在strong_set)：")
		for s in faction_directive_targets:
			print("    %s" % str(s))

	print("\n④強→強候選(strong_set=top%d或15%%取大，本卷用軍力armed非population)：" % 8)
	if strong_vs_strong.is_empty():
		print("  ★★★母體=0——沒有出現任何強打強的候選 ⇒ 這就是答案：不是嚇阻，是【提名不到】。")
		print("  ★照票面規則：母體不足就不做util分解，省下這一跑——不硬撐少數幾筆。")
	else:
		print("  母體=%d筆，需要util分解(留給下一輪或人工判讀)：" % strong_vs_strong.size())
		for s in strong_vs_strong:
			print("    %s" % str(s))

	print("\n=== attack_door_census_bed DONE ===")
