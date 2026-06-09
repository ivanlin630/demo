# Outpost 公庫獨立結構 — Design

> 日期：2026-06-09
> 議題：B（resident system 後續）— 居民團持物資不分公私，特殊資源（mining/mint/manufacturing）跟基本物資混在一起，違反「公庫」概念

## 背景

當前居民團 `team.resources` 同時含：
- 採集的食物/材料（村民自家收成）
- ore_gold/ore_silver/ore_iron（理應領主壟斷的礦藏）
- mint facility 產出的 coin（屬領主鑄幣權）
- manufacturing 設施產出的 goods/weapons/armor（屬領主軍備）

這種混雜：
- 領主搶居民食物（_resolve_tribute）→ 同時把礦也視為居民資產被扣 rate ×（不對）
- 公庫概念缺失（中世紀真實有 領主府庫、官倉、武庫 等）
- 居民團滅 → 物資全消失 / 留 abandoned_coin（僅 coin），其他物資處理不一致

需要分離「公庫（owner 的）」與「居民團 resources（村民集體）」。

## 目標

1. `HexTileData.public_storage: Dictionary` 通用倉庫結構（所有 resource key）
2. **預設流向：** 特殊資源 + 設施產出 → 公庫；基本採集 → 居民團
3. Owner 抵達 outpost 自動「視需求領存」（NPC AI）；玩家手動 actions
4. 公庫上限依 outpost level + type
5. 滅團在 outpost → 物資全進公庫
6. D 攻佔連動：tile.outpost_owner 變 → 公庫自然歸新 owner
7. `_resolve_tribute` 食物收稅維持既有不變
8. 玩家 `withdraw_from_storage` + `deposit_to_storage` actions

## 不在範圍

- 公庫的「安全/防盜」機制（暫無，公庫透過 outpost 攻佔換手）
- 上交皇糧（居民食物部分自動進公庫）— 後續可加
- 公庫物資的市集交易（玩家不能在公庫上跟商隊直接 trade）— 後續
- UI 顯示公庫內容 — 後續 UI spec

## 新欄位

```gdscript
# HexTileData
var public_storage: Dictionary = {}
# 元素: { "food": 50.0, "coin": 100.0, "ore_gold": 5.0, "goods": 20.0, ... }
```

## 預設流向規則

### 進入公庫

| Source | 機制 |
|---|---|
| `ore_gold/silver/iron/steel` 採集 | `resource_system.collect_resources` 採到 ore 時直接 → 公庫（不進居民團）|
| Mint coin（FACILITY_DEF mint）| `outpost_system._tick_mint` ore → coin 進公庫 |
| Manufacturing 產出 goods/weapons/armor | `manufacturing_system.tick_all` 產品 → 公庫 |
| 滅團在 outpost | `_on_team_extinct` 全 team.resources + treasury → 公庫 |

### 進入居民團（既有路徑不變）

| Source | 機制 |
|---|---|
| food, material 採集 | `collect_resources` 既有 |
| Manufacturing 的食品/工具（如未來加）| 既有路徑 |

### 修改 collect_resources

```gdscript
# scripts/simulation/resource_system.gd._collect_from_tile
const PUBLIC_RESOURCES: Array = ["ore_gold", "ore_silver", "ore_iron", "ore_steel"]

for res in src_tile.resources.keys():
    # ... 既有 gain 計算
    if res in PUBLIC_RESOURCES:
        # 特殊資源進公庫
        var dst_tile = state.world.tiles.get(team.tile_pos.x*1000 + team.tile_pos.y)
        if dst_tile != null and dst_tile.outpost_level > 0:
            var cap = OutpostSystem.new()._get_storage_cap(dst_tile, res)
            var current = float(dst_tile.public_storage.get(res, 0))
            dst_tile.public_storage[res] = minf(current + gain, cap)
        # else: 沒 outpost 採到 ore 也只能進 team.resources（fallback）
    else:
        team.resources[res] = float(team.resources.get(res, 0)) + gain
    src_tile.resources[res] = maxf(current_tile_qty - gain, 0.0)
```

### 修改 mint tick (參考 Coin Economy spec)

```gdscript
# outpost_system._tick_mint：產出進公庫（非居民團 resources）
func _tick_mint(state, tile, team):
    if tile.mint_level == 0: return
    var rate = tile.mint_level * MINT_BASE_RATE
    # 從居民團 ore 扣？或從 tile.public_storage["ore_*"]？
    # 由於 ore 已進公庫，從 public_storage 扣
    var gold_qty = float(tile.public_storage.get("ore_gold", 0))
    if gold_qty > 0:
        var convert = minf(gold_qty, rate / GOLD_TO_COIN_RATIO)
        tile.public_storage["ore_gold"] = gold_qty - convert
        var coin_added = convert * GOLD_TO_COIN_RATIO
        var cap = _get_storage_cap(tile, "coin")
        var cur_coin = float(tile.public_storage.get("coin", 0))
        tile.public_storage["coin"] = minf(cur_coin + coin_added, cap)
```

### Manufacturing 也改

```gdscript
# manufacturing_system 產品改進公庫
# ...产品 -> tile.public_storage["goods"/"weapon_*"/"armor_*"]
```

## Owner 取存（NPC AI + Player）

### NPC 自動「視需求領存」

```gdscript
# faction_ai_system._evaluate_storage_visit
func _evaluate_storage_visit(state, team, tile):
    if tile.outpost_owner != team.team_id: return
    if not tile.public_storage: return
    for res in tile.public_storage:
        var stored = float(tile.public_storage[res])
        var team_have = float(team.resources.get(res, 0))
        var needed = _calc_team_need(team, res)
        if team_have < needed:
            var take = minf(stored, needed - team_have)
            if take > 0:
                tile.public_storage[res] = stored - take
                team.resources[res] = team_have + take
        elif team_have > needed * 2:
            # surplus → deposit
            var cap = OutpostSystem.new()._get_storage_cap(tile, res)
            var deposit_max = cap - stored
            var deposit = minf(team_have - needed, deposit_max)
            if deposit > 0:
                tile.public_storage[res] = stored + deposit
                team.resources[res] = team_have - deposit

func _calc_team_need(team: TeamData, res: String) -> float:
    match res:
        "food": return float(team.population) * 14.0   # 2 週
        "material": return 50.0 + float(team.population) * 2.0
        "coin": return float(team.population) * 10.0
        "weapon_melee_low", "weapon_melee_high", "weapon_ranged_low", "weapon_ranged_high":
            return float(team.named_members.size()) * 2.0
        "armor_low", "armor_high":
            return float(team.named_members.size())
        _:
            return 0.0   # 礦類等不需要，全可存
```

觸發：team 抵達 self.outpost tile → `_evaluate_storage_visit`（在 movement arrival 或 sim_runner tick）

### 玩家 actions

```gdscript
"withdraw_from_storage": _action_withdraw_from_storage,
"deposit_to_storage": _action_deposit_to_storage,

func _action_withdraw_from_storage(state, _target, pt, pt_id):
    var res = state.player_state.get("storage_res", "")
    var amount = float(state.player_state.get("storage_amount", 0))
    if res == "" or amount <= 0:
        return { "ok": false, "msg": "未指定 res / amount" }
    var pos = pt.tile_pos
    var tile = state.world.tiles.get(pos.x * 1000 + pos.y)
    if tile == null or tile.outpost_owner != pt_id:
        return { "ok": false, "msg": "非自家 outpost" }
    var stored = float(tile.public_storage.get(res, 0))
    if stored < amount:
        return { "ok": false, "msg": "公庫不足" }
    tile.public_storage[res] = stored - amount
    pt.resources[res] = float(pt.resources.get(res, 0)) + amount
    return { "ok": true, "msg": "取出 %s × %.0f" % [res, amount] }

func _action_deposit_to_storage(state, _target, pt, pt_id):
    var res = state.player_state.get("storage_res", "")
    var amount = float(state.player_state.get("storage_amount", 0))
    if res == "" or amount <= 0:
        return { "ok": false, "msg": "未指定 res / amount" }
    var pos = pt.tile_pos
    var tile = state.world.tiles.get(pos.x * 1000 + pos.y)
    if tile == null or tile.outpost_owner != pt_id:
        return { "ok": false, "msg": "非自家 outpost" }
    var have = float(pt.resources.get(res, 0))
    if have < amount:
        return { "ok": false, "msg": "team 資源不足" }
    var cap = OutpostSystem.new()._get_storage_cap(tile, res)
    var stored = float(tile.public_storage.get(res, 0))
    if stored + amount > cap:
        return { "ok": false, "msg": "公庫已滿" }
    tile.public_storage[res] = stored + amount
    pt.resources[res] = have - amount
    return { "ok": true, "msg": "存入 %s × %.0f" % [res, amount] }
```

## 公庫上限

```gdscript
# outpost_system 加常數
const OUTPOST_STORAGE_CAP: Dictionary = {
    "civilian": [200, 500, 1500],   # L1, L2, L3 per resource
    "military": [300, 800, 2500],
}

func _get_storage_cap(tile: HexTileData, _res: String) -> float:
    var arr = OUTPOST_STORAGE_CAP.get(tile.outpost_type, [100, 300, 800])
    return float(arr[clampi(tile.outpost_level - 1, 0, 2)])
```

注意：本 spec 全 resource type 同 cap。後續可細化（如 ore cap 較小，food cap 較大）。

## 滅團（修改 Coin Economy spec 的 _on_team_extinct）

```gdscript
func _on_team_extinct(state, team):
    var tile = state.world.tiles.get(team.tile_pos.x*1000 + team.tile_pos.y)
    if tile == null: return
    if tile.outpost_level > 0:
        # 全 team.resources + treasury → 公庫
        for res in team.resources:
            var stored = float(tile.public_storage.get(res, 0))
            var cap = _get_storage_cap(tile, res)
            tile.public_storage[res] = minf(stored + float(team.resources[res]), cap)
        var cur_coin = float(tile.public_storage.get("coin", 0))
        var cap = _get_storage_cap(tile, "coin")
        tile.public_storage["coin"] = minf(cur_coin + team.anon_treasury, cap)
    else:
        # 無 outpost → abandoned_coin（既有）
        tile.abandoned_coin += team.anon_treasury
    team.anon_treasury = 0.0
    team.resources.clear()
```

## D 攻佔連動（自然處理）

`tile.outpost_owner` 變更 → 公庫物資不動 → 新 owner 自然有權領（透過 `_evaluate_storage_visit` 或玩家手動）。無需特別 hook。

## _resolve_tribute 不變

食物收稅維持既有路徑：
- Owner 派 team task=徵收 → 同 tile → 從**居民團 resources** 抽 food × tax_rate
- 公庫不參與 tribute
- 食物從未進公庫（採集流向居民團，符合農民自家收成）

## 不變量

- `tile.public_storage[res] >= 0` 永遠成立
- `tile.public_storage[res] <= cap`
- 礦/mint coin/manufacturing 產品 ONLY 進公庫（不進居民團）
- food/material 採集 ONLY 進居民團
- 滅團在 outpost → 全進公庫；溢出 cap 部分 → 丟失（記 log）
- 攻佔後新 owner 自動有權

## 測試

`headless_test.gd`：

1. **public_storage 欄位**：預設空 dict
2. **礦採集進公庫**：team 在 outpost 採 ore_gold → tile.public_storage["ore_gold"] 增
3. **食物採集進居民團**：採 food → team.resources["food"] 增（公庫不變）
4. **mint 從公庫扣 ore 產 coin 進公庫**：tile.public_storage["ore_gold"] 減、coin 增
5. **NPC 自動領（缺食）**：team food < needed + 自家 outpost → 自動領 food 進 team
6. **NPC 自動存（多食）**：team food > needed × 2 → 自動存 food 進公庫
7. **NPC 不領別人 outpost**：tile.outpost_owner != team → 不領
8. **公庫上限**：deposit 達 cap → 拒絕多餘
9. **玩家 withdraw_from_storage**：玩家自家 outpost → 取
10. **玩家 deposit_to_storage**：自家 outpost → 存
11. **玩家非自家 outpost reject**：outpost_owner != pt_id → ok=false
12. **滅團在 outpost → 公庫**：team 滅 → resources 全進 public_storage
13. **滅團溢出 cap → 丟失**：超 cap 部分不入庫
14. **D 攻佔後新 owner 自動領**：tile.outpost_owner 變 → 新 owner 抵達自動領

## 風險

- **collect_resources 改 ore 流向**：影響既有採礦行為
- **manufacturing_system 產出改流向**：需確認既有產出寫入位置
- **mint 從公庫扣 ore（依賴 ore 已進公庫）**：必須 collect_resources 先改完
- **公庫 cap 設定**：可能太小（軍事 outpost 收 ore 不夠裝）或太大（無壓力）
- **NPC `_evaluate_storage_visit` 觸發頻率**：每 hour 跑可能過頻，建議只在「team 抵達新 tile」時觸發

## 解決

- 居民團 vs 公庫概念分離
- 滅團物資處理一致化（之前只處理 coin → abandoned_coin，現在全資源 → 公庫）
- 領主壟斷礦 + 鑄幣 + 軍備（特殊資源不屬村民）

## 連動已存在 specs

- **Coin Economy spec**：mint coin 從進居民團改進公庫（連動更新）
- **D Outpost capture spec**：攻佔後 outpost_owner 變即可，公庫物資自動歸 winner
- **E Resident system spec**：居民團 resources 不變，仍持基本物資
- **C NPC infrastructure spec**：manufacturing 產出位置改公庫

## 後續延伸

- 上交皇糧（居民團食物自動部分流公庫）
- 公庫防盜（鎖/守衛）
- 公庫安全：encounter 在 outpost 上發生時公庫部分被搶
- 公庫 UI 顯示
- Cap by resource type（細分 ore/food/coin cap 不同）
