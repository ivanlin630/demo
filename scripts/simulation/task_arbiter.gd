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
# ★持守統一 Slice 3（HOW spec 2026-07-28 §6）：committed progressive 動作 persist_strength > 此 → 擋非危機搶班。
# persist_strength ∈[0,PERSIST_CAP 0.3]（progressive-only,人格加權沉沒成本）。THRESHOLD 定在分固執/務實位置：
# 固執(lean 1.0)過 ~1/3 progress 黏、中性(0.5)過 ~2/3、務實(0.2)幾乎不黏。危機/玩家/同 task 不受此擋。
const PERSIST_HOLD_THRESHOLD: float = 0.1   # TEST VALUE — slice 調
# ★硬擋只作用【真有終點/完成的 progressive task】(BUILD 族)——非 ongoing 開放式(PRODUCE/TRADE/GOVERN/FORAGE 等)。
# 否則長 PRODUCE 隊 persist 高被硬鎖→不轉攻擊/防衛→戰鬥趨零=向凍(execution-verified 抓:attrition 0)。
# 決策層 bonus(Slice1)仍對全 committed 溫和偏置(max 0.3 不鎖);此硬 return-false 門檻只保 completable committed。
const PROGRESSIVE_HOLD_TASKS: Array = [
	TeamData.TASK_BUILD, TeamData.TASK_CONSTRUCT, TeamData.TASK_UPGRADE,
	TeamData.TASK_EXPAND, TeamData.TASK_SETTLE, TeamData.TASK_MIGRATE,
]

# A1a 拆閥（spec 2026-07-07-A1a-arbiter-valve）：引擎主 rank 的 dispatch source 白名單。
# 這兩面（_decide_unified / _evaluate_solo）的 rank[0] 允許同層換掉引擎自己派的 task
#（equal-priority self-replace，閉迴路）。scout/prosperity scaffolding 自帶 release 換手
# 不入列；ambition@AMBIENT 被嚴格大於覆蓋不需入列。外部子系統/PLAYER 不在列=仍嚴格大於。
const ENGINE_SOURCES: Array = ["unified", "solo", "invite_settle"]   # ★A4 9筆：invite_settle 同層 50=50 self-replace（非 priority-crank、被邀 settle 令不被同層 stomp）


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
	# crisis-override 免疫窗：剛 crisis-released 的 task 短時間禁重委派（防同 cadence release-then-instant-recommit：
	# defection「等待新領主」/solo FLEE 子系統立刻打回原 task → survival 永無機會）。只擋「同一 task」→ survival
	# 選別的 task（覓食/買糧…）不受阻，順利接住餓死隊。到期自動解。
	if new_task == team.crisis_released_task and team.crisis_released_task != "" \
			and state.world.current_tick < team.crisis_released_until:
		return false
	# ★持守統一 Slice 3 門檻式（§6）：committed progressive 動作（persist_strength 高）擋【非危機】搶班，完成優先。
	# 危機 axis（任一側 ≥PRIO_THREAT：combat/survival/threat）不介入=守命/背水一戰；玩家命令（PRIO_PLAYER）authority 不擋；
	# 同 task（target 更新非搶班）不擋。persist_strength progressive-only 已保證只 progressive committed 動作有值（FLEE/IDLE=0）。
	# ★latch 反例：單點門檻 return false（非 skip reeval 硬鎖）——被擋者下 tick 照評、危機/玩家照打斷、committed 隊自跑決策、
	#   完成/timeout 就釋放 persist 歸 0 → 世界照演化不凍。
	if new_task != team.current_task \
			and team.current_task in PROGRESSIVE_HOLD_TASKS \
			and priority < PRIO_THREAT and team.task_priority < PRIO_THREAT \
			and priority != PRIO_PLAYER \
			and team.persist_strength > PERSIST_HOLD_THRESHOLD:
		if Probe.enabled: Probe.bump("persist.hold")
		return false
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
	# ★threat-oracle S3：擴認 PRIO_THREAT self-replace（收斂後 threat option 走 _decide_unified@PRIO_THREAT 70；
	# 同層 threat option 可換 迎戰→求和 不卡=finding3 黏性）。source 白名單(unified/solo)擋 uprising 誤觸。
	if priority in [PRIO_DISPATCH, PRIO_THREAT, PRIO_SURVIVAL] and team.task_priority == priority \
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
	team.flee_from_pos = Vector2i(-1, -1)   # flee 位移根治：清逃離位（避 stale 殘留）


# 不改釋放流程、就地轉換 task 的欄位同步（如 安頓→生產）。
# A1a：蓋 task_start_tick（與 try_set 同源）——否則 transition 進場的 task（如 PRODUCE）
# 拿 stale 起算，timeout 檢查派出即秒殺（W2 TRADE 漏斗定罪過同型 bug）。
static func transition(state: WorldState, team: TeamData, new_task: String, priority: int, _source: String = "transition") -> void:
	# ★arbiter 後門根治（手不聽腦，team16 凍死）：transition 舊為無條件 raw 覆寫繞 arbiter → 外部低 prio
	# 呼叫（defection「等待新領主」@AMBIENT）clobber 引擎剛派的 survival@80 + 繞免疫 → crisis 永不 fire。
	# 補齊三 guard（對齊 try_set 的 current_task 寫入不變量）：擋「外部 in-place stomp active emergency」。
	# ★emergency task 自身的正當退場走 release（→re-rank/re-set），非靠 transition 降級：resolution caller
	#   已改 release-first（現任=IDLE@0 → guard 不 fire → 正常轉換），故此 guard 只擋 (a) 外部 stomp、不誤傷 (b) 退場。
	if team.combat_target != -1: return                       # combat lock 絕對（同 try_set:40）
	if new_task == team.crisis_released_task and team.crisis_released_task != "" \
			and state.world.current_tick < team.crisis_released_until:
		return                                                # crisis-免疫（補 transition 洩漏，對齊 try_set:45）
	if team.task_priority >= PRIO_THREAT and priority < team.task_priority:
		return                                                # emergency-respect：擋外部低 prio in-place stomp
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
