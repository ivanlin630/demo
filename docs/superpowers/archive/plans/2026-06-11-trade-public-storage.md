# Trade 接公庫 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** trade 接 public_storage，居民團公庫物資進交易池 + trader 可跟空 outpost 公庫交易。

**Architecture:**
- `_resolve_market` 開頭 absorb 在自家 outpost 上 team 的 public_storage 進 team.resources
- `_resolve_market` 結尾 spill back 多出來的回 public_storage
- trader 抵達無 owner 駐紮的 outpost tile → trader vs 公庫交易

**Spec:** `docs/superpowers/specs/2026-06-11-trade-public-storage-design.md`

---

## 檔案

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/interaction_system.gd` | `_absorb_public_storage` / `_spill_back_public_storage` helper + `_resolve_market` 套用 + trader vs outpost virtual partner |
| `scripts/debug/headless_test.gd` | ~6 個測試 |

---

## Task 1: absorb / spill_back helpers

- [ ] **Step 1: 測試**

```gdscript
func _test_absorb_then_spill_no_trade() -> void:
	# Setup team 在自家 outpost，public_storage = { food:50 }, team.resources={food:10}
	# absorb → team.resources.food = 60, original = { food:10 }
	# spill_back（沒 trade）→ team.resources.food = 10, public_storage.food = 50（還原）
	# ...
	print("TradePublic Task1a OK")

func _test_absorb_only_at_own_outpost() -> void:
	# team 在別人 outpost 上 → 不 absorb
	# ...
	print("TradePublic Task1b OK")

func _test_spill_back_with_cap_overflow() -> void:
	# trade 後 team food 多 100，但 cap 只剩 30 → 30 進 storage, 70 留 team
	# ...
	print("TradePublic Task1c OK")
```

- [ ] **Step 2: 加 helper**

於 `interaction_system.gd` 加（見 spec）：

```gdscript
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

static func _spill_back_public_storage(state: WorldState, team: TeamData,
		original: Dictionary) -> void:
	var tile: HexTileData = state.world.tiles.get(
		team.tile_pos.x * 1000 + team.tile_pos.y)
	if tile == null or tile.outpost_owner != team.team_id: return
	for res in original:
		var current: float = float(team.resources.get(res, 0))
		var orig: float = float(original[res])
		var diff: float = current - orig
		var cap: float = OutpostSystem.new()._get_storage_cap(tile, res)
		var stored: float = float(tile.public_storage.get(res, 0))
		if diff >= 0:
			var space: float = maxf(cap - stored, 0.0)
			var deposit: float = minf(diff, space)
			tile.public_storage[res] = stored + deposit
			team.resources[res] = orig + (diff - deposit)
		else:
			tile.public_storage[res] = maxf(stored + diff, 0.0)
			team.resources[res] = orig
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(interaction): absorb/spill_back public_storage helpers (Task 1)"
```

---

## Task 2: `_resolve_market` 套用

- [ ] **Step 1: 測試**

```gdscript
func _test_resolve_market_absorbs_storage() -> void:
	# Setup: trader (a) + outpost owner (b) 同 tile
	# b 在自家 outpost: public_storage = { food: 100 }, team.resources = { coin: 50 }
	# a (trader): resources = { coin: 200, goods: 0 }
	# 跑 _resolve_market
	# Expected: a 用 coin 換 b 公庫食物，trade 後 b.resources 恢復 + public_storage 減
	# ...
	print("TradePublic Task2 OK")
```

- [ ] **Step 2: 改 `_resolve_market`**

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

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(interaction): _resolve_market absorb 公庫 (Task 2)"
```

---

## Task 3: trader 抵達空 outpost → vs 公庫交易

- [ ] **Step 1: 測試**

```gdscript
func _test_trader_vs_empty_outpost() -> void:
	# Setup: trader 在 outpost tile，但 outpost owner team 不在 tile
	# public_storage = { food: 100 }
	# Expected: trader vs 公庫交易發生（無 owner team 在場）
	# ...
	print("TradePublic Task3 OK")
```

- [ ] **Step 2: 加 trader vs outpost path**

於 `process_on_move`（或 `_try_interact`）內，trader 抵達 outpost tile + 無 partner team 同格時：

```gdscript
func _try_trader_vs_outpost(state: WorldState, trader: TeamData) -> bool:
	if trader.current_task != TeamData.TASK_TRADE: return false
	var tile: HexTileData = state.world.tiles.get(
		trader.tile_pos.x * 1000 + trader.tile_pos.y)
	if tile == null or tile.outpost_owner == -1: return false
	var owner: TeamData = state.teams.get(tile.outpost_owner)
	if owner == null: return false
	if owner.tile_pos == trader.tile_pos: return false   # owner 同格 → 走正常 _resolve_market
	# trader vs 公庫
	_resolve_market_trader_vs_storage(state, trader, owner, tile)
	return true

func _resolve_market_trader_vs_storage(state: WorldState, trader: TeamData,
		owner: TeamData, tile: HexTileData) -> void:
	# 把 owner.resources 暫存，注入 public_storage 後跑 _resolve_market
	var owner_original: Dictionary = owner.resources.duplicate()
	var owner_original_tile: Vector2i = owner.tile_pos
	owner.tile_pos = trader.tile_pos   # 暫設同 tile 讓 absorb 生效
	_resolve_market(state, trader, owner)
	owner.tile_pos = owner_original_tile
	# (resources 已經 absorb/spill_back 處理)
```

注意：本實作 owner 暫時 sync tile_pos，是 hack。乾淨版需獨立 trade path。

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(interaction): trader 抵達空 outpost 仍可交易 (Task 3)"
```

---

## Task 4: 整合驗證 + handback

- [ ] **Step 1: 跑全測試 + multi**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log -Encoding UTF8 | Select-String "Market|trade_success|Trade" | Group-Object | Sort-Object Count -Descending
```

預期：trade 成交 > 0、ALL INVARIANTS PASSED。

- [ ] **Step 2: 寫 handback**

`docs/superpowers/handbacks/2026-06-11-trade-public-storage.md`：

```markdown
# Hand Back: Trade 接公庫

## 實作摘要
- absorb / spill_back helpers
- _resolve_market 套用
- trader vs 空 outpost path

## 驗證
- headless: N/N
- multi: trade 成交 [數據]

## 待主 session
- 空 outpost trade hack（owner tile_pos 暫設）→ 後續清理
```

- [ ] **Step 3: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-11-trade-public-storage.md
git commit -m "docs: trade public storage handback (Task 4)"
```
