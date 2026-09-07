extends SceneTree
# population_and_turnover_specimen_bed：人口儀器卷(主線)+k校驗story稽核 兩票合併一輪跑。
# ★人口卷六格現況(已查code，非猜)：
#   ①出生 breed.born(全域,已有)／②成年population_system.gd:87(無tap)／③晉升anon→named
#   PersonGenerator.generate_for_team(無tap)／④死亡 death.starve_*/death.combat_*(全域分軸已有,
#   無per-team)／⑤淨成長率(由①②③④推導,不獨立量)／⑥a erase.minors_lost+merge.minors_moved_n
#   (全域,已有,零新tap)／⑥b 無逐次timestamp。
#   ⇒ ①④⑥a 零新tap可做(全域口徑)；②③⑥b需per-team/逐次tap，本床量不到，誠實聲明非0。
# ★gather-not-pure-read已知坑（systems 2026-09-07裁）：DecisionContext.gather純讀路徑會寫7個
#   節奏快取——本床不自己呼叫gather，只讀SpecimenTracer既有capture_*產出的資料，不按別人鬧鐘。
# ★k校驗story稽核：SpecimenTracer全隊取樣(18隊母體全開，非抽樣)，跑完dump jsonl供人工/QA讀
#   motive→action→outcome：GATE-B同格嫌疑、六種未被交易碰過資源的candidate有無出現過。
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

	# specimen：全隊取樣(k校驗要"18隊全開"，不抽樣)
	var all_ids: Array[int] = []
	for tid in state.teams.keys(): all_ids.append(int(tid))
	state.specimen_team_ids = all_ids
	SpecimenTracer.reset()
	SpecimenTracer.enabled = true
	print("[specimen] 全隊取樣team_ids=%s" % str(all_ids))

	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	# 人口卷：periodic per-team snapshot（minor_population/population），推導淨變化——
	# ★不是出生/死亡/晉升各自計數(那需要per-event tap，本床沒有)，是「淨變化」的觀測，如實聲明分辨力限制。
	var pop_samples: Dictionary = {}   # team_id -> Array[{tick, pop, minor}]

	print("=== population_and_turnover_specimen_bed: config=%s days=%d ticks=%d seed=%d ===" % [
		cfg, days, ticks, seed_val])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 1440 == 0:   # 每日採樣一次（足夠看淨成長率趨勢，不需要逐tick）
			for tid2 in state.teams:
				var t: TeamData = state.teams[tid2]
				if not pop_samples.has(tid2): pop_samples[tid2] = []
				(pop_samples[tid2] as Array).append({
					"tick": tick, "pop": t.population, "minor": t.minor_population,
				})
		if tick % 10000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d teams=%d breed.born累計=%d erase.minors_lost累計=%.0f merge.minors_moved_n累計=%.0f" % [
				tick, state.teams.size(), int(Probe.counts.get("breed.born", 0)),
				Probe.amounts.get("erase.minors_lost", 0.0), Probe.amounts.get("merge.minors_moved_n", 0.0)])

	SpecimenTracer.flush()
	var specimen_path: String = "docs/measurements/2026-09-07-population-turnover.specimen.jsonl"
	SpecimenTracer.write_jsonl(specimen_path)

	print("\n=== 人口儀器卷 結果(90天窗/%d ticks/%.2f天) ===" % [ticks, float(ticks) / float(WorldState.TICKS_PER_DAY)])
	print("①出生 breed.born(全域)=%d" % int(Probe.counts.get("breed.born", 0)))
	print("②成年：無tap，量不到(非0)——population_system.gd:87需要新tap")
	print("③晉升anon→named：無tap，量不到(非0)——PersonGenerator.generate_for_team需要新tap")
	print("④死亡分軸(全域)：")
	print("  死亡.成人named餓死(hunger/bleed)=%d/%d" % [
		int(Probe.counts.get("death.starve_named_hunger", 0)), int(Probe.counts.get("death.starve_named_bleed", 0))])
	print("  死亡.小孩餓死=%d　死亡.匿名成人餓死=%d" % [
		int(Probe.counts.get("death.starve_minor", 0)), int(Probe.counts.get("death.starve_anon", 0))])
	print("  死亡.戰死(pop/named)=%d/%d" % [
		int(Probe.counts.get("death.combat_pop", 0)), int(Probe.counts.get("death.combat_named", 0))])
	print("⑤淨成長率：由①④推導(②③未量，不構成完整推導，如實聲明不獨立給數字)")
	print("⑥a 滅團死亡帳：帶小孩滅團的隊數=%d　小孩總損失=%.0f（陽性對照：>0=機制真的動）" % [
		int(Probe.counts.get("erase.teams_with_minors", 0)), Probe.amounts.get("erase.minors_lost", 0.0)])
	print("⑥a 合併搬小孩：觸發次數=%d　搬運小孩總數=%.0f（陽性對照：>0=搬家機制真的動，非蒸發）" % [
		int(Probe.counts.get("merge.minors_moved", 0)), Probe.amounts.get("merge.minors_moved_n", 0.0)])
	print("⑥b 饑荒死亡順序(成人vs小孩)：無逐次timestamp，只有全域累計次數，量不到順序——如實聲明")

	print("\n設計錨驗證：75天/胎(blueprint引用60天窗數字) vs 本窗30天/胎錨——本床未逐隊算breed_progress速率，")
	print("  若要驗這個錨需要額外讀team.breed_progress時序，本輪未做，列入下一輪")

	print("\n=== k校驗story稽核 specimen落地：%s ===" % specimen_path)
	print("全隊取樣%d隊，含①GATE-B同格嫌疑②六種未被交易資源(herb/gem/ore_gold/ore_iron/ore_steel/weapon_melee_low)" % all_ids.size())
	print("  的candidate有無出現——需人工/QA逐條讀jsonl裡的candidates欄位，本床只負責produce，不代為判讀因果")

	print("=== population_and_turnover_specimen_bed DONE ===")
