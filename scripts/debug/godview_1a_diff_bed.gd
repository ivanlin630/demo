extends SceneTree
# @observe-pure
# ★★★god-view 1a 驗收床（systems 2026-09-02）：★注意第①條跟平常相反 ——
#   **`fp` 逐位元不變【不是】條件**：這兩顆是【行為修正】，fp 本來就會變。
#   要的是：★★【差在哪印得出來】。fp 變了而說不出差在哪 ＝ 沒通過。
#
# 本床印三組：
#   ①★候選母體對帳：舊 `team_discovered` vs 新 `known_targets` 的大小與【差集】
#     ⇒ ★★這是本 slice【唯一】能證明「god-view 真的關掉了」的東西
#   ②★恆 0 桶（Fix A 的 belief_pos 缺失）—— 非 0 ＝ 兩個 belief API 不一致，另一個 bug
#   ③★占村掃描的逐段殺法（哪一格把候選篩掉）
func _init() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 2
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "warring_states"
	print("=== god-view 1a diff｜config=%s days=%d ===" % [cfg, days])
	var state := MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg, true)
	seed(1337)
	var runner := SimRunner.new()
	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, Vector2i(-1, -1))

	var calls: int = int(Probe.counts.get("gv.occupy_scan_calls", 0))
	var disc: float = float(Probe.amounts.get("gv.occupy_pool_discovered", 0.0))
	var known: float = float(Probe.amounts.get("gv.occupy_pool_known", 0.0))
	var only: float = float(Probe.amounts.get("gv.occupy_pool_only_discovered", 0.0))
	print("── ①候選母體對帳（占村掃描 %d 次的累計）──" % calls)
	print("  舊母體 team_discovered 累計 = %.0f（平均 %.2f/次）" % [disc, disc / maxf(float(calls), 1.0)])
	print("  新母體 known_targets   累計 = %.0f（平均 %.2f/次）" % [known, known / maxf(float(calls), 1.0)])
	print("  ★差集（發現過但【現在沒 belief】）= %.0f" % only)
	if calls == 0:
		print("  ★★★警告：掃描 0 次 ⇒ 上面三個數字【什麼都不證明】（不是「差集 0」，是【沒跑到】）")
	elif only == 0.0:
		print("  ★這是【真結果】：這張床上兩個母體恰好相同 —— ★★不是「沒事」，是「這個窗裡沒差」")
	else:
		print("  ★★★god-view 真的被關掉了：那 %.0f 個是【舊 code 看得到、新 code 看不到】的目標" % only)

	print("── ②「知道它存在、但不知道它在哪」（★合法第三結果，非違規桶）──")
	var z: int = int(Probe.counts.get("belief.known_but_positionless", 0))
	print("  belief.known_but_positionless = %d" % z)
	print("    ★語意：has_belief=true 而 belief_pos 無效 ⇒ ★★棄該 target 的位置相關評分，【絕不退回 live】")
	print("    ★★★它【不必是 0】—— 我原本把它寫成「必須恆 0」，那是錯的（systems 2026-09-02 訂正）")

	print("── ③占村掃描逐段殺法（互斥）──")
	for k in ["occupy.scan_kill_nopos", "occupy.scan_kill_tile_unknown", "occupy.scan_outpost_target",
			  "occupy.scan_kill_nobel", "occupy.scan_kill_unreach", "occupy.scan_kill_notweak"]:
		print("  %-32s = %d" % [k, int(Probe.counts.get(k, 0))])
	print("── ④行為差（★fp 本來就會變，這裡是要【說得出差在哪】）──")
	print("  fp   = %s" % StateFingerprint.compute(state))
	print("  eph  = %s" % EphemeralStateHash.compute(state))
	print("  full = %s（★只在同一棵樹內可比）" % FullStateHash.compute(state))
	for k in ["occupy.scan_outpost_target", "prosperity.target_picked", "conq.combat_entered"]:
		print("  %-32s = %d" % [k, int(Probe.counts.get(k, 0))])
	print("★誠實限：本床是【單一 config／單一 seed】—— 差集的【數值】不可外推，")
	print("  ★★可外推的是【方向】：新母體 ⊆ 舊母體（known_targets 是 team_intel 的 key，必然 ⊆ discovered）")
	quit()
