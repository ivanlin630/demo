extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-07）：S1(無勢力不再被當同勢力,12處same_faction)改了世界什麼。
# 兩棵樹各跑一次這支床（內容逐字相同,複製進兩個worktree），比對輸出。
#
# ①真隊(faction_id!=-1)／無勢力隊(faction_id==-1) 死亡時的cause分類(starve/combat/other)
#   ★複製faction_ai_system.gd既有extinct.*判準(famine_days>0→starve,combat_target!=-1→combat,
#   否則other)，外部觀察不靠Probe counter(避免兩棵樹的tap本身也在S1影響範圍內的風險)。
# ②無勢力隊之間：combat_start/掠奪(raid_out)/外交訊息(alliance/tribute/invite)事件數
# ③據點易主次數(tile.outpost_owner 轉移，逐tick watch)
# ④每項列前3個具體實例(team id, tick)
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/s1_faction_minus_one_world_effect.gd

const SEED: int = 1337
const TOTAL_TICKS: int = 30 * 1440


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d｜殺玩家=否" % SEED)

	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	Probe.arm()

	var prev_teams: Dictionary = {}   # team_id → true（存活中）
	var prev_faction: Dictionary = {}   # team_id → 上次看到的 faction_id（供死亡時讀最後值）
	var prev_task_snap: Dictionary = {}   # team_id → {famine_days, combat_target}

	for tid0 in ws.teams.keys():
		prev_teams[int(tid0)] = true
		var t0: TeamData = ws.teams[tid0]
		prev_faction[int(tid0)] = int(t0.faction_id)
		prev_task_snap[int(tid0)] = {"famine_days": t0.famine_days, "combat_target": t0.combat_target}

	var death_events: Array = []   # {tick, team, faction_at_death, cause}
	var msg_seen: Dictionary = {}
	var faction_pair_msgs: Array = []   # {tick, type, a, b, description}（兩邊都faction_id==-1時）
	var owner_prev: Dictionary = {}   # tile_id → outpost_owner
	var owner_change_events: Array = []   # {tick, tile_pos, from, to}

	for tid00 in ws.world.tiles.keys():
		owner_prev[tid00] = ws.world.tiles[tid00].outpost_owner

	for _i in range(TOTAL_TICKS):
		runner.advance_tick(ws, no_player)
		var cur_tick: int = ws.world.current_tick

		# ── ①死亡偵測 ──────────────────────────────────────────────────────────
		for tid in prev_teams.keys():
			if not ws.teams.has(tid) and bool(prev_teams[tid]):
				var snap: Dictionary = prev_task_snap.get(tid, {})
				var cause: String = "other"
				if float(snap.get("famine_days", 0.0)) > 0.0:
					cause = "starve"
				elif int(snap.get("combat_target", -1)) != -1:
					cause = "combat"
				death_events.append({"tick": cur_tick, "team": int(tid),
					"faction_at_death": int(prev_faction.get(tid, -999)), "cause": cause})
				prev_teams[tid] = false
		for tid2 in ws.teams.keys():
			var t2: TeamData = ws.teams[tid2]
			prev_teams[int(tid2)] = true
			prev_faction[int(tid2)] = int(t2.faction_id)
			prev_task_snap[int(tid2)] = {"famine_days": t2.famine_days, "combat_target": t2.combat_target}

		# ── ②無勢力隊之間的互動訊息（combat_start/tribute/diplomacy等，兩邊都faction==-1） ──
		for msg in ws.global_messages:
			var mkey: String = "%d:%d" % [int(msg.origin_tick), int(msg.id)]
			if msg_seen.has(mkey):
				continue
			msg_seen[mkey] = true
			var mtype: String = String(msg.type)
			if not ["combat_start", "combat_end", "tribute", "diplomacy", "revolt", "flee",
					"subjugate", "faction_establish", "captives_taken"].has(mtype):
				continue
			var a_id: int = int(msg.origin_team_id)
			var b_id: int = -999
			for pk in msg.params.keys():
				var pks: String = String(pk)
				if pks == "target" or pks == "origin":
					var v = msg.params[pk]
					if typeof(v) == TYPE_STRING and v.is_valid_int():
						b_id = int(v)
					elif typeof(v) == TYPE_INT:
						b_id = int(v)
			if b_id == -999 or b_id == a_id:
				continue
			var ta: TeamData = ws.teams.get(a_id)
			var tb: TeamData = ws.teams.get(b_id)
			if ta == null or tb == null:
				continue
			if int(ta.faction_id) == -1 and int(tb.faction_id) == -1:
				faction_pair_msgs.append({"tick": int(msg.origin_tick), "type": mtype,
					"a": a_id, "b": b_id, "description": msg.description})

		# ── ③據點易主 ───────────────────────────────────────────────────────────
		for tile_id in ws.world.tiles.keys():
			var tile: HexTileData = ws.world.tiles[tile_id]
			var prev_owner: int = int(owner_prev.get(tile_id, -1))
			if int(tile.outpost_owner) != prev_owner:
				owner_change_events.append({"tick": cur_tick, "tile": [tile.tile_pos.x, tile.tile_pos.y],
					"from": prev_owner, "to": int(tile.outpost_owner)})
				owner_prev[tile_id] = int(tile.outpost_owner)

	# ── 彙總輸出 ──────────────────────────────────────────────────────────────
	print("\n========== ①消失路徑：先分真死亡(extinct.team.<id>) vs 併入/解散(MEASURER_TEMP.*) ==========")
	print("（★MEASURER_TEMP.* 是臨時tap，只在本worktree，不會進任何commit——systems授權，用來\
分辨 state.teams 移除的三個寫入點：faction_ai_system.gd:2935目標村消失解散／:2951移民抵達併入\
／:5166真死亡）")
	var path_by_group: Dictionary = {}   # "has_faction|path" → n
	var real_death_events: Array = []
	for d in death_events:
		var grp: String = "has_faction" if int(d["faction_at_death"]) != -1 else "no_faction"
		var tid_d: int = int(d["team"])
		var path: String = _classify_path(tid_d)
		if path == "real_death":
			real_death_events.append(d)
		var key: String = "%s|%s" % [grp, path]
		path_by_group[key] = int(path_by_group.get(key, 0)) + 1
	var pkeys: Array = path_by_group.keys()
	pkeys.sort()
	for k in pkeys:
		print("  %s ＝ %d" % [k, int(path_by_group[k])])
	print("  消失事件總數＝%d｜migrant.arrived(全域)＝%d" \
		% [death_events.size(), int(Probe.counts.get("migrant.arrived", 0))])

	print("\n========== ①b 真死亡(real_death)才分 starve/combat/other ==========")
	var cause_by_group: Dictionary = {}
	for d in real_death_events:
		var grp: String = "has_faction" if int(d["faction_at_death"]) != -1 else "no_faction"
		var key: String = "%s|%s" % [grp, String(d["cause"])]
		cause_by_group[key] = int(cause_by_group.get(key, 0)) + 1
	var ckeys: Array = cause_by_group.keys()
	ckeys.sort()
	for k in ckeys:
		print("  %s ＝ %d" % [k, int(cause_by_group[k])])
	print("  真死亡事件總數＝%d" % real_death_events.size())
	print("  前3個實例（消失事件，含路徑分類）：")
	for i in range(min(3, death_events.size())):
		var d2 = death_events[i]
		var tid_d2: int = int(d2["team"])
		var path2: String = "unknown"
		path2 = _classify_path(tid_d2)
		print("    tick=%d｜team=%d｜faction_at_death=%d｜path=%s｜cause(若real_death才有意義)=%s" \
			% [int(d2["tick"]), tid_d2, int(d2["faction_at_death"]), path2, String(d2["cause"])])

	print("\n========== ②無勢力隊之間的互動事件（combat_start/tribute/diplomacy等） ==========")
	var by_type: Dictionary = {}
	for m in faction_pair_msgs:
		var mt: String = String(m["type"])
		by_type[mt] = int(by_type.get(mt, 0)) + 1
	var tkeys: Array = by_type.keys()
	tkeys.sort()
	for tk in tkeys:
		print("  %s ＝ %d" % [tk, int(by_type[tk])])
	print("  總數＝%d" % faction_pair_msgs.size())
	print("  前3個實例：")
	for i2 in range(min(3, faction_pair_msgs.size())):
		var m2 = faction_pair_msgs[i2]
		print("    tick=%d｜type=%s｜a=team%d｜b=team%d｜%s" \
			% [int(m2["tick"]), String(m2["type"]), int(m2["a"]), int(m2["b"]), String(m2["description"])])

	print("\n========== ③據點易主次數 ==========")
	print("  總易主次數＝%d" % owner_change_events.size())
	print("  前3個實例：")
	for i3 in range(min(3, owner_change_events.size())):
		var o = owner_change_events[i3]
		print("    tick=%d｜tile=%s｜from=%d｜to=%d" % [int(o["tick"]), str(o["tile"]), int(o["from"]), int(o["to"])])

	print("\n========== 既有Probe計數對照（convert_via_settle 全域，無team-pair細節） ==========")
	print("  convert_via_settle ＝ %d" % int(Probe.counts.get("convert_via_settle", 0)))
	print("  extinct.starve=%d｜extinct.combat=%d｜extinct.other=%d（production既有counter,\
全域不分faction,僅供交叉核對）" % [int(Probe.counts.get("extinct.starve", 0)),
		int(Probe.counts.get("extinct.combat", 0)), int(Probe.counts.get("extinct.other", 0))])

	var out_path: String = "docs/measurements/s1-faction-minus-one-world-effect-%s.jsonl" % tree_sha
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED}))
	for d3 in death_events:
		f.store_line(JSON.stringify({"kind": "death", "row": d3}))
	for m3 in faction_pair_msgs:
		f.store_line(JSON.stringify({"kind": "faction_pair_msg", "row": m3}))
	for o3 in owner_change_events:
		f.store_line(JSON.stringify({"kind": "owner_change", "row": o3}))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== s1_faction_minus_one_world_effect DONE ===")
	quit(0)


func _classify_path(tid: int) -> String:
	if Probe.counts.has("extinct.team.%d" % tid): return "real_death"
	if Probe.counts.has("MEASURER_TEMP.arrived.team.%d" % tid): return "migrant_arrived_merged"
	if Probe.counts.has("MEASURER_TEMP.disband.team.%d" % tid): return "target_gone_disbanded"
	if Probe.counts.has("MEASURER_TEMP.beast_cleanup.team.%d" % tid): return "beast_hunted_cleanup"
	if Probe.counts.has("MEASURER_TEMP.massacre.team.%d" % tid): return "massacre_village_erased"
	if Probe.counts.has("MEASURER_TEMP.subteam_absorbed.team.%d" % tid): return "subteam_absorbed_by_parent"
	return "unknown"


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
