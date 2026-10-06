extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-06）：
# ①Q-raid：Team11 掠奪那段四欄（Probe.sample_window 對準 team=11, tick 13350-13400）
# ②施工：construct.stall／construct.start（outpost_system.gd）
# ③wall.reject_*（outpost_system.gd，bump_pt 全域+per-team，無 tick/sample）
# ④village.build_fired（outpost_system.gd:678，純 bump 全域計數）＋同窗「誰還在宣稱建設」
# ⑤move_target 相鄰卻不動：全世界普查，≥60 tick(1小時) 零位移才算一段，
#   逐 tick 複查三條已知阻擋條件（複製自 movement_system.gd:process 的真實邏輯，純讀不猜）：
#   ①resident_lock(TAG_PRODUCE+_is_resident_team)／①combat_block(combat_target!=-1)／
#   ①insufficient_time_budget(move_tick_acc < move_cost_pure 重算值，含日夜速度)／
#   ①flee_special(current_task==FLEE，邏輯特殊不細分，仍算①有理由非②)
#   三條都不成立才算②真無理由；若某段完全無法判（目前沒有，三條涵蓋 process() 的全部 continue 點）
#   才算③沒有儀器——★本床目前判準涵蓋 process() 讀到的所有 continue 分支，没有③的情況，
#   如果未來 process() 新增我沒讀到的 continue 分支，這裡會把它誤判成②，交件裡會註明這個誠實限。
#
# ★Probe.sample_window 是新 Probe 表面，但純過濾既有 samples（不讀 state、不呼 rand，見
# probe_stats.gd:129-134 自己的註解）；沿用今天已驗證多次的「Probe 開/關逐位相同」結論，
# 不重跑整輪 A/B（同一個已證安全的機制家族，新增的只是一個 filter，不是新讀點）。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/ticketA_taps_and_movestuck.gd

const SEED: int = 1337
const TOTAL_TICKS: int = 30 * 1440
const STUCK_MIN_TICKS: int = 60   # 1 小時


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d" % SEED)

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	Probe.sample_window["raid.composition"] = {"team": 11, "tick_min": 13350, "tick_max": 13400}

	var day_night := DayNightSystem.new()
	var fai := FactionAISystem.shared()

	# ── move_target 卡住：逐隊狀態機 ──────────────────────────────────────────────
	var stuck_start: Dictionary = {}     # team_id → tick（本段卡住開始）
	var stuck_reasons: Dictionary = {}   # team_id → Dictionary（本段內見過的 reason 集合）
	var stuck_episodes: Array = []       # 完結的段
	var claimed_build_teams_global: Dictionary = {}   # 全程 current_option∈{建設,紮根} 的隊

	for _i in range(TOTAL_TICKS):
		runner.advance_tick(ws, no_player)
		var cur_tick: int = ws.world.current_tick
		var time_mult: float = day_night.get_speed_mult(ws)
		for tid in ws.teams.keys():
			var t: TeamData = ws.teams[tid]
			if String(t.current_option) == "建設" or String(t.current_option) == "紮根":
				claimed_build_teams_global[int(tid)] = true

			var adjacent: bool = t.move_target != Vector2i(-1, -1) \
				and _hex_dist(t.tile_pos, t.move_target) == 1
			var prev: Dictionary = stuck_start.get(tid, {})
			if adjacent:
				if prev.is_empty():
					stuck_start[tid] = {"tick": cur_tick, "pos": t.tile_pos, "target": t.move_target}
					stuck_reasons[tid] = {}
				elif prev["pos"] != t.tile_pos or prev["target"] != t.move_target:
					# 位置動了或目標變了 ⇒ 這段結束（若夠長記一筆），重新起算
					_flush_stuck(stuck_episodes, tid, prev, stuck_reasons.get(tid, {}), cur_tick - 1)
					stuck_start[tid] = {"tick": cur_tick, "pos": t.tile_pos, "target": t.move_target}
					stuck_reasons[tid] = {}
				else:
					# 同一段持續：複查三條已知阻擋條件
					var r: Dictionary = stuck_reasons.get(tid, {})
					if t.tags.has(TeamData.TAG_PRODUCE) and fai._is_resident_team(ws, t) \
							and t.current_task not in [TeamData.TASK_FLEE, TeamData.TASK_JOIN,
								TeamData.TASK_MERGE, TeamData.TASK_REVOLT, TeamData.TASK_MIGRATE]:
						r["①resident_lock"] = true
					if t.combat_target != -1:
						r["①combat_block"] = true
					if t.current_task == TeamData.TASK_FLEE:
						r["①flee_special"] = true
					var cost: int = MovementSystem.move_cost_pure(ws, t, time_mult, null)
					if t.move_tick_acc < cost:
						r["①insufficient_time_budget"] = true
					if r.is_empty():
						r["②true_no_reason_this_tick"] = true
					stuck_reasons[tid] = r
			else:
				if not prev.is_empty():
					_flush_stuck(stuck_episodes, tid, prev, stuck_reasons.get(tid, {}), cur_tick - 1)
					stuck_start.erase(tid)
					stuck_reasons.erase(tid)

	# 跑完仍卡著的段也收尾
	for tid in stuck_start.keys():
		_flush_stuck(stuck_episodes, tid, stuck_start[tid], stuck_reasons.get(tid, {}), TOTAL_TICKS)

	print("\n########## ①Q-raid（Team11, tick 13350-13400）##########")
	var raid_samples: Array = Probe.samples.get("raid.composition", [])
	var raid_dropped: int = int(Probe.sample_window_dropped.get("raid.composition", 0))
	print("[Q-raid] 窗內收到 %d 筆（窗外擋掉 %d 筆——證明窗真的在作用，不是「窗內本來就只有這些」）" \
		% [raid_samples.size(), raid_dropped])
	for i in range(raid_samples.size()):
		var row: Dictionary = raid_samples[i]
		print("  #%d｜tick=%s｜team=%s｜原始util(drive)=%s｜需求層加權後=%s｜人格調製後=%s｜最終合成=%s" % [
			i, str(row.get("tick", "?")), str(row.get("team", "?")),
			str(row.get("drive", "?")), str(row.get("after_weight", "?")),
			str(row.get("after_coeff", "?")), str(row.get("final", "?"))])

	print("\n########## ②施工 construct.start / construct.stall ##########")
	print("[construct] start 計數=%d（start_task_not_build=%d）｜stall 計數=%d" % [
		int(Probe.counts.get("construct.start", 0)), int(Probe.counts.get("construct.start_task_not_build", 0)),
		int(Probe.counts.get("construct.stall", 0))])
	var start_samples: Array = Probe.samples.get("construct.start", [])
	var stall_samples: Array = Probe.samples.get("construct.stall", [])
	print("[construct.start] 樣本 %d 筆（team0 (2,13)／team3 (11,5) 若在就看得到）：" % start_samples.size())
	for row in start_samples:
		print("  tick=%s｜tile=%s｜ct_id=%s｜team=%s｜action=%s" % [
			str(row.get("tick")), str(row.get("tile")), str(row.get("ct_id")),
			str(row.get("team")), str(row.get("action"))])
	print("[construct.stall] 樣本 %d 筆：" % stall_samples.size())
	for row in stall_samples:
		print("  tick=%s｜tile=%s｜ct_id=%s｜ct_task=%s｜ct_pos=%s｜ct_reason=%s" % [
			str(row.get("tick")), str(row.get("tile")), str(row.get("ct_id")),
			str(row.get("ct_task")), str(row.get("ct_pos")), str(row.get("ct_reason"))])

	print("\n########## ③wall.reject_* ##########")
	var wall_keys: Array = []
	for k in Probe.counts.keys():
		if String(k).begins_with("wall.reject_"):
			wall_keys.append(String(k))
	wall_keys.sort()
	for k in wall_keys:
		print("  %s = %d" % [k, int(Probe.counts[k])])

	print("\n########## ④village.build_fired（全域計數，無 team 維度）##########")
	print("[village.build_fired] 全域=%d" % int(Probe.counts.get("village.build_fired", 0)))
	var still_claiming: Array = claimed_build_teams_global.keys()
	still_claiming.sort()
	print("[village.build_fired] ★全程(30天)曾宣稱建設/紮根的隊=%s（%d 支）——這個全域數不能直接歸\
給某一隊，讀的人要自己對照這張名單；若只剩 1 隊還在宣稱，這個數才能近似歸給它" \
		% [str(still_claiming), still_claiming.size()])

	print("\n########## ⑤move_target 相鄰卻不動（全世界，≥%d tick）##########" % STUCK_MIN_TICKS)
	print("[母體邊界] 普查全世界每一隊每一段「move_target 設定且與 tile_pos 相鄰(hex距離=1)且\
期間 tile_pos／move_target 皆未變」的連續區段，≥%d tick 才記一筆。" % STUCK_MIN_TICKS)
	stuck_episodes.sort_custom(func(a, b): return int(a["duration"]) > int(b["duration"]))
	print("[⑤] 共 %d 段（≥1小時）。逐段：" % stuck_episodes.size())
	var cat_count: Dictionary = {}
	for ep in stuck_episodes:
		var reasons: Array = (ep["reasons"] as Dictionary).keys()
		reasons.sort()
		var cat: String = str(reasons) if not reasons.is_empty() else "③沒有任何已知①條件成立也沒有②標記（理論上不會發生，見下誠實限）"
		cat_count[cat] = int(cat_count.get(cat, 0)) + 1
		print("  team=%d｜tick=%d–%d(持續%d)｜pos=%s｜target=%s｜本段出現過的理由=%s" % [
			int(ep["team"]), int(ep["start"]), int(ep["end"]), int(ep["duration"]),
			str(ep["pos"]), str(ep["target"]), str(reasons)])
	print("\n[⑤] 分類統計（理由集合 → 段數）：")
	for cat in cat_count.keys():
		print("  %s ｜ %d 段" % [cat, int(cat_count[cat])])
	var pure_no_reason: int = 0
	for ep in stuck_episodes:
		var rs: Dictionary = ep["reasons"]
		if rs.size() == 1 and rs.has("②true_no_reason_this_tick"):
			pure_no_reason += 1
	print("[⑤] ★★★純②（整段從頭到尾三條已知①條件一次都沒成立過）的段數＝%d（這才是真正要開票的那種；\
段落只要出現過任一①理由就不算純②，哪怕只出現一次——因為那代表至少有一刻是「有理由」，\
不是整段都無理由）。" % pure_no_reason)
	print("[⑤] ★誠實限：①的三條複製自 movement_system.gd:process() 讀到的 continue 分支（resident鎖／\
combat_target／move_tick_acc<cost／FLEE特殊分支）。本床判準刻意保守：只要三條有一條成立就算①，\
不算②——如果 process() 還有我沒讀到的分支，本床會把那類段誤歸進②（高估②，不會低估），\
讀的人要知道②的段數是『上限』不是『confirmed』。")

	var out_path: String = "docs/measurements/ticketA-taps-and-movestuck.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED}))
	for row in raid_samples:
		f.store_line(JSON.stringify({"kind": "Q_raid", "row": row}))
	for ep in stuck_episodes:
		f.store_line(JSON.stringify({"kind": "move_stuck", "team": ep["team"], "start": ep["start"],
			"end": ep["end"], "duration": ep["duration"], "pos": [ep["pos"].x, ep["pos"].y],
			"target": [ep["target"].x, ep["target"].y], "reasons": (ep["reasons"] as Dictionary).keys()}))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== ticketA_taps_and_movestuck DONE ===")
	quit(0)


func _flush_stuck(episodes: Array, tid, start_info: Dictionary, reasons: Dictionary, end_tick: int) -> void:
	var start_tick: int = int(start_info["tick"])
	var duration: int = end_tick - start_tick + 1
	if duration >= STUCK_MIN_TICKS:
		episodes.append({"team": int(tid), "start": start_tick, "end": end_tick, "duration": duration,
			"pos": start_info["pos"], "target": start_info["target"], "reasons": reasons.duplicate()})


func _hex_dist(a: Vector2i, b: Vector2i) -> int:
	return FactionAISystem._hex_dist(a, b)


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
