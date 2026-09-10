extends SceneTree
# @bed-kind: diagnostic
# slice: 卡③ 的「更寬效果」打到誰（systems 要數字不要推論 2026-09-11）
#
# ★三類分開：同 faction／跨 faction／無 faction —— ★★合計答不出「誰被打到」。
# ★★★母體地板：若「站在別人據點上而未登記」是 0 次 ⇒ **不可判**，而那本身就是答案（沒有人被打到）。
# env：PB_TICKS（預設 3000）／PB_CONFIG（預設 warring_states）

func _initialize() -> void:
	var ticks: int = int(OS.get_environment("PB_TICKS")) if OS.has_environment("PB_TICKS") else 3000
	var cfg: String = OS.get_environment("PB_CONFIG") if OS.has_environment("PB_CONFIG") else "warring_states"
	print("=== 勞力池被擋掉的是誰（%d tick ＝ %.1f 遊戲天，%s）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg])
	seed(4242)
	var st := MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	for _i in range(ticks):
		runner.advance_tick(st, Vector2i(-1, -1))
	var owner_n: int = int(Probe.counts.get("pool.in.owner", 0))
	var reg_n: int = int(Probe.counts.get("pool.in.registered", 0))
	var classes: Array = ["same_faction", "cross_faction", "no_faction", "no_owner"]
	var blocked_total: int = 0
	for c in classes:
		blocked_total += int(Probe.counts.get("pool.blocked." + c, 0))
	print("")
	print("★母體：進池 owner %d 次／進池 registered %d 次／**被擋 %d 次**" % [owner_n, reg_n, blocked_total])
	if blocked_total == 0:
		print("★★★被擋 0 次 ⇒ **不可判**（★而那本身就是答案：沒有人被這一刀打到）")
	else:
		print("%-16s %10s %10s %14s" % ["類別", "次數", "佔比", "被擋的勞力量"])
		for c in classes:
			var n: int = int(Probe.counts.get("pool.blocked." + c, 0))
			if n == 0:
				print("%-16s %10s %10s %14s" % [c, "★0 次", "—", "—"])
				continue
			print("%-16s %10d %9.1f%% %14.1f" % [c, n, 100.0 * float(n) / float(blocked_total),
				Probe.amount("pool.blocked_labor." + c)])
	print("★★改前對照：這些【被擋】的隊次在舊規則下【全部會被算進池】（舊規則只看站位＋PRODUCE）")
	print("   ⇒ ★所以上表的次數就是「改前拿得到工位、改後拿不到」的那一群")
	print("=== 事實查核完畢（★純診斷：本床不下判決）===")
	quit()
