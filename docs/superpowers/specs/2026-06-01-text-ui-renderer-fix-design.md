# Text UI Renderer Fix & Real-time Refresh Design Spec

**Date:** 2026-06-01
**Status:** Approved → Awaiting Plan

---

## 目標

修正兩個文字 UI 問題：
1. **TextMapRenderer**：同一 Y 的格子被拆成兩條子行 → 改為每 Y 一條線，奇偶行縮排呈現 hex stagger
2. **即時刷新**：Space/G 鍵 tick 推進為阻塞迴圈，畫面凍結 → 改為非阻塞，每 TICKS_PER_HOUR 渲染一次

Tick scheduling 邏輯放進 `SimBridge`，未來圖形 UI 可直接呼叫同樣 API。

---

## 1. TextMapRenderer 修正

**檔案：** `scripts/ui/text_map_renderer.gd`

### 問題

現有 `render()` 對每個 Y 值產生兩條子行（even_line / odd_line），依 dcol 奇偶分配：

```
even_line (Y=k): tile at x=0,2,4...
odd_line  (Y=k):   tile at x=1,3,5...  （縮排 2）
```

結果：同一 Y 的格子分散在兩行，視覺上混亂。

### 新設計

每個 Y 一條線，奇數 Y 縮排 2 格（half-cell hex stagger）：

```
y=0: [0,0]  [1,0]  [2,0]  [3,0]       ← indent=0
  y=1: [0,1]  [1,1]  [2,1]  [3,1]     ← indent=2
y=2: [0,2]  [1,2]  [2,2]  [3,2]       ← indent=0
```

### 新 `render()` 邏輯

```gdscript
static func render(state: WorldState, player_tid: int, cursor: Vector2i) -> String:
    var player_team: TeamData = state.teams.get(player_tid)
    var player_pos: Vector2i  = player_team.tile_pos if player_team else Vector2i(4, 4)
    var discovered: Array     = state.team_discovered.get(player_tid, [])

    # 找地圖邊界（tile 實際 x/y 範圍）
    var xs: Array = []; var ys: Array = []
    for tile in state.world.tiles.values():
        xs.append(tile.tile_pos.x); ys.append(tile.tile_pos.y)
    if xs.is_empty(): return "（無地圖）"
    var xmin: int = xs.min(); var xmax: int = xs.max()
    var ymin: int = ys.min(); var ymax: int = ys.max()

    # 建 team 位置查詢表
    var team_at: Dictionary = {}
    for tid in state.teams:
        var t: TeamData = state.teams[tid]
        var k: int = t.tile_pos.x * 1000 + t.tile_pos.y
        if not team_at.has(k): team_at[k] = []
        (team_at[k] as Array).append(tid)

    # 每個 Y 一條線，奇數 Y 縮排 2
    var lines: Array = []
    for y in range(ymin, ymax + 1):
        var indent: String = "  " if y % 2 == 1 else ""
        var line: String = indent
        for x in range(xmin, xmax + 1):
            line += _cell(state, Vector2i(x, y), player_pos, player_tid, cursor, discovered, team_at)
        lines.append(line)
    return "\n".join(lines)
```

**`_cell()`、`_visible_team()`、`_hex_dist()`** 不變。

---

## 2. SimBridge Tick Scheduling

**檔案：** `scripts/ui/sim_bridge.gd`

### 新增 API

```gdscript
var _ticks_remaining: int = 0

# 請求推進 n ticks（非阻塞，由 tick_step 每 frame 分批執行）
func request_advance(n: int) -> void:
    _ticks_remaining = n

# 取消推進
func cancel_advance() -> void:
    _ticks_remaining = 0

# 是否正在推進
func is_advancing() -> bool:
    return _ticks_remaining > 0

# 每 frame 呼叫：推進 TICKS_PER_HOUR ticks，回傳結果
# 遭遇戰/新發現事件觸發時自動停止
# 返回 { "events": Array, "done": bool }
func tick_step() -> Dictionary:
    if _ticks_remaining <= 0:
        return { "events": [], "done": true }
    var n: int = mini(WorldState.TICKS_PER_HOUR, _ticks_remaining)
    var events := advance_ticks(n)
    _ticks_remaining = maxi(0, _ticks_remaining - n)
    if events.size() > 0:
        _ticks_remaining = 0   # 重要事件 → 停止推進
    return { "events": events, "done": _ticks_remaining <= 0 }
```

`advance_ticks()` 原有邏輯不動。

---

## 3. text_ui_main 改動

**檔案：** `scripts/ui/text_ui_main.gd`

### 新增 `_process()`

```gdscript
func _process(_delta: float) -> void:
    if not _bridge.is_advancing(): return
    var result := _bridge.tick_step()
    _events.append_array(result.get("events", []))
    if _events.size() > 100:
        _events = _events.slice(_events.size() - 100)
    _refresh()
    if _state.encounter_active:
        _bridge.cancel_advance()
```

### `_input()` 修改

**KEY_SPACE**（原有阻塞迴圈 → 改為 request_advance）：

```gdscript
KEY_SPACE:
    _bridge.request_advance(WorldState.TICKS_PER_DAY)
```

**KEY_G**（完成數字輸入後 → 改為 request_advance）：

```gdscript
# _handle_input_mode 中 KEY_ENTER 分支：
if _input_buffer.length() > 0 and int(_input_buffer) > 0:
    var n: int = mini(int(_input_buffer), 99999)
    _input_mode = false
    _input_bar.text = ""
    _bridge.request_advance(n)
    _refresh()
```

**KEY_ESCAPE**（優先取消 advance）：

```gdscript
KEY_ESCAPE:
    if _bridge.is_advancing():
        _bridge.cancel_advance()
        _refresh()
    elif _interact_mode:
        # 原有 interact_mode ESC 邏輯
        ...
    elif _member_mode:
        ...
    elif _inv_mode:
        ...
```

**KEY_M**（自動移動）：維持現有阻塞邏輯，不在此 spec 範圍。

---

## 修改檔案清單

| 檔案 | 動作 |
|---|---|
| `scripts/ui/text_map_renderer.gd` | 重寫 `render()`：移除 even/odd 子行，改為每 Y 一條線 + 奇數縮排 |
| `scripts/ui/sim_bridge.gd` | 新增 `_ticks_remaining`、`request_advance()`、`cancel_advance()`、`is_advancing()`、`tick_step()` |
| `scripts/ui/text_ui_main.gd` | 新增 `_process()`；KEY_SPACE/G 改 request_advance；KEY_ESCAPE 加取消 advance |

headless_test 不涉及（純 UI 改動，無模擬邏輯變化）。

---

## 注意事項

- **hex stagger 方向**：奇數 Y 縮排 2。若日後發現方向不對（偶數 Y 應縮排），僅需將條件從 `y % 2 == 1` 改為 `y % 2 == 0`，不影響其他邏輯。
- **`_ticks_remaining` 扣減精度**：`advance_ticks(n)` 遇事件會提前中止（實際跑不足 n ticks），但 `_ticks_remaining` 仍扣 n。誤差在此 debug UI 可接受；若需精確可改為逐 tick 推進。
- **遭遇戰觸發**：`_process()` 偵測到 `encounter_active` 時呼叫 `cancel_advance()`，防止背景繼續推進。
- **KEY_M 不改**：自動移動保留阻塞行為，因其需要「到達目的地才停」的精確控制，改成非阻塞需額外判斷條件，不在此 spec。
