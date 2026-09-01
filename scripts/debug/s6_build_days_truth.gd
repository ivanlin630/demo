extends SceneTree
# @observe-pure
# ★★★S6 前置：一座 farm 工地【實際花幾個遊戲日】—— ★量字面量，不量代理量。
#
# ★不用 build_eta_days()（那是【估算器】，而估算器正是要查的東西）。
# ★★也不用「重寫一遍那個迴圈」——既有床 build_eta_single_source_test 的 _simulate_days
#   是【副本】，副本對不代表 production 對（S5a 那次我就被自己的副本騙過一輪）。
# ★★★這裡呼叫【真的 production 函式】OutpostSystem.tick_all(state)，
#   照它在 registry 裡的 LOD_NEAR 節律（SimRunner.NEAR_CADENCE，讀常數不手抄），
#   一路跑到 construction_ticks_left <= 0，數經過幾個 world tick。
#
# ★★誠實界限（先講）：本床【直接驅動 outpost_tick】而不是走完整 advance_tick。
#   ⇒ 它假設施工隊【全程留在 TASK_BUILD 且站在工地上】。
#   ★真實世界裡隊會跑掉（那是「手不聽腦」那條線的問題）——
#   ★★所以本床答的是【工期本身有多長】，不是【實際上多久蓋完】。兩者不同，別混。

func _initialize() -> void:
	_run(); quit()

# 取「全程唯一的那個 pop」；若不唯一回 -1（讓對照欄自己現形，而不是偷偷取第一個）
func _sole_pop(pop_seen: Dictionary) -> int:
	if pop_seen.size() == 1:
		return int(pop_seen.keys()[0])
	return -1

func _run() -> void:
	var pop: int = int(OS.get_environment("BED_POP")) if OS.has_environment("BED_POP") else 1
	var facility: String = OS.get_environment("BED_FACILITY") if OS.has_environment("BED_FACILITY") else "farming"
	var cost: int = int((OutpostSystem.FACILITY_DEF[facility]["cost"] as Dictionary)["ticks"])

	var state := WorldState.new()
	GameSetup.setup(state, GameSetup.load_config("res://config/peaceful_economy.json"))
	state.player_id = -1

	# 取一個既有 tile 與一支既有隊，把隊放到該格並設成建設中
	var tile: HexTileData = null
	for tid in state.world.tiles:
		tile = state.world.tiles[tid]
		break
	var team: TeamData = null
	for tid2 in state.teams:
		var t: TeamData = state.teams[tid2]
		if t.beast_kind == "":
			team = t
			break
	if tile == null or team == null:
		print("★FAIL：床拿不到 tile 或 team")
		return
	team.tile_pos = tile.tile_pos
	team.current_task = TeamData.TASK_BUILD
	# ★★★不能寫 team.population = pop：那顆是【唯讀衍生】(team_data.gd:55-59，setter 是 pass)
	#   ⇒ 賦值會被【靜默吞掉】，而床照樣印出「pop=1」＝ ★儀器說謊（第一跑就踩到：
	#     印 pop=1、實際 pop=6、每窗扣 6 ⇒ 0.5 天是錯的數字配對的參數）
	#   ⇒ 改成【動它的來源】：清 named + anon，只留 leader ⇒ 真 pop = 1
	team.named_members = []
	team.anon_cohorts = {}
	if team.leader_id == -1:
		print("★FAIL：這支隊沒有 leader，湊不出 pop=1")
		return
	tile.construction_ticks_left = cost
	tile.construction_team_id = team.team_id
	tile.construction_started_tick = -1
	tile.construction_target = {"facility": facility}

	Probe.reset(); Probe.enabled = true
	var os_sys := OutpostSystem.new()
	var start_tick: int = state.world.current_tick
	var windows: int = 0
	var guard: int = 0
	# ★節律從 registry 的常數讀（SimRunner.NEAR_CADENCE），不手抄數字
	var cadence: int = SimRunner.NEAR_CADENCE
	# ★★pop 是【讀來的】不是【設來的】：每窗記真值，收工核對是否全程同一個
	var pop_seen: Dictionary = {}
	var left_before: int = tile.construction_ticks_left
	var per_window_delta: Dictionary = {}
	while tile.construction_ticks_left > 0 and guard < 2000000:
		state.world.current_tick += 1
		guard += 1
		if state.world.current_tick % cadence == 0:
			# ★保險：真實世界裡隊可能被別的系統改掉 task；本床固定它（見檔頭誠實界限）
			team.current_task = TeamData.TASK_BUILD
			team.tile_pos = tile.tile_pos
			pop_seen[team.population] = int(pop_seen.get(team.population, 0)) + 1
			left_before = tile.construction_ticks_left
			os_sys.tick_all(state)
			var d: int = left_before - tile.construction_ticks_left
			per_window_delta[d] = int(per_window_delta.get(d, 0)) + 1
			windows += 1
	var end_tick: int = state.world.current_tick
	var ticks: int = end_tick - start_tick
	var days: float = float(ticks) / float(WorldState.TICKS_PER_DAY)

	var out: Array = []
	out.append("# S6 前置：一座 %s 工地實際花幾個遊戲日（★量字面量，非估算器）" % facility)
	out.append("# ★複驗所需的全部參數（★★否則『3 天』三個月後沒人能複驗）：")
	out.append("#   facility=%s  cost.ticks=%d  ★pop（【讀來的】真值分佈 pop→窗數）=%s"
		% [facility, cost, str(pop_seen)])
	out.append("#   ★每窗扣掉多少（delta→窗數）=%s  ★★這一欄是【真相源那行 ticks_left -= maxi(pop,1)】的字面觀測"
		% str(per_window_delta))
	out.append("#   TICKS_PER_HOUR=%d  TICKS_PER_DAY=%d  NEAR_CADENCE=%d"
		% [WorldState.TICKS_PER_HOUR, WorldState.TICKS_PER_DAY, SimRunner.NEAR_CADENCE])
	out.append("#   起 tick=%d  訖 tick=%d  經過 world tick=%d  outpost_tick 執行次數=%d"
		% [start_tick, end_tick, ticks, windows])
	out.append("#")
	out.append("## ★答案：%.4f 遊戲日" % days)
	out.append("#")
	out.append("# ★對照兩個預期（systems 給的，★我不往任一邊靠）：")
	out.append("#   ≈3 天   ⇒ cost.ticks 的單位是 person-hour ⇒ S6 表的「舊」欄低估 10 倍")
	out.append("#   ≈0.3 天 ⇒ S6 表是對的")
	out.append("#   ★★其他值 ⇒ 照實報")
	out.append("# ★★★而估算器怎麼說（★只當對照，不當答案）：build_eta_days = %.4f 天"
		% OutpostSystem.build_eta_days(cost, _sole_pop(pop_seen)))
	out.append("# ★誠實界限：本床直接驅動 outpost_tick，假設施工隊全程在崗")
	out.append("#   ⇒ 答的是【工期本身】，不是【實際上多久蓋完】（隊會不會跑掉是另一條線）")
	out.append("# construct tap：progress=%d  stall=%d"
		% [int(Probe.counts.get("construct.progress", 0)), int(Probe.counts.get("construct.stall", 0))])

	for l in out:
		print(l)
	var path: String = OS.get_environment("S6_OUT") if OS.has_environment("S6_OUT") \
		else "docs/measurements/2026-09-01-s6-build-days-truth.txt"
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(out)) + "\n"); f.close()
		print("落地：%s" % path)
	print("=== s6_build_days_truth DONE ===")
