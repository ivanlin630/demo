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
var tile_id: int                              # pos.x * 1000 + pos.y
var resources: Dictionary                     # { "food", "wood", "ore", "special" }
var productivity: float                       # 生產力乘數
var occupied_by: int                          # team_id 或 -1
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
food_gain = tile.productivity × tile.resources["food"] × 0.01
team.resources["food"] += food_gain
```

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

## 未來擴充

- 地形乘數（影響移動 Tick 成本與生產力）
- 據點升級（農業型 / 軍事型 / 貿易型）
- 世界生成（隨機 tile 分佈與資源）
