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
	# ★★★母體紀律（★我第一版在這裡犯了今天一直在抓的那個錯）：
	#   逐站計數要與【它自己的分母】同一批 —— 第一版用「全部 145 段」數到場／送達，
	#   卻除以「完整結束 23 段」⇒ 132 > 23 ⇒ ★**比率大於 1 的表，是母體錯配的指紋**。
	#   ⇒ 這一版：**closed（完整結束）與 all（含窗末未完）兩組各自印，並各自標分母**。
	# ★★而還要再切一刀：**起算距離 0** 與 **起算距離 > 0** 是兩群完全不同的信使
	#   （前者生成時就站在目標身上 ⇒ 當場送達；後者才是「旅程」）——
	#   ★★★把它們混在一個平均裡，會把「遠的送不到」洗成「大部分送到了」。
	var groups: Dictionary = {"closed_far": [], "closed_near": [], "open_far": [], "open_near": []}
	for r in rows:
		var kk: String = ("open_" if bool(r["cut"]) else "closed_") + ("near" if int(r["dist0"]) <= 0 else "far")
		(groups[kk] as Array).append(r)
	print("")
	print("★①母體：信使 episode 共 %d 段（完整結束 %d／窗末未完 %d）" % [
		n, n - (groups["open_far"] as Array).size() - (groups["open_near"] as Array).size(),
		(groups["open_far"] as Array).size() + (groups["open_near"] as Array).size()])
	print("   ★分四群：起算距離 >0 ＝【真的有旅程】／起算距離 0 ＝【生成時就站在目標身上】")
	for gk in ["closed_far", "closed_near", "open_far", "open_near"]:
		var g: Array = groups[gk]
		var at_c: int = 0; var mt: int = 0; var dl: int = 0
		for r2 in g:
			if bool(r2["at_cell"]): at_c += 1
			if bool(r2["met"]): mt += 1
			if bool(r2["delivered"]): dl += 1
		var rate: String = "不可判(母體0)" if g.is_empty() else ("%.1f%%" % (100.0 * float(dl) / float(g.size())))
		print("   %-12s 母體 %3d ｜到格 %3d｜相遇 %3d｜送達 %3d ｜送達率 %s" % [gk, g.size(), at_c, mt, dl, rate])
	print("   ★『抵達了但沒相遇』只在【有旅程】那一群有意義 —— ★★而那正是求居案的同族（到了但沒見到人）")
	var by_exit: Dictionary = {}
	var cross_no_envoy: int = 0
	var cross_no_envoy_delivered: int = 0
	for r3 in rows:
		var ex: String = String(r3["exit"])
		by_exit[ex] = int(by_exit.get(ex, 0)) + 1
		if not bool(r3["same_faction"]) and String(r3["reason"]) != "envoy_proposal":
			cross_no_envoy += 1
			if bool(r3["delivered"]): cross_no_envoy_delivered += 1
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
		print("   ★★★母體非 0 而送達 0 ⇒ **與負斷言一致**（★仍是觀測、不是證明）")
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
