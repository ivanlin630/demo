# Mount 公庫系統 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** mounts 改 PUBLIC_RESOURCES。stable 產出 + outpost 鄰格 wild_horses 採集都進公庫。NPC AI 出征前 auto-withdraw。

**Architecture:**
- `PUBLIC_RESOURCES` 加 `"mounts"`（resource_system.gd）
- `produce_stable_day` 改進 `tile.public_storage["mounts"]`
- `harvest_system.tick_all` 加每日 outpost 鄰格 wild_horses 批採
- `faction_ai_system._auto_withdraw_mounts` 出征前依 task 拉 mount
- 玩家既有 withdraw/deposit 自動支援（PUBLIC 變更自動 OK）

**Spec:** `docs/superpowers/specs/2026-06-11-mount-public-storage-design.md`

**Class names (verified)**：`OutpostSystem` / `FactionAISystem` / `HarvestSystem` / `ResourceSystem`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/resource_system.gd` | `PUBLIC_RESOURCES` 加 `"mounts"` |
| `scripts/simulation/outpost_system.gd` | `produce_stable_day` mount 改進 public_storage；`_get_storage_cap` 加 mount entry（or 重用 generic）|
| `scripts/simulation/harvest_system.gd` | `tick_all` 加每日 outpost 鄰格 wild_horses 批採 |
| `scripts/simulation/faction_ai_system.gd` | `_auto_withdraw_mounts` + 串入 `evaluate_all` |
| `scripts/debug/headless_test.gd` | ~6 個測試 |

## 測試命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd
```

---

## Task 1: PUBLIC_RESOURCES 加 mounts + cap

**Files:**
- Modify: `scripts/simulation/resource_system.gd`
- Modify: `scripts/simulation/outpost_system.gd`（如需 mount 專屬 cap）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_mounts_in_public_resources() -> void:
	assert("mounts" in ResourceSystem.PUBLIC_RESOURCES)
	print("MountStorage Task1 OK")
```

- [ ] **Step 2: 改 const**

```gdscript
const PUBLIC_RESOURCES: Array = [
	"ore_gold", "ore_silver", "ore_iron", "ore_steel", "mounts"
]
```

- [ ] **Step 3: 確認 storage cap**

`_get_storage_cap` 既有用 generic（依 outpost_type / level），mount 直接套用。若想 mount 專屬 cap：

```gdscript
const MOUNT_STORAGE_CAP: Array = [10.0, 30.0, 80.0]

func _get_storage_cap(tile: HexTileData, res: String) -> float:
	if res == "mounts":
		return MOUNT_STORAGE_CAP[clampi(tile.outpost_level - 1, 0, 2)]
	var arr: Array = OUTPOST_STORAGE_CAP.get(tile.outpost_type, [100.0, 300.0, 800.0])
	return float(arr[clampi(tile.outpost_level - 1, 0, 2)])
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/resource_system.gd scripts/simulation/outpost_system.gd scripts/debug/headless_test.gd
git commit -m "feat(public): PUBLIC_RESOURCES 加 mounts + cap (Task 1)"
```

---

## Task 2: Stable 產出進公庫

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_stable_produces_to_public_storage() -> void:
	print("--- MountStorage Task2: stable 產出進公庫 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 5 * 1000 + 5; tile.tile_pos = Vector2i(5, 5)
	tile.terrain = "plains"; tile.outpost_type = "civilian"
	tile.outpost_level = 1; tile.outpost_owner = 0
	tile.stable_level = 1
	state.world.tiles[tile.tile_id] = tile
	var owner := TeamData.new()
	owner.team_id = 0; owner.resources = { "food": 500 }
	state.teams[0] = owner
	var os := OutpostSystem.new()
	# 跑一整天 day_fraction=1.0
	os.produce_stable_day(state, tile, 1.0)
	# 0.3/day → public_storage["mounts"] 加 (累積到 1 才 +1)
	# 跑 4 天確保 stable progress >= 1
	os.produce_stable_day(state, tile, 1.0)
	os.produce_stable_day(state, tile, 1.0)
	os.produce_stable_day(state, tile, 1.0)
	var stored: int = int(tile.public_storage.get("mounts", 0))
	assert(stored >= 1, "公庫應 >= 1, 實際=%d" % stored)
	assert(int(owner.resources.get("mounts", 0)) == 0, "owner team 不應拿 mount")
	print("MountStorage Task2 OK (stored=%d)" % stored)
```

- [ ] **Step 2: 改 `produce_stable_day`**

找 line 149，將 `owner.resources["mounts"]` 改為 `tile.public_storage["mounts"]`：

```gdscript
if tile.stable_progress >= 1.0 - 1e-9:
	var produced: int = int(tile.stable_progress + 1e-9)
	tile.stable_progress -= float(produced)
	# 改進公庫（受 cap 限制）
	var cap: float = _get_storage_cap(tile, "mounts")
	var stored: float = float(tile.public_storage.get("mounts", 0))
	var space: float = maxf(cap - stored, 0.0)
	var actual: float = minf(float(produced), space)
	tile.public_storage["mounts"] = stored + actual
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/outpost_system.gd scripts/debug/headless_test.gd
git commit -m "feat(stable): 產出進 public_storage 而非 owner.resources (Task 2)"
```

---

## Task 3: Harvest outpost 鄰格 daily 採集

**Files:**
- Modify: `scripts/simulation/harvest_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_outpost_collect_wild_horses() -> void:
	print("--- MountStorage Task3: outpost 鄰格採野馬 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = 240   # tick day 邊界
	# outpost tile
	var tile_op := HexTileData.new()
	tile_op.tile_id = 0; tile_op.tile_pos = Vector2i(0, 0)
	tile_op.outpost_level = 1; tile_op.outpost_owner = 0
	state.world.tiles[tile_op.tile_id] = tile_op
	# 鄰格有野馬
	var ntile := HexTileData.new()
	ntile.tile_id = 1 * 1000 + 0; ntile.tile_pos = Vector2i(1, 0)
	ntile.resources["wild_horses"] = 2
	state.world.tiles[ntile.tile_id] = ntile
	var hs := HarvestSystem.new()
	hs.tick_all(state)
	assert(int(tile_op.public_storage.get("mounts", 0)) == 2,
		"應收 2，實際=%d" % int(tile_op.public_storage.get("mounts", 0)))
	assert(int(ntile.resources.get("wild_horses", 0)) == 0, "野馬應清空")
	print("MountStorage Task3 OK")

func _test_outpost_collect_no_outpost_skip() -> void:
	# tile 沒 outpost → 不採
	# ...

func _test_outpost_collect_cap_limit() -> void:
	# 公庫滿了 → 不收（野馬留在 tile）
	# ...
```

- [ ] **Step 2: 加函數 + 串入 tick_all**

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
	# 既有 regen 等

func _collect_wild_horses_by_outposts(state: WorldState) -> void:
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		if tile.outpost_owner == -1 or tile.outpost_level == 0: continue
		var cap: float = OutpostSystem.new()._get_storage_cap(tile, "mounts")
		var stored: float = float(tile.public_storage.get("mounts", 0))
		for d in HEX_DIRS:
			var npos: Vector2i = tile.tile_pos + d
			var ntile: HexTileData = state.world.tiles.get(npos.x * 1000 + npos.y)
			if ntile == null: continue
			var wh: int = int(ntile.resources.get("wild_horses", 0))
			if wh <= 0: continue
			var space: float = maxf(cap - stored, 0.0)
			var taken: int = mini(wh, int(space))
			if taken > 0:
				stored += float(taken)
				ntile.resources["wild_horses"] = wh - taken
				tile.public_storage["mounts"] = stored
				print("[Mount] Outpost %s 採野馬 +%d" % [str(tile.tile_pos), taken])
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/harvest_system.gd scripts/debug/headless_test.gd
git commit -m "feat(harvest): outpost 鄰格 wild_horses 每日批採 (Task 3)"
```

---

## Task 4: NPC AI auto-withdraw

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_auto_withdraw_on_active_task() -> void:
	# Setup: team 在自家 outpost + task=攻擊 + public_storage 有 10 mounts
	# Expected: withdraw 達 target_ratio
	# ...
	print("MountStorage Task4a OK")

func _test_no_withdraw_when_idle() -> void:
	# task=idle → 不 withdraw
	# ...
	print("MountStorage Task4b OK")
```

- [ ] **Step 2: 加函數**

```gdscript
const MOUNT_TARGET_RATIO: float = 0.5

func _auto_withdraw_mounts(state: WorldState, team: TeamData) -> void:
	if team.current_task in ["idle", TeamData.TASK_PREPARE]: return
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
		print("[Mount] Team%d auto-withdraw %d mounts" % [team.team_id, take])
```

- [ ] **Step 3: 串入 `evaluate_all`**

於 task assign 後但 movement 前 call：

```gdscript
for tid in active_teams:
	var team: TeamData = state.teams[tid]
	# 既有 task 評估 / 派發 ...
	_auto_withdraw_mounts(state, team)
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): NPC auto-withdraw mounts on active task (Task 4)"
```

---

## Task 5: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-11-mount-public-storage.md`

- [ ] **Step 1: 跑全測試 + multi**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log -Encoding UTF8 | Select-String "auto-withdraw|採野馬|stable|Loot.*mount" | Group-Object | Select-Object Count, Name | Sort-Object Count -Descending
```

預期：multi 中可能看到 outpost 鄰格採馬 / NPC withdraw（如果有 stable 蓋出）。ALL INVARIANTS PASSED。

- [ ] **Step 2: 寫 handback**

`docs/superpowers/handbacks/2026-06-11-mount-public-storage.md`：

```markdown
# Hand Back: Mount 公庫系統

## 實作摘要

- PUBLIC_RESOURCES 加 mounts
- stable 產出 → tile.public_storage["mounts"]
- harvest 每日 outpost 鄰格 wild_horses 批採 → public_storage
- faction_ai _auto_withdraw_mounts NPC 出征前自動拉 mount

## 行為變化

- stable 產馬入公庫不入 team
- outpost 鄰格野馬每日被採
- NPC team 在自家 outpost + active task → 自動 withdraw 達 50% ratio
- 玩家 withdraw/deposit 既有路徑自動支援 mount

## 驗證結果

- headless_test：N/N 過
- game_sim_test：ALL INVARIANTS PASSED
- multi：[填數據]

## 待主 session 確認

- MOUNT_TARGET_RATIO 0.5 是否合理
- mount cap 10/30/80 是否合理
- 戰利品仍 team.resources（無自動 deposit）是否要加
```

- [ ] **Step 3: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-11-mount-public-storage.md
git commit -m "docs: mount public storage handback (Task 5)"
```
