extends SceneTree
# @bed-kind: acceptance
# slice: 批二① SEEK_TILE_RANGE → SEEK_DAYS × 該隊真速度
#
# ★★★本床【分開報兩種世界】（spec §4 最特別的一格）：
#   radius ≤ 15（含 warring_states）：舊版那個 `d > max_range` continue 從沒 fire
#     ⇒ 本票在那裡是【引入一個新的限制】
#   radius ≥ 16：它一直在 fire，而且對所有隊都是同一個 30
#     ⇒ 本票在那裡是【把錯的值換成對的值】
#   ⇒ 兩件不同的事，不得混成一句「差異化成立」。

const OLD_RANGE: int = 30   # ★舊常數，寫死在床裡當反事實對照（production 已刪）

var _fails: int = 0
var _sections: int = 0
const EXPECT_SECTIONS: int = 4

func _initialize() -> void:
	print("=== SEEK RANGE FROM REAL MOVE COST ===")
	_test_single_source()
	_report_world("res://config/warring_states.json", 14)
	_report_world("res://config/infonet_moderate_distress_fragility.json", 24)
	# ★★★第三個世界（radius 40）：前兩個都 eff=0，而【0 有兩種意思】——
	#   ①上界從來不 binding（地形太密）②改動沒穿透。★分辨它的唯一辦法是找一個【地圖夠大】的世界。
	_report_world("res://config/infonet_recovery_r3_relocate.json", 40)
	if _sections != EXPECT_SECTIONS:
		_fails += 1
		push_error("[FAIL] 只跑完 %d/%d 段 —— 中途崩掉" % [_sections, EXPECT_SECTIONS])
	print("=== DONE === SECTIONS=%d/%d FAILS=%d" % [_sections, EXPECT_SECTIONS, _fails])
	quit()

func _ok(cond: bool, msg: String) -> void:
	if cond:
		print("  PASS: " + msg)
	else:
		_fails += 1
		push_error("[FAIL] " + msg)

func _count(hay: String, needle: String) -> int:
	var n: int = 0
	var from: int = 0
	while true:
		var i: int = hay.find(needle, from)
		if i == -1:
			break
		n += 1
		from = i + 1
	return n

func _test_single_source() -> void:
	print("-- ④ 同源：tiles_per_day 在 goal_resolver 裡只算一次 --")
	var needle: String = "WorldState.TICKS_PER_DAY) / float(maxi("
	# ★成對對照先跑：自造兩次 ⇒ 必須數到 2（否則「真檔數到 1」是恆真）
	var fake: String = "a = float(%s x, 1))\nb = float(%s y, 1))" % [needle, needle]
	_ok(_count(fake, needle) == 2, "④對照：合成的兩次要數到 2（實得 %d）" % _count(fake, needle))
	var f := FileAccess.open("res://scripts/simulation/decision/goal_resolver.gd", FileAccess.READ)
	if f == null:
		_fails += 1
		push_error("[FAIL] 讀不到 goal_resolver.gd")
		_sections += 1
		return
	var src: String = f.get_as_text()
	f.close()
	var got: int = _count(src, needle)
	_ok(got == 1, "④真檔只算一次（實得 %d）⇒ ETA 與 seek 半徑共用同一個計算點" % got)
	_sections += 1

func _report_world(cfg: String, radius: int) -> void:
	var kind: String = "【引入新限制】radius %d ≤ 15：舊 continue 從沒 fire" if radius <= 15 \
		else "【把錯的值換成對的值】radius %d ≥ 16：舊版一直在 fire 且對所有隊都是 30"
	print("-- %s --" % [kind % radius])
	seed(1337)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var first_stall: int = -1
	for tick in range(WorldState.TICKS_PER_DAY):
		if runner.advance_tick(state, Vector2i(-1, -1)) != "" and first_stall == -1:
			first_stall = tick
	print("  [有效窗] 1 天｜首次非推進：%s" % ("無" if first_stall == -1 else str(first_stall)))
	var slow: Array = []      # tiles/day < 4 ⇒ 半徑該 < 28
	var blind: Array = []     # 半徑 < 1 ⇒ 把慢變成瞎（不得發生）
	var ranges: Array = []
	var diff_target: int = 0  # ★eff：找到的目標與舊版不同（逐隊 × 逐地形）
	var diff_by_terrain: Array = []
	var canary: int = 0       # ★⑥絕境金絲雀（只印不判）
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		var tpd: float = GoalResolver._tiles_per_day(state, t)
		var r: int = GoalResolver.seek_range_tiles(state, t)
		ranges.append(r)
		if tpd < 4.0:
			slow.append("T%d(%.2f→%d格)" % [tid, tpd, r])
		if r < 1:
			blind.append(tid)
		# ★★★不能只測一種地形：forest 到處都是 ⇒ 兩版都找得到最近的那一格 ⇒ eff 恆 0，
		#   而那個 0 會被讀成「這張票沒穿透」——實際是【我只問了一個問不出差別的問題】。
		#   ⇒ 掃 REGEN_RATE 的全部地形（＝真正的 seek 母體），逐地形比對。
		for terr in ResourceSystem.REGEN_RATE:
			var new_p: Vector2i = GoalResolver.find_nearest_terrain_tile(state, t, String(terr), r)
			var old_p: Vector2i = GoalResolver.find_nearest_terrain_tile(state, t, String(terr), OLD_RANGE)
			if new_p != old_p:
				diff_target += 1
				if diff_by_terrain.size() < 8:
					diff_by_terrain.append("T%d/%s(%d格:%s→%s)" % [tid, String(terr), r,
						("有" if old_p != Vector2i(-1, -1) else "無"), ("有" if new_p != Vector2i(-1, -1) else "無")])
		# ★⑥絕境金絲雀：半徑【內】零候選、而半徑【外】有候選的絕境隊（任一地形）
		var ctx: DecisionContext = DecisionContext.gather(state, t)
		if ctx.food_days < ctx.desperation_entry_threshold:
			for terr2 in ResourceSystem.REGEN_RATE:
				if GoalResolver.find_nearest_terrain_tile(state, t, String(terr2), r) == Vector2i(-1, -1) 						and GoalResolver.find_nearest_terrain_tile(state, t, String(terr2), OLD_RANGE) != Vector2i(-1, -1):
					canary += 1
					break
	# ★★★決定性診斷（eff=0 的分解）：上界只有在【它小於最近目標的距離】時才 binding。
	#   ⇒ 量真實的「最近目標距離」，否則 eff=0 分不出【上界沒被碰到】與【改動沒穿透】。
	var far: int = 0
	var far_named: Array = []
	for tid3 in state.teams:
		var t3: TeamData = state.teams[tid3]
		for terr3 in ResourceSystem.REGEN_RATE:
			var p3: Vector2i = GoalResolver.find_nearest_terrain_tile(state, t3, String(terr3), 9999)
			if p3 == Vector2i(-1, -1):
				continue
			var d3: int = FactionAISystem._hex_dist(t3.tile_pos, p3)
			if d3 > far:
				far = d3
				far_named = ["T%d/%s=%d格" % [tid3, String(terr3), d3]]
			elif d3 == far and far_named.size() < 4:
				far_named.append("T%d/%s=%d格" % [tid3, String(terr3), d3])
	print("  ★最遠的「最近目標」＝ %d 格（%s）｜而最小半徑 = %d 格" % [
		far, ", ".join(far_named), int(ranges.min()) if ranges.size() > 0 else -1])
	ranges.sort()
	var n: int = ranges.size()
	print("  半徑分布：min=%d median=%d max=%d（舊版全部都是 %d）" % [
		int(ranges[0]), int(ranges[n / 2]), int(ranges[n - 1]), OLD_RANGE])
	print("  ★慢隊（tiles/day < 4）%d 支：%s" % [slow.size(), ", ".join(slow.slice(0, mini(6, slow.size())))])
	print("  ★eff（隊×地形：靶與舊版不同）%d / %d 組｜★⑥絕境金絲雀 %d 支（只印不判）" % [
		diff_target, n * ResourceSystem.REGEN_RATE.size(), canary])
	if diff_by_terrain.size() > 0:
		print("    具名：%s" % ", ".join(diff_by_terrain))
	else:
		print("    ★沒有任何一組改變 ⇒ 這個世界裡新舊上界【對結果沒有差別】（見卷面末的判讀）")
	if radius <= 15:
		print("  ★★這個世界裡舊版的 continue 從沒 fire（全圖跨度 < 30）⇒ 上面的 eff 全部是【新引入的限制】")
	else:
		print("  ★★這個世界裡舊版一直在 fire ⇒ 上面的 eff 是【錯的值換成對的值】")
	# 斷言只掛【慢隊那一端】：快隊上限 126 而地圖跨度小得多 ⇒ 結構性不可觀測
	var slow_bad: Array = []
	for tid in state.teams:
		var t2: TeamData = state.teams[tid]
		if GoalResolver._tiles_per_day(state, t2) < 4.0 and GoalResolver.seek_range_tiles(state, t2) >= 28:
			slow_bad.append(tid)
	_ok(slow_bad.is_empty(), "①慢隊半徑 < 28（違反的隊：%s）" % [str(slow_bad)])
	_ok(blind.is_empty(), "⑤沒有隊被算成半徑 0（把慢變成瞎的隊：%s）" % [str(blind)])
	_sections += 1
