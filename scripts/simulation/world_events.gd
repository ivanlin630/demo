class_name WorldEvents

# ★T0-A1 事件匯流排：突發事件 → 相關隊【當 tick 就能重新思考】，不必等 cadence。
# 這一刀【只加不減】：cadence 輪詢照舊，pending 只是額外的喚醒來源（A2 輪詢退場是另一票）。
#
# ★★★【已失效的舊前提】（t0-emit-ordering 推翻，留著是因為它解釋了現在的形狀）：
#   舊：「pending_rethink 不入 state_fingerprint 的正當性基礎＝單 tick 內清空。」
#   ★而那個「單 tick 內清空」本身就是 bug 的成因：
#     排在消費者【之後】才 emit 的，在被讀到前就被清掉 ——
#     實測 warring 30 日：★★【消失 28,385 次嗚醒】（整體落空 12.5%）。
#   ★★★現在：雙緩衝（pending_prev ∪ pending_rethink）⇒ 跨 tick 存活
#     ⇒ ★pending_prev 【已經進 state_fingerprint】。兩件必須同進退。
#   ★禁分批消費這條不變：換頁是【整批】搞，不是一顆一顆消。
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
		# ★★★emit 當下把【主體隊 + 它的勢力 + 有沒有領袖】一起記下來。
		#   ★為什麼要記 faction：勢力層那五支的 actor 是【勢力】而 subjects 是【隊】
		#     ⇒ 不帶 faction 就 join 不起來，★★而 join 不起來會被誤讀成「沒人醒」。
		#   ★★★為什麼記在 emit 當下而不是跑完回頭查：30 日內隊會換勢力、領袖會死 ——
		#     拿收尾狀態回頭判，會把【當時存在的消費者】判成不存在。
		#   ★seen / unseen 由床【事後】對接 poll.eventwake 算，production 不做判斷。
		for tid2 in subjects:
			var id2: int = int(tid2)
			if id2 == -1 or not state.teams.has(id2):
				continue
			var _tm = state.teams[id2]
			Probe.bump_sample("t0.emit_ctx", {"k": kind, "t": state.world.current_tick,
				"team": id2, "fid": int(_tm.faction_id), "leader": int(_tm.leader_id)}, 40000)

# ★★★可見集合的【單一真值】：pending_prev ∪ pending_rethink。
#   回傳來源而不只是 bool —— ★死水要能分「本 tick 就看到」與「延到下一 tick 才看到」，
#   而那一欄從 0 變正數【就是本票的效果量】。
#   ★★is_pending 由它導出，不另寫一份判斷（否則兩份會漂）。
static func pending_source(state: WorldState, team_id: int) -> String:
	# ★不管結果如何都記：這一隊【被查看過】。順序無關，「查過」就是查過。
	if Probe.enabled: state.pending_visit[team_id] = state.world.current_tick
	if state.pending_rethink.has(team_id):
		if Probe.enabled: state.pending_seen[team_id] = state.world.current_tick
		return "cur"
	if state.pending_prev.has(team_id):
		if Probe.enabled: state.pending_seen[team_id] = state.world.current_tick
		return "prev"
	return ""

static func is_pending(state: WorldState, team_id: int) -> bool:
	return pending_source(state, team_id) != ""

# ★★faction 層的查詢：pending_rethink 是【team_id 索引】，而五支 T3 節律是 faction 級。
#   ★這不是第二套機制 —— 它讀的是同一份 pending_rethink，只是換一個 scope 問。
#   ★★語意寫死：【任一成員隊被喚醒 ⇒ 該勢力本 tick 重想】
#     理由：勢力層的決策吃的就是成員隊的狀態，成員出事而勢力不重想，
#     正是【手不聽腦】的另一型。
static func pending_source_faction(state: WorldState, faction) -> String:
	if faction == null:
		return ""
	# ★★先掃一輪 cur，再掃一輪 prev —— ★不可以逐隊比對兩格就早退，
	#   否則「某隊 prev 有、另一隊 cur 有」會依成員順序回不同答案（★同一世界兩種結果）。
	var lead: int = int(faction.leader_team_id)
	if Probe.enabled:
		# ★勢力層查的是【成員隊】⇒ 這些隊都算被查看過。
		#   ★★早退（命中就 return）的情況不影響判斷：命中代表旗子【被讀到】，
		#     那面旗子本來就不會進 lost。
		state.pending_visit[lead] = state.world.current_tick
		for mv in faction.member_team_ids:
			state.pending_visit[int(mv)] = state.world.current_tick
	if state.pending_rethink.has(lead):
		if Probe.enabled: state.pending_seen[lead] = state.world.current_tick
		return "cur"
	for mid in faction.member_team_ids:
		if state.pending_rethink.has(int(mid)):
			if Probe.enabled: state.pending_seen[int(mid)] = state.world.current_tick
			return "cur"
	if state.pending_prev.has(lead):
		if Probe.enabled: state.pending_seen[lead] = state.world.current_tick
		return "prev"
	for mid2 in faction.member_team_ids:
		if state.pending_prev.has(int(mid2)):
			if Probe.enabled: state.pending_seen[int(mid2)] = state.world.current_tick
			return "prev"
	return ""

static func is_pending_faction(state: WorldState, faction) -> bool:
	return pending_source_faction(state, faction) != ""

# ★★★tick 結尾【換頁】（不再是清空）：本 tick 的整批 → prev，供【下一 tick 的完整一輪】看到。
#   ★舊註解說「不跨 tick 存活，這是不入 fingerprint 的正當性基礎」——★★那個前提現在【失效了】，
#     所以 pending_prev 已經加進 state_fingerprint。兩件事必須同進退，不能只改一邊。
#   ★★★代價寫明：一發 emit 現在【最多被看到兩個 tick】（本 tick + 下一 tick）
#     ⇒ 同一顆事件可能喚醒同一支兩次。那是這個形狀的固有成本，不是 bug，
#     而它可量（死水的 delayed 欄）。★用「消失 28,385 次」換「可能重醒一次」。
#   ★誠實界定不變：本函式不提供消費【順序】保證——那由既有 team 迴圈決定。
static func consume_and_clear(state: WorldState) -> void:
	if Probe.enabled and not state.pending_rethink.is_empty():
		Probe.bump("t0.consumed", state.pending_rethink.size())
	if state.pending_rethink.is_empty() and state.pending_prev.is_empty():
		return
	# ★★★換頁【之前】結算上一批的命運：pending_prev 裡即將被丟掉的旗子，
	#   有沒有人讀過它？★沒人讀過 ⇒ 這一發喚醒【真的消失了】。
	#   ★★這是需求①的字面量測，而且與 tick 內順序無關（讀過就是讀過）。
	if Probe.enabled:
		# ★★★needs①「不得消失」拆兩件（systems 訂正：需求本身包含兩個成因）：
		#   ①a lost_ordering    旗子死時，消費者【在窗內查看過這一隊】⇒ ★雙緩衝的責任，必須歸零
		#   ①b lost_not_visited 旗子死時，消費者【窗內根本沒查它】⇒ ★★雙緩衝修不掉
		#      （消費者 600 tick 才走訪一次，而旗子只活 2 tick）⇒ ★★★照實報，不算失敗
		#   ★窗 = {C-1, C}：此刻 pending_prev 裝的是上一 tick 的旗子，本 tick 結尾丟掉。
		# ★★★off-by-one 血證（第一版）：pending_seen 存 bool 並在【每次換頁清空】，
		#   而旗子活【兩個 tick】⇒ ★在第一個 tick 被讀到的，結算前就被我清掉了
		#   ⇒ ★★量出「被讀過 = 0 ／ 消失率 100%」——而同一份輸出的 dw4 欄同時顯示
		#      GOAL 事件醒了 3289 次。★★★兩欄打架才抓到，不是我自己看出來的。
		#   ⇒ 改存【最後一次被讀到的 tick】並比對窗，不再清空（dict 以隊數為界）。
		var _win_lo: int = state.world.current_tick - 1
		for lid in state.pending_prev:
			if int(state.pending_seen.get(lid, -999999)) >= _win_lo:
				Probe.bump("t0.flag_consumed")
			elif int(state.pending_visit.get(lid, -999999)) >= _win_lo:
				Probe.bump("t0.lost_ordering")
			else:
				Probe.bump("t0.lost_not_visited")
	state.pending_prev = state.pending_rethink
	state.pending_rethink = {}
