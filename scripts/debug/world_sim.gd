extends SceneTree

# 純 NPC 世界長期量測台。無玩家 → 不觸發絕後 game_over → 世界跑滿 max_ticks。
# 量因果脊椎長期 emergent（立國/vendetta/誘殺/scout/鑄幣）。純觀測。

func _initialize() -> void:
	_run()
	quit()

func _run() -> void:
	print("=== world_sim: 純 NPC 長期量測 ===")
	Probe.enabled = true
	Probe.reset()
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/world_sim.json")
	if config.is_empty():
		print("[FAIL] config/world_sim.json 載入失敗")
		Probe.enabled = false
		return
	GameSetup.setup(state, config)
	if state.player_id != -1:
		print("[WARN] player_id=%d（預期 -1 無玩家）" % state.player_id)
	var max_ticks: int = int(config.get("max_ticks", 172800))
	print("[world_sim] max_ticks=%d (%.1f 年) teams=%d" % [
		max_ticks, max_ticks / 86400.0, state.teams.size()])

	var no_player := Vector2i(-1, -1)
	var alive_zero_streak := 0
	for tick in range(max_ticks):
		runner.advance_tick(state, no_player)
		# encounter 超時防卡（無玩家驅動 → 逾時強制 draw）
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		# 月取樣（長跑免 log 爆）
		if (tick + 1) % (240 * 30) == 0:
			var month: int = (tick + 1) / (240 * 30)
			print("[world_sim] === 月 %d (tick=%d) 存活隊=%d ===" % [month, tick + 1, state.teams.size()])
			TeamTrace.dump(state, tick + 1)
			SpineTrace.dump(state, tick + 1)
		# 周期不變量
		if (tick + 1) % 240 == 0:
			_check_inv(state, tick + 1)
		# 世界全滅 → 提早收尾（連續 3 取樣存活 0）
		if state.teams.is_empty():
			alive_zero_streak += 1
			if alive_zero_streak >= 3:
				print("[world_sim] 世界全滅 @ tick=%d → 提早收尾" % (tick + 1))
				break
		else:
			alive_zero_streak = 0

	print("[world_sim] 不變量違反累計=%d" % _inv_violations)
	Probe.summary()
	Probe.enabled = false
	print("=== world_sim DONE ===")

var _inv_violations := 0
func _check_inv(state: WorldState, tick: int) -> void:
	# 複用既有 InvariantAudit.check（與 headless_test 同來源；回違反訊息 Array，空=一致）
	var v: Array = InvariantAudit.check(state)
	if not v.is_empty():
		_inv_violations += v.size()
		print("[InvariantViolation] tick=%d 違反 %d 例:%s" % [tick, v.size(), str(v[0])])
