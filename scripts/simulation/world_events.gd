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
	# ══ 本票新增（spec 2026-09-25 #4）：玩家事件流原本對自家隊【全盲】 ══
	# ★★★這四種都用 `wake_thinking = false` —— 理由不是效能，是【範圍】：
	#   它們是【給玩家看的資訊事件】，而本票的目的是「玩家看得見」，不是「改 NPC 行為」。
	#   ⇒ 傳 true 會順便改 NPC 的 thinking 排程 ＝ 這張票沒有被要求的行為改動。
	# ★★而【誠實限】：`emit()` 仍然無條件設 `pending_rethink[id]` ⇒
	#   ★★★行為面【沒有】被完全關掉，而那是 spec 要求「寫入點在 emit 內」的必然結果
	#   （一個事件進了匯流排，就會喚醒它的主體）。實測這一輪零漂移，但那是【量到的】
	#   不是【結構保證的】—— 已呈報 systems 判要不要讓這四種真的喚醒 NPC。
	# ★★★掛點刻意【不是】 `state.remove_member()`：它 13 個產品呼叫端裡只有 3 個是真的
	#   離隊／死亡，其餘是分家出母隊／繼任 leader 出 named／轉隊 ⇒ 掛那裡會噴假事件。
	"member_left",         # ★ReactionSystem N1_flee／N3_defect（★帶 reason，spec P6）
	"member_died",         # ★HealthSystem.check_starvation_deaths（★帶 cause：餓死／失血而亡）
	"came_of_age",         # ★PopulationSystem 未成年長大（帶人數）
	"member_joined",       # ★PlayerCommandSystem 招募匿名成功（帶實際搬過來的人數）
	                       #   ★★這一顆【不是「我們沒想到的事件」，是我們自己 S3 開的洞】：
	                       #     rung 是意圖資格的閘（faction_ai_system.gd:1181
	                       #     `ambition_rung >= RUNG_EXPAND` 才選得了擴張），
	                       #   ★★★而 S3 把 INTENT 從 10 小時搬到 T3=3 日 ⇒ 升階最多 3 日才反映到意圖。
	                       #     S3 之前這個延遲是 10 小時，所以當時看不見。
	# ══ 本票新增（spec 2026-09-29 #7③）：強制事件的【生命週期三點】 ══
	# ★★★原本三點【一點都不在】玩家事件流裡：到達只有 UI 面板（玩家離開面板就再也看不到）、
	#   回應結果只有指令佇列那一句、逾時只有一行 `str(dict)` 的終端 debug print。
	#   ⇒ 用戶逐字「像 team11 找我要幹嘛我 UI 看不到 至少終端 LOG 要記錄吧?」
	# ★三種的 subject 都是【玩家自己的隊】（事情是關於玩家被找上門）⇒ 走自家隊 self-knowledge。
	"forced_event_arrived",   # ★WorldState.set_player_forced_event（唯一寫入口,8 個產生端都經過）
	"forced_event_resolved",  # ★PlayerCommandSystem.respond_to_forced（★帶 handler 自己回的 msg）
	"forced_event_timeout",   # ★SimRunner hour-tick 自動拒絕
	# ══ M 票 §2（藍圖 fda4636f1）：敵對隊進到玩家隊同格或相鄰 —— 寫入點在模擬層算完位置之後（SimRunner._note_hostile_adjacent）══
	"hostile_adjacent",
	# ══ #8-0（spec 2026-10-13-alliance-never-moves-faction-leader）：據點易主 —— 寫入點在 OutpostOwnerBank.set_owner（單寫者）══
	#   ★只在玩家相關時 emit、wake_thinking=false（NPC↔NPC 易主不進匯流排）
	"outpost_owner_changed",
	"resident_changed_faction",   # ★#8-2 登記居民改投別的勢力（地主要知道；玩家相關才發）
	# ══ spec 2026-10-13-player-subteams 二：玩家子隊的物理與事件 ＝ 玩家事件（被攻擊／糧將盡／紀律脫離／逾時併回／分團）══
	#   ★寫入點＝emit_player_subteam（各發生處呼它）；subjects＝[玩家隊, 子隊]、wake_thinking=false
	"player_subteam",
]

# ③狀態跨線型（本刀新增偵測點）
const STATE_KINDS: Array = [
	"famine_crossed",      # famine_days 由 0 轉正
	"labor_crisis",        # 共址勞力池危機（食物餘命跌破危機線）
	"intel_arrived",       # 關鍵情報抵達（belief 更新改變已知威脅/機會）
	"captive_overguard",   # ★玩家 holder 俘虜超過可看守數（不超額→超額那一次；spec 2026-10-14-battle-aftermath §2c）
	"captive_unfed",       # ★玩家 holder 養不起俘虜 ⇒ 被放走（與 NPC 缺糧釋放對稱）
	"aftermath_settled",   # ★戰後沒處置就推進 ⇒ 被動選項結清（PlayerCommandSystem.settle_pending_aftermath）
]

static func all_kinds() -> Array:
	return MESSAGE_KINDS + FUNC_KINDS + STATE_KINDS

# ══ ★D1（spec 2026-10-07 play-py-real-run-four-screen-defects §1）：kind → 玩家看得懂的短名【唯一一份】══════
# ★事件流的「來源」欄與 describe() 沒有專屬句子時的那一句，都從這裡取 ⇒ 識別字不會再漏到玩家畫面
# ★母體 ＝ all_kinds()（三張清單）；E2E 格 a 逐一驗每個 kind 都有短名（新增 kind 的人會被擋下來）
const KIND_LABEL: Dictionary = {
	"combat_start": "開戰", "combat_end": "戰鬥結束", "famine_warning": "饑荒警訊",
	"faction_defect": "叛離勢力", "faction_establish": "建立勢力", "diplomacy": "外交",
	"extortion": "勒索", "subjugate": "臣服", "tribute": "進貢", "aid_given": "援助",
	"aid_refused": "拒絕援助", "trade_done": "成交", "order_buy": "收購單", "order_sell": "出售單",
	"order_delivered": "交貨", "outpost_built": "建成據點", "split": "分裂", "replace": "換人領導",
	"combat_engaged": "戰鬥", "leader_death": "領袖身亡", "team_extinct": "全滅", "teams_erased": "消失",
	"betrayed": "背叛", "convoy_stranded": "運輸隊", "construction_stalled": "工地",
	"construction_abandoned": "工地", "plan_invalidated": "計畫", "rung_changed": "野心",
	"member_left": "離隊", "member_died": "死亡", "came_of_age": "成年", "member_joined": "招募",
	"forced_event_arrived": "找上門", "forced_event_resolved": "回應", "forced_event_timeout": "逾時",
	"famine_crossed": "饑荒", "labor_crisis": "勞力危機", "intel_arrived": "情報", "captive_overguard": "看守不足", "captive_unfed": "俘虜放走", "aftermath_settled": "戰後", "hostile_adjacent": "敵人逼近",
	"outpost_owner_changed": "據點易主", "resident_changed_faction": "居民改投",
	"player_subteam": "子隊",
}
# ══ ★M 票 §2：推進的停點（具名集合，唯一一份）—— 推進碰到這幾種【涉及玩家隊】的事件就停在那一 tick ══════════════
#   找上門／提案到達（強制事件）、被攻擊或遭遇開始、敵對隊進入同格或相鄰格、成員死亡或離隊、★自家隊開始挨餓
#   ★挨餓（famine_crossed＝famine_days 由 0 轉正那一刻；spec 2026-10-13-possessed-team-followups 乙，藍圖裁「開始挨餓」進停點）
#     不節流：附身 30 天兩世界（待機／每天狩獵）×2 種子，單日最多 1 次（docs/measurements/2026-10-14-possessed-followups/）
#     ⇒ 若日後出現「一天停好幾次」，那是糧在 0 附近震盪（吃飽／滿足度兩處歸零），回去看那份量測，不要在這裡加冷卻
#   ★抵達目的地不走 kind（UI 讀 move_target 邊緣，M 票 §1④）；★看到新的隊伍不是停點
const ADVANCE_STOP_KINDS: Array = ["forced_event_arrived", "combat_engaged", "combat_start", "combat_end", "hostile_adjacent",
	"member_died", "member_left", "outpost_owner_changed", "resident_changed_faction", "player_subteam",
	"famine_crossed"]

# 玩家事件匯流排上 seq0 之後第一筆停點事件（kind ∈ ADVANCE_STOP_KINDS 且主體含玩家隊）；沒有 ⇒ {}
static func stop_event_since(state: WorldState, seq0: int) -> Dictionary:
	var ptid: int = state.get_player_team_id()
	if ptid == -1:
		return {}
	for e in state.player_events:
		var d: Dictionary = e
		if int(d.get("seq", 0)) <= seq0:
			continue
		if ADVANCE_STOP_KINDS.has(String(d.get("kind", ""))) and (d.get("subjects", []) as Array).has(ptid):
			return d
	return {}

# 查不到 ⇒ ""（呼叫端據此【不印給玩家】；debug 走法印原名）
static func kind_label(kind: String) -> String:
	return String(KIND_LABEL.get(kind, ""))

# 標記：subjects 內每一隊在【本 tick】可立即重新思考。
# ★★★`wake_thinking` 預設 **true**（票 §10.1）：
#   ⇒ **任何未來新增的 emit 都會自動維持瞬醒** ＝ 構造保證。
#   ★反過來設計（預設 false、需要的人自己打開）＝ 清單保證 ⇒ 漏改一處就【靜默失去瞬醒】。
# ★玩家子隊事件的唯一寫入口（spec player-subteams 二）：what ∈ PLAYER_SUBTEAM_WHAT；句子帶子隊名與位置
#   ★呼叫端只在「這一隊是玩家子隊」時呼（紀律脫離那一格在脫離前判）；附身隊本身不走這裡
const PLAYER_SUBTEAM_WHAT: Dictionary = {
	"attacked": "被 %s 攻擊（照常自衛，不會自己逃；要不要召回由你決定）",
	"famine": "斷糧了",   # ★掛在 famine_crossed 那一點（famine_days 由 0 轉正），不另算一條「將盡」線
	"discipline_fail": "紀律失效，脫離成獨立隊",
	"construct_timeout": "抵達後遲遲沒有開工，停在原地待命（召回才會回來）",
	"capacity_split": "人數超過容量，分出 %d 人",
	"settle_refused": "到了，但那裡已經不是你的據點，原地待命",
	"camp_refused": "到了，但那格已經有據點或營地，原地待命",
	"build_refused": "到了，但沒能開工（%s），原地待命",
}

static func emit_player_subteam(state: WorldState, sub: TeamData, what: String, info: Dictionary = {}) -> void:
	var ptid: int = state.get_player_team_id()
	if ptid == -1 or sub == null:
		return
	var d: Dictionary = info.duplicate()
	d["what"] = what
	d["sub"] = sub.team_id
	d["pos"] = sub.tile_pos
	emit(state, "player_subteam", [ptid, sub.team_id], false, d)

static func _player_subteam_sentence(state: WorldState, info: Dictionary) -> String:
	var what: String = String(info.get("what", ""))
	var tpl: String = String(PLAYER_SUBTEAM_WHAT.get(what, what))
	var body: String = tpl
	match what:
		"attacked":       body = tpl % _team_name(state, int(info.get("by", -1)))
		"capacity_split": body = tpl % int(info.get("n", 0))
		"build_refused":  body = tpl % String(info.get("reason", ""))
	var p: Vector2i = info.get("pos", Vector2i(-1, -1))
	return "你的子隊 %s 在 (%d,%d) %s" % [_team_name(state, int(info.get("sub", -1))), p.x, p.y, body]

static func emit(state: WorldState, kind: String, subjects: Array,
		wake_thinking: bool = true, info: Dictionary = {}) -> void:
	if state == null or subjects.is_empty():
		return
	for tid in subjects:
		var id: int = int(tid)
		if id == -1 or not state.teams.has(id):
			continue
		state.pending_rethink[id] = true
		if wake_thinking:
			state.pending_think[id] = true
	# ★★★玩家可見事件佇列的【唯一寫入點】（spec §2①）——
	#   寫在這裡而不是各呼叫端，是因為「緩衝不是來源」：emit 一次，同時進匯流排與玩家佇列。
	#   ★繞過 emit 直接寫佇列 ＝ 第二本帳 ⇒ P3 用 grep 斷言只有這一處。
	_feed_player(state, kind, subjects, info)
	if Probe.enabled:
		Probe.bump("t0.emit")
		Probe.bump("t0.emit." + kind)
		# ★★★DIAG（2026-09-22）：只多【一個維度】——這個 emit 落在 pass tick 還是非 pass tick。
		#   ★`t0.emit.<kind>` 這顆早就在數了 ⇒ 不另造第二套計數,只補這一維
		#   （★★造東西前先看誰已經在做這件事；第二套從出生就開始漂）。
		Probe.bump("t0.emit.%s.%s" % [kind,
			("pass" if state.world.current_tick % SimRunner.NEAR_CADENCE == 0 else "nonpass")])
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

# ★★★思考路徑專用（票 §10.1）：形狀逐字鏡射 `pending_source`／`is_pending`，
#   ★只換讀哪一個集合 —— **不發明第二種寫法**（同檔 `reaction_system.gd:57` 的理由）。
#   ★★`pending_visit`／`pending_seen` 仍記在共用那一份：它們量的是「這一隊被走訪／被讀」，
#     而那與「它進的是哪一個集合」無關。
static func pending_think_source(state: WorldState, team_id: int) -> String:
	if Probe.enabled: state.pending_visit[team_id] = state.world.current_tick
	if state.pending_think.has(team_id):
		if Probe.enabled: state.pending_seen[team_id] = state.world.current_tick
		return "cur"
	return ""

static func is_pending_think(state: WorldState, team_id: int) -> bool:
	return pending_think_source(state, team_id) != ""

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
	# ★★★新集合必須在【同一點】清空（票 §10.2①）——而且要清在【早退之前】：
	#   ★下面那個 `is_empty()` 早退會跳過函式尾端的 clear ⇒ 若只在尾端清，早退路徑會殘留。
	#   ★★目前 `pending_think ⊆ pending_rethink` ⇒ 早退時它【應該】也是空的，
	#   ★★★但那是一條沒有人在檢查的不變量 ⇒ 不靠它，無條件清。
	state.pending_think.clear()
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

# ══════════ 玩家可見事件佇列（spec 2026-09-25）══════════

# ★★★過濾器：【預設不給】，例外是白名單、逐條具名（blueprint 釘的 WHAT）。
#   ★白名單第①條：**自家隊 self-knowledge** —— 而它不是本票發明的例外，
#     `belief_system.gd:123` 的檔頭就寫著通道分流：同-faction 自家人走
#     `faction.known_member_states`（自帶 last_tick、不經 BeliefSystem），跨-faction 才走 belief。
#     ⇒ ★★所以「自家隊全知」是【既有的通道事實】，不是為玩家開的後門。
#   ★白名單第②條：**情報到了／看得見** ⇒ 走 `BeliefSystem.has_belief()`
#     ——【NPC 決定 belief 用的那同一支函式】，★不另寫一條「玩家看得到什麼」的規則。
#     而「看得見」不需要另一支函式：`VisionSystem.tick_discovery()` 偵測到就
#     `_write_tier01()` 寫 belief ⇒ **看得見是 has_belief 的上游**，它已經被涵蓋。
#
# ★★★而我要把一個【誠實限】寫在這裡，因為它是真的、而且我沒有權限自己收緊：
#   `has_belief()` 回答的是「我對那支隊【有沒有任何 claim】」，
#   ★不是「我知不知道【這件事】發生了」⇒ 一筆 30 天前的舊情報，會讓玩家【即時】
#   看到那支隊今天的領袖死訊。⇒ 那是 god-view 從一扇 belief 形狀的門漏出來。
#   ★★真正對齊的判準需要 staleness gate（`belief_pos` 用的那一個）或
#     per-event 的感知，而兩者都是【設計決定】不是實作細節 ⇒ 已呈報 systems。
static func _player_perceives(state: WorldState, subjects: Array) -> bool:
	var ptid: int = state.get_player_team_id()
	if ptid == -1:
		return false   # ★沒有玩家 ⇒ 不給（預設不給，而不是「給全部」）
	var pteam: TeamData = state.teams.get(ptid)
	var pfid: int = int(pteam.faction_id) if pteam != null else -1
	for tid in subjects:
		var id: int = int(tid)
		if id == ptid:
			return true   # ①自家隊 self-knowledge
		# ②同-faction 自家人：★走的是 `belief_system.gd:123` 檔頭寫的【那條既有通道】
		#   （同-faction 自家人 → `faction.known_member_states`，自帶 last_tick、不經 BeliefSystem）
		#   ⇒ ★「自家全知」站在 code 上，不是站在 spec 上。
		var t2: TeamData = state.teams.get(id)
		if t2 != null and pfid != -1 and int(t2.faction_id) == pfid:
			return true
	# ★★★③他隊：【先不放行】（systems 裁 2026-09-24）。
	#   ★原本這裡是 `BeliefSystem.has_belief()` —— 而它是 belief【形狀】的、不是 belief【粒度】的：
	#     它回答「我對那支隊有沒有任何 claim」，★不是「我知不知道【這件事】發生了」
	#     ⇒ 一筆 30 天前的舊情報，會讓玩家【即時】看到那支隊今天的領袖死訊。
	#   ★★牆漏了就不再是例外，是 god-view —— 而漏的形狀正好是最難發現的那種：
	#     它【有 belief 撐著】，所以看起來合法。
	#   ★★★解除條件：有了 staleness gate（`belief_pos` 用的那個）或 per-event 感知之後再放行。
	return false

# 寫入佇列。★只由 `emit()` 呼叫 —— 它是那個唯一寫入點的實作，不是第二個入口。
static func _feed_player(state: WorldState, kind: String, subjects: Array, info: Dictionary = {}) -> void:
	if state == null:
		return
	if not _player_perceives(state, subjects):
		return
	# ★情報折疊（藍圖回饋 #6 ①）：同一 tick、同一來源（同一個給情報的隊、同是親見或轉述）的自家情報折成一條
	#   ★只折帶內容的那幾則（＝自家隊；受眾規則在 belief_system 那端）；折進去的不另發 seq（同一件事）
	if kind == "intel_arrived" and info.has("tgt") and _fold_intel(state, subjects, info):
		return
	if kind == "intel_arrived" and info.has("tgt"):
		info = info.duplicate()
		info["items"] = [{"tgt": info["tgt"], "pos": info["pos"], "age": info.get("age", -1)}]
	state.player_event_seq += 1
	state.player_events.append({
		"tick": state.world.current_tick, "seq": state.player_event_seq,
		"kind": kind, "subjects": subjects.duplicate(),
		"info": info.duplicate(), "text": describe(state, kind, subjects, info)})

# kind → 人話。★放在本檔＝跟 `MESSAGE_KINDS`／`FUNC_KINDS` 那兩張清單【同一個地方】
#   ⇒ 新增一個 kind 的人，會在同一個檔裡看到「它還要有一句人話」。
static func describe(state: WorldState, kind: String, subjects: Array, info: Dictionary = {}) -> String:
	var who: String = _team_name(state, subjects[0] if not subjects.is_empty() else -1)
	match kind:
		"member_left":
			# ★★★原因是【必印】不是可選：spec P6 —— 一個沒有原因的「有人離隊了」
			#   會讓玩家去猜，而猜出來的因果比沒有因果更糟。
			return "%s：%s 離隊了（%s）" % [who, String(info.get("name", "有人")),
				String(info.get("reason", "原因不明"))]
		"member_died":
			return "%s：%s 死了（%s）" % [who, String(info.get("name", "有人")),
				String(info.get("cause", "死因不明"))]
		"came_of_age":
			return "%s：%d 名未成年長大成人" % [who, int(info.get("n", 0))]
		"member_joined":
			return "%s：招到 %d 人" % [who, int(info.get("n", 0))]
		# ── 強制事件三點。★★★片語一律呼 `PlayerApiMapper.action_phrase`：
		#   面板與事件流【同一張表】，否則兩邊各自漂＝本票要修的那個病自己復發。
		"forced_event_arrived":
			var fw_a: String = _forced_what(info)
			var fid_a: int = int(info.get("from_id", -1))
			return fw_a if fid_a == -1 else "Team%d 找上門：%s" % [fid_a, fw_a]
		"forced_event_resolved":
			# ★結果那一段用 handler 自己回的 `msg`（零第二份真相；同 09-28 結果句那張票的原則）
			var fid_r: int = int(info.get("from_id", -1))
			var subj_r: String = "「%s」" % _forced_what(info)
			if fid_r != -1:
				subj_r = "Team%d 的「%s」" % [fid_r, _forced_what(info)]
			return "你對%s回應了「%s」：%s" % [subj_r,
				String(info.get("response_label", info.get("response", "?"))),
				String(info.get("msg", ""))]
		"forced_event_timeout":
			var fid_t: int = int(info.get("from_id", -1))
			var subj_t: String = "「%s」" % _forced_what(info)
			if fid_t != -1:
				subj_t = "Team%d 的「%s」" % [fid_t, _forced_what(info)]
			return "你沒有回應%s⇒ 視同拒絕" % subj_t
		"leader_death":          return "%s 的領袖死了" % who
		"team_extinct":          return "%s 全滅了" % who
		"teams_erased":          return "%s 沒了" % who
		"combat_engaged":        return "%s 捲進了戰鬥" % who
		# ★N 讀常數（寬限期內不致死；resource_system 過了寬限才開始餓死人）——不抄數字
		"famine_crossed":        return "%s：存糧吃完，開始挨餓（再 %d 天開始有人餓死）" % [who, ResourceSystem.FAMINE_GRACE_DAYS]
		"betrayed":              return "%s 被盟友背叛" % who
		"outpost_owner_changed": return _owner_change_sentence(state, info)
		"player_subteam":        return _player_subteam_sentence(state, info)
		"resident_changed_faction":
			var rp: Vector2i = info.get("pos", Vector2i(-1, -1))
			var tf: int = int(info.get("to_faction", -1))
			return "你據點 (%d,%d) 的居民 %s 改投%s" % [rp.x, rp.y, _team_name(state, int(info.get("resident", -1))),
				("勢力%d" % tf) if tf != -1 else "自立（離開勢力）"]
		"intel_arrived":         return _intel_sentence(state, who, info)
		"combat_end":
			if info.has("aftermath"):
				return combat_end_sentence(state, info["aftermath"])
		"captive_overguard":     return "%s：看守不足：俘虜 %d 人、可看守 %d 人" % [who, int(info.get("captives", 0)), int(info.get("cap", 0))]
		"captive_unfed":         return "%s：養不起，俘虜被放走 %d 人" % [who, int(info.get("n", 0))]
		"aftermath_settled":     return String(info.get("text", ""))
		"extortion":
			if info.has("aggressor"):
				var got: String = String(info.get("got", ""))
				return "%s 勒索 %s：%s" % [_team_name(state, int(info["aggressor"])), _team_name(state, int(info.get("target", -1))),
					("拿到 " + got) if got != "" else "對方已無可取"]
			return "%s：勒索" % who
		"convoy_stranded":       return "%s 的運輸隊回不去，轉為自立" % who
		"construction_stalled":  return "%s 的工地停擺" % who
		"construction_abandoned":return "%s 放棄了工地" % who
		"plan_invalidated":      return "%s 的計畫行不通了" % who
		"rung_changed":          return "%s 的野心變了" % who
		"hostile_adjacent":      return "%s 逼近到你旁邊（%d 格）" % [who, int(info.get("dist", 1))]
		# ★D1：沒有專屬句子的 kind（訊息型那一批）⇒ 「誰：短名」；短名也沒有 ⇒ ""（不把識別字當句子）
		_:
			var lb: String = kind_label(kind)
			return "%s：%s" % [who, lb] if lb != "" else ""

# ★`from_id` 可以是 -1（choose_heir 沒有對方）⇒ 三句各自有自己的框,不硬套同一個前綴。
#   ★★這一格是實測抓到的：第一版印出「Team-1 找上門」。
static func _forced_what(info: Dictionary) -> String:
	return PlayerApiMapper.action_phrase(String(info.get("action", "")),
		String(info.get("proposal", "")))

const OWNER_CHANGE_REASON: Dictionary = {"alliance": "結盟", "capture": "被攻下", "takeover": "接管",
	"construct": "建成", "abandon": "放棄", "demolish": "拆除", "relocate_abandon": "遷村棄守", "death_release": "原主覆滅"}

static func _owner_change_sentence(state: WorldState, info: Dictionary) -> String:
	var pos: Vector2i = info.get("pos", Vector2i(-1, -1))
	var why: String = String(OWNER_CHANGE_REASON.get(String(info.get("reason", "")), String(info.get("reason", ""))))
	var old: int = int(info.get("old", -1))
	var now: int = int(info.get("new", -1))
	var ptid: int = state.get_player_team_id()
	if now == ptid:
		return "你取得了 (%d,%d) 的據點（%s）" % [pos.x, pos.y, why]
	if old == ptid:
		return "你失去了 (%d,%d) 的據點：%s（%s）" % [pos.x, pos.y, ("歸 " + _team_name(state, now)) if now != -1 else "無主", why]
	return "(%d,%d) 的據點易主：%s → %s（%s）" % [pos.x, pos.y,
		_team_name(state, old) if old != -1 else "無主", _team_name(state, now) if now != -1 else "無主", why]

# 同 tick、同來源的上一則自家情報 ⇒ 把這一則併進去、重組句子；回 true＝已併
#   ★只看【最後一筆】（R²）：中間夾了別的事件就不併——保住「玩家事件佇列唯一寫入點」與事件順序；跨 tick 不併
static func _fold_intel(state: WorldState, subjects: Array, info: Dictionary) -> bool:
	if state.player_events.is_empty():
		return false
	var d: Dictionary = state.player_events[state.player_events.size() - 1]
	if int(d.get("tick", -1)) != state.world.current_tick:
		return false
	if String(d.get("kind", "")) != "intel_arrived" or d.get("subjects", []) != subjects:
		return false
	var di: Dictionary = d.get("info", {})
	if not di.has("items") or int(di.get("source_id", -2)) != int(info.get("source_id", -3)):
		return false
	if bool(di.get("firsthand", false)) != bool(info.get("firsthand", false)):
		return false
	(di["items"] as Array).append({"tgt": info["tgt"], "pos": info["pos"], "age": info.get("age", -1)})
	d["text"] = describe(state, "intel_arrived", subjects, di)
	return true

# ★情報句（改法 4＋回饋 #6）：info 只在自家隊那則才有（belief_system 那一端擋）⇒ 缺欄 ⇒ 舊句，不印空對象
#   親見「你看到 A 在 (q,r)、B 在 (q,r)」／轉述「你從 TeamX 得知：A 在 (q,r)（N 前的消息）、…」
#   ——轉述保留「得知」：claim 可能失真；★同 tick 同來源的多則已在 _feed_player 折成這一句
static func _intel_sentence(state: WorldState, who: String, info: Dictionary) -> String:
	if not info.has("tgt") or not info.has("pos"):
		return "%s 收到了情報" % who
	var items: Array = info.get("items", [{"tgt": info["tgt"], "pos": info["pos"], "age": info.get("age", -1)}])
	var firsthand: bool = bool(info.get("firsthand", false))
	var parts: Array = []
	for it in items:
		var pos: Vector2i = it["pos"]
		var p: String = "%s 在 (%d,%d)" % [_team_name(state, int(it["tgt"])), pos.x, pos.y]
		if not firsthand and int(it.get("age", -1)) >= 0:
			p += "（%s前的消息）" % _age_text(int(it["age"]))
		parts.append(p)
	if firsthand:
		return "你看到 " + "、".join(parts)
	return "你從 %s 得知：%s" % [_team_name(state, int(info.get("source_id", -1))), "、".join(parts)]

static func _age_text(ticks: int) -> String:
	var mins: int = ticks * PlayerApiMapper.MINUTES_PER_HOUR / WorldState.TICKS_PER_HOUR   # ★分鐘換算走具名常數（bare-tick 閘）
	if mins < PlayerApiMapper.MINUTES_PER_HOUR:
		return "%d 分鐘" % mins
	if ticks < WorldState.TICKS_PER_DAY:
		return "%d 小時" % (ticks / WorldState.TICKS_PER_HOUR)
	return "%d 天" % (ticks / WorldState.TICKS_PER_DAY)

# ★玩家遭遇戰結算句（spec 2026-10-14-battle-aftermath §1：單一產生者；encounter_system 不手寫字串；零英文識別字）
#   ★只寫玩家該知道的：敵方數字＝場上看到的（上場陣亡、上場受傷、記名戰死），不讀敵隊整體人口
static func combat_end_sentence(state: WorldState, am: Dictionary) -> String:
	var sides: Dictionary = am.get("sides", {})
	var me: int = -1
	var foe: int = -1
	for tid in sides:
		if bool(sides[tid].get("is_player", false)): me = int(tid)
	for tid in sides:
		if int(tid) != me: foe = int(tid)
	var parts: Array = []
	var stays: Dictionary = am.get("stays", {})
	var foe_name: String = String(am.get("names", {}).get(foe, "對手"))
	if bool(am.get("beast", false)):
		parts.append(("獵得%s" % foe_name) if bool(stays.get(me, false)) else ("被%s擊退" % foe_name))
	elif stays.is_empty() or (not bool(stays.get(me, false)) and not bool(stays.get(foe, false))):
		parts.append("雙方都倒下了，各自帶回傷兵")
	elif bool(stays.get(me, false)):
		parts.append("你守住了戰場")
	else:
		parts.append("你撤出了戰場，%s 留在場上" % foe_name)
	for pair in [[me, "你方"], [foe, "對方"]]:
		var sd: Dictionary = sides.get(pair[0], {})
		if sd.is_empty():
			continue
		var dead_named: Array = sd.get("dead_named", [])
		var dead: int = int(sd.get("dead_anon", 0)) + dead_named.size()
		var hurt: int = maxi(int(sd.get("wounded_mid", sd.get("wounded0", 0))) - int(sd.get("wounded0", 0)), 0)
		var line: String = "%s 死 %d 傷 %d" % [pair[1], dead, hurt]
		if not dead_named.is_empty():
			line += "（戰死：%s）" % "、".join(PackedStringArray(dead_named))
		parts.append(line)
	var mine: Dictionary = sides.get(me, {})
	var theirs: Dictionary = sides.get(foe, {})
	if int(theirs.get("held_by_enemy", 0)) > 0:
		parts.append("你押走 %d 人" % int(theirs["held_by_enemy"]))
	if int(mine.get("held_by_enemy", 0)) > 0:
		parts.append("你方被押走 %d 人" % int(mine["held_by_enemy"]))
	if bool(am.get("fate_pending", false)):
		parts.append("對方 %d 名傷兵倒在戰場上，等你處置" % int(am.get("disabled_enemy", 0)))
	if bool(am.get("pursuit_possible", false)):
		parts.append("對方有 %d 人逃散，可以追擊" % int(am.get("pursuit_e", 0)))
	if am.has("fate_choice") and int(am.get("victim", -1)) == me:
		var k: int = int(mine.get("fate_killed", 0))
		var c: int = int(mine.get("fate_captured", 0))
		var r: int = int(mine.get("fate_released", 0))
		var how: Array = []
		if k > 0: how.append("殺了 %d" % k)
		if c > 0: how.append("俘走 %d" % c)
		if r > 0: how.append("放了 %d" % r)
		parts.append("%s 處置你方傷兵：%s" % [foe_name, "、".join(PackedStringArray(how)) if not how.is_empty() else "沒有傷兵"])
		if c > 0 and r > 0:
			parts.append("看守不過來，放走 %d 人" % r)
	if int(mine.get("pursuit_killed", 0)) > 0:
		parts.append("撤退時被追擊，又死 %d 人" % int(mine["pursuit_killed"]))
	var loot: Dictionary = am.get("loot", {})
	if not loot.is_empty() and bool(stays.get(me, false)):
		var ls: Array = []
		for rk in loot:
			ls.append("%s %.0f" % [TextBank.res_name(String(rk)), float(loot[rk])])
		parts.append("戰利品可收：%s" % "、".join(PackedStringArray(ls)))
	for n in am.get("notes", []):
		parts.append(String(n))
	return "戰鬥結束：" + "｜".join(PackedStringArray(parts))

static func _team_name(state: WorldState, tid: int) -> String:
	if tid == -1 or not state.teams.has(tid):
		return "某支隊伍"
	# ★TeamData 沒有名字欄位（team_data.gd 只有 named_members）——
	#   ★★我原本寫 `t.get("team_name", "")`，而 TeamData 是 Object：它的 `get()` 只吃一個參數
	#   ⇒ 噴 151 次「Invalid call to function 'get'」而 headless 的 HARD-FAILS 仍是 3（＝基準值）
	#   ⇒ ★★★那正是「離開碼／彙總數字看起來正常，而 stderr 在尖叫」——
	#     抓到它的是 grep SCRIPT ERROR，不是 rc。
	return "Team%d" % tid
