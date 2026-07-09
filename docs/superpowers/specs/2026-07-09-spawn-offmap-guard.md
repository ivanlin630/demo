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

## ★行為/determinism 影響（measurer 必知，reviewer 修正=條件性非必然）
- **RNG 消耗保近 case 不變（reviewer 澄清）**：新碼 `start := rng.randi()`（1 抽）取代舊 `dir` 抽（1 抽）、`for` 掃描**不呼 rng**（純 `start+i` 位移）→ **非邊緣 origin 第一候選即合格 → 消耗仍 = origin 1 抽 + start 1 抽 = 舊碼同量**。
- **只有** origin 靠邊緣、6 方向全越界/被佔 → 落 `_random_empty_tile` fallback（內有 `while` rng 迴圈）→ 這才是額外消耗**唯一觸發點**。
- ∴ **位移是 data-dependent 非必然**：某 seed 若開局全隊 tile_pos 掃描 **0 越界**（原本沒踩 bug）→ RNG **byte-identical、軌跡零變**；只有**原本有越界隊**的 seed 才位移（一旦觸發，該 seed 下游全岔=單 RNG stream 特性）。
- **measurer 判讀**：先跑「開局全隊 0 越界？」掃描分類——0 越界的 seed 應 byte-identical（非位移=正常）、有越界的 seed 位移=修 bug 預期（非退化）。別把「有些 seed 沒位移」當異常。

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
