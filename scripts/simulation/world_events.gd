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
	"construction_stalled",     # ★零進度持續 ≥ 耐性窗。★【不是】失敗：量到的 3 個工地後來全部蓋完。
	                            #   保留它是因為它是「開了工卻沒人上工」的唯一觀測器，丟掉等於丟線索。
	"construction_abandoned",   # ★承諾【真的消失】：換 task 且不 serves ／ 工地易主。這個才是執行型失敗進料口。
	"plan_invalidated",    # ★FailureMemory.record_invalidation（當前計畫已不可行→該隊當 tick 重想）
	"rung_changed",        # ★AmbitionLadder.update 升/降野心階（ambition_ladder.gd）
	                       #   ★★這一顆【不是「我們沒想到的事件」，是我們自己 S3 開的洞】：
	                       #     rung 是意圖資格的閘（faction_ai_system.gd:1181
	                       #     `ambition_rung >= RUNG_EXPAND` 才選得了擴張），
	                       #   ★★★而 S3 把 INTENT 從 10 小時搬到 T3=3 日 ⇒ 升階最多 3 日才反映到意圖。
	                       #     S3 之前這個延遲是 10 小時，所以當時看不見。
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
		# ★★★真 emit 站的【時序】樣本（kind, 主體隊, tick）。
		#   ★動機是我自己驗收的一個盲點：S4b 的 210 格是把 burst 注在 advance_tick【之前】，
		#     所以那些格子永遠看得到 pending ⇒ ★★它證的是【閘會不會醒】，
		#     ★★★不是【真 emit 站有沒有趕在消費者那一 pass 之前】。
		#   而 pending_rethink 是【tick 結尾清空】⇒ 在消費者 pass【之後】才 emit 的那些，
		#   ★會在被讀到前就被清掉 ——「emit 了」與「有人醒了」是兩件事。
		#   ⇒ 這顆樣本要跟 poll.eventwake 對接，才答得出【哪些 kind 的真 emit 真的叫醒了誰】。
		for tid2 in subjects:
			var id2: int = int(tid2)
			if state.teams.has(id2):
				# ★emit 的 subjects 一律是隊 id ⇒ 前綴 "T"（與 DecisionTier.actor_scope 同一套）
				Probe.bump_sample("t0.emit_at", {"k": kind, "a": "T" + str(id2), "t": state.world.current_tick}, 40000)

static func is_pending(state: WorldState, team_id: int) -> bool:
	return state.pending_rethink.has(team_id)

# ★★faction 層的查詢：pending_rethink 是【team_id 索引】，而五支 T3 節律是 faction 級。
#   ★這不是第二套機制 —— 它讀的是同一份 pending_rethink，只是換一個 scope 問。
#   ★★語意寫死：【任一成員隊被喚醒 ⇒ 該勢力本 tick 重想】
#     理由：勢力層的決策吃的就是成員隊的狀態，成員出事而勢力不重想，
#     正是【手不聽腦】的另一型。
static func is_pending_faction(state: WorldState, faction) -> bool:
	if faction == null:
		return false
	if state.pending_rethink.has(int(faction.leader_team_id)):
		return true
	for mid in faction.member_team_ids:
		if state.pending_rethink.has(int(mid)):
			return true
	return false

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
