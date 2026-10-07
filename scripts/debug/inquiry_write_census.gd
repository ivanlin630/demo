extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-07）：打聽(gather_intel)到底有沒有記下東西。
# 入口：player_command_system.gd:1340-1388（_action_gather_intel → _action_confirm_gather_intel
# → InquirySystem.resolve_inquiry + SimMessageSystem._exchange_intel 寫belief）。
#
# 做法：第3/10/20/30天各建一個獨立世界(seed1337,從頭跑到那一天)，對玩家隊×每個目標隊×
# InquirySystem.get_options()回傳的每個可問題目各打聽一次，逐筆印(對象,題目,mode,寫入,
# 結果筆數,結果句)。★誠實限：同一checkpoint世界內，同批次內「後面問的」會受「前面問的」
# 影響belief/關係狀態(非完全互相獨立)，但每個checkpoint世界測完即丟、不會延續進之後的
# 量測，滿足「打聽不得改變之後的量測」。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/inquiry_write_census.gd

const SEED: int = 1337
const CHECKPOINT_DAYS: Array = [3, 10, 20, 30]


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d｜殺玩家=否" % SEED)

	var all_rows: Array = []
	var mode_dist: Dictionary = {}
	var written_gt0_n: int = 0
	var written_eq0_but_result_nonempty: Array = []

	for day in CHECKPOINT_DAYS:
		print("\n########## checkpoint day=%d ##########" % day)
		var rows: Array = _run_checkpoint(int(day))
		for r in rows:
			all_rows.append(r)
			var mode: String = String(r["mode"])
			mode_dist[mode] = int(mode_dist.get(mode, 0)) + 1
			if int(r["written"]) > 0:
				written_gt0_n += 1
			elif int(r["written"]) <= 0 and bool(r["result_nonempty"]):
				written_eq0_but_result_nonempty.append(r)

	print("\n========== 彙總 ==========")
	print("總打聽次數＝%d" % all_rows.size())
	var mkeys: Array = mode_dist.keys()
	mkeys.sort()
	print("mode 分佈：")
	for mk in mkeys:
		print("  %s ＝ %d" % [mk, int(mode_dist[mk])])
	print("寫入(written)>0 的比例＝%d／%d＝%.1f%%" \
		% [written_gt0_n, all_rows.size(), (100.0 * written_gt0_n / all_rows.size() if all_rows.size() > 0 else 0.0)])

	print("\n========== 寫入=0 但結果筆數>0 的案例（判是不是belief早已有同一筆重複）==========")
	print("共 %d 筆，列前5：" % written_eq0_but_result_nonempty.size())
	for i in range(min(5, written_eq0_but_result_nonempty.size())):
		var r2 = written_eq0_but_result_nonempty[i]
		print("  day=%d｜player→Team%d｜topic=%s｜mode=%s｜written=%d｜result=%s｜msg=%s" % [
			int(r2["day"]), int(r2["target"]), String(r2["topic"]), String(r2["mode"]),
			int(r2["written"]), str(r2["result_payload"]), String(r2["msg"])])

	var out_path: String = "docs/measurements/inquiry-write-census.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED,
		"total": all_rows.size(), "written_gt0_n": written_gt0_n, "mode_dist": mode_dist}))
	for r3 in all_rows:
		f.store_line(JSON.stringify(r3))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== inquiry_write_census DONE ===")
	quit(0)


func _run_checkpoint(day: int) -> Array:
	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for _i in range(day * WorldState.TICKS_PER_DAY):
		runner.advance_tick(ws, no_player)

	var player_tid: int = ws.get_player_team_id()
	if player_tid == -1 or not ws.teams.has(player_tid):
		print("[HALT-checkpoint] 找不到玩家隊,跳過 day=%d" % day)
		return []
	var pt: TeamData = ws.teams[player_tid]
	var pcs := PlayerCommandSystem.new()
	var iq := InquirySystem.new()

	var rows: Array = []
	var target_ids: Array = ws.teams.keys()
	target_ids.sort()
	for tid in target_ids:
		if int(tid) == player_tid:
			continue
		var tgt: TeamData = ws.teams[tid]
		var options: Array = iq.get_options(ws, pt, tgt)
		for opt in options:
			var choice: String = String(opt["id"])
			ws.player_state["gather_intel_npc_id"] = int(tid)
			ws.player_state["gather_intel_choice"] = choice
			var res: Dictionary = pcs._action_confirm_gather_intel(ws, int(tid), pt, player_tid)
			var payload: Dictionary = res.get("payload", {})
			var written: int = 0
			var mode: String = "n/a"
			# ask_faction_status 刻意不寫 belief、也不經 _exchange_intel 的 out dict，
			# 用固定 mode="self_knowledge" 標記，不跟其餘四題混進同一桶。
			if choice == "ask_faction_status":
				mode = "self_knowledge"
			else:
				# 重放同一組規則取得 mode/written（_action_confirm_gather_intel 內部的 out_gi
				# 沒有回傳出來，這裡用訊息句反推：3句固定句型，照 house 的「機械可判三句」原文比對）
				var msg: String = String(res.get("msg", ""))
				if msg == "他不願多說":
					mode = "silent"
				elif msg == "他也不知道":
					mode = "knows_nothing"
				elif msg.begins_with("他說了些事情"):
					mode = "told"
					var us: int = msg.find("記下 ")
					var ue: int = msg.find(" 筆")
					if us != -1 and ue != -1:
						written = int(msg.substr(us + 3, ue - (us + 3)))
			var result_nonempty: bool = _payload_nonempty(payload)
			rows.append({"day": day, "player": player_tid, "target": int(tid), "topic": choice,
				"mode": mode, "written": written, "result_nonempty": result_nonempty,
				"result_payload": payload, "msg": String(res.get("msg", ""))})
			print("  day=%d｜player→Team%-3d｜topic=%-18s｜mode=%-14s｜written=%d｜result_nonempty=%s｜msg=%s" \
				% [day, int(tid), choice, mode, written, str(result_nonempty), String(res.get("msg", ""))])
	return rows


func _payload_nonempty(p: Dictionary) -> bool:
	for k in p:
		var v = p[k]
		if v is Array:
			if not (v as Array).is_empty(): return true
		elif v != null:
			return true
	return false


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
