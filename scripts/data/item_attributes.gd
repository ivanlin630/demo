# scripts/data/item_attributes.gd
class_name ItemAttributes

const ITEM_REGISTRY: Dictionary = {

	# ── 武器 ──────────────────────────────────────────────
	"weapon_melee_low": {
		"display_name":  "短劍",
		"category":      "weapon",
		"damage":        10.0,
		"range":         1,
		"is_2h":         false,
		"parry_chance":  0.10,
		"weight":        2.5,
	},
	"weapon_melee_high": {
		"display_name":  "長劍",
		"category":      "weapon",
		"damage":        15.0,
		"range":         1,
		"is_2h":         false,
		"parry_chance":  0.20,
		"weight":        4.0,
	},
	"weapon_ranged_low": {
		"display_name":  "短弓",
		"category":      "weapon",
		"damage":        8.0,
		"range":         4,
		"is_2h":         true,
		"parry_chance":  0.0,
		"weight":        2.0,
	},
	"weapon_ranged_high": {
		"display_name":  "長弓",
		"category":      "weapon",
		"damage":        12.0,
		"range":         6,
		"is_2h":         true,
		"parry_chance":  0.0,
		"weight":        3.0,
	},
	"unarmed": {
		"display_name":  "徒手",
		"category":      "weapon",
		"damage":        5.0,
		"range":         1,
		"is_2h":         false,
		"parry_chance":  0.05,
		"weight":        0.0,
	},

	# ── 護甲 / 盾牌 ────────────────────────────────────────
	"armor_low": {
		"display_name":        "皮甲",
		"display_name_shield": "皮盾",
		"category":            "armor",
		"damage_reduction":    0.4,
		"block_chance":        0.30,
		"weight":              4.0,
	},
	"armor_high": {
		"display_name":        "鐵甲",
		"display_name_shield": "鐵盾",
		"category":            "armor",
		"damage_reduction":    0.6,
		"block_chance":        0.50,
		"weight":              7.0,
	},

	# ── 消耗品 ─────────────────────────────────────────────
	"food": {
		"display_name": "乾糧",
		"category":     "consumable",
		"weight":       0.5,
	},
	"medicine": {
		"display_name": "藥品",
		"category":     "consumable",
		"weight":       0.3,
		"use_cost": {
			"草藥":   1,
			"繃帶":   2,
			"解毒劑": 3,
		},
	},
	"tools": {
		"display_name": "工具包",
		"category":     "consumable",
		"weight":       2.0,
		"use_cost": {
			"夾板": 1,
		},
	},
	"arrows": {
		"display_name":   "箭矢",
		"category":       "consumable",
		"weight":         0.05,
		"cost_per_shot":  1,
	},
}

const ARROW_COST_PER_SHOT: int = 1

static func _lookup(grade: String) -> Dictionary:
	return ITEM_REGISTRY.get(grade, {})

static func get_damage(grade: String) -> float:
	return float(_lookup(grade).get("damage", _lookup("unarmed").get("damage", 5.0)))

static func get_range(grade: String) -> int:
	return int(_lookup(grade).get("range", 1))

static func is_2h(grade: String) -> bool:
	return bool(_lookup(grade).get("is_2h", false))

static func get_parry_chance(grade: String) -> float:
	return float(_lookup(grade).get("parry_chance", 0.05))

static func get_damage_reduction(grade: String) -> float:
	return float(_lookup(grade).get("damage_reduction", 0.0))

static func get_block_chance(grade: String) -> float:
	return float(_lookup(grade).get("block_chance", 0.0))

static func get_weight(grade: String, qty: int = 1) -> float:
	return float(_lookup(grade).get("weight", 1.0)) * qty

static func get_medicine_cost(action: String) -> int:
	return int(_lookup("medicine").get("use_cost", {}).get(action, 0))

static func get_tools_cost(action: String) -> int:
	return int(_lookup("tools").get("use_cost", {}).get(action, 0))

static func get_display_name(grade: String, slot: String = "") -> String:
	var item: Dictionary = _lookup(grade)
	if slot in ["hand_1", "hand_2"] and item.has("display_name_shield"):
		return item["display_name_shield"]
	return item.get("display_name", grade)

static func get_category(grade: String) -> String:
	return _lookup(grade).get("category", "")

static func is_weapon(grade: String) -> bool:
	return get_category(grade) == "weapon"

static func is_armor(grade: String) -> bool:
	return get_category(grade) == "armor"
