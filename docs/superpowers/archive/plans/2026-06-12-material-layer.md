# 設施改制 B 期（材料層）Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** herb/野馬群高產點圖塊 + 野馬→馴馬(horses)→戰馬(mounts)鏈 + wagons/medicine 配方 + 選址資源權重與多中心。

**Spec:** `docs/superpowers/specs/2026-06-12-material-layer-design.md`

**Verified facts:**
- `world_generator._apply_resources`：wild_horses 生成（plains 1% 1-2 / forest 0.5% 1，不入 resource_cap）；`WILD_HORSE_PLAINS_CHANCE` 等 const
- `harvest_system`：`_regen_wild_horses`（每月 5% +1，`WILD_HORSE_TILE_CAP`=3）、`_collect_wild_horses_by_outposts`（日批採 → `public_storage["mounts"]`，:66）
- `resource_system._collect_from_tile`（:106）generic loop 掃 `tile.resources` 全 key — **wild_horses 會被按 0.01 比例採成碎數（既有 leak，本期修）**；`FOOD_PER_MOUNT_PER_DAY=0.5`（:4）；`PUBLIC_RESOURCES`（:6 含 mounts）
- `outpost_system`：`STABLE_PRODUCE_PER_DAY=[0.3,0.7,1.0]` / `STABLE_FOOD_PER_DAY` / `produce_stable_day`（food→mounts 魔法，本期廢）；`MOUNT_STORAGE_CAP=[10,30,80]`；FACILITY_DEF v2 stable `allowed_outpost: ["civilian"]`
- `manufacturing_system.RECIPE_GROUPS`（A 期 4 組：manufacturing_level / smelter_level / weaponsmith_level / armorsmith_level；組內缺口排序）；`apothecary_level` group 尚未存在
- `encounter_system.apply_mount_loot`（kill_ratio 比例）
- `faction_ai_system._evaluate_new_outpost_location`（:1498 dist 2-5、score 無資源項、單中心 leader_team）；`_facility_terrain_fit`（A 期，藥坊 herb ×3 / 馬廄 wild_horses ×3 已寫）
- 測試：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`

---

## Task 1: 圖塊生成 + 再生（herb / 野馬草原）

**Files:**
- Modify: `scripts/simulation/world_generator.gd`, `scripts/simulation/harvest_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_herb_generation() -> void:
	# 1000 forest tile 樣本：~30% 有 herb 2-6；~5% 藥草林 10-20
	# plains 無 herb
	# ...
	print("Material Task1a OK")

func _test_horse_plain_generation() -> void:
	# plains ~3% 野馬草原 4-8（與既有 1% 1-2 並存）
	# ...
	print("Material Task1b OK")

func _test_herb_regen() -> void:
	# herb 月邊界 +1 至 cap（= 生成初始值）
	# ...
	print("Material Task1c OK")
```

- [ ] **Step 2: world_generator**

```gdscript
const HERB_FOREST_CHANCE: float = 0.30
const HERB_RICH_CHANCE: float = 0.05      # 藥草林（先 roll rich 再 roll 一般）
const WILD_HORSE_RICH_CHANCE: float = 0.03  # 野馬草原

# _apply_resources 內 match tile.terrain:
"forest":
	if rng.randf() < HERB_RICH_CHANCE:
		tile.resources["herb"] = rng.randi_range(10, 20)
	elif rng.randf() < HERB_FOREST_CHANCE:
		tile.resources["herb"] = rng.randi_range(2, 6)
	if rng.randf() < WILD_HORSE_FOREST_CHANCE:
		tile.resources["wild_horses"] = 1
"plains":
	if rng.randf() < WILD_HORSE_RICH_CHANCE:
		tile.resources["wild_horses"] = rng.randi_range(4, 8)
	elif rng.randf() < WILD_HORSE_PLAINS_CHANCE:
		tile.resources["wild_horses"] = rng.randi_range(1, 2)
```

herb 計入 `resource_cap`（採集型資源，cap = 初始值供再生上限）；wild_horses 維持不入 cap。

- [ ] **Step 3: harvest_system 再生**

```gdscript
const WILD_HORSE_TILE_CAP_RICH: int = 8   # 野馬草原 cap（一般點維持 3）

func _regen_herb(state: WorldState) -> void:
	# 月邊界：herb +1 至 resource_cap["herb"]
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		var cap: int = int(tile.resource_cap.get("herb", 0))
		if cap <= 0: continue
		var cur: int = int(tile.resources.get("herb", 0))
		if cur < cap:
			tile.resources["herb"] = cur + 1
```

`_regen_wild_horses` cap 改：tile 初始 ≥4（rich）→ cap 8，否則 3。

- [ ] **Step 4: 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/world_generator.gd scripts/simulation/harvest_system.gd scripts/debug/headless_test.gd
git commit -m "feat(material): herb/野馬草原 高產點生成 + 再生 (Task 1)"
```

---

## Task 2: horses 資源 + 日捕改制 + collect 排除 wild_horses

**Files:**
- Modify: `scripts/simulation/resource_system.gd`, `scripts/simulation/harvest_system.gd`, `scripts/simulation/outpost_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_collect_excludes_wild_horses() -> void:
	# tile 有 wild_horses=2 → _collect_from_tile 不採（活物），herb 正常採
	# ...
	print("Material Task2a OK")

func _test_daily_catch_to_horses() -> void:
	# 日捕 → public_storage["horses"]（非 mounts）；無馬廄 outpost 每日 cap 1
	# civilian stable Lv2 → 每日 cap 1+2=3
	# ...
	print("Material Task2b OK")
```

- [ ] **Step 2: 改動**

`resource_system`：
- `PUBLIC_RESOURCES` 加 `"horses"`
- `_collect_from_tile` 開頭加排除：`if res == "wild_horses": continue`
- horses 草料：mount 草料消耗行旁加 `horses × 0.5 food/day`（同公式，effective 不限 pop — 馴馬不騎）

`harvest_system._collect_wild_horses_by_outposts`：
- 產出 key `"mounts"` → `"horses"`
- 每 outpost 每日捕獲上限：`1 + tile.stable_level if civilian else 1`（民用馬廄=馴馬設施加成）
- storage cap 沿 `_get_storage_cap(tile, "horses")`

`outpost_system._get_storage_cap`：`"horses"` 分支同 `MOUNT_STORAGE_CAP`。

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/resource_system.gd scripts/simulation/harvest_system.gd scripts/simulation/outpost_system.gd scripts/debug/headless_test.gd
git commit -m "feat(material): horses 資源 + 日捕改制 + collect 排除活物 (Task 2)"
```

---

## Task 3: stable 雙態（military 訓練戰馬）+ 廢 food→mounts

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_military_stable_trains_mounts() -> void:
	# military outpost + stable Lv1 + public_storage horses=5 + owner food 足
	# 跑數日 → horses 減、mounts 增（0.3/日累積）
	# horses=0 → 不產
	# ...
	print("Material Task3a OK")

func _test_civilian_stable_no_training() -> void:
	# civilian stable 不跑訓練配方（只有捕獲加成，Task 2 已驗）
	# 廢 food→mounts：civilian stable 不再憑空生 mounts
	# ...
	print("Material Task3b OK")
```

- [ ] **Step 2: 改 stable**

FACILITY_DEF stable `allowed_outpost: ["civilian", "military"]`。

`produce_stable_day` 重寫：

```gdscript
# military：horses + 草料 → mounts（訓練）；civilian：無產出（捕獲加成在 harvest 端）
func produce_stable_day(state: WorldState, tile: HexTileData, day_fraction: float) -> void:
	if tile.stable_level <= 0: return
	if tile.outpost_type != "military": return
	var owner: TeamData = state.teams.get(tile.outpost_owner)
	if owner == null: return
	var horses_avail: float = float(tile.public_storage.get("horses", 0))
	if horses_avail < 1.0: return
	var lvl_idx: int = clampi(tile.stable_level - 1, 0, 2)
	var food_cost: float = STABLE_FOOD_PER_DAY[lvl_idx] * day_fraction
	if float(owner.resources.get("food", 0)) < food_cost: return
	owner.resources["food"] = float(owner.resources.get("food", 0)) - food_cost
	tile.stable_progress += STABLE_PRODUCE_PER_DAY[lvl_idx] * day_fraction
	if tile.stable_progress >= 1.0 - 1e-9:
		var trained: int = int(tile.stable_progress + 1e-9)
		trained = mini(trained, int(horses_avail))
		tile.stable_progress -= float(trained)
		tile.public_storage["horses"] = horses_avail - float(trained)
		var cap: float = _get_storage_cap(tile, "mounts")
		var stored: float = float(tile.public_storage.get("mounts", 0))
		tile.public_storage["mounts"] = minf(stored + float(trained), cap)
```

（生產人力 gate 在 tick_all 層既有，沿用）

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/outpost_system.gd scripts/debug/headless_test.gd
git commit -m "feat(material): stable 雙態 (military horses→mounts 訓練) + 廢 food→mounts (Task 3)"
```

---

## Task 4: wagons + medicine 配方

**Files:**
- Modify: `scripts/simulation/manufacturing_system.gd`
- Modify: `scripts/simulation/interaction_system.gd`（BASE_PRICE/TARGET_PER_POP 加 horses/medicine 若缺）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_wagon_recipe() -> void:
	# 工坊 + horses 1（team.resources）+ mat 6 + tools 1 → wagons
	# ...
	print("Material Task4a OK")

func _test_medicine_recipe() -> void:
	# apothecary_level 1 + herb 2 → medicine；無 herb 不產
	# ...
	print("Material Task4b OK")
```

- [ ] **Step 2: RECIPE_GROUPS 加**

```gdscript
# manufacturing_level 組加：
{ "out": "wagons", "rate_const": "WAGON_RATE", "in": { "horses": 1.0, "material": 6.0, "tools": 1.0 } },
# 新組：
"apothecary_level": [
	{ "out": "medicine", "rate_const": "MEDICINE_RATE", "in": { "herb": 2.0 } },
],
```

`WAGON_RATE` / `MEDICINE_RATE` 新 const（TEST VALUE 比照同級）。`TARGET_PER_POP` 加 wagons 0.2 / medicine 1.0 / horses 0.5（缺口排序用）。

注意：配方原料讀 team.resources — 居民團 absorb 公庫機制（trade 既有）不適用製造；製造端 horses 來源 = 居民團自有（採集/交易）。公庫 horses 供軍用訓練。herb 採集進 team ✓。

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/manufacturing_system.gd scripts/simulation/interaction_system.gd scripts/debug/headless_test.gd
git commit -m "feat(material): wagons/medicine 配方 (Task 4)"
```

---

## Task 5: 戰利品 horses + 選址改制

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`（horses loot）
- Modify: `scripts/simulation/faction_ai_system.gd`（選址）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_horses_loot() -> void:
	# loser horses=4, kill_ratio 0.5 → winner +2
	# ...
	print("Material Task5a OK")

func _test_siting_resource_weight() -> void:
	# 兩候選格同 productivity：鄰藥草林者 score 高 +30×N
	# ...
	print("Material Task5b OK")

func _test_siting_multi_center() -> void:
	# faction 第二 outpost 周邊富點進候選（非 leader 所在）
	# ...
	print("Material Task5c OK")
```

- [ ] **Step 2: horses loot**

`apply_mount_loot` 內 mounts 公式複製一份跑 `"horses"`。

- [ ] **Step 3: 選址改制**

`_evaluate_new_outpost_location`：

```gdscript
# 多中心：faction 所有 outpost + leader 所在
var centers: Array = [leader_team.tile_pos]
for tile_id in state.world.tiles:
	var t: HexTileData = state.world.tiles[tile_id]
	if t.outpost_owner == -1: continue
	var o: TeamData = state.teams.get(t.outpost_owner)
	if o != null and o.faction_id == leader_team.faction_id and leader_team.faction_id != -1:
		centers.append(t.tile_pos)
# 候選：任一 center 的 dist 2-5
# score 加資源權重（候選格本格+鄰6格）：
const SITE_RES_BONUS: Dictionary = {
	"herb": 30.0, "wild_horses": 25.0, "ore_iron": 20.0,
	"ore_gold": 35.0, "ore_silver": 35.0,
}
for d in [Vector2i.ZERO] + HEX_DIRS:
	var ntile = state.world.tiles.get(...)
	if ntile == null: continue
	for res in SITE_RES_BONUS:
		if float(ntile.resources.get(res, 0)) > 0:
			score += SITE_RES_BONUS[res]
```

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/encounter_system.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(material): horses loot + 選址資源權重/多中心 (Task 5)"
```

---

## Task 6: 整合驗證 + handback

**Files:**
- Create: `docs/superpowers/handbacks/2026-06-12-material-layer.md`

- [ ] **Step 1: 跑全測試 + multi**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log | Select-String "herb|horses|捕|訓練|藥坊|wagons|medicine" | Group-Object | Select-Object Count, Name | Sort-Object Count -Descending | Select-Object -First 15
```

驗收：
- herb 被採 > 0；horses 捕獲 > 0
- 新據點選址落在資源點旁（log 列選址 + 周邊資源）
- mounts 訓練（軍鎮成形才有 — 0 屬預期，記錄）
- ALL INVARIANTS PASSED；coin 等值守恆 delta 0

- [ ] **Step 2: handback + Commit**

```markdown
# Hand Back: B 期材料層
## 實作摘要 / 行為變化（herb 採集量、horses 捕獲量、選址分布）/ 驗證 / 待確認（生成率與捕獲率 tune、馬鎮 food 壓力觀察）
```

```powershell
git add docs/superpowers/handbacks/2026-06-12-material-layer.md
git commit -m "docs: material layer handback (Task 6)"
```
