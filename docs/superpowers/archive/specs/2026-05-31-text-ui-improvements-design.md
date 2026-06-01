# Text UI Improvements Design Spec

**Date:** 2026-05-31
**Status:** Approved → Awaiting Plan

---

## 問題清單

1. **地圖形狀歪斜** — 渲染用 axial 座標的奇偶 x 分行，導致視覺呈平行四邊形而非六邊形
2. **游標越界** — WASD 可移出地圖外，渲染顯示空格但位置無意義
3. **跳過時間固定** — Space 只能跳 1 天（TICKS_PER_DAY ticks），無法自訂
4. **移動不自動推進** — 按 M 設目標後需手動 Space，不直覺
5. **狀態欄資訊不完整** — 缺玩家角色個人資料、武器/甲/藥資源、選中格的 team 資訊
6. **無 DEBUG 欄** — 開發除錯困難
7. **指令提示不完整** — 缺 G 鍵說明

---

## 1. 地圖渲染修正：Axial → Visual 座標轉換

### 問題根源

`text_map_renderer.gd` 目前對每個 y 行，把偶數 x 格放第一子行、奇數 x 格放第二子行。由於地圖使用 **axial 座標**，row y=0 的有效格只在 x=4..8（右半部），導致地圖整體向右傾斜（平行四邊形）。

### 解法：Axial → Display Column 轉換

每個 tile 在視覺上的「顯示欄」計算公式：

```
display_col = tile_pos.x + floor((tile_pos.y - mid_y) / 2.0)
```

其中 `mid_y = (ymin + ymax) / 2`（= 地圖中心行，通常是 radius = 4）。

**驗算（radius=4，中心 (4,4)）：**

| tile_pos | display_col | 說明 |
|---|---|---|
| (4, 0) | 4 + floor(-4/2) = 4-2 = **2** | 頂行中心 |
| (8, 0) | 8 + (-2) = **6** | 頂行右端 |
| (4, 4) | 4 + 0 = **4** | 地圖中心（玩家） |
| (0, 4) | 0 + 0 = **0** | 中間行左端 |
| (8, 4) | 8 + 0 = **8** | 中間行右端 |
| (4, 8) | 4 + floor(4/2) = 4+2 = **6** | 底行中心（對稱） |
| (0, 8) | 0 + 2 = **2** | 底行左端（對稱頂行右端） |

結果：每行的 display_col 以中心對稱，視覺呈正六邊形。

**注意 GDScript 整數除法**：`-3 / 2 = -1`（截斷，非向下），必須用：
```gdscript
int(floor(float(tile_pos.y - mid_y) / 2.0))
```

### 渲染演算法

1. 算每個 tile 的 display_col（上述公式）和 display_row（= tile_pos.y）
2. 建表：`grid[display_row][display_col] = tile`
3. 找 display_col 的 min/max
4. 對每個 display_row，輸出兩行：
   - 偶數 display_col（(dcol - dcol_min) % 2 == 0）→ 第一行（不縮排）
   - 奇數 display_col → 第二行（縮排 1 空格）
5. display_col 對應的 tile_pos：`tile_pos.x = dcol - int(floor((drow - mid_y) / 2.0))`，`tile_pos.y = drow`

---

## 2. 游標邊界限制

游標只能移到**地圖內存在的 tile**（`state.world.tiles` 有此 key）。

移動前驗證：
```gdscript
func _move_cursor(delta: Vector2i) -> void:
    var new_pos := _cursor + delta
    var key := new_pos.x * 1000 + new_pos.y
    if state.world.tiles.has(key):
        _cursor = new_pos
    _refresh()
```

若目標不在地圖：游標不動（無提示，靜默）。

---

## 3. G 鍵：自訂 Tick 跳過

**操作流程：**
```
按 G → InputBar 顯示 "跳過 tick 數: _" → 輸入數字 → Enter 執行 / Escape 取消
```

**實作方式：**
- `_input_mode: bool` 標誌，進入後攔截所有按鍵
- `_input_buffer: String` 累積輸入的數字字串
- 按 0-9：append 到 buffer（最多 6 位）
- 按 BackSpace：移除最後一位
- 按 Enter：`int(_input_buffer)` ticks，執行後退出 input mode
- 按 Escape：取消，退出 input mode
- InputBar Label 顯示當前輸入狀態

**驗證：**
- buffer 為空或 "0" → Enter 無效（不執行）
- 最大值：99999 ticks（約 4166 天，測試模式）

---

## 4. M 鍵：自動推進到達目的地

按 M 後：
1. 設 `player_team.move_target = cursor`
2. **立即進入自動推進**，每次推進 1 tick，檢查是否到達
3. 停止條件：`team.tile_pos == target` 或達到上限（1000 ticks = ~41 天）
4. 每推進 24 ticks（1 天）重繪一次 UI（讓使用者看到進度，避免完全凍結）
5. 推進結束後在 EventLog 顯示：「Team0 到達 (x,y)」或「移動逾時（已推進 N ticks）」

**注意：** `move_target = Vector2i(-1,-1)` 是「無目標」sentinel。到達後系統應自動清除（movement_system 負責），不需 UI 處理。

---

## 5. 右側狀態欄完善

目前缺：

**玩家角色資料（只顯示健康和技能）：**
```
────────────────
玩家: [name]  HP:[正常/輕傷/重傷]
  技能: 統領:[val] 戰鬥:[val] 求生:[val] ...（只列 >0.01 的）
```

健康判斷：遍歷 `p.body_parts`，有 severed/critical → 重傷，有 wounded → 輕傷，其餘 → 正常。

**完整資源：**
```
資源:
  食:[food] 幣:[coin] 材:[material]
  低武:[weapon_melee_low] 高武:[weapon_melee_high]
  低甲:[armor_low] 高甲:[armor_high]
  藥:[medicine] 工:[tools]
```

**選中格 team 資訊（若有 team 在此格且已發現）：**
```
選中: (x,y) [terrain]
  農:[productivity%]  食:[food]
  Team[id] [faction] 人口:[pop]
```

---

## 6. Debug 欄（最頂部）

位置：場景最頂部，一個 `Label`（ScrollContainer 可選）。

顯示格式：

```
[DEBUG] Tick:1234 Hour:10 Day:51 Month:1 Season:春
Teams: T0@(4,4)pop=10 idle | T1@(7,5)pop=8 harvest | T5@(1,4)pop=6 raid
Events(last10): [T1230]interaction T0→T5 | [T1210]salary T0 -15 | ...
Msgs(last10): [T1200]Team0←"同盟邀請" | ...
```

**資料來源：**
- Tick/Hour/Day/Month/Season：從 `state.world.current_tick` 計算，用 WorldState 常數
- Teams：遍歷 `state.teams.values()`，取 team_id、tile_pos、population、current_task
- Events（last 10）：`_events` array 最後 10 筆
- Messages（last 10）：`state.global_messages` 最後 10 筆

**Season 計算：**
```gdscript
var month := (tick / WorldState.TICKS_PER_MONTH) % 12
var season_names := ["春","春","春","夏","夏","夏","秋","秋","秋","冬","冬","冬"]
var season := season_names[month]
```

---

## 7. 場景結構更新

```
TextUI (Node)
└── VBox (VBoxContainer)  # anchor full screen
    ├── DebugBar (Label)               ← NEW：debug 資訊，最頂部
    ├── HBox (HBoxContainer)
    │   ├── MapLabel (Label)           ← 地圖（等寬字體）
    │   └── StateLabel (Label)         ← 狀態資訊
    ├── EventLabel (Label)             ← 事件 log（最近 6 條）
    ├── InputBar (Label)               ← NEW：G 鍵輸入提示行（平時空白）
    └── HintLabel (Label)              ← 按鍵提示（更新文字）
```

**HintLabel 更新文字：**
```
[WASD]游標 [Enter]選中 [M]移動(自動) [Space]+1天 [G]跳N tick [H]回玩家 [P]成員 [I]背包 [Q]離開
```

---

## 8. P 鍵：成員欄

按 P 切換「成員模式」，EventLabel 區域改顯示成員清單（按 P 或 Escape 關閉）。

```
── 成員 Team0 ──
[隊長] 玩家  裝備:weapon_melee_low  HP:正常
[成員] P0_1  裝備:空  HP:輕傷
[成員] P0_2  裝備:空  HP:正常
匿名人口: 7  武裝率: 30%
── [P/Esc] 關閉 ──
```

**資料來源：**
- `team.leader_id` + `team.named_members` → 依序顯示
- 裝備：`p.equipment["hand_1"].grade`（空則顯示「空」）
- HP：同第 5 節健康判斷
- 匿名人口：`team.population`；武裝率：(team 武器總數) / population

**實作：**
- `_member_mode: bool`
- 進入時 `_refresh()` 改呼叫 `_build_member_str()` 寫入 EventLabel
- 離開時恢復正常 EventLabel

---

## 9. I 鍵：背包

按 I 切換「背包模式」，EventLabel 區域改顯示裝備 + 背包（按 I 或 Escape 關閉）。

```
── 裝備 ──
  右手: weapon_melee_low  左手: 空
  頭:空 胸:空 右臂:空 左臂:空 右腿:空 左腿:空
── 背包 (2/6) ──
  [1] medicine × 2
  [2] armor_low × 1
── 從 Team 取出 ──
  [T1] weapon_melee_low: 5
  [T2] armor_low: 0（灰）
── [數字]選取 [E]裝備 [G]取出 [S]存入 [I/Esc]關閉 ──
```

**操作流程：**
- 按 1–9：選擇背包 slot 或 Team 取出項目（`_inv_selection: int`）
- 選背包物品後：
  - E → 裝備（`PlayerSystem.equip_item`，武器→hand_1，護甲→torso）
  - S → 存回 team（`PlayerSystem.deposit_to_team`）
- 選 Team 取出項目後：
  - G → 取出 1 個（`PlayerSystem.take_from_team`）
- I 或 Escape：關閉

**實作：**
- `_inv_mode: bool`、`_inv_selection: int`（-1 = 未選）
- 攔截 1-9、E、G、S、Escape 鍵（`_input_mode` 外另一個 mode flag）
- `_build_inv_str() -> String` 渲染背包畫面

---

## 10. 不在此次範圍

- Vision system 整合（explored 持久化）— 另立 spec
- SimBridge 事件系統整合（目前 _events 只有 UI log）— 另立 spec
- 多 team 初始化（目前只有玩家 team）— 另立 spec
- **命令**（玩家主動下令）— 另立 spec（與互動合併設計）
- **互動**（外交/交易/攻擊觸發）— 另立 spec（與命令合併設計）

---

## 11. 驗證標準（更新）

**Headless（map_render_test.gd）：**
```gdscript
# 地圖應呈六邊形：頂行和底行各 5 格，中間行 9 格
var lines := map_str.split("\n")
# 每兩行為一個 display_row，共 9×2 = 18 行（ymin=0 to ymax=8）
assert(lines.size() == 18)
# 玩家 "@" 應在中間某行（display_row=4 = 第 9 行）
var center_line: String = lines[8]  # display_row=4 even sub-line
assert(center_line.contains("@"))
```

**目測（開 Godot）：**
- 地圖呈六邊形（頂底小，中間大）
- 游標無法移出地圖外
- G → 輸入 "48" → Enter → 推進 48 ticks（2 天）
- M → 設目標 → 自動跑到達（EventLog 顯示到達訊息）
- Debug 欄顯示正確 Tick/Day 和 Team 資訊
- P → 顯示成員清單，Esc 關閉
- I → 顯示背包，數字選取，E/G/S 操作，Esc 關閉
