class_name TrainingSystem

# TASK_TRAIN team：每 tick 為各 anon tier 累積 exp。
# 速率 = leader 戰術 skill × 該 tier 人數 × EXP_RATE_MULT。

const EXP_RATE_MULT: float = 1.0   # global tunable（TEST VALUE）

func process(state: WorldState, team_ids: Array) -> void:
	for tid in team_ids:
		var team: TeamData = state.teams.get(tid)
		if team == null:
			continue
		if team.current_task != TeamData.TASK_TRAIN:
			continue
		var leader: PersonData = state.persons.get(team.leader_id)
		if leader == null:
			continue
		var tact: float = float(leader.skills.get("戰術", 0.0))
		if tact <= 0.0:
			continue
		for tier in AnonTierSystem.TIER_ORDER:
			if tier == "菁英":
				continue
			var n: int = int(team.anon_tiers.get(tier, 0))
			if n <= 0:
				continue
			AnonTierSystem.add_exp(team, tier, tact * float(n) * EXP_RATE_MULT)
			# W4: 補 promote tick caller — 累積 exp 後升到不能升（count=1 迴圈,exp/物資/count 不足自停）
			var promoted: int = 0
			while AnonTierSystem.try_promote(state, team, tier, 1) > 0:
				promoted += 1
			if promoted > 0:
				print("[Train] Team%d %s 升階 %d 人" % [team.team_id, tier, promoted])
