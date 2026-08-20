class_name WorldEvents

# ★T0-A1 事件匯流排：突發事件 → 相關隊【當 tick 就能重新思考】，不必等 cadence。
# 這一刀【只加不減】：cadence 輪詢照舊，pending 只是額外的喚醒來源（A2 輪詢退場是另一票）。
#
# ★pending_rethink 不入 state_fingerprint 的正當性基礎＝【單 tick 內清空】：
#   emit 在本 tick 標記 → 本 tick 的決策迴圈讀 → 本 tick 結尾 consume_and_clear 清空。
#   ★禁分批消費（跨 tick 存活＝determinism 盲點；而且 byte-identical 抓不到「三跑都一樣殘留」的偽陰性）。
#
# ★掛點表（T4 對帳守衛讀這裡）：三類——
#   ①訊息型（emit_message 為 chokepoint、逐 type 掛）
#   ②函式 chokepoint 型（不經訊息層的：戰鬥起/領袖死/滅團/同批死亡/★背叛）
#   ③狀態跨線型（本來連偵測點都沒有、本刀新增）
# ★誠實邊界：守衛只結構性保護 ①（type 集合可枚舉）；②③ 沒有結構性保護
#   （背叛正是從這缺口漏的：它全檔零 emit_message、卻有 player_alerts 通知玩家＝玩家中心家族）。

# ①訊息型：emit_message 的全部 type（T4 守衛與此對帳；新增 type 未掛＝FAIL）
const MESSAGE_KINDS: Array = [
	"combat_start", "combat_end", "famine_warning", "faction_defect", "faction_establish",
	"diplomacy", "extortion", "subjugate", "tribute", "aid_given", "aid_refused",
	"trade_done", "order_buy", "order_sell", "order_delivered", "outpost_built",
	"split", "replace",
]

# ②函式 chokepoint 型（不經訊息層）
const FUNC_KINDS: Array = [
	"combat_engaged",      # NpcCombatSystem.start_combat（被襲）
	"leader_death",        # EventSystem.on_leader_death
	"team_extinct",        # FactionAISystem._on_team_extinct（目睹）
	"teams_erased",        # WorldState.erase_teams（同批死亡）
	"betrayed",            # ★DiplomaticAiSystem._execute_betrayal（受害方＝ally_team）
	"convoy_stranded",     # FactionAISystem._convoy_go_independent（回不了母隊→轉獨立，帶著貨自謀生路）
	"plan_invalidated",    # ★FailureMemory.record_invalidation（當前計畫已不可行→該隊當 tick 重想）
]

# ③狀態跨線型（本刀新增偵測點）
const STATE_KINDS: Array = [
	"famine_crossed",      # famine_days 由 0 轉正
	"labor_crisis",        # 共址勞力池危機（食物餘命跌破危機線）
	"intel_arrived",       # 關鍵情報抵達（belief 更新改變已知威脅/機會）
]

static func all_kinds() -> Array:
	return MESSAGE_KINDS + FUNC_KINDS + STATE_KINDS

# 標記：subjects 內每一隊在【本 tick】可立即重新思考。
static func emit(state: WorldState, kind: String, subjects: Array) -> void:
	if state == null or subjects.is_empty():
		return
	for tid in subjects:
		var id: int = int(tid)
		if id == -1 or not state.teams.has(id):
			continue
		state.pending_rethink[id] = true
	if Probe.enabled:
		Probe.bump("t0.emit")
		Probe.bump("t0.emit." + kind)

static func is_pending(state: WorldState, team_id: int) -> bool:
	return state.pending_rethink.has(team_id)

# ★單 tick 清空（sim_runner tick 結尾呼一次）：不分批、不跨 tick 存活
#（這是 pending_rethink 不入 state_fingerprint 的正當性基礎）。
# ★誠實界定：本函式【只負責清空】——決策的消費順序由既有 team 迴圈決定
#   （那本來就是 deterministic 的）；這裡不提供、也不需要順序保證。
static func consume_and_clear(state: WorldState) -> void:
	if state.pending_rethink.is_empty():
		return
	if Probe.enabled:
		Probe.bump("t0.consumed", state.pending_rethink.size())
	state.pending_rethink.clear()
