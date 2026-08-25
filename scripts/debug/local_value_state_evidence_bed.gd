extends SceneTree
# ★接線的【執行證據】：`fp` 不變只證等價、不證執行（03_implementer 案例本體）。
#   本床讀 `local_value.*` 三顆 tap，回答三個【不同】的問題：
#     calls                    ＝ 這條估值路有沒有在跑（分母）
#     calls_with_state         ＝ 有多少次是【接線後】的呼叫（傳了 state）
#     state_changes_stock      ＝ ★其中有多少次，傳 state 真的看到不一樣的庫存（＝真的改了估值）
#   ★三顆缺一：只看第三顆的 0 分不出「沒走到」與「走到了但庫存本來就一樣」。
# env：LW_CONFIG / PERF_SEED / ADHOC_DAYS / PERF_OUT

func _initialize() -> void:
	_run(); quit()

func _run() -> void:
	var cfg: String = _env("LW_CONFIG", "warring_states")
	var days: int = int(_env("ADHOC_DAYS", "30"))
	var sd: int = int(_env("PERF_SEED", "1337"))
	var out_path: String = _env("PERF_OUT", "")
	print("=== local_value state 執行證據：config=%s days=%d seed=%d ===" % [cfg, days, sd])
	seed(sd)
	Probe.enabled = true
	Probe.reset()
	FactionAISystem._a2b_remote_tribute_payers.clear()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config("res://config/%s.json" % cfg)
	if config.is_empty():
		print("[FAIL] config 載入失敗"); return
	config["seed"] = sd
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	for _t in range(days * WorldState.TICKS_PER_DAY):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.teams.is_empty(): break
	var lines: Array = []
	var calls: int = int(Probe.counts.get("local_value.calls", 0))
	var withs: int = int(Probe.counts.get("local_value.calls_with_state", 0))
	var diff: int = int(Probe.counts.get("local_value.state_changes_stock", 0))
	lines.append("[%s day %d seed %d] teams=%d" % [cfg, days, sd, state.teams.size()])
	lines.append("  local_value.calls               = %d   （分母：這條估值路有在跑嗎）" % calls)
	lines.append("  local_value.calls_with_state    = %d   （接線後的呼叫；★blind 呼叫 = %d）" % [withs, calls - withs])
	lines.append("  local_value.state_changes_stock = %d   （★其中真的看到不一樣的庫存）" % diff)
	if withs > 0:
		lines.append("  ⇒ 接線覆蓋率 = %.1f%%（with_state / calls）" % (100.0 * withs / maxf(calls, 1)))
		lines.append("  ⇒ ★真改變估值的比例 = %.1f%%（changes / with_state）" % (100.0 * diff / maxf(withs, 1)))
	for k in Probe.counts.keys():
		if String(k).begins_with("local_value.state_changes_stock."):
			lines.append("      %-40s = %d" % [String(k), int(Probe.counts[k])])
	lines.append("--- 判讀 ---")
	if calls == 0:
		lines.append("  ★這張床上這條估值路【完全沒跑】⇒ 這裡的 0 什麼都不能證明（換床）")
	elif withs == 0:
		lines.append("  ★有跑但【一次都沒傳 state】⇒ 接線沒生效（是 bug，回頭查）")
	elif diff == 0:
		lines.append("  ★有傳 state 但庫存從未不同 ⇒ 這些隊【本來就沒有糧倉/公庫】")
		lines.append("     ⇒ fp 不變是【世界沒有可改變的東西】，不是接線沒接上（兩者不可互換）")
	else:
		lines.append("  ★接線真的改變了估值 ⇒ fp 應該要變；若 fp 沒變，要另外解釋")
	var text: String = "\n".join(PackedStringArray(lines))
	print("\n" + text)
	if out_path != "":
		var f := FileAccess.open(out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(text + "\n"); f.close()
	print("=== local_value state 執行證據 DONE ===")

func _env(key: String, dflt: String) -> String:
	var v: String = OS.get_environment(key)
	return v if v != "" else dflt
