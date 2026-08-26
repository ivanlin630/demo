class_name TimeScale

# ── 時間量唯一權威源（TimeScale 骨架，time-scale wave slice A）──────────────
# 承既有根，單向依賴 TimeScale → {WorldState, EncounterSystem}；反向禁（避免循環）。
#   TICK_PER_DAY        根        承 world_state（天長）
#   BASE_ACTION_TICKS   第二根    承 encounter（遭遇戰動作粒度）
#   ENCOUNTER_MAP_SCALE 錨②       承 encounter 地圖直徑（=24，遭遇戰地圖尺度）
#   MOVE_TICKS_PER_HEX  錨①       = BASE_ACTION × ENCOUNTER_MAP_SCALE（連動；S2 刪 WORLD_SPEED_MULT）
# 新碼一律用 TimeScale.*；語意延遲/timeout 用 days(N)/hours(N)，非裸硬編 tick。
#
# ★★★S2 重錨（2026-08-27）：A2 四件套【出列】—— 而理由不是「做完了」，是【不再需要】。
#   ★A2 當初把四件綁在一起，是因為【只】拿掉 WORLD_SPEED_MULT 會讓移動變 5 倍慢
#     （MOVE 48→240 tick @ 10 tick/小時 ＝ 4.8h → 24h）⇒ 缺沿途補給就是餓死潮。
#   ★★而 S2 同時把根旋鈕 10→60 tick/小時 ⇒ 240 tick ＝【 4 小時】，不是 24 小時。
#   ⇒ ★★★移動實際從 4.8h 只變成 4h（-17%），餓死潮的前提不存在，
#     沿途補給/FOOD 重校/承載力重校三件因此出列（非延後，是前提消失）。
const TICK_PER_HOUR: int       = WorldState.TICKS_PER_HOUR   # ★S2：根旋鈕本身
const TICK_PER_DAY: int        = WorldState.TICKS_PER_DAY
const BASE_ACTION_TICKS: int   = EncounterSystem.BASE_ACTION_TICKS
const ENCOUNTER_MAP_SCALE: int = EncounterSystem.MAP_DIAMETER
# ★S2：WORLD_SPEED_MULT 已刪 —— 世界格時間＝動作×格數，【公式無係數】（LOCKED §0 命門）。
const MOVE_TICKS_PER_HEX: int  = BASE_ACTION_TICKS * ENCOUNTER_MAP_SCALE  # = 240 tick = 4 小時（平原）

# ★★分鐘層（S2 新）：有些時長不是整數小時（例：turn ＝ 2.4 小時）。
#   ★hours() 只吃整數小時 ⇒ 表達不了；重錨後 1 分鐘 ＝ 1 tick，分鐘成為可用粒度。
#   ★★TICK_PER_MINUTE 是給【const 上下文】用的 —— GDScript 的 const 不能呼叫 static func，
#     而時間常數幾乎都宣告成 const；兩者同一個導出式，不是兩份真相。
const TICK_PER_MINUTE: int     = TICK_PER_HOUR / 60   # = 1（★根 < 60 會塌成 0，而那由動作>=10 tick 守衛擋下）

static func days(n: int) -> int:  return n * TICK_PER_DAY
static func hours(n: int) -> int: return n * TICK_PER_DAY / 24
# ★S2：分鐘粒度（非整數小時的時長用這一支，例：minutes(144) ＝ 2.4 小時）。
static func minutes(n: int) -> int: return n * TICK_PER_HOUR / 60
