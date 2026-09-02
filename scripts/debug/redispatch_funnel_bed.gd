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
	print("── ③輸的當下：完整 per-option util 表（★母體只有 3 ⇒ 不取樣，全印）──")
	var tabs: Array = Probe.samples.get("redispatch.lost_table", []) as Array
	print("  表數 = %d（★應等於 lost = %d；不等 ⇒ 有的沒印到）" % [tabs.size(), lost])
	for row in tabs:
		print("  ── tick=%s team=%s ──" % [str(row["tick"]), str(row["team"])])
		print("     承諾 opt = %s ／ current_option = %s" % [str(row["committed"]), str(row["current_option"])])
		print("     ★persist 這一格【有沒有加到】= %s（persist_strength=%s）"
			% [str(row["persist_applies"]), str(row["persist_strength"])])
		print("     承諾 util = %s ／ 贏家 = %s util = %s ／ ★差距 = %s"
			% [str(row["committed_u"]), str(row["winner"]), str(row["winner_u"]), str(row["gap"])])
		print("     ★判「輸得對不對」用的現況（★皆為已存欄位，沒有呼叫會推進 EWMA 的東西）：")
		print("        pop=%s food_runway=%s famine_days=%s readiness=%s in_combat=%s"
			% [str(row["pop"]), str(row["food_runway"]), str(row["famine_days"]),
			   str(row["readiness"]), str(row["in_combat"])])
		print("     全候選表：")
		for c in (row["table"] as Array):
			print("        %-10s u=%s" % [String(c["opt"]), str(c["u"])])
	print("  ★★★判讀協定（blueprint 定、systems 轉述）：")
	print("     ①先問【它輸得對不對】，再談持守加成。★禁 crank。")
	print("     ②★『可能 genuine』也是一個【解釋】——它一樣要等數字，不是答案")
	print("     ③★★而在看完這張表之前，不對「為什麼輸」給任何解釋")
	print("★誠實限：①單 config／單 seed／短窗；★★★本刀是【純觀測】—— 它讓再派看得見，")
	print("  ★而候選本來就自動在 ranked 裡（current_option 活過 release ⇒ 自帶 persist_strength）")
	print("  ⇒ ★★若 not_in_ranked 佔多數，那才是要開的下一票（承諾在、選項不可選）")
	quit()
