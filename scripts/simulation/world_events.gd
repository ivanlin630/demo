class_name WorldEvents

# ★T0-A1 事件匯流排：突發事件 → 相關隊【當 tick 就能重新思考】，不必等 cadence。
# 這一刀【只加不減】：cadence 輪詢照舊，pending 只是額外的喚醒來源（A2 輪詢退場是另一票）。
#
# ★pending_rethink 不入 state_fingerprint 的正當性基礎＝【單 tick 內清空】（★此前提現在仍成立）。
#
# ★★★而【喚醒會消失】這件事是真的，成因【不是順序】（2026-08-28 實測定案）：
#   實測 warring 30 日：★旗子命運 被讀過 2770 ／ ★★沒人讀過就死掉 406（12.78%）；
#   peaceful 30 日更極端：被讀過 32 ／ 沒人讀過 122（79.22%）。
#   ★★而【全部】是 lost_not_visited：消費者那一 tick 根本沒走訪該隊。
#     消費者的走訪節奏是 60（near）／600（far）tick，而旗子只活 1 tick。
#   ★★★曾試過雙緩衝（讓旗子多活一個 tick）⇒ 【救回 0 面旗子】，已回滾：
#     任何【固定壽命】都在賭「消費者剛好在窗內來」——而間隔差 60～600 倍，賭不贏。
#     ⇒ ★真修法是 per-actor 消費（旗子活到被讀為止），那是另一票。
#   ★禁分批消費這條不變。
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

# ★可見集合的【單一真值】（雙緩衝回滾後只剩 pending_rethink）。
#   ★★回傳 String 而不是 bool 的形狀留著：它讓【旗子命運】那組儀器不必再改，
#   而 per-actor 消費那一票還會用到。★★★現在它只會回 "cur" 或 ""。
#   ★同時在這裡記【誰查看過這一隊】—— 旗子命運要靠它分
#   「有走訪過卻沒讀到」與「這一 tick 根本沒走訪」。
#   ★★is_pending 由它導出，不另寫一份判斷（否則兩份會漂）。
static func pending_source(state: WorldState, team_id: int) -> String:
	# ★不管結果如何都記：這一隊【被查看過】。順序無關，「查過」就是查過。
	if Probe.enabled: state.pending_visit[team_id] = state.world.current_tick
	if state.pending_rethink.has(team_id):
		if Probe.enabled: state.pending_seen[team_id] = state.world.current_tick
		return "cur"
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
	return ""

static func is_pending_faction(state: WorldState, faction) -> bool:
	return pending_source_faction(state, faction) != ""

# ★★★tick 結尾清空（★雙緩衝已回滾，2026-08-28）：
#   ★回滾理由（systems 裁）：雙緩衝【救回 0 面旗子】(bonus 救回 = 0，兩張床)，
#     而代價是真的 —— pending_prev 進了 state_fingerprint ⇒ 往後每一次「fp 變了」
#     都要先排除「是不是指紋定義又變了」＝ ★★汙染主要偵測器。
#   ★★★真成因不是【順序】是【走訪間隔】：消費者 60／600 tick 才走訪一次，
#     而任何【固定壽命】都在賭「消費者剛好在窗內來」—— 賭不贏。
#     ⇒ 真修法是 per-actor 消費（旗子活到被讀為止），那是另一票。
#
# ★而【旗子命運結算】留著：單緩衝下它量的就是【每 tick 有多少喚醒沒人讀到】——
#   ★★那正是 per-actor 那一票要用的基線，而且它現在量的是【真實現況】不是某個修法的效果。
static func consume_and_clear(state: WorldState) -> void:
	if state.pending_rethink.is_empty():
		if Probe.enabled: state.pending_seen = {}
		return
	if Probe.enabled:
		Probe.bump("t0.consumed", state.pending_rethink.size())
		# ★旗子只活這一 tick ⇒ 沒被讀過就是【消失】。與 tick 內順序無關（讀過就是讀過）。
		var _now: int = state.world.current_tick
		for lid in state.pending_rethink:
			if int(state.pending_seen.get(lid, -999999)) >= _now:
				Probe.bump("t0.flag_consumed")
			else:
				if int(state.pending_visit.get(lid, -999999)) >= _now:
					Probe.bump("t0.lost_ordering")      # 這一 tick 走訪過，但走訪在 emit 之前
				else:
					Probe.bump("t0.lost_not_visited")   # 這一 tick 根本沒走訪這一隊
				# ★★★樣本要涵蓋【兩種丟法】—— systems 問的是「那些丟掉的喚醒」，
				#   ★不是只問其中一種。第一版我只採樣 not_visited，
				#   ★★而實測多數是 ordering（warring 30 日：379 vs 27）⇒ 會漏掉九成母體。
				#   ★★★留樣本是要回答「這一隊【下一次真正被走訪】時，選擇有沒有改變」，
				#     那是為了避開反事實（「若沒丟會怎樣」量不到）。
				var _lt = state.teams.get(lid)
				Probe.bump_sample("t0.lost_at", {"team": lid, "t": _now,
					"fid": int(_lt.faction_id) if _lt != null else -1}, 40000)
		state.pending_seen = {}
	state.pending_rethink.clear()
