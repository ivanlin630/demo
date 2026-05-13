class_name NpcMemorySystem
extends RefCounted
## NPC profile generation, memory recording, and relation tracking.
## NPC profiles are created lazily when the player deeply interacts with someone.
## Memories carry intensity levels (SLIGHT / DEEP / SCAR) and fade over time.

# ── Inner classes ─────────────────────────────────────────────────────────────

class NpcProfile:
	var id:              int    = -1
	var name:            String = ""
	var social_identity: String = "平民"  # 農民/商人/士兵/盜匪/流民/僧侶/貴族
	var personality:     String = ""      # 謹慎/衝動/忠誠/貪婪/仁慈/冷酷
	var goal:            String = ""      # 求生/復仇/致富/晉升/逃離戰亂
	var skill_level:     int    = 1       # 1–5; affects info accuracy the NPC gives
	var faction_id:      int    = -1
	var memories:        Array  = []      # Array[MemoryEntry]

	func _init() -> void:
		memories = []

	func summary() -> String:
		return "[%s] %s　性格：%s　目標：%s　技能：%d/5" % [
			social_identity, name, personality, goal, skill_level
		]


class MemoryEntry:
	var type:        String = ""   # "rescue" | "betrayal" | "battle" | "loss" | "humiliation" | "robbery"
	var description: String = ""
	var turn:        int    = 0
	var intensity:   int    = 1   # GameConfig.MEM_SLIGHT / MEM_DEEP / MEM_SCAR
	var strength:    float  = 1.0 # 0.0–1.0; decays; SCAR never fades

	func _init(t: String, desc: String, trn: int, inten: int) -> void:
		type        = t
		description = desc
		turn        = trn
		intensity   = inten
		strength    = 1.0


class NpcRelation:
	var a_id:     int   = -1
	var b_id:     int   = -1
	var trust:    float = 0.5   # 0.0–1.0
	var affinity: float = 0.5   # 0.0–1.0
	var fear:     float = 0.0   # 0.0–1.0
	var loyalty:  float = 0.5   # 0.0–1.0

	func _init(a: int, b: int) -> void:
		a_id = a
		b_id = b

# ── Constants ─────────────────────────────────────────────────────────────────

const PERSONALITIES: Array = ["謹慎", "衝動", "忠誠", "貪婪", "仁慈", "冷酷"]
const GOALS:         Array = ["求生", "復仇", "致富", "晉升", "逃離戰亂"]
const IDENTITIES:    Array = ["農民", "商人", "士兵", "盜匪", "流民", "僧侶", "貴族"]

# ── Fields ────────────────────────────────────────────────────────────────────

var _world:     WorldState
var _profiles:  Array = []   # Array[NpcProfile]
var _relations: Array = []   # Array[NpcRelation]
var _rng:       RandomNumberGenerator
var _next_id:   int = 1000   # NPC IDs start above faction ID range

func _init(ws: WorldState) -> void:
	_world    = ws
	_rng      = RandomNumberGenerator.new()
	_rng.seed = ws.seed_value + 777777
	_profiles  = []
	_relations = []

# ── Profile management ────────────────────────────────────────────────────────

## Create a new NPC profile with randomised personality/goal/identity.
## Call this when the player has a deep interaction at an outpost.
func create_profile(npc_name: String, identity: String = "", fid: int = -1) -> NpcProfile:
	var p := NpcProfile.new()
	p.id              = _next_id
	_next_id         += 1
	p.name            = npc_name
	p.social_identity = identity if not identity.is_empty() \
		else IDENTITIES[_rng.randi_range(0, IDENTITIES.size() - 1)]
	p.personality     = PERSONALITIES[_rng.randi_range(0, PERSONALITIES.size() - 1)]
	p.goal            = GOALS[_rng.randi_range(0, GOALS.size() - 1)]
	p.skill_level     = _rng.randi_range(1, 5)
	p.faction_id      = fid
	_profiles.append(p)
	return p

func get_profile(id: int) -> NpcProfile:
	for p in _profiles:
		if (p as NpcProfile).id == id:
			return p as NpcProfile
	return null

func get_all_profiles() -> Array:
	return _profiles

## Return all profiles belonging to a faction.
func get_faction_profiles(fid: int) -> Array:
	var result: Array = []
	for p in _profiles:
		if (p as NpcProfile).faction_id == fid:
			result.append(p)
	return result

# ── Memory ────────────────────────────────────────────────────────────────────

## Record a significant event in an NPC's memory.
## intensity: GameConfig.MEM_SLIGHT / MEM_DEEP / MEM_SCAR
func record_event(subject_id: int, type: String,
		description: String, intensity: int) -> void:
	var p := get_profile(subject_id)
	if p == null:
		return
	p.memories.append(MemoryEntry.new(type, description, _world.current_turn, intensity))

# ── Relations ─────────────────────────────────────────────────────────────────

func get_or_create_relation(a_id: int, b_id: int) -> NpcRelation:
	for r in _relations:
		var rel := r as NpcRelation
		if (rel.a_id == a_id and rel.b_id == b_id) \
				or (rel.a_id == b_id and rel.b_id == a_id):
			return rel
	var new_rel := NpcRelation.new(a_id, b_id)
	_relations.append(new_rel)
	return new_rel

## delta_trust / delta_affinity: positive or negative adjustment.
func adjust_relation(a_id: int, b_id: int,
		delta_trust: float, delta_affinity: float) -> void:
	var rel := get_or_create_relation(a_id, b_id)
	rel.trust    = clamp(rel.trust    + delta_trust,   0.0, 1.0)
	rel.affinity = clamp(rel.affinity + delta_affinity, 0.0, 1.0)

# ── Simulation tick ───────────────────────────────────────────────────────────

## Call once per simulation turn to decay non-scar memories.
func update_turn() -> void:
	for pvar in _profiles:
		var p := pvar as NpcProfile
		var expired: Array = []
		for mvar in p.memories:
			var mem := mvar as MemoryEntry
			if mem.intensity >= GameConfig.MEM_SCAR:
				continue  # scars never fade
			var fade: float = GameConfig.MEM_FADE_SLIGHT \
				if mem.intensity == GameConfig.MEM_SLIGHT \
				else GameConfig.MEM_FADE_DEEP
			mem.strength -= fade
			if mem.strength <= 0.0:
				expired.append(mem)
		for m in expired:
			p.memories.erase(m)

# ── Helper: subjective info quality ──────────────────────────────────────────

## A low-skill NPC gives imprecise or wrong info about an event.
## Returns a distorted description string based on npc skill level.
func distort_for_skill(npc_id: int, true_desc: String) -> String:
	var p := get_profile(npc_id)
	if p == null:
		return true_desc

	var skill := p.skill_level
	if skill >= 4:
		return true_desc   # 高技能：如實傳達

	if skill == 3:
		# 中技能：有點不確定
		return "據說 " + true_desc

	if skill == 2:
		# 低技能：加入個人偏見
		var noise := ["可能是饑荒引起的。", "聽說和某支軍隊有關。", "傳聞是外地人幹的。"]
		return true_desc + " " + noise[_rng.randi_range(0, noise.size() - 1)]

	# 技能1：幾乎無法理解
	return "聽說附近有大事發生，但說不清楚。"
