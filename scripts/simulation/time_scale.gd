class_name TimeScale

# ── 時間量唯一權威源（TimeScale 骨架，time-scale wave slice A）──────────────
# 承既有根，單向依賴 TimeScale → {WorldState, EncounterSystem}；反向禁（避免循環）。
#   TICK_PER_DAY        根        承 world_state（天長）
#   BASE_ACTION_TICKS   第二根    承 encounter（遭遇戰動作粒度）
#   ENCOUNTER_MAP_SCALE 錨②       承 encounter 地圖直徑（=24，遭遇戰地圖尺度）
#   MOVE_TICKS_PER_HEX  錨①       = BASE_ACTION × ENCOUNTER_MAP_SCALE / WORLD_SPEED_MULT（連動）
# 新碼一律用 TimeScale.*；語意延遲/timeout 用 days(N)/hours(N)，非裸硬編 tick。
#
# ★A1/A2 拆片（藍圖 timewave-five-rulings，防餓死潮）：本 = A1 骨架（散落常數收單源，
#   ×5 先留=零行為變,可即 merge）。A2 = 拿掉 WORLD_SPEED_MULT(×5→1,MOVE 48→240)
#   + ④沿途補給 + FOOD 消耗重校 + gen 承載力重校，四件一個 landing（缺補給裸切 ×1=餓死潮）。
const TICK_PER_DAY: int        = WorldState.TICKS_PER_DAY
const BASE_ACTION_TICKS: int   = EncounterSystem.BASE_ACTION_TICKS
const ENCOUNTER_MAP_SCALE: int = EncounterSystem.MAP_DIAMETER
const WORLD_SPEED_MULT: int    = 5   # A2-pending：×5→1 綁四件（藍圖 A2）;A1 先留=零行為
const MOVE_TICKS_PER_HEX: int  = BASE_ACTION_TICKS * ENCOUNTER_MAP_SCALE / WORLD_SPEED_MULT  # =48（A1 ×5留;A2 拿 mult→240=1天/hex）

static func days(n: int) -> int:  return n * TICK_PER_DAY
static func hours(n: int) -> int: return n * TICK_PER_DAY / 24
