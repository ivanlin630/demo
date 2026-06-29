extends SceneTree

# 餓死 measure（藍圖 2026-06-30「餓死=經濟底債優先，instrument 一隊食物收支，別猜」）。
# 量：戰國 seed 能人(野心≥0.6+統領≥0.4)的食物收支月軌跡——food/pop/burn(pop×2.4)/income(Δ+burn 推)/
#   tile(terrain/pool/outpost)/task + 累計餓死([Famine])。找赤字源:income<burn?無食源 tile?pop 太大?稅?
# 純量測，不改邏輯。

func _initialize() -> void:
	_run(); quit()

func _is_capable(state: WorldState, team: TeamData) -> bool:
	var lp: PersonData = state.persons.get(team.leader_id)
	if lp == null: return false
	return float(lp.values.get("野心", 0.0)) >= 0.6 and float(lp.skills.get("統領", 0.0)) >= 0.4

func _ledger(state: WorldState, tid: int, snap: Dictionary) -> String:
	var t: TeamData = state.teams.get(tid)
	if t == null: return "T%d: 死/併" % tid
	var food: float = float(t.resources.get("food", 0))
	var burn: float = float(t.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY \
		+ (float(t.resources.get("mounts", 0)) + float(t.resources.get("horses", 0))) * ResourceSystem.FOOD_PER_MOUNT_PER_DAY
	var days: float = food / maxf(burn, 0.001)
	var income: String = "NA"
	var net: String = "NA"
	if snap.has(tid):
		var inc: float = (food - float(snap[tid])) / 30.0 + burn
		income = "%.1f" % inc
		net = "%+.1f" % (inc - burn)
	snap[tid] = food
	var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
	var tile_str: String = "off_map"
	if tile != null:
		var gran: float = float(tile.public_storage.get("food", 0)) if tile.outpost_owner == tid else 0.0
		tile_str = "%s/pool=%.0f/op=%d/granary=%.0f" % [tile.terrain, float(tile.resources.get("food", 0)), tile.outpost_level, gran]
	var own_op: bool = ResourceSystem.own_granary_tile(state, t) != null
	return "T%d pop=%d food=%.0f days=%.1f burn/d=%.1f income/d=%s net/d=%s own_granary=%s tile=%s task=%s" % [
		tid, t.population, food, days, burn, income, net, own_op, tile_str, t.current_task]

func _run() -> void:
	print("=== food ledger diagnose: 能人為何餓死 (a 經濟底) ===")
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config := GameSetup.load_config("res://config/warring_states.json")
	if config.is_empty(): print("[FAIL] config"); return
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)
	var capable: Array = []
	for tid in state.teams:
		if _is_capable(state, state.teams[tid]): capable.append(tid)
	print("[food] 追蹤能人 = %s" % str(capable))
	var snap: Dictionary = {}
	# t0 ledger
	print("--- t0 ---")
	for tid in capable: print("  " + _ledger(state, tid, snap))

	for month in range(8):
		var fam_before: Dictionary = {}
		for tid in capable:
			fam_before[tid] = int(state.teams[tid].famine_days) if state.teams.has(tid) else -1
		for _t in range(240 * 30):
			runner.advance_tick(state, no_player)
			if state.encounter_active and state.encounter_tick > 800:
				runner._encounter_system.resolve_encounter_end(state, "draw")
		print("--- 月%d ---" % (month + 1))
		for tid in capable: print("  " + _ledger(state, tid, snap))

	# 收尾：赤字判定提示
	print("\n[food] 判讀：income/d < burn/d = 收不抵支(赤字)；own_granary=false+tile pool 低 = 無食源；")
	print("[food]   pop 大但 income 低 = 養不起；task 非生產/覓食/駐守 = 沒在生產糧。")
	print("=== food ledger diagnose DONE ===")
