# scripts/debug/team_ui_test.gd
# Headless test for team member inspector snapshot and TeamUiHelper rendering.
extends SceneTree

func _initialize() -> void:
	print("=== TEAM UI TEST START ===")
	_test_members_detail_snapshot()
	_test_team_stats_snapshot()
	_test_helper_rendering()
	print("=== TEAM UI TEST DONE ===")
	quit()

func _test_members_detail_snapshot() -> void:
	print("\n-- members_detail snapshot --")
	var state := WorldState.new()
	var runner := SimRunner.new()
	var bridge := SimBridge.new(runner, state)

	# Setup: leader + 2 members + player
	var team := TeamData.new()
	team.team_id = 0
	team.population = 3
	team.resources = { "food": 50.0, "coin": 0, "material": 0 }
	team.tile_pos = Vector2i(0, 0)
	state.teams[0] = team
	state.team_known[0] = []
	state.team_discovered[0] = []
	state.world.tiles[0] = HexTileData.new()

	for i in range(3):
		var p := PersonData.new()
		p.id = i
		p.person_name = "Member_%d" % i
		p.role = "leader" if i == 0 else "civilian"
		p.team_id = 0
		p.stress = float(i) * 0.2
		p.loyalty = 0.9 - float(i) * 0.1
		state.persons[i] = p
		if i == 0:
			team.leader_id = i
		else:
			team.named_members.append(i)

	state.player_id = 0

	var result := bridge.query_player()
	assert(result.get("ok"), "query_player should succeed")
	var snap: Dictionary = result.get("data", {}).get("snapshot", {})

	assert(snap.has("members_detail"), "snapshot must have members_detail")
	var md: Array = snap.get("members_detail", [])
	assert(md.size() == 3, "members_detail should have 3 entries, got %d" % md.size())

	var leader = md[0]
	assert(leader.get("name") == "Member_0", "leader name correct")
	assert(leader.get("role") == "leader", "leader role correct")
	assert(leader.has("hp_current"), "leader has hp_current")
	assert(leader.has("hp_max"), "leader has hp_max")
	assert(leader.has("attributes"), "leader has attributes")
	assert(leader.has("values"), "leader has values")
	assert(leader.has("skills"), "leader has skills")
	assert(leader.has("body_parts"), "leader has body_parts")
	assert(leader.has("equipped"), "leader has equipped")
	assert(leader.has("inventory"), "leader has inventory")
	assert(leader.get("hp_max") > 0.0, "hp_max > 0")

	var member1 = md[1]
	assert(member1.get("role") == "member", "member1 role is member")
	assert(absf(float(member1.get("stress", -1)) - 0.2) < 0.001, "member1 stress correct")

	print("  [OK] members_detail: 3 members, fields present, values correct")

func _test_team_stats_snapshot() -> void:
	print("\n-- team_stats snapshot --")
	var state := WorldState.new()
	var runner := SimRunner.new()
	var bridge := SimBridge.new(runner, state)

	var team := TeamData.new()
	team.team_id = 0
	team.population = 5
	team.resources = { "food": 200.0, "coin": 0, "material": 0 }
	team.tile_pos = Vector2i(0, 0)
	state.teams[0] = team
	state.team_known[0] = []
	state.team_discovered[0] = []
	state.world.tiles[0] = HexTileData.new()

	var p := PersonData.new()
	p.id = 0; p.person_name = "P0"; p.team_id = 0
	state.persons[0] = p
	team.leader_id = 0
	state.player_id = 0

	var result := bridge.query_player()
	assert(result.get("ok"), "query_player should succeed")
	var snap: Dictionary = result.get("data", {}).get("snapshot", {})

	assert(snap.has("team_stats"), "snapshot must have team_stats")
	var ts: Dictionary = snap.get("team_stats", {})
	assert(ts.has("food_qty"), "team_stats has food_qty")
	assert(ts.has("carry_weight"), "team_stats has carry_weight")
	assert(ts.has("carry_capacity"), "team_stats has carry_capacity")
	assert(ts.has("member_count"), "team_stats has member_count")
	assert(ts.get("food_qty") == 200, "food_qty == 200, got %d" % ts.get("food_qty"))
	assert(ts.get("carry_capacity") > 0.0, "carry_capacity > 0")
	assert(ts.get("member_count") == 1, "member_count == 1 (only leader), got %d" % ts.get("member_count"))

	print("  [OK] team_stats: food_qty=%d cap=%.1f count=%d" % [
		ts.get("food_qty"), ts.get("carry_capacity"), ts.get("member_count")])

func _test_helper_rendering() -> void:
	print("\n-- TeamUiHelper rendering --")
	var member: Dictionary = {
		"id": 0,
		"name": "TestHero",
		"role": "leader",
		"stress": 0.3,
		"fear": 0.1,
		"loyalty": 0.9,
		"hp_current": 120.0,
		"hp_max": 180.0,
		"attributes": {"體力": 0.6, "智力": 0.4, "魅力": 0.5, "毅力": 0.7},
		"values": {"野心": 0.8, "慎重": 0.3, "義氣": 0.6, "求生欲": 0.4, "貪婪": 0.2, "好戰": 0.7, "殘忍": 0.1, "信義": 0.5},
		"skills": {"統領": 0.5, "戰鬥": 0.8, "弓箭": 0.3, "求生": 0.6, "生產": 0.1, "製造": 0.0, "工程": 0.0, "醫療": 0.2, "戰術": 0.4, "計謀": 0.3, "交涉": 0.0, "商業": 0.0, "偵查": 0.1, "潛行": 0.0},
		"body_parts": {
			"head":      {"hp": 20.0, "max_hp": 20.0, "status": "healthy", "poisoned": false, "bleeding": "none", "fracture": false},
			"torso":     {"hp": 40.0, "max_hp": 50.0, "status": "wounded", "poisoned": false, "bleeding": "none", "fracture": false},
			"right_arm": {"hp": 25.0, "max_hp": 25.0, "status": "healthy", "poisoned": false, "bleeding": "none", "fracture": false},
			"left_arm":  {"hp": 25.0, "max_hp": 25.0, "status": "healthy", "poisoned": false, "bleeding": "none", "fracture": false},
			"right_leg": {"hp": 10.0, "max_hp": 30.0, "status": "wounded", "poisoned": false, "bleeding": "none", "fracture": false},
			"left_leg":  {"hp": 30.0, "max_hp": 30.0, "status": "healthy", "poisoned": false, "bleeding": "none", "fracture": false},
		},
		"equipped": {
			"hand_1": {"type": "weapon", "grade": "weapon_melee_high"},
			"hand_2": {"type": "none",   "grade": ""},
			"head":   {"type": "none",   "grade": ""},
			"torso":  {"type": "armor",  "grade": "armor_low"},
			"right_arm": {"type": "none", "grade": ""},
			"left_arm":  {"type": "none", "grade": ""},
			"right_leg": {"type": "none", "grade": ""},
			"left_leg":  {"type": "none", "grade": ""},
		},
		"inventory": [{"grade": "medicine", "qty": 3}],
	}
	var team_stats: Dictionary = {
		"food_qty": 100, "carry_weight": 12.5, "carry_capacity": 50.0, "member_count": 1
	}

	# quick card
	var qc: Array = TeamUiHelper.render_quick_card(member)
	assert(qc.size() > 0, "render_quick_card returns lines")
	var qc_text: String = "\n".join(qc)
	assert(qc_text.contains("TestHero"), "quick card has name")
	print("  [OK] render_quick_card")

	# health detail
	var hd: Array = TeamUiHelper.render_health_detail(member)
	assert(hd.size() > 0, "render_health_detail returns lines")
	var hd_text: String = "\n".join(hd)
	assert(hd_text.contains("120"), "health detail has hp_current")
	print("  [OK] render_health_detail")

	# equipment detail
	var ed: Array = TeamUiHelper.render_equipment_detail(member)
	assert(ed.size() > 0, "render_equipment_detail returns lines")
	var ed_text: String = "\n".join(ed)
	assert(ed_text.contains("weapon_melee_high"), "equipment detail has weapon")
	print("  [OK] render_equipment_detail")

	# stats detail
	var sd: Array = TeamUiHelper.render_stats_detail(member)
	assert(sd.size() > 0, "render_stats_detail returns lines")
	var sd_text: String = "\n".join(sd)
	assert(sd_text.contains("戰鬥"), "stats detail has top skill")
	print("  [OK] render_stats_detail")

	# three columns
	var all_members: Array = [member]
	var three_col: String = TeamUiHelper.render_three_columns(
		all_members, 0, TeamUiHelper.render_quick_card(member), team_stats, "Team0", 100)
	assert(three_col.length() > 0, "render_three_columns returns non-empty string")
	assert(three_col.contains("TestHero"), "three_columns includes member name")
	assert(three_col.contains("食物:100"), "three_columns includes food stats")
	print("  [OK] render_three_columns")

	# member_list_row
	var row: String = TeamUiHelper.render_member_list_row(member)
	assert(row.contains("[隊長]"), "member_list_row has role tag")
	assert(row.contains("TestHero"), "member_list_row has name")
	print("  [OK] render_member_list_row")
