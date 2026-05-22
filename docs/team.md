# 團體 (Team)

## 相關文件
- [核心概念](game-design.md)
- [人物](person.md)
- [世界](world.md)
- [事件](event.md)

---

## 定義

地圖上的棋子單位。由記名 NPC（leader + advisors）帶領，代表一群人的集體行動。

---

## 資料結構

定義於 `scripts/data/team_data.gd`：

```gdscript
var team_id: int
var leader_id: int          # 記名 NPC id
var advisors: Array         # 記名 NPC id[]（前任領袖降職後加入）
var members: Array          # 非記名 NPC id[]

var population: int         # 成人人口，上限 50，最小 1
var minor_population: int   # 未成年人口，上限 = population × 20%，不計入上限

var resources: Dictionary   # { "food", "material", "weapon", "money", "goods" }
var move_speed: float       # 移動速度，影響每格耗 Tick 數

var tags: Array             # 職責標籤：["生產", "製造", "貿易", "掠奪", "保衛", "統領"]
var current_task: String    # "idle" / "生產" / "製造" / "貿易" / "掠奪" / "攻擊" / "巡邏"

var unrest_turns: int       # 不滿積累值
var faction_id: int         # 所屬勢力，-1 = 獨立
var tile_pos: Vector2i      # 當前大地圖格座標
```

---

## 人口規則

- 成人上限：50
- 成人最小：1（不會因消耗或逃跑歸零）
- 未成年人口：上限為 `population × 0.2`，不計入 50 人上限
- 未成年轉成人：由年齡系統驅動（未來實作）

---

## 不滿（unrest_turns）

| 來源 | 變化 |
|---|---|
| N2_riot（暴動反應） | +1 |
| P4_expand（擴張反應） | -1 |
| 事件：替換領袖 | -20 |
| 事件：Team 分裂 | 歸零 |

門檻：
- `>= 20`：觸發領袖替換事件（若有統領 >= 0.3 的異見者）
- `>= 30`：觸發分裂事件（若異見者 義氣 < 0.4 且目標衝突）

---

## 標籤（tags）對反應的影響

| 標籤 | 影響 |
|---|---|
| "生產" | P2_produce 基礎分數啟用（0.6 vs 0.1） |
| "統領" | P4_expand 基礎分數啟用（0.55 vs 0.05） |

---

## 資源收集條件

- 所在格 `has_outpost == true`
- 每 Tick 收取：`tile.productivity × tile.resources["food"] × 0.01`

---

## 與勢力關係

- 有 `"統領"` 標籤的 Team 可成為勢力核心
- `faction_id == -1` → 獨立 Team
- 勢力支配需外交或武力（未來實作）

---

## 未來擴充

- 移動 AI（目標格、行軍、追擊）
- 移動速度受地形、負重、疲勞修正
- Team 間外交（結盟、臣服、宣戰）
- 任務系統（current_task 實際影響行為）
