extends SceneTree
# @bed-kind: acceptance
# slice: 絕境暴力正例格——DISPATCH到期工單(掠奪票merge後兌現，desperation-violence-cell-remeasure)
#
# ★問法改了(systems 2026-09-17)：舊版問「餓+有牙⇒攻擊贏argmax」3seed×10天=0次，
#   那個0是結構造成的(掠奪當時是不打折的常數，攻擊是三層連乘)——追錯格。
#   新問法：★餓且有牙的隊，會不會【動手】(搶=TASK_LOOT或打=TASK_ATTACK，任一)？
# ★母體=餓(food_days<DESPERATION_DAYS)且有牙(armed>0)的隊天數；報：動手次數/母體。
# ★副問(便宜,順跑)：【餓】與【有牙】各自的頻率(不是交集)——0可以是「兩條件很少同時
#   成立」也可以是「成立了但不動手」，兩者在總數上長得一樣，缺這兩個數分不開。
# ★★★這一輪與上一輪(v2/v3 gen5_remeasure_bed)不可加總——掠奪估值整個換過，
#   舊的0次是被推翻的那個世界的讀數，不是這一輪的基準；本床是全新一輪，不引舊數字做差。
# ★不需要呼叫DecisionContext.gather/rank_scored_ctx——「動手」只讀team.current_task，
#   比對象是TASK_LOOT("掠奪")/TASK_ATTACK("攻擊")兩個task常數(spec原話「搶或打任一」)，
#   零額外引擎呼叫，逐日採樣(比之前每7天一次的頻率高，因為這裡便宜)。
#
# env：BED_DAYS(預設10)／BED_SEED(預設1337)／BED_CONFIG(預設warring_states)
# ★機器紀律(systems今天訂)：開跑前看FreeMB、一次跑一個、交件帶[BedSelfCheck] HEAD=<sha>。

func _initialize() -> void:
	_run(); quit()

# ★03b_measurer.md判準⑩：比對兩份輸出前先證明它們是同一棵樹。
func _bed_self_check_tree() -> void:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short", "HEAD"], out)
	var sha: String = (out[0] as String).strip_edges() if not out.is_empty() else "UNKNOWN"
	out.clear()
	OS.execute("git", ["status", "--porcelain", "--", "scripts/simulation/"], out)
	var dirty_lines: int = 0
	if not out.is_empty():
		for l in (out[0] as String).split("\n"):
			if l.strip_edges() != "": dirty_lines += 1
	print("[BedSelfCheck] HEAD=%s scripts/simulation-dirty=%d（%s）" % [
		sha, dirty_lines, "clean" if dirty_lines == 0 else "★dirty!跟其他log比對前先確認同commit"])

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 10
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	print("=== desperation_violence_cell_bed: config=%s days=%d seed=%d ===" % [cfg, days, seed_val])
	_bed_self_check_tree()
	print("[HOST] start proc_static_MB=%.0f（★這不是系統FreeMB，是進程自身靜態記憶體——真FreeMB跑前另查）" % (float(OS.get_static_memory_usage()) / 1048576.0))

	seed(seed_val)
	Probe.reset(); Probe.arm()
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var ticks: int = days * WorldState.TICKS_PER_DAY

	var n_sampled: int = 0
	var n_hungry: int = 0
	var n_armed: int = 0
	var n_hungry_and_armed: int = 0
	var n_violence: int = 0
	var n_loot: int = 0
	var n_attack: int = 0
	var violence_samples: Array = []   # ★逐筆存最先撞到的幾筆(cap小,便宜)，讓「動手」讀出來像故事

	for tick in range(ticks):
		runner.advance_tick(st, no_player)
		if (tick + 1) % WorldState.TICKS_PER_DAY == 0:
			var d: int = (tick + 1) / WorldState.TICKS_PER_DAY
			for tid in st.teams:
				var team: TeamData = st.teams[tid]
				if team == null or team.leader_id == -1: continue
				var pop: int = team.population
				if pop <= 0: continue
				var need: float = maxf(float(pop) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
				var fd: float = ResourceSystem.effective_food(st, team) / need
				var armed: float = FactionAISystem.new()._calc_own_armed(st, team)
				n_sampled += 1
				var is_hungry: bool = fd < DecisionTerms.DESPERATION_DAYS
				var is_armed: bool = armed > 0.0
				if is_hungry: n_hungry += 1
				if is_armed: n_armed += 1
				if is_hungry and is_armed:
					n_hungry_and_armed += 1
					var is_loot: bool = team.current_task == TeamData.TASK_LOOT
					var is_atk: bool = team.current_task == TeamData.TASK_ATTACK
					if is_loot: n_loot += 1
					if is_atk: n_attack += 1
					if is_loot or is_atk:
						n_violence += 1
						if violence_samples.size() < 30:
							violence_samples.append("day=%d team=%d food_days=%.2f armed=%.2f task=%s" % [
								d, team.team_id, fd, armed, team.current_task])
					# ★systems 2026-09-17問：那18筆各自的rank表(贏家/掠奪名次util/攻擊名次util)——
					#   「不動手」是結果不是原因，原因寫在選了什麼上面。母體只有個位數/十位數,逐筆存不OOM。
					var ctx: DecisionContext = DecisionContext.gather(st, team, false)
					# ★追加票①(10筆take/need/odds/person)：不手抄terms.gd的公式——terms.gd:411-415
					#   本來就有Probe.bump_sample("raid.factors",{take,need,odds,person,...})，cap=200。
					#   ★首次跑發現全部raid_factors_captured=false——production自己全世界所有隊每天
					#   都在eval loot_drive,cap=200在day1就爆滿,first-N早就不收新的了(同一族坑，
					#   systems今天講過很多次)。★修法：呼叫前先清空這一個key(只清這一格,不動其他Probe
					#   狀態，純診斷結構零RNG零gameplay影響)，呼叫後任何新entry必為這一筆(我的for迴圈
					#   逐team序列處理，呼叫之間不會有advance_tick插進來，不會被別隊污染)。
					Probe.samples.erase("raid.factors")
					var scored: Array = DecisionEngine.rank_scored_ctx(ctx, team.current_option, st, team)
					var _raid_arr: Array = (Probe.samples.get("raid.factors", []) as Array)
					var raid_factors: Dictionary = {}
					if not _raid_arr.is_empty():
						raid_factors = _raid_arr[_raid_arr.size() - 1]
					var winner_opt: String = String(scored[0]["opt"]) if not scored.is_empty() else ""
					var winner_u: float = float(scored[0]["u"]) if not scored.is_empty() else 0.0
					var loot_rank: int = -1
					var loot_u: float = 0.0
					var atk_rank: int = -1
					var atk_u2: float = 0.0
					for i in range(scored.size()):
						var e: Dictionary = scored[i]
						if String(e["opt"]) == "掠奪": loot_rank = i + 1; loot_u = float(e["u"])
						if String(e["opt"]) == "攻擊": atk_rank = i + 1; atk_u2 = float(e["u"])
					# ★追加票②：18筆不在候選集的原因分佈——外部呼production既有predicate分類(不手抄belief/path
					#   物理，只重跑同一組if-continue的判斷順序，仿resident_truthset_distance_bed手法)：
					#   逐個team_discovered候選看它卡在哪一道門(has_belief/reachable/pop_est)，
					#   取「這支隊所有候選裡走得最遠的那一道」為此隊此刻的阻擋原因。
					var block_reason: String = ""
					if loot_rank < 0:
						var _disc: Array = st.team_discovered.get(team.team_id, [])
						if _disc.is_empty():
							block_reason = "①不在team_discovered"
						else:
							var _furthest: int = 0   # 0=沒人過has_belief 1=過has_belief沒人reachable 2=過reachable沒人夠弱
							# ★systems 2026-09-17問：③reachable=false的細分——PathSystem.estimate_catch_up
							#   本來就回傳reason(out_of_sight/team_missing/no_belief_pos/no_path/too_fast/too_far)
							#   +eta(僅too_far)。不是新量測，只是把已有欄位存下來——記第一個造成furthest=1的
							#   候選之reason/eta，只在最終furthest確定停在1時才採用(否則該候選的reason已不代表
							#   這支隊最終的分類)。
							var _reach_reason: String = ""
							var _reach_eta: int = -1
							for _tid3 in _disc:
								if _tid3 == team.team_id: continue
								if not BeliefSystem.has_belief(st, team.team_id, _tid3): continue
								if _furthest < 1: _furthest = 1
								var _catch: Dictionary = PathSystem.estimate_catch_up(st, team, _tid3, true)
								if not bool(_catch.get("reachable", false)):
									if _reach_reason == "":
										_reach_reason = String(_catch.get("reason", "(無reason欄位?回報)"))
										_reach_eta = int(_catch.get("eta", -1))
									continue
								if _furthest < 2: _furthest = 2
								var _bel3: Dictionary = BeliefSystem.best_estimate(st, team.team_id, _tid3)
								var _pop3: float = float(_bel3.get("population_est", 0.0))
								if _pop3 < float(team.population) * 0.7: _furthest = 3
							match _furthest:
								0: block_reason = "②has_belief=false(全部候選)"
								1: block_reason = "③reachable=false(全部有belief的候選)｜reason=%s%s" % [
									_reach_reason, ("｜eta=%d" % _reach_eta) if _reach_eta >= 0 else ""]
								2: block_reason = "④pop_est≥0.7×我方(全部reachable的候選都不夠弱)"
								_: block_reason = "(異常:furthest=3卻loot_rank<0,回報)"
					# ★追加票②(blueprint讀法)：通道三布林——照票面定義逐字用，不代換更嚴格的production applicable
					var has_regime: bool = team.faction_id != -1
					var has_market: bool = ctx.has_food_market
					var has_coin_and_market: bool = float(team.resources.get("coin", 0.0)) > 0.0 and ctx.has_food_market
					Probe.bump_sample("desperation_violence.rank18", {
						"seed": seed_val, "day": d, "team": team.team_id,
						"贏家opt": winner_opt, "贏家u": snappedf(winner_u, 0.0001),
						"掠奪名次": (loot_rank if loot_rank > 0 else null), "掠奪u": (snappedf(loot_u, 0.0001) if loot_rank > 0 else null),
						"攻擊名次": (atk_rank if atk_rank > 0 else null), "攻擊u": (snappedf(atk_u2, 0.0001) if atk_rank > 0 else null),
						"掠奪不在候選集": loot_rank < 0, "攻擊不在候選集": atk_rank < 0,
						"掠奪不在候選集原因": (block_reason if loot_rank < 0 else null),
						"take": raid_factors.get("take", null), "need_raid": raid_factors.get("need", null),
						"odds_raid": raid_factors.get("odds", null), "person_raid": raid_factors.get("person", null),
						"raid_factors_captured": not raid_factors.is_empty(),
						"有政權可徵": has_regime, "有幣可買且市場可達": has_coin_and_market, "市場可達": has_market,
						"food_days": snappedf(fd, 0.01), "self_armed_ratio": snappedf(ctx.self_armed_ratio, 0.001),
						"has_weak_prey": ctx.has_weak_prey, "weak_prey_id": ctx.weak_prey_id,
						"當前task_snapshot": team.current_task,
					}, 30)
			print("[WINDOW] day=%d/%d status=running" % [d, days])
			print("[DAILY] day=%d 累計：餓且有牙=%d 動手=%d(掠奪%d/攻擊%d)" % [
				d, n_hungry_and_armed, n_violence, n_loot, n_attack])

	print("[HOST] end proc_static_MB=%.0f" % (float(OS.get_static_memory_usage()) / 1048576.0))
	print("")
	print("=== 結果(seed=%d，窗=%d天) ===" % [seed_val, days])
	print("★母體/定義：逐team-day採樣總數=%d｜餓(food_days<%.2f)=%d｜有牙(armed>0)=%d｜★餓且有牙(本題母體)=%d" % [
		n_sampled, DecisionTerms.DESPERATION_DAYS, n_hungry, n_armed, n_hungry_and_armed])
	print("★★主問：餓且有牙的隊，會不會動手(搶TASK_LOOT或打TASK_ATTACK，任一)？")
	if n_hungry_and_armed == 0:
		print("   ★★★母體=0⇒本題【不可判】——不是綠也不是紅，是這個世界(此窗此seed)裡沒有『餓且有牙』的隊")
	else:
		print("   動手次數=%d／母體%d ＝ %.1f%%（掠奪%d次｜攻擊%d次）" % [
			n_violence, n_hungry_and_armed, 100.0 * float(n_violence) / float(n_hungry_and_armed), n_loot, n_attack])
	print("   逐筆(前%d筆)：" % mini(30, violence_samples.size()))
	for s in violence_samples:
		print("      %s" % s)
	print("")
	# ★systems 2026-09-17：那18筆各自的rank表——不動手是結果不是原因，原因在選了什麼上面
	var rank_samples: Array = (Probe.samples.get("desperation_violence.rank18", []) as Array)
	print("★逐筆rank表(母體=%d｜存了=%d｜%s)：" % [
		n_hungry_and_armed, rank_samples.size(),
		"未截斷" if rank_samples.size() >= n_hungry_and_armed else "★★被cap截斷!母體>cap"])
	for s in rank_samples:
		print("      %s" % str(s))
	print("")
	print("[WINDOW] day=%d/%d status=completed reason=window_reached" % [days, days])
	print("=== desperation_violence_cell_bed DONE (seed=%d) ===" % seed_val)
