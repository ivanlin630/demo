class_name HandBrainProbe

# 「手聽腦」單點同-tick 不變量探針（純觀測，env-gated 預設關，關時 byte-identical）。
#
# 取代舊 hand_obeys_brain_bed 的「跨修 aggregate 率比」——那法三漏洞（腦模型比真引擎窄／執行中
# 誤判／跨版本分岔噪音）讓它當閘壞。本探針改「單點同-tick」：掛在引擎真正做決策的那一刻
#（_decide_unified／非-unified solo dispatch），在引擎敲定 winner、呼叫 TaskArbiter.try_set 的
# 同一 tick、同一 state，當場比對「腦這次實際敲定的 task」vs「手 try_set 後實際持有的 current_task」。
# 零延遲、零重算 → 執行中誤判消失；同 seed 同 code 逐事件確定性復現。
#
# 核心不變量：引擎為此隊敲定 dispatch 決策 → current_task 必 == 該 winner task（除物理鎖/高優先豁免）。
#   違反 = 事件，依同-tick 可觀測 state 分機制：
#     arbiter_latch      — try_set 被現任 @>=50 嚴格大於閘丟（含 no-release busy）；winner 沒到手。
#     side_effect_freeze — try_set 失敗但 combat_target 副作用已落（D2）；手凍在非戰鬥 task。
#     subset_fallthrough — winner 落地但非誠實 rank[0]（rank[0] 被 feasibility/continue 跳過→次佳，含 D5）。
#     other              — 其餘背離。
#   豁免（非違規）：
#     player       — 玩家令 @60 合法壓過 @50 dispatch。
#     subset_active— 隊在 survival@80/threat@70 task（更急迫 weigh 合法持有）。此即舊漏洞①：
#                    「引擎的窄@50模型 ≠ 寬 survival 模型」是模型差非 bug，不計違規。
#
# 另（A2 scope，結構計數非本 tick 不變量）：leader/subteam 手寫 dispatch 繞引擎 → leader_bypass/subteam_bypass。
#
# 非擾動硬保：capture/note 只讀 team.current_task/combat_target/task_priority/task_reason + append 自家
#   static 陣列；零 team/world state 寫、零 RNG。enabled=false → 首行 early-return，byte-identical。

static var enabled: bool = false

# ── 引擎單點不變量（unified + 非-unified solo dispatch 路）──
static var decisions: int = 0            # 觀測到的引擎 dispatch 決策點總數
static var obeys: int = 0                # current_task == winner 且 winner == rank[0]
static var excused: int = 0
static var violations: int = 0
static var mech: Dictionary = {}         # 機制 → count（arbiter_latch/side_effect_freeze/subset_fallthrough/other）
static var excuse: Dictionary = {}       # 豁免 → count（player/subset_active）
static var src_dec: Dictionary = {}      # src(unified/solo) → 決策數
static var src_viol: Dictionary = {}     # src → 違規數
static var rank0_hist: Dictionary = {}   # rank[0] opt 分布（腦想要什麼）
static var fallthrough_hist: Dictionary = {}   # fallthrough 時 rank[0] opt 分布（哪個腦頂選被跳）

# ── 繞引擎 dispatch（A2 scope，結構計數）──
static var bypass: Dictionary = {}       # "leader"/"subteam" → count

# ── 事件清單（同 run 內確定性；capped 供 dump/記憶體）──
static var events: Array = []
const MAX_EVENTS: int = 4000

const MECHS: Array = ["arbiter_latch", "side_effect_freeze", "subset_fallthrough", "other"]
const EXCUSES: Array = ["player", "subset_active"]
const COMBAT_TASKS: Array = [TeamData.TASK_ATTACK, TeamData.TASK_LOOT, TeamData.TASK_DEFEND]
const LEADER_BYPASS_REASONS: Array = ["faction_tribute", "faction_diplomacy", "faction_goal", "consolidate"]
const SUBTEAM_BYPASS_REASONS: Array = ["subteam_idle", "deviation"]

static func reset() -> void:
	decisions = 0; obeys = 0; excused = 0; violations = 0
	mech = {}
	for m in MECHS: mech[m] = 0
	excuse = {}
	for e in EXCUSES: excuse[e] = 0
	src_dec = {}; src_viol = {}
	rank0_hist = {}; fallthrough_hist = {}
	bypass = {"leader": 0, "subteam": 0}
	events = []

# ── 引擎單點探針：_decide_unified／非-unified solo 敲定 winner + try_set + 副作用後、return 前呼叫。──
#   rank0_opt = ranked[0]["opt"]（腦誠實菜單頂，未經 feasibility 跳過）
#   winner_opt/winner_task = 引擎本 cadence 實派（try_set 的 task）
#   set_ok = try_set 回值（非-unified solo 路恆真：失敗則 continue 試次佳）
# 讀 team 此刻 state（同 tick 同 ctx）→ 比對，零寫零 RNG。
static func capture(state: WorldState, team: TeamData, src: String, rank0_opt: String,
		winner_opt: String, winner_task: String, set_ok: bool) -> void:
	if not enabled: return
	decisions += 1
	src_dec[src] = int(src_dec.get(src, 0)) + 1
	rank0_hist[rank0_opt] = int(rank0_hist.get(rank0_opt, 0)) + 1
	var result_task: String = team.current_task

	# ── 手是否持有腦這次敲定的 winner task？──
	if result_task == winner_task:
		if winner_opt == rank0_opt:
			obeys += 1
			return
		# winner 落地但非誠實 rank[0]（rank[0] 被 feasibility/continue 跳 → 次佳 fallthrough）
		fallthrough_hist[rank0_opt] = int(fallthrough_hist.get(rank0_opt, 0)) + 1
		_violation(state, team, src, "subset_fallthrough", rank0_opt, winner_opt, winner_task, result_task, set_ok)
		return

	# ── 手未持有 winner：先高優先/物理鎖豁免（漏洞① 修：更急迫 weigh 合法持有非 bug）──
	if team.task_priority == TaskArbiter.PRIO_PLAYER or not team.player_commanded_task.is_empty():
		excused += 1; excuse["player"] += 1; return
	if team.task_priority == TaskArbiter.PRIO_SURVIVAL or team.task_priority == TaskArbiter.PRIO_THREAT:
		excused += 1; excuse["subset_active"] += 1; return

	# ── 分機制 ──
	if team.combat_target != -1 and not (result_task in COMBAT_TASKS):
		_violation(state, team, src, "side_effect_freeze", rank0_opt, winner_opt, winner_task, result_task, set_ok)
	elif not set_ok:
		_violation(state, team, src, "arbiter_latch", rank0_opt, winner_opt, winner_task, result_task, set_ok)
	else:
		_violation(state, team, src, "other", rank0_opt, winner_opt, winner_task, result_task, set_ok)

static func _violation(state: WorldState, team: TeamData, src: String, mech_key: String,
		rank0_opt: String, winner_opt: String, winner_task: String, result_task: String, set_ok: bool) -> void:
	violations += 1
	mech[mech_key] = int(mech.get(mech_key, 0)) + 1
	src_viol[src] = int(src_viol.get(src, 0)) + 1
	if events.size() < MAX_EVENTS:
		events.append({
			"tick": state.world.current_tick, "team_id": team.team_id,
			"cat": _category(state, team), "src": src, "mech": mech_key,
			"rank0_opt": rank0_opt, "winner_opt": winner_opt,
			"winner_task": winner_task, "result_task": result_task,
			"set_ok": set_ok, "prio": team.task_priority, "ct": team.combat_target,
		})

# ── 繞引擎 dispatch 計數（A2 scope）：leader cascade／subteam argmax 手寫 try_set 成功後呼。──
#   task_start_tick == 本 tick（AI phase，current_tick 尚未 +1）且 reason ∈ bypass 集 → 本 tick 一次繞過。
static func note_bypass(state: WorldState, team: TeamData, cat: String) -> void:
	if not enabled: return
	if team.task_start_tick != state.world.current_tick: return
	var reasons: Array = LEADER_BYPASS_REASONS if cat == "leader" else SUBTEAM_BYPASS_REASONS
	if not (team.task_reason in reasons): return
	bypass[cat] = int(bypass.get(cat, 0)) + 1
	if events.size() < MAX_EVENTS:
		events.append({
			"tick": state.world.current_tick, "team_id": team.team_id,
			"cat": cat, "src": "bypass", "mech": cat + "_bypass",
			"winner_task": team.current_task, "reason": team.task_reason,
		})

static func _category(state: WorldState, team: TeamData) -> String:
	if team.parent_team_id != -1:
		return "subteam"
	if team.faction_id != -1:
		var f = state.factions.get(team.faction_id)
		if f != null and f.leader_team_id == team.team_id:
			return "leader"
		return "member"
	return "solo"

# ── 快照（bed 每 seed 跑完取值 → 存 → reset 下一 seed）──
static func snapshot() -> Dictionary:
	return {
		"decisions": decisions, "obeys": obeys, "excused": excused, "violations": violations,
		"mech": mech.duplicate(), "excuse": excuse.duplicate(),
		"src_dec": src_dec.duplicate(), "src_viol": src_viol.duplicate(),
		"rank0_hist": rank0_hist.duplicate(), "fallthrough_hist": fallthrough_hist.duplicate(),
		"bypass": bypass.duplicate(),
		"events": events.duplicate(true),
	}
