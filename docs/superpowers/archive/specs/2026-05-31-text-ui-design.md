# Text UI Design Spec

**Date:** 2026-05-31
**Status:** Approved → Awaiting Plan

---

## 目標

用純文字 UI 取代現有圖形化 UI，作為主要遊玩介面。模擬邏輯不動，只換前端。

---

## 同時修正：座標全正數化

**問題：** 目前地圖中心 (0,0)，tile 座標含負數 → 已知多個 bug 根源。

**修正：** `world_generator.gd` 建圖時中心改為 `(radius, radius)`，所有 tile 座標 ≥ 0。

| 模式 | 中心 | 範圍 |
|---|---|---|
| 原本 | (0,0) | (-4,-4) ~ (4,4) |
| 修正後 | (4,4) | (0,0) ~ (8,8) |

影響範圍：`world_generator.gd`（建圖）、`headless_test.gd`（初始化 tile_pos）、其他 tile_pos 引用。

---

## 場景架構

### 新檔案

| 檔案 | 職責 |
|---|---|
| `scenes/TextUI.tscn` | 新主場景 |
| `scripts/ui/text_ui_main.gd` | 主控制器：鍵盤輸入、tick 推進、UI 組合 |
| `scripts/ui/text_map_renderer.gd` | 地圖字串生成（純函數，headless 可測） |

### 修改檔案

| 檔案 | 改動 |
|---|---|
| `project.godot` | 主場景改為 `scenes/TextUI.tscn` |
| `scripts/simulation/world_generator.gd` | 中心座標偏移至 `(radius, radius)` |
| `scripts/debug/headless_test.gd` | tile_pos 初始化改為正座標 |

### 保留不動

`scripts/simulation/` 全部系統、`scripts/data/` 所有資料結構、`SimBridge`——不動。

---

## 場景佈局

```
┌─────────────────────────────────────┬──────────────────────┐
│ 地圖區（RichTextLabel, 等寬字體）    │ 狀態區（Label）       │
│                                     │ Team0@ (4,4)          │
│  ·  ·  ·  ·  ·  ·  ·  ·  ·         │ 人口:10 受傷:0         │
│   ·  ·  ·  ·  ·  ·  ·  ·           │ 食:4850 幣:190         │
│  ·  · F  ·  @  ·  ·  ·  ·          │ 任務:harvest           │
│   ·  ·  ·  · [1] ·  ·  ·           │ ──────────────         │
│  ·  ·  ·  ·  ·  M  ·  ·  ·         │ 選中: (3,4) 平原       │
│   ·  ·  ·  ·  ·  ·  ·  ·           │ 速:×1.0 農:80%         │
│  ·  ·  ·  ·  ·  ·  ·  ·  ·         │ 食:200 材:0            │
├─────────────────────────────────────┴──────────────────────┤
│ 事件 log（Label, 最近 6 條）                                │
│ [T48] Team1 採集食物 +15  [T47] Team0 移動至 (4,4)         │
├─────────────────────────────────────────────────────────────┤
│ [WASD]游標  [Enter]選中  [M]移動  [Space]+1天  [H]回玩家   │
│ [P]成員  [I]物品  [Q]離開                                   │
└─────────────────────────────────────────────────────────────┘
```

Godot 節點：

```
TextUI (Node)
├── HBox (HBoxContainer)
│   ├── MapLabel (RichTextLabel)  ← 地圖字串
│   └── StateLabel (Label)        ← 狀態字串
├── EventLabel (Label)            ← 事件 log
└── HintLabel (Label)             ← 按鍵提示（固定文字）
```

---

## 地圖渲染

### 格式

`text_map_renderer.gd` 提供純函數：

```gdscript
static func render(state: WorldState, player_tid: int, cursor: Vector2i) -> String
```

回傳多行字串，直接填入 `RichTextLabel.text`。

### 格子格式（3 chars）

| 狀態 | 格式 | 說明 |
|---|---|---|
| 玩家位置 | `@` | 單字元，中心 |
| 已知 team | `0`~`9` | team_id 最後一位 |
| 視野內空格 | terrain 字母 | `P`=plains `F`=forest `M`=mountain |
| 探索過/視野外 | `p` `f` `m` | 小寫 |
| 未探索（迷霧） | `?` | |
| 無效格（不在地圖） | ` ` | 空白 |
| 游標 | `[X]` | 括號包住格子內容 |

### 奇偶列錯位（hex stagger）

奇數列（col % 2 == 1）視覺上在偶數列之間，以每行前導空格模擬：

```
 0  1  2  3  4  5  6  7  8    ← 偶數列
   0  1  2  3  4  5  6  7  8  ← 奇數列（縮排 1 格）
```

具體：`render()` 先按 col 分組，col 為奇數則在行前加空格偏移。實際輸出按 row 掃描，非 col。

正確做法：對每個 row，先輸出 col=0,2,4,6,8 的格子（一行），再輸出 col=1,3,5,7 的格子（縮排一行）。這樣視覺上模擬 hex 的奇偶交錯。

---

## 狀態區

`text_ui_main.gd` 的 `_build_state_str() -> String`：

```
Team0 @ (4,4) [獨立]
任務: harvest  疲勞: 5%
人口: 10 | 受傷: 0 | 未成年: 2
────────────────
玩家: P0 HP:正常 忠誠:80%
技能: 統領:0.50 生產:0.30
────────────────
資源:
  食:4850 幣:190 材:100
  低武:5 低甲:2 藥:5
────────────────
選中: (3,4) 平原
  速:×1.0  農:80%
  資源: 食:200
  Team1 [勢力0] 人口:8
```

---

## 控制方案

| 按鍵 | 動作 |
|---|---|
| `W`/`A`/`S`/`D` | 移動游標 |
| `Enter` | 選中游標格（更新狀態區） |
| `M` | 設定移動目標到游標位置（驗證 tile 存在） |
| `Space` | 推進 24 tick（1 天） |
| `H` | 游標跳到玩家位置 |
| `P` | 顯示成員清單（在狀態區展開） |
| `Q` | 離開遊戲 |

**不用滑鼠、不用按鈕。**

---

## 事件 Log

- 最多保留最近 100 條事件訊息（`Array[String]`）
- 顯示最後 6 條
- 每次 tick 推進後 append（從 `_bridge.advance_tick()` 的 events array 取）

---

## 驗證標準

**Headless 可驗：**
```gdscript
# text_map_renderer.gd 純函數可在 headless_test 呼叫
var map_str := TextMapRenderer.render(state, 0, Vector2i(4,4))
assert(map_str.contains("@"))       # 玩家顯示
assert(map_str.contains("?"))       # 迷霧存在
assert(map_str.length() > 100)      # 非空
```

**目測確認（需開遊戲）：**
- 開遊戲看到地圖（非黑畫面）
- WASD 游標移動正確
- Space 推進後事件 log 更新
- M 鍵設定移動目標後 team 開始移動
- 迷霧格顯示 `?`

---

## 不在此次範圍

- 舊圖形 UI 不刪除（只不載入）
- 成員 popup → 改在狀態區展開（簡化版）
- 物品系統 UI（`I` 鍵暫時無效）
- 多行事件詳細內容（只顯示 type + 數字摘要）
