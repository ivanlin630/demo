extends SceneTree
# ★量測員派工（systems 2026-10-06，藍圖方向票 1d3ae0409②＋裁定 a9053c817）：
# docs/superpowers/handbacks/2026-10-06-systems-to-measurer-observation-round-30-days.md
#
# 觀察輪：一個完整世界 30 天，玩家活著（不殺），產三份給 blueprint(WHAT)＋QA(因果) 讀：
#   ①事件故事（SpecimenDumpHelper，motive→action→outcome）
#   ②經濟帳（抽樣隊，逐日 food/coin/material 淨變動 net + 當日期末餘額）
#   ③資訊傳播樣本（belief 寫入事件：觀察者/目標/來源類型/tick/credibility/distorted）
# ＋★★必答 Q-material（母體普查，非抽樣）：幾隊宣稱過建設/紮根、幾隊 material 有進出、
#   幾隊建物欄（outpost/各設施 level）有變化。
# Q-raid 本輪空著（等 systems 的 sample_window tap 接上再補跑，見前一輪 handback）。
#
# ★★先驗「觀測不改被觀測物」：同 seed 1337、同樹，PASS A(Probe=off) vs PASS B(Probe=on)
#   比決策序列 hash ＋ 世界 fp，逐位元組相同才放行 PASS C（正式產三份）。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/observation_round_30day.gd

const SEED: int = 1337
const DAYS: int = 30
const NEAR_COUNT: int = 3
const BELIEF_ROW_CAP: int = 2000
const CLAIM_BUILDING_OPTS: Array = ["建設", "紮根"]
const FACILITY_LEVEL_FIELDS: Array = ["outpost_level", "camp_level", "farming_level",
	"manufacturing_level", "stable_level", "apothecary_level", "smelter_level",
	"weaponsmith_level", "armorsmith_level", "mint_level"]


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d" % SEED)

	print("\n########## PASS A（Probe=OFF，對照組）##########")
	var a: Dictionary = _run_pass(false, false)

	print("\n########## PASS B（Probe=ON，只切 Probe）##########")
	var b: Dictionary = _run_pass(true, false)

	print("\n========== 先驗：Probe 開/關是否改世界（30 天版）==========")
	var decision_match: bool = String(a["decision_hash"]) == String(b["decision_hash"]) \
		and int(a["decision_n"]) == int(b["decision_n"])
	var fp_match: bool = String(a["world_fp"]) == String(b["world_fp"])
	print("[COMPARE] 決策序列：A.n=%d｜B.n=%d｜hash一致=%s" % [int(a["decision_n"]), int(b["decision_n"]),
		str(decision_match)])
	print("[COMPARE] 世界 fp：A=%s" % String(a["world_fp"]))
	print("[COMPARE]          B=%s｜一致=%s" % [String(b["world_fp"]), str(fp_match)])

	if not (decision_match and fp_match):
		print("\n[HALT] ★★★30 天版 Probe 開/關不是逐位元組相同 ⇒ 停，不產三份正式產物，回報 systems。")
		quit(1)
		return
	print("[COMPARE] ★★★逐位元組相同 ⇒ 放行 PASS C。")

	print("\n########## PASS C（Probe=ON，正式產三份）##########")
	var c: Dictionary = _run_pass(true, true)

	print("\n========== 母體邊界 ==========")
	print("[POPULATION] 抽樣：player=%d｜近鄰=%s｜最遠=%s（共 %d 隊）｜世界共 %d 隊｜%d 天" \
		% [int(c["player_tid"]), str(c["near_ids"]), str(c["far_id"]), c["sample_ids"].size(),
		c["total_team_n"], DAYS])

	print("\n========== ★★必答 Q-material（母體普查，全隊非抽樣）==========")
	var qm: Dictionary = c["q_material"]
	print("[Q-material] 世界共 %d 隊；宣稱過建設/紮根＝%d 隊；其中 material 有進出＝%d 隊；其中建物欄有變化＝%d 隊" \
		% [c["total_team_n"], qm["claimed_n"], qm["claimed_and_material_moved_n"], qm["claimed_and_building_changed_n"]])
	print("[Q-material] 明細（team_id｜宣稱建設/紮根｜material動過｜建物欄動過）：")
	for row in qm["rows"]:
		print("  team%-3d｜claimed=%s｜material_moved=%s｜building_changed=%s" \
			% [int(row["team_id"]), str(row["claimed"]), str(row["material_moved"]), str(row["building_changed"])])

	print("\n[Q-raid] 本輪空著 —— 等「決策 tap 對準某隊某段」(_cmp 補 team/tick + sample_window) merge 後，\
systems 會敲我用 sample_window 補跑（同 seed 1337、同樹段）。")

	print("\n========== 三份已落地 ==========")
	print("① specimen：%s" % String(c["specimen_path"]))
	print("② 經濟帳：%s" % String(c["economic_path"]))
	print("③ 資訊傳播：%s｜筆數：見過 %d 筆，寫入 %d 筆（cap=%d）" \
		% [String(c["belief_path"]), c["belief_seen_n"], c["belief_kept_n"], BELIEF_ROW_CAP])
	print("[belief-分類] 目擊(親見)=%d｜傳聞(隊友/商旅/流民，NPC互換)=%d｜打聽(玩家主動，本輪母體恆0——這輪\
玩家活著但零指令，不是 tap 沒接電)=%d" % [c["belief_witness_n"], c["belief_rumor_n"], c["belief_inquiry_n"]])

	print("\n[MECH-ANOMALIES]")
	if c["mech_anomalies"].is_empty():
		print("  無")
	else:
		for anomaly in c["mech_anomalies"]:
			print("  - " + String(anomaly))

	print("\n=== observation_round_30day DONE（PASS A/B/C 全跑完）===")
	quit(0)


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"


func _run_pass(probe_on: bool, full_analysis: bool) -> Dictionary:
	var mech_anomalies: Array = []
	seed(SEED)
	# ★bed-arm-gate 要求：建世界一律走 helper（arm 先於 setup，寫死順序）。
	#   strip_player=false —— 本輪玩家要活著（這一輪不殺玩家）。
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)

	if not probe_on:
		# helper 固定 arm；這一輪要「Probe=OFF」對照，世界建好後立刻關閘（不是重建世界）。
		Probe.enabled = false
		Probe.reset()

	# ── 選隊：player ＋ 最近鄰 NEAR_COUNT 支 ＋ 最遠 1 支（確定性，tick0 狀態即可，不等暖身）──
	var player_tid: int = ws.get_player_team_id()
	var near_ids: Array[int] = []
	var far_id: int = -1
	var sample_ids: Array[int] = []
	if player_tid != -1 and ws.teams.has(player_tid):
		var player_team: TeamData = ws.teams[player_tid]
		var player_pos: Vector2i = player_team.tile_pos
		var others: Array = []
		for tid in ws.teams.keys():
			if int(tid) == player_tid:
				continue
			var t: TeamData = ws.teams[tid]
			var d: float = Vector2(t.tile_pos - player_pos).length()
			others.append({"tid": int(tid), "dist": d})
		var near_sorted: Array = others.duplicate()
		near_sorted.sort_custom(func(x, y):
			if x["dist"] != y["dist"]: return x["dist"] < y["dist"]
			return x["tid"] < y["tid"])
		for i in range(min(NEAR_COUNT, near_sorted.size())):
			near_ids.append(int(near_sorted[i]["tid"]))
		var far_sorted: Array = others.duplicate()
		far_sorted.sort_custom(func(x, y):
			if x["dist"] != y["dist"]: return x["tid"] < y["tid"]
			return x["dist"] > y["dist"])
		if far_sorted.size() > 0:
			far_id = int(far_sorted[0]["tid"])
		sample_ids.append(player_tid)
		for nid in near_ids: sample_ids.append(nid)
		if far_id != -1 and not sample_ids.has(far_id):
			sample_ids.append(far_id)
	else:
		mech_anomalies.append("★致命：tick0 找不到玩家隊（player_tid=%d）" % player_tid)

	if full_analysis:
		ws.specimen_team_ids = sample_ids
		SpecimenTracer.reset()
		SpecimenTracer.enabled = true
		print("[SPECIMEN-TEAMS] player=%d｜近鄰=%s｜最遠=%d｜sample_ids=%s" \
			% [player_tid, str(near_ids), far_id, str(sample_ids)])

	var hasher := HashingContext.new()
	hasher.start(HashingContext.HASH_SHA256)
	var decision_n: int = 0
	var day_len: int = WorldState.TICKS_PER_DAY

	# ── Q-material 母體普查用的累計器（全隊，非抽樣）──────────────────────────
	var claimed_building: Dictionary = {}     # team_id → bool（曾在任一 tick 宣稱建設/紮根）
	var material_prev: Dictionary = {}        # team_id → 上一日 material
	var material_moved: Dictionary = {}       # team_id → bool
	var building_sig_prev: Dictionary = {}    # team_id → 上一日建物欄簽章(int)
	var building_changed: Dictionary = {}     # team_id → bool

	# ── ②經濟帳（抽樣隊）────────────────────────────────────────────────────
	var econ_rows: Array = []
	var econ_prev: Dictionary = {}   # team_id → {food,coin,material}（上一日期末值）

	# ── ③資訊傳播（抽樣隊當 observer）────────────────────────────────────────
	var belief_rows: Array = []
	var belief_seen_n: int = 0
	var belief_witness_n: int = 0
	var belief_rumor_n: int = 0
	var belief_inquiry_n: int = 0   # 本輪結構上恆 0（無玩家指令），見下

	for day in range(DAYS):
		for _i in range(day_len):
			runner.advance_tick(ws, no_player)
			var cur_tick: int = ws.world.current_tick
			var ids: Array = ws.teams.keys()
			ids.sort()
			var parts: Array = []
			for tid in ids:
				var t: TeamData = ws.teams[tid]
				parts.append("%d:%s" % [int(tid), t.current_option])
				decision_n += 0   # (計數在下面統一 +1，避免每隊重複加)
				if full_analysis and CLAIM_BUILDING_OPTS.has(String(t.current_option)):
					claimed_building[int(tid)] = true
			hasher.update(("|".join(parts)).to_utf8_buffer())
			decision_n += 1

			if full_analysis:
				for obs_tid in sample_ids:
					if not ws.team_intel.has(obs_tid):
						continue
					var intel: Dictionary = ws.team_intel[obs_tid]
					for tgt_tid in intel.keys():
						var claims: Array = intel[tgt_tid]
						for c in claims:
							if int(c.get("tick", -1)) == cur_tick:
								belief_seen_n += 1
								var stype: String = String(c.get("source_type", ""))
								if stype == "親見": belief_witness_n += 1
								elif stype in ["隊友", "商旅", "流民"]: belief_rumor_n += 1
								if belief_rows.size() < BELIEF_ROW_CAP:
									belief_rows.append({
										"tick": cur_tick, "observer": int(obs_tid), "target": int(tgt_tid),
										"source_type": stype, "source_id": int(c.get("source_id", -1)),
										"credibility": c.get("credibility", null),
										"distorted": c.get("distorted", null),
									})

		# ── 日界：Q-material 普查 ＋ ②經濟帳（抽樣）────────────────────────────
		if full_analysis:
			for tid2 in ws.teams.keys():
				var t2: TeamData = ws.teams[tid2]
				var mat: float = float(t2.resources.get("material", 0.0))
				if material_prev.has(tid2) and not is_equal_approx(float(material_prev[tid2]), mat):
					material_moved[int(tid2)] = true
				material_prev[tid2] = mat
				var sig: int = _building_signature(ws, tid2)
				if building_sig_prev.has(tid2) and int(building_sig_prev[tid2]) != sig:
					building_changed[int(tid2)] = true
				building_sig_prev[tid2] = sig

			for stid in sample_ids:
				if not ws.teams.has(stid):
					continue
				var st: TeamData = ws.teams[stid]
				var food_now: float = float(st.resources.get("food", 0.0))
				var coin_now: float = float(st.resources.get("coin", 0.0))
				var mat_now: float = float(st.resources.get("material", 0.0))
				var prev: Dictionary = econ_prev.get(stid, {})
				var row: Dictionary = {
					"day": day, "tick": ws.world.current_tick, "team_id": int(stid),
					"food_end": snappedf(food_now, 0.01), "coin_end": snappedf(coin_now, 0.01),
					"material_end": snappedf(mat_now, 0.01),
					"food_net": (snappedf(food_now - float(prev.get("food", food_now)), 0.01) if prev.has("food") else null),
					"coin_net": (snappedf(coin_now - float(prev.get("coin", coin_now)), 0.01) if prev.has("coin") else null),
					"material_net": (snappedf(mat_now - float(prev.get("material", mat_now)), 0.01) if prev.has("material") else null),
				}
				econ_rows.append(row)
				econ_prev[stid] = {"food": food_now, "coin": coin_now, "material": mat_now}

	var fp: String = _world_fp(ws)
	var digest: PackedByteArray = hasher.finish()

	var specimen_path: String = ""
	var economic_path: String = ""
	var belief_path: String = ""
	var q_material: Dictionary = {"claimed_n": 0, "claimed_and_material_moved_n": 0,
		"claimed_and_building_changed_n": 0, "rows": []}

	if full_analysis:
		specimen_path = "docs/measurements/observation-30day.specimen.jsonl"
		SpecimenTracer.flush()
		SpecimenDumpHelper.dump(ws, specimen_path)

		economic_path = "docs/measurements/observation-30day-economic.jsonl"
		_write_jsonl(economic_path, econ_rows)

		belief_path = "docs/measurements/observation-30day-belief.jsonl"
		_write_jsonl(belief_path, belief_rows)

		var qm_rows: Array = []
		var claimed_n: int = 0; var cm_n: int = 0; var cb_n: int = 0
		var all_ids: Array = ws.teams.keys()
		all_ids.sort()
		for tid3 in all_ids:
			var claimed: bool = bool(claimed_building.get(tid3, false))
			var mmoved: bool = bool(material_moved.get(tid3, false))
			var bchanged: bool = bool(building_changed.get(tid3, false))
			qm_rows.append({"team_id": int(tid3), "claimed": claimed, "material_moved": mmoved, "building_changed": bchanged})
			if claimed:
				claimed_n += 1
				if mmoved: cm_n += 1
				if bchanged: cb_n += 1
		q_material = {"claimed_n": claimed_n, "claimed_and_material_moved_n": cm_n,
			"claimed_and_building_changed_n": cb_n, "rows": qm_rows}

		if ws.world.current_tick != DAYS * day_len:
			mech_anomalies.append("★★tick 沒有如期前進：要求 %d，實際 current_tick=%d" % [DAYS * day_len, ws.world.current_tick])

	return {
		"world_fp": fp, "decision_hash": digest.hex_encode(), "decision_n": decision_n,
		"mech_anomalies": mech_anomalies, "player_tid": player_tid, "near_ids": near_ids,
		"far_id": far_id, "sample_ids": sample_ids, "total_team_n": ws.teams.size(),
		"specimen_path": specimen_path, "economic_path": economic_path, "belief_path": belief_path,
		"belief_seen_n": belief_seen_n, "belief_kept_n": belief_rows.size(),
		"belief_witness_n": belief_witness_n, "belief_rumor_n": belief_rumor_n,
		"belief_inquiry_n": belief_inquiry_n, "q_material": q_material,
	}


# ── 建物欄簽章：該隊名下所有 tile 的設施 level 總和（owner churn 也會反映在這個數字裡，★誠實限
#   寫進交件：這個數字漲跌可能是「升級」也可能是「換主」，這份不拆分，只答「有沒有變」）───────
func _building_signature(ws: WorldState, team_id: int) -> int:
	var sig: int = 0
	for tid in ws.world.tiles:
		var t: HexTileData = ws.world.tiles[tid]
		if int(t.outpost_owner) != int(team_id):
			continue
		for f in FACILITY_LEVEL_FIELDS:
			sig += int(t.get(f))
	return sig


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


func _write_jsonl(path: String, rows: Array) -> void:
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if f == null:
		push_error("[observation_round_30day] 開檔失敗：%s" % path)
		return
	for row in rows:
		f.store_line(JSON.stringify(row))
	f.close()
