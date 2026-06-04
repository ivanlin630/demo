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
var _next_faction_id: int = 0
var player_id: int = -1
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
var ticks_per_day: int:
	get: return TICKS_PER_DAY

func create_faction(leader_team_id: int) -> int:
	var f = load("res://scripts/data/faction_data.gd").new()
	f.faction_id = _next_faction_id
	f.leader_team_id = leader_team_id
	f.member_team_ids = [leader_team_id]
	factions[f.faction_id] = f
	_next_faction_id += 1
	teams[leader_team_id].faction_id = f.faction_id
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

# ── 遭遇戰臨時狀態（active 期間使用，結束後清空） ──
var encounter_active: bool        = false
var encounter_units: Array        = []   # Array[Dictionary]
var encounter_attacker_id: int    = -1
var encounter_defender_id: int    = -1
var pursuit_edge_offset: int      = 0   # 追擊進場邊緣輪換計數
var encounter_tick: int           = 0

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
