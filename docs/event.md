# 事件

## 相關文件
- [README](../README.md)
- [核心概念](game-design.md)
- [待討論議題](open-questions.md)


這份文件專講「事件怎麼被觸發、怎麼結算、怎麼從個體反應彙總成勢力事件」。

## 1) 目前事件現況

事件以團體狀態驅動為主，常見類型有：

- `famine`
- `unrest`
- `collapse`
- `expansion`
- `war`

## 2) 目前事件流程

1. 世界推進到新回合
2. 系統做資源、人口、安全、擴張、衝突結算
3. 符合條件時發出事件
4. 事件寫入訊息系統
5. 訊息再慢慢擴散到據點與玩家

## 3) 目前事件邏輯在哪裡改

主要在 [scripts/faction_system.gd](../scripts/faction_system.gd)：

- `_collect_resources()`：食物不足會引發饑荒事件
- `_update_needs()`：勞力 / 安全不足會引發動盪
- `_trigger_collapse()`：長期動盪後的崩潰結果
- `_try_expand()`：擴張事件
- `_resolve_conflicts()`：戰爭事件

## 4) 事件頻率與門檻在哪裡改

主要在 [config/game_config.gd](../config/game_config.gd)：

- `EVENT_FAMINE_COOLDOWN`
- `EVENT_LABOR_COOLDOWN`
- `EVENT_COLLAPSE_COOLDOWN`
- `EVENT_EXPANSION_COOLDOWN`
- `EVENT_WAR_COOLDOWN`
- `SAFETY_MIN_THRESHOLD`
- `LABOR_MIN_THRESHOLD`
- `UNREST_BANDIT_TURNS`

## 5) 你想要的目標版

你想要的不是「勢力數值到了就跳事件」，而是：

1. 先有資源與壓力
2. 再有人物反應
3. 再由人物反應產生事件
4. 最後才回寫成勢力層的結果

## 6) 事件結算建議分層

### Phase 1：生存需求

- 收資源
- 吃糧
- 更新安全與勞力

### Phase 2：實體反應

- 領主做決策
- 守衛反應
- 平民反應
- 彙總成事件候選

## 7) 這份文件和其他分類的關係

- 人物反應來源：看 [人物](person.md)
- 資源壓力來源：看 [世界](world.md)
- 事件如何變成訊息：看 [訊息](message.md)
