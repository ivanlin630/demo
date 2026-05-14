# 人物

## 相關文件
- [README](../README.md)
- [核心概念](game-design.md)
- [待討論議題](open-questions.md)


這份文件專講「勢力內部的實體人物」：領主、守衛、平民代表，以及未來要往更細 NPC 模型擴充時該改哪裡。

## 1) 目前角色層現況

現在的遊戲還是以勢力為單位，人物資料很少。真正已經存在的角色感內容主要是：

- 玩家角色
- 據點接觸時生成的少量 NPC profile
- 勢力領袖的簡化代表

## 2) 你想要的角色架構

最小原型建議先做三類代表人物：

- 領主 / 首領：決策者
- 守衛 / 武裝代表：安全反應
- 平民代表：生存、逃亡、謠言、壓力反應

每個人物至少要有：

- `id`
- `name`
- `role`
- `faction_id`
- `stress`
- `fear`
- `loyalty`
- `memory`
- `needs`

## 3) 哪些檔案要改

### 資料結構

主要在 [scripts/world_state.gd](../scripts/world_state.gd)：

- 新增 `NpcEntityData` 或等價結構
- 在 `FactionData` 加 `representatives` 或 `members`
- 如果要記個人需求與狀態，欄位也先放這裡

### 生成人物

主要在 [scripts/world_generator.gd](../scripts/world_generator.gd)：

- 勢力建立時順便生成最小代表人物
- 先做 3 個代表，不要直接做完整人口池

### 人物驅動事件

主要在 [scripts/faction_system.gd](../scripts/faction_system.gd)：

- 第 2 階段讓人物根據需求做反應
- 把人物反應彙總成勢力事件

### 顯示與互動

主要在 [scripts/ui_controller.gd](../scripts/ui_controller.gd)：

- 據點面板顯示代表人物
- 顯示人物的情緒、忠誠、壓力、記憶摘要

## 4) 未來擴充方向

- 更細的群體角色
- 派系關係
- 個人記憶與社會記憶
- 人物接觸才同步情報

## 5) 這份文件和其他分類的關係

- 資源與消耗：看 [世界](world.md)
- 事件生成：看 [事件](event.md)
- 訊息傳播：看 [訊息](message.md)
