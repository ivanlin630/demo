class_name TimeScale

# ── 時間量唯一權威源（TimeScale 骨架，time-scale wave slice A）──────────────
# 承既有根，單向依賴 TimeScale → {WorldState, EncounterSystem}；反向禁（避免循環）。
#   TICK_PER_DAY        根        承 world_state（天長）
#   BASE_ACTION_TICKS   第二根    承 encounter（遭遇戰動作粒度）
#   ENCOUNTER_MAP_SCALE 錨②       承 encounter 地圖直徑（=24，遭遇戰地圖尺度）
#   MOVE_TICKS_PER_HEX  錨①       = BASE_ACTION × ENCOUNTER_MAP_SCALE（連動,禁另塞倍率）
# 新碼一律用 TimeScale.*；語意延遲/timeout 用 days(N)/hours(N)，非裸硬編 tick。
const TICK_PER_DAY: int        = WorldState.TICKS_PER_DAY
const BASE_ACTION_TICKS: int   = EncounterSystem.BASE_ACTION_TICKS
const ENCOUNTER_MAP_SCALE: int = EncounterSystem.MAP_DIAMETER
const MOVE_TICKS_PER_HEX: int  = BASE_ACTION_TICKS * ENCOUNTER_MAP_SCALE  # =240=1天（錨①）

static func days(n: int) -> int:  return n * TICK_PER_DAY
static func hours(n: int) -> int: return n * TICK_PER_DAY / 24
