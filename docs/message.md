# 訊息 (Message)

## 相關文件
- [核心概念](game-design.md)
- [事件](event.md)
- [人物](person.md)

---

## 三層架構

| 層 | 欄位 | 說明 |
|---|---|---|
| 世界真相 | `WorldState.global_messages` | 所有事件的原始記錄，不失真 |
| 團體已知 | `WorldState.team_known[team_id]` | 該 Team 接收到的訊息（可失真） |
| 玩家已知 | `WorldState.team_known[player_team_id]` | 玩家角色持有的訊息（未來獨立） |

---

## 資料結構

定義於 `scripts/data/message_data.gd`：

```gdscript
var id: int
var type: String           # 事件類型（"unrest", "split", "famine" 等）
var description: String
var source_pos: Vector2i   # 事件發生位置
var origin_team_id: int
var origin_tick: int       # 產生時間
var strength: float        # 0.0–1.0，傳播強度
var is_distorted: bool     # 是否已被人為扭曲
```

---

## 訊息系統

定義於 `scripts/simulation/message_system.gd`（class_name SimMessageSystem）。

### 常數

```gdscript
HOP_DECAY = 0.15           # 每次 hop 強度衰減
TIME_DECAY_PER_TICK = 0.005 # 每 Tick 時間衰減
```

### 強度衰減公式

```
strength -= HOP_DECAY × hops + TIME_DECAY_PER_TICK × (current_tick - origin_tick)
```

### 訊息交換（`exchange_messages`）

**需要明確行動觸發**，不自動發生：

1. 複製訊息
2. 套用強度衰減（hop +1, time decay）
3. 人為失真：`if randf() > person.loyalty → is_distorted = true`
4. 強度 > 0 的訊息寫入目標 team_known

### 待處理佇列（`process_pending`）

每 Tick Step 6 呼叫，處理 `_pending` 佇列中的排程訊息。

---

## 設計規則

- 訊息只能靠**實體接觸**傳播（兩 Team 同格或相鄰格）
- 人為失真由 NPC loyalty 決定（loyalty 越低越容易扭曲）
- 玩家必須與實體（NPC 或 Team）互動才能接收訊息
- 強度衰減 = hop 次數 + 時間老化（兩者都計）

---

## 訊息流程

```
事件觸發（event_system）
  → 寫入 global_messages
  → 寫入 origin_team.team_known
  → 實體接觸時 exchange_messages()
    → 衰減 + 人為失真 → 寫入 target.team_known
  → 玩家接觸實體 → 複製到 player_known
```

---

## 未來擴充

- **訊息分類**：public（據點可同步）/ sensitive（需人物接觸）/ rumor（自由失真）
- **Debug 視窗**：顯示訊息來源、carrier、強度、失真狀態、到達時間
- **玩家訊息日誌**：獨立 player_known，與 team_known 分離
