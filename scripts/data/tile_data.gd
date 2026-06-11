class_name HexTileData

var tile_id: int = 0
var tile_pos: Vector2i = Vector2i.ZERO
var terrain: String = "plains"   # "plains" / "forest" / "mountain"
var resources: Dictionary = { "food": 0, "material": 0 }
var resource_cap: Dictionary = {}   # set by world_generator, never modified after gen
var harvest_factor: float = 1.0    # 0.1–2.0，every N ticks updated by HarvestSystem
var productivity: float = 1.0
var occupied_by: int = -1

# 據點
var outpost_type: String = ""       # "" | "civilian" | "military"
var outpost_level: int = 0          # 0=無, 1/2/3
var outpost_owner: int = -1         # team_id
var farming_level: int = 0          # 0–3，civilian only
var manufacturing_level: int = 0    # 0–3，civilian only
var stable_level: int = 0           # 0–3 馬廄（眷養 mounts，限平原）
var stable_progress: float = 0.0    # mount 產出小數累積（≥1 轉整數入 owner team）
var apothecary_level: int = 0       # 0–3 藥坊（civilian；herb→medicine，B 期啟用）
var smelter_level: int = 0          # 0–3 冶煉廠（military；ore_iron→ore_steel）
var weaponsmith_level: int = 0      # 0–3 武器坊（military）
var armorsmith_level: int = 0       # 0–3 護甲坊（military）
var garrison: Array = []            # person_ids
var prisoners: Array = []           # person_ids

# 公庫 / 經濟
var public_storage: Dictionary = {}   # 公庫，所有 resource keys
var abandoned_coin: float = 0.0       # 滅團遺財（無 outpost）
var mint_level: int = 0               # mint 設施等級

# 建設進度
var construction_ticks_left: int = 0
var construction_team_id: int = -1
var construction_target: Dictionary = {}   # { action, type?, level? }
