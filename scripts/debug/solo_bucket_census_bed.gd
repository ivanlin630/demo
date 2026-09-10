extends SceneTree
# @bed-kind: diagnostic
# slice: 「便宜路」到底是什麼 —— ★0.03 s 有兩個相反的意思，而【次數】才分得出來
#
# ★(a) 幾乎沒被走過（次數 ≈ 0）⇒ 那個為了省錢做的分岔，那筆錢從來沒省到
# ★(b) 被走很多次、每次極快 ⇒ 它正在做它該做的事
# ⇒ 同一個除法：us/call。★★而母體（solo.enter）一起印 —— 沒有分母的比率不可信。
# env：SB_TICKS（預設 3000）／SB_CONFIG（預設 warring_states）

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("SB_TICKS")) if OS.has_environment("SB_TICKS") else 3000
	var cfg: String = OS.get_environment("SB_CONFIG") if OS.has_environment("SB_CONFIG") else "warring_states"
	print("=== solo 兩桶普查（%d tick ＝ %.1f 遊戲天，%s）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg])
	seed(4242)
	var st := MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	SimRunner.phase_timing = true
	var runner := SimRunner.new()
	# ★相位表每 tick 清 ⇒ 要自己累加（★★否則拿到的是【最後一個 tick】的值而不是全窗）
	var eng_us: int = 0
	var chp_us: int = 0
	for _i in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
		eng_us += int(FactionAISystem._fai_ph.get("loop2.solo_engine", 0))
		chp_us += int(FactionAISystem._fai_ph.get("loop2.solo_cheap", 0))
	var enter: int = int(Probe.counts.get("solo.enter", 0))
	var eng_n: int = int(Probe.counts.get("solo.engine", 0))
	var chp_n: int = int(Probe.counts.get("solo.cheap", 0))
	print("")
	print("桶            次數        佔母體      總計(s)     us/call")
	print("%-12s %6d %10s %12.3f %11.1f" % ["engine", eng_n,
		"%.1f%%" % (100.0 * float(eng_n) / maxf(1.0, float(enter))), float(eng_us) / 1e6,
		float(eng_us) / maxf(1.0, float(eng_n))])
	print("%-12s %6d %10s %12.3f %11.1f" % ["cheap", chp_n,
		"%.1f%%" % (100.0 * float(chp_n) / maxf(1.0, float(enter))), float(chp_us) / 1e6,
		float(chp_us) / maxf(1.0, float(chp_n))])
	print("★母體 solo.enter = %d（★沒有分母的比率不可信）｜engine+cheap = %d（差 %d）" % [
		enter, eng_n + chp_n, enter - eng_n - chp_n])
	# ★早退的四個出口各自的次數（★它們是 cheap 桶【裡面】是什麼的答案）
	var exits: Array = []
	for k in Probe.counts:
		if String(k).begins_with("solo.exit."):
			exits.append("%s=%d" % [String(k).replace("solo.exit.", ""), int(Probe.counts[k])])
	exits.sort()
	print("★★cheap 桶裡的出口分布：%s" % ("（無 —— 那條路一次都沒走到）" if exits.is_empty() else "、".join(exits)))
	print("=== DONE === SECTIONS=1/1 FAILS=0")
	quit()
