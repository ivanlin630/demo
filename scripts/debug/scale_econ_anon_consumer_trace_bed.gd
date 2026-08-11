extends SceneTree

# [measurer持久fixture 2026-08-08] anon真consumer trace(tick0-500,Team0聚焦)。
# ticket:docs/superpowers/handbacks/2026-08-08-systems-to-measurer-anon-consumer-trace.md
# 用env ANON_TRACE=1掛get_stack()自動抓caller(anon_tier_system.gd transfer_proportional/add_anon/remove_anon,
# 測完git checkout --revert),跑到tick500(day~2)即可,pool 3→0發生在day1-5內。

const DISP_CONFIG := "res://config/infonet_scale_econ_dispersed.json"
const SEED: int = 8181
const TICKS: int = 1200   # day5,涵蓋pool真正歸零那刻

func _initialize() -> void:
	print("=== anon真consumer trace(seed=%d tick0-%d,Team0聚焦) ===" % [SEED, TICKS])
	seed(SEED)
	FactionAISystem._a2b_remote_tribute_payers.clear()
	Probe.reset(); Probe.enabled = true
	var state := WorldState.new()
	var runner := SimRunner.new()
	var config: Dictionary = GameSetup.load_config(DISP_CONFIG)
	config["seed"] = SEED
	GameSetup.setup(state, config)
	var no_player := Vector2i(-1, -1)

	print("day0 起始 lord_anon=%d" % AnonTierSystem.total_pop(state.teams[0]))
	for tick in range(TICKS):
		runner.advance_tick(state, no_player)
		if state.encounter_active and state.encounter_tick > 800:
			runner._encounter_system.resolve_encounter_end(state, "draw")
		if state.world.current_tick % WorldState.TICKS_PER_DAY == 0 and state.teams.has(0):
			print("  day%d end: lord_anon=%d lord_pop=%d" % [
				state.world.current_tick / WorldState.TICKS_PER_DAY,
				AnonTierSystem.total_pop(state.teams[0]), state.teams[0].population])
	print("=== DONE ===")
	quit()
