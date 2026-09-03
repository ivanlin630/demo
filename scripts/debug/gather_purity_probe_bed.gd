extends SceneTree
# @observe-pure
# ★★★構造式實證：`DecisionContext.gather(state, team)`（advance=false，★即觀測路徑走的那條）
#   到底還寫不寫 state —— ★不靠隨機跑撞，直接【構造】會走到每個寫點的情境。
#
# ★背景：systems 的票說「真正還活著的副作用只剩 idle_employ 快取寫【一處】」（R² 查證）。
#   ★★而我讀 code 讀到【不只一處】⇒ 照裁定③停下來報之前，先用實驗坐實，不是只貼行號。
#
# ★★★方法：快照 → 呼一次 gather(advance=false) → 再快照 → 逐欄比。
#   ★欄位清單【寫死在這裡】，而它是【下界】：我只比得了我列出來的欄位。
#     ⇒ 所以另外附一個【全域證據】：WorldEvents 的 pending 佇列有沒有變長
#       （那顆抓得到「有人被叫醒」這種我沒列進欄位清單的副作用）。

func _initialize() -> void:
	_run(); quit()

func _snap(team: TeamData, tile: HexTileData, state: WorldState) -> Dictionary:
	return {
		"idle_employ_cached": tile.idle_employ_cached,
		"idle_employ_next_tick": tile.idle_employ_next_tick,
		"labor_eval_next_tick": tile.labor_eval_next_tick,
		"labor_alloc_size": tile.labor_alloc.size(),
		"expand_eval_next_tick": team.expand_eval_next_tick,
		"expand_site_cached": str(team.expand_site_cached),
		"consolidate_eval_next_tick": team.consolidate_eval_next_tick,
		"consolidate_target_cache": team.consolidate_target_cache,
		"absorb_target_cache": team.absorb_target_cache,
		"need_urgency_size": team.need_urgency.size(),
		"★pending_rethink_size": state.pending_rethink.size(),
	}

func _run() -> void:
	var out: Array = []
	print("[CONTROL-RAN] gather_purity_probe_bed 已執行到 _run（★對照組自證已跑）")
	out.append("# gather(advance=false) 純度構造式實證 —— ★觀測路徑走的就是這條")
	out.append("# [CONTROL-RAN] 本床確實執行（★陽性對照必須先證明自己跑起來了）")

	# ★用 helper 建世界（arm 先發生）
	var state := MeasureBedHelper.arm_and_setup("res://config/peaceful_economy.json")
	# 找一支站在自家 outpost 上的隊（gather 的幾個寫點都掛在這個前提下）
	var team: TeamData = null
	var tile: HexTileData = null
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var tl: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
		if tl != null and tl.outpost_level > 0 and tl.outpost_owner == t.team_id:
			team = t; tile = tl; break
	if team == null:
		# 構造：沒有現成的就自己造一個（★不要因為隨機世界沒生出來就報「沒事」）
		for tid2 in state.teams:
			team = state.teams[tid2]; break
		tile = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
		tile.outpost_level = 2
		tile.outpost_owner = team.team_id
		tile.manufacturing_level = 1
		if not TeamData.TAG_PRODUCE in team.tags:
			team.tags.append(TeamData.TAG_PRODUCE)
		out.append("# ★構造：世界沒有現成的『站自家 outpost』隊 ⇒ 自己造一個（team=%d）" % team.team_id)
	out.append("# 受測隊 team=%d｜tile=(%d,%d)｜outpost_level=%d"
		% [team.team_id, tile.tile_pos.x, tile.tile_pos.y, tile.outpost_level])

	var before: Dictionary = _snap(team, tile, state)
	var _ctx: DecisionContext = DecisionContext.gather(state, team)   # ★advance 預設 false ＝ 觀測路徑
	var after: Dictionary = _snap(team, tile, state)

	var changed: Array = []
	for k in before:
		if str(before[k]) != str(after[k]):
			changed.append("%s: %s → %s" % [str(k), str(before[k]), str(after[k])])
	out.append("#")
	out.append("## 呼叫【一次】gather(advance=false) 之後，變了幾個欄位：%d" % changed.size())
	for c in changed:
		out.append("  ★ " + c)
	if changed.is_empty():
		out.append("  （零變動 —— ★而那可能是【沒觸發】不是【沒影響】：見下方觸發條件檢查）")
	out.append("#")
	out.append("## 觸發條件檢查（★『相同』要能分辨是沒影響還是沒踩到）")
	out.append("  has_own_outpost 前提｜outpost_level=%d owner==team=%s"
		% [tile.outpost_level, str(tile.outpost_owner == team.team_id)])
	out.append("  ctx.idle_labor=%.4f（>0 才會走 idle_employ 那個寫點）" % _ctx.idle_labor)
	out.append("  team.population=%d" % team.population)
	out.append("#")
	out.append("# ★★誠實限：欄位清單是【我列的】⇒ 這是下界；")
	out.append("#   ★★★所以另附 pending_rethink 大小當全域證據（抓得到「有人被叫醒」這類我沒列的副作用）")

	for line in out:
		print(line)
	var path: String = OS.get_environment("PURITY_OUT") if OS.has_environment("PURITY_OUT") \
		else "docs/measurements/2026-09-01-gather-purity-probe.txt"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(out)) + "\n"); f.close()
		print("落地：%s" % path)
	print("=== gather_purity_probe DONE（變動欄位 %d）===" % changed.size())
