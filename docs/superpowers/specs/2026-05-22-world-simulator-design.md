# 世界模擬器設計規格

**日期**：2026-05-22  
**範圍**：世界模擬器核心（不含玩家系統）

---

## Context

遊戲核心是資訊不透明的社會模擬。玩家不是全知者，世界持續運行。
目標是先建立可獨立運作的世界模擬器，玩家系統之後疊上去。

所有舊 scripts 已刪除，從零開始設計。

---

## 建構策略：B + C

**Phase 1：資料結構層**  
定義所有 GDScript class，無邏輯，只有欄位與型別。

**Phase 2：純模擬邏輯層**  
在資料結構上疊 Tick loop 與各系統邏輯。debug output 驗證，不做 UI / 渲染。

---

## 地圖系統

- 大地圖 + 遭遇戰地圖，皆用正六邊形格
- Team 在大地圖 = 單一格棋子
- Team 在遭遇戰 = 成員展開至各格
- 兩張地圖共用同一時間系統，無場景切換凍結

---

## 時間系統

- **Tick**：最小時間單位（= 10 秒遊戲時間）
- **Turn**：= N Tick（可配置）
- 每 Tick 執行完整世界更新循環
- 遭遇戰期間大地圖繼續推進

### Tick 循環（每 Tick 執行）

```
① Tick 推進（時間 +1）
② 資源收集（據點 → Team 資源庫）
③ 消耗結算（糧食 / 安全 / 勞力 → 需求缺口 → 壓力）
④ 人物反應（壓力 → NPC 評估 → 輸出反應）
⑤ 事件生成（NPC 反應彙總 → Team/Faction 事件）
⑥ 訊息發射（事件 → global_messages → 傳播）
⑦ 玩家輸入（預留介面，世界模擬器階段跳過）
```

### LOD 分區模擬

- **近區**（大地圖固定半徑內）：每 Tick 完整執行 ①–⑥
- **遠區**（半徑外）：每 N Tick 執行一次，跳過 ④ 人物反應，只算資源 / 人口 / 事件聚合
- 遭遇戰地圖：場上所有單位全精度模擬

---

## 資料結構

### World（世界）

```gdscript
# 世界由六角格 Tile 組成
Tile:
  tile_id: int
  resources: { food, wood, ore, special }
  productivity: float
  occupied_by: int  # team_id or -1
  has_outpost: bool

World:
  tiles: Dictionary  # tile_id → Tile
  current_tick: int
  current_turn: int
```

### Team（團體）

```gdscript
Team:
  team_id: int
  leader_id: int          # Person id（記名 NPC）
  advisors: Array[int]    # Person id[]
  members: Array[int]     # 非記名 NPC id[]
  population: int         # 成人人口，上限 50，最小 1
  minor_population: int   # 未成年，不計入上限，上限 = population × 20%
  resources: { food, material, weapon, money, goods }
  move_speed: float
  tags: Array[String]     # 生產 / 製造 / 貿易 / 掠奪 / 保衛 / 統領
  current_task: String    # 生產 / 製造 / 貿易 / 掠奪 / 攻擊 / 巡邏 / 閒晃
  unrest_turns: int
  faction_id: int         # -1 = 獨立
```

### Person（人物，記名 NPC）

```gdscript
Person:
  id: int
  name: String
  role: String            # leader / advisor / civilian / guard
  team_id: int
  age: int                # 決定 minor → adult 轉換

  # 狀態（獨立追蹤）
  needs: { food: float, safety: float, belonging: float }
  stress: float           # 0.0–1.0
  fear: float             # 0.0–1.0
  loyalty: float          # 0.0–1.0

  # 決策輸入
  goals: Array[String]    # 長期目標，效用函數輸入

  # 記憶（Phase A）
  memory: Array[{ event_id: int, intensity: String }]
  # intensity: "minor" / "significant" / "traumatic"
  # Phase B（關係記憶）預留介面
```

### Message（訊息）

```gdscript
Message:
  id: int
  type: String
  description: String
  source_pos: Vector2i
  origin_team_id: int
  origin_tick: int
  strength: float         # 0.0–1.0（可信度 × 新鮮度）
  is_distorted: bool

# 三層訊息池
global_messages: Array[Message]      # 世界真相
team_known: Dict[team_id → Array]    # Team / 據點已知
player_known: Array[Message]         # 玩家已知（預留）
```

---

## 訊息系統規則

| 規則 | 設計 |
|---|---|
| 傳播 | 實體接觸才能交換，需要明確行動 |
| 熵增失真 | `strength -= hop_decay × time_aging`（每次傳遞 + 時間老化疊加） |
| NPC 人為失真 | 依 NPC `loyalty` / 性格屬性，自動計算扭曲機率 |
| 玩家人為失真 | 玩家主動干預時可選擇扭曲（預留介面） |
| 玩家接收 | 必須與實體互動才能同步訊息（預留） |

---

## NPC 人物反應

Person 每 Tick（近區）：
1. 從 Team 資源狀況取得壓力輸入
2. 以 `stress + fear + loyalty + goals` 效用函數評估
3. 輸出一個反應（或維持現狀）
4. 重大事件寫入 memory

### 反應清單（初版）

| | 代號 | 名稱 | 觸發傾向 |
|---|---|---|---|
| 正 | P1 | 服從 | 低壓力，高忠誠 |
| 正 | P2 | 增產 | 資源充足，穩定 |
| 正 | P3 | 招募 | 人口有空間，穩定 |
| 正 | P4 | 擴張 | 資源充足，leader 目標 |
| 正 | P5 | 繁殖 | 安全穩定，食物充足 |
| 負 | N1 | 逃亡 | 高壓力，低忠誠 |
| 負 | N2 | 暴動 | 高壓力，高恐懼 |
| 負 | N3 | 叛變 | 高壓力，外部吸引 |
| 負 | N4 | 怠工 | 中壓力，低忠誠 |
| 負 | N5 | 勒索 | 中高壓力，高膽量 |

---

## Team 決策

Team 每 Turn 用**效用函數**選任務：

```
score(task) = base_score(task, tags)
            + resource_weight(task, resources)
            + leader_goal_weight(task, leader.goals)
            + advisor_modifier(task, advisors)
```

取最高分任務執行。新增任務 = 新增一個評分函數，不改核心邏輯。

---

## 事件生成

⏸ **待定**：事件彙總邏輯（計數門檻 / 加權比例 / 嚴重度累積）待 Team + Person 實作完成後，根據實際數據決定。

---

## 玩家系統

⏸ **預留介面**：世界模擬器完成後疊加，不影響核心模擬邏輯。

---

## 驗證方式

Phase 1（資料結構）：
- GDScript class 可實例化，欄位型別正確
- 1 World + 3 Team + 9 Person（每 Team 3個）可序列化印出

Phase 2（模擬邏輯）：
- 跑 100 Tick，debug output 顯示每 Tick 的資源變化
- Team 資源不足 → Person stress 上升 → 出現負面反應
- 訊息從事件產生 → 存入 global_messages → 傳播到鄰近 Team
- 遠區 Team 每 N Tick 才更新一次（log 可驗證）
