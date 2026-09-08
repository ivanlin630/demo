extends SceneTree
# population_and_turnover_specimen_bed：人口儀器卷(主線)+k校驗story稽核 兩票合併一輪跑。
# ★人口卷六格現況(2026-09-09更新，commit 0ab03121三組儀器已merge)：
#   ①出生 breed.born(全域,已有)／②成年 pop.mature.batches(隊次)/pop.mature.n(人次)
#   (population_system.gd:93-94,已merge)／③晉升漏斗逐關 anon_tier_system.try_promote：
#   promote.attempt(母體)/promote.kill.*(七種early-return分關)/promote.ok/promote.ok.n(已merge)／
#   ④死亡 death.starve_*/death.combat_*(全域分軸已有,無per-team)／⑤淨成長率(由①②③④推導,不獨立量)／
#   ⑥a erase.minors_lost+merge.minors_moved_n(全域,已有,零新tap)／⑥b 無逐次timestamp，仍量不到。
#   ⇒ ①②③④⑥a 現在都可量；⑥b誠實聲明非0非不存在，只是量不到順序。
# ★乾淨分母(systems 2026-09-09裁,不需改code)：state.teams裡負team_id是beast_system.gd:16造的
#   pseudo-team，逐日快照時同時數負id數量，report真實隊數=teams.size()-beast數。
# ★75天/胎錨驗：team.breed_progress逐日快照(reaction_system.gd:319累加/326-328到1.0扣1生1)，
#   用連續兩日快照的正向delta(跳過wrap/負值)算daily_rate，anchor=1.0/daily_rate；★不用
#   breed.rate_sample(bump_sample cap=24筆,first-N偏差,已知坑)，直接讀team狀態本身。
# ★gather-not-pure-read已知坑（systems 2026-09-07裁）：DecisionContext.gather純讀路徑會寫7個
#   節奏快取——本床不自己呼叫gather，只讀SpecimenTracer既有capture_*產出的資料，不按別人鬧鐘。
# ★k校驗story稽核：SpecimenTracer全隊取樣(母體全開，非抽樣)，跑完dump jsonl供人工/QA讀
#   motive→action→outcome：GATE-B同格嫌疑、六種未被交易碰過資源的candidate有無出現過。
# ★跑法紀律(systems 2026-09-09)：長跑前先--check-only驗語法(2秒)，避免parse error長得像卡住；
#   背景跑完後逐PID驗證真的不在了，回傳碼不算數。
# 用法：BED_CONFIG(default res://config/warring_states.json) BED_DAYS(default 90) BED_SEED(default 1337)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 90
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)

	# specimen：k校驗story稽核已收口(QA verdict已產，2026-09-07)，90天長窗預設關閉——
	# ★舊坑：90天全隊specimen在tick=20000就因檔案暴增(30天=114MB)被外部殺，人口卷本身跑不完。
	# 要重開k校驗時設BED_SPECIMEN=1。
	var specimen_on: bool = OS.has_environment("BED_SPECIMEN") and OS.get_environment("BED_SPECIMEN") == "1"
	var all_ids: Array[int] = []
	if specimen_on:
		for tid in state.teams.keys(): all_ids.append(int(tid))
		state.specimen_team_ids = all_ids
		SpecimenTracer.reset()
		SpecimenTracer.enabled = true
		print("[specimen] 全隊取樣team_ids=%s" % str(all_ids))
	else:
		print("[specimen] 本輪關閉(BED_SPECIMEN!=1)——k校驗story稽核已收口，90天窗只跑人口卷聚合")

	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	# 人口卷：periodic per-team snapshot（minor_population/population/breed_progress），推導淨變化——
	# ★不是出生/死亡各自計數的替代(那些已有全域tap，見下)，是「淨變化」+「75天/胎錨」的觀測。
	var pop_samples: Dictionary = {}   # team_id -> Array[{tick, pop, minor, breed_progress}]
	var teams_total_by_day: Array = []   # 逐日[{tick, total, beast, clean}]（乾淨分母，零新tap）

	print("=== population_and_turnover_specimen_bed: config=%s days=%d ticks=%d seed=%d ===" % [
		cfg, days, ticks, seed_val])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 1440 == 0:   # 每日採樣一次（足夠看淨成長率趨勢，不需要逐tick）
			var beast_n: int = 0
			for tid2 in state.teams:
				var t: TeamData = state.teams[tid2]
				if int(tid2) < 0: beast_n += 1
				if not pop_samples.has(tid2): pop_samples[tid2] = []
				(pop_samples[tid2] as Array).append({
					"tick": tick, "pop": t.population, "minor": t.minor_population,
					"breed_progress": t.breed_progress,
				})
			teams_total_by_day.append({
				"tick": tick, "total": state.teams.size(), "beast": beast_n,
				"clean": state.teams.size() - beast_n,
			})
		if tick % 10000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d teams=%d breed.born累計=%d erase.minors_lost累計=%.0f merge.minors_moved_n累計=%.0f" % [
				tick, state.teams.size(), int(Probe.counts.get("breed.born", 0)),
				Probe.amounts.get("erase.minors_lost", 0.0), Probe.amounts.get("merge.minors_moved_n", 0.0)])

	var specimen_path: String = "docs/measurements/2026-09-07-population-turnover.specimen.jsonl"
	if specimen_on:
		SpecimenTracer.flush()
		SpecimenTracer.write_jsonl(specimen_path)

	print("\n=== 人口儀器卷 結果(窗=%.2f天/%d ticks) ===" % [float(ticks) / float(WorldState.TICKS_PER_DAY), ticks])
	print("①出生 breed.born(全域)=%d" % int(Probe.counts.get("breed.born", 0)))
	print("②成年(population_system.gd:93-94，2026-09-09已merge)：隊次(batches)=%d　人次(n)=%.0f" % [
		int(Probe.counts.get("pop.mature.batches", 0)), Probe.amounts.get("pop.mature.n", 0.0)])
	print("③晉升漏斗逐關(anon_tier_system.try_promote，2026-09-09已merge)：")
	var promote_attempt: int = int(Probe.counts.get("promote.attempt", 0))
	print("  嘗試(母體)=%d　成功=%d(人次%.0f)" % [
		promote_attempt, int(Probe.counts.get("promote.ok", 0)), Probe.amounts.get("promote.ok.n", 0.0)])
	if promote_attempt == 0:
		print("  ★★母體=0——不可判(沒人試 vs 試了都被擋，這輪窗口分不出來)")
	else:
		for kill_key in ["count_le0", "already_elite", "not_enough_bodies", "not_enough_exp",
				"not_enough_res", "leader_tactics_cap", "elite_weapon"]:
			var kc: int = int(Probe.counts.get("promote.kill." + kill_key, 0))
			if kc > 0:
				print("  死在[%s]=%d(佔嘗試%.1f%%)" % [kill_key, kc, float(kc) / float(promote_attempt) * 100.0])
	print("④死亡分軸(全域)：")
	print("  死亡.成人named餓死(hunger/bleed)=%d/%d" % [
		int(Probe.counts.get("death.starve_named_hunger", 0)), int(Probe.counts.get("death.starve_named_bleed", 0))])
	print("  死亡.小孩餓死=%d　死亡.匿名成人餓死=%d" % [
		int(Probe.counts.get("death.starve_minor", 0)), int(Probe.counts.get("death.starve_anon", 0))])
	print("  死亡.戰死(pop/named)=%d/%d" % [
		int(Probe.counts.get("death.combat_pop", 0)), int(Probe.counts.get("death.combat_named", 0))])
	print("⑤淨成長率：由①②③④推導(非獨立量，如實聲明由上列格拼出，非另一支tap)")
	print("⑥a 滅團死亡帳：帶小孩滅團的隊數=%d　小孩總損失=%.0f（陽性對照：>0=機制真的動）" % [
		int(Probe.counts.get("erase.teams_with_minors", 0)), Probe.amounts.get("erase.minors_lost", 0.0)])
	print("⑥a 合併搬小孩：觸發次數=%d　搬運小孩總數=%.0f（陽性對照：>0=搬家機制真的動，非蒸發）" % [
		int(Probe.counts.get("merge.minors_moved", 0)), Probe.amounts.get("merge.minors_moved_n", 0.0)])
	print("⑥b 饑荒死亡順序(成人vs小孩)：無逐次timestamp，只有全域累計次數，量不到順序——如實聲明")

	# ★乾淨分母：逐日印，不只頭尾（systems 2026-09-09要求）
	print("\n乾淨分母(排除beast pseudo-team，負team_id，零新tap，直接code算)：")
	for row in teams_total_by_day:
		print("  tick=%d 總隊=%d beast=%d 乾淨=%d" % [row["tick"], row["total"], row["beast"], row["clean"]])

	# ★75天/胎錨驗：逐隊、逐日breed_progress delta，跳過負值(wrap/生育後扣1)，取正向delta平均
	var anchor_days_per_litter: Array = []
	var teams_no_signal: int = 0
	for tid4 in pop_samples:
		var arr: Array = pop_samples[tid4]
		var pos_deltas: Array = []
		for i in range(1, arr.size()):
			var d: float = float(arr[i]["breed_progress"]) - float(arr[i - 1]["breed_progress"])
			if d > 0.0:
				pos_deltas.append(d)
		if pos_deltas.is_empty():
			teams_no_signal += 1
			continue
		var sum_d: float = 0.0
		for d2 in pos_deltas: sum_d += d2
		var avg_daily_rate: float = sum_d / float(pos_deltas.size())
		if avg_daily_rate > 0.0:
			anchor_days_per_litter.append(1.0 / avg_daily_rate)
	print("\n75天/胎錨驗(逐隊breed_progress日delta推導，非breed.rate_sample——那個cap=24筆first-N偏差)：")
	print("  有訊號隊數=%d　無訊號隊數(全程delta<=0，不可判非0)=%d" % [anchor_days_per_litter.size(), teams_no_signal])
	if not anchor_days_per_litter.is_empty():
		anchor_days_per_litter.sort()
		var n_a: int = anchor_days_per_litter.size()
		print("  days/胎：min=%.1f p50=%.1f max=%.1f（設計錨=75天/胎，blueprint引用60天窗數字，供對照）" % [
			anchor_days_per_litter[0], anchor_days_per_litter[n_a / 2], anchor_days_per_litter[n_a - 1]])
	else:
		print("  ★不可判——本窗無隊產生正向breed_progress訊號")

	if specimen_on:
		print("\n=== k校驗story稽核 specimen落地：%s ===" % specimen_path)
		print("全隊取樣%d隊，含①GATE-B同格嫌疑②六種未被交易資源(herb/gem/ore_gold/ore_iron/ore_steel/weapon_melee_low)" % all_ids.size())
		print("  的candidate有無出現——需人工/QA逐條讀jsonl裡的candidates欄位，本床只負責produce，不代為判讀因果")
	else:
		print("\nk校驗story稽核：本輪未跑(已收口，見QA verdict)")

	print("=== population_and_turnover_specimen_bed DONE ===")
