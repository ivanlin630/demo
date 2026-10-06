extends SceneTree
# @bed-kind: diagnostic
# ★量測員派工（systems 2026-10-06，R² CLEAN `8b838fbe3`）：A1 建設「為什麼沒開工」
# spec：docs/superpowers/specs/2026-10-06-a1-why-was-build-never-started-tap-HOW.md
#
# P0：Team0／Team3 的 home_count（state.own_outpost_count）
# T1：每日邊界，TASK_BUILD 的隊分四類 (i)腳下工地屬本隊 (ii)屬別隊 (iii)腳下沒工地 (iv)以上皆非
# P4：陽性對照——佈置一支「選了建設、腳下沒工地」的隊，驗證必入 (iii)
# 先驗：Probe 開/關，fp 與決策序列逐位相同
# T2′（既有床 construction_funnel_bed.gd 已另跑，Team3 100% 落在
#   resolver.empty_no_own_outpost／goal.readd_blocked_no_otile；Team0 落在
#   resolver.empty_wrong_outpost_type／empty_pop_below_min——結論見 handback，本床不重做）
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/a1_build_never_started.gd

const SEED: int = 1337
const TOTAL_TICKS: int = 30 * 1440


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d｜殺玩家=否" % SEED)

	print("\n########## PASS A（Probe=OFF，對照組）##########")
	var a: Dictionary = _run_pass(false)
	print("\n########## PASS B（Probe=ON）##########")
	var b: Dictionary = _run_pass(true)

	print("\n========== 先驗：Probe 開/關是否改世界 ==========")
	var match_hash: bool = String(a["decision_hash"]) == String(b["decision_hash"])
	var match_fp: bool = String(a["world_fp"]) == String(b["world_fp"])
	print("[COMPARE] 決策hash一致=%s｜世界fp一致=%s" % [str(match_hash), str(match_fp)])
	if not (match_hash and match_fp):
		print("[HALT] 不逐位相同，停")
		quit(1)
		return
	print("[COMPARE] ★逐位元組相同，放行。")

	print("\n========== P0：Team0／Team3 的 home_count ==========")
	print("  Team0 home_count=%d" % int(b["home_count"].get(0, -999)))
	print("  Team3 home_count=%d" % int(b["home_count"].get(3, -999)))
	print("（home_count==0 ⇒ 基建評估層的 guard_no_own_outpost 必擋在第一關，確認見\
construction_funnel_bed.gd 本輪另跑的結果：infra 家族 Team0/Team3 整段零出現）")

	print("\n========== T1：每日 TASK_BUILD 四類（互斥窮盡） ==========")
	print("day｜TASK_BUILD隊數｜(i)own｜(ii)other｜(iii)no_site｜(iv)other｜對帳")
	var days_sorted: Array = (b["t1_by_day"] as Dictionary).keys()
	days_sorted.sort()
	for day in days_sorted:
		var row: Dictionary = b["t1_by_day"][day]
		var sum4: int = int(row["i"]) + int(row["ii"]) + int(row["iii"]) + int(row["iv"])
		var total: int = int(row["total"])
		print("%3d｜%6d｜%4d｜%4d｜%4d｜%4d｜%s" % [int(day), total, int(row["i"]), int(row["ii"]),
			int(row["iii"]), int(row["iv"]), ("✅" if sum4 == total else "❌對不上")])
	print("\n[T1-team0/3] Team0／Team3 若曾 current_task==TASK_BUILD，逐日落在哪一類：")
	for row2 in b["t1_team03_rows"]:
		print("  day=%d｜team=%d｜類別=%s｜ct_id=%s" % [int(row2["day"]), int(row2["team"]), String(row2["class"]), str(row2["ct_id"])])
	if (b["t1_team03_rows"] as Array).is_empty():
		print("  ★Team0／Team3 在這 30 天裡【從未】current_task==TASK_BUILD（可能一直是別的 task，\
或從未被決策引擎 commit 到「建設」這個 option）——這本身也是答案的一部分，不是空集合沒意義。")

	print("\n========== P4：陽性對照 ==========")
	print("  佈置：強制一支現有隊 current_task=TASK_BUILD、所在 tile 的 construction_team_id 設為 -1")
	print("  結果：%s" % String(b["p4_result"]))

	var out_path: String = "docs/measurements/a1-build-never-started.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED,
		"fp_match": match_fp, "hash_match": match_hash,
		"home_count_team0": b["home_count"].get(0, -999), "home_count_team3": b["home_count"].get(3, -999)}))
	for day in days_sorted:
		f.store_line(JSON.stringify({"kind": "T1_day", "day": day, "row": b["t1_by_day"][day]}))
	for row3 in b["t1_team03_rows"]:
		f.store_line(JSON.stringify({"kind": "T1_team03", "row": row3}))
	f.store_line(JSON.stringify({"kind": "P4", "result": b["p4_result"]}))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== a1_build_never_started DONE ===")
	quit(0)


func _run_pass(probe_on: bool) -> Dictionary:
	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	if probe_on:
		Probe.arm()
	else:
		Probe.enabled = false
		Probe.reset()

	var hasher := HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)
	var day_len: int = WorldState.TICKS_PER_DAY
	var t1_by_day: Dictionary = {}
	var t1_team03_rows: Array = []

	for day in range(30):
		for _i in range(day_len):
			runner.advance_tick(ws, no_player)
			var ids: Array = ws.teams.keys()
			ids.sort()
			var parts: Array = []
			for tid in ids:
				var t: TeamData = ws.teams[tid]
				parts.append("%d:%s" % [int(tid), t.current_option])
			hasher.update(("|".join(parts)).to_utf8_buffer())

		# 日界 T1 分類
		var cnt: Dictionary = {"i": 0, "ii": 0, "iii": 0, "iv": 0, "total": 0}
		for tid2 in ws.teams.keys():
			var t2: TeamData = ws.teams[tid2]
			if String(t2.current_task) != TeamData.TASK_BUILD:
				continue
			cnt["total"] = int(cnt["total"]) + 1
			var tile_id: int = t2.tile_pos.x * 1000 + t2.tile_pos.y
			var tile: HexTileData = ws.world.tiles.get(tile_id)
			var ct_id: int = int(tile.construction_team_id) if tile != null else -1
			var cls: String = ""
			if ct_id == -1:
				cnt["iii"] = int(cnt["iii"]) + 1; cls = "iii_no_site"
			elif ct_id == int(tid2):
				cnt["i"] = int(cnt["i"]) + 1; cls = "i_own"
			elif tile != null:
				cnt["ii"] = int(cnt["ii"]) + 1; cls = "ii_other"
			else:
				cnt["iv"] = int(cnt["iv"]) + 1; cls = "iv_other"
			if int(tid2) == 0 or int(tid2) == 3:
				t1_team03_rows.append({"day": day, "team": int(tid2), "class": cls, "ct_id": ct_id})
		t1_by_day[day] = cnt

	var home_count: Dictionary = {}
	for tid3 in [0, 3]:
		home_count[tid3] = ws.own_outpost_count(tid3) if ws.teams.has(tid3) else -998

	# P4 陽性對照：挑一支現存隊，強制 task=TASK_BUILD、腳下 tile construction_team_id=-1
	var p4_result: String = ""
	var any_tid: int = -1
	for tid4 in ws.teams.keys():
		any_tid = int(tid4); break
	if any_tid != -1:
		var pt: TeamData = ws.teams[any_tid]
		pt.current_task = TeamData.TASK_BUILD
		var tile_id2: int = pt.tile_pos.x * 1000 + pt.tile_pos.y
		var tile2: HexTileData = ws.world.tiles.get(tile_id2)
		if tile2 != null:
			tile2.construction_team_id = -1
			var ct_id2: int = int(tile2.construction_team_id)
			var cls2: String = "iii_no_site" if ct_id2 == -1 else "???"
			p4_result = "team=%d｜classified=%s｜★必入(iii)=%s" % [any_tid, cls2, str(cls2 == "iii_no_site")]
		else:
			p4_result = "★佈置失敗：team%d 腳下沒有 tile 物件" % any_tid
	else:
		p4_result = "★佈置失敗：世界沒有任何隊"

	var fp: String = _world_fp(ws)
	var digest: PackedByteArray = hasher.finish()
	return {"decision_hash": digest.hex_encode(), "world_fp": fp, "home_count": home_count,
		"t1_by_day": t1_by_day, "t1_team03_rows": t1_team03_rows, "p4_result": p4_result}


func _world_fp(ws: WorldState) -> String:
	var ids: Array = ws.teams.keys()
	ids.sort()
	var arr: Array = []
	for tid in ids:
		var t: TeamData = ws.teams[tid]
		arr.append([tid, t.leader_id, t.tile_pos.x, t.tile_pos.y, t.population,
			t.current_task, t.current_option, t.task_priority,
			snappedf(float(t.resources.get("food", 0)), 0.01),
			snappedf(float(t.resources.get("coin", 0)), 0.01),
			snappedf(float(t.resources.get("material", 0)), 0.01)])
	arr.append(["__world__", ws.world.current_tick, ws.game_over, ws.game_over_reason])
	return JSON.stringify(arr).sha256_text()


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
