class_name FactionData

var faction_id: int = 0
var faction_name: String = ""
var is_established: bool = false
var leader_team_id: int = -1
var member_team_ids: Array = []
var tribute_rate: float = 0.10

# 策略層（faction_ai_system 讀寫）
var goals: Array = []        # ["徵收", "立國", "擴張", "防禦"]
var directive_change_tick: int = 0   # ⑦ 統一重評：faction 命令(goals)最後變化 tick（_emit_goal stamp；成員 directive_fresh 讀）
var strategy: String = "idle"

# commander-v2 means-end：意圖驅動 + 每令 driver（北極星：named 意圖必有可解釋驅動）
var intent: Dictionary = {}        # {type:String, target_id:int, why:String} 承諾追蹤（hysteresis）
# ★★S3：五支 faction 級節律的【下次評估 tick】—— 全部改走 CadenceStagger。
#   ★舊實作是 `current_tick % C == 0` ⇒ 所有 faction 【同一批 tick 到期】
#     （實測指紋：間隔範圍 [4320, 4320] 完全剛性）—— 而那正是 CadenceStagger 存在的理由。
#   ★★搬完的直接證據不是統計量，是【範圍要散開】。
# ★錯開票 (乙)：每小時那一趣 pass 的【勢力粒度】下次到期 tick。
#   ★為什麼不跟著成員隊：faction_ai 是【勢力粒度】的系統 ——
#     批次裡只要有一個成員到期它就把整個勢力的活做一遛
#     ⇒ ★★隊粒度錯開之下，一個 M 成員的勢力每小時會被做 ~M 次而不是 1 次。
#     ⇒ ★★★那不是「慢」是【重複執行】，而 faction-drive-once 那一列就是來擋這個的。
#   ★`_next_tick` 字尾 ⇒ FpCoverage 的 CADENCE_SUFFIXES 自動排除在指紋外（同 TeamData 那顆）。
var pass_next_tick: int = 0
var infra_eval_next_tick: int = 0
var faction_update_next_tick: int = 0
var betray_eval_next_tick: int = 0
var strategic_eval_next_tick: int = 0
var alliance_eval_next_tick: int = 0
# ★第⑦票：定期徵收的 `effective_interval` 是【動態】的 ⇒ 它是不是 FAR_ZONE_INTERVAL 的倍數
#   純屬偶然 ⇒ 與 salary 同一類（遠盟只在恰好對上相位時才徵得到）。
var levy_eval_next_tick: int = 0     # ★下次「守成」定期徵收評估 tick（⑦：取代裸 modulo）
var intent_eval_next_tick: int = 0   # 下次 intent 重選 tick（cadence，A2b #3；鏡射 team threat/subteam_eval_next_tick）
var goal_drivers: Dictionary = {}  # goal(String) → {intent:String, why:String, mode:String} 每令連回意圖

# 跨勢力關係（立國號才有意義；未立國號留空）
# "neutral" / "ally" / "enemy"
var relations: Dictionary = {}  # faction_id → String

var known_member_states: Dictionary = {}
# { team_id: int → {
#   "food":         float,    # resources["food"]
#   "weapons":      int,      # sum(melee_low+melee_high+ranged_low+ranged_high)
#   "goods":        float,    # resources["goods"]
#   "population":   int,
#   "tile_pos":     Vector2i,
#   "current_task": String,
#   "last_tick":    int,
# }}

var player_goal_override: String = ""
# 玩家設定的勢力目標；"" = 無 override（faction_ai 自動計算）
# 有效值："expand" / "defend" / "trade_net"

# 策略層（strategic_ai_system 讀寫）
var strategic_goals: Array = []
# strategic goal 格式: { "type": String, "target_id": int, "priority": float }
# type: "expand" / "defend" / "trade_net" / "tribute" / "alliance"
