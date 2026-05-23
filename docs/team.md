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
var move_target: Vector2i   # 目標格，(-1,-1) = 不移動
var move_tick_acc: int      # 累積 Tick，達移動成本門檻才走一格

var tags: Array             # 職責標籤：["統領", "軍隊", "商隊", "生產", "宗教", "流亡", "子團"]
var current_task: String    # "idle" / "徵收" / "偵查" / "信使" / "攻擊" / "掠奪" / "外交" / "護衛" / "逃跑"
                            # （預留）"生產" / "製造" / "貿易" / "巡邏"

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

## 標籤（tags）

### 對個人反應的影響

| 標籤 | 影響 |
|---|---|
| "生產" | P2_produce 基礎分數啟用（0.6 vs 0.1） |
| "統領" | P4_expand 基礎分數啟用（0.55 vs 0.05） |

### 對 task 的權限（_tag_weight）

| 標籤 | 高權限 task（×1.0）| 有 tag 但無匹配（×0.0）| 無任何 tag（×0.5）|
|---|---|---|---|
| 統領 | 全部 | — | — |
| 軍隊 | 攻擊/掠奪/護衛/偵查/信使/徵收/巡邏 | 其餘 | — |
| 商隊 | 外交/信使/護衛/偵查/貿易 | 其餘 | — |
| 生產 | 信使/生產/製造 | 其餘 | — |
| 宗教 | 外交/信使 | 其餘 | — |
| 流亡 | idle/逃跑（硬封其餘） | 全部其餘 ×0.0 | — |
| 子團 | 全部（跟指令，不過濾） | — | — |

### tag 增減機制（EventTagShift）

| 條件 | 變化 |
|---|---|
| leader 好戰 > 0.7 且 野心 > 0.6 | +軍隊、-生產 |
| wounded / population > 0.5 | +流亡、-軍隊 |
| food/人 > 5 且 wounded=0 且 unrest < 5 | -流亡（恢復）|

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

## 移動系統

定義於 `scripts/simulation/movement_system.gd`。

- 每 Tick 累積 `move_tick_acc`，達 `move_tick_cost` 才走一格
- 移動成本：`clamp(round(10 / move_speed), 3, 30)`
- 路徑：greedy step（選最接近 move_target 的鄰格）
- 抵達：更新 `occupied_by`，**不**自動建立據點

## 未來擴充

- 移動 AI（自動設定 move_target，依目標/資源/威脅評估）
- A* 路徑（有障礙地形時替換 `_step_team` 內部）
- 移動速度受地形、負重、疲勞修正
- Team 間外交（結盟、臣服、宣戰）
- 任務系統（current_task 實際影響行為）
