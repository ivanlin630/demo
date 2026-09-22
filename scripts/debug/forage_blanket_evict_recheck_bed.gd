# @bed-kind: diagnostic
# forage_blanket_evict_recheck_bed：subteam-idle①複驗——「覓食subteam抵達後被blanket歸建」症狀
# 在main HEAD(世代6/HW-2)量：subteam.forage_arrived(①-b母體)、merge.forage_blanket_evicted(①-a分子)、
# collect.forage_subteam_task_collected(①-a分母:真的採集次數)。純觀測，不改production邏輯。
# 用法：SPECIMEN_SEED(default 1337) SPECIMEN_MONTHS(default 3)
extends SceneTree

const LIVE_CP_EVERY: int = 2000   # ★分段輸出間隔須小於預期跑到的長度（03b測量七母題血證）

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var seed_val: int = int(OS.get_environment("SPECIMEN_SEED")) if OS.has_environment("SPECIMEN_SEED") else 1337
	var months: int = int(OS.get_environment("SPECIMEN_MONTHS")) if OS.has_environment("SPECIMEN_MONTHS") else 3
	seed(seed_val)
	var config_path: String = OS.get_environment("WARRING_CONFIG") if OS.get_environment("WARRING_CONFIG") != "" else "res://config/warring_states.json"
	var config: Dictionary = GameSetup.load_config(config_path)
	config["seed"] = seed_val
	var state: WorldState = MeasureBedHelper.arm_and_setup(config)   # ★bed-arm閘要求(systems 2026-09-22修正符號)
	print(MeasureBedHelper.arm_order_report())
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var runner := SimRunner.new()

	var total_ticks: int = months * WorldState.TICKS_PER_MONTH
	var no_player := Vector2i(-1, -1)
	print("=== forage_blanket_evict_recheck_bed: seed=%d months=%d ===" % [seed_val, months])
	for tick in range(total_ticks):
		runner.advance_tick(state, no_player)
		if tick % 5000 == 0:
			print("[progress] tick=%d teams=%d" % [tick, state.teams.size()])
		if tick % LIVE_CP_EVERY == 0 and tick > 0:
			print("[LIVE-CHECKPOINT] tick=%d subteam.forage_arrived=%d merge.forage_blanket_evicted=%d collect.forage_subteam_task_collected=%d collect.l0_forage_ran=%d" % [
				tick, Probe.counts.get("subteam.forage_arrived", 0), Probe.counts.get("merge.forage_blanket_evicted", 0),
				Probe.counts.get("collect.forage_subteam_task_collected", 0), Probe.counts.get("collect.l0_forage_ran", 0)])
		if state.teams.is_empty():
			break

	var arrived: int = Probe.counts.get("subteam.forage_arrived", 0)
	var evicted: int = Probe.counts.get("merge.forage_blanket_evicted", 0)
	var collected: int = Probe.counts.get("collect.forage_subteam_task_collected", 0)
	print("\n=== FINAL ===")
	print("★母體(①-b) subteam.forage_arrived=%d" % arrived)
	print("★分子(①-a) merge.forage_blanket_evicted=%d" % evicted)
	print("★分母對照 collect.forage_subteam_task_collected(真的採集次數)=%d" % collected)
	if arrived > 0:
		print("★★比例 evicted/arrived=%.4f" % (float(evicted) / float(arrived)))
	else:
		print("★★母體=0 ⇒ 不可判（不是綠）")

	# ①-c thrash 樣子（proxy）：以 parent team_id 分組，窗內同一 parent 產生的 forage-arrival 事件數分佈
	var samples: Array = Probe.samples.get("subteam.forage_arrived_sample", []) as Array
	print("\n=== ①-c thrash proxy（按 parent team_id 分組的 forage-arrival 事件數；samples cap=1000） ===")
	print("★samples.size()=%d（若=1000 為 cap，後續事件未收錄，不可讀成「沒發生」）" % samples.size())
	var per_parent: Dictionary = {}
	for s in samples:
		var d: Dictionary = s as Dictionary
		var p: int = int(d.get("parent", -1))
		per_parent[p] = per_parent.get(p, 0) + 1
	var dist: Dictionary = {}   # 事件數 bucket -> 幾個 parent
	for p in per_parent.keys():
		var c: int = per_parent[p]
		var bucket: String = str(c) if c <= 5 else "6+"
		dist[bucket] = dist.get(bucket, 0) + 1
	print("distinct parent 數=%d ／ 分佈(事件數->parent數)=%s" % [per_parent.size(), str(dist)])

	print("=== DONE ===")
