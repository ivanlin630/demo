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
3. 依距離與衰減產生 `pending delivery`
4. 到站後寫入據點與勢力的 `known_messages`
5. 玩家按 E 接觸據點時，複製該勢力已知訊息到個人日誌

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

- `_schedule_deliveries()`：決定送去哪裡
- `_process_pending_deliveries()`：決定何時到站
- `_subjective_text()`：決定失真程度

### 玩家接收

主要改 [scripts/main.gd](../scripts/main.gd)：

- `_check_interact()`：接觸據點後把對方已知訊息寫進玩家日誌
- `get_player_visible_messages()`：玩家畫面顯示用

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
