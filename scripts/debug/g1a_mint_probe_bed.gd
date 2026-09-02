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
	# ★★★arm 必須在【建世界之前】（bed-arm 閘，systems 2026-09-02）：
	#   ★舊寫法是先 new WorldState、搭完 fixture 才 `Probe.arm()`
	#     ⇒ ★★setup 期發生的事【不入帳】，而那跟「没發生」在輸出上長得一樣。
	#   ★★★而我今天已經踩過一次同族（這支床第一版根本沒 arm ⇒ cand=0
	#     看起來像「`_pick_facility` 從不跑」）⇒ 這一次走 helper，不自己拼順序。
	var state: WorldState = MeasureBedHelper.arm_and_new()
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
	print("日|隊料|工具|糧|食日|pop|vault礦|地上礦|mint_L|farm_L|施工隊|餘工期|開工tick|task|建設中設施")
	# ★★★#35 第二步（systems 2026-09-02）：dump 建設選項的 per-option util。
	#   ★而我【不新建 tap】—— `_pick_facility` 本來就有 `infra.cand`／`infra.winner`（`:5170`／`:5186`），
	#     只是默認關著（`trace_infra = false`）。★★新建一份就是兩份定義。
	#   ★★★而它是 `bump_sample`（first-N，cap 4000）⇒ 後面的會被鶿掉，所以下面必印【樣本數 vs 母體】。
	# ★★★先 arm Probe —— ★這支床第一版【沒 arm】，於是 cand=0、母體=0，
	#   而那跟「_pick_facility 從來沒跑」長得一模一樣 ⇒ ★★差一點就去查【不存在的第二條建設路】。
	#   ★★★所以下面必印 CONTROL 行：儀器有沒有開，要寫在輸出裡而不是假設。
	FactionAISystem.trace_infra = true
	print("[CONTROL] %s" % MeasureBedHelper.arm_order_report())
	print("[CONTROL] Probe.enabled=%s trace_infra=%s（★false 的話下面整張表都是儀器沒開）"
		% [str(Probe.enabled), str(FactionAISystem.trace_infra)])
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
		var _fd: float = ResourceSystem.effective_food(state, team) / maxf(float(team.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
		print("%d|%.0f|%.0f|%.0f|%.1f|%d|%.0f|%.0f|%d|%d|%d|%d|%d|%s|%s" % [
			d + 1,
			float(team.resources.get("material", 0)), float(team.resources.get("tools", 0)),
			float(team.resources.get("food", 0)), _fd, team.population,
			float(tile.public_storage.get("ore_gold", 0)) + float(tile.public_storage.get("ore_silver", 0)),
			float(tile.resources.get("ore_gold", 0)) + float(tile.resources.get("ore_silver", 0)),
			tile.mint_level, tile.farming_level, tile.construction_team_id, left, tile.construction_started_tick,
			team.current_task, str(tile.construction_target.get("facility", ""))])
	print("── ★★★【建設選項 per-option util】—— ★第一問是「farming 贏得對不對」──")
	var cand: Array = Probe.samples.get("infra.cand", []) as Array
	var win: Array = Probe.samples.get("infra.winner", []) as Array
	print("  ★樣本數：cand=%d（cap 4000）／winner=%d（cap 4000）"
		% [cand.size(), win.size()])
	print("  ★★母體（_pick_facility 進場次數，全數非取樣）：%d"
		% _sum_prefix("pick.") )
	print("  ★★★達 cap 的話後面的輪次【靈默消失】⇒ 下面的輪次是【前 N 輪】不是【全部】")
	# ★依 tick 分輪：同一 tick 的 cand 就是【同一次決策的候選集】
	var by_tick: Dictionary = {}
	for c in cand:
		var tk: int = int((c as Dictionary).get("tick", -1))
		if not by_tick.has(tk): by_tick[tk] = []
		(by_tick[tk] as Array).append(c)
	var tks: Array = by_tick.keys(); tks.sort()
	var shown: int = 0
	for tk2 in tks:
		if shown >= 12: break
		shown += 1
		var row: Array = []
		for c2 in (by_tick[tk2] as Array):
			var cd: Dictionary = c2
			row.append("%s=%.3f" % [String(cd.get("facility", "?")), float(cd.get("util", 0.0))])
		row.sort()
		print("  tick=%d day=%d 料=%.0f｜%s" % [int(tk2),
			int(tk2) / WorldState.TICKS_PER_DAY,
			float((by_tick[tk2] as Array)[0].get("team_material", 0.0)),
			"｜".join(PackedStringArray(row))])
	if tks.size() > 12:
		print("  …共 %d 輪，上面只印前 12 輪（★而這是【印】的截斷，不是【量】的截斷）" % tks.size())
	print("── ★★★【到底是誰開的工】—— ★兩條路各自計數──")
	print("  ①`_pick_facility` 選出來的（基建路，有比較 mint）：進場 %d 次，winner 樣本 %d 筆"
		% [_sum_prefix("pick."), (Probe.samples.get("infra.winner", []) as Array).size()])
	print("  ②`_ensure_rescue_build_started`（自救建田，★★facility 來自 `_food_rescue_eval` 而【不經過 `_pick_facility`】）= %d"
		% int(Probe.counts.get("survival.rescue_build", 0)))
	print("  （參考）construct.start = %d｜village.build_fired = %d"
		% [int(Probe.counts.get("construct.start", 0)), int(Probe.counts.get("village.build_fired", 0))])
	print("  ★★★自救路的 facility 選擇（驗收③）：")
	var _fr: Array = []
	for k5 in Probe.counts.keys():
		if String(k5).begins_with("food_rescue."):
			_fr.append("%s=%d" % [String(k5).substr(12), int(Probe.counts[k5])])
	_fr.sort()
	print("     %s" % "｜".join(PackedStringArray(_fr)))
	print("  ★驗收④續蓋回歸：food_rescue.inprogress_continue = %d（★★修法前後應相同）"
		% int(Probe.counts.get("food_rescue.inprogress_continue", 0)))
	print("  ★修法前：兩條路【從不互相比較】—— 自救建田直接拿 `_food_rescue_eval` 選定的 facility 去蓋。")
	print("  ★★修法後：自救路的選擇迴圈改呼 `_pick_facility` ⇒ 兩條路同秤。")
	print("  ★★★讀法：上面 `pick.<facility>` 列出自救路現在選了什麼；若還是 farming 就是修法沒接上。")
	print("  ★讀法：mint 有沒有出現在候選裡是第一問（沒出現＝被三道過濾濾掉，不是輸）；")
	print("     ★★出現了而 util 輸 farming ⇒ 才是【優先序】；★★★而一個沒糖的村先蓋田可能完全合理。")
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

func _sum_prefix(pfx: String) -> int:
	var n: int = 0
	for k in Probe.counts.keys():
		if String(k).begins_with(pfx) and String(k).contains(".entry"): n += int(Probe.counts[k])
	return n
