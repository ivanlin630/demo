extends SceneTree
# ★形狀表的【機械 falsifier】（systems 裁 2026-08-25）。
#
# ★存在理由：形狀表 `AcquisitionPaths.SHAPE_TABLE` 是一張【手工表】，
#   而手工表准留的唯一條件是 —— ★「這張表變錯的時候，誰會發現？」有機械答案才准留。
#   本床就是那個機械答案。
#
# ★做法：跑一輪開 driver_ledger 的世界 → 掃所有【delta > 0】的 (資源, reason) 對
#        → 任何一個資源【形狀 unknown】＝ 紅。
#   ★這比「新 resource 未分類＝紅」多抓一種：★舊 resource 長出【新的增加路徑】
#     （例：某天有人給 gem 加了 regen ⇒ 它就不再是純 stock）。
#
# ★★分類按【出處】不按【字面】：只認 `kind == "resource"` 的紀錄。
#   `field` 是混雜欄（tags/readiness/solo_intent/loyalty/coin 與真資源同欄）⇒
#   直接掃 field 會把 `tags` 當資源（同 constitution_gate fingerprint 踩過的混雜命中）。
#
# ★driver_ledger 的三個限制（world_state:122-123）：預設關、ring-buffer cap=4096(TEST VALUE)、
#   冷啟動記不到 ⇒ ★它是【離線稽核】工具，不准接進 runtime 決策路徑。
# env：LW_CONFIG(peaceful_economy)、ADHOC_DAYS(30)、PERF_SEED(1337)、PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = OS.get_environment("LW_CONFIG") if OS.get_environment("LW_CONFIG") != "" else "peaceful_economy"
	var days: int = int(OS.get_environment("ADHOC_DAYS")) if OS.get_environment("ADHOC_DAYS") != "" else 30
	var sd: int = int(OS.get_environment("PERF_SEED")) if OS.get_environment("PERF_SEED") != "" else 1337
	var out_path: String = OS.get_environment("PERF_OUT")
	seed(sd)
	WorldState.driver_ledger_enabled = true
	WorldState.clear_driver_ledger()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config 載入失敗"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	# ★每 N tick 抽乾一次 ledger：ring-buffer cap=4096 會吃掉早期紀錄，
	#   不抽乾的話「掃過整輪」是假的（★同族：讀到半成品當完整資料）。
	var pairs: Dictionary = {}
	for tick in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.teams.is_empty(): break
		if (tick + 1) % 500 == 0:
			_drain(pairs)
	_drain(pairs)
	WorldState.driver_ledger_enabled = false

	var lines: Array = []
	lines.append("=== resource-shape falsifier: config=%s days=%d seed=%d ===" % [cfg, days, sd])
	var unknown: Array = []
	var by_shape: Dictionary = {}
	for res in pairs.keys():
		var shape: String = AcquisitionPaths.shape_of(String(res))
		by_shape[shape] = int(by_shape.get(shape, 0)) + 1
		if shape == "unknown":
			unknown.append("%s　(reason: %s)" % [String(res), str((pairs[res] as Dictionary).keys())])
	lines.append("  掃到【真的會增加】的資源 = %d 種（★按資源分群，不按 reason 字面）" % pairs.size())
	for s2 in by_shape:
		lines.append("    %-16s = %d 種" % [String(s2), int(by_shape[s2])])
	if unknown.is_empty():
		lines.append("★PASS 形狀表覆蓋所有【真的會增加】的資源")
	else:
		unknown.sort()
		lines.append("★FAIL 未分類（形狀 unknown）：")
		for u in unknown:
			lines.append("    " + u)
		lines.append("  ⇒ 這些資源【真的有增加路徑】卻不在形狀表上 —— 補分類，或說明為什麼不需要。")
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()

func _drain(pairs: Dictionary) -> void:
	for e in WorldState.driver_ledger:
		if String(e.get("kind", "")) != "resource":
			continue   # ★只認出處＝bank 的紀錄，不靠字面猜
		if float(e.get("delta", 0.0)) <= 0.0:
			continue   # 只問「增加路徑」
		# ★★分群鍵是【(kind, 資源名)】，reason 只當【人看的說明】不當分類鍵。
		#   血證：同一個 `wild_game` 有兩種拼法並存——
		#   `regen_wild_game`（harvest_system）與 `regen_wildgame`（resource_system:141）。
		#   按 reason 字面分群 ⇒ 一個資源算成兩條路徑；更糟的是分類表登記了其中一個拼法，
		#   另一個【靜默漏掉】⇒ ★falsifier 自己變成盲點來源。
		var _res: String = String(e.get("field", ""))
		if not pairs.has(_res):
			pairs[_res] = {}
		(pairs[_res] as Dictionary)[String(e.get("reason", ""))] = true
	WorldState.clear_driver_ledger()
