extends SceneTree

# [blueprint 一次性 2026-08-13] dump seed1337 各隊領袖初始 技能+屬性+個性(用戶要)。
# 重生同 ③ audit 初始態(GameSetup.setup seed1337 warring_states.json)、只讀零跑 tick。

const WORLD_SEED: int = 1337
const CONFIG_PATH := "res://config/warring_states.json"

func _initialize() -> void:
	seed(WORLD_SEED)
	var state := WorldState.new()
	var config: Dictionary = GameSetup.load_config(CONFIG_PATH)
	config["seed"] = WORLD_SEED
	GameSetup.setup(state, config)

	var out: Array = []
	var tids: Array = state.teams.keys()
	tids.sort()
	for tid in tids:
		var t: TeamData = state.teams[tid]
		var lp = state.persons.get(t.leader_id)
		var rec: Dictionary = {
			"team_id": tid, "faction_id": t.faction_id, "pop": t.population,
			"parent_team_id": t.parent_team_id, "named_leader": lp != null,
			"leader_id": t.leader_id, "current_task": t.current_task,
		}
		if lp != null:
			rec["leader_name"] = lp.person_name
			rec["role"] = lp.role
			rec["age"] = lp.age
			rec["attributes"] = lp.attributes.duplicate()
			rec["skills"] = lp.skills.duplicate()
			rec["values"] = lp.values.duplicate()
		out.append(rec)

	var dump: Dictionary = {
		"seed": WORLD_SEED, "total_teams": state.teams.size(),
		"total_factions": state.factions.size(), "teams": out,
	}
	var f := FileAccess.open("res://docs/measurements/2026-08-13-seed1337-initial-skills-attrs.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(dump, "  ")); f.close()
		print("[dump] → docs/measurements/2026-08-13-seed1337-initial-skills-attrs.json  teams=%d" % state.teams.size())
	print("=== DONE ===")
	quit()
