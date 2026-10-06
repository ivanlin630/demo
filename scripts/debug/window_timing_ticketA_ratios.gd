extends SceneTree
# ★量測員派工（systems 2026-10-06）②：
# docs/superpowers/handbacks/2026-10-06-systems-to-measurer-team7-combat-trace-and-30day-cost.md ②
#
# 量：seed 1337 跑 7/10/15/30 天各耗幾秒（同機、跑前已確認 Godot 進程數=0）。
# 順手在每個窗印票 A 三格的分子/分母：
#   C1：宣稱建設/紮根的隊數中，material 全程零進出 且 建物欄全程零變化 的隊數
#       （分母=宣稱過的隊數，分子=宣稱且兩者都零效果的隊數）
#   C2：at_market 且 current_option=="貿易" 的 隊·日，其中當日 coin 淨額==0 的比例
#       （分母=這樣的隊·日數，分子=其中 coin_net==0 的）
#   C3："領取" 剛被 commit（current_option 從別的值變成"領取"）的次數，其中那一 tick coin
#       瞬時無變化的次數（分母=commit 次數，分子=瞬時 coin 不動的次數）
# ★操作定義是我自己訂的（信裡沒逐字給判準），寫清楚讓 systems 核對是否是他要的那個意思。
#
# 跑法：.\tools\godot.ps1 --headless --script scripts/debug/window_timing_ticketA_ratios.gd

const SEED: int = 1337
const WINDOWS_DAYS: Array = [7, 10, 15, 30]
const CLAIM_BUILDING_OPTS: Array = ["建設", "紮根"]
const FACILITY_LEVEL_FIELDS: Array = ["outpost_level", "camp_level", "farming_level",
	"manufacturing_level", "stable_level", "apothecary_level", "smelter_level",
	"weaponsmith_level", "armorsmith_level", "mint_level"]


func _initialize() -> void:
	var tree_sha: String = _git_head_sha()
	print("[TREE] HEAD=%s" % tree_sha)
	print("[SEED] %d" % SEED)

	var results: Array = []
	for n in WINDOWS_DAYS:
		print("\n########## N=%d 天 ##########" % n)
		var r: Dictionary = _run_window(int(n))
		results.append(r)
		print("[N=%d] 耗時=%.2fs｜C1=%d/%d｜C2=%d/%d｜C3=%d/%d" % [
			int(n), float(r["seconds"]), int(r["c1_num"]), int(r["c1_den"]),
			int(r["c2_num"]), int(r["c2_den"]), int(r["c3_num"]), int(r["c3_den"])])

	print("\n========== 彙總（seed 1337，同機） ==========")
	print("N天｜耗時(s)｜C1分子/分母｜C2分子/分母｜C3分子/分母")
	for r in results:
		print("%2d｜%7.2f｜%d/%d｜%d/%d｜%d/%d" % [
			int(r["days"]), float(r["seconds"]), int(r["c1_num"]), int(r["c1_den"]),
			int(r["c2_num"]), int(r["c2_den"]), int(r["c3_num"]), int(r["c3_den"])])

	var out_path: String = "docs/measurements/window-timing-ticketA-ratios.jsonl"
	var f: FileAccess = FileAccess.open(out_path, FileAccess.WRITE)
	f.store_line(JSON.stringify({"kind": "meta", "tree": tree_sha, "seed": SEED}))
	for r in results:
		f.store_line(JSON.stringify(r))
	f.close()
	print("\n[DUMP-PATH] %s" % out_path)
	print("=== window_timing_ticketA_ratios DONE ===")
	quit(0)


func _run_window(days: int) -> Dictionary:
	var t_start: int = Time.get_ticks_msec()
	seed(SEED)
	var ws: WorldState = MeasureBedHelper.arm_and_setup("res://config/default.json", false)
	var runner := SimRunner.new()
	var no_player := Vector2i(-1, -1)
	var day_len: int = WorldState.TICKS_PER_DAY

	var claimed_building: Dictionary = {}
	var material_prev: Dictionary = {}
	var material_moved: Dictionary = {}
	var building_sig_prev: Dictionary = {}
	var building_changed: Dictionary = {}

	var c2_num: int = 0; var c2_den: int = 0
	var c3_num: int = 0; var c3_den: int = 0
	var coin_prev_day: Dictionary = {}       # team_id → 上一日期末 coin
	var flagged_today: Dictionary = {}       # team_id → bool（今天有沒有出現 at_market+貿易）
	var coin_at_day_start: Dictionary = {}   # team_id → 今天開始時的 coin（給 C2 用，等同上一日期末）
	var prev_option: Dictionary = {}         # team_id → 上一 tick 的 current_option
	var prev_coin_tick: Dictionary = {}      # team_id → 上一 tick 的 coin（給 C3 瞬時比較）

	for day in range(days):
		for _i in range(day_len):
			runner.advance_tick(ws, no_player)
			for tid in ws.teams.keys():
				var t: TeamData = ws.teams[tid]
				if CLAIM_BUILDING_OPTS.has(String(t.current_option)):
					claimed_building[int(tid)] = true
				var coin_now: float = float(t.resources.get("coin", 0.0))

				# C2：at_market + 貿易 當日旗標
				var mtile: HexTileData = ws.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
				var at_market: bool = mtile != null and mtile.outpost_level > 0
				if at_market and String(t.current_option) == "貿易":
					flagged_today[int(tid)] = true

				# C3：「領取」剛被 commit（上一tick不是,這一tick是）
				var popt: String = String(prev_option.get(tid, ""))
				if String(t.current_option) == "領取" and popt != "領取":
					c3_den += 1
					var pcoin: float = float(prev_coin_tick.get(tid, coin_now))
					if is_equal_approx(pcoin, coin_now):
						c3_num += 1
				prev_option[tid] = t.current_option
				prev_coin_tick[tid] = coin_now

		# 日界：Q-material 累計
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

		# 日界：C2 結算（今天有旗標的隊，比對今天期末 coin vs 昨天期末 coin）
		for tid3 in ws.teams.keys():
			var t3: TeamData = ws.teams[tid3]
			var coin_end: float = float(t3.resources.get("coin", 0.0))
			if bool(flagged_today.get(tid3, false)) and coin_prev_day.has(tid3):
				c2_den += 1
				if is_equal_approx(float(coin_prev_day[tid3]), coin_end):
					c2_num += 1
			coin_prev_day[tid3] = coin_end
		flagged_today.clear()

	var claimed_n: int = 0; var c1_num: int = 0
	for tid4 in ws.teams.keys():
		if bool(claimed_building.get(tid4, false)):
			claimed_n += 1
			if not bool(material_moved.get(tid4, false)) and not bool(building_changed.get(tid4, false)):
				c1_num += 1

	var elapsed_s: float = float(Time.get_ticks_msec() - t_start) / 1000.0
	return {"days": days, "seconds": elapsed_s, "final_tick": ws.world.current_tick,
		"c1_num": c1_num, "c1_den": claimed_n, "c2_num": c2_num, "c2_den": c2_den,
		"c3_num": c3_num, "c3_den": c3_den}


func _building_signature(ws: WorldState, team_id: int) -> int:
	var sig: int = 0
	for tid in ws.world.tiles:
		var t: HexTileData = ws.world.tiles[tid]
		if int(t.outpost_owner) != int(team_id):
			continue
		for f in FACILITY_LEVEL_FIELDS:
			sig += int(t.get(f))
	return sig


func _git_head_sha() -> String:
	var out: Array = []
	OS.execute("git", ["rev-parse", "--short=9", "HEAD"], out, true)
	if out.size() > 0:
		return String(out[0]).strip_edges()
	return "UNKNOWN"
