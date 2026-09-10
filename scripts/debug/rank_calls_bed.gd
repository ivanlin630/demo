extends SceneTree
# @bed-kind: diagnostic
# slice: 把 unified.rank 的 80.77s 拆成【幾次呼叫 × 每次幾微秒】
#
# ★理由（systems 裁）：「每次很貴」與「叫很多次」的下一張票【完全不同】，
#   ★★而總計那個數字【兩種都長一樣】。
# ★★★而四個 from_* 一起量：否則只知道 leader 的形狀，分不出
#   「leader 特別貴」與「rank 本來就貴、只是 leader 叫得多」。
# env：RC_TICKS（預設 6000）／RC_CONFIG（預設 warring_states）

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("RC_TICKS")) if OS.has_environment("RC_TICKS") else 6000
	var cfg: String = OS.get_environment("RC_CONFIG") if OS.has_environment("RC_CONFIG") else "warring_states"
	print("=== rank 呼叫拆解（%d tick ＝ %.1f 遊戲天，%s）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg])
	# ★★★儀器自己的成本：Probe 開/關同窗對照（★關掉那趟【沒有任何相位數字】
	#   ⇒ 只能比外層牆鐘總時 —— 這一句要跟數字一起出現）
	var probe_on: bool = OS.get_environment("RC_PROBE") != "0"
	if probe_on:
		Probe.arm()
	else:
		Probe.enabled = false
	seed(4242)
	var st := WorldState.new()
	GameSetup.setup(st, GameSetup.load_config("res://config/%s.json" % cfg))
	st.player_id = -1
	var runner := SimRunner.new()
	var _w0: int = Time.get_ticks_usec()
	for _i in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
	var _wall: float = float(Time.get_ticks_usec() - _w0) / 1e6
	# ★★牆鐘對照的【前提】：Probe 開/關必須是同一個世界（觀測不得改被觀測物）
	#   ⇒ 印 fp，兩趟相同才准把 215s vs 189s 的差解釋成【儀器成本】。
	print("★fp=%s（Probe=%s）—— ★兩趟必須相同，否則牆鐘差是兩個世界的差" % [
		StateFingerprint.compute(st), "ON" if probe_on else "OFF"])
	print("★牆鐘總時：%.2f s（Probe=%s）—— ★★兩趟相比才看得出儀器佔多少" % [_wall, "ON" if probe_on else "OFF"])
	if not probe_on:
		print("=== DONE === SECTIONS=1/1 FAILS=0（★Probe 關 ⇒ 本趟沒有相位數字，只有牆鐘）")
		quit()
	print("")
	print("呼叫端        次數      總計(s)   us/call   單次max(ms)   走這條路的隊數  每隊次數")
	var srcs: Array = ["leader", "member", "solo", "threat", "unknown"]
	for src in srcs:
		var n: int = int(Probe.counts.get("rank.calls." + src, 0))
		var us: float = Probe.amount("rank.us." + src)
		var mx: float = float(Probe.peaks.get("rank.us_max." + src, 0.0))   # ★note() 寫進 peaks，不是 amounts
		var teams: int = 0
		for k in Probe.counts:
			if String(k).begins_with("rank.teams." + src + "."):
				teams += 1
		if n == 0:
			# ★母體地板：0 次要【明寫】—— ★★沒出現的呼叫端與沒登記的呼叫端在表上長得一樣
			print("%-12s ★0 次（★★明寫：它在這一窗【沒有被走到】，不是沒登記）" % src)
			continue
		print("%-12s %6d  %9.2f  %8.1f  %11.1f  %14d  %8.2f" % [
			src, n, us / 1e6, us / float(n), mx / 1000.0, teams,
			float(n) / maxf(1.0, float(teams))])
	print("")
	print("★★分段（每次呼叫拆成四段；★儀器自成一段 —— 它在被量的那條路上做真工）")
	print("呼叫端     次數   goals(us)  gather(us)  score(us)  ★probe(us)   四段和   options/call  us/option")
	for src in srcs:
		var n: int = int(Probe.counts.get("rank.seg.calls." + src, 0))
		if n == 0:
			continue
		var g: float = Probe.amount("rank.seg.goals." + src) / float(n)
		var ga: float = Probe.amount("rank.seg.gather." + src) / float(n)
		var sc: float = Probe.amount("rank.seg.score." + src) / float(n)
		var pb: float = Probe.amount("rank.seg.probe." + src) / float(n)
		var op: float = Probe.amount("rank.seg.options." + src) / float(n)
		print("%-10s %5d  %9.1f  %10.1f  %9.1f  %10.1f  %8.1f  %11.2f  %9.1f" % [
			src, n, g, ga, sc, pb, g + ga + sc + pb, op, (g + ga + sc) / maxf(1.0, op)])
	print("")
	print("★驗：us/call × 次數 應 ≈ 總計（純除法，印出來讓人自己驗）")
	print("★★★而【儀器成本】只有這一段量得到；Probe 關掉那一趟【沒有任何相位數字】")
	print("   ⇒ 那一趟只能比外層牆鐘總時（見交件的 Probe 開/關對照）")
	print("=== DONE === SECTIONS=1/1 FAILS=0")
	quit()
