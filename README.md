# Medieval World Evolution – 2.5D 中世紀社會演化原型

## 專案定位

這是一個以「資訊不對稱、社會互動、世界自行演化」為核心的 Godot 4.x 原型。

目前狀態對齊 [docs/project-goals.md](docs/project-goals.md)：
- 第一階段（Vertical Slice）已完成
- 第二階段（Demo）已完成部分核心系統（NPC 個體化、記憶、傳聞失真、聚落需求循環）

核心設計方向請見 [docs/game-design.md](docs/game-design.md)。

---

## 目前已實作內容

### 1) 時間與地圖
- 六角格大地圖（2.5D 顯示）
- 半即時/回合制可切換
- 統一世界時間推進（玩家在回合制移動一格會推進時間）
- 相機縮放（鍵盤 + 滑鼠滾輪）

### 2) 世界演化（聚合模擬）
- 勢力每回合進行資源收集、人口變化、擴張、衝突
- 聚落需求欄位：safety、labor、unrest_turns、is_armed_group
- 治安不足會累積動盪，觸發社會崩潰事件（流民化/兵變/叛亂）

### 3) 資訊傳播與主觀認知
- 事件訊息延遲傳播（信使、商旅、流民、隊友）
- 傳播途中會依 carrier 與訊息強度失真
- UI 顯示主觀描述（可靠/傳聞/可疑），不是客觀全知資訊

### 4) 玩家與遭遇戰
- 玩家可生成並在六角格移動
- 可與據點互動查看勢力資訊與訊息
- 可觸發基礎遭遇戰流程
- 玩家死亡後支援接手 NPC 繼續遊玩（原型版）

### 5) NPC 個體化與記憶
- 深度互動後可生成 NPC 檔案（身份、性格、目標、技能）
- 記憶有強度（輕微/深刻/刻骨）與衰減
- 已建立關係資料結構與調整介面（trust/affinity/fear/loyalty）

---

## 操作按鍵（目前版本）

| 按鍵 | 功能 |
|---|---|
| T | 切換半即時 / 回合制 |
| PageUp / PageDown / 滑鼠滾輪 | 地圖縮放 |
| Space | 推進回合 |
| + / - | 調整每次推進回合數 |
| P | 暫停 / 繼續時間 |
| [ / ] | 調整每回合秒數 |
| B | 嘗試觸發遭遇戰 |
| Enter | 生成玩家 |
| 數字鍵盤 7 / 9 / 4 / 6 / 1 / 3 | 六角方向移動（主要） |
| A / D + Q / R / Z / X | 六角方向移動（相容） |
| E | 互動 / 查看據點資訊 |

---

## 執行方式

### 方式 A：Godot 編輯器
1. 安裝 Godot 4.2+
2. Import 專案中的 project.godot
3. 按 F5 執行

### 方式 B：命令列（可用於快速驗證）
在專案根目錄執行：

Godot_v4.2.2-stable_win64_console.exe --path . --quit --verbose

說明：
- headless 模式可能出現 Dummy Renderer 的 mesh_get_surface_count 訊息，這通常不是 GDScript 語法錯誤。

---

## 主要程式模組

- scripts/main.gd：主流程與系統串接（世界、時間、戰鬥、玩家）
- scripts/world_state.gd：世界資料容器（Cell/Faction/Outpost）
- scripts/world_generator.gd：地圖與初始勢力生成
- scripts/faction_system.gd：每回合勢力演化與聚落需求/崩潰
- scripts/message_system.gd：延遲傳播、失真、主觀訊息顯示
- scripts/npc_memory.gd：NPC 個體化、記憶、關係
- scripts/player_controller.gd：玩家六角格移動
- scripts/ui_controller.gd：HUD 與互動資訊面板

---

## 文件索引

- 核心設計與目標
  - [docs/game-design.md](docs/game-design.md)：核心玩法、世界觀、時間尺度與設計不變量。
  - [docs/project-goals.md](docs/project-goals.md)：四階段開發目標、目前進度與中長期範圍。
  - [docs/open-questions.md](docs/open-questions.md)：待討論議題、決策追蹤與高優先反饋。

- 協作與交付規範
  - [docs/coding-standards.md](docs/coding-standards.md)：程式風格、命名規則與檔案責任邊界。
  - [docs/delivery-standards.md](docs/delivery-standards.md)：交付驗收標準與文件同步要求。
  - [docs/change-management.md](docs/change-management.md)：小型修正、功能變更與架構調整流程。
  - [docs/roles.md](docs/roles.md)：Human / AI Agent 角色分工與可動作範圍。

- 世界模型與規則拆解
  - [docs/person.md](docs/person.md)：人物層、代表角色與未來 NPC 擴充方向。
  - [docs/world.md](docs/world.md)：世界狀態、資源流、時間推進與勢力成長。
  - [docs/event.md](docs/event.md)：事件觸發、結算流程與事件分層。
  - [docs/message.md](docs/message.md)：訊息產生、傳播、失真與玩家接收流程。

- 補充參考
  - [docs/glossary.md](docs/glossary.md)：專案術語與常用定義。

## Agent / Contributor 閱讀順序

1. 先讀本 README，掌握專案定位、目前已實作內容、操作方式與文件地圖。
2. 再讀 [docs/game-design.md](docs/game-design.md) 與 [docs/project-goals.md](docs/project-goals.md)，確認核心設計方向與階段目標。
3. 開始實作、調整設計或整理文件時，隨時查閱 [docs/open-questions.md](docs/open-questions.md)，避免與未定案事項衝突。
4. 實作前後都要遵守 [docs/coding-standards.md](docs/coding-standards.md)、[docs/delivery-standards.md](docs/delivery-standards.md) 與 [docs/change-management.md](docs/change-management.md)。

---

## 注意事項

- .godot/ 與 tools/godot/*.exe 已加入 .gitignore，避免提交大型快取與本機執行檔。
- 目前是系統原型階段，數值平衡與內容量仍會持續調整。
