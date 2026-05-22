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
copy.strength = msg.strength × (1 - HOP_DECAY) × max(1 - age × TIME_DECAY_PER_TICK, 0.1)
```

強度 <= 0.05 的訊息不傳。

### 訊息生成（`emit_message`）

事件觸發時由各 event 直接呼叫：

```gdscript
SimMessageSystem.new().emit_message(state, type, description, team)
```

目前觸發點：
- `event_unrest_replace.gd`：替換成功 → type = `"replace"`
- `event_unrest_split.gd`：分裂成功 → type = `"split"`

### 自動傳播（`propagate_on_arrival`）

**event-driven**：只在 Team 實際移動到新格時觸發，不每 Tick 掃。

- 觸發條件：MovementSystem.process() 回傳的 arrived 列表
- 傳播範圍：**同格（tile_pos 完全相同）**，鄰格不傳
- 近區、遠區皆適用

流程：
1. 每個 arrived Team 掃描全部 Teams
2. 同格者雙向呼叫 `_exchange_one_way`
3. 去重：已持有相同 `msg.id` 的訊息跳過
4. 套用衰減後決定傳播模式

### 傳播模式（`_decide_propagation_mode`）

由 **發送方 leader** 的屬性機率抽樣：

| 模式 | 效果 | 影響權重 |
|---|---|---|
| `honest` | 原樣傳遞 | 義氣 × 0.6 + 慎重 × 0.3 - 計謀 × 0.2 |
| `unintentional` | 輕微扭曲，強度 × 0.8，可能位移 source_pos | stress × 0.4 + (1 - 慎重) × 0.2 |
| `malicious` | 嚴重扭曲，強度 × 0.5，竄改 origin_team_id 或 source_pos | 計謀 × 0.7 - 義氣 × 0.4 |
| `silent` | 不傳 | 慎重 × 0.3 + fear × 0.3 |

### 手動交換（`exchange_messages`）

保留供未來玩家手動觸發（按 E 接觸 NPC），不自動呼叫。

### 待處理佇列（`process_pending`）

每 Tick Step 8 呼叫，處理 `_pending` 佇列中的排程訊息（目前為 stub）。

---

## 設計規則

- 訊息只能靠**實體接觸**傳播（兩 Team **同格**，鄰格不傳）
- 傳播為 event-driven：只在 Team 抵達新格時觸發，不每 Tick 掃
- 失真模式由發送方 leader 的 `計謀 / 義氣 / 慎重 / stress / fear` 決定（4 種模式機率抽樣）
- 玩家必須與實體（NPC 或 Team）互動才能接收訊息
- 強度衰減 = hop 次數 + 時間老化（兩者都計）

---

## 訊息流程

```
事件觸發（event_unrest_split / event_unrest_replace）
  → emit_message()
    → 寫入 global_messages
    → 寫入 origin_team.team_known

Team 抵達新格（MovementSystem.process → arrived）
  → SimRunner._step3_propagate_messages(arrived, all_teams)
    → propagate_on_arrival()
      → 找同格 Teams → _exchange_one_way()
        → 去重 + 衰減 + 傳播模式抽樣 → 寫入 target.team_known

玩家接觸實體（未來）
  → exchange_messages() → 複製到 player_known
```

---

## 未來擴充

- **訊息分類**：public（據點可同步）/ sensitive（需人物接觸）/ rumor（自由失真）
- **Debug 視窗**：顯示訊息來源、carrier、強度、失真狀態、到達時間
- **玩家訊息日誌**：獨立 player_known，與 team_known 分離
