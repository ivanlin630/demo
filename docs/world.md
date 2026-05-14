# 世界

## 相關文件
- [README](../README.md)
- [核心概念](game-design.md)
- [待討論議題](open-questions.md)


這份文件專講「世界狀態、資源產出、消耗、時間、勢力成長」這些底層規則。

## 1) 目前世界現況

世界現在主要是以勢力為單位在運作。

每個勢力目前主要有：

- `population`
- `food`
- `wood`
- `ore`
- `military`
- `safety`
- `labor`
- `unrest_turns`


## 2) 世界資源怎麼流

主要在 [scripts/faction_system.gd](../scripts/faction_system.gd)：

1. 從領地格子收資源
2. 扣掉人口消耗的食物
3. 更新人口、軍力、安全、勞力
4. 根據結果影響事件與擴張

## 3) 現在的消耗規則

### 食物

- 每回合會依人口扣食物
- 核心公式在 `FOOD_PER_PERSON`

### 人口

- 食物夠：人口增長
- 食物不夠：人口下降
- 安全太低：額外人口流失

### 軍力

- 擴張與衝突都會消耗軍力
- 軍力不足會影響勢力安全與事件觸發

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

這會接到 [人物](person.md) 與 [事件](event.md)。

## 7) 現在該去哪個檔案改

- 世界資源與消耗：`faction_system.gd`
- 勢力狀態欄位：`world_state.gd`
- 數值門檻：`game_config.gd`
- 世界時間推進：`main.gd`
