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
var world: WorldData
var teams: Dictionary           # team_id → TeamData
var persons: Dictionary         # person_id → PersonData
var global_messages: Array      # 世界真相訊息
var team_known: Dictionary      # team_id → Array[MessageData]
```

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

## Tick 循環（6 步驟）

```
① advance_time     → current_tick +1，每 6 Tick current_turn +1
② collect_resources → 有 has_outpost 的 Team 收取糧食
③ resolve_consumption → 消耗糧食，更新人物需求
④ person_reactions → 每個 NPC 跑效用函數，輸出反應
⑤ generate_events  → EventSystem 處理分裂/替換等事件
⑥ emit_messages    → SimMessageSystem 處理待發訊息
```

---

## 資源系統

定義於 `scripts/simulation/resource_system.gd`。

### 資源收集

條件：`team.has_outpost == true`（透過 tile_id = pos.x × 1000 + pos.y 查詢）

```
for res in tile.resources:
    gain = tile.productivity × tile.resources[res] × 0.01
    team.resources[res] += gain
```

收集泛用化——tile 有哪些 key，team 就累積哪些 key（包含 ore_gold 等稀有資源）。

### 資源消耗

```
food_needed = (population + minor_population) × 0.1  # FOOD_PER_PERSON_PER_TICK
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
