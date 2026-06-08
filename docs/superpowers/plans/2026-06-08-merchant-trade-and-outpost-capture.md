# 商隊真實貿易 + Outpost 攻佔/棄置 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A 統一 `_resolve_market` 雙向貿易 + merchant_inventory 跑商；D outpost 5 條易主路徑（武力/無人接管/外交勸降/起義/手動棄置）。

**Architecture:**
- `TeamData` 加 `merchant_inventory: Array` + `occupying_outpost_since: int`
- 重寫 `interaction_system._resolve_market` 取代 `_resolve_trade`
- `encounter_system.resolve_encounter_end` 加 outpost 接管
- `faction_ai_system` 加 `_evaluate_outpost_takeover`、改寫 `_evaluate_uprising`、`_find_trade_target` 改進
- `diplomatic_ai_system.handle_diplomacy_message` propose_alliance 加 outpost 連動
- `player_command_system` 加 `abandon_outpost`

**Tech Stack:** Godot 4.2.2 GDScript；headless test。

**Spec:** `docs/superpowers/specs/2026-06-08-merchant-trade-and-outpost-capture-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 加 `merchant_inventory`、`occupying_outpost_since` |
| `scripts/simulation/interaction_system.gd` | 拆 `_resolve_trade` → 新 `_resolve_market` + `_attempt_trade_direction` + `_execute_transfer` + `_calc_reserve` |
| `scripts/simulation/faction_ai_system.gd` | `_find_trade_target` 改進、新 `_evaluate_outpost_takeover`、改寫 `_evaluate_uprising` |
| `scripts/simulation/encounter_system.gd` | `resolve_encounter_end` 加武力佔領 outpost |
| `scripts/simulation/diplomatic_ai_system.gd` | propose_alliance 接受時加 outpost 連動 |
| `scripts/simulation/player_command_system.gd` | 加 `abandon_outpost` action |
| `scripts/debug/headless_test.gd` | 12 個測試 case |

## 執行測試的標準命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

---

## Task 1: TeamData 新欄位

**Files:**
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_merchant_capture_fields() -> void:
	print("--- Trade Task1: TeamData 新欄位 ---")
	var t := TeamData.new()
	assert(t.merchant_inventory == [], "預設 merchant_inventory 應為空")
	assert(t.occupying_outpost_since == -1, "預設 occupying_outpost_since 應 -1")
	t.merchant_inventory.append({ "grade": "food", "qty": 5, "bought_at": 2.0, "bought_from": 1 })
	assert(t.merchant_inventory.size() == 1)
	print("Trade Task1 OK")
```

加 `_test_merchant_capture_fields()` 到 `_initialize`。

- [ ] **Step 2: 跑測試失敗 → 加欄位**

於 `scripts/data/team_data.gd` 找 `var tax_rate: float = 0.3` 附近加：

```gdscript
var merchant_inventory: Array = []          # 商隊 inventory，元素: {grade, qty, bought_at, bought_from}
var occupying_outpost_since: int = -1       # 駐留無人 outpost 起始 tick，達 3 天接管
```

- [ ] **Step 3: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(team): merchant_inventory + occupying_outpost_since fields (Task 1)"
```

---

## Task 2: 拆 `_resolve_trade` → `_resolve_market` 基礎結構

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試（雙向 + resources surplus only）**

```gdscript
func _test_resolve_market_bidirectional() -> void:
	print("--- Trade Task2: _resolve_market 雙向 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# A：有 food surplus，缺 material
	var a := TeamData.new()
	a.team_id = 0; a.population = 10
	a.resources["food"] = 500.0
	a.resources["material"] = 5.0
	a.resources["coin"] = 200.0
	a.current_task = TeamData.TASK_TRADE
	state.teams[0] = a
	# B：有 material surplus，缺 food
	var b := TeamData.new()
	b.team_id = 1; b.population = 10
	b.resources["food"] = 10.0
	b.resources["material"] = 500.0
	b.resources["coin"] = 300.0
	state.teams[1] = b
	var inter := InteractionSystem.new()
	inter._resolve_market(state, a, b)
	# 預期：A 賣 food 給 B、B 賣 material 給 A
	assert(float(b.resources["food"]) > 10.0, "B 應收到 food")
	assert(float(a.resources["material"]) > 5.0, "A 應收到 material")
	print("Trade Task2 OK (a food=%.0f mat=%.0f, b food=%.0f mat=%.0f)" % [
		float(a.resources["food"]), float(a.resources["material"]),
		float(b.resources["food"]), float(b.resources["material"])])
```

- [ ] **Step 2: 跑測試失敗 → 加新函數**

打開 `scripts/simulation/interaction_system.gd`，加：

```gdscript
func _calc_reserve(team: TeamData, res: String) -> float:
	if res == "food":
		return float(team.population) * 0.1 * FOOD_RESERVE_TICKS
	elif res == "coin":
		return float(team.resources.get(res, 0)) * 0.5
	return 0.0

func _execute_transfer(seller: TeamData, buyer: TeamData, res: String, qty: int, price: float) -> void:
	seller.resources[res] = float(seller.resources.get(res, 0)) - qty
	buyer.resources[res] = float(buyer.resources.get(res, 0)) + qty
	buyer.resources["coin"] = float(buyer.resources.get("coin", 0)) - qty * price
	seller.resources["coin"] = float(seller.resources.get("coin", 0)) + qty * price

func _resolve_market(state: WorldState, a: TeamData, b: TeamData) -> void:
	_attempt_trade_direction(state, a, b)
	_attempt_trade_direction(state, b, a)
	if a.current_task == TeamData.TASK_TRADE: a.current_task = TeamData.TASK_IDLE
	if b.current_task == TeamData.TASK_TRADE: b.current_task = TeamData.TASK_IDLE

func _attempt_trade_direction(state: WorldState, seller: TeamData, buyer: TeamData) -> void:
	var buyer_coin: float = float(buyer.resources.get("coin", 0))
	if buyer_coin <= 0.0: return
	var s_leader = state.persons.get(seller.leader_id)
	var commerce: float = float(s_leader.skills.get("商業", 0.0)) if s_leader else 0.0
	# (1) inventory 段 Task 3 加；本 task 先做 resources surplus
	# (2) 賣 surplus
	for res in BASE_PRICE.keys():
		var stock: float = float(seller.resources.get(res, 0))
		var reserve: float = _calc_reserve(seller, res)
		var surplus: float = maxf(stock - reserve, 0.0)
		if surplus <= 0.0: continue
		var ask: float = _local_value(seller, res) * (1.0 - commerce * 0.1)
		var bid: float = _local_value(buyer, res)
		if ask <= 0.0 or ask >= bid: continue
		var qty: int = mini(int(surplus), int(buyer_coin / ask))
		if qty <= 0: continue
		_execute_transfer(seller, buyer, res, qty, ask)
		buyer_coin -= qty * ask
```

更新 `_resolve_pair` 觸發改為 `_resolve_market`：

```gdscript
if a.current_task == TeamData.TASK_TRADE or b.current_task == TeamData.TASK_TRADE:
	_resolve_market(state, a, b)
	return
```

- [ ] **Step 3: 移除舊 `_resolve_trade`（保留至 Task 5 cleanup）**

暫保留但 grep 所有 reference，確認 `_resolve_pair` 已切到 `_resolve_market`。

- [ ] **Step 4: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(market): _resolve_market bidirectional (resources only) (Task 2)"
```

---

## Task 3: merchant_inventory 賣/買兩段

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

```gdscript
func _test_merchant_inventory_trade() -> void:
	print("--- Trade Task3: 商隊 inventory 賺差價 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# 商隊 A：inventory 有 weapon_melee_low，bought_at=10
	var a := TeamData.new()
	a.team_id = 0; a.population = 5
	a.tags = ["商隊"]
	a.resources["coin"] = 0.0
	a.merchant_inventory.append({
		"grade": "weapon_melee_low", "qty": 5, "bought_at": 10.0, "bought_from": 99
	})
	a.current_task = TeamData.TASK_TRADE
	state.teams[0] = a
	# Buyer B：缺武器，coin 充足
	var b := TeamData.new()
	b.team_id = 1; b.population = 20   # 大隊缺武器 → local_value 高
	b.resources["coin"] = 500.0
	b.resources["weapon_melee_low"] = 0
	state.teams[1] = b
	var inter := InteractionSystem.new()
	inter._resolve_market(state, a, b)
	# 預期：A inventory 物品賣給 B，coin 多
	assert(float(a.resources["coin"]) > 0.0, "A 應收到 coin")
	assert(int(b.resources.get("weapon_melee_low", 0)) > 0, "B 應收到武器")
	# inventory 應減少或清空
	var remaining: int = 0
	for item in a.merchant_inventory: remaining += int(item.qty)
	assert(remaining < 5, "inventory 應減少（賣出部分）")
	print("Trade Task3 OK (A coin=%.0f, B 武器=%d, inv 剩 %d)" % [
		float(a.resources["coin"]), int(b.resources["weapon_melee_low"]), remaining])
```

- [ ] **Step 2: 跑測試失敗 → 加 inventory 段**

修改 `_attempt_trade_direction`，在 surplus 段前加 inventory 段：

```gdscript
# (1) seller 商隊優先賣 inventory
if seller.tags.has("商隊"):
	var inv_copy: Array = seller.merchant_inventory.duplicate()
	for item in inv_copy:
		if int(item.get("bought_from", -1)) == buyer.team_id: continue
		var bid: float = _local_value(buyer, item["grade"])
		if bid <= float(item["bought_at"]): continue
		var qty: int = mini(int(item["qty"]), int(buyer_coin / bid))
		if qty <= 0: continue
		# 轉移：buyer 收物品 + 付 coin，seller 收 coin
		buyer.resources[item["grade"]] = float(buyer.resources.get(item["grade"], 0)) + qty
		buyer.resources["coin"] = float(buyer.resources.get("coin", 0)) - qty * bid
		seller.resources["coin"] = float(seller.resources.get("coin", 0)) + qty * bid
		item["qty"] = int(item["qty"]) - qty
		buyer_coin -= qty * bid
	# 清空 qty<=0 的 inventory
	seller.merchant_inventory = seller.merchant_inventory.filter(func(it): return int(it.get("qty", 0)) > 0)
```

- [ ] **Step 3: 加買進 inventory（買方是商隊時，從 surplus 段把 buyer 物品從 resources 移到 inventory）**

在 surplus 段的 `_execute_transfer` 後加：

```gdscript
_execute_transfer(seller, buyer, res, qty, ask)
buyer_coin -= qty * ask
# 買方若是商隊 → 物品移到 inventory
if buyer.tags.has("商隊"):
	buyer.resources[res] = float(buyer.resources.get(res, 0)) - qty   # 從 resources 扣回
	buyer.merchant_inventory.append({
		"grade": res, "qty": qty, "bought_at": ask, "bought_from": seller.team_id
	})
```

- [ ] **Step 4: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(market): inventory sell + buy-into-inventory for 商隊 (Task 3)"
```

---

## Task 4: 改進 `_find_trade_target`（最大價差/距離）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_find_trade_target_max_gap() -> void:
	print("--- Trade Task4: _find_trade_target 最大價差 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var merchant := TeamData.new()
	merchant.team_id = 0; merchant.tile_pos = Vector2i(0, 0); merchant.population = 5
	merchant.resources["food"] = 100.0
	state.teams[0] = merchant
	state.team_discovered[0] = [1, 2]
	# Team 1: 近，價差小
	var t1 := TeamData.new()
	t1.team_id = 1; t1.tile_pos = Vector2i(1, 0); t1.population = 5
	t1.resources["food"] = 100.0
	state.teams[1] = t1
	state.team_intel[0] = { 1: { "food": 100.0, "population": 5 } }
	# Team 2: 遠，價差大
	var t2 := TeamData.new()
	t2.team_id = 2; t2.tile_pos = Vector2i(3, 0); t2.population = 50
	t2.resources["food"] = 0.0
	state.teams[2] = t2
	state.team_intel[0][2] = { "food": 0.0, "population": 50 }
	var fai := FactionAISystem.new()
	var target = fai._find_trade_target(state, merchant)
	# Team 2 食物缺 + 人多 → local_value 高，價差大；雖遠但 score 應較高
	assert(target == 2, "應選最大價差 target，實際=%d" % target)
	print("Trade Task4 OK (target=%d)" % target)
```

- [ ] **Step 2: 跑測試失敗 → 改 `_find_trade_target`**

替換現有實作：

```gdscript
const MERCHANT_MAX_RANGE: int = 20

func _find_trade_target(state: WorldState, merchant: TeamData) -> int:
	var best_id: int = -1
	var best_score: float = -1e9
	for tid in state.team_discovered.get(merchant.team_id, []):
		if tid == merchant.team_id: continue
		if not state.teams.has(tid): continue
		var t: TeamData = state.teams[tid]
		var dist: int = _hex_dist(merchant.tile_pos, t.tile_pos)
		if dist > MERCHANT_MAX_RANGE: continue
		var snap: Dictionary = state.team_intel.get(merchant.team_id, {}).get(tid, {})
		var max_gap: float = 0.0
		for res in InteractionSystem.BASE_PRICE:
			var my_val: float = InteractionSystem.new()._local_value(merchant, res)
			var their_val_est: float = my_val
			if snap.has(res) and res in ["food", "material"]:
				var pop: int = int(snap.get("population", 10))
				var stk: float = float(snap.get(res, 0))
				var target: float = float(pop) * float(InteractionSystem.TARGET_PER_POP.get(res, 1.0))
				var sr: float = clampf((target - stk) / maxf(target, 1.0), -0.5, 1.0)
				their_val_est = float(InteractionSystem.BASE_PRICE[res]) * (1.0 + sr)
			var gap: float = absf(their_val_est - my_val)
			if gap > max_gap: max_gap = gap
		var score: float = max_gap / float(maxi(dist, 1))
		if score > best_score:
			best_score = score
			best_id = tid
	return best_id
```

- [ ] **Step 3: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _find_trade_target uses max price gap / distance (Task 4)"
```

---

## Task 5: 移除舊 `_resolve_trade`

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Verify: grep references

- [ ] **Step 1: grep 所有 reference**

```bash
grep -rn "_resolve_trade\b" scripts/ --include="*.gd"
```

確認剩餘 reference 都指向 `_resolve_market`。

- [ ] **Step 2: 移除 `_resolve_trade` 函數定義**

刪掉 `interaction_system.gd` 內 `_resolve_trade` 函數整段。`_grow_commerce_skill` 等 helper 若需保留也保留。

- [ ] **Step 3: 跑測試確認無 regression**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/interaction_system.gd
git commit -m "refactor(market): remove deprecated _resolve_trade (Task 5)"
```

---

## Task 6: encounter outpost 武力佔領

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_encounter_capture_outpost() -> void:
	print("--- Trade Task6: 戰勝接管 outpost ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	# Outpost on (4,4) owned by Team 99
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(4, 4); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 99
	state.world.tiles[4004] = tile
	# Attacker Team 0, defender Team 99
	state.encounter_attacker_id = 0
	state.encounter_defender_id = 99
	state.encounter_active = true
	# Encounter 假設發生在 (4,4) — 模擬手動設
	var enc := EncounterSystem.new()
	enc.resolve_encounter_end(state, "attacker_win")
	# Outpost owner 應變 attacker
	assert(tile.outpost_owner == 0, "outpost owner 應變 attacker=0，實際=%d" % tile.outpost_owner)
	print("Trade Task6 OK")
```

- [ ] **Step 2: 跑測試失敗 → 加 outpost capture**

`encounter_system.resolve_encounter_end` 結尾加：

```gdscript
# D B1: 戰勝接管 outpost
if result in ["attacker_win", "defender_win"]:
	var winner_id: int = atk_id if result == "attacker_win" else def_id
	var loser_id: int  = def_id if result == "attacker_win" else atk_id
	# 找 encounter 地點（敗方 tile_pos 或 attacker tile_pos）
	var loser_team: TeamData = state.teams.get(loser_id)
	if loser_team != null:
		var tile_id: int = loser_team.tile_pos.x * 1000 + loser_team.tile_pos.y
		var tile: HexTileData = state.world.tiles.get(tile_id)
		if tile != null and tile.outpost_level > 0 and tile.outpost_owner != winner_id:
			var old_owner: int = tile.outpost_owner
			tile.outpost_owner = winner_id
			print("[Capture] Outpost (%d,%d) %d→%d" % [
				loser_team.tile_pos.x, loser_team.tile_pos.y, old_owner, winner_id])
```

- [ ] **Step 3: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "feat(encounter): B1 武力佔領 outpost on encounter win (Task 6)"
```

---

## Task 7: 無人 outpost 自動接管（3 天駐留）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_unowned_outpost_takeover() -> void:
	print("--- Trade Task7: 無人 outpost 3 天接管 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(2, 2); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = -1   # 無人
	state.world.tiles[2002] = tile
	var t := TeamData.new()
	t.team_id = 0; t.tile_pos = Vector2i(2, 2)
	state.teams[0] = t
	var fai := FactionAISystem.new()
	# 第一次：起始駐留
	state.world.current_tick = 0
	fai._evaluate_outpost_takeover(state, t)
	assert(t.occupying_outpost_since == 0, "起始 tick 應記")
	assert(tile.outpost_owner == -1, "尚未到 3 天")
	# 跳到 3 天後
	state.world.current_tick = 3 * WorldState.TICKS_PER_DAY
	fai._evaluate_outpost_takeover(state, t)
	assert(tile.outpost_owner == 0, "3 天後應接管，實際=%d" % tile.outpost_owner)
	assert(t.occupying_outpost_since == -1, "接管後 reset")
	print("Trade Task7 OK")
```

- [ ] **Step 2: 加函數**

```gdscript
const OUTPOST_TAKEOVER_DAYS: int = 3

func _evaluate_outpost_takeover(state: WorldState, team: TeamData) -> void:
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_level == 0:
		team.occupying_outpost_since = -1
		return
	if tile.outpost_owner == team.team_id:
		team.occupying_outpost_since = -1
		return
	if tile.outpost_owner != -1:
		team.occupying_outpost_since = -1
		return
	if team.occupying_outpost_since == -1:
		team.occupying_outpost_since = state.world.current_tick
		return
	if state.world.current_tick - team.occupying_outpost_since >= OUTPOST_TAKEOVER_DAYS * WorldState.TICKS_PER_DAY:
		tile.outpost_owner = team.team_id
		team.occupying_outpost_since = -1
		print("[Takeover] Team%d 接管無人 outpost (%d,%d)" % [
			team.team_id, team.tile_pos.x, team.tile_pos.y])
```

整合到 `evaluate_all` team loop：

```gdscript
_evaluate_outpost_takeover(state, team)
```

- [ ] **Step 3: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): _evaluate_outpost_takeover (3-day occupy unowned) (Task 7)"
```

---

## Task 8: propose_alliance 對居民團 → outpost 連動

**Files:**
- Modify: `scripts/simulation/diplomatic_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_alliance_outpost_transfer() -> void:
	print("--- Trade Task8: 居民團 alliance → outpost 轉 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(3, 3); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 99
	state.world.tiles[3003] = tile
	# Original owner Team 99 faction 10
	var owner := TeamData.new(); owner.team_id = 99; owner.faction_id = 10
	state.teams[99] = owner
	# 居民團 Team 0
	var v := TeamData.new()
	v.team_id = 0; v.faction_id = 10; v.tile_pos = Vector2i(3, 3)
	v.tags = [TeamData.TAG_PRODUCE]; v.population = 10
	var v_leader := PersonData.new(); v_leader.id = 100
	v_leader.values = { "義氣": 0.4, "信義": 0.5 }   # 中等義氣
	state.persons[100] = v_leader; v.leader_id = 100
	state.teams[0] = v
	# 攻方 Team 5 faction 20
	var attacker := TeamData.new(); attacker.team_id = 5; attacker.faction_id = 20
	attacker.tile_pos = Vector2i(3, 3)
	state.teams[5] = attacker
	state.create_faction(5)   # 確保 faction 20 存在
	# 模擬 alliance accept（直接呼叫 _form_alliance + outpost 連動）
	var diplo := DiplomaticAiSystem.new()
	diplo._form_alliance(state, attacker, v)
	# 自定 outpost 連動（_form_alliance 內加 if PRODUCE → tile.outpost_owner = sender.team_id）
	assert(tile.outpost_owner == 5, "outpost owner 應變攻方 5，實際=%d" % tile.outpost_owner)
	print("Trade Task8 OK")
```

- [ ] **Step 2: 修 `_form_alliance` 加 outpost 連動**

打開 `scripts/simulation/diplomatic_ai_system.gd`，找 `_form_alliance` 函數結尾加：

```gdscript
# D C1: 若 self (target) 是居民團 → outpost 轉移
if team_b.tags.has(TeamData.TAG_PRODUCE):
	var tile: HexTileData = state.world.tiles.get(team_b.tile_pos.x * 1000 + team_b.tile_pos.y)
	if tile != null and tile.outpost_level > 0 and tile.outpost_owner != team_a.team_id:
		var old_owner: int = tile.outpost_owner
		tile.outpost_owner = team_a.team_id
		print("[Surrender] 居民團 Team%d 投降，outpost (%d,%d) %d→%d" % [
			team_b.team_id, team_b.tile_pos.x, team_b.tile_pos.y, old_owner, team_a.team_id])
```

- [ ] **Step 3: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/diplomatic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(diplomacy): propose_alliance to villager → outpost transfer (Task 8)"
```

---

## Task 9: 起義 A/B 路徑（改 `_evaluate_uprising`）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試（守城 + 流亡）**

```gdscript
func _test_uprising_paths() -> void:
	print("--- Trade Task9: 起義 A 守城 vs B 流亡 ---")
	# Path A: 野心高 → 守城
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(0, 0); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 99
	state.world.tiles[0] = tile
	var v := TeamData.new()
	v.team_id = 0; v.population = 10; v.faction_id = 10
	v.tags = [TeamData.TAG_PRODUCE]; v.tile_pos = Vector2i(0, 0)
	v.tax_rate = 0.7; v.resources["food"] = 0; v.unrest_turns = 70
	var l := PersonData.new(); l.id = 100; l.loyalty = 0.1
	l.values = { "野心": 0.9, "慎重": 0.7, "義氣": 0.3, "求生欲": 0.2 }
	state.persons[100] = l; v.leader_id = 100
	state.teams[0] = v
	var fai := FactionAISystem.new()
	fai._evaluate_uprising(state, v)
	assert(tile.outpost_owner == 0, "Path A 應 outpost = village，實際=%d" % tile.outpost_owner)
	assert(v.current_task == "守城", "Path A task 應 守城")
	assert(v.tags.has(TeamData.TAG_PRODUCE), "Path A tags 仍 PRODUCE")
	# Path B: 求生欲高 → 流亡
	var state2 := WorldState.new()
	state2.world = WorldData.new()
	var tile2 := HexTileData.new()
	tile2.tile_pos = Vector2i(0, 0); tile2.outpost_level = 1
	tile2.outpost_type = "civilian"; tile2.outpost_owner = 99
	state2.world.tiles[0] = tile2
	var v2 := TeamData.new()
	v2.team_id = 0; v2.population = 10; v2.faction_id = 10
	v2.tags = [TeamData.TAG_PRODUCE]; v2.tile_pos = Vector2i(0, 0)
	v2.tax_rate = 0.7; v2.resources["food"] = 0; v2.unrest_turns = 70
	var l2 := PersonData.new(); l2.id = 100; l2.loyalty = 0.1
	l2.values = { "求生欲": 0.9, "野心": 0.2, "慎重": 0.2, "義氣": 0.2 }
	state2.persons[100] = l2; v2.leader_id = 100
	state2.teams[0] = v2
	var fai2 := FactionAISystem.new()
	fai2._evaluate_uprising(state2, v2)
	assert(tile2.outpost_owner == 99, "Path B outpost owner 暫不變")
	assert(v2.tags.has("流亡"), "Path B tags 應 流亡")
	assert(not v2.tags.has(TeamData.TAG_PRODUCE), "Path B tags 應 erase 生產")
	print("Trade Task9 OK")
```

- [ ] **Step 2: 改寫 `_evaluate_uprising`**

替換現有 spec E 的實作為：

```gdscript
func _evaluate_uprising(state: WorldState, team: TeamData) -> void:
	if not _is_resident_team(state, team): return
	if team.current_task in ["起義", "守城"]: return
	if team.current_task in SURVIVAL_TASKS: return
	var avg_loy: float = _avg_named_loyalty(state, team)
	if avg_loy >= 0.2: return
	if team.unrest_turns < 60: return
	if _count_stress_sources(state, team) < 2: return
	var leader: PersonData = state.persons.get(team.leader_id)
	if leader == null: return
	var ambition: float = float(leader.values.get("野心", 0.5))
	var prudence: float = float(leader.values.get("慎重", 0.5))
	var honor: float = float(leader.values.get("義氣", 0.5))
	var survival: float = float(leader.values.get("求生欲", 0.5))
	var stand_score: float = ambition * 0.5 + prudence * 0.3 + honor * 0.2
	var flee_score: float = survival * 0.5 + (1.0 - honor) * 0.3
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x * 1000 + team.tile_pos.y)
	if stand_score > flee_score:
		# Path A 守城
		team.faction_id = -1
		team.current_task = "守城"
		if tile: tile.outpost_owner = team.team_id
		print("[Uprising A] Team%d 守城（野心=%.2f）" % [team.team_id, ambition])
	else:
		# Path B 流亡（原 spec E 邏輯）
		team.faction_id = -1
		team.tags.erase(TeamData.TAG_PRODUCE)
		team.tags.append("流亡")
		team.current_task = "起義"
		team.move_target = Vector2i(-1, -1)
		print("[Uprising B] Team%d 流亡（求生=%.2f）" % [team.team_id, survival])
	# Cascade fear
	for tid in state.teams:
		var t: TeamData = state.teams[tid]
		if not t.tags.has(TeamData.TAG_PRODUCE): continue
		if _hex_dist(team.tile_pos, t.tile_pos) > 2: continue
		for pid in ([t.leader_id] as Array) + t.named_members:
			var p = state.persons.get(pid)
			if p: p.fear = minf(p.fear + 0.1, 1.0)
```

- [ ] **Step 3: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(uprising): A 守城 vs B 流亡 paths by leader values (Task 9)"
```

---

## Task 10: 玩家手動棄置（`abandon_outpost`）

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加測試**

```gdscript
func _test_abandon_outpost() -> void:
	print("--- Trade Task10: 玩家棄置 outpost ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100
	var tile := HexTileData.new()
	tile.tile_pos = Vector2i(5, 5); tile.outpost_level = 1
	tile.outpost_type = "civilian"; tile.outpost_owner = 0
	state.world.tiles[5005] = tile
	var pt := TeamData.new(); pt.team_id = 0; pt.leader_id = 100
	state.teams[0] = pt
	var pp := PersonData.new(); pp.id = 100; pp.team_id = 0
	state.persons[100] = pp
	state.player_state["abandon_pos"] = [5, 5]
	var cmd := PlayerCommandSystem.new()
	var r: Dictionary = cmd.execute_action(state, -1, "abandon_outpost")
	assert(r.get("ok", false), "abandon 應成功")
	assert(tile.outpost_owner == -1, "outpost owner 應 -1，實際=%d" % tile.outpost_owner)
	print("Trade Task10 OK")
```

- [ ] **Step 2: 加 action**

```gdscript
# player_command_system.gd action 註冊
"abandon_outpost": _action_abandon_outpost,
```

```gdscript
func _action_abandon_outpost(state: WorldState, _target_id: int, pt: TeamData, pt_id: int) -> Dictionary:
	var pos_arr: Array = state.player_state.get("abandon_pos", [-1, -1])
	var pos := Vector2i(int(pos_arr[0]), int(pos_arr[1]))
	if pos.x < 0:
		return { "ok": false, "msg": "未指定 outpost 位置" }
	var tile: HexTileData = state.world.tiles.get(pos.x * 1000 + pos.y)
	if tile == null or tile.outpost_level == 0:
		return { "ok": false, "msg": "目標無 outpost" }
	if tile.outpost_owner != pt_id:
		return { "ok": false, "msg": "非自家 outpost" }
	tile.outpost_owner = -1
	return { "ok": true, "msg": "已棄置 outpost (%d,%d)" % [pos.x, pos.y] }
```

- [ ] **Step 3: 跑測試通過 + Commit**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(player_cmd): abandon_outpost action (Task 10)"
```

---

## Task 11: 整合驗證 + game_sim_test 跑通

**Files:** 跑既有測試

- [ ] **Step 1: 全 headless test 跑**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

確認 Trade Task1-10 全 OK + 既有測試全過。

- [ ] **Step 2: game_sim_test 跑**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "ALL INVARIANTS|Feature 通|Trade|Capture|Takeover|Uprising|Surrender" | Select-Object -First 30
```

預期：ALL INVARIANTS PASSED，可能會出現 Trade/Capture/Uprising 等新 log。

- [ ] **Step 3: 若 game_sim_test 結果改變 → 更新測試斷言或 config**

可能性：
- Trade FEATURE 從 FAIL 變 OK（雙向 market 更易達成）
- Encounter 觸發後 outpost 易主，可能影響後續流程
- 起義 Path A 觸發後 outpost 變村民所有，玩家失去 outpost

若 invariant 違規 → debug。

- [ ] **Step 4: Commit（無 code 改動則跳過）**

---

## Task 12: Handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-08-merchant-trade-and-outpost-capture.md`

- [ ] **Step 1: 寫 handback**

```markdown
# Hand Back: Merchant Trade (A) + Outpost Capture (D)

## 實作摘要

- TeamData：新欄位 `merchant_inventory: Array`、`occupying_outpost_since: int`
- interaction_system：
  - 新 `_resolve_market(a, b)` 雙向結算
  - 新 `_attempt_trade_direction(seller, buyer)` 含 inventory 賣 + buyer 商隊買進 inventory
  - 新 `_execute_transfer`、`_calc_reserve` helpers
  - 移除舊 `_resolve_trade`
- faction_ai_system：
  - 改進 `_find_trade_target`（最大價差 / 距離）
  - 新 `_evaluate_outpost_takeover`（3 天駐留自動接管）
  - 改寫 `_evaluate_uprising`（A 守城 vs B 流亡 二路徑）
- encounter_system：`resolve_encounter_end` 加 B1 武力佔領
- diplomatic_ai_system：`_form_alliance` 加居民團 outpost 連動
- player_command_system：加 `abandon_outpost` action

## 行為變化

- 商隊真實跑商：有 inventory 機制、買低賣高賺差價
- 任何 team 可走 _resolve_market 雙向結算（不限商隊）
- 戰勝 outpost 自動易主
- 居民團 alliance 被勸降 → outpost 連動轉
- 居民起義依個性 → A 守城（變 owner）或 B 流亡
- 玩家可手動棄置自家 outpost
- 無人 outpost 任何 team 駐 3 天可接管

## 連動風險

- _resolve_trade 移除影響：grep 確認所有 reference 都改 _resolve_market
- 商隊買進 inventory 時 _execute_transfer 已加到 resources，需在 inventory append 後從 resources 扣回
- 起義 Path A 修改 spec E 既有行為，可能影響 game_sim_test 預期
- encounter 後 outpost 易主，連動 居民團 owner 變更 → E spec 偵測 → 7 天緩衝
- 武力佔領用 loser.tile_pos 找 outpost，若 loser team 已移動或被消滅可能找不到

## 待主 session 確認

- 商隊 inventory 上限機制（wagons 連動）獨立 spec
- 純無人 + 無居民 outpost 自動棄置（本 spec 暫不做）
- 殖民/開拓新 outpost（連動 NPC 基建 C spec）
```

- [ ] **Step 2: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-08-merchant-trade-and-outpost-capture.md
git commit -m "docs: A+D handback (Task 12)"
```
