extends SceneTree

# 統一統領決策 measure-first（藍圖 ruling 2026-06-28「量統領同發幾個矛盾令當基準」）。
# 真根：_update_goals 多閾值並行——各大事(徵收/立國/外交/攻擊/掠奪)各算分過閾全發 → 同時下矛盾令。
# 量：各 persona leader 跑 _update_goals → f.goals 同發幾個 stakes（攻擊/外交/掠奪/徵收/立國）。
# 純量測，不改邏輯。

func _initialize() -> void:
	_run(); quit()

func _new_state() -> WorldState:
	var s := WorldState.new(); s.world = WorldData.new(); s.player_id = -1
	return s

func _tile(s: WorldState, pos: Vector2i) -> void:
	var key: int = pos.x * 1000 + pos.y
	if not s.world.tiles.has(key):
		var t := HexTileData.new(); t.tile_pos = pos; t.terrain = "plains"
		s.world.tiles[key] = t

func _fill(s: WorldState, r: int) -> void:
	for x in range(-r, r + 1):
		for y in range(-r, r + 1):
			_tile(s, Vector2i(x, y))

func _seed(team: TeamData, n: int) -> void:
	var named: int = team.named_members.size() + (1 if team.leader_id != -1 else 0)
	if n - named > 0:
		AnonCohort.add(team.anon_cohorts, "平民", "healthy", n - named)

# 建 established faction + leader（指定 persona）+ 2 member + 鄰獨立隊（外交/攻擊 target）。
# 回 f.goals（跑 _update_goals 後）。
func _measure_leader(persona_name: String, values: Dictionary) -> Array:
	var s := _new_state()
	_fill(s, 4)
	var fai := FactionAISystem.new()
	# 獨立鄰（外交/攻擊 target + leader belief 弱）
	var ind := TeamData.new(); ind.team_id = 9; ind.tile_pos = Vector2i(2, 0); ind.faction_id = -1
	var i_ldr := PersonData.new(); i_ldr.id = 90; s.persons[90] = i_ldr; ind.leader_id = 90
	_seed(ind, 4); ind.resources = {"food": 100.0}; s.teams[9] = ind
	# leader 隊
	var lt := TeamData.new(); lt.team_id = 0; lt.tile_pos = Vector2i(0, 0)
	lt.faction_id = 1; lt.readiness = 1.0; lt.tags = [TeamData.TAG_MILITARY]
	var ldr := PersonData.new(); ldr.id = 1; ldr.values = values; ldr.skills = {"統領": 0.7}
	s.persons[1] = ldr; lt.leader_id = 1; _seed(lt, 12)
	lt.resources = {"food": 99999.0, "material": 200.0, "weapon_melee_low": 30.0}
	lt.armed_anon_ratio = 1.0   # own_armed 足，過攻擊 strength gate
	s.teams[0] = lt
	s.team_discovered[0] = [9]
	BeliefSystem.record_claim(s, 0, 9, 90, "親見",
		{"population_est": 4.0, "armed_est": 2.0, "tile_pos": Vector2i(2, 0)}, 1.0, false)
	# 2 member（富 member 供徵收 target）
	var m1 := TeamData.new(); m1.team_id = 1; m1.tile_pos = Vector2i(1, 0); m1.faction_id = 1
	var m1l := PersonData.new(); m1l.id = 11; s.persons[11] = m1l; m1.leader_id = 11
	_seed(m1, 6); m1.resources = {"food": 5000.0}; s.teams[1] = m1
	var f := FactionData.new(); f.faction_id = 1; f.leader_team_id = 0
	f.member_team_ids = [0, 1]; f.is_established = true
	f.known_member_states = {1: {"food_est": 5000.0, "current_task": "idle"}}
	s.factions[1] = f
	# 跑 _update_goals（霸主決策）
	fai._update_goals(s, f)
	return f.goals.duplicate()

# commander-v2：回 [goals, intent, drivers]（means-end 後），補力 member 在攻擊 task → 征服 viable。
func _measure_leader2(persona_name: String, values: Dictionary) -> Array:
	var s := _new_state()
	_fill(s, 4)
	var fai := FactionAISystem.new()
	var ind := TeamData.new(); ind.team_id = 9; ind.tile_pos = Vector2i(2, 0); ind.faction_id = -1
	var i_ldr := PersonData.new(); i_ldr.id = 90; s.persons[90] = i_ldr; ind.leader_id = 90
	_seed(ind, 4); ind.resources = {"food": 100.0}; s.teams[9] = ind
	var lt := TeamData.new(); lt.team_id = 0; lt.tile_pos = Vector2i(0, 0)
	lt.faction_id = 1; lt.readiness = 1.0; lt.tags = [TeamData.TAG_MILITARY]
	var ldr := PersonData.new(); ldr.id = 1; ldr.values = values; ldr.skills = {"統領": 0.7}
	s.persons[1] = ldr; lt.leader_id = 1; _seed(lt, 12)
	lt.resources = {"food": 99999.0, "material": 200.0, "weapon_melee_low": 30.0}
	lt.armed_anon_ratio = 1.0
	s.teams[0] = lt
	s.team_discovered[0] = [9]
	BeliefSystem.record_claim(s, 0, 9, 90, "親見",
		{"population_est": 4.0, "armed_est": 2.0, "tile_pos": Vector2i(2, 0)}, 1.0, false)
	var m1 := TeamData.new(); m1.team_id = 1; m1.tile_pos = Vector2i(1, 0); m1.faction_id = 1
	var m1l := PersonData.new(); m1l.id = 11; s.persons[11] = m1l; m1.leader_id = 11
	_seed(m1, 6); m1.resources = {"food": 5000.0}; s.teams[1] = m1
	var f := FactionData.new(); f.faction_id = 1; f.leader_team_id = 0
	f.member_team_ids = [0, 1]; f.is_established = true
	f.known_member_states = {1: {"food_est": 5000.0, "current_task": TeamData.TASK_ATTACK, "armed_est": 8}}
	s.factions[1] = f
	fai._update_goals(s, f)
	return [f.goals.duplicate(), f.intent.duplicate(), f.goal_drivers.duplicate()]

func _run() -> void:
	print("=== commander directive measure v2: means-end 意圖驅動（每令帶 driver）===")
	var personas := [
		{"name": "好戰霸主", "v": {"野心": 0.9, "好戰": 0.9, "義氣": 0.1, "貪婪": 0.5, "求生欲": 0.4}},
		{"name": "貪婪商霸", "v": {"野心": 0.7, "好戰": 0.3, "義氣": 0.2, "貪婪": 0.9, "求生欲": 0.4}},
		{"name": "溫和守成", "v": {"野心": 0.3, "好戰": 0.1, "義氣": 0.7, "貪婪": 0.3, "求生欲": 0.5, "慎重": 0.7}},
		{"name": "野心謀略", "v": {"野心": 0.9, "好戰": 0.5, "義氣": 0.3, "貪婪": 0.6, "求生欲": 0.4}},
		{"name": "均衡", "v": {"野心": 0.5, "好戰": 0.5, "義氣": 0.5, "貪婪": 0.5, "求生欲": 0.5}},
	]
	var driverless_total: int = 0
	for p in personas:
		var r: Array = _measure_leader2(p["name"], p["v"])
		var goals: Array = r[0]; var intent: Dictionary = r[1]; var drivers: Dictionary = r[2]
		print("  %-8s 意圖=%-4s → f.goals=%s" % [p["name"], intent.get("type", "?"), str(goals)])
		for g in goals:
			var d: Dictionary = drivers.get(g, {})
			if d.is_empty():
				driverless_total += 1
				print("      ⚠ 無因令 %s（無 driver）" % g)
			else:
				print("      ↳ %s : intent=%s why=%s mode=%s" % [g, d.get("intent", "?"), d.get("why", "?"), d.get("mode", "?")])
	print("\n結論：每令連回意圖 driver（intent+why+mode）。無因令總數=%d（北極星：應為 0）" % driverless_total)
	assert(driverless_total == 0, "[measure] 仍有無因令（北極星違反）：%d" % driverless_total)
	print("=== commander directive measure DONE ===")
