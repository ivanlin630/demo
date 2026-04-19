# Medieval World Evolution – 2.5D 中世紀求生世界演化

## 簡介

以 **Godot 4.x** 開發的回合制 2.5D 中世紀生存模擬遊戲垂直切片。
玩家可觀察由 seed 驅動的格子世界自行演化，或隨時加入其中自由探索。

---

## 技術規格

| 項目 | 說明 |
|---|---|
| 引擎 | Godot **4.2** 或更新版本 |
| 渲染 | Forward Plus 3D |
| 顯示方式 | 2.5D：3D 地形平面 + 2D Billboard 圖示（Label3D） |
| 平台 | PC 鍵盤 |

---

## 如何執行

1. 安裝 [Godot 4.2+](https://godotengine.org/download)（官方穩定版）
2. 在 Godot 編輯器中選 **Import** → 選取本專案的 `project.godot`
3. 按 **F5**（或工具列的 ▶ Run）即可執行
4. 若要修改地圖大小或 seed，編輯 `config/game_config.gd` 頂部的變數後重新執行

---

## 操作按鍵

| 按鍵 | 功能 |
|---|---|
| `Space` | 推進 N 回合（N 預設為 1） |
| `+` / `=` | 增加每次推進的回合數（最多 20） |
| `-` | 減少每次推進的回合數（最少 1） |
| `Enter` | 在地圖上生成玩家（第一次按下） |
| `W A S D` | 玩家移動（需先生成玩家） |
| `E` | 靠近據點時互動，在 HUD 顯示該勢力詳細資訊 |

---

## 主要資料結構

### `WorldState`（`scripts/world_state.gd`）

```text
WorldState
├── map_width:    int          # 地圖寬（格）
├── map_height:   int          # 地圖高（格）
├── seed_value:   int
├── current_turn: int
├── cells:        Array        # CellData[map_height × map_width]
├── factions:     Array        # FactionData[]
├── outposts:     Array        # OutpostData[]
└── global_messages: Array     # MessageData[]（全域日誌）

CellData
├── terrain:    int            # 0=水域 1=草地 2=森林 3=山地
├── food_res:   float
├── wood_res:   float
├── ore_res:    float
└── faction_id: int            # -1 = 無主

FactionData
├── id:           int
├── name:         String
├── color:        Color
├── population:   float
├── food:         float
├── wood:         float
├── ore:          float
├── military:     float
├── outpost_pos:  Vector2i
├── territory:    Array[Vector2i]
└── known_messages: Array[MessageData]

OutpostData
├── pos:             Vector2i
├── faction_id:      int
└── known_messages:  Array[MessageData]
```

### `MessageSystem.MessageData`（`scripts/message_system.gd`）

```text
MessageData
├── type:        String    # "war" | "famine" | "resource_found" | "expansion"
├── description: String    # 人類可讀描述
├── source_pos:  Vector2i  # 事件發生座標
├── faction_id:  int       # 發起勢力（-1 = 自然事件）
├── origin_turn: int       # 產生回合
└── strength:    float     # 0.0–1.0；隨距離與回合衰減
```

---

## 系統說明

### 世界生成
- 使用 `FastNoiseLite`（Perlin）根據 `seed_value` 生成高度圖
- 高度閾值決定地形：水域 / 草地 / 森林 / 山地
- 每種地形有不同的食物、木材、礦石產出（見 `config/game_config.gd`）
- 預設地圖 128×128，可在 `game_config.gd` 調整 `map_width` / `map_height`

### 勢力起始
- 生成 3–5 個勢力，各自佔有 3×3 初始領地
- 初始屬性（人口、食物、武力）隨機但受 seed 控制（可重現）

### 回合演化
每按一次 `Space` 推進 N 回合，每回合依序執行：
1. **資源收集**：統計領地產出；食物消耗 = 人口 × 0.5
2. **人口變化**：食物充足時成長 3%；饑荒時每回合損失 8%
3. **領土擴張**：武力足夠時向鄰近無主格子擴張
4. **衝突判定**：相鄰勢力有 25% 機率交戰，損失兵力/人口，輸方失去一格領地
5. **訊息衰減**：所有已知訊息強度每回合減少 0.12

### 訊息傳播
- 事件觸發（戰爭、饑荒、擴張）時立即向周圍 12 格半徑的據點擴散
- 訊息強度 = 1.0 − 距離 × 0.06
- 每個據點與勢力各自維護「已知訊息列表」

### 玩家
- 開局預設為觀察模式；按 `Enter` 在第一個據點附近生成玩家
- 玩家以 `WASD` 在地圖上自由移動
- 靠近據點 6 格內按 `E` 可查看該勢力的詳細數值與已知訊息

---

## 檔案結構

```
project.godot
main.tscn
config/
  game_config.gd      ← 全域設定（autoload 單例）
scripts/
  main.gd             ← 主場景腳本：場景建構、輸入、渲染協調
  world_state.gd      ← 世界資料容器（CellData / FactionData / OutpostData）
  world_generator.gd  ← Perlin 地形生成 + 勢力放置
  faction_system.gd   ← 每回合勢力更新（資源/人口/擴張/衝突）
  message_system.gd   ← 訊息產生、擴散、衰減（MessageData）
  player_controller.gd← 玩家移動
  ui_controller.gd    ← HUD 顯示（CanvasLayer）
```
