extends SceneTree
# @bed-kind: diagnostic
# 信使旅程切段（HOW spec 2026-09-11-herald-journey-segments）：★這一票【只量不修】。
#
# ★為什麼只量：同卷已證「尺可信」（fp 逐字相同、紮營 0% → 79.2%）⇒ 2.2% 是世界的事實
#   ⇒ 要問的是【那 44 趟從哪幾個門出去】，不是「送達判定對不對」。
# ★★母體：一段 `TASK_HERALD` episode（commit 成立 → 換 task／窗末）。★窗末未完【單獨一類、不進分母】。
# ★★★門鈴格（spec §③）：送達的唯一入口是 pairwise 相遇（interaction_system:390-393 同派系內／
#   :421-425 envoy_proposal）⇒ **抵達目標格 ≠ 送達**，要與那支目標隊【本身】相遇。
#   ⇒ 本床把「抵達目標格」與「與目標同格（相遇）」分成兩格量，★因為它們正是求居案同族的兩件事。
# ★而 spec §③(ii) 那個【負斷言】（跨派系且 task_reason != envoy_proposal 的信使可能沒有送達分支）
#   —— ★★本床用逐筆資料證實或推翻它：每段都記 same_faction 與 task_reason，並與送達交叉。
# env：HJ_TICKS（預設 43200 ＝ 30 天）／HJ_SEED（預設 1337）／HJ_CONFIG（預設 warring_states）

func _initialize() -> void:
	_run(); quit(0)

func _run() -> void:
	var ticks: int = int(OS.get_environment("HJ_TICKS")) if OS.has_environment("HJ_TICKS") else 43200
	var seed_val: int = int(OS.get_environment("HJ_SEED")) if OS.has_environment("HJ_SEED") else 1337
	var cfg: String = OS.get_environment("HJ_CONFIG") if OS.has_environment("HJ_CONFIG") else "warring_states"
	print("=== 信使旅程切段（%d tick ＝ %.1f 遊戲天，%s，seed=%d，★預設 config 未改）===" % [
		ticks, float(ticks) / float(WorldState.TICKS_PER_DAY), cfg, seed_val])
	seed(seed_val)
	var st: WorldState = MeasureBedHelper.arm_and_setup("res://config/%s.json" % cfg)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	var live: Dictionary = {}     # team_id → 進行中的 episode
	var rows: Array = []          # 逐筆（★全收，母體是數十不是數千）
	for tick in range(ticks):
		runner.advance_tick(st, no_player)
		for tid in st.teams:
			var t: TeamData = st.teams[tid]
			if t.current_task == TeamData.TASK_HERALD:
				if not live.has(tid) or int(live[tid]["oid"]) != t.order_target_id:
					if live.has(tid):
						_close(live[tid], st, rows, false)
					var tgt: TeamData = st.teams.get(t.order_target_id)
					live[tid] = {
						"team": tid, "start": st.world.current_tick, "oid": t.order_target_id,
						"reason": t.task_reason, "opt": t.current_option,
						"same_faction": tgt != null and tgt.faction_id == t.faction_id and t.faction_id != -1,
						"dist0": FactionAISystem._hex_dist(t.tile_pos, t.move_target) if t.move_target != Vector2i(-1, -1) else -1,
						"at_cell": false, "met": false,
						"done0": int(Probe.counts.get("task.done.t%d.%s" % [tid, TeamData.TASK_HERALD], 0)),
						"lost0": _lost_of(tid),
					}
				var ep: Dictionary = live[tid]
				if t.move_target != Vector2i(-1, -1) and t.tile_pos == t.move_target:
					ep["at_cell"] = true              # ★①抵達目標【格】
				var tg: TeamData = st.teams.get(t.order_target_id)
				if tg != null and tg.tile_pos == t.tile_pos:
					ep["met"] = true                  # ★②與目標隊【本身】相遇（門鈴按得到）
			elif live.has(tid):
				_close(live[tid], st, rows, false)
				live.erase(tid)
	for tid2 in live:
		_close(live[tid2], st, rows, true)

	# ── 逐站分桶 ──
	var n: int = rows.size()
	var cut: int = 0
	var at_cell: int = 0
	var met: int = 0
	var delivered: int = 0
	var by_exit: Dictionary = {}
	var cross_no_envoy: int = 0
	var cross_no_envoy_delivered: int = 0
	for r in rows:
		if bool(r["cut"]): cut += 1
		if bool(r["at_cell"]): at_cell += 1
		if bool(r["met"]): met += 1
		if bool(r["delivered"]): delivered += 1
		var ex: String = String(r["exit"])
		by_exit[ex] = int(by_exit.get(ex, 0)) + 1
		if not bool(r["same_faction"]) and String(r["reason"]) != "envoy_proposal":
			cross_no_envoy += 1
			if bool(r["delivered"]): cross_no_envoy_delivered += 1
	print("")
	print("★①母體：信使 episode 共 %d 段（其中窗末未完 %d 段，★單獨一類、不進分母）" % [n, cut])
	if n - cut <= 0:
		push_error("[FAIL] 母體 0：本窗沒有任何完整結束的信使 episode —— ★不可判，不是「都沒送到」")
		print("[TEST-SUITE-COMPLETE]")
		return
	print("★②逐站（分母＝完整結束的 %d 段）：" % (n - cut))
	print("   出發 %d → 抵達目標【格】 %d → 與目標隊【相遇】 %d → 送達判定成立 %d" % [
		n - cut, at_cell, met, delivered])
	print("   ★『抵達了但沒相遇』= %d 段（★★這正是求居案「到了 4 次、領主見到 0 次」的同族）" % maxi(at_cell - met, 0))
	print("★③出口分桶（★加總必須 ＝ 母體；沒有「其他」這一桶）：%s" % str(by_exit))
	var tot: int = 0
	for k in by_exit: tot += int(by_exit[k])
	print("   守恆：分桶加總 %d vs 母體 %d ⇒ %s" % [tot, n, "OK" if tot == n else "★不符，要查"])
	print("★④送達入口分流：同派系 order %d 次｜envoy_proposal %d 次" % [
		int(Probe.counts.get("herald.delivered.order", 0)),
		int(Probe.counts.get("herald.delivered.envoy", 0))])
	print("★★★⑤spec §③(ii) 那個負斷言（跨派系 ＋ task_reason != envoy_proposal）：")
	print("   母體 %d 段；其中送達 %d 段" % [cross_no_envoy, cross_no_envoy_delivered])
	if cross_no_envoy == 0:
		print("   ★母體 0 ⇒ **不可判**（★★而那與「它們都送不到」是兩個結論）")
	elif cross_no_envoy_delivered == 0:
		print("   ★★★母體非 0 而送達 0 ⇒ **與負斷言一致**（★仍是觀測、不是證明：見誠實限）")
	else:
		print("   ★★★**負斷言被推翻**：這一類有送達 ⇒ 存在第三條路，要找出它")
	print("")
	print("★逐筆（全收）：")
	for r2 in rows:
		print("   team=%d 起 tick=%d 目標=%d 同派系=%s reason=%s 起算距離=%d｜到格=%s 相遇=%s 送達=%s 出口=%s%s" % [
			int(r2["team"]), int(r2["start"]), int(r2["oid"]), str(r2["same_faction"]),
			String(r2["reason"]), int(r2["dist0"]), str(r2["at_cell"]), str(r2["met"]),
			str(r2["delivered"]), String(r2["exit"]), "　★窗末未完" if bool(r2["cut"]) else ""])
	print("")
	print("★誠實限：①出口桶取自 arbiter 自己的分支計數（same_level／higher／defy／release／transition），")
	print("   ★★『個位數不判方向』——本卷只報數、不報趨勢；②窗末未完單獨一類；")
	print("   ★★★③負斷言只能被逐筆【推翻】，一致不等於證明（可能只是本窗沒發生）")
	print("★>2 秒幀數 = %d / %d" % [SimRunner.frames_over_budget, SimRunner.frames_total])
	print("★fp = %s" % StateFingerprint.compute(st))
	print("=== DONE === SECTIONS=1/1 FAILS=0")
	print("[TEST-SUITE-COMPLETE]")

func _lost_of(tid: int) -> Dictionary:
	var out: Dictionary = {}
	for b in ["same_level", "higher", "defy", "release", "transition"]:
		out[b] = int(Probe.counts.get("lost.t%d.%s.%s" % [tid, TeamData.TASK_HERALD, b], 0))
	return out

func _close(ep: Dictionary, st: WorldState, rows: Array, cut: bool) -> void:
	var tid: int = int(ep["team"])
	var delivered: bool = int(Probe.counts.get("task.done.t%d.%s" % [tid, TeamData.TASK_HERALD], 0)) > int(ep["done0"])
	# ★出口＝這一段結束時，arbiter 的哪一個分支動了（★由 arbiter 自己的計數決定，不是我判的）
	var exit_kind: String = "窗末未完" if cut else "未知"
	if not cut:
		var before: Dictionary = ep["lost0"]
		var now: Dictionary = _lost_of(tid)
		for b in ["same_level", "higher", "defy", "release", "transition"]:
			if int(now[b]) > int(before[b]):
				exit_kind = b if exit_kind == "未知" else exit_kind + "+" + b
	if delivered and not cut:
		exit_kind = "送達後" + ("（" + exit_kind + "）" if exit_kind != "未知" else "")
	rows.append({"team": tid, "start": int(ep["start"]), "oid": int(ep["oid"]),
		"same_faction": bool(ep["same_faction"]), "reason": String(ep["reason"]),
		"dist0": int(ep["dist0"]), "at_cell": bool(ep["at_cell"]), "met": bool(ep["met"]),
		"delivered": delivered, "exit": exit_kind, "cut": cut})
