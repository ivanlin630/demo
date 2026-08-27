extends SceneTree

# ★★★S2 / g1a 【逐決策 specimen】—— QA 要的不是前後終態對照，是【為什麼排序會變】。
#   ★所以這張床出三樣：
#     ①每一次設施決策的【每一個候選】的 util（不只贏家）
#     ②贏家與當下的隊料
#     ③material / coin 的軌跡
#   ★★【取樣規則講死】：material/coin 不是每 tick 都寫 —— 寫【變化時】＋【每日邊界】。
#     因為重錨後 25 遊戲日 = 36000 tick，逐 tick 寫會讓 QA 拿到一堆重複列。
#     ★★★而【變化時】不會漏掉任何一筆真的異動，不是截斷。
#
# 用法：TRACE_DAYS=25 godot --headless --path <wt> --script scripts/debug/s2_g1a_decision_specimen.gd
#   ★舊根對照：把本檔複製進舊根 worktree 跑（記得先 --import）。

func _initialize() -> void:
	var days: int = int(OS.get_environment("TRACE_DAYS")) if OS.has_environment("TRACE_DAYS") else 25
	var out_path: String = OS.get_environment("TRACE_OUT") if OS.has_environment("TRACE_OUT") 		else "docs/measurements/2026-08-27-s2-g1a-decision.specimen.jsonl"
	seed(1337)
	var state := WorldState.new()
	state.world = WorldData.new()
	var pos := Vector2i(2, 0)

	# ── fixture（★逐行鏡射 headless_test._test_g1a_mining_to_coin，不自己發明）──
	var tile := HexTileData.new()
	tile.tile_id = pos.x * 1000 + pos.y; tile.tile_pos = pos
	tile.terrain = "mountain"; tile.productivity = 0.7
	tile.resources["ore_gold"] = 50.0; tile.resource_cap["ore_gold"] = 50.0
	state.world.tiles[tile.tile_id] = tile
	tile.public_storage.erase("ore_gold"); tile.public_storage.erase("ore_silver")
	tile.outpost_type = "civilian"; tile.outpost_level = 1

	var team := TeamData.new()
	team.team_id = 800; team.tile_pos = pos; team.faction_id = -1
	team.tags.append(TeamData.TAG_PRODUCE)
	var ldr := PersonData.new(); ldr.id = 8000; ldr.team_id = 800
	ldr.skills["統領"] = 0.5
	ldr.values["貪婪"] = 0.8; ldr.values["野心"] = 0.6
	state.persons[8000] = ldr; team.leader_id = 8000
	var want_anon: int = 10 - 1
	AnonCohort.add(team.anon_cohorts, "平民", "healthy", want_anon)
	state.teams[800] = team
	tile.outpost_owner = team.team_id
	team.resources["food"] = 500.0
	team.resources["material"] = 200.0
	team.resources["tools"] = 20.0
	state.create_faction(team.team_id)

	Probe.reset(); Probe.enabled = true
	FactionAISystem.trace_infra = true

	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var traj: Array = []
	var last_mat: float = -1.0
	var last_coin: float = -1.0
	for t in range(ticks):
		runner.advance_tick(state, pos)
		var mat: float = float(team.resources.get("material", 0))
		var coin: float = _coin_total(state)
		var day_edge: bool = (state.world.current_tick % WorldState.TICKS_PER_DAY) == 0
		if day_edge or absf(mat - last_mat) > 0.001 or absf(coin - last_coin) > 0.001:
			traj.append({"tick": state.world.current_tick,
				"day": float(state.world.current_tick) / float(WorldState.TICKS_PER_DAY),
				"material": mat, "coin": coin,
				"vault_ore": _vault_ore(tile),
				"reason": "day_edge" if day_edge else "changed"})
			last_mat = mat; last_coin = coin

	var cands: Array = Probe.samples.get("infra.cand", [])
	var winners: Array = Probe.samples.get("infra.winner", [])
	print("=== s2_g1a_decision_specimen ===")
	print("根旋鈕 TICKS_PER_HOUR=%d｜TICKS_PER_DAY=%d｜跑 %d 遊戲日 = %d tick"
		% [WorldState.TICKS_PER_HOUR, WorldState.TICKS_PER_DAY, days, ticks])
	print("★母體 vs 樣本：candidate 寫入 %d 筆（cap 4000）｜winner %d 筆｜軌跡 %d 列"
		% [cands.size(), winners.size(), traj.size()])
	if cands.size() >= 4000:
		print("★★警告：candidate 撠到 cap ⇒ 這是【前 N 筆】不是全部，QA 讀的時候要知道")
	print("終態：mint_level=%d coin=%.0f vault_ore=%.1f 隊料=%.1f"
		% [tile.mint_level, _coin_total(state), _vault_ore(tile), float(team.resources.get("material", 0))])
	var lv: Dictionary = {"outpost_L": tile.outpost_level}
	for f in OutpostSystem.FACILITY_DEF:
		var k: String = String(OutpostSystem.FACILITY_DEF[f].get("current_level_key", ""))
		if k != "": lv[String(f)] = tile.get(k)
	print("設施：%s" % str(lv))

	var fa := FileAccess.open(out_path, FileAccess.WRITE)
	if fa != null:
		fa.store_line(JSON.stringify({"kind": "meta", "ticks_per_hour": WorldState.TICKS_PER_HOUR,
			"ticks_per_day": WorldState.TICKS_PER_DAY, "days": days,
			"n_candidates": cands.size(), "n_winners": winners.size(), "n_traj": traj.size(),
			"final": {"mint_level": tile.mint_level, "coin": _coin_total(state),
				"vault_ore": _vault_ore(tile), "material": float(team.resources.get("material", 0)),
				"levels": lv},
			"取樣規則": "candidate/winner 逐筆（cap 4000）｛material/coin 寫變化時＋每日邊界（非逐 tick，但不漏異動）"}))
		for c in cands: fa.store_line(JSON.stringify(_tag(c, "candidate")))
		for w in winners: fa.store_line(JSON.stringify(_tag(w, "winner")))
		for tj in traj: fa.store_line(JSON.stringify(_tag(tj, "traj")))
		fa.close()
		print("落地：%s" % out_path)
	print("=== s2_g1a_decision_specimen DONE ===")
	quit()

func _tag(d: Dictionary, kind: String) -> Dictionary:
	var o: Dictionary = d.duplicate()
	o["kind"] = kind
	return o

func _coin_total(state: WorldState) -> float:
	var total: float = 0.0
	for tid in state.teams: total += float(state.teams[tid].resources.get("coin", 0))
	for tile_id in state.world.tiles: total += float(state.world.tiles[tile_id].public_storage.get("coin", 0))
	return total

func _vault_ore(tile) -> float:
	return float(tile.public_storage.get("ore_gold", 0)) + float(tile.public_storage.get("ore_silver", 0))
