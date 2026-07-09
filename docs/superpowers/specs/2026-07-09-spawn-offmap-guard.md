# Spec — 初始隊生成越界修（_random_near 邊界檢查）

- from: systems
- 工單: 用戶 observer 手驗發現「有初始隊在地圖外」（2026-07-09）
- 病灶: `game_setup.gd:309 _random_near`

## 問題（root cause 確認）
```gdscript
static func _random_near(positions: Array, rng) -> Vector2i:
    if positions.is_empty(): return Vector2i(0, 0)
    var origin: Vector2i = positions[rng.randi() % positions.size()]
    var dirs: Array = [Vector2i(1,0), ...6 hex dirs]
    return origin + dirs[rng.randi() % dirs.size()]   # ★無邊界檢查
```
`origin`（據點/leader 位置）在**地圖邊緣**時，`origin + dir` 落到半徑外**不存在的 tile** → 隊生在圖外。用於 `:148`（faction branch 隊近據點）、`:261`（faction 隊近 leader）。`_random_empty_tile` 從既有 tile keys 挑=安全；`_random_near` 是唯一越界源。

## 修（D1：_random_near 驗 tile 存在 + fallback）
```gdscript
static func _random_near(state: WorldState, positions: Array, rng) -> Vector2i:
    if positions.is_empty(): return _random_empty_tile(state, rng)
    var origin: Vector2i = positions[rng.randi() % positions.size()]
    var dirs: Array = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1),
                       Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,1)]
    # 隨機起點掃 6 方向，取第一個「存在且未被佔」的鄰格；全不合則退 _random_empty_tile。
    var start: int = rng.randi() % dirs.size()
    for i in range(dirs.size()):
        var cand: Vector2i = origin + dirs[(start + i) % dirs.size()]
        var key: int = cand.x * 1000 + cand.y
        if state.world.tiles.has(key) and not _is_tile_occupied(state, cand):
            return cand
    return _random_empty_tile(state, rng)   # 邊緣全鄰格越界/被佔 → 安全兜底
```
- **簽名加 `state`**：現 `_random_near(positions, rng)` → `_random_near(state, positions, rng)`（需驗 tile 存在）。改兩 caller（:148/:261）。
- **語意保真意圖**：仍「近 origin」（優先鄰格），只是排除越界/被佔；邊緣退安全隨機格（原本越界=生圖外=bug，退 in-map 是修正非退化）。
- 保留原 `dir` 六方向集（不擴散、不改地圖尺度）。

## ★行為/determinism 影響（measurer 必知）
- 修改**改 seeded 世界初始佈局**（原越界隊 → 現落 in-map）→ **seeded 床 baseline 位移=預期**（非退化）。
- RNG 流：新增 `for` 掃描 + 可能呼 `_random_empty_tile`（內有 `rng.randi()` 迴圈）→ **RNG 消耗改變 → 全下游 seeded 軌跡岔開**。∴ 舊 seeded 硬斷值全需 re-baseline（headless reproducible 自比即可，非 hardcode）。
- **不是「零行為變」slice**——是「修 bug 必然改軌跡」。measurer 報「baseline 位移=修 bug 預期」，別當退化 reject。

## 觸及檔
| 檔 | 改點 |
|---|---|
| `scripts/simulation/game_setup.gd` | `_random_near` +state 參 +邊界/佔用檢查 +fallback；兩 caller(:148/:261) 傳 state |

**不碰**：`_random_empty_tile`（已安全）、地圖尺度、其他 spawn。

## 驗收法
1. `--headless --import` 綠；`game_sim_multi` ≥1000 tick 無崩。
2. **★守衛（硬）**：開局全隊 `tile_pos` 皆 `state.world.tiles.has(x*1000+y)`（in-map）——加 headless 斷言掃全隊初始位置，0 越界。跑數 seed（含小半徑逼邊緣觸發原 bug）。
3. constitution_gate 綠。
4. seeded 床值位移=預期（measurer 標註，非退化）。

## 流程
spec → reviewer 審（fallback 語意 + RNG 影響）→ implementer → measurer（re-baseline + 越界斷言）。
