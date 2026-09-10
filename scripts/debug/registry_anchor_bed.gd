extends SceneTree
# @bed-kind: acceptance
# slice: 登記錨 ④a（加欄位＋改讀者＋遷移）
#
# ★★★這張票最容易做錯的不是欄位，是【遷移】：沒有它，上線那一刻全世界同時失去居民身分。
# ★★而判準是【逐隊相同】不是總數 —— 「錨上線」與「世界崩了」在總數以外的指標上長得一樣。
# env：RA_TICKS（shadow 窗，預設 400）

var fails: int = 0
var sections: int = 0

func _ok(name: String, cond: bool, detail: String) -> void:
	sections += 1
	if cond:
		print("  PASS %s ── %s" % [name, detail])
	else:
		fails += 1
		print("  [FAIL] %s ── %s" % [name, detail])

func _make() -> WorldState:
	# ★走 helper（arm → setup 的順序寫死在它裡面）：自己拼順序＝建世界那一段的 tap 是盲的，
	#   ★而「少掉一段」與「那一段沒發生」在輸出上長得一模一樣。
	var cfg: String = OS.get_environment("RA_CONFIG") if OS.has_environment("RA_CONFIG") else "warring_states"
	return MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("RA_TICKS")) if OS.has_environment("RA_TICKS") else 400
	print("=== 登記錨 ④a 驗收床（shadow 窗 %d tick ＝ %.2f 遊戲天）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY)])
	seed(9001)
	var st := _make()   # ★helper 內含 Probe.arm()

	# ①★★★遷移逐隊相同（不是總數）
	var mism: Array = []
	var residents: int = 0
	var lodgers: int = 0        # 房客＝登記在【別人擁有】的據點（同 faction 借宿）
	for tid in st.teams:
		var t: TeamData = st.teams[tid]
		var was: bool = FactionAISystem.legacy_resident_by_position(st, t)
		var now: bool = FactionAISystem.is_resident_static(st, t)
		if was != now:
			mism.append("Team%d was=%s now=%s pos=%s reg=%s" % [tid, was, now, t.tile_pos, t.work_outpost])
		if now:
			residents += 1
			var tile: HexTileData = st.world.tiles.get(t.work_outpost.x * 1000 + t.work_outpost.y)
			if tile != null and tile.outpost_owner != t.team_id:
				lodgers += 1
	_ok("①遷移逐隊相同", mism.is_empty(),
		"%d 支隊逐隊比對；不一致 %d 筆%s" % [st.teams.size(), mism.size(),
			"" if mism.is_empty() else " ⇒ " + ", ".join(mism.slice(0, 5))])

	# ②★母體地板（兩者皆 0 ⇒ ①自動成立 ⇒ 不可判）
	# ★★★裁定（systems 2026-09-10 §③）：房客那一格【目前無論哪個 config 都不可判】
	#   ⇒ 明寫不可判，★不要用「沒有不一致」冒充綠；★★它要等世界真的長出房客（攻擊門／④b）。
	_ok("②母體地板（居民）", residents > 0,
		"居民 %d 支（★0 ⇒ ①自動成立 ⇒ 不可判）" % residents)
	print("  ★②-b 房客母體：%d 支 ⇒ %s" % [lodgers,
		"可判" if lodgers > 0 else "★★【不可判】—— 三個 config 在 t=0 房客都是 0，掛著等世界長出房客（不硬湊）"])

	# ③★★讀者真的切過去了：清空一支隊的登記 ⇒ 在【每一個】讀者處都變非居民
	var victim: TeamData = null
	for tid in st.teams:
		if FactionAISystem.is_resident_static(st, st.teams[tid]):
			victim = st.teams[tid]
			break
	if victim == null:
		_ok("③讀者逐站點名", false, "★母體塌陷：找不到任何居民 ⇒ 不可判")
	else:
		var tile: HexTileData = st.world.tiles.get(victim.work_outpost.x * 1000 + victim.work_outpost.y)
		var before_ctx: bool = DecisionContext.gather(st, victim, false).is_resident
		var before_works: bool = ManufacturingSystem.new()._team_works_tile(st, victim, tile)
		victim.work_outpost = Vector2i(-1, -1)
		var sites: Array = []
		sites.append(["is_resident_static", FactionAISystem.is_resident_static(st, victim)])
		sites.append(["WorldState.is_registered_resident", st.is_registered_resident(victim)])
		sites.append(["DecisionContext.is_resident", DecisionContext.gather(st, victim, false).is_resident])
		# ★`_team_works_tile` 已【退出本票】（systems 裁：它屬 slice 2）⇒ 它【不該】跟著翻
		#   ⇒ ★★所以它在這裡是【反向對照】：翻了才是錯（那代表本票偷偷改了生產權）。
		var works_after: bool = ManufacturingSystem.new()._team_works_tile(st, victim, tile)
		var still: Array = []
		for s in sites:
			if bool(s[1]):
				still.append(String(s[0]))
		_ok("③讀者逐站點名", before_ctx and still.is_empty() and works_after == before_works,
			"清空 Team%d 的登記 ⇒ 登記讀者：%s；★反向對照 `_team_works_tile` %s（清空前 ctx=%s works=%s）" % [
				victim.team_id, "全部變非居民" if still.is_empty() else "仍為居民：" + ", ".join(still),
				"沒跟著翻（正確：它已退出本票）" if works_after == before_works else "★跟著翻了＝本票偷改了生產權",
				before_ctx, before_works])

	# ★★★重新 arm：①③ 那兩段【自己動手清空過登記】⇒ 它們會在 shadow 桶裡留下
	#   「舊 true 新 false」的假不一致 —— ★而那是【床自己造的】，不是世界的。
	#   ⇒ 量測窗要跟被量的東西對齊（同一族教訓：窗貼著被量的東西）。
	Probe.arm()
	# ④★shadow：跑一窗，新謂詞 vs 舊站位判定逐次比對（★先驗比對次數 > 0）
	var st2 := _make()
	var runner := SimRunner.new()
	for _i in range(ticks):
		runner.advance_tick(st2, Vector2i(-1, -1))
	var rn: int = int(Probe.counts.get("registry.shadow.resident.n", 0))
	var rm: int = int(Probe.counts.get("registry.shadow.resident.mismatch", 0))
	var wn: int = int(Probe.counts.get("registry.shadow.works.n", 0))
	var wm: int = int(Probe.counts.get("registry.shadow.works.mismatch", 0))
	_ok("④shadow 母體地板", rn > 0 and wn > 0,
		"resident 比對 %d 次／works 比對 %d 次（★0 次 ⇒ 『零不一致』沒有鑑別力）" % [rn, wn])
	# ★★★語意變更之後，shadow 不再是「零不一致」閘，而是【差異量表】：
	#   ①resident：登記制是【持久】的 ⇒ 離家的居民在舊判定下是 false、登記制下仍是 true
	#     ⇒ ★不一致【是預期的】，而它的【方向】必須單向（was=false&now=true 才對；反向＝真的壞了）
	#   ②works：本支已退出本票（行為＝舊實作）⇒ 這裡的不一致只是 slice 2 的參考量
	var wrong_dir: int = 0
	for d in Probe.samples.get("registry.shadow.resident.detail", []):
		if bool(d.get("was", false)) and not bool(d.get("now", false)):
			wrong_dir += 1
	_ok("④resident 差異只准單向", wrong_dir == 0,
		"resident 不一致 %d 筆，其中【舊 true 新 false】%d 筆（★後者＝居民憑空消失＝真的壞了）" % [rm, wrong_dir])
	print("  ★④-b works 不一致 %d/%d（本支已退出本票，行為＝舊實作 ⇒ 此為 slice 2 的參考量）" % [wm, wn])
	print("  ★④-c 自動登記 stub 觸發 %d 次（★④b 上線後這個數字該歸零）／【登記了但人不在】%d 次" % [
		int(Probe.counts.get("registry.auto_register_stub", 0)),
		int(Probe.counts.get("registry.resident.away", 0))])
	if rm > 0 or wm > 0:
		print("    ★不一致樣本（前 5）：")
		for d in Probe.samples.get("registry.shadow.resident.detail", []).slice(0, 5):
			print("      resident %s" % [d])
		for d in Probe.samples.get("registry.shadow.works.detail", []).slice(0, 5):
			print("      works    %s" % [d])
	# ★一跳 denied 的分語境計數（★紅燈要有主詞）
	var hops: Array = []
	for k in Probe.counts:
		if String(k).begins_with("registry.parent_hop.denied."):
			hops.append("%s=%d" % [String(k).replace("registry.parent_hop.denied.", ""), int(Probe.counts[k])])
	print("  ★一跳 denied 分語境：%s" % ("（無）" if hops.is_empty() else "、".join(hops)))
	# ★★★而「登記數 0」有兩個意思，這裡要分開：①遷移沒接上 ②這個世界【本來就沒有居民】
	#   ⇒ 所以同時印【舊判定】現在說幾支是居民 —— 兩個數字並排才讀得出是哪一種。
	var legacy_now: int = 0
	for tid in st2.teams:
		if FactionAISystem.legacy_resident_by_position(st2, st2.teams[tid]):
			legacy_now += 1
	print("  ★登記數（跑完 %d tick 後）：%d / %d 支隊；★★而【舊站位判定】此刻說有 %d 支居民" % [
		ticks, _count_reg(st2), st2.teams.size(), legacy_now])
	print("  ★fp=%s" % StateFingerprint.compute(st2))

	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [sections - fails, sections, fails])
	quit(1 if fails > 0 else 0)

func _count_reg(st: WorldState) -> int:
	var n: int = 0
	for tid in st.teams:
		if st.is_registered_resident(st.teams[tid]):
			n += 1
	return n
