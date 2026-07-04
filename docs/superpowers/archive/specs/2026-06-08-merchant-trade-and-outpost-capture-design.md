# 商隊真實貿易 + Outpost 攻佔/棄置（A + D）— Design

> 日期：2026-06-08
> 議題：A 商隊 merchant_inventory 跑商；D outpost 易主機制（武力 / 外交 / 自動 / 手動）

## 背景

### A 商隊貿易現況

`_resolve_trade(seller, buyer)` 只實作單向「seller push surplus → buyer」。商隊只能賣自家庫存，賣完無採購機制 → coin 累積無消耗管道。商隊無「跨地買低賣高」中介行為。

### D outpost 易主現況

`tile.outpost_owner` 一旦設定永不變。沒有攻佔、棄置、自動接管邏輯。敵人站上 outpost 只能「借用採食」，無法接管。E spec 加了居民起義機制但 outpost ownership 連動模糊。

## 目標

1. 統一 `_resolve_market(a, b)` 雙向結算貿易（取代既有 _resolve_trade）
2. 加 `merchant_inventory` 欄位通用（任何 team），AI 限商隊主動跑商
3. 商隊 task=貿易 自動切換買賣（無新 task 名稱）
4. 商隊找「價差最大」target 跑商
5. outpost 攻佔 5 條路徑：武力 / 外交勸降 / 起義 / 自動 / 手動棄置
6. 居民起義改 E spec：依 leader 個性選「守城型 A」或「流亡型 B」
7. outpost_owner 變更規則完整文件化

## 不在範圍

- 銀礦 → 造幣 → coin 真實來源（獨立 spec）
- 薪資流向重構（獨立 spec）
- 商隊 inventory 重量/wagons 上限（暫無限）
- 升級 outpost 邏輯（既有不動）

## 新欄位

```gdscript
# TeamData
var merchant_inventory: Array = []
# 元素: { "grade": String, "qty": int, "bought_at": float, "bought_from": int }
```

## 統一 `_resolve_market`（取代 `_resolve_trade`）

### 觸發

`interaction_system._resolve_pair` 改：

```gdscript
# 貿易：跨勢力均可
if a.current_task == TeamData.TASK_TRADE or b.current_task == TeamData.TASK_TRADE:
    _resolve_market(state, a, b)
    return
```

### 函數結構

```gdscript
func _resolve_market(state: WorldState, a: TeamData, b: TeamData) -> void:
    _attempt_trade_direction(state, a, b)  # A 賣給 B
    _attempt_trade_direction(state, b, a)  # B 賣給 A
    # task 重置
    if a.current_task == TeamData.TASK_TRADE: a.current_task = TeamData.TASK_IDLE
    if b.current_task == TeamData.TASK_TRADE: b.current_task = TeamData.TASK_IDLE

func _attempt_trade_direction(state, seller, buyer):
    var buyer_coin = float(buyer.resources.get("coin", 0))
    if buyer_coin <= 0: return
    var commerce = _get_commerce_skill(state, seller)
    
    # (1) seller 商隊優先賣 inventory 賺差價
    if seller.tags.has("商隊"):
        for item in seller.merchant_inventory.duplicate():
            if item.bought_from == buyer.team_id: continue   # 不賣回賣家
            var bid = _local_value(buyer, item.grade)
            if bid <= item.bought_at: continue   # 無利潤
            var qty = mini(int(item.qty), int(buyer_coin / bid))
            if qty <= 0: continue
            _execute_transfer(seller, buyer, item.grade, qty, bid)
            item.qty -= qty
            if item.qty <= 0: seller.merchant_inventory.erase(item)
            buyer_coin -= qty * bid
    
    # (2) seller 賣 resources surplus（既有邏輯）
    for res in BASE_PRICE.keys():
        var stock = float(seller.resources.get(res, 0))
        var reserve = _calc_reserve(seller, res)
        var surplus = maxf(stock - reserve, 0.0)
        if surplus <= 0: continue
        var ask = _local_value(seller, res) * (1.0 - commerce * 0.1)
        var bid = _local_value(buyer, res)
        if ask >= bid: continue
        var qty = mini(int(surplus), int(buyer_coin / ask))
        if qty <= 0: continue
        _execute_transfer(seller, buyer, res, qty, ask)
        # buyer 若是商隊 → 進 inventory；否則進 resources
        if buyer.tags.has("商隊"):
            buyer.merchant_inventory.append({
                "grade": res, "qty": qty, "bought_at": ask, "bought_from": seller.team_id
            })
        # 注意：_execute_transfer 已加到 buyer.resources，商隊重複處理需注意
        buyer_coin -= qty * ask

func _execute_transfer(seller, buyer, res, qty, price):
    # seller 物品 → buyer
    seller.resources[res] = float(seller.resources.get(res, 0)) - qty
    buyer.resources[res] = float(buyer.resources.get(res, 0)) + qty
    # coin
    buyer.resources["coin"] = float(buyer.resources.get("coin", 0)) - qty * price
    seller.resources["coin"] = float(seller.resources.get("coin", 0)) + qty * price
```

注意：商隊買進 inventory 時，物品同時加進 buyer.resources（被 _execute_transfer 加），需要在 inventory append 後從 resources 扣回（移到 inventory）。Inventory 概念上是 resources 的子集（標記為「待轉售」）。

修正：

```gdscript
# 在 surplus 賣段，商隊買家：
if buyer.tags.has("商隊"):
    # _execute_transfer 已加到 buyer.resources[res]，移到 inventory
    buyer.resources[res] -= qty   # 從 resources 扣回（移轉）
    buyer.merchant_inventory.append({...})
# else: 普通買家，留在 resources
```

### 玩家 `submit_trade_offer` 不受影響

既有 player path 仍用獨立邏輯（明確 give/wants），不走 market 自動。

### 既有 `_resolve_trade` 拆除

原 `_resolve_trade` 函數整段刪掉，全 reference 改 `_resolve_market`。

### `_calc_reserve` 抽出

```gdscript
func _calc_reserve(team, res):
    if res == "food":
        return float(team.population) * 0.1 * FOOD_RESERVE_TICKS
    elif res == "coin":
        return float(team.resources.get(res, 0)) * 0.5
    return 0.0
```

## 商隊 AI 找 target（faction_ai 改進）

`faction_ai._find_trade_target` 從「最近有 coin 的 buyer」改為「最大價差 / 距離」：

```gdscript
func _find_trade_target(state, merchant):
    var best_id = -1; var best_score = -INF
    for tid in state.team_discovered.get(merchant.team_id, []):
        if tid == merchant.team_id: continue
        if not state.teams.has(tid): continue
        var t = state.teams[tid]
        var snap = state.team_intel.get(merchant.team_id, {}).get(tid, {})
        var dist = _hex_dist(merchant.tile_pos, t.tile_pos)
        if dist > MERCHANT_MAX_RANGE: continue
        # 最大價差（粗估，靠 snapshot 與自家 local_value）
        var max_gap = 0.0
        for res in BASE_PRICE:
            var my_val = _local_value(merchant, res)
            var their_val_est = my_val   # 預設無 intel = 等價
            # 簡化：snapshot 有 stock 估算 → 推估 value
            if snap.has("food") and res == "food":
                var pop = int(snap.get("population", 10))
                var stk = float(snap.get("food", 0))
                # local_value 公式倒推
                var target = pop * 1.0
                var sr = clampf((target - stk) / maxf(target, 1.0), -0.5, 1.0)
                their_val_est = BASE_PRICE[res] * (1.0 + sr)
            var gap = absf(their_val_est - my_val)
            max_gap = maxf(max_gap, gap)
        var score = max_gap / float(maxi(dist, 1))
        if score > best_score:
            best_score = score
            best_id = tid
    return best_id
```

## D Outpost 易主機制

### 變更觸發表

| 路徑 | 條件 | 結果 |
|---|---|---|
| **武力佔領（B1）** | encounter 結束 + winner != original owner | `tile.outpost_owner = winner_id` |
| **無人接管** | team 駐留 `tile.outpost_owner == -1` 的 outpost 3 天 | `outpost_owner = team_id` |
| **外交勸降（C1）** | 居民團接受 propose_alliance / offer_surrender | `outpost_owner = 新 faction 提議方 team_id` |
| **起義守城（A）** | 居民起義 + 個性偏「野心+慎重」 | `outpost_owner = village_team_id` |
| **起義流亡（B）** | 居民起義 + 個性偏「求生」 | 不變（居民離開 → 3 天後自動 -1）|
| **手動棄置** | 玩家 action `abandon_outpost` | `outpost_owner = -1` |
| **自動棄置** | outpost 無 owner team 接觸 + 無居民 持續 3 天 | `outpost_owner = -1` |

### B1 武力佔領

`encounter_system.resolve_encounter_end` 結算後加：

```gdscript
# B1: 戰勝接管 outpost
if result in ["attacker_win", "defender_win"]:
    var winner_id = atk_id if result == "attacker_win" else def_id
    var tile_pos = state.world.tiles 找 encounter tile_pos（接續既有 encounter location）
    var tile = state.world.tiles.get(...)
    if tile and tile.outpost_level > 0 and tile.outpost_owner != winner_id:
        var old_owner = tile.outpost_owner
        tile.outpost_owner = winner_id
        _emit_outpost_capture_message(old_owner, winner_id, tile.tile_pos)
```

注意：encounter 發生在 hexgrid tile 上，需從 state 拿 encounter 地點。

### 無人接管（新 tracking）

`TeamData` 新欄位 `var occupying_outpost_since: int = -1`：

```gdscript
# faction_ai 每輪 check
func _evaluate_outpost_takeover(state, team):
    var tile = state.world.tiles.get(team.tile_pos.x*1000 + team.tile_pos.y)
    if tile == null or tile.outpost_level == 0:
        team.occupying_outpost_since = -1
        return
    if tile.outpost_owner == team.team_id:
        team.occupying_outpost_since = -1
        return
    if tile.outpost_owner != -1:
        team.occupying_outpost_since = -1   # 有主人，不接管
        return
    # 無人 outpost
    if team.occupying_outpost_since == -1:
        team.occupying_outpost_since = state.world.current_tick
    elif state.world.current_tick - team.occupying_outpost_since >= 3 * WorldState.TICKS_PER_DAY:
        tile.outpost_owner = team.team_id
        team.occupying_outpost_since = -1
        _emit_outpost_claim_message(team.team_id, team.tile_pos)
```

### C1 外交勸降（重用 propose_alliance / offer_surrender）

`diplomatic_ai_system.handle_diplomacy_message` 既有 propose_alliance：成功 → `_form_alliance`。

新增：若 target 是居民團 → 連動 `tile.outpost_owner = sender_team_id`：

```gdscript
"propose_alliance":
    if _evaluate_alliance(...) > threshold:
        _form_alliance(state, sender_team, self_team)
        # 若 self 是居民團 → outpost 轉移
        if self_team.tags.has(TeamData.TAG_PRODUCE):
            var tile = state.world.tiles.get(...)
            if tile and tile.outpost_owner != sender_team.team_id:
                tile.outpost_owner = sender_team.team_id
                _emit_outpost_surrender_message(...)
```

### 起義路徑修正（修 E spec）

`faction_ai._evaluate_uprising` 改為：

```gdscript
# 起義觸發後，依 leader 個性選 A/B
var stand_score = ambition * 0.5 + prudence * 0.3 + honor * 0.2
var flee_score = survival * 0.5 + (1.0 - honor) * 0.3
if stand_score > flee_score:
    # A 守城型
    team.faction_id = -1
    team.current_task = "守城"
    var tile = ...
    if tile: tile.outpost_owner = team.team_id   # 居民變新 owner
    # tags 維持 ["生產"]（仍農民身分）
else:
    # B 流亡型（原 E spec 邏輯）
    team.faction_id = -1
    team.tags.erase(TeamData.TAG_PRODUCE)
    team.tags.append("流亡")
    team.current_task = "起義"
    # outpost 不變，等 3 天無人後自動 -1
```

### 手動棄置（新 player action）

`player_command_system` 加 `abandon_outpost`：

```gdscript
"abandon_outpost": _action_abandon_outpost,

func _action_abandon_outpost(state, target_id, pt, pt_id):
    var pos_arr = state.player_state.get("abandon_pos", [-1, -1])
    var pos = Vector2i(int(pos_arr[0]), int(pos_arr[1]))
    var tile = state.world.tiles.get(pos.x * 1000 + pos.y)
    if tile == null or tile.outpost_owner != pt_id:
        return { "ok": false, "msg": "非自家 outpost" }
    tile.outpost_owner = -1
    return { "ok": true, "msg": "已棄置 outpost (%d,%d)" % [pos.x, pos.y] }
```

### 自動棄置（新 tracking）

每個 tile 加暫存 last_owner_contact_tick？太重。改靠 `_evaluate_owner_contact` 反向：當居民團 trigger defection no_contact → outpost_owner = -1。

For outpost 無居民也無 owner 接觸 N 天 → 簡化用 tile.last_visit_tick（既有？若無則新增）。

實作上：每 tile 加 `var last_owner_visit_tick: int = -1`，owner team 抵達時更新；超過 30 天 → outpost_owner = -1。

→ 跟既有 intel snapshot 機制重複。可省略，靠居民 defection 路徑 + 戰勝接管 + 手動棄置足夠。**本 spec 暫不做純粹「無人 + 無居民」自動棄置**，列為後續。

## Movement 不需新限制

商隊維持任何 task 可動。task=貿易 + move_target = target tile，抵達後 `_resolve_pair` 觸發 market。

## 不變量

- `merchant_inventory` 元素 qty > 0；qty <= 0 時自動 erase
- `bought_at` > 0
- _resolve_market 結束後雙方 coin >= 0
- tile.outpost_owner 變更後 emit message
- 商隊 inventory 物品同一 grade 不合併（讓 bought_at 不同保留）

## 測試

`headless_test.gd`：

1. **merchant_inventory 欄位**：預設空 []
2. **_resolve_market 雙向**：A 賣 B + B 賣 A，雙方 resources/coin 都對
3. **商隊 inventory 賣利潤**：bought_at=10、buyer local_value=15 → 賣 5 個 → 商隊 coin+25
4. **商隊 inventory 不賣回賣家**：item.bought_from == buyer → skip
5. **_find_trade_target 找最大價差**：兩 target，價差大 → 選那個
6. **B1 武力佔領**：encounter attacker_win → tile.outpost_owner = attacker
7. **無人接管**：team 駐留 outpost 3 天 (current_tick 跳 720) → owner = team
8. **C1 外交勸降**：居民團接受 propose_alliance → outpost 轉移
9. **起義 A 守城**：野心高 leader → outpost_owner = village
10. **起義 B 流亡**：求生欲高 leader → outpost 不變、tags 變流亡
11. **手動棄置**：abandon_outpost action → owner = -1
12. **_calc_reserve food/coin** 計算正確

## 風險

- **_resolve_trade 拆除影響範圍**：所有 reference 改 _resolve_market，需 grep
- **商隊 inventory 賣 + buyer 商隊也買進 inventory** 同一 tx 中：兩層 inventory transfer 邏輯需驗
- **無人 outpost 自動接管**新欄位 `occupying_outpost_since` 在 team 移動時要重置
- **起義 A 改寫**會改 E spec 既有測試 → 需更新 Resident Task 9 測試
- **encounter location → outpost tile**：encounter 觸發位置需從 state 找

## 後續延伸

- 商隊 inventory 重量限制（wagons 連動）
- 商隊維護路線記憶（去過哪賺多少）
- 自動棄置「純無人 outpost N 天 → -1」（本 spec 暫不做）
- 殖民/開拓新 outpost（連動 NPC 基建 spec C）
- 多商隊競爭：到達順序、爭奪
