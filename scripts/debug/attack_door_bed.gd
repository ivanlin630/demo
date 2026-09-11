extends SceneTree
# @bed-kind: acceptance
# slice: 攻擊門降級為可行性（HOW spec 2026-09-10-attack-applicable-demote-to-feasibility §⑤）
#
# ★母體與「一趟」的定義（今天買來的教訓，寫在檔頭）：
#   ·門開率的母體 ＝ **每一次 `DecisionContext.gather`**（新舊兩門在**同一次 gather** 上同時判
#     ⇒ ★逐字同母體、不必跑兩趟、不留會腐爛的旗標 ＝ 驗收⑥的成對反事實）
#   ·「攻擊 fire」的母體 ＝ `TASK_ATTACK` 真的被 `try_set` 設上的次數（**提名 ≠ 執行**，分開量）
#   ·滅團／開打是**湧現聚合** ⇒ ★★**單 seed 不可歸因**（spec §③ 分級），本床只報數並明寫此限
# env：AD_TICKS（預設 43200 ＝ 30 天）／AD_SEED（預設 1337）／AD_CONFIG（預設 warring_states）

func _initialize() -> void:
	_run(); quit(0 if _fails == 0 else 1)

var _fails: int = 0

func _ok(cond: bool, msg: String) -> void:
	if cond: print("  [OK] %s" % msg)
	else:
		_fails += 1
		push_error("[FAIL] %s" % msg)

func _run() -> void:
	var ticks: int = int(OS.get_environment("AD_TICKS")) if OS.has_environment("AD_TICKS") else 43200
	var seed_val: int = int(OS.get_environment("AD_SEED")) if OS.has_environment("AD_SEED") else 1337
	var cfg: String = OS.get_environment("AD_CONFIG") if OS.has_environment("AD_CONFIG") else "warring_states"
	print("=== 攻擊門降級 驗收（%d tick ＝ %.1f 天，%s，seed=%d，★預設 config 未改）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg, seed_val])
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var worst_us: int = 0
	var worst_tick: int = -1
	for tick in range(ticks):
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(st, no_player)
		var dt: int = Time.get_ticks_usec() - t0
		if dt > worst_us:
			worst_us = dt
			worst_tick = tick

	# ── ①門開率（★新舊同母體）──
	var n_open: int = int(Probe.counts.get("attack.door.new_open", 0))
	var n_closed: int = int(Probe.counts.get("attack.door.new_closed", 0))
	var o_open: int = int(Probe.counts.get("attack.door.old_open", 0))
	var o_closed: int = int(Probe.counts.get("attack.door.old_closed", 0))
	var moth: int = n_open + n_closed
	print("")
	print("★①門開率（母體＝gather 次數 %d）：新門 %d (%.2f%%)｜舊門 %d (%.2f%%)" % [
		moth, n_open, 100.0 * float(n_open) / maxf(float(moth), 1.0),
		o_open, 100.0 * float(o_open) / maxf(float(o_open + o_closed), 1.0)])
	var pairs: Dictionary = {}
	for k in Probe.counts:
		if String(k).begins_with("attack.door.pair."):
			pairs[String(k).replace("attack.door.pair.", "")] = int(Probe.counts[k])
	print("   ★成對矩陣（N/n＝新門開/關，O/o＝舊門開/關）：%s" % str(pairs))
	print("   ★★『nO』那一格若非 0 ⇒ **新門比舊門還嚴** ⇒ 那是回歸，不是放寬")
	if moth == 0:
		push_error("[FAIL] 母體 0：本窗沒有任何 gather —— ★不可判，不是綠")
	else:
		_ok(100.0 * float(n_open) / float(moth) > 20.0,
			"①新門開率 > 20%%（實測 %.2f%%；★下限是【機制在動】，不是平衡目標）" % (100.0 * float(n_open) / float(moth)))
		_ok(int(pairs.get("nO", 0)) == 0,
			"⑥成對反事實：沒有【舊門開而新門關】的格子（實測 %d）★★新門必須是舊門的超集" % int(pairs.get("nO", 0)))

	# ── ②沒有 IDLE 陷阱（★提名與執行分開量）──
	var idle_no_target: int = int(Probe.counts.get("attack.to_task_idle.no_target", 0))
	var idle_no_pos: int = int(Probe.counts.get("attack.to_task_idle.no_belief_pos", 0))
	print("")
	print("★②IDLE 陷阱：to_task 因【無 target】回 IDLE %d 次｜因【無 belief_pos】回 IDLE %d 次" % [
		idle_no_target, idle_no_pos])
	_ok(idle_no_target == 0 and idle_no_pos == 0,
		"②門開了就派得出去（兩個 IDLE 出口都是 0）★★★門與執行同一組條件的硬斷")

	# ── ★提名 vs 真的執行（implementer 提、spec 收的形狀要求）──
	var nominated: int = int(Probe.counts.get("optpool.cand.攻擊", 0))
	var won: int = int(Probe.counts.get("optpool.win.攻擊", 0))
	var dispatched: int = int(Probe.counts.get("conq.member_atk_dispatch", 0))
	var entered: int = int(Probe.counts.get("conq.combat_entered", 0))
	print("★★提名 %d → 贏 argmax %d → 派出 %d → 真的開打 %d" % [nominated, won, dispatched, entered])
	print("   ★『常被提名、然後溶解成 IDLE』在聚合上長得像『改完沒效果』⇒ 這一列必須分開印")

	# ── ③強弱矩陣（分布，不設門檻）──
	var ratios: Array = Probe.samples.get("attack.armed_ratio", [])
	print("")
	if ratios.is_empty():
		print("★③強弱矩陣：母體 0（本窗沒有攻擊 fire 的樣本）⇒ ★不可判，不是「世界很和平」")
	else:
		var rs: Array = []
		for r in ratios: rs.append(float(r["ratio"]))
		rs.sort()
		print("★③強弱比（self_armed / target_armed_est）分布 母體 %d：min=%.2f p50=%.2f p95=%.2f max=%.2f" % [
			rs.size(), rs[0], rs[rs.size() / 2], rs[int(float(rs.size()) * 0.95)], rs[rs.size() - 1]])
		print("   ★只報分布不設門檻（世界該長怎樣是 blueprint 的）")

	# ── ④勒索替代 ──
	print("★④勒索 fire（`raid.extort`，interaction_system:505）：%d" % int(Probe.counts.get("raid.extort", 0)))
	print("   ★blueprint 預測**應下降** ⇒ falsifiable；★★沒下降要回報，不得靜默")

	# ── ⑤滅團（★母體地板先印）──
	var ext: int = int(Probe.counts.get("extinct.starve", 0)) + int(Probe.counts.get("extinct.combat", 0)) \
		+ int(Probe.counts.get("extinct.other", 0))
	print("★⑤滅團 %d 次（餓 %d／戰 %d／其他 %d）" % [ext,
		int(Probe.counts.get("extinct.starve", 0)), int(Probe.counts.get("extinct.combat", 0)),
		int(Probe.counts.get("extinct.other", 0))])
	if ext == 0:
		print("   ★★★母體 0 ⇒ 這一格【不可判】——★不得把 0 讀成「煞車有效」（spec 的母體地板）")

	# ── ⑦perf（可慢不可卡：最壞單幀）──
	print("★⑦最壞單幀 %.3f s（tick=%d）｜>2 秒幀數 %d / %d" % [
		float(worst_us) / 1000000.0, worst_tick, SimRunner.frames_over_budget, SimRunner.frames_total])
	print("   ★同輪同儀器負載內才可比（今天買來的規則）")
	print("★fp = %s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=%d" % _fails)
	print("[TEST-SUITE-COMPLETE]")
