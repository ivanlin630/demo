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
# ★★★`wake_thinking` 預設 **true**（票 §10.1）：
#   ⇒ **任何未來新增的 emit 都會自動維持瞬醒** ＝ 構造保證。
#   ★反過來設計（預設 false、需要的人自己打開）＝ 清單保證 ⇒ 漏改一處就【靜默失去瞬醒】。
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
		"leader_death":          return "%s 的領袖死了" % who
		"team_extinct":          return "%s 全滅了" % who
		"teams_erased":          return "%s 沒了" % who
		"combat_engaged":        return "%s 捲進了戰鬥" % who
		"betrayed":              return "%s 被盟友背叛" % who
		"intel_arrived":         return "%s 收到了情報" % who
		"convoy_stranded":       return "%s 的運輸隊回不去，轉為自立" % who
		"construction_stalled":  return "%s 的工地停擺" % who
		"construction_abandoned":return "%s 放棄了工地" % who
		"plan_invalidated":      return "%s 的計畫行不通了" % who
		"rung_changed":          return "%s 的野心變了" % who
		_:                       return "%s：%s" % [who, kind]

static func _team_name(state: WorldState, tid: int) -> String:
	if tid == -1 or not state.teams.has(tid):
		return "某支隊伍"
	# ★TeamData 沒有名字欄位（team_data.gd 只有 named_members）——
	#   ★★我原本寫 `t.get("team_name", "")`，而 TeamData 是 Object：它的 `get()` 只吃一個參數
	#   ⇒ 噴 151 次「Invalid call to function 'get'」而 headless 的 HARD-FAILS 仍是 3（＝基準值）
	#   ⇒ ★★★那正是「離開碼／彙總數字看起來正常，而 stderr 在尖叫」——
	#     抓到它的是 grep SCRIPT ERROR，不是 rc。
	return "Team%d" % tid
