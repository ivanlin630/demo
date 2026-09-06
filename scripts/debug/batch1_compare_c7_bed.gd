extends SceneTree
# batch1_compare_c7_bed：batch1-compare規格⑦(per-team執行次數vs距錨點距離，至少三系統)
# 零新tap：既有 sysexec.collect.byteam.%04d / sysexec.vision.byteam.%04d / sysexec.fatigue.byteam.%04d
# （resource_system/vision_system/sim_runner，本身就是為驗收②這格設計的，註解寫著「第X個系統」）。
# ★誠實限先講：這三個sysexec tap是⑧批才加的——①世界(daaabc46)完全沒有(已grep驗證)，
#   所以①世界這格【量不到，非0】。
# 錨點：不猜地圖尺寸常數，用【期末所有現存隊tile_pos的重心】當錨點（純觀測，零假設）。
# 用法：BED_CONFIG(default res://config/peaceful_economy.json) BED_DAYS(default 90) BED_SEED(default 1337)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 90
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/peaceful_economy.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	print("=== batch1_compare_c7_bed: config=%s days=%d ticks=%d seed=%d ===" % [cfg, days, ticks, seed_val])

	for tick in range(ticks):
		runner.advance_tick(state, no_player)
		if tick % 20000 == 0 and tick > 0:
			print("[CHECKPOINT] tick=%d teams=%d" % [tick, state.teams.size()])

	print("\n=== ⑦ per-team執行次數 vs 距錨點距離 ===")
	var has_any_sysexec: bool = false
	for k in Probe.counts.keys():
		if String(k).begins_with("sysexec."):
			has_any_sysexec = true
			break
	if not has_any_sysexec:
		print("★sysexec.*不存在(批前世界無此tap，量不到，非0)")
		print("=== batch1_compare_c7_bed DONE ===")
		return

	# 錨點：期末現存隊tile_pos重心
	var cx: float = 0.0; var cy: float = 0.0; var n: int = 0
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		cx += t.tile_pos.x; cy += t.tile_pos.y; n += 1
	if n == 0:
		print("★母體=0(無現存隊)⇒不可判")
		print("=== batch1_compare_c7_bed DONE ===")
		return
	cx /= n; cy /= n
	print("錨點(現存隊重心)=(%.1f, %.1f)　現存隊數=%d" % [cx, cy, n])

	var systems: Array = ["collect", "vision", "fatigue"]
	for sys in systems:
		print("\n--- 系統=%s ---" % sys)
		var rows: Array = []   # [team_id, dist, exec_count]
		for tid in state.teams:
			var t: TeamData = state.teams[tid]
			var dist: float = Vector2(t.tile_pos.x - cx, t.tile_pos.y - cy).length()
			var cnt: int = int(Probe.counts.get("sysexec.%s.byteam.%04d" % [sys, tid], 0))
			rows.append([tid, dist, cnt])
		rows.sort_custom(func(a, b): return a[1] < b[1])   # 按距離排序
		for r in rows:
			print("  team=%d 距錨點=%.1f 執行次數=%d" % [r[0], r[1], r[2]])
		# 粗分近/遠兩組看有沒有系統性差異
		var mid: int = int(rows.size() / 2.0)
		var near_sum: float = 0.0; var far_sum: float = 0.0
		for i in range(rows.size()):
			if i < mid: near_sum += rows[i][2]
			else: far_sum += rows[i][2]
		var near_avg: float = near_sum / maxf(mid, 1.0)
		var far_avg: float = far_sum / maxf(rows.size() - mid, 1.0)
		print("  近半(%d隊)平均執行次數=%.1f　遠半(%d隊)平均執行次數=%.1f　比值(遠/近)=%.3f" % [
			mid, near_avg, rows.size() - mid, far_avg, (far_avg / near_avg) if near_avg > 0.0 else -1.0])

	print("=== batch1_compare_c7_bed DONE ===")
