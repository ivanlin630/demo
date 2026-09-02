extends SceneTree
# @observe-pure
# ★★★#35「g1a 礦村未鑄幣」【復發】—— ★本票是【查】不是【修】：問的是「舊修法為什麼失效」。
#
# ★舊修法（`headless_test.gd` `_mk_produce_team_on`）：`ldr.skills["統領"] = 0.5`
#   ★★它針對的成因是「effective_pop_cap 讀到 0 → overflow 拆走生產人力 → 殘隊跑不動 collect/mint」。
#   ★★★而 baseline 現在的原文顯示【施工隊=800／task=建設／餘工期 1912】
#     ⇒ 隊【在蓋】⇒ ★「殘隊跑不動」那個成因【已經不是現在的成因】。
#
# ★所以本床不重測「有沒有鑄幣」（那個 assert 已經在 headless_test 裡），
#   ★★本床逐日 dump【工程為什麼推不完】：料／工具／人力／工期餘額／task，
#   ★★★因為「工期太長」與「料斷了」與「人力跑掉」是三件不同的事，而 assert 訊息只給了最後一刻的快照。
#
# ★fixture 逐行鏡射 `headless_test.gd::_test_g1a_mining_to_coin`（★不是另建一個世界 ——
#   另建就等於在回答另一個問題）。

func _initialize() -> void:
	_run(); quit()

static func _seed_pop(team: TeamData, n: int) -> void:
	var named_in: int = team.named_members.size() + (1 if team.leader_id != -1 else 0)
	var want_anon: int = maxi(n - named_in, 0)
	var cur_anon: int = AnonCohort.total(team.anon_cohorts)
	var delta: int = want_anon - cur_anon
	if delta > 0:
		AnonCohort.add(team.anon_cohorts, "平民", "healthy", delta)
	elif delta < 0:
		AnonCohort.remove(team.anon_cohorts, "平民", "healthy", -delta)

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 25
	var sd: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(sd)
	var state := WorldState.new()
	state.world = WorldData.new()
	var pos := Vector2i(2, 0)
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
	_seed_pop(team, 10)
	var ldr := PersonData.new(); ldr.id = 8000; ldr.team_id = 800
	ldr.skills["統領"] = 0.5                       # ★★★舊修法就是這一行
	ldr.values["貪婪"] = 0.8; ldr.values["野心"] = 0.6
	state.persons[8000] = ldr; team.leader_id = 8000
	state.teams[800] = team
	tile.outpost_owner = team.team_id
	team.resources["food"] = 500.0
	team.resources["material"] = 200.0
	team.resources["tools"] = 20.0
	state.create_faction(team.team_id)

	print("=== #35 g1a 鑄幣鏈逐日 dump｜days=%d seed=%d ===" % [days, sd])
	print("★舊修法在不在：ldr.skills[統領] = %.2f（★★在，而症狀仍復發 ⇒ 成因換了）"
		% float(ldr.skills.get("統領", 0.0)))
	print("★★第一格要答的：pop cap 有沒有被撐住（舊修法的【直接效果】）")
	print("   population=%d  minor=%d  anon=%d" % [team.population, team.minor_population,
		AnonCohort.total(team.anon_cohorts)])
	print("日|隊料|工具|vault礦|地上礦|mint_L|施工隊|餘工期|開工tick|task|建設中設施")
	var runner := SimRunner.new()
	var prev_left: int = -1
	var prev_start: int = -999
	var starts: Dictionary = {}
	var stalled_days: int = 0
	for d in range(days):
		for _t in range(WorldState.TICKS_PER_DAY):
			runner.advance_tick(state, pos)
		var left: int = tile.construction_ticks_left
		if prev_left != -1 and left == prev_left and left > 0:
			stalled_days += 1
		prev_left = left
		# ★【開工了幾次、蓋的是什麼】—— ★★它才是【沒鑄幣】的直接答案：
		#   一直在蓋別的東西 ≠ 工期太長，也 ≠ 料斷了。
		if tile.construction_started_tick != prev_start and tile.construction_team_id != -1:
			prev_start = tile.construction_started_tick
			var _f: String = str(tile.construction_target.get("facility", "?"))
			starts[_f] = int(starts.get(_f, 0)) + 1
		print("%d|%.0f|%.0f|%.0f|%.0f|%d|%d|%d|%d|%s|%s" % [
			d + 1,
			float(team.resources.get("material", 0)), float(team.resources.get("tools", 0)),
			float(tile.public_storage.get("ore_gold", 0)) + float(tile.public_storage.get("ore_silver", 0)),
			float(tile.resources.get("ore_gold", 0)) + float(tile.resources.get("ore_silver", 0)),
			tile.mint_level, tile.construction_team_id, left, tile.construction_started_tick,
			team.current_task, str(tile.construction_target.get("facility", ""))])
	print("── ★★★【這段窗口裡到底蓋了什麼】──")
	var _st: Array = []
	for k in starts.keys(): _st.append("%s×%d" % [String(k), int(starts[k])])
	_st.sort()
	print("  開工次數：%s" % ("｜".join(PackedStringArray(_st)) if not _st.is_empty() else "（從未開工）"))
	print("  終局設施：outpost_L=%d farming=%d mint=%d manufacturing=%d smelter=%d" % [
		tile.outpost_level, tile.farming_level, tile.mint_level, tile.manufacturing_level, tile.smelter_level])
	print("── ★★★讀法（★三件不同的事，別混）──")
	print("  ①【工期太長】：餘工期【每日穩定下降】而窗不夠 ⇒ 拉長窗就會過")
	print("  ②【料斷了】  ：隊料掉到 0 而餘工期【卡住不動】 ⇒ 拉長窗【也不會過】")
	print("  ③【人力跑掉】：施工隊變 -1 或 task 不再是建設 ⇒ 決策端把它換走了")
	print("  ★餘工期【與前一日相同】的天數 = %d／%d（★★非 0 ＝ 工程有停過，不是純粹「還沒蓋完」）"
		% [stalled_days, days])
	print("★誠實限：①單 seed／單 fixture（鏡射 headless_test 那一支，非隨機世界）")
	print("  ★★本票【不改 production】⇒ 上面只有觀測，沒有任何修法")
