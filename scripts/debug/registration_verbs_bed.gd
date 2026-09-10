extends SceneTree
# @bed-kind: acceptance
# slice: ④b 登記動詞（收留／求居／據點滅→流離）
#
# ★★★這張票的成功判準【不是動詞能用】，是【跑完自然窗後世界裡真的有房客】。
#   ★母體必須來自**預設 config** —— 禁調參數／改初始佈局／加特製 config。
#   ★★跑不出來 ⇒ **就是紅**，而紅的意思是「動詞沒有真的接上世界」。
# env：RV_TICKS（預設 8640 ＝ 6 遊戲天）／RV_CONFIG（預設 warring_states）

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("RV_TICKS")) if OS.has_environment("RV_TICKS") else 8640
	var cfg: String = OS.get_environment("RV_CONFIG") if OS.has_environment("RV_CONFIG") else "warring_states"
	print("=== ④b 登記動詞（%d tick ＝ %.1f 遊戲天，%s，★預設 config 未改）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg])
	seed(4242)
	var st := MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	for _i in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))

	# ①母體：登記在【別人村裡】的隊（★印數量與是哪幾隊）
	var lodgers: Array = []
	var residents: int = 0
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		if not st.is_registered_resident(t):
			continue
		residents += 1
		var wt: HexTileData = st.world.tiles.get(t.work_outpost.x * 1000 + t.work_outpost.y)
		if wt != null and wt.outpost_owner != t.team_id:
			lodgers.append("Team%d@(%d,%d)owner=%d%s" % [t.team_id, t.work_outpost.x, t.work_outpost.y,
				wt.outpost_owner, "同faction" if wt.outpost_owner != -1 and st.teams.has(wt.outpost_owner) \
					and (st.teams[wt.outpost_owner] as TeamData).faction_id == t.faction_id and t.faction_id != -1 else "跨/無faction"])
	print("")
	print("★①母體：居民 %d 支／**房客 %d 支** %s" % [residents, lodgers.size(),
		"⇒ " + str(lodgers) if not lodgers.is_empty() else "⇒ ★★★紅：動詞沒有真的接上世界"])
	# ②stub 是否被真動詞接管
	print("★②stub %d 次／收留動詞 %d 次（同 faction %d／跨 faction %d）／流離 %d 次" % [
		int(Probe.counts.get("registry.auto_register_stub", 0)),
		int(Probe.counts.get("registry.verb.shelter", 0)),
		int(Probe.counts.get("registry.verb.shelter.same_faction", 0)),
		int(Probe.counts.get("registry.verb.shelter.cross_faction", 0)),
		int(Probe.counts.get("registry.verb.displaced", 0))])
	# ③秤在競爭池裡：收留／求居的候選與勝負（★不是只記 win）
	print("★③收留：候選 %d 次／贏 %d 次｜求居：候選 %d 次／贏 %d 次" % [
		int(Probe.counts.get("decision.opt_applicable.收留", 0)),
		int(Probe.counts.get("optpool.win.收留", 0)),
		int(Probe.counts.get("decision.opt_applicable.求居", 0)),
		int(Probe.counts.get("optpool.win.求居", 0))])
	# ⑥一隊一登記（動詞上線後重驗）
	var multi: int = 0
	for tid in st.teams:
		var t2: TeamData = st.teams[tid]
		if t2.work_outpost != Vector2i(-1, -1):
			var wt2: HexTileData = st.world.tiles.get(t2.work_outpost.x * 1000 + t2.work_outpost.y)
			if wt2 == null or wt2.outpost_level <= 0:
				multi += 1   # ★登記指向一個不存在的據點 ＝ 流離沒清乾淨
	print("★⑥一隊一登記：欄位是單值 ⇒ 結構上保證；★而【指向已消失據點】的殘留 = %d 支" % multi)
	# ★★★母體為 0 時要答的是【為什麼】—— 三個前置各自的數字（★不是只說「沒有發生」）
	var produce_n: int = 0
	var produce_homeless: int = 0
	var homeless_with_known_host: int = 0
	var outposts_n: int = 0
	for tid3 in st.world.tiles:
		var tl: HexTileData = st.world.tiles[tid3]
		if tl.outpost_level > 0 and tl.outpost_owner != -1:
			outposts_n += 1
	for tid4 in st.teams:
		var t4: TeamData = st.teams[tid4]
		if t4.beast_kind != "" or not t4.tags.has(TeamData.TAG_PRODUCE):
			continue
		produce_n += 1
		if st.own_outpost_tile(t4.team_id) != null:
			continue
		produce_homeless += 1
		var known: Dictionary = st.team_tile_known.get(t4.team_id, {})
		for ktid in known:
			var kt: HexTileData = st.world.tiles.get(int(ktid))
			if kt != null and kt.outpost_level > 0 and kt.outpost_owner != -1 and kt.outpost_owner != t4.team_id:
				homeless_with_known_host += 1
				break
	print("★★母體拆解：世界上有主據點 %d 個｜PRODUCE 隊 %d 支｜其中【無自家據點】%d 支｜其中【知道別人據點】%d 支" % [
		outposts_n, produce_n, produce_homeless, homeless_with_known_host])
	print("   ⇒ ★求居的前置鏈是：PRODUCE ∧ 無自家據點 ∧ 知道一個別人的據點 —— 上面四個數字說明它斷在哪一節")
	print("★⑦fp=%s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=%d" % (0 if not lodgers.is_empty() else 1))
	quit(0 if not lodgers.is_empty() else 1)
