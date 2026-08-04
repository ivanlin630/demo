extends SceneTree

# 資訊網 Part2 dispatch-fix TDD（spec 2026-08-04-infonet-part2-dispatch-anon-herald-HOW）。
# root:bootstrap 修好 applicable 但 dispatch=0（herald 需 spare named、小餓 resident 無→送不出）。
# fix:①applicable gate on spawn-ability（治 regression+誠實）②求援 herald=anon 1 人 empty-handed messenger。
# 守:util 一字不改；anon 信使零特權只送 distress；empty-handed 零 res carry（餓 resident 任何流失都在乎）。

var _fail: int = 0

func _initialize() -> void:
	_test_anon_messenger_spawn()     # ①dispatch_anon_messenger:1-pop anon(leader_id=-1)、母隊扣 1 pop
	_test_anon_messenger_emptyhanded() # ②★empty-handed:零 resource carry（不 proportional-split）
	_test_dispatch_help_end_to_end() # ③_dispatch_help_herald:小餓 resident(pop>=2,無 named)→anon herald 送出
	_test_pop_gate()                 # ④pop<2→不送（不掏空）
	if _fail == 0: print("=== DONE === ALL PASS")
	else: print("=== DONE === %d FAIL" % _fail)
	quit()

func _ok(c: bool, m: String) -> void:
	if c: print("  [PASS] %s" % m)
	else: _fail += 1; print("  [FAIL] %s" % m)

func _mk_mother(anon_pop: int, with_res: bool) -> Array:
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var m := TeamData.new(); m.team_id = 1; m.faction_id = 0; m.tile_pos = Vector2i(5,5)
	AnonCohort.add(m.anon_cohorts, "平民", "healthy", anon_pop)   # 全 anon、無 named leader spare
	if with_res:
		m.resources = {"food": 100.0, "coin": 50.0, "material": 30.0}
	state.teams[1] = m
	return [state, m]

# ① anon messenger spawn：1-pop、leader_id=-1、母隊 pop 扣 1。
func _test_anon_messenger_spawn() -> void:
	print("--- ①anon messenger spawn ---")
	var a := _mk_mother(10, false); var state: WorldState = a[0]; var m: TeamData = a[1]
	var pop0: int = m.population
	var hid: int = SubteamSystem.new().dispatch_anon_messenger(state, 1, TeamData.TASK_HERALD, "help_call",
		Vector2i(9,9), 2, {"help_origin": 1, "timeout": 9999})
	_ok(hid != -1, "anon messenger 派出（hid=%d）" % hid)
	if hid != -1:
		var h: TeamData = state.teams[hid]
		_ok(h.leader_id == -1 and h.population == 1 and h.current_task == TeamData.TASK_HERALD and h.task_reason == "help_call",
			"herald:leader_id=-1 pop=1 task=HERALD reason=help_call（got leader=%d pop=%d）" % [h.leader_id, h.population])
		_ok(m.population == pop0 - 1, "母隊 pop 扣 1（%d→%d 真成本自限）" % [pop0, m.population])

# ② ★empty-handed：herald 零 resource（不沿 dispatch() proportional-split）。
func _test_anon_messenger_emptyhanded() -> void:
	print("--- ②empty-handed 零 res carry ---")
	var a := _mk_mother(10, true); var state: WorldState = a[0]; var m: TeamData = a[1]
	var mfood0: float = float(m.resources.get("food", 0))
	var hid: int = SubteamSystem.new().dispatch_anon_messenger(state, 1, TeamData.TASK_HERALD, "help_call",
		Vector2i(9,9), 2, {"help_origin": 1, "timeout": 9999})
	var h: TeamData = state.teams[hid]
	var h_food: float = float(h.resources.get("food", 0)); var h_coin: float = float(h.resources.get("coin", 0)); var h_mat: float = float(h.resources.get("material", 0))
	_ok(h_food == 0.0 and h_coin == 0.0 and h_mat == 0.0, "★herald 零 res carry（food=%.1f coin=%.1f mat=%.1f=empty-handed）" % [h_food, h_coin, h_mat])
	_ok(absf(float(m.resources.get("food",0)) - mfood0) < 0.01, "母隊 food 不流失（%.1f→%.1f=餓 resident 任何流失都在乎、信使空手）" % [mfood0, float(m.resources.get("food",0))])

# ③ side-dispatch 端到端：深餓 resident（pop>=2、全 anon、名冊可達領主）→ _try_herald_side 派 anon herald。
func _test_dispatch_help_end_to_end() -> void:
	print("--- ③side-dispatch 端到端（深餓 resident）---")
	var state := WorldState.new(); state.world = WorldData.new(); state.world.current_tick = 1000
	var fac := FactionData.new(); fac.faction_id = 0; fac.leader_team_id = 1; state.factions[0] = fac
	var lt := HexTileData.new(); lt.tile_pos = Vector2i(9,9); lt.outpost_level = 1; lt.outpost_owner = 1
	state.world.tiles[9*1000+9] = lt
	var lord := TeamData.new(); lord.team_id = 1; lord.faction_id = 0; lord.tile_pos = Vector2i(9,9)
	AnonCohort.add(lord.anon_cohorts, "平民", "healthy", 20); state.teams[1] = lord
	var m := TeamData.new(); m.team_id = 2; m.faction_id = 0; m.tile_pos = Vector2i(5,5); m.tags = [TeamData.TAG_PRODUCE]
	AnonCohort.add(m.anon_cohorts, "平民", "healthy", 5); m.resources = {"food": 0.2}   # 深餓 severity 高
	var lm := PersonData.new(); lm.id = 12; lm.values = {"求生欲": 1.0, "野心": 0.0, "義氣": 0.6}; state.persons[12] = lm; m.leader_id = 12
	state.teams[2] = m
	Probe.reset(); Probe.enabled = true
	FactionAISystem.new()._try_herald_side(state, m)
	Probe.enabled = false
	_ok(int(Probe.counts.get("help.letter_dispatched", 0)) == 1,
		"深餓 resident(全 anon、A③名冊解出領主 seat)→ side-dispatch B carrier letter（dispatched=%d）=修 dispatch=0+argmax-loss 根" % int(Probe.counts.get("help.letter_dispatched",0)))

# ④ pop<2 → 不送（不掏空）。
func _test_pop_gate() -> void:
	print("--- ④pop<2 不送 ---")
	var a := _mk_mother(1, false); var state: WorldState = a[0]; var m: TeamData = a[1]
	var hid: int = SubteamSystem.new().dispatch_anon_messenger(state, 1, TeamData.TASK_HERALD, "help_call",
		Vector2i(9,9), 2, {})
	_ok(hid == -1, "pop 1（<2）→ 不派 anon 信使（hid=%d、不掏空）" % hid)
