class_name WorldState

# ── 時間基底 ──────────────────────────────────────────────────
const TICKS_PER_DAY:    int   = 240          # 10 ticks/hour
const TICKS_PER_HOUR:   int   = TICKS_PER_DAY / 24   # = 10
const TICKS_PER_MONTH:  int   = TICKS_PER_DAY * 30   # = 7200 ticks
const TICKS_PER_SEASON: int   = TICKS_PER_DAY * 90   # = 21600 ticks
const TICKS_PER_YEAR:   int   = TICKS_PER_DAY * 360  # = 86400 ticks
const SECONDS_PER_TICK: float = 86400.0 / float(TICKS_PER_DAY)

var world: WorldData = WorldData.new()
var teams: Dictionary = {}
var persons: Dictionary = {}
var global_messages: Array = []
var team_known: Dictionary = {}
var team_discovered: Dictionary = {}   # int team_id → Array[int] 已知 team_id 清單
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
var _next_faction_id: int = 0
var player_id: int = -1
var specimen_team_ids: Array[int] = []   # 指標團：LOD-exempt + SpecimenTracer 詳捕決策（觀測 only，debug/seed 設）
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

func disband_faction(faction_id: int) -> void:
	if not factions.has(faction_id):
		return
	var f = factions[faction_id]
	for tid in f.member_team_ids:
		if teams.has(tid):
			teams[tid].faction_id = -1
	factions.erase(faction_id)
	print("[Faction] 勢力%d 解散" % faction_id)

# 雙向單一入口：team.faction_id ↔ faction.member_team_ids 一處同維護（規則3）。
# 換 faction 自動退舊團、入新團；idempotent。
func set_team_faction(team: TeamData, fid: int) -> void:
	if team.faction_id == fid:
		return
	if team.faction_id != -1 and factions.has(team.faction_id):
		factions[team.faction_id].member_team_ids.erase(team.team_id)
	team.faction_id = fid
	if fid != -1 and factions.has(fid):
		if not factions[fid].member_team_ids.has(team.team_id):
			factions[fid].member_team_ids.append(team.team_id)

func clear_team_faction(team: TeamData) -> void:
	set_team_faction(team, -1)

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

# 單一 team 移除 chokepoint：清光所有指向 tid 的 ref，使「無懸空 team_id」成不變量。
# 所有 team 移除（滅團/合併/野獸清除）都須走此入口。
func erase_team(tid: int) -> void:
	var team: TeamData = teams.get(tid)
	if team == null:
		return
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
			disband_faction(team.faction_id)
	# 3. 其他隊指向 tid 的 ref 全清
	for otid in teams:
		if otid == tid:
			continue
		var o: TeamData = teams[otid]
		if o.combat_target == tid:
			o.combat_target = -1
		if o.order_target_id == tid:
			o.order_target_id = -1
		o.known_reputations.erase(tid)
		o.invite_cooldown.erase(tid)
		o.diplomacy_reject_cooldown.erase(tid)
		o.strategic_assignments.erase(tid)
	# 4. registry：自身條目 + 交叉 discovered/known
	team_known.erase(tid)
	team_discovered.erase(tid)
	for obs in team_known:
		team_known[obs].erase(tid)
	for obs in team_discovered:
		team_discovered[obs].erase(tid)
	# 5. 移除
	teams.erase(tid)


# 解析「保證活」的 team ref（契約：納管 team-ref 非 -1 即指向活 team）。
# caller 須先處理 -1（語意上的「無」）再呼叫。不存在 = 不變量被破 → assert
# （debug 抓 bug；release 剝離 → 不崩，保 1000-tick 韌性）。
func require_team(tid: int) -> TeamData:
	assert(teams.has(tid), "require_team: Team%d 不存在（team-ref 不變量被破）" % tid)
	return teams[tid]

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
