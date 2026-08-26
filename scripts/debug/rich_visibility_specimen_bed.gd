extends SceneTree

# ★rich-point-visibility 的【故事 specimen】床（QA 2026-08-26 指名要）。
#
# QA 要能回答的三題（★本床只【產證據】不下結論——故事判讀是 QA 的職）：
#   ①★6 座有據點的老熟林裡，`(0,14)`／`(10,14)` 累計汲取仍是 0 —— 那兩隊 30 天在幹嘛？
#   ②★★`dispatch_builder.attempt` 12→81 而 `accepted` 只 23→28 ——
#      是【同一隊反覆試】還是【很多隊各試一次】？★兩者故事完全不同。
#   ③★挑幾隊命中老熟林的，讀 motive→action→outcome。
#
# ★★儀器紀律（systems 已點名，本床照做）：
#   ★**判「有沒有在採」用【累計汲取】(逐 tick 累加下降量)，不用存量差分。**
#     池子 cap-bound 且日 regen 12 ⇒ 日採 ≤12 就被補滿 ⇒ Δ 恆 0 而材料一直在流
#     （血證：同一批格子 Δ 全 0，累計汲取卻是 217／183／182／153）。
#   ★★`bump_sample` 是 **first-N** 取樣 ⇒ **母體與樣本數必須並列印**，否則讀者會把樣本當母體。
#
# ★兩趟的理由（沿用 means_end_specimen_bed）：specimen 名單必須在【跑之前】設好
#   （tracer 逐決策捕捉，事後補不回來），但「誰擁有老熟林」要世界建起來才知道
#   ⇒ pass1 只建世界讀 t=0 歸屬（不跑 tick，省一趟）＋跑一趟收 Probe 樣本回答②，
#      pass2 同 seed 重跑、指名 specimen 全程 trace。
#   ★兩趟世界一致的根據：seeded ＋ 觀測零耗 global RNG（invariants §觀測者禁耗 RNG）。
#
# ★零 production 改（本檔純 runner）。
#
# env：
#   LW_CONFIG     預設 peaceful_economy
#   PERF_SEED     預設 1337
#   ADHOC_DAYS    預設 30
#   SPECIMEN_OUT  預設 docs/measurements/2026-08-26-rich-visibility-story.specimen.jsonl
#   SPECIMEN_N    最多幾支主角（預設 4）
#   SPECIMEN_TEAM_ID  手動指定則跳過挑選

func _initialize() -> void:
	_run()
	quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "peaceful_economy")
	var days: int = int(_env("ADHOC_DAYS", "30"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	var want: int = int(_env("SPECIMEN_N", "4"))
	var out_path: String = _env("SPECIMEN_OUT",
		"docs/measurements/2026-08-26-rich-visibility-story.specimen.jsonl")
	print("=== rich-visibility 故事 specimen：config=%s days=%d seed=%d out=%s ===" % [cfg, days, sd, out_path])

	# ── pass1：世界建起來 → 誰擁有老熟林；跑一趟 → 汲取量 + attempt 分布 ──
	var p1: Dictionary = _pass1(cfg, sd, days)
	if p1.is_empty():
		print("[FAIL] pass1 沒有世界"); return
	var ids: Array[int] = []
	var manual: String = _env("SPECIMEN_TEAM_ID", "")
	if manual != "":
		for part in manual.split(","):
			var s: String = part.strip_edges()
			if s.is_valid_int(): ids.append(int(s))
		print("[pass1] 主角手動指定 = %s" % str(ids))
	else:
		ids = _pick_actors(p1, want)
	if ids.is_empty():
		print("[FAIL] 挑不到主角（★這本身是個結果：沒有隊擁有老熟林）"); return

	# ── pass2：同 seed 重跑，指名 specimen 全程 trace ──
	_pass2_trace(cfg, sd, days, ids, out_path)
	_story_index(p1, ids, out_path)
	print("=== rich-visibility 故事 specimen DONE ===")

# ────────── pass1 ──────────
func _pass1(cfg: String, sd: int, days: int) -> Dictionary:
	print("\n───────── pass1：老熟林歸屬 + 累計汲取 + attempt 分布 ─────────")
	var state: WorldState = _fresh_world(cfg, sd)
	if state == null: return {}
	var wg = load("res://scripts/simulation/world_generator.gd").new()
	# ★t=0：哪幾格是老熟林、誰擁有它
	var og: Array = []
	for tid in state.world.tiles:
		var t: HexTileData = state.world.tiles[tid]
		if t.terrain == "forest" and float(t.resources.get("material", 0)) >= float(wg.OLD_GROWTH_MATERIAL_MIN):
			og.append(tid)
	var owner0: Dictionary = {}
	var m0: Dictionary = {}
	for oid in og:
		var t2: HexTileData = state.world.tiles[oid]
		owner0[oid] = int(t2.outpost_owner) if t2.outpost_level > 0 else -1
		m0[oid] = float(t2.resources.get("material", 0))
	# ★跑：逐 tick 累加汲取（★流，不是差分）
	var drawn: Dictionary = {}
	var prev: Dictionary = {}
	for oid2 in og:
		drawn[oid2] = 0.0
		prev[oid2] = float(state.world.tiles[oid2].resources.get("material", 0))
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		for oid3 in og:
			var cur: float = float(state.world.tiles[oid3].resources.get("material", 0))
			if cur < float(prev[oid3]):
				drawn[oid3] = float(drawn[oid3]) + (float(prev[oid3]) - cur)
			prev[oid3] = cur
		if state.teams.is_empty(): break
	return {"og": og, "owner0": owner0, "m0": m0, "drawn": drawn, "state": state}

# ★挑主角：①零汲取但有據點的（QA 第①題的主角）②汲取最多的（對照）
func _pick_actors(p1: Dictionary, want: int) -> Array[int]:
	var zero: Array[int] = []
	var busy: Array = []
	for oid in (p1["og"] as Array):
		var ow: int = int((p1["owner0"] as Dictionary)[oid])
		if ow < 0: continue
		var dr: float = float((p1["drawn"] as Dictionary)[oid])
		if dr <= 0.001:
			if not zero.has(ow): zero.append(ow)
		else:
			busy.append({"team": ow, "drawn": dr})
	busy.sort_custom(func(a, b): return float(a["drawn"]) > float(b["drawn"]))
	var out: Array[int] = []
	for z in zero:                                   # ★零汲取優先（那是要被解釋的異常）
		if out.size() < want and not out.has(z): out.append(int(z))
	for b in busy:                                   # ★再補汲取最多的當對照組
		var tb: int = int(b["team"])
		if out.size() < want and not out.has(tb): out.append(tb)
	# ★★★attempt 最多的那一隊【一定要在名單裡】——QA 第②題（12→81 是集中還是分散）的主角就是它。
	#   ★第一版沒有這條：Team6 一隊吃掉 81 次裡的 70 次，卻不在 specimen ⇒
	#     **索引說得出「有一隊試了 70 次」，jsonl 卻讀不到它為什麼要試 70 次** —— 那份 specimen 答不了問題。
	var top_t: int = -1
	var top_n: int = 0
	if Probe.samples.has("dispatch_builder.attempt"):
		var cnt: Dictionary = {}
		for smp in (Probe.samples["dispatch_builder.attempt"] as Array):
			var tm: int = int(smp.get("team", -1))
			cnt[tm] = int(cnt.get(tm, 0)) + 1
		for k in cnt:
			if int(cnt[k]) > top_n:
				top_n = int(cnt[k]); top_t = int(k)
	if top_t >= 0 and not out.has(top_t):
		out.append(top_t)   # ★不受 want 上限擋（它是被指名的主角，不是補位的）
		print("[pass1] ★attempt 最多的 Team%d（%d 次）強制納入 specimen" % [top_t, top_n])
	return out

# ────────── pass2 ──────────
func _pass2_trace(cfg: String, sd: int, days: int, ids: Array[int], out_path: String) -> void:
	print("\n───────── pass2：同 seed 重跑，specimen=%s，全程 trace ─────────" % str(ids))
	var state: WorldState = _fresh_world(cfg, sd)
	if state == null: return
	state.specimen_team_ids = ids
	SpecimenTracer.reset()
	SpecimenTracer.enabled = true
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	SpecimenTracer.summary()
	SpecimenDumpHelper.dump(state, out_path)

# ────────── 故事索引（給 QA 的入口，不取代 jsonl）──────────
func _story_index(p1: Dictionary, ids: Array[int], out_path: String) -> void:
	print("\n───────── ★故事索引（詳情讀 %s）─────────" % out_path)
	var state: WorldState = p1["state"]
	print("[索引] specimen=%s  決策 entry 總數=%d" % [str(ids), SpecimenTracer.decision_count])

	# ★QA①：老熟林逐座 → 誰擁有、採了多少
	print("\n[QA①] 老熟林逐座（★汲取＝流，不是存量差分）")
	print("   座標      material0   owner(t=0)   ★累計汲取")
	for oid in (p1["og"] as Array):
		var t: HexTileData = state.world.tiles[oid]
		var ow: int = int((p1["owner0"] as Dictionary)[oid])
		print("   (%2d,%2d)  %8.0f   %-10s   %8.1f%s" % [
			t.tile_pos.x, t.tile_pos.y, float((p1["m0"] as Dictionary)[oid]),
			("Team%d" % ow) if ow >= 0 else "（無據點）",
			float((p1["drawn"] as Dictionary)[oid]),
			"   ←★零汲取但【有據點】" if (ow >= 0 and float((p1["drawn"] as Dictionary)[oid]) <= 0.001) else ""])

	# ★QA②：attempt 是集中還是分散 —— ★母體與樣本並列（bump_sample 是 first-N）
	var pop: int = int(Probe.counts.get("dispatch_builder.attempt", 0))
	var samples: Array = (Probe.samples["dispatch_builder.attempt"] as Array) \
		if Probe.samples.has("dispatch_builder.attempt") else []
	print("\n[QA②] dispatch_builder.attempt 的集中度")
	print("   ★母體 = %d｜★★樣本 = %d（bump_sample 是 first-N；%s）" % [
		pop, samples.size(),
		"樣本涵蓋全母體" if samples.size() >= pop else "★樣本 < 母體，下面的分布只代表【前 %d 筆】" % samples.size()])
	var per_team: Dictionary = {}
	var per_team_day: Dictionary = {}
	for smp in samples:
		var tm: int = int(smp.get("team", -1))
		var dy: int = int(smp.get("tick", 0)) / WorldState.TICKS_PER_DAY
		per_team[tm] = int(per_team.get(tm, 0)) + 1
		var key: String = "%d|%d" % [tm, dy]
		per_team_day[key] = int(per_team_day.get(key, 0)) + 1
	var tks: Array = per_team.keys(); tks.sort()
	var mx: int = 0
	for k in tks:
		var c: int = int(per_team[k])
		if c > mx: mx = c
		print("   Team%-4d 試了 %3d 次" % [int(k), c])
	var mxd: int = 0
	for k2 in per_team_day:
		if int(per_team_day[k2]) > mxd: mxd = int(per_team_day[k2])
	print("   ⇒ ★不同隊數 = %d｜單隊最多 %d 次｜★★單隊單日最多 %d 次" % [tks.size(), mx, mxd])
	print("   ★★★「很多隊各試一次」vs「少數隊反覆試」由上面三個數字判 —— 我不替 QA 選。")

	# ★QA③：命中老熟林的隊有哪些在 specimen 裡
	var hit: Array = []
	for oid2 in (p1["og"] as Array):
		var ow2: int = int((p1["owner0"] as Dictionary)[oid2])
		if ow2 >= 0 and not hit.has(ow2): hit.append(ow2)
	print("\n[QA③] 擁有老熟林的隊 = %s｜其中在 specimen 名單裡的 = %s" % [str(hit), str(ids)])

	# ★閘：wall 拒絕理由（跨到聚合面，讓 QA 對得上 systems 那封的數字）
	# ★★★這裡我第一版讀【裸 key】印出 0｜0 —— 而 81 次 attempt 配 0 次 accepted 不可能。
	#   根因：`outpost_system.gd:532` 的 bump 一律接日尾綴（`"wall.accepted" + ".day.NNN"`）
	#   ⇒ ★裸 key 從來沒有被 bump 過 ⇒ **讀裸 key 恆得 0**。
	#   ★★而 0 長得跟「這件事沒發生」一模一樣 —— 交到 QA 手上就是一條假的矛盾。
	print("
[對帳] reject_cannot_afford=%d｜accepted=%d｜attempt=%d（★wall.* 為日桶加總，裸 key 恆 0）" % [
		_sum_days("wall.reject_cannot_afford.day."),
		_sum_days("wall.accepted.day."), pop])

# ★把 `<key>.day.NNN` 這一族加總回一個數（★別讀裸 key —— 它從來沒被 bump 過）
func _sum_days(prefix: String) -> int:
	var total: int = 0
	for k in Probe.counts:
		if String(k).begins_with(prefix):
			total += int(Probe.counts[k])
	return total

# ────────── 共用 ──────────
func _fresh_world(cfg: String, sd: int) -> WorldState:
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config 載入失敗：res://config/%s.json" % cfg)
		return null
	config["seed"] = sd
	GameSetup.setup(state, config)
	return state

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
