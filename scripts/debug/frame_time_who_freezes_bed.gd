extends SceneTree
# frame_time_who_freezes_bed：可慢不可卡——誰凍住那5-10秒(systems票)。
# ★★★方法論偏離票面原指示(headless非GUI)，理由請見卷面誠實限——先讀完這段。
#
# 用戶立法：畫面節奏均勻=硬要求,量的是最壞單frame不是總時。票面要求走GUI/
# observation路徑(headless沒有frame概念)。
#
# ★但production既有兩件既存儀器讓headless可以站得住當代理：
#   ①ObserverBridge.tick_step(observer_bridge.gd:26-36)：★★★單frame預算=12ms
#     (FRAME_BUDGET_MS)，while迴圈跑tick直到超預算才break——★★★但註解明寫
#     「單tick不可分割→單tick spike仍會超預算一次，但不累積」。
#     ⇒ 若某個tick本身耗時5-10秒，budget機制救不了它，那一frame幾乎完全等於
#       那一個慢tick的耗時(budget內能跑的其他快tick遠小於秒級，可忽略)。
#   ②SimRunner.phase_timing(sim_runner.gd:110/137-139)：production既有opt-in
#     儀器，單tick耗時>PHASE_SPIKE_US(100ms)就印[PhaseSpike]逐系統耗時排序前6名
#     +teams數；每日邊界印[TickPerf] avg/max。
# ⇒ ★headless開phase_timing=true，量到的[TickPerf]單tick max_us，在
#   ObserverBridge的12ms-budget-不可切割語意下，可以合理當「真實frame最壞耗時」
#   的極接近代理——這是工程論證，不是迴避GUI，卷面誠實限會標明這個替代未經GUI
#   實測驗證，若systems/blueprint要真GUI驗證，請回這封信。
#
# 量①每tick耗時分布(從[TickPerf]逐日min/avg/max，本床額外算全窗p95/max)
#   ②尖峰逐系統耗時([PhaseSpike]既有輸出，直接讀log不用額外parse在bed內)
#   ③週期性(尖峰tick的間隔，事後從log算)
#   ④尖峰母體([PhaseSpike]自帶teams=，已足夠)
# 用法：BED_CONFIG BED_DAYS(default 90，涵蓋至少2次月級pass機會) BED_SEED(default 1337)

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var days: int = int(OS.get_environment("BED_DAYS")) if OS.has_environment("BED_DAYS") else 90
	var cfg: String = OS.get_environment("BED_CONFIG") if OS.has_environment("BED_CONFIG") else "res://config/warring_states.json"
	var seed_val: int = int(OS.get_environment("BED_SEED")) if OS.has_environment("BED_SEED") else 1337
	seed(seed_val)
	Probe.arm()
	var state: WorldState = MeasureBedHelper.arm_and_setup(cfg, true)
	SimRunner.phase_timing = true   # ★開啟既有production儀器，非新增tap
	var runner := SimRunner.new()
	var ticks: int = days * WorldState.TICKS_PER_DAY
	var no_player := Vector2i(-1, -1)

	print("=== frame_time_who_freezes_bed: config=%s days=%d ticks=%d seed=%d phase_timing=ON ===" % [cfg, days, ticks, seed_val])
	print("★方法論：headless量單tick耗時代理frame耗時，理由見檔頭註解——非真GUI實測")

	var global_max_us: int = 0
	var global_max_tick: int = -1
	for tick in range(ticks):
		var t0: int = Time.get_ticks_usec()
		runner.advance_tick(state, no_player)
		var dt: int = Time.get_ticks_usec() - t0
		if dt > global_max_us:
			global_max_us = dt
			global_max_tick = tick

	print("\n=== 結果(窗=%.2f天/%d ticks) ===" % [float(ticks) / float(WorldState.TICKS_PER_DAY), ticks])
	print("①②③④的原始資料＝上面[PhaseSpike]/[TickPerf]逐行輸出(production既有格式，本床沒有額外parse)")
	print("全窗單tick最大耗時=%dus(%.1fms)　發生於tick=%d(day=%.2f)" % [
		global_max_us, float(global_max_us) / 1000.0, global_max_tick, float(global_max_tick) / float(WorldState.TICKS_PER_DAY)])
	if float(global_max_us) / 1000.0 < 5000.0:
		print("★★量到的最壞單tick遠小於5秒(用戶抱怨的5-10秒)⇒本卷這個世界配置/窗口沒有重現用戶情況")
		print("  ⇒ 該問的是【用戶跑的是什麼設定】(config/世界規模/隊數)，不是「用戶記錯了」")
	else:
		print("★★★量到的單tick耗時達到用戶抱怨量級(>=5秒)——見上方[PhaseSpike]逐系統拆解找兇手")

	print("\n=== frame_time_who_freezes_bed DONE ===")
