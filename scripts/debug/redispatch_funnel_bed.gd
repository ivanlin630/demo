extends SceneTree
# @observe-pure
# ★★★#10 承諾再派 funnel ＋ stall 三態 tap：★本床要證的是【每一段都有數】，
#   而不是「有沒有變好」——★★「輸」必須看得見，否則它跟「沒送回」長得一模一樣。
#
# ★★★而三態 tap 的意義（reviewer 點出，不是順便補觀測）：
#   「keeps-losing 會不會變成新 latch」的答案是【不會】—— stall_verdict 是 outcome-based
#   （食物餘命 delta）非 execution-based ⇒ 必然在 stall_ticks 內落進 STALLED 或 RESOLVING。
#   ★而那個安全閥【本身能不能被驗證】，就靠這三個 tap。

func _init() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 2
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	print("=== 再派 funnel｜config=%s days=%d ===" % [cfg, days])
	var state := MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg, true)
	seed(1337)
	var runner := SimRunner.new()
	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))

	print("── ①stall 三態（★安全閥自身的可驗證性）──")
	var w: int = int(Probe.counts.get("survival.stall_waiting", 0))
	var r: int = int(Probe.counts.get("survival.stall_resolving", 0))
	var e: int = int(Probe.counts.get("survival.stall_exclude", 0))
	print("  WAITING=%d ／ RESOLVING=%d ／ STALLED=%d ／ 合計=%d" % [w, r, e, w + r + e])
	if w + r + e == 0:
		print("  ★★★合計 0 ⇒ 本窗【根本沒判過】—— 下面的 funnel 數字要照這個前提讀")
	elif w > 0 and (r + e) == 0:
		print("  ★全部落在 WAITING ⇒ ★★這個窗還沒走到判定點（stall_ticks 未到），不是「安全閥不動」")

	print("── ②再派 funnel（★每段有數）──")
	var sent: int = int(Probe.counts.get("redispatch.candidate_sent", 0))
	var nir: int = int(Probe.counts.get("redispatch.not_in_ranked", 0))
	var won: int = int(Probe.counts.get("redispatch.won", 0))
	var lost: int = int(Probe.counts.get("redispatch.lost", 0))
	print("  送回 candidate_sent = %d" % sent)
	print("    ├ ★不在候選集 not_in_ranked = %d（★★這一格才是真缺口：承諾還在而 option 不可選）" % nir)
	print("    ├ 贏 won  = %d" % won)
	print("    └ 輸 lost = %d（★「輸」是合法結果：承諾保留、任務給贏家）" % lost)
	if sent == 0:
		print("  ★★★sent = 0 ⇒ 這個窗裡【沒有 IDLE 且帶承諾的隊】——")
		print("     ★不是「再派沒用」，是【母體空】。★★兩者長得一樣，所以要印這一行。")
	elif sent != nir + won + lost:
		print("  ★FAIL 對帳不平：sent %d ≠ %d ⇒ 有一段沒被歸類" % [sent, nir + won + lost])
	else:
		print("  ★對帳平：sent ＝ not_in_ranked ＋ won ＋ lost")
	print("★誠實限：①單 config／單 seed／短窗；★★★本刀是【純觀測】—— 它讓再派看得見，")
	print("  ★而候選本來就自動在 ranked 裡（current_option 活過 release ⇒ 自帶 persist_strength）")
	print("  ⇒ ★★若 not_in_ranked 佔多數，那才是要開的下一票（承諾在、選項不可選）")
	quit()
