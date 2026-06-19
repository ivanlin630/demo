class_name TaskArbiter
# Task 優先權仲裁：所有 current_task 寫入走 try_set / transition，結束走 release。
# 優先權按事件性質（緊急度）分層；同層先到先得；migration 後直接賦值 = bug
#（豁免：新 team 建立時無現任，可直接賦值但須同時設 task_priority）。
# Spec: docs/superpowers/specs/2026-06-11-task-arbiter-design.md

const PRIO_COMBAT:   int = 100
const PRIO_SURVIVAL: int = 80
const PRIO_THREAT:   int = 70
const PRIO_PLAYER:   int = 60
const PRIO_VENDETTA: int = 55   # 私人脫軌（強仇+衝動）：生存(80)/威脅(70)下、prosperity(50)上
const PRIO_DISPATCH: int = 50
const PRIO_FACTION:  int = 30
const PRIO_AMBIENT:  int = 10


# 嘗試設 task。優先權嚴格大於現任才搶得動（同層先到先得）。
# state 供抗命判定讀 leader；回 true = 已設；false = 被現任擋下。
# 呼叫端必須處理 false：被擋時不得執行配套副作用（prosperity_target_id 等）。
static func try_set(state: WorldState, team: TeamData, new_task: String,
		move_target: Vector2i, priority: int, _source: String = "") -> bool:
	if team.combat_target != -1:
		return false   # 戰鬥鎖絕對（combat 結束流程清 combat_target）
	if team.current_task == TeamData.TASK_IDLE or priority > team.task_priority:
		team.current_task = new_task
		team.move_target = move_target
		team.task_priority = priority
		team.task_reason = _source
		team.task_start_tick = state.world.current_tick
		return true
	# 抗命窗口：NPC 慾望 (50) 挑戰玩家命令 (60) → leader 個性確定性判定
	if team.task_priority == PRIO_PLAYER and priority == PRIO_DISPATCH:
		var leader: PersonData = state.persons.get(team.leader_id)
		if leader != null and _defiance_check(leader):
			print("[抗命] Team%d leader 棄玩家命令 → %s" % [team.team_id, new_task])
			team.current_task = new_task
			team.move_target = move_target
			team.task_priority = priority
			team.task_reason = "defy_" + _source
			team.task_start_tick = state.world.current_tick
			return true
		if leader != null:
			# 壓抑：慾望轉 stress/unrest（餵既有叛變管線；stress 進 desire 公式 → 憋多了爆）
			leader.stress = minf(leader.stress + 0.05, 1.0)
			team.unrest_turns += 1
	return false


# task 完成 / 取消 / 釋放條件達成 → 回 idle + priority 歸 0
static func release(team: TeamData) -> void:
	team.current_task = TeamData.TASK_IDLE
	team.move_target = Vector2i(-1, -1)
	team.task_priority = 0


# 不改釋放流程、就地轉換 task 的欄位同步（如 安頓→生產）
static func transition(team: TeamData, new_task: String, priority: int, _source: String = "transition") -> void:
	team.current_task = new_task
	team.task_priority = priority
	team.task_reason = _source


# 抗命判定：確定性，無 RNG。desire > obedience + 0.3 → 抗命
static func _defiance_check(leader: PersonData) -> bool:
	var obedience: float = leader.loyalty \
		+ float(leader.values.get("義氣", 0.5)) * 0.5 \
		+ float(leader.values.get("信義", 0.5)) * 0.5
	var desire: float = float(leader.values.get("貪婪", 0.5)) \
		+ float(leader.values.get("野心", 0.5)) * 0.5 \
		+ leader.stress * 0.3   # 壓抑累積 → 越憋越想反
	return desire > obedience + 0.3
