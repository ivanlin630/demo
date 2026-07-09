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

# A1a 拆閥（spec 2026-07-07-A1a-arbiter-valve）：引擎主 rank 的 dispatch source 白名單。
# 這兩面（_decide_unified / _evaluate_solo）的 rank[0] 允許同層換掉引擎自己派的 task
#（equal-priority self-replace，閉迴路）。scout/prosperity scaffolding 自帶 release 換手
# 不入列；ambition@AMBIENT 被嚴格大於覆蓋不需入列。外部子系統/PLAYER 不在列=仍嚴格大於。
const ENGINE_SOURCES: Array = ["unified", "solo"]


# A2c-2（FA6 折入）：戰略移動 move_target 唯一 arbiter-owned write path（收 movement 直讀 bypass=D11/V3）。
# 純移動覆蓋——不碰 current_task/task_priority（候選 C 精髓：保 IDLE→interaction:253 自發併隊續 fire）。
# ★內建 2 道純 team-欄 guard（原掛 movement:64/68，folding 一併搬進 method，防未來呼叫點遺漏破不變量）：
static func set_strategic_move(team: TeamData, pos: Vector2i) -> void:
	if team.combat_target != -1: return                    # 戰鬥鎖絕對（同 try_set:28-29 全域不變量）
	if team.current_task == TeamData.TASK_FLEE: return      # 逃跑不被戰略位覆蓋
	# 僅 move_target 空/抵達才覆蓋（保現行觸發顆粒，byte-identical），不動 task=IDLE 保留。
	if team.move_target == Vector2i(-1, -1) or team.move_target == team.tile_pos:
		team.move_target = pos
		Probe.bump("strat.sa_move_dispatch")   # overlay 實際生效頻率（D0 探針，count 折後不變）


# 嘗試設 task。優先權嚴格大於現任才搶得動（同層先到先得）。
# state 供抗命判定讀 leader；回 true = 已設；false = 被現任擋下。
# 呼叫端必須處理 false：被擋時不得執行配套副作用（prosperity_target_id 等）。
static func try_set(state: WorldState, team: TeamData, new_task: String,
		move_target: Vector2i, priority: int, _source: String = "") -> bool:
	if team.combat_target != -1:
		return false   # 戰鬥鎖絕對（combat 結束流程清 combat_target）
	if team.current_task == TeamData.TASK_IDLE or priority > team.task_priority:
		# 漏斗站4探針（純觀測）：TRADE 在途被搶 → 記誰搶走（new_task|source）
		if Probe.enabled and team.current_task == TeamData.TASK_TRADE \
				and new_task != TeamData.TASK_TRADE:
			Probe.bump("trade.preempt.%s|%s" % [new_task, _source])
		team.current_task = new_task
		team.move_target = move_target
		team.task_priority = priority
		team.task_reason = _source
		team.task_start_tick = state.world.current_tick
		return true
	# A1a source-gated equal-priority self-replace：引擎每 cadence 的 rank[0] 同層換掉
	# 引擎自己派的 task（腦選、手無條件執行）。兩側都要 engine-owned：新 source 在白名單、
	# 現任 task_reason 也在（defy_ 前綴=抗命贏來的引擎 task，視同）→ herald/merchant/scout
	# 等同層現任不被 stomp。防抖動由引擎 COMMITMENT_BONUS 承擔（rank 前已偏置現任 option）。
	if priority == PRIO_DISPATCH and team.task_priority == PRIO_DISPATCH \
			and _source in ENGINE_SOURCES \
			and team.task_reason.trim_prefix("defy_") in ENGINE_SOURCES:
		if new_task == team.current_task:
			team.move_target = move_target   # A1a: 同 task 但新 target（換更好市場/新 prey 位）→ 手跟腦更新目標
			return true   # 不重蓋 task_start_tick（單源，timeout 不歸零）；move_target 更新無關 timeout
		if Probe.enabled and team.current_task == TeamData.TASK_TRADE:
			Probe.bump("trade.preempt.%s|%s" % [new_task, _source])   # 漏斗站4 parity
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
			UnrestBank.add(team, 1, "task")
	return false


# task 完成 / 取消 / 釋放條件達成 → 回 idle + priority 歸 0
static func release(team: TeamData) -> void:
	team.current_task = TeamData.TASK_IDLE
	team.move_target = Vector2i(-1, -1)
	team.task_priority = 0


# 不改釋放流程、就地轉換 task 的欄位同步（如 安頓→生產）。
# A1a：蓋 task_start_tick（與 try_set 同源）——否則 transition 進場的 task（如 PRODUCE）
# 拿 stale 起算，timeout 檢查派出即秒殺（W2 TRADE 漏斗定罪過同型 bug）。
static func transition(state: WorldState, team: TeamData, new_task: String, priority: int, _source: String = "transition") -> void:
	team.current_task = new_task
	team.task_priority = priority
	team.task_reason = _source
	team.task_start_tick = state.world.current_tick


# 抗命判定：確定性，無 RNG。desire > obedience + 0.3 → 抗命
static func _defiance_check(leader: PersonData) -> bool:
	var obedience: float = leader.loyalty \
		+ float(leader.values.get("義氣", 0.5)) * 0.5 \
		+ float(leader.values.get("信義", 0.5)) * 0.5
	var desire: float = float(leader.values.get("貪婪", 0.5)) \
		+ float(leader.values.get("野心", 0.5)) * 0.5 \
		+ leader.stress * 0.3   # 壓抑累積 → 越憋越想反
	return desire > obedience + 0.3
