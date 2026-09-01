extends SceneTree
# @observe-pure
# ★★★對帳：「盈餘」這個量，從產生到抵達 breed_progress 的那條線上，★到底哪一段讀不到它。
#
# ★三個量，逐日逐隊同時記（★同一 tick 取樣，避免「不同時刻的比率」那個老坑）：
#   ①measurer 口徑的盈餘 ＝ FoodFlow._sustainable_inflow − burn   （產出 − 消耗）
#   ②breed 實際讀的量     ＝ team.food_flow_avg                    （effective_food 的【存量差分】EMA）
#   ③糧倉飽和度           ＝ 自家公庫 food / cap
#
# ★★假說（★寫在前面，看數字前）：①>0 而 ②≈0 的隊，③會貼近 1.0
#   ⇒ 因為 ② EMA 的是【存量變化】，而存量一旦到 cap 就不再變 ⇒ 越有盈餘越早飽和、越永久讀成「沒盈餘」
# ★★★而若 ③ 沒有貼 cap ⇒ ★假說錯，斷點在別段（那也是答案，照實報）

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 90
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "peaceful_economy"
	seed(1337)
	print("[CONTROL-RAN] surplus_vs_breedsignal_bed 已執行到參數段｜config=%s days=%d" % [cfg, days])
	var state: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg, true)
	var runner := SimRunner.new()
	var os_sys := OutpostSystem.new()
	var _rs := ReactionSystem.new()   # _breed_balance 是 instance method

	# 逐隊累計：盈餘天數 / ②≈0 的天數 / ③平均飽和度（只在盈餘日取樣）
	var surplus_days: Dictionary = {}
	var surplus_but_signal0: Dictionary = {}
	var sat_sum: Dictionary = {}
	var sat_n: Dictionary = {}
	var elig_sum: Dictionary = {}
	var elig_n: Dictionary = {}
	var rel_sum: Dictionary = {}
	var capfull: Dictionary = {}
	var relpos: Dictionary = {}
	var born: int = 0

	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
		for tid in state.teams:
			var team: TeamData = state.teams[tid]
			if team.beast_kind != "":
				continue
			var inflow: float = FoodFlow._sustainable_inflow(state, team)
			var burn: float = float(team.population + team.minor_population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY
			var net: float = inflow - burn
			if net <= 0.0:
				continue
			surplus_days[tid] = int(surplus_days.get(tid, 0)) + 1
			# ★breed 實際讀的那個量
			if absf(team.food_flow_avg) < 0.05:
				surplus_but_signal0[tid] = int(surplus_but_signal0.get(tid, 0)) + 1
			# ★★★適齡人數（★直接量，不要用 daily/f 反推 —— 反推是推論不是量測）
			#   鏡射 _tick_breed 的兩道 gate：needs.safety>0.7 且 needs.food>0.7，且 _breed_balance>0
			var elig: float = 0.0
			for pid in state.persons:
				var pn: PersonData = state.persons[pid]
				if pn.team_id != team.team_id: continue
				if float(pn.needs.get("safety", 1.0)) <= 0.7 or float(pn.needs.get("food", 1.0)) <= 0.7: continue
				if _rs._breed_balance(team, pn.sex) <= 0.0: continue
				elig += 1.0
			elig_sum[tid] = float(elig_sum.get(tid, 0.0)) + elig
			rel_sum[tid] = float(rel_sum.get(tid, 0.0)) + ReactionSystem.breed_rel_surplus(team)
			elig_n[tid] = int(elig_n.get(tid, 0)) + 1
			# ★★★名額閘（_tick_breed 的第一道 return）：minor_population >= maxi(1, pop*0.25)
			# ★★★均值藏分佈：team9 均值 +0.192 卻沒生 ⇒ 要看【有幾天真的 >0】
			if ReactionSystem.breed_rel_surplus(team) > 0.0:
				relpos[tid] = int(relpos.get(tid, 0)) + 1
			var bcap: int = maxi(1, int(team.population * 0.25))
			if team.minor_population >= bcap:
				capfull[tid] = int(capfull.get(tid, 0)) + 1
			# ★糧倉飽和度（自家公庫）
			var g: HexTileData = ResourceSystem.own_granary_tile(state, team)
			if g != null:
				var cap: float = os_sys.storage_cap(g, "food")
				if cap > 0.0:
					sat_sum[tid] = float(sat_sum.get(tid, 0.0)) + float(g.public_storage.get("food", 0)) / cap
					sat_n[tid] = int(sat_n.get(tid, 0)) + 1
	born = int(Probe.counts.get("breed.born", 0))

	var out: Array = []
	out.append("# 盈餘 → breed 訊號 對帳｜config=%s days=%d" % [cfg, days])
	out.append("# ①盈餘＝_sustainable_inflow − burn｜②breed 讀的＝food_flow_avg｜③自家公庫飽和度")
	out.append("# 全世界 breed.born 累計 = %d" % born)
	out.append("#")
	out.append("# ★★★設計假設（reaction_system.gd:7-11 反推）：健康村 rel_surplus≈K=0.15 ⇒ f≈0.5，★適齡 5 人")
	out.append("#   ⇒ 目標 births_per_day = 0.0133 × 0.5 × 5 = 0.0333（≈ 一個月一名額）")
	out.append("team|①盈餘天|②平均 rel_surplus|★②>0 的天數|平均適齡|名額滿")
	var ids: Array = surplus_days.keys(); ids.sort()
	for tid in ids:
		var sd: int = int(surplus_days[tid])
		var s0: int = int(surplus_but_signal0.get(tid, 0))
		var sat: float = float(sat_sum.get(tid, 0.0)) / maxf(float(sat_n.get(tid, 0)), 1.0)
		var er: float = float(elig_sum.get(tid, 0.0)) / maxf(float(elig_n.get(tid, 0)), 1.0)
		var rr: float = float(rel_sum.get(tid, 0.0)) / maxf(float(elig_n.get(tid, 0)), 1.0)
		var cf: int = int(capfull.get(tid, 0))
		var rp: int = int(relpos.get(tid, 0))
		out.append("%d|%d|%.4f|%d(%.0f%%)|%.2f|%d(%.0f%%)"
			% [tid, sd, rr, rp, 100.0 * float(rp) / maxf(float(sd), 1.0), er,
			   cf, 100.0 * float(cf) / maxf(float(sd), 1.0)])
	out.append("#")
	out.append("# ★讀法：★★「盈餘天多、而 food_flow_avg≈0 佔比高」＝ breed 看不到那個盈餘")
	out.append("#   ★★★而若同一列的糧倉飽和度也接近 1.0 ⇒ 假說成立：存量到 cap ⇒ 差分歸零 ⇒ 訊號歸零")
	out.append("#")
	out.append("## ★★★四段斷點分辨（★rate_sample 只在 daily>0 時 fire ⇒ 它分得開 A/B/C 與 D）")
	# ★★★這行我上一版寫錯了：_tick_breed 只呼叫 bump_sample，【從不】bump counts
	#   ⇒ counts["breed.rate_sample"] 恆為 0 ⇒ ★「次數 = 0」是我自己的儀器造的假陰性。
	#   ★★真的計數在 samples.size()（而它有 cap 24 ⇒ 只是【下界】，不是次數）。
	out.append("breed.rate_sample 樣本 = %d（★cap 24 ⇒ 這是下界不是次數；counts 恆 0 是儀器假象）｜breed.born = %d"
		% [(Probe.samples.get("breed.rate_sample", []) as Array).size(), born])
	var smp: Array = Probe.samples.get("breed.rate_sample", []) as Array
	out.append("樣本數 = %d（cap 24）" % smp.size())
	for i in range(mini(8, smp.size())):
		out.append("  " + str(smp[i]))
	out.append("# ★讀法：樣本 = 0 ⇒ 斷在 A(名額滿)/B(f<=0)/C(無適齡) 三者之一")
	out.append("#        樣本 > 0 而 born = 0 ⇒ ★★斷在 D：★★★速率低，progress 還沒到 1.0")
	out.append("#        ★★★而【progress 逼近 1.0】與【機制壞了】長得一樣 —— 只有上面那張 progress 表分得開")
	# ★★★D 段直讀：breed_progress 是持久欄 ⇒ 跑完直接讀，不必推。
	#   ★這回答的是「rate_sample 看不到的那一半」：progress 到底走了多遠。
	out.append("#")
	out.append("## ★★★終局 breed_progress（★1.0 ＝ 一名額；★★它是持久欄，直讀非推導）")
	out.append("team|breed_progress|pop|minor|名額 cap|realized rel_surplus(終值)")
	var tids2: Array = state.teams.keys(); tids2.sort()
	var pos_n: int = 0
	var neg_n: int = 0
	for tid2 in tids2:
		var tm: TeamData = state.teams[tid2]
		if tm.beast_kind != "":
			continue
		var rs: float = ReactionSystem.breed_rel_surplus(tm)
		if rs > 0.0: pos_n += 1
		else: neg_n += 1
		out.append("%d|%.4f|%d|%d|%d|%+.4f" % [int(tid2), tm.breed_progress, tm.population,
			tm.minor_population, maxi(1, int(tm.population * 0.25)), rs])
	out.append("# ★正負分佈（終值）：正 %d 隊／負 %d 隊" % [pos_n, neg_n])
	out.append("# ★誠實限：①用 FoodFlow._sustainable_inflow（★與 breed 讀的是不同的量，那正是本表要證的）")
	out.append("#   ★★而『盈餘』的口徑若換成別的（例如含狩獵/交易），這張表的左欄會變 —— 口徑寫在這裡")
	for l in out:
		print(l)
	var path: String = OS.get_environment("SB_OUT") if OS.has_environment("SB_OUT") \
		else "docs/measurements/2026-09-01-surplus-vs-breedsignal.txt"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(out)) + "\n"); f.close()
		print("落地：%s" % path)
	print("=== surplus_vs_breedsignal DONE ===")
