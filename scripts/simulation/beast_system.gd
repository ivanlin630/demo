class_name BeastSystem

# 獸級 → 戰鬥/獎勵/行為。TEST VALUE 全待量測。
# behavior: "flee"(鹿,逃型) / "fight"(豬,戰型) / "predator"(熊狼,戰型且兇)
const BEAST_PROFILE: Dictionary = {
	"deer":  { "count": 1, "hp_mult": 0.6, "combat": 0.1, "claw": "beast_claw_light",
			   "behavior": "flee",  "meat": 25.0, "hide": 0.0,  "strength": 2.0 },
	"boar":  { "count": 1, "hp_mult": 1.0, "combat": 0.4, "claw": "beast_claw_light",
			   "behavior": "fight", "meat": 40.0, "hide": 5.0,  "strength": 8.0 },
	"bear":  { "count": 1, "hp_mult": 2.0, "combat": 0.7, "claw": "beast_claw_heavy",
			   "behavior": "predator", "meat": 80.0, "hide": 15.0, "strength": 20.0 },
	"wolves":{ "count": 4, "hp_mult": 0.7, "combat": 0.5, "claw": "beast_claw_light",
			   "behavior": "predator", "meat": 50.0, "hide": 10.0, "strength": 16.0 },
}

# 造臨時野獸 pseudo-team，入 state.teams，回傳 team_id。
func build_beast_team(state: WorldState, kind: String, pos: Vector2i) -> int:
	var prof: Dictionary = BEAST_PROFILE.get(kind, BEAST_PROFILE["boar"])
	var t := TeamData.new()
	# id counter 移 WorldState.next_beast_id（★禁 instance/static var）：每 BeastSystem.new() 都拿到
	# per-world 唯一遞減 id（舊 instance var 令每 new() 重置 -1000000 → 全 beast 撞 id → create_team 覆寫）。
	t.team_id = state.next_beast_id
	state.next_beast_id -= 1
	state.set_team_tags(t, [TeamData.TAG_BEAST], "beast_spawn")
	t.beast_kind = kind
	t.beast_strength = float(prof["strength"])
	t.tile_pos = pos
	state.set_team_faction(t, -1)   # S11 chokepoint（fresh team，no-op；單寫者一致）
	t.leader_id = -1
	t.named_members = []
	t.anon_cohorts = {}
	AnonCohort.add(t.anon_cohorts, AnonCohort.TIER_PLEB, "healthy", int(prof["count"]))
	ResourceBank.clear_all(t, "beast_spawn_init")
	t.armed_anon_ratio = 1.0   # 全員上場
	state.create_team(t)   # S9 chokepoint：註冊 + known/discovered init
	return t.team_id

# 獸戰結束：勝方得肉(food)+皮(material)，清除獸隊。
func reward_and_cleanup(state: WorldState, winner_id: int, beast_id: int) -> void:
	var beast: TeamData = state.teams.get(beast_id)
	var winner: TeamData = state.teams.get(winner_id)
	if beast != null and winner != null:
		var prof: Dictionary = BEAST_PROFILE.get(beast.beast_kind, {})
		ResourceBank.add(winner, "food", float(prof.get("meat", 0)), "beast_reward")
		winner.forage_today = float(winner.forage_today) + float(prof.get("meat", 0))
		if float(prof.get("hide", 0)) > 0:
			ResourceBank.add(winner, "material", float(prof["hide"]), "beast_reward")
		# 獵勝得戰鬥 exp（勝方 leader/named）
		for pid in ([winner.leader_id] as Array) + winner.named_members:
			var p: PersonData = state.persons.get(pid)
			if p: SkillSystem.cap_add(p, "戰鬥", 0.003)   # TEST VALUE 獵勝 exp
		print("[BeastHunt] Team%d 獵 %s 得肉%d" % [winner_id, beast.beast_kind, int(prof.get("meat", 0))])
	_cleanup(state, beast_id)

func _cleanup(state: WorldState, beast_id: int) -> void:
	state.erase_team(beast_id)
