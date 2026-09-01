class_name WorldState

# ── 時間基底 ──────────────────────────────────────────────────
# ★★★S2 根旋鈕（重錨 2026-08-27）：【唯一自由參數】從 TICKS_PER_DAY 改成 TICKS_PER_HOUR。
#   ★世界以【時間】思考，tick 是推導值 —— 要換 tick 粒度只改這一顆。
#   ★★初值 60 ⇒ 1 tick 恰好＝1 分鐘，而那是【推導結果】不是寫死的身分。
#   ★★★下限守衛：遭遇動作＝10 分鐘＝TICKS_PER_HOUR/6，而它必須 >= 10 tick
#     （速度差檔位的解析度地板）⇒ 本顆不得小於 60。assert 在 debug/time_const_check.gd。
# ★裸 tick 守衛 (c) 白名單：它【就是根】—— hours()/days() 由它導出，改成 hours() 會循環定義。
#   ★★而【它的值】由 debug/time_const_check.gd 的根值凍結哨兵看著：改了會紅，
#     紅了的處置是【確認有意並更新那一格】，不是拿掉守衛。
const TICKS_PER_HOUR:   int   = 60           # ★唯一自由參數（1 tick = 1 分鐘，推導值）
# ★S1b 白名單(c)：24 ＝【一天幾小時】的曆法結構，★不隨 tick 縮放 ——
#   根旋鈕改成別的值時，這個 24 必須【維持 24】，否則「小時」就不是小時了。
# TIER: n/a — 曆法基底（單位定義），不是節律
const TICKS_PER_DAY:    int   = TICKS_PER_HOUR * 24   # = 1440
# TIER: n/a — 曆法基底（單位定義），不是節律
const TICKS_PER_MONTH:  int   = TICKS_PER_DAY * 30   # = 43200 ticks
# TIER: n/a — 曆法基底（單位定義），不是節律
const TICKS_PER_SEASON: int   = TICKS_PER_DAY * 90   # = 129600 ticks
# TIER: n/a — 曆法基底（單位定義），不是節律
const TICKS_PER_YEAR:   int   = TICKS_PER_DAY * 360  # = 518400 ticks
const SECONDS_PER_TICK: float = 86400.0 / float(TICKS_PER_DAY)

var world: WorldData = WorldData.new()
var teams: Dictionary = {}
var persons: Dictionary = {}
var global_messages: Array = []
# ★資訊網 B carrier：飛行中的信件（求援 distress）——net-new、非 state.teams 成員
# → 免撞 succession/cull/subteam-routing/on_leader_death/combat 全 team 機具（B root 根治）。
# 每封 Dictionary：{origin_team_id, faction_id, target_lord_id, target_pos, kind, payload, current_pos, spawn_tick, timeout, speed}
var in_transit_letters: Array = []
# 觀測事件 channel（observer slice）：emit_ambient 專用 append-only。
# 獨立於 global_messages —— ★理由已更新（2026-08-20）：order_id 改走 next_order_id 專用
# 計數器後，append 不再位移 oid 流；保持分離的現行理由＝global_messages 無界成長 +
# observer channel 純度（此 channel sim 零讀、僅 observer UI 消費）。
var observer_messages: Array = []
var team_known: Dictionary = {}
# ★★★market-known 快取的失效鍵之一（spec 2026-08-27 gather-dirty-flag-cache）：
#   ★世界上任何一格 outpost_level 變動就 +1 —— ★★只在【世界 tile】的寫入點 bump（6 處，窮盡見 handback）。
#   ★★★為什麼是全域計數器而不是逐 tile 版本：快取要問的是「我 vision 範圍內有沒有變」，
#     而逐 tile 比對＝重掃 vision＝正是要省掉的那筆開銷（R² 已分析，換機制迴避不了窮盡工作量）。
#   ★保守面：任何一格變動都會讓【所有隊】失效一次 ⇒ 命中率偏低，★但絕不 stale。
#     ★★這個方向是刻意選的：漏失效＝NPC 拿過期世界做決策，而它【沒有症狀】。
var outpost_epoch: int = 0
# ★market-known 快取的鍵（team_id → [tile_pos, outpost_epoch, team_known.size()]）。
#   ★★純觀測不了的東西：它是【快取狀態】不是世界事實 ⇒ 存檔／重播時可安全丟棄（重算一次即可）。
var team_market_known_key: Dictionary = {}
var team_discovered: Dictionary = {}   # int team_id → Array[int] 已知 team_id 清單
# god-view Slice C：market-discovery belief store（team_id → Dictionary{tile_id:int→true} 已知市集 outpost tile）。
# 三源習得：創世-nearby(game_setup) / 直接親見(vision 半徑內 outpost) / relay harvest(team_known order/outpost_built 訊息)。
# 貿易目標選擇（_nearest_market_outpost）只掃此=belief-gate（非全圖 god-view）。demolish(outpost_level→0)清此 tile 全隊條目。
var team_market_known: Dictionary = {}
# ★means-end S3 定位型 belief store（鏡射 team_market_known）：{ team_id: { tile_id: true } } 已發現 tile。
# tile-discovery 兩源（親見 vision 半徑 bounded scan + relay team_known tile 訊息）。所有權/control 型 tile 查詢讀此
# =belief-gate（禁全圖 god-view；純地形查詢另走 find_nearest_terrain_tile # gate-ok 公共地理）。
var team_tile_known: Dictionary = {}
var team_intel: Dictionary = {}
# { obs_id: int → { tgt_id: int → {
#   "tier":           int,       # 最高接觸層級：0/1/2
#   "population_est": int,       # 帶距離雜訊
#   "tile_pos":       Vector2i,
#   "last_tick":      int,
#   # tier ≥ 1: "resource_scale": int,   # 0缺乏/1勉強/2充裕/3豐盛（帶±1雜訊）
#   # tier 2: "faction_id", "tags", "current_task",
#   #          "food_est", "material_est", "coin_est", "goods_est", "armed_est"
# }}}
var factions: Dictionary = {}
var teams_pending_erase: Array = []   # 滅團延遲清除：tick 末單點 erase（中途 erase 不安全）
var offmap_extinct_coin: float = 0.0  # off-map 滅團（radius 全無有效格）coin 顯性 sink；CoinAudit 全池計 → 守恆閉合非靜默丟失
# P0 加固：tile→teams 共用空間索引（sim_runner 每次移動後 rebuild，O(N) 一次）。
# 消費端（hostile-within / co-location / 居民查）以鄰域查取代全掃 → 收 O(N²)/hr。
# 純加速結構、非真值源：消費端仍 live 復驗 tile_pos/hex_dist（容 key 碰撞 + 建後瞬時態）。
var teams_by_tile: Dictionary = {}   # tile_id(int = x*1000+y) → Array[int] team_ids

# ★效能 arc B：owner → 自家據點 tile_id 索引（取代 _find_own_outpost / _faction_roster_pos 的全圖掃）。
# 純加速結構、非真值源：表由 world.tiles **迭代序**整表重建、每 owner 只留第一個命中
# ＝完全重現舊掃「迭代序中的第一個符合者」語意（HOW spec §3）。失效走 OwnerOutpostIndex.epoch。
var _oo_map: Dictionary = {}      # team_id → tile_id（owner=-1 亦入表，與舊掃對任何輸入皆等價）
var _oo_epoch: int = 0            # 0 = 尚未建（OwnerOutpostIndex.epoch 從 1 起）
var _next_faction_id: int = 0
# beast pseudo-team id counter（負區段，避開正常 team id）。★per-world（非 BeastSystem instance var，
# 亦禁 static var）：每 world fresh init → per-seed 決定性 + 每 beast 唯一遞減 id。舊 instance var 令每
# BeastSystem.new() 重置 -1000000 → 全 beast 撞同 id → create_team 靜默覆寫（beast id 碰撞 bug）。
# ★team id 單一分配器（slice monotonic-team-id 2026-08-21）：★永不重用。
# 修前全站有 7 份獨立的 `_next_team_id`＝`max(現存 id)+1` ⇒ 最高 id 的隊一死，下一個子隊就撿回同一號碼
# ⇒ specimen／量測床／QA 都拿 team_id 當身分 ⇒ 兩條命被縫成一條假故事（實測 team12：命1 2400→4600、
#   空白 4600–7300、命2 7300 起，max_gap 2740 與空白完全吻合）。
# ★收斂成【一個動作】而非「七處各讀同一計數器」——後者只是把「重用 id」換成「七個物理上分開的計數概念」。
var next_team_id: int = 0
# ★person id 單一分配器（slice monotonic-person-id 2026-08-21，形狀照抄 team-id 那刀）。
# ★傷害面比 team 那次更隱蔽：`p.relations`（person_data:62）與 `p.relation_edges`（:63）**都以 person id 當鍵**
#   ⇒ 新人撿到舊 id 會平白繼承一段跟自己毫無關係的恩怨情仇，而且【不報錯、聚合數字也不反常】
#   （team 重用至少會在 specimen／床這種有人在看的地方露破綻）。
var next_person_id: int = 0

var next_beast_id: int = -1000000
var player_id: int = -1
var specimen_team_ids: Array[int] = []   # 指標團：LOD-exempt + SpecimenTracer 詳捕決策（觀測 only，debug/seed 設）
# ★訂單簿 tap：order_id 全域遞增計數器（★存 state 非 static var——static 跨 new() 會 id 碰撞、
# 見 known_issues beast id 前科）。只增不減；存檔即帶走。
var next_order_id: int = 1
# ★T0-A1 事件匯流排：本 tick 被事件喚醒、可立即重新思考的隊（team_id → true）。
# ★不入 state_fingerprint：因為它【單 tick 內清空】（tick 結尾 WorldEvents.consume_and_clear），
#   不跨 tick 存活＝非持久狀態。分批消費會讓這個正當性失效。
var pending_rethink: Dictionary = {}
# ★★★純觀測（Probe-gated 才寫）：這面旗子【有沒有人讀過】。
#   ★動機：「窗內有沒有被走訪」這個問法會被 tick 內順序污染（走訪在 emit 之前 vs 之後
#     長得一樣）——★★我已經在 pass_done 那顆上踩過同一個病一次。
#   ★★★換成問【旗子死掉時有沒有人讀過它】：那是需求①「不得消失」的字面量，
#     而且它與順序無關 —— 讀過就是讀過。
#   ★不入 fingerprint：它是觀測欄，production 決策不讀它。
var pending_seen: Dictionary = {}
# ★★★純觀測：這一隊【最後一次被任何消費者查看】的 tick。
#   ★用途：把「旗子死了」拆成 systems 要的兩件——
#     ①a 因【順序】而丟（消費者在窗內查過它，只是那時還沒 emit）⇒ ★雙緩衝的責任，必須歸零
#     ①b 因【走訪間隔】而丟（消費者在窗內根本沒查它）⇒ ★★雙緩衝修不掉，照實報
#   ★★記在【逐 actor 的檢查點】上（pending_source / pending_source_faction 真的碰到這一隊時），
#     ★★★不是逐支逐 tick 的粗標記 —— 那顆分不出「這一隊」有沒有被碰到，只能當上界。
var pending_visit: Dictionary = {}
var player_state: Dictionary = {}
var player_hostile_teams: Array = []   # Array[int] team_ids that attacked player
var player_pending_targets: Array = []
# Array[int] — 同格、無敵意 NPC team_ids，等玩家選擇互動類型或忽略
# 玩家 team 移動到新格子時清除；玩家執行任意行動後對應 id 移除

var player_forced_event: Dictionary = {}
# NPC 強制非戰互動，格式：
# { "from_id": int, "action": String, ... }
# action = "diplomacy" → { ..., "proposal": String }  非阻塞，下一 TICKS_PER_HOUR 未回應自動拒絕
# action = "extort"    → { ..., "from_id": int }       非阻塞，下一 TICKS_PER_HOUR 未回應自動拒絕
# 空 Dict = 無待處理強制事件
var player_forced_event_id: String = ""
# 對應 player_forced_event 的唯一 ID（str(randi()) 生成）
# 空字串 = 無待處理強制事件
var player_pending_orders: Dictionary = {}
# 格式：{ member_team_id(String) → { "task": String, "herald_id": int } }
# 信使出發後寫入；信使抵達同格後 interaction_system 清除並設 player_commanded_task
var player_pre_encounter: Dictionary = {}
# NPC 主動攻擊玩家，等待玩家選擇迎擊或投降後才真正開始遭遇戰
# 格式：{ "attacker_id": int, "defender_id": int }
# 空 Dict = 無待處理預備遭遇戰
var player_alerts: Array = []
# Array[Dictionary]，格式：{ "type": String, "tick": int, "data": Dictionary }
# 類型：food_critical / member_defected / faction_member_betrayed /
#       subteam_destroyed / outpost_captured
# UI 輪詢後清空（同 forced_event 模式）
var game_over: bool = false
var game_over_reason: String = ""
# H: 玩家絕後 → game_over=true，sim_runner 凍結世界

var ticks_per_day: int:
	get: return TICKS_PER_DAY

# ── Pattern B driver-ledger（第3不變量：凡 state 變化必有可解釋 driver）──────
# 5 bank 的 reason 參數 → record_driver 真記（現丟棄）。預設 off（enabled=false）→
# record no-op、僅一次 bool 檢查＝正常 run 零成本。debug / audit / 強制閘時開。
# ring-buffer（cap）→ 開時亦 bounded，避無界成長（連 scaling）。
static var driver_ledger: Array = []          # Array[Dictionary] {tick,entity,field,delta,reason}
static var driver_ledger_enabled: bool = false
static var driver_ledger_cap: int = 4096      # TEST VALUE
static var driver_tick_hint: int = 0          # sim_runner 開 ledger 時填當前 tick；off 不動

# ★`kind` 由【呼叫端的身分】填，不由字面推（systems 裁 2026-08-25）：
#   `field` 是混雜欄——`tags`/`readiness`/`solo_intent`/`loyalty`/`coin` 跟真資源名同欄。
#   直接掃 `field` 會把 `tags` 當成資源（同 constitution_gate fingerprint 踩過的混雜命中）。
#   ★用【出處】分類不用【字面】分類 —— 字面會碰撞，出處不會。
#   `resource_bank`/`tile_bank` 的 `res` 參數天生就是資源 ⇒ 由它們填 `"resource"`。
# ★`kind` 【必填、無 default】：default 存在的唯一效果是讓【下一個忘記填的人】靜默通過。
#   實證：bank 的 `reason: String = ""` 有 default，而 208/208 個呼叫點全都有傳
#   ⇒ 那個 default 從來沒被用過，它只能防到未來的錯誤——而「防到」的方式是讓它靜默。
static func record_driver(entity, field: String, delta: float, reason: String, kind: String) -> void:
	if not driver_ledger_enabled:
		return
	driver_ledger.append({
		"tick":   driver_tick_hint,
		"entity": entity,
		"field":  field,
		"delta":  delta,
		"reason": reason,
		"kind":   kind,
	})
	while driver_ledger.size() > driver_ledger_cap:
		driver_ledger.pop_front()

static func clear_driver_ledger() -> void:
	driver_ledger.clear()

# ★效能 arc B：owner → 自家據點查表（等價替換 `for tile_id in world.tiles` 全圖掃）。
# 回傳該 team 在 world.tiles 迭代序中的第一個 outpost_level>0 據點 tile，無則 null。
# 失效即整表重建（見 OwnerOutpostIndex 檔頭：整表重建天然免疫 spec §3 的「後設蓋前者」陷阱）。
func own_outpost_tile(team_id: int) -> HexTileData:
	if _oo_epoch != OwnerOutpostIndex.epoch:
		_rebuild_owner_outpost()
	var tid = _oo_map.get(team_id, null)
	if tid == null:
		return null
	return world.tiles.get(tid)

func _rebuild_owner_outpost() -> void:
	_oo_map.clear()
	for tile_id in world.tiles:   # ★依 world.tiles 迭代序 → 每 owner 只留第一個命中＝舊掃同一選擇
		var t: HexTileData = world.tiles[tile_id]
		if t.outpost_level > 0 and not _oo_map.has(t.outpost_owner):
			_oo_map[t.outpost_owner] = tile_id
	_oo_epoch = OwnerOutpostIndex.epoch
	if Probe.enabled: Probe.bump("owner_outpost.rebuild")

# ★唯一出生口：配一個新 team id（單調遞增、永不重用）。
# 防禦性 floor：若 state 裡已存在 >= 計數器的 id（例如未來的存檔載入忘了同步），
# 這裡把計數器抬過去並【留下 tap】——寧可看得見地自我修復，也不要靜默撞號。
# ★唯一出生口（person）：單調遞增、永不重用。floor 同 team 版：state 裡已有 >= 計數器的 id 就抬過去 + 留 tap。
func consume_next_person_id() -> int:
	for pid in persons:
		if int(pid) >= next_person_id and int(pid) >= 0:
			next_person_id = int(pid) + 1
			if Probe.enabled: Probe.bump("personid.floor_bump")
	var id: int = next_person_id
	next_person_id += 1
	return id

func consume_next_team_id() -> int:
	for tid in teams:
		if int(tid) >= next_team_id and int(tid) >= 0:
			next_team_id = int(tid) + 1
			if Probe.enabled: Probe.bump("teamid.floor_bump")
	var id: int = next_team_id
	next_team_id += 1
	return id

func create_faction(leader_team_id: int) -> int:
	if not teams.has(leader_team_id):
		push_warning("[create_faction] leader_team_id=%d 不存在於 state.teams，跳過" % leader_team_id)
		return -1
	var f = load("res://scripts/data/faction_data.gd").new()
	f.faction_id = _next_faction_id
	f.leader_team_id = leader_team_id
	f.member_team_ids = []   # 由 set_team_faction bidir-safe 補入 leader（退舊籍後）
	factions[f.faction_id] = f
	_next_faction_id += 1
	# bidir-safe：若 leader 原屬他 faction（成員/獨立隊建國），先退舊 member_team_ids
	# 再入新——否則舊 faction 陣列殘留懸空 id，該隊日後 erase 時 faction_id-gated
	# cleanup 只清新 faction，舊 faction 懸空 → _assign_member_tasks require_team crash。
	set_team_faction(teams[leader_team_id], f.faction_id)
	return f.faction_id

# ★繼承-lite（用戶 2026-08-15 裁簡易版；爭位/內戰＝王朝 arc 界外）：勢力領袖團死 → 最強成員接位，
# 沒人接才解散（原行為）。單一 owner：三處領袖團死路徑全走這裡。
# 最強＝統領（該隊 leader skills["統領"]、無 leader 視 0）降序 → 平手 population 大 → 再平手 team_id 小
#（全序＝determinism）。零 RNG、零新結構。
# ★also_dead＝本 tick 已判死但尚未真 erase 的隊（erase_teams 批次期間 state.teams 仍持有全部 dead_list；
#   領袖隊若排在前面處理，同批死亡的隊友此刻仍 teams.has()==true → 會選出「這 tick 稍後就被清掉的
#   死人繼任者」）。呼叫點傳自己的 dead 集合 / 既有 teams_pending_erase。
# bookkeeping：known_member_states 由各呼叫點自己的既有清理負責（本函式不碰，見下方訂正註）。
func succeed_or_disband_faction(faction_id: int, dead_leader_tid: int, also_dead: Dictionary = {}) -> void:
	if not factions.has(faction_id):
		return
	var f = factions[faction_id]
	# ★merge-gate 訂正（A）：不在此 erase known_member_states[死者]——三處語境都不該由本函式做：
	#   erase_teams 前一行已 erase（冗餘）／faction_ai 那條稍後走 cleanup→erase_teams 也會 erase（冗餘）／
	#   ★npc_combat 那條【團還活著】（只是 named leader 死、on_leader_death 回 false），抹掉一支仍在世
	#   成員隊的 faction belief 記錄＝未經 spec 的 belief 破壞、可能改 faction 決策。
	var best: int = -1
	var best_cmd: float = -1.0
	var best_pop: int = -1
	for cid in f.member_team_ids:
		if cid == dead_leader_tid or also_dead.has(cid) or not teams.has(cid):
			continue
		var cand: TeamData = teams[cid]
		var ldr: PersonData = persons.get(cand.leader_id)
		var cmd: float = float(ldr.skills.get("統領", 0.0)) if ldr != null else 0.0
		var pop: int = cand.population
		if cmd > best_cmd 				or (cmd == best_cmd and pop > best_pop) 				or (cmd == best_cmd and pop == best_pop and (best == -1 or cid < best)):
			best = cid; best_cmd = cmd; best_pop = pop
	if best == -1:
		if Probe.enabled: Probe.bump("faction.disband_no_heir")
		disband_faction(faction_id)
		return
	f.leader_team_id = best
	if Probe.enabled: Probe.bump("faction.succession")
	print("[Succession] 勢力%d 領袖團 %d 死 → %d 接位" % [faction_id, dead_leader_tid, best])

func disband_faction(faction_id: int) -> void:
	if not factions.has(faction_id):
		return
	var f = factions[faction_id]
	# ★★★A#27 routing（systems 裁 2026-09-02，★否決「加第二個 tap」）：
	#   ★病是【單寫者其實不單一】——這裡原本直寫 `teams[tid].faction_id = -1`，繞過 set_team_faction
	#   ⇒ 加第二個 tap ＝ 把病留著，並把「記得同時維護兩處」的責任交給未來的人（而他不會知道）
	#   ⇒ ★★正解是把寫者收回一個。
	# ★★★而 `.duplicate()` 是必要的，不是保險：set_team_faction 會
	#   `factions[old].member_team_ids.erase(team_id)` ⇒ 直接迭代原陣列＝【邊走邊刪】會跳過元素。
	for tid in f.member_team_ids.duplicate():
		if teams.has(tid):
			set_team_faction(teams[tid], -1, LEAVE_FACTION_DISSOLVED)
	factions.erase(faction_id)
	print("[Faction] 勢力%d 解散" % faction_id)

# ★★★A#27 離團理由的【一處定義常數集】（systems 2026-09-02 裁，這是授權的條件）：
#   ★不准九個呼叫站各寫字串字面值 —— ★★打錯一個字 ⇒ 多一個桶、總數照樣對得起來，
#   ★★★而那個桶【永遠是 0】⇒ 看起來就像「這個出口沒發生」。那正是本票要修的病的完全同形。
const LEAVE_UNSET: String = "unset"                       # ★呼叫端沒標 ⇒ 這個桶非 0 就是有人漏標
const LEAVE_UPRISING_INDEPENDENT: String = "uprising_independent"   # 起義自立脫離
const LEAVE_UPRISING_EXILE: String = "uprising_exile"               # 起義流亡脫離
const LEAVE_DEFECT_SURRENDER_FAIL: String = "defect_surrender_fail" # defection path B：投靠強鄰失敗 → clear
const LEAVE_DEFECT_INDEPENDENT: String = "defect_independent"       # defection path C：獨立
const LEAVE_DEFECT_EVENT: String = "defect_event"                   # event_faction_defect 正常脫離
const LEAVE_DEFECT_FACTION_MISSING: String = "defect_faction_missing" # event_faction_defect：faction 已不存在的防禦路徑
const LEAVE_BETRAYAL: String = "betrayal"                           # 外交背叛離團
const LEAVE_PLAYER: String = "player_leave"                         # 玩家主動離團
const LEAVE_PLAYER_BETRAY: String = "player_betray"                 # 玩家背叛離團
const LEAVE_FACTION_DISSOLVED: String = "faction_dissolved"         # ★勢力解散（原本直寫，A#27 導回窄口）
const LEAVE_REASONS: Array = [
	LEAVE_UNSET, LEAVE_UPRISING_INDEPENDENT, LEAVE_UPRISING_EXILE,
	LEAVE_DEFECT_SURRENDER_FAIL, LEAVE_DEFECT_INDEPENDENT, LEAVE_DEFECT_EVENT,
	LEAVE_DEFECT_FACTION_MISSING, LEAVE_BETRAYAL, LEAVE_PLAYER, LEAVE_PLAYER_BETRAY,
	LEAVE_FACTION_DISSOLVED,
]

# 雙向單一入口：team.faction_id ↔ faction.member_team_ids 一處同維護（規則3）。
# 換 faction 自動退舊團、入新團；idempotent。
# ★★A#27 tap：掛在【早退之後】—— 早退擋掉 6 顆 `set_team_faction(t, -1)` 的 fresh-team no-op
#   ⇒ ★不會把「本來就沒 faction」記成一次離團。
#   ★★分母與被數的東西在【同一個地方】產生：join / leave 同一個窄口分流。
func set_team_faction(team: TeamData, fid: int, reason: String = LEAVE_UNSET) -> void:
	if team.faction_id == fid:
		return
	if Probe.enabled:
		Probe.bump("faction.change_total")
		if fid == -1:
			Probe.bump("faction.leave_total")
			# ★不在常數集裡 ⇒ 有人打錯字或新增了沒登記的理由。★★這個桶【必須恆 0】。
			Probe.bump("faction.leave." + (reason if reason in LEAVE_REASONS else "unknown_reason"))
		else:
			Probe.bump("faction.join")
	if team.faction_id != -1 and factions.has(team.faction_id):
		factions[team.faction_id].member_team_ids.erase(team.team_id)
	team.faction_id = fid
	if fid != -1 and factions.has(fid):
		if not factions[fid].member_team_ids.has(team.team_id):
			factions[fid].member_team_ids.append(team.team_id)

func clear_team_faction(team: TeamData, reason: String = LEAVE_UNSET) -> void:
	set_team_faction(team, -1, reason)

# 雙向單一入口：child.parent_team_id ↔ parent.subteam_ids 一處同維護（規則3）。
# 換 parent 自動退舊母、入新母；idempotent。
func set_subteam_parent(child: TeamData, parent_id: int) -> void:
	if child.parent_team_id == parent_id:
		return
	if child.parent_team_id != -1 and teams.has(child.parent_team_id):
		teams[child.parent_team_id].subteam_ids.erase(child.team_id)
	child.parent_team_id = parent_id
	if parent_id != -1 and teams.has(parent_id):
		if not teams[parent_id].subteam_ids.has(child.team_id):
			teams[parent_id].subteam_ids.append(child.team_id)

func detach_subteam(child: TeamData) -> void:
	set_subteam_parent(child, -1)

# combat_target 單寫者 chokepoint（F-S4）：戰鬥中 flag（戰鬥起設、結束清）。
# 所有 team.combat_target= 直寫改走此/clear_combat_target；erase_team 續清懸空（B 類單欄 target 瞬時態容忍）。
# 語意純戰鬥；社交（投靠/乞食）走 set_social_target。mirror set_leader/set_team_faction。
func set_combat_target(team: TeamData, tid: int) -> void:
	team.combat_target = tid

func clear_combat_target(team: TeamData) -> void:
	team.combat_target = -1

# social_target 單寫者 chokepoint：社交互動目標（投靠/乞食），語意 ≠ combat_target。
# BEG/JOIN dispatch 設此；interaction resolver 讀此；erase_team 續清懸空。mirror set_combat_target。
func set_social_target(team: TeamData, tid: int) -> void:
	team.social_target = tid

func clear_social_target(team: TeamData) -> void:
	team.social_target = -1

# 雙向單一入口：team.named_members ↔ person.team_id 一處同維護（規則2 roster 版）。
# add=入隊（append if absent + team_id 回指）；remove=離隊（erase[+清 team_id]）。
# 類比 set_team_faction。idempotent。以 pid 收參（多數 site 只持 id；person 缺席容忍）。
# clear_team_id=false：離開 named 但仍屬本隊 →「晉升 leader」/「死亡留屍不改籍」
#   （health famine 蓄意保 team_id 供 get_player_team_id）→ 不清 team_id。
func add_member(team: TeamData, pid: int) -> void:
	if not team.named_members.has(pid):
		team.named_members.append(pid)
	var p: PersonData = persons.get(pid)
	if p != null:
		p.team_id = team.team_id

func remove_member(team: TeamData, pid: int, clear_team_id: bool = true) -> void:
	team.named_members.erase(pid)
	if clear_team_id:
		var p: PersonData = persons.get(pid)
		if p != null:
			p.team_id = -1

# 雙向單一入口：team.leader_id ↔ person.team_id（leader 屬本隊）+ role 同步（規則2 leader 版）。
# 統一 leader 指派 chokepoint，mirror add_member/set_team_faction：所有 team.leader_id= 直寫改走此。
# 新 leader：出 named_members（leader 與 named 分職）+ team_id 回指本隊 + role="leader"
#   （即使新 leader 曾持 stale team_id 亦強制修正 → 根修 leader/team_id desync）。
# old_leader_action: "member"=舊 leader 留隊降 named（team_id 已本隊、補回 named + role="member"）；
#   "none"(default)=舊 leader 已死/已他處理，不動（succession/建國 常態）。
# pid=-1 允許（清空 leader，transient；不設 role/team_id）。idempotent。
func set_leader(team: TeamData, pid: int, old_leader_action: String = "none") -> void:
	var old_id: int = team.leader_id
	if old_id != -1 and old_id != pid and old_leader_action == "member":
		var op: PersonData = persons.get(old_id)
		if op != null:
			op.role = "member"
		add_member(team, old_id)   # 舊 leader 降 named（team_id 已本隊；idempotent）
	team.leader_id = pid
	if pid != -1:
		team.named_members.erase(pid)   # leader 出 named（與 named 分職）
		var p: PersonData = persons.get(pid)
		if p != null:
			p.team_id = team.team_id     # 強制回指本隊（修 stale desync）
			p.role = "leader"

# ── S5 tags 單寫者 chokepoint ─────────────────────────────────
# load-bearing tags（軍隊/生產/流亡，movement 讀決策）＝真值源保護點。reason 供 driver-ledger 審計。
# 所有 team.tags= / .append / .erase 直寫改走此三入口（outpost_system 暫豁免＝平行紀律：
#   conquest-yield-chain 在飛同機改 outpost，避 merge 撞；該波 merge 後補收）。
# 語意鏡射原直寫（append/erase 無條件，不加 dedup）→ pointwise 位元不變；原有 site-guard 保留於呼叫端。
# CI-scan: grep -nE '\.tags *=[^=]|\.tags\.append|\.tags\.erase|\.tags\.clear' scripts/simulation scripts/data
#   → 除 world_state.gd / outpost_system.gd 應為 0。
func set_team_tags(team: TeamData, tags: Array, reason: String = "") -> void:
	team.tags = tags
	record_driver(team, "tags", 0.0, reason, "trait")

func add_tag(team: TeamData, tag, reason: String = "") -> void:
	team.tags.append(tag)
	record_driver(team, "tags", 1.0, reason, "trait")

func remove_tag(team: TeamData, tag, reason: String = "") -> void:
	team.tags.erase(tag)
	record_driver(team, "tags", -1.0, reason, "trait")

# ── S6 高風險無主欄 chokepoint（本波收 readiness + solo_intent，非全欄）──────
# readiness：戰鬥/恢復多系統寫 → 單寫者 + reason。值計算留呼叫端（此只賦值+記，pointwise 不變）。
#   npc_combat_system drain 暫豁免＝平行紀律（conquest-yield-chain 在飛），該波 merge 後補收。
# CI-scan: grep -nE '\.readiness *=[^=]' scripts/simulation scripts/data
#   → 除 world_state.gd / npc_combat_system.gd 應為 0。
func set_readiness(team: TeamData, val: float, reason: String = "") -> void:
	team.readiness = val
	record_driver(team, "readiness", 0.0, reason, "state")

# solo_intent：獨立隊戰略 intent struct（type/why/mode，driver-complete）。faction_ai._set_solo 升格呼此（消旁寫）。
# CI-scan: grep -nE '\.solo_intent *=' scripts → 除 world_state.gd 應為 0。
func set_solo_intent(team: TeamData, itype: String, why: String, mode: String, reason: String = "") -> void:
	team.solo_intent = {"type": itype, "why": why, "mode": mode}
	record_driver(team, "solo_intent", 0.0, reason, "state")

# 單一 team 建立 chokepoint（S9，erase_team 對稱）：teams 註冊 + known/discovered row init。
# 所有 `state.teams[id] = team` 直寫（世界gen/beast/subteam/manpower/population/reaction/split/tutorial）改走此，
# 一處保證 registry 完整 → 根除「建隊漏 init known/discovered → 後續查詢 desync」病例（recruit_tutorial 曾漏）。
# 刻意不碰：tile 索引由 rebuild_team_tile_index 每 _step2_move 重建（此不預插，保 pointwise）；
#   team_intel row 由 belief_system lazy init（此不碰）。known/discovered 用無條件 = []（mirror 原 10 站點無條件寫）。
# CI-scan（強制閘地基）: grep -n 'state\.teams\[.*\] *=' scripts/simulation scripts/data
#   → 除 world_state.gd 自身應為 0（debug/ fixture 除外）。
func create_team(team: TeamData) -> void:
	teams[team.team_id] = team
	team_known[team.team_id] = []
	team_discovered[team.team_id] = []

# 單一 team 移除 chokepoint：語意 = erase_teams([tid])（薄 wrapper，呼叫端零改動）。
# 所有 team 移除（滅團/合併/野獸清除）都須走此/erase_teams 入口。
func erase_team(tid: int) -> void:
	erase_teams([tid])

# 批次 team 移除 chokepoint：清光所有指向 dead set 的 ref，使「無懸空 team_id」成不變量。
# die-off 潮 K 隊逐隊 erase = K 趟 O(N) 全掃 spike（違效能域「早晚期成本無延遲差」）
# → 批次收斂：每隊局部步驟（步1 母子/步2 faction）照原順序逐隊做（語意/連鎖順序不變）；
# 步3/4/4b 合一單趟：dead set Dictionary O(1) membership，一趟 teams + 一趟 known/discovered/intel
# （每 observer row 逐 dead tid erase，row 內 O(1)）。O(K·N) → O(N + K)。
func erase_teams(tids: Array) -> void:
	var dead: Dictionary = {}
	var dead_list: Array = []
	for tid in tids:
		if teams.has(tid) and not dead.has(tid):
			dead[tid] = true
			dead_list.append(tid)
	if dead_list.is_empty():
		return
	# ★T0-A1 ②：同批死亡 → 死者的 faction 同僚立即重新思考（盟主/成員結構剛變）
	var _notify: Array = []
	for _dtid in dead_list:
		var _dt: TeamData = teams[_dtid]
		if _dt.faction_id != -1 and factions.has(_dt.faction_id):
			for _mid in factions[_dt.faction_id].member_team_ids:
				if not dead.has(_mid): _notify.append(_mid)
	WorldEvents.emit(self, "teams_erased", _notify)
	# ★★★A#14 死亡可見（systems 裁 2026-09-02，掛點＝這個唯一窄口）：
	#   ★所有死法（戰鬥／饑荒／併入／滅族）都得經過 erase_teams ⇒ 一個掛點解多個觀測缺口。
	#   ★★掛在【mutation 開始之前】：下面那個 for 會 detach/清 ref，這裡的 team 還是完整的。
	#   ★★★純觀測：`capture_death` 只做欄位直讀（不呼 `_snapshot`、不呼任何會寫的東西）、零 RNG、
	#     specimen-gated（非 specimen ／ tracer 關 ⇒ 兩個 early-return）⇒ tracer off 時 byte-identical。
	for _dtid2 in dead_list:
		SpecimenTracer.capture_death(self, teams[_dtid2], "erase_teams")
	# ★★★死隊的看板單隨它一起走（族④#6 改票，systems 2026-09-02）：
	#   ★訂單生命週期是【owner 驅動】的（`order_system.gd:88` 原文：「他隊 entry 不動，由各自
	#     tick_team_orders 維護」），而 `tick_team_orders` 只對【活著的隊】跑
	#   ⇒ ★★隊死了 ⇒ 它的 board entry 在【任何活市集上永久掛著】，而那些 tile 的 outpost_level > 0
	#     ⇒ 讀得到 ⇒ ★★★不需要拆除、也不需要易主就會發生
	#   ★這【不是】capture/demolish 特判：藍圖禁的是「易主時特別清空」，
	#     而「實體消失時清掉它留下的懸空引用」是通則。
	#   ★★掃法：整批一趟（★不是每隊一趟）—— 沿用本函式既有的 O(N+K) 精神
	if not dead_list.is_empty():
		var _orders_seen: int = 0
		var _orders_removed: int = 0
		for _tk in world.tiles:
			var _wt: HexTileData = world.tiles[_tk]
			if _wt.market_orders.is_empty():
				continue
			_orders_seen += _wt.market_orders.size()
			var _kept: Array = []
			for _e in _wt.market_orders:
				if dead.has(int(_e.get("origin_team", -1))):
					_orders_removed += 1
				else:
					_kept.append(_e)
			if _kept.size() != _wt.market_orders.size():
				_wt.market_orders = _kept
		if Probe.enabled:
			# ★entry counter：沒有它，「殘留 0」與「這個窗裡根本沒隊死」長得一模一樣
			Probe.bump("erase.batches")
			Probe.add_amount("erase.teams_erased", float(dead_list.size()))
			# ★★清之前【全世界看板上有幾筆】—— 沒有這個分母，「清了 N 筆」不知道是多是少
			Probe.add_amount("erase.board_entries_seen", float(_orders_seen))
			Probe.add_amount("erase.board_entries_removed", float(_orders_removed))
	for tid in dead_list:
		var team: TeamData = teams[tid]
		# 1. 母子：脫離 parent + 孤兒化自己的子隊
		if team.parent_team_id != -1:
			detach_subteam(team)
		for cid in team.subteam_ids.duplicate():
			if teams.has(cid):
				teams[cid].parent_team_id = -1
		team.subteam_ids.clear()
		# 2. faction：退成員 + known_member_states + 若為盟主則解散
		if team.faction_id != -1 and factions.has(team.faction_id):
			var f = factions[team.faction_id]
			f.member_team_ids.erase(tid)
			f.known_member_states.erase(tid)
			if f.leader_team_id == tid:
				# ★繼承-lite：領袖團死 → 先找接班（傳本批 dead 集合，排除同波死者＝dead-man-walking race）
				succeed_or_disband_faction(team.faction_id, tid, dead)
		# 3b. 傷亡累積器 _cas_carry 餘量清除（隊死 chokepoint=所有消滅路徑；防 team_id 重用洩漏。
		# §D4 A / reviewer R②：真累積器硬要求顯式 erase，非靠 start_combat 隱式重置）
		NpcCombatSystem._cas_carry.erase(tid)
	# 3a. settlement S1a 死亡釋放：dead tid owned outpost tile → outpost_owner=-1（鬼城解鎖，供他隊既有
	# takeover timer 撿现成認領）。★R² 效率：單 pass over world.tiles 配 dead:Dictionary O(1) membership
	# （非每 dead team 各掃全圖 O(dead×tiles)）。同 :315 for-otid-if-dead.has pattern。
	for tid in world.tiles:
		var wt: HexTileData = world.tiles[tid]
		if dead.has(wt.outpost_owner):
			wt.outpost_owner = -1
			OwnerOutpostIndex.invalidate()   # ★效能 arc B chokepoint③：繞過 bank 的直接 owner 寫
	# 3. 其他隊指向任一 dead tid 的 ref 單趟全清（死隊間互指不清：隨 teams.erase 一併消失）
	for otid in teams:
		if dead.has(otid):
			continue
		var o: TeamData = teams[otid]
		if dead.has(o.combat_target):
			o.combat_target = -1
		if dead.has(o.social_target):
			o.social_target = -1
		if dead.has(o.order_target_id):
			o.order_target_id = -1
		for dtid in dead_list:
			o.known_reputations.erase(dtid)
			o.invite_cooldown.erase(dtid)
			o.diplomacy_reject_cooldown.erase(dtid)
			o.strategic_assignments.erase(dtid)
	# 4. registry 交叉：discovered/known 每 observer row 逐 dead tid erase
	for obs in team_known:
		if dead.has(obs):
			continue
		for dtid in dead_list:
			team_known[obs].erase(dtid)
	for obs in team_discovered:
		if dead.has(obs):
			continue
		for dtid in dead_list:
			team_discovered[obs].erase(dtid)
	# 4b. team_intel prune（top memory leak 修）：死 tid 的 observer row + 各 observer 對其 target claim
	# 皆清（否則 observer dict + 死 target claim rows 隨世界年齡無界成長）。同 chokepoint。
	for obs in team_intel:
		if dead.has(obs):
			continue
		for dtid in dead_list:
			team_intel[obs].erase(dtid)
	# 5. 自身條目（known/discovered/intel row）+ 移除，逐 dead tid 收尾
	for dtid in dead_list:
		team_known.erase(dtid)
		team_discovered.erase(dtid)
		team_intel.erase(dtid)
		teams.erase(dtid)


# 解析「保證活」的 team ref（契約：納管 team-ref 非 -1 即指向活 team）。
# caller 須先處理 -1（語意上的「無」）再呼叫。不存在 = 不變量被破 → assert
# （debug 抓 bug；release 剝離 → 不崩，保 1000-tick 韌性）。
func require_team(tid: int) -> TeamData:
	assert(teams.has(tid), "require_team: Team%d 不存在（team-ref 不變量被破）" % tid)
	return teams[tid]

# ── P0 tile→teams 空間索引 ─────────────────────────────────
# rebuild：O(N) 全掃一次重建（sim_runner 每次 _step2_move 後呼，使消費端見 post-move 位置）。
func rebuild_team_tile_index() -> void:
	teams_by_tile.clear()
	for tid in teams:
		var key: int = _tile_key(teams[tid].tile_pos)
		if not teams_by_tile.has(key):
			teams_by_tile[key] = []
		teams_by_tile[key].append(int(tid))

# 同格查詢：回 tile_pos 上所有 team_id（消費端仍須 live 復驗 tile_pos 以容碰撞/瞬時態）。
func teams_on_tile(tile_pos: Vector2i) -> Array:
	return teams_by_tile.get(_tile_key(tile_pos), [])

# 鄰域查詢：回 hex_dist(center, tile) ≤ range_hex 的 tile 上所有 team_id（軸座標鄰域枚舉）。
# 回傳為候選超集（枚舉的鄰域 tile 保證 hex_dist≤range，但 key 碰撞可能混入他格）→ 消費端復驗 hex_dist。
func teams_within(center: Vector2i, range_hex: int) -> Array:
	var out: Array = []
	for dq in range(-range_hex, range_hex + 1):
		var lo: int = maxi(-range_hex, -dq - range_hex)
		var hi: int = mini(range_hex, -dq + range_hex)
		for dr in range(lo, hi + 1):
			var key: int = (center.x + dq) * 1000 + (center.y + dr)
			if teams_by_tile.has(key):
				out.append_array(teams_by_tile[key])
	return out

func _tile_key(pos: Vector2i) -> int:
	return pos.x * 1000 + pos.y

# ── 遭遇戰臨時狀態（active 期間使用，結束後清空） ──
var encounter_active: bool        = false
var encounter_units: Array        = []   # Array[Dictionary]
var encounter_attacker_id: int    = -1
var encounter_defender_id: int    = -1
var pursuit_edge_offset: int      = 0   # 追擊進場邊緣輪換計數
var encounter_tick: int           = 0
var encounter_log: Array          = []   # U11: 遭遇戰命中/閃避/格擋/落空 訊息流（init 清空，UI 經 bridge 讀最新 n 條）
var last_encounter_result: Dictionary = {}
# Format: { "winner_id": int, "loser_id": int, "loot_pool": Dictionary, "can_subjugate": bool }
# Cleared after player takes/leaves loot.

# Leader 繼承等用：player 所屬 team_id 單一源（player 死亡時反查掛載 team）。
func get_player_team_id() -> int:
	if player_id == -1:
		return -1
	var p = persons.get(player_id)
	if p == null:
		for tid in teams:
			var t = teams[tid]
			if t.leader_id == player_id or player_id in t.named_members:
				return tid
		return -1
	return p.team_id

func snapshot_faction_member(team_id: int, tick: int) -> void:
	var t: TeamData = teams.get(team_id) as TeamData
	if t == null or t.faction_id == -1:
		return
	var f = factions.get(t.faction_id)
	if f == null:
		return
	f.known_member_states[team_id] = {
		"food":         float(t.resources.get("food", 0.0)),
		"weapons":      (int(t.resources.get("weapon_melee_low",   0))
		              + int(t.resources.get("weapon_melee_high",  0))
		              + int(t.resources.get("weapon_ranged_low",  0))
		              + int(t.resources.get("weapon_ranged_high", 0))),
		"goods":        float(t.resources.get("goods", 0.0)),
		"population":   t.population,
		"tile_pos":     t.tile_pos,
		"current_task": t.current_task,
		"last_tick":    tick,
	}
