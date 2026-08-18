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
# ★settlement S2a：L0 營地階梯——獨立 flag，非 outpost_level=0（全樹 47 站把 level==0 當空 tile 哨兵）。
# L0=transient shelter：無倉/設施/領土/居民身分（outpost_level 保持 0）。camp_level 0=無、1=L0。
# camp_ticks_left：棄置衰敗計時（forage 時 reset=full、regenerate_tiles 每日遞減；<=0→camp_level=0 無廢墟）。
# ★兩欄皆納 state_fingerprint（determinism；同 construction_ticks_left 慣例）。
var camp_level: int = 0
var camp_ticks_left: int = 0
# ★資訊網 bootstrap-fix 界⑤：隱匿據點旗（一行前瞻 stub、現恆 false=公告名冊；名冊 fallback filter not outpost_hidden）。
# 對抗資訊戰層（parked）將來令首領設 true=秘密據點不上組織名冊。現不加功能。
var outpost_hidden: bool = false
var farming_level: int = 0          # 0–3，civilian only
var manufacturing_level: int = 0    # 0–3，civilian only
var stable_level: int = 0           # 0–3 馬廄（眷養 mounts，限平原）
var stable_progress: float = 0.0    # mount 產出小數累積（≥1 轉整數入 owner team）
# ★統一勞力池（labor pool，2026-08-03）：共址 PRODUCE pop 稀缺分配給採集/製造工位（size 在生產 matter）。
var labor_alloc: Dictionary = {}    # workstation_key(gather:<res>/mfg:<level_key>) → {demand,share,fill}；LaborSystem 每 cadence 重算
var labor_eval_next_tick: int = 0   # per-tile cadence gate（lazy-on-cadence rebalance）
# ★B idle-labor→建設：idle_employ_value 快取（NeedOracle 遞迴 tile-scan 昂貴→cadence-gate，單寫者=outpost owner；決策讀）。
var idle_employ_cached: float = 0.0  # 上次算的 idle_employ_value（owner 隊決策時算、存此）
var idle_employ_next_tick: int = 0   # per-tile cadence gate（同 LABOR_CADENCE；避每決策重算 NeedOracle 遞迴）
var apothecary_level: int = 0       # 0–3 藥坊（civilian；herb→medicine，B 期啟用）
var smelter_level: int = 0          # 0–3 冶煉廠（military；ore_iron→ore_steel）
var weaponsmith_level: int = 0      # 0–3 武器坊（military）
var armorsmith_level: int = 0       # 0–3 護甲坊（military）
var garrison: Array = []            # person_ids
var prisoners: Array = []           # person_ids

# 公庫 / 經濟
var public_storage: Dictionary = {}   # 公庫，所有 resource keys
# WS-2b：市集訂單看板（outpost tile 上的公開訂單登錄；隊抵達此 tile 才親讀得到 = firsthand honest）。
# entry = {order_id, kind, res, qty_remaining, origin_team, expire_tick}。
# 看板是發起隊 active_orders 的可見性鏡像，權威仍在 active_orders；過期/滿足須同步清。
var market_orders: Array = []
var abandoned_coin: float = 0.0       # 滅團遺財（無 outpost）
var mint_level: int = 0               # mint 設施等級
var predator_infamy: int = 0          # 掠食者致死計數（輕量 hook；持久惡獸實體屬任務系統）

# 建設進度
var construction_ticks_left: int = 0
var construction_team_id: int = -1
var construction_target: Dictionary = {}   # { action, type?, level? }
var construction_started_tick: int = -1        # 施工開始 tick（timeout 判定）
var construction_last_progress_tick: int = -1  # 最後實際進度 tick
