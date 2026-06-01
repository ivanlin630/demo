# Encounter Map Hexagonal Boundary Fix

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 修正遭遇戰地圖從矩形邊界改為正六邊形邊界（內切圓半徑 MAP_RADIUS），加入 MAP_DIAMETER 常數。

**Architecture:** 只改 `encounter_system.gd`，修正 `_get_edge_hexes` 邊緣定義，加入 `_is_in_map` 驗證。

**Tech Stack:** Godot 4.2.2 GDScript，headless test `scripts/debug/headless_test.gd`

---

## 檔案一覽

| 檔案 | 改動 |
|---|---|
| `scripts/simulation/encounter_system.gd` | 加 `MAP_DIAMETER`；修 `_get_edge_hexes`；加 `_is_in_map` |

---

## Task 1：修正 encounter_system.gd

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`

- [ ] **Step 1：加 MAP_DIAMETER 常數**

在 `const MAP_RADIUS: int = 10` 下方加：

```gdscript
const MAP_DIAMETER: int = MAP_RADIUS * 2   # 內切圓直徑 = 1 world-hex 的尺度
```

- [ ] **Step 2：加 _is_in_map 驗證函數**

在 `hex_dist` 函數後加：

```gdscript
func _is_in_map(pos: Vector2i) -> bool:
    return hex_dist(Vector2i.ZERO, pos) <= MAP_RADIUS
```

- [ ] **Step 3：修正 _get_edge_hexes**

完整替換 `_get_edge_hexes` 函數：

```gdscript
func _get_edge_hexes(edge: int) -> Array:
    var result: Array = []
    match edge:
        0:  # top: y=-R, x from 0 to R
            for x in range(0, MAP_RADIUS + 1):
                result.append(Vector2i(x, -MAP_RADIUS))
        1:  # upper-right: x=R, y from -R to 0
            for y in range(-MAP_RADIUS, 1):
                result.append(Vector2i(MAP_RADIUS, y))
        2:  # lower-right: x+y=R, x from 0 to R
            for x in range(0, MAP_RADIUS + 1):
                result.append(Vector2i(x, MAP_RADIUS - x))
        3:  # bottom: y=R, x from -R to 0
            for x in range(-MAP_RADIUS, 1):
                result.append(Vector2i(x, MAP_RADIUS))
        4:  # lower-left: x=-R, y from 0 to R
            for y in range(0, MAP_RADIUS + 1):
                result.append(Vector2i(-MAP_RADIUS, y))
        5:  # upper-left: x+y=-R, x from -R to 0
            for x in range(-MAP_RADIUS, 1):
                result.append(Vector2i(x, -MAP_RADIUS - x))
    return result
```

**驗證：** 每條邊應有 MAP_RADIUS+1 = 11 個 tile，六條邊共 60 個唯一邊界 tile（6×10，角點各算一次）。

- [ ] **Step 4：在 headless_test.gd 加驗證**

在現有測試區加：

```gdscript
print("--- EncounterMapShape ---")
var enc := EncounterSystem.new()
# 每條邊應有 MAP_RADIUS+1 tiles
for edge in range(6):
    var hexes: Array = enc._get_edge_hexes(edge)
    var ok: bool = hexes.size() == EncounterSystem.MAP_RADIUS + 1
    print("  edge%d size=%d %s" % [edge, hexes.size(), "OK" if ok else "FAIL"])
    # 每個 tile 都應在地圖內（hex_dist == MAP_RADIUS）
    for h in hexes:
        var d: int = enc.hex_dist(Vector2i.ZERO, h)
        if d != EncounterSystem.MAP_RADIUS:
            print("  FAIL edge%d tile(%d,%d) dist=%d != %d" % [edge, h.x, h.y, d, EncounterSystem.MAP_RADIUS])
# 總唯一邊界 tile = 6 * MAP_RADIUS = 60
var all_edge: Array = []
for edge in range(6):
    for h in enc._get_edge_hexes(edge):
        if not all_edge.has(h): all_edge.append(h)
var expected: int = 6 * EncounterSystem.MAP_RADIUS
print("  unique edge tiles=%d (expected %d) %s" % [
    all_edge.size(), expected, "OK" if all_edge.size() == expected else "FAIL"])
print("  MAP_DIAMETER=%d" % EncounterSystem.MAP_DIAMETER)
print("EncounterMapShape OK" if all_edge.size() == expected else "EncounterMapShape FAIL")
```

- [ ] **Step 5：跑 headless 確認**

```powershell
cd A:\GDS\demo
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DONE|SCRIPT ERROR|EncounterMap|edge|FAIL"
```

預期：
- 6 條邊各 11 tiles，全 OK
- unique edge tiles=60 OK
- MAP_DIAMETER=20
- `=== DONE ===`，無 SCRIPT ERROR

- [ ] **Step 6：Commit**

```
git add scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "fix(encounter): hexagonal map boundary; add MAP_DIAMETER; fix _get_edge_hexes"
```
