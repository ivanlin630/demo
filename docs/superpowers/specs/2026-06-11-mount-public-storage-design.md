# Mount 公庫系統 — Design

> 日期：2026-06-11
> 議題：mounts 既在 `team.resources`，但 stable 養 / 採集應該在 outpost 庫存。改為 PUBLIC_RESOURCES，跟 ore 統一處理。

## 背景

當前狀態：
- mounts / wagons 在 `team.resources`
- PUBLIC_RESOURCES = ["ore_gold", "ore_silver", "ore_iron", "ore_steel"]
- 既有 玩家 `withdraw_from_storage` / `deposit_to_storage` 命令
- 既有 `OutpostSystem._get_storage_cap` 公庫上限
- stable facility 既有產出 → `team.resources["mounts"]`（不對）
- 採集 wild_horses 機制已移除（待本 spec）

## 不變量

- mount 是 PUBLIC_RESOURCE，stable / 採集都進 `tile.public_storage["mounts"]`
- `effective_mounts` 只看 `team.resources["mounts"]`（公庫的不算）→ 出征必先 withdraw
- 戰利品 mount loot 進 `winner.resources["mounts"]`（戰場無 outpost）
- 玩家 withdraw/deposit 仍走既有 player_command 路徑
- NPC AI 在 task 評估時自動 withdraw 需要的 mount 數

## 目標

1. `PUBLIC_RESOURCES` 加 `"mounts"`
2. stable 產出 → `public_storage["mounts"]`
3. `harvest_system` 加每日 outpost 鄰格 wild_horses 採集 → `public_storage["mounts"]`
4. NPC AI 自動 withdraw：出征前依 task 需求從自家 outpost 拉 mount 進 team.resources
5. 玩家 withdraw/deposit 既有路徑沿用（mount 已自動可用，無需新 command）

## NPC AI 自動 withdraw

`faction_ai_system` 加：

```gdscript
const MOUNT_TARGET_RATIO: float = 0.5   # NPC 出征前嘗試 ratio 騎兵化

func _auto_withdraw_mounts(state: WorldState, team: TeamData) -> void:
    # 條件：在自家 outpost + 即將出征
    if team.current_task in ["idle", "備戰"]: return
    var tile: HexTileData = state.world.tiles.get(
        team.tile_pos.x * 1000 + team.tile_pos.y)
    if tile == null or tile.outpost_owner != team.team_id: return
    var available: int = int(tile.public_storage.get("mounts", 0))
    if available <= 0: return
    var current: int = int(team.resources.get("mounts", 0))
    var target: int = int(float(team.population) * MOUNT_TARGET_RATIO)
    var need: int = maxi(target - current, 0)
    var take: int = mini(need, available)
    if take > 0:
        tile.public_storage["mounts"] = available - take
        team.resources["mounts"] = current + take
        print("[Mount] Team%d auto-withdraw %d mounts from outpost" % [team.team_id, take])
```

Call point：`evaluate_all` per-team，task assign 後但移動前。

## Outpost 鄰格採集

`harvest_system` 加每日 batch：

```gdscript
const HEX_DIRS: Array = [
    Vector2i(1, 0), Vector2i(-1, 0),
    Vector2i(0, 1), Vector2i(0, -1),
    Vector2i(1, -1), Vector2i(-1, 1),
]

func tick_all(state: WorldState) -> void:
    # 既有 ...
    if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
        _collect_wild_horses_by_outposts(state)

func _collect_wild_horses_by_outposts(state: WorldState) -> void:
    for tile_id in state.world.tiles:
        var tile: HexTileData = state.world.tiles[tile_id]
        if tile.outpost_owner == -1 or tile.outpost_level == 0: continue
        for d in HEX_DIRS:
            var npos: Vector2i = tile.tile_pos + d
            var ntile: HexTileData = state.world.tiles.get(npos.x * 1000 + npos.y)
            if ntile == null: continue
            var wh: int = int(ntile.resources.get("wild_horses", 0))
            if wh <= 0: continue
            # 進 outpost 公庫（cap 限制）
            var cap: float = OutpostSystem.new()._get_storage_cap(tile, "mounts")
            var stored: float = float(tile.public_storage.get("mounts", 0))
            var space: float = maxf(cap - stored, 0.0)
            var taken: int = mini(wh, int(space))
            if taken > 0:
                tile.public_storage["mounts"] = stored + float(taken)
                ntile.resources["wild_horses"] = wh - taken
                print("[Mount] Outpost %s 採野馬 +%d" % [
                    str(tile.tile_pos), taken])
```

## Stable 產出改

`outpost_system.produce_stable_day`（既有）改：

```gdscript
# 既有
# owner_team.resources["mounts"] = ... 
# 新
var cap: float = _get_storage_cap(tile, "mounts")
var stored: float = float(tile.public_storage.get("mounts", 0))
var space: float = maxf(cap - stored, 0.0)
var produce: float = STABLE_PRODUCE_PER_DAY * float(tile.stable_level)
tile.public_storage["mounts"] = stored + minf(produce, space)
```

= 直接進 outpost 公庫，不再進 owner team。

## PUBLIC_RESOURCES + storage cap

`resource_system.gd`：

```gdscript
const PUBLIC_RESOURCES: Array = [
    "ore_gold", "ore_silver", "ore_iron", "ore_steel", "mounts"
]
```

`outpost_system._get_storage_cap` 加 mount cap：

```gdscript
"mounts": [10, 30, 80][level - 1]
```

或重用既有 generic cap。

## 測試

1. **PUBLIC_RESOURCES 含 mounts**
2. **stable 產出進公庫**：跑 30 天 → public_storage["mounts"] 累積
3. **採集 daily batch**：outpost 鄰格 wild_horses 每日進公庫
4. **採集 cap 限制**：超 cap 不收
5. **NPC AI auto-withdraw**：team 出征前 withdraw target_ratio
6. **NPC AI 不在 idle 不 withdraw**
7. **玩家 withdraw**（既有路徑）：mount 從 public_storage 到 team.resources
8. **戰利品 loot**：winner team.resources（不進公庫）
9. **effective_mounts 只 team.resources**：公庫的不算 speed bonus
10. **integration：multi 4 config × 90 天，stable/採集/withdraw 都跑**

## 風險

- **NPC AI auto-withdraw 時機**：放錯 call point 可能 team 永遠帶滿 mount → 加 task gate
- **MOUNT_TARGET_RATIO 0.5**：每個 team 騎兵化 50% 可能過多，需 tune
- **採集 cap 限制**：野馬累積但公庫滿 → 浪費，玩家可能怨
- **戰利品仍進 team.resources**：勝方回家還要手動 deposit 才能存入公庫（無自動 deposit）
- **mount cap 設計**：等級 1 cap 10 / 等級 3 cap 80，是否合理待 tune
- **既有玩家 deposit/withdraw** 應自動支援 mount（PUBLIC_RESOURCES 改 = 自動）

## 解決

- mount 「在馬廄裡」概念正確
- stable / 採集都進公庫，跟 ore 統一
- 玩家明確 inventory（要用要 withdraw）
- NPC AI 自動 withdraw，避免「養了馬不會用」
- 戰利品 仍歸 winner（戰場無 outpost，合理）
