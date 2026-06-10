# Trade 接公庫 — Design

> 日期：2026-06-11
> 議題：W2 fix step 1（trader → outpost tile）後 trade 成交仍 0。outpost owner 可能不在 tile 上、公庫物資未進交易池。需 trade 接 public_storage。

## 背景

當前狀態：
- trader 抵達 outpost tile，但 partner team 可能不在 tile 上（出征中 / 路過後離開）
- `_resolve_market` 只用 `team.resources`，公庫物資不參與
- 居民團物資多沉澱在 `tile.public_storage`，team.resources 常空 → 交易池空

## 不變量

- 同格才互動規則保留：trade 仍需 trader 跟 partner 同 tile
- 公庫物資交易進出尊重 cap 限制
- 公庫只在「自家 outpost」上 absorb 進交易池

## 目標

1. `_resolve_market` 開頭，對「在自家 outpost 上的 team」absorb `tile.public_storage` 進 team.resources（臨時）
2. `_resolve_market` 結尾，把多出來的物資 spill back 回 public_storage（cap 限制）
3. 沒 owner team 在 tile 時：trader 跟 outpost「虛擬 partner」交易（用 public_storage as resources + outpost owner leader 決定）

## 設計

### 改 1：absorb / spill_back helper

`interaction_system.gd`：

```gdscript
# 在自家 outpost 上 → absorb public_storage 進 team.resources
# 回傳 { res: original_team_amount } 供 spill_back 還原
static func _absorb_public_storage(state: WorldState, team: TeamData) -> Dictionary:
    var original: Dictionary = {}
    var tile: HexTileData = state.world.tiles.get(
        team.tile_pos.x * 1000 + team.tile_pos.y)
    if tile == null or tile.outpost_owner != team.team_id: return original
    for res in tile.public_storage:
        var public_amount: float = float(tile.public_storage[res])
        if public_amount <= 0: continue
        var team_amount: float = float(team.resources.get(res, 0))
        original[res] = team_amount
        team.resources[res] = team_amount + public_amount
    return original

# trade 結束後，多出來的存回 public_storage（cap 限制；超量留 team）
static func _spill_back_public_storage(state: WorldState, team: TeamData,
        original: Dictionary) -> void:
    var tile: HexTileData = state.world.tiles.get(
        team.tile_pos.x * 1000 + team.tile_pos.y)
    if tile == null or tile.outpost_owner != team.team_id: return
    for res in original:
        var current: float = float(team.resources.get(res, 0))
        var orig: float = float(original[res])
        # diff > 0 → 存回，diff < 0 → 公庫減少
        var diff: float = current - orig
        var cap: float = OutpostSystem.new()._get_storage_cap(tile, res)
        var stored: float = float(tile.public_storage.get(res, 0))
        if diff >= 0:
            # team 多了 → 把 (current - orig) 存回 public_storage
            var space: float = maxf(cap - stored, 0.0)
            var deposit: float = minf(diff, space)
            tile.public_storage[res] = stored + deposit
            team.resources[res] = orig + (diff - deposit)
        else:
            # team 少了 → 從 public_storage 扣 (-diff)，team 回原值
            tile.public_storage[res] = maxf(stored + diff, 0.0)
            team.resources[res] = orig
```

### 改 2：`_resolve_market` 套用

```gdscript
func _resolve_market(state: WorldState, a: TeamData, b: TeamData) -> void:
    var a_original: Dictionary = _absorb_public_storage(state, a)
    var b_original: Dictionary = _absorb_public_storage(state, b)
    _attempt_trade_direction(state, a, b)
    _attempt_trade_direction(state, b, a)
    _spill_back_public_storage(state, a, a_original)
    _spill_back_public_storage(state, b, b_original)
    if a.current_task == TeamData.TASK_TRADE: a.current_task = TeamData.TASK_IDLE
    if b.current_task == TeamData.TASK_TRADE: b.current_task = TeamData.TASK_IDLE
```

### 改 3：trader 抵達空 outpost 仍可交易

`process_on_move` 或 `_try_interact` 內，trader（current_task=TASK_TRADE）抵達 outpost tile 時，即使該 tile 上無 owner team 駐紮，也觸發跟「虛擬 partner」交易。

最簡實作：建一個 transient virtual team 代表 outpost：
- leader_id = outpost owner leader (read-only decision)
- resources = tile.public_storage 直接 reference
- 不入 state.teams

或更簡單：直接 inline 在 trader path 加 outpost trade：

```gdscript
# process_on_move 或 _try_interact 內，trader 在 outpost tile 上但無 partner team:
if mover.current_task == TeamData.TASK_TRADE:
    var tile: HexTileData = state.world.tiles.get(
        mover.tile_pos.x * 1000 + mover.tile_pos.y)
    if tile and tile.outpost_owner != -1:
        var owner: TeamData = state.teams.get(tile.outpost_owner)
        # owner 不在 tile 上仍可交易（trader vs 公庫）
        if owner != null and owner.tile_pos != mover.tile_pos:
            _resolve_market_trader_vs_outpost(state, mover, owner, tile)
```

`_resolve_market_trader_vs_outpost`：類似 `_resolve_market` 但 buyer/seller side 用 public_storage。

## 測試

1. **absorb / spill_back round-trip**：team 在自家 outpost，absorb 後 trade 0 件 → spill_back 還原 OK
2. **trader vs outpost owner 同 tile**：兩團同格，公庫 absorb 進交易池，trade 後 spill back
3. **trader 抵達空 outpost**：owner 不在 tile，trade 仍發生（vs 虛擬 partner）
4. **公庫 cap 限制**：spill_back 時超 cap → team 留多餘
5. **multi 跑出 trade 成交 > 0**

## 風險

- **`_resolve_market` 變動多**：原本純 team-team，現含 absorb/spill_back，邏輯重
- **絕對 sync**：absorb 後 trade 中物資變化必須 100% reflect 在 team.resources，spill_back 才能正確分流
- **cap 限制副作用**：trade 多賺的 物資 超 cap → 留 team.resources，玩家可能困惑
- **trader vs outpost virtual**：需新交易 path，不能完全重用 `_resolve_market`
