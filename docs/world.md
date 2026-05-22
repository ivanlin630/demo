# 世界

## 相關文件
- [README](../README.md)
- [核心概念](game-design.md)
- [待討論議題](open-questions.md)


這份文件專講「世界狀態、資源產出、消耗、時間、勢力成長」這些底層規則。

# 世界 (World)

## 定義
- 世界由六角格圖塊組成
- 每個圖塊有基礎資源欄位（食物、木材、礦石、特殊資源）
- 團體建設據點並駐守執行任務後才能採集該格與鄰近格的資源

# 世界 (World)

## 圖塊結構
- `tile_id`
- `resources` (food, wood, ore, special)
- `productivity` (基礎生產力值)
- `occupied_by` (team_id 或 null)
- `has_outpost` (是否有據點,哪種據點)

## 資源啟用規則
1. **團體建設據點**：必須先在圖塊上建立據點 (`has_outpost = true`)。
2. **團體駐守任務**：團體需駐守並執行「生產」任務。
3. **資源啟用範圍**：據點所在格 + 鄰近格資源進入生產池。
4. **生產量公式**：move_tick_cost = clamp(round(base_move / team.move_speed × terrain_factor × load_factor), min_cost, max_cost)
5. **資源歸屬**：生產結果存入團體資源庫 (`team.resources`)，再由勢力或交易流動。
## 移動與時間
- 移動耗時公式：move_tick_cost = clamp(round(base_move / team.move_speed × terrain_factor × load_factor), min_cost, max_cost)
- 玩家移動將消耗 Tick，推進世界時間。

## 據點功能
- 據點可作為資源生產點。
- 據點可作為NPC團體傷患回復點
- 據點可同步NPC團體 public 訊息（接到 message.md）。
- 據點可作為事件觸發點。

## 未來擴充
- 據點升級：農業型、軍事型、貿易型。
- 據點影響範圍：鄰近格數量可依升級擴大。
- 據點防禦：保衛標籤團體駐守時提供。


勢力主要是以團體（Team）為單位在運作。
團體細節參照team.md

勢力目前主要有：
已宣稱圖塊範圍,供勢力團體判斷支配範圍以及外交

## 2) 世界資源怎麼流

主要在 [scripts/faction_system.gd](../scripts/faction_system.gd)：
這部分要改一改 以後資源留都會放在團體階級


## 4) 時間與世界推進

主要在 [scripts/main.gd](../scripts/main.gd)：

- `world_tick`：世界 tick
- `current_turn`：回合
- `_advance_world_ticks()`：Tick / Turn 換算
- `_advance_turns()`：每回合呼叫世界結算

## 5) 參數在哪裡改

主要在 [config/game_config.gd](../config/game_config.gd)：

- `FOOD_PER_PERSON`
- `GROWTH_RATE`
- `STARVATION_RATE`
- `SAFETY_FROM_MIL_RATIO`
- `SAFETY_MIN_THRESHOLD`
- `LABOR_FROM_POP_RATIO`
- `LABOR_MIN_THRESHOLD`
- `UNREST_POP_LOSS_RATE`
- `TURN_TO_TICK`
- `WORLD_SECONDS_PER_TICK`

## 6) 你未來想要的世界版

你後面想要的版本比較像：

- 世界產資源
- NPC 分配與消耗資源
- NPC 因資源壓力做出反應
- 反應再轉成事件

這會接到[團體](team.md) [人物](person.md) 與 [事件](event.md)。

## 7) 現在該去哪個檔案改

- 世界資源與消耗：`faction_system.gd`
- 勢力狀態欄位：`world_state.gd`
- 數值門檻：`game_config.gd`
- 世界時間推進：`main.gd`
