extends SceneTree
# @observe-pure
# ★★★#5 確認 tap（★純觀測，fp 必須逐位元不變）——要回答 systems 那一句：
#   「backstop release 了幾次」與「上游重新設成 (-1,-1) 幾次」，這兩個數的關係是什麼？
#   ★後者 ≈ 前者 ⇒ 坐實【上游每 tick 重造】
#   ★★後者 ≪ 前者 ⇒ 結構推論錯 ⇒ ★★★停下來報，不要自己解釋
#
# ★而 `_flee_threat_pos` 有【兩條】回 (-1,-1) 的路，意思完全不同：
#   桶 A `flee.pos_none_no_threat`   ＝ 沒有威脅卻在逃
#   桶 B `flee.pos_none_positionless` ＝ 有威脅但不知道它在哪
#   ⇒ ★★修法方向會因為哪個佔多數而不同 —— 而【修法不在本票】。

func _init() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 3
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	print("=== #5 flee tap｜config=%s days=%d ===" % [cfg, days])
	var state := MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg, true)
	seed(1337)
	var runner := SimRunner.new()
	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))
		# ★★★分段吐值（systems 2026-09-02 的通則，★而我這支床自己也犯了同一條）：
		#   ★原本只在最後印 ⇒ 被 timeout 砍掉就【一格都沒有】，而那跟「沒發生」長得一模一樣。
		#   ★★間隔要小於【預期能跑到的長度】，所以逐日印（而不是逐十日）。
		print("[CP] day=%d flee呼叫=%d(A=%d B=%d) 設無效=%d backstop=%d 退化=%d band=%d 無目的地過門檻=%d" % [
			d + 1,
			int(Probe.counts.get("flee.pos_none_no_threat", 0)) + int(Probe.counts.get("flee.pos_none_positionless", 0)) + int(Probe.counts.get("flee.pos_ok", 0)),
			int(Probe.counts.get("flee.pos_none_no_threat", 0)), int(Probe.counts.get("flee.pos_none_positionless", 0)),
			int(Probe.counts.get("flee.set_invalid.decide_unified", 0)) + int(Probe.counts.get("flee.set_invalid.solo", 0)),
			int(Probe.counts.get("flee.backstop_release", 0)),
			int(Probe.counts.get("flee.degrade.total", 0)),
			int(Probe.counts.get("flee.band_no_dest_below_threshold", 0)),
			int(Probe.counts.get("flee.no_dest_above_threshold", 0))])

	var a: int = int(Probe.counts.get("flee.pos_none_no_threat", 0))
	var b: int = int(Probe.counts.get("flee.pos_none_positionless", 0))
	var ok: int = int(Probe.counts.get("flee.pos_ok", 0))
	var si_u: int = int(Probe.counts.get("flee.set_invalid.decide_unified", 0))
	var so_u: int = int(Probe.counts.get("flee.set_ok.decide_unified", 0))
	var si_s: int = int(Probe.counts.get("flee.set_invalid.solo", 0))
	var so_s: int = int(Probe.counts.get("flee.set_ok.solo", 0))
	var back: int = int(Probe.counts.get("flee.backstop_release", 0))

	print("── ①`_flee_threat_pos` 的三個出口（互斥且窮盡）──")
	print("  桶A 沒有威脅卻在逃 = %d" % a)
	print("  桶B 有威脅但不知在哪 = %d" % b)
	print("  有效位置           = %d" % ok)
	print("  合計 = %d（★呼叫次數；0 ⇒ 這個窗裡【根本沒人選 FLEE】，不是「都正常」）" % (a + b + ok))

	print("── ②兩個設定站（設進去的值是不是 (-1,-1)）──")
	print("  decide_unified：invalid=%d ok=%d" % [si_u, so_u])
	print("  solo          ：invalid=%d ok=%d" % [si_s, so_s])
	var set_invalid: int = si_u + si_s
	print("  ★上游設成 (-1,-1) 合計 = %d" % set_invalid)

	print("── ★★★③systems 要的那個關係 ──")
	print("  backstop release = %d ／ 上游設成 (-1,-1) = %d" % [back, set_invalid])
	if back == 0 and set_invalid == 0:
		print("  ★★★兩邊都是 0 ⇒ 這個窗裡【這條路沒被走到】—— ★不是「問題不存在」，是母體空")
	elif back == 0:
		print("  ★backstop=0 而上游 invalid=%d ⇒ ★★設了無效值但【沒有走到 backstop】：" % set_invalid)
		print("     可能它們沒進 movement（同 tick 被別的路改掉），★★★這與「每 tick 重造」不同，要查")
	elif set_invalid == 0:
		print("  ★★★backstop=%d 而上游 invalid=0 ⇒ 【結構推論錯】：無效值不是這兩站設的 ⇒ 停下來報" % back)
	else:
		var ratio: float = float(set_invalid) / float(back)
		print("  比值 上游/backstop = %.2f" % ratio)
		if ratio >= 0.8 and ratio <= 1.25:
			print("  ⇒ ★★★兩數相當 ⇒ 坐實【上游每 tick 重造】（release 清掉、下一 tick 又設回無效）")
		elif ratio < 0.8:
			print("  ⇒ ★★★後者 ≪ 前者 ⇒ systems 的結構推論【與這個窗的數字不合】—— 停下來報，不自己解釋")
		else:
			print("  ⇒ ★上游設得比 backstop 多 ⇒ 有些無效值【沒有走到 backstop】（另一條消化路），要查")
	# ★★★flee-to-safety 修法落地後的五格驗收（★修法前跑這床，下面全是 0＝桶還沒接線，不是「沒發生」）
	print("── ④flee-to-safety 驗收五格 ──")
	var mdest: int = int(Probe.counts.get("flee.move_to_dest", 0))
	var maway: int = int(Probe.counts.get("flee.move_away_fallback", 0))
	print("  ①朝目的地 = %d／②away-tile 退化 = %d／③backstop = %d（★三層各接住幾次）" % [mdest, maway, back])
	print("  ★派發時就已有目的地（不必重解）= %d（★★① 的數字小不代表沒走到）"
		% int(Probe.counts.get("flee.dest_already_set", 0)))
	print("  ③退化去向（母體＝怕過門檻但無目的地）total = %d"
		% int(Probe.counts.get("flee.degrade.total", 0)))
	var _tops: Array = []
	for k2 in Probe.counts.keys():
		if String(k2).begins_with("flee.degrade.top_"):
			_tops.append("%s=%d" % [String(k2).substr(17), int(Probe.counts[k2])])
	_tops.sort()
	print("     → %s" % ("｜".join(PackedStringArray(_tops)) if not _tops.is_empty() else "（空）"))
	print("  ⑤band（有威脅座標、沒怕過門檻、無目的地）= %d（★systems 判 benign，數字大⇒重判）"
		% int(Probe.counts.get("flee.band_no_dest_below_threshold", 0)))
	print("  ★怕過門檻但無目的地 = %d（★★這是退化路該接住的母體；它與上一行必須分得開）"
		% int(Probe.counts.get("flee.no_dest_above_threshold", 0)))
	print("── ★★★⑤四個 FLEE 派發站：誰設了 flee_from_pos、誰沒設 ──")
	print("  ★有設：decide_unified=%d＋solo=%d" % [so_u + si_u, so_s + si_s])
	var _sub: int = int(Probe.counts.get("flee.dispatch_site.subteam_NO_SET", 0))
	var _tri: int = int(Probe.counts.get("flee.dispatch_site.trigger_survival_NO_SET", 0))
	print("  ★★沒設：subteam=%d＋trigger_survival=%d" % [_sub, _tri])
	if _sub + _tri > 0:
		print("  ★★★這兩站非 0 ⇒ 它們派出的 FLEE 身上的 flee_from_pos 是【上一次 release() 清成的 (-1,-1)】")
		print("     ⇒ ★而那正是 measurer 量到的 signature，★★而它不經過我上面那兩個設定站⇒兩站恆 0")
	else:
		print("  ★兩站都是 0 ⇒ 【這個窗裡】沒走到；★★而「走不到」要更大的窗才能講")
	print("★誠實限：①單 config／單 seed／%d 日；★★本票【只加 tap 不改行為】——" % days)
	print("  ★★★修法方向取決於 blueprint 裁「怕、但不知道往哪逃的隊該做什麼」，在他裁之前加任何 guard 都等於替他選")
	quit()
