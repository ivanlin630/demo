# 訊息

這份文件專講「訊息怎麼產生、怎麼傳、怎麼失真、怎麼被玩家接收」。

## 1) 目前訊息系統現況

現在已經有三層：

- 世界真相：`global_messages`
- 勢力/據點已知：`known_messages`
- 玩家個人已知：`player_known_messages`

## 2) 訊息流程

1. 事件觸發後呼叫 `emit_message()`
2. 先寫進 `global_messages`
3. 寫入事發團體或記名NPC內的 `known_messages`
4. 如果跟其他實體單位接觸後判斷是否交換 `known_messages`與是否失真加權
5. 玩家按 E 接觸團體或記名NPC時，複製該單位已知訊息到個人日誌

## 3) 目前訊息資料欄位

主要在 [scripts/message_system.gd](../scripts/message_system.gd)：

- `MessageData.type`
- `MessageData.description`
- `MessageData.source_pos`
- `MessageData.faction_id`
- `MessageData.origin_turn`
- `MessageData.strength`
- `MessageData.received_turn`
- `PendingDelivery.target_outpost_idx`
- `PendingDelivery.arrive_turn`
- `PendingDelivery.carrier`
- `PendingDelivery.payload`

## 4) 你要改哪些地方

### 傳播規則

主要改 [scripts/message_system.gd](../scripts/message_system.gd)：

舊的code邏輯

### 玩家接收

主要改 [scripts/main.gd](../scripts/main.gd)：

舊的code邏輯

### 顯示介面

主要改 [scripts/ui_controller.gd](../scripts/ui_controller.gd)：

- 顯示最近世界訊息
- 顯示玩家已接收訊息
- 顯示 debug 面板中的 pending queue

## 5) 訊息分類建議

如果要把系統再整理，可以分成：

- public：據點可同步的公開情報
- sensitive：需要接觸人物才知道的敏感情報
- rumor：可能失真的流言
- truth：世界內部真實事件記錄

## 6) 這份文件和其他分類的關係

- 事件來源：看 [事件](event.md)
- 世界資源觸發的消息：看 [世界](world.md)
- 人物接觸與認知：看 [人物](person.md)
