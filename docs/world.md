# 世界 (World)

## 相關文件
- [核心概念](game-design.md)
- [團體](team.md)
- [人物](person.md)
- [事件](event.md)

---

## 資料結構

### HexTileData（`scripts/data/tile_data.gd`）

```gdscript
var tile_id: int       # pos.x * 1000 + pos.y
var terrain: String    # "plains" / "forest" / "mountain"
var resources: Dictionary  # 任意 string key（見資源 Key 命名規範）
var productivity: float    # 生產力乘數（依地形而異）
var occupied_by: int       # team_id 或 -1
var has_outpost: bool
```

### WorldData（`scripts/data/world_data.gd`）

```gdscript
var tiles: Dictionary      # tile_id → HexTileData
var current_tick: int
var current_turn: int      # 每 6 Tick 推進 1 Turn
```

### WorldState（`scripts/data/world_state.gd`）

```gdscript
# ── 時間常數 ──
const TICKS_PER_DAY    = 240      # 10 ticks/hour
const TICKS_PER_MONTH  = 7200     # 30 天
const TICKS_PER_SEASON = 21600    # 90 天
const TICKS_PER_YEAR   = 86400    # 360 天

# ── 核心資料 ──
var world: WorldData
var teams: Dictionary            # team_id → TeamData
var persons: Dictionary          # person_id → PersonData
var factions: Dictionary         # faction_id → FactionData
var global_messages: Array       # 世界真相訊息
var team_known: Dictionary       # team_id → Array[MessageData]
var team_discovered: Dictionary  # team_id → Array[int]（已知 team_id）
var team_intel: Dictionary       # obs_id → { tgt_id → { tier, pop_est, tile_pos, ... } }

# ── 玩家狀態 ──
var player_id: int = -1
var player_state: Dictionary = {}           # 任意 key-value（pending_trade_target 等）
var player_hostile_teams: Array = []        # Array[int] 對玩家敵意的 team_ids
var player_pending_targets: Array = []      # 同格可互動的 NPC team_ids
var player_forced_event: Dictionary = {}    # NPC 強制互動（diplomacy/extort）；空=無
var player_forced_event_id: String = ""     # 對應事件的唯一 ID（str(randi())）

# ── 遭遇戰臨時狀態 ──
var encounter_active: bool = false
var encounter_units: Array = []             # Array[Dictionary]
var encounter_attacker_id: int = -1
var encounter_defender_id: int = -1
var pursuit_edge_offset: int = 0
var encounter_tick: int = 0
var last_encounter_result: Dictionary = {}
# Format: { "winner_id": int, "loser_id": int, "loot_pool": Dictionary }
# 玩家取/棄戰利品後清空
```

**方法：**
- `create_faction(leader_team_id)` → 建立新勢力，回傳 faction_id
- `disband_faction(faction_id)` → 解散勢力，所有成員 faction_id → -1
- `snapshot_faction_member(team_id, tick)` → 寫入勢力成員快照（food/weapons/goods/pop/tile/task）

---

## 時間系統

- **Tick**：世界最小模擬單位
- **Turn**：每 6 Tick 推進 1 Turn
- Tick 由 `SimRunner.advance_tick()` 驅動

---

## LOD 分區模擬

定義於 `scripts/simulation/sim_runner.gd`：

| 區域 | 觸發條件 | 執行步驟 |
|---|---|---|
| 近區 | 距玩家 ≤ 3 格 | ①–⑥ 完整每 Tick |
| 遠區 | 距玩家 > 3 格 | ②③⑤⑥ 每 10 Tick 一次（跳過 NPC 反應） |

---

## Tick 循環（14 步驟）

定義於 `sim_runner.gd`。遭遇戰 active 期間跳過 ①–⑩ 直接跑 ⑪。

```
①  advance_time         → current_tick+1；每6Tick current_turn+1
①b update_vision        → VisionSystem.tick_discovery（近/遠區皆做）
②  collect_resources    → 有 outpost 的 Team 收取資源
③  resolve_consumption  → 消耗食物，更新 needs/stress/fear
④  harvest              → HarvestSystem 農業乘數更新（每6Tick）
⑤  movement             → MovementSystem 推進移動（日夜/地形/負重/疲勞）
⑥  interaction          → InteractionSystem 同格接觸（戰鬥/外交/勒索/貿易）
⑦  person_reactions     → 每NPC效用函數輸出反應（近區）
⑧  generate_events      → EventSystem 分裂/替換/脫隊
⑨  faction_ai           → FactionAISystem 目標評估/外交/戰略指派
⑩  population_overflow  → 人口溢出分裂（每10Tick）
⑪  encounter_round      → EncounterSystem 遭遇戰一回合（encounter_active 時）
⑫  salary               → SalarySystem 薪資結算（每TICKS_PER_MONTH）
⑬  emit_messages        → SimMessageSystem 訊息傳播
⑭  npc_cleanup          → NpcAiSystem.cleanup_goals 目標修剪
⑮  cleanup_extinct      → tick 末單點：滅團(pop≤0)路由遺財(守恆)+ erase（中途 erase 不安全）
```

> 註：飢餓致死於日邊界 `check_starvation_deaths`（blood≤0）；一般稅於採集(②)後自動撥公庫；滅團清除(⑮)延後到 tick 末避免多系統持 team_ids 快照崩潰。

---

## 資源系統

定義於 `scripts/simulation/resource_system.gd`。

### 資源收集

條件：所在格 `tile.outpost_level > 0`

```
# _collect_from_tile（resource_system:254-284）
labor_mult = LaborSystem.fill(tile, "gather:"+res) × LABOR_SCALE   # ★統一勞力池 need-gated；need=0→0 不採
for res in tile.resources:
    gain = tile.productivity × tile.resources[res] × COLLECT_RATE(0.05) × day_fraction
    gain × = outpost_mult × labor_mult × work_morale
    team.resources[res] += gain           # (ore/成品 → tile public_storage 公庫)
```

- **★勞力鏈（2026-08-03）**：`labor_mult` = 統一勞力池分配（共址 PRODUCE pop 按 need 加權比例，取代舊 `sqrt(pop/5)`）；**need-gated full-stop**。詳 [[team.md]] 採集 + 勞力池 HOW spec。
- **承載**：`current`(tile.resources[res] 隨採集遞減) × COLLECT_RATE + regen ＝生態承載真載體、勞力池不碰。
- 收集泛用化——tile 有哪些 key，team 就累積哪些（含稀有資源）。

### 資源消耗

```
food_needed = total_pop × FOOD_PER_PERSON_PER_DAY(0.8) × day_fraction   # resource_system:3,126
```

- 食物充足：扣除消耗，`needs["food"] = 1.0`
- 食物不足：清零，`needs["food"] = available / needed`

---

## 地圖格 ID 規則

`tile_id = pos.x × 1000 + pos.y`

六角距離公式：`(|dx| + |dx+dy| + |dy|) / 2`

---

## 據點功能

- 啟用資源收集
- 訊息同步節點（未來：進據點可同步 public 訊息）
- 傷患恢復點（未來）

---

---

## 資源 Key 命名規範

所有 resources Dictionary 使用任意 string key，命名慣例：

| Key 模式 | 說明 | 存在位置 |
|---|---|---|
| `"food"` | 糧食 | tile / team |
| `"material"` | 通用原料 | tile / team |
| `"ore_gold"` | 金礦 | tile / team |
| `"ore_silver"` | 銀礦 | tile / team |
| `"gem_*"` | 寶石類 | tile / team |
| `"coin"` | 實體鑄幣（未來） | team |
| `"credit_{fid}"` | 勢力 fid 信用幣（未來） | team |
| `"weapon"` | 武器（通用，未來細分） | team |
| `"goods"` | 貨物 | team |

---

## 地形系統

定義於 `scripts/simulation/world_generator.gd`。

| 地形 | food 範圍 | material 範圍 | productivity | 稀有資源 |
|---|---|---|---|---|
| plains | 80–250 | 10–50 | 0.9–1.3 | — |
| forest | 40–120 | 60–180 | 0.7–1.1 | — |
| mountain | 10–50 | 20–80 | 0.5–0.9 | ore_gold (12%)、ore_silver (25%) |

WorldGenerator.generate(state, { "radius": N, "seed": S }) 產生以 (0,0) 為中心、半徑 N 的 hex 地圖。

---

## 未來擴充

- 地形移動成本（mountain 移動較慢）
- 農作系統（outpost 升級後額外 food 產出，受天氣影響）
- 金本位：ore_gold → coin 鑄造
- 信用本位：立國號發行 credit_{faction_id}
- 據點升級（農業型 / 軍事型 / 貿易型）
