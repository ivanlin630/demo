class_name AmbitionLadder

const RUNG_SURVIVE: int = 0
const RUNG_ACCUMULATE: int = 1
const RUNG_EXPAND: int = 2
const RUNG_STATE: int = 3
const RUNG_HEGEMON: int = 4

const ARCHETYPE_FORCE: String = "武力"
const ARCHETYPE_TRADE: String = "商業"
const ARCHETYPE_SETTLE: String = "定居"

const LADDER_EVAL_CADENCE: int = 10 * WorldState.TICKS_PER_HOUR
# 安全門檻 proxy（TEST VALUE）
const SURPLUS_DAYS: float = 7.0
const EXPAND_MIN_POP: int = 8
const STATE_MIN_FACTION_TEAMS: int = 2
const HEGEMON_MIN_FACTION_TEAMS: int = 4

# leader values 最高軸 → archetype（平手序 武力>商業>定居）。TEST VALUE 權重。
static func derive_archetype(leader: PersonData) -> String:
	if leader == null:
		return ARCHETYPE_SETTLE
	var v: Dictionary = leader.values
	var force: float = float(v.get("野心", 0.5)) * 0.5 + float(v.get("好戰", 0.5)) * 0.5
	var trade: float = float(v.get("貪婪", 0.5))
	var settle: float = float(v.get("義氣", 0.5)) * 0.5 + float(v.get("慎重", 0.5)) * 0.5
	if force >= trade and force >= settle:
		return ARCHETYPE_FORCE
	if trade >= settle:
		return ARCHETYPE_TRADE
	return ARCHETYPE_SETTLE

# 野心 → 封頂 rung（TEST VALUE）
static func derive_cap(leader: PersonData) -> int:
	if leader == null:
		return RUNG_ACCUMULATE
	var amb: float = float(leader.values.get("野心", 0.5))
	if amb < 0.3: return RUNG_ACCUMULATE
	if amb < 0.55: return RUNG_EXPAND
	if amb < 0.8: return RUNG_STATE
	return RUNG_HEGEMON
