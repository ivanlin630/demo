# 設施改制 A 期 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Slot 制 + 8 設施拆分（軍民歸屬）+ 需求迴路（地利×缺口×個性）+ 三級建造成本（建造守恆）+ 有限資源守恆審計 + 軍屯 + 生產人力 gate。驗收：multi 90 天 NPC 建造 > 0 且村莊設施組合 ≥2 種。

**Spec:** `docs/superpowers/specs/2026-06-12-facility-overhaul-design.md`

**Verified facts:**
- `OutpostSystem`：`OUTPOST_COST`（:10-18 civilian mat+coin / military mat+coin+weapon）、`UPGRADE_COST`（:28-31）、`FACILITY_DEF`（:44-78 4 設施）、`FARMING_CAP`/`MANUFACTURING_CAP`/`STABLE_CAP`、`start_build`（:268，:283 資源不足檢查）、`_subteam_upgrade_facility`（:444 用 UPGRADE_COST[facility]）、`tick_all`（mint/stable 產出）、`produce_stable_day`、`_tick_mint`
- `FactionAISystem._evaluate_infrastructure`（:1454）：(1) 升級 outpost (2) 擴建設施（**civilian only**、只看 cap、無 trigger_check 呼叫）(3) 蓋新 outpost。`_dispatch_facility_builder` 派子隊
- `ManufacturingSystem._run_recipes`（固定優先序：工藝品→高武→冶煉→低武→一般製造），跑在 `manufacturing_level > 0` 的 tile
- `AnonTierSystem.try_promote`（:178-196）：PROMOTION_COST 含 coin，直接蒸發
- `player_command_system`：RECRUIT_COST_ANON 50 / NAMED 150（:918/:1038 蒸發）
- `HexTileData` 既有欄位：farming_level / manufacturing_level / mint_level / stable_level / stable_progress
- 居民判定：`FactionAISystem._is_resident_team`；殘留檢查 `_has_resident_team_on_tile`
- 軍屯 filter 點：`_try_dispatch_or_invite`
- 測試：`.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`；新 class / const 改動後先 `--import`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/data/tile_data.gd` | 加 apothecary_level / smelter_level / weaponsmith_level / armorsmith_level |
| `scripts/simulation/outpost_system.gd` | FACILITY_DEF v2（8 設施 + allowed_outpost + 三級 cost）、FACILITY_SLOTS、slots_used、OUTPOST_COST 去 coin/weapon、生產人力 gate |
| `scripts/simulation/manufacturing_system.gd` | 配方拆 4 組（工坊/冶煉/武器/護甲）+ 組內缺口排序 |
| `scripts/simulation/faction_ai_system.gd` | `_evaluate_infrastructure` 重寫（score 公式 + 飢餓 override + 拆遷）+ 軍用 outpost 開放 + 軍屯 filter |
| `scripts/simulation/anon_tier_system.gd` | 升等 coin → anon_treasury |
| `scripts/simulation/player_command_system.gd` | 招募 coin → 目標 team |
| `scripts/debug/headless_test.gd` | ~14 測試 |

---

## Task 1: tile 欄位 + FACILITY_DEF v2 + slot 制

**Files:**
- Modify: `scripts/data/tile_data.gd`, `scripts/simulation/outpost_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_facility_def_v2() -> void:
	print("--- Facility Task1a: FACILITY_DEF v2 ---")
	assert(OutpostSystem.FACILITY_DEF.size() == 8)
	for f in ["farming", "workshop", "apothecary", "mint", "stable",
			"smeltery", "weaponsmith", "armorsmith"]:
		assert(OutpostSystem.FACILITY_DEF.has(f), "缺 %s" % f)
	assert(OutpostSystem.FACILITY_DEF["weaponsmith"]["allowed_outpost"] == ["military"])
	assert(OutpostSystem.FACILITY_DEF["farming"]["allowed_outpost"] == ["civilian"])
	# 三級成本：低級無 tools，中級含 tools，全部無 coin
	assert(not OutpostSystem.FACILITY_DEF["farming"]["cost"].has("coin"))
	assert(int(OutpostSystem.FACILITY_DEF["smeltery"]["cost"].get("tools", 0)) > 0)
	assert(int(OutpostSystem.FACILITY_DEF["farming"]["cost"].get("tools", 0)) == 0)
	print("Facility Task1a OK")

func _test_facility_slots() -> void:
	print("--- Facility Task1b: slot 制 ---")
	var tile := HexTileData.new()
	tile.outpost_type = "civilian"; tile.outpost_level = 1
	assert(OutpostSystem.slot_cap(tile) == 2)
	tile.outpost_level = 3
	assert(OutpostSystem.slot_cap(tile) == 5)
	tile.outpost_type = "military"; tile.outpost_level = 1
	assert(OutpostSystem.slot_cap(tile) == 1)
	tile.farming_level = 1; tile.weaponsmith_level = 2
	assert(OutpostSystem.slots_used(tile) == 2, "2 類設施 = 2 slot（level 不佔額外）")
	print("Facility Task1b OK")
```

- [ ] **Step 2: tile_data 加欄位**

```gdscript
var apothecary_level: int = 0
var smelter_level: int = 0
var weaponsmith_level: int = 0
var armorsmith_level: int = 0
```

- [ ] **Step 3: FACILITY_DEF v2 全表**

替換既有 FACILITY_DEF（廢 cap_by_outpost / trigger_check 字串；FARMING_CAP / MANUFACTURING_CAP / STABLE_CAP 刪除）：

```gdscript
const FACILITY_SLOTS: Dictionary = {
	"civilian": [2, 3, 5],
	"military": [1, 2, 3],
}

# 三級建造成本：低=純 mat / 中=mat+tools。建造守恆：無 coin、無有限資源。TEST VALUES
const FACILITY_DEF: Dictionary = {
	"farming": {
		"cost": { "material": 30, "tools": 0, "ticks": 720 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "farming_level",
		"leader_pref": { "慎重": 0.3 },
	},
	"workshop": {
		"cost": { "material": 60, "tools": 0, "ticks": 1680 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "manufacturing_level",
		"leader_pref": { "貪婪": 0.2 },
	},
	"apothecary": {
		"cost": { "material": 50, "tools": 2, "ticks": 1680 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "apothecary_level",
		"leader_pref": { "慎重": 0.2 },
	},
	"mint": {
		"cost": { "material": 100, "tools": 5, "ticks": 7200 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "mint_level",
		"leader_pref": { "貪婪": 0.4, "野心": 0.2 },
	},
	"stable": {
		"cost": { "material": 40, "tools": 0, "ticks": 3360 },
		"allowed_outpost": ["civilian"],
		"current_level_key": "stable_level",
		"required_terrain": "plains",
		"leader_pref": { "野心": 0.2, "好戰": 0.3 },
	},
	"smeltery": {
		"cost": { "material": 80, "tools": 3, "ticks": 3360 },
		"allowed_outpost": ["military"],
		"current_level_key": "smelter_level",
		"leader_pref": { "好戰": 0.2 },
	},
	"weaponsmith": {
		"cost": { "material": 80, "tools": 3, "ticks": 3360 },
		"allowed_outpost": ["military"],
		"current_level_key": "weaponsmith_level",
		"leader_pref": { "好戰": 0.4 },
	},
	"armorsmith": {
		"cost": { "material": 80, "tools": 3, "ticks": 3360 },
		"allowed_outpost": ["military"],
		"current_level_key": "armorsmith_level",
		"leader_pref": { "慎重": 0.3, "好戰": 0.2 },
	},
}

static func slot_cap(tile: HexTileData) -> int:
	var arr: Array = FACILITY_SLOTS.get(tile.outpost_type, [0, 0, 0])
	return int(arr[clampi(tile.outpost_level - 1, 0, 2)])

static func slots_used(tile: HexTileData) -> int:
	var n: int = 0
	for f in FACILITY_DEF:
		if int(tile.get(FACILITY_DEF[f]["current_level_key"])) > 0:
			n += 1
	return n
```

`UPGRADE_COST` 改同表衍生（×2 / ×3 by level），既有 `_subteam_upgrade_facility` 改讀 FACILITY_DEF cost × level 倍率。

- [ ] **Step 4: import + 跑 + Commit**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/data/tile_data.gd scripts/simulation/outpost_system.gd scripts/debug/headless_test.gd
git commit -m "feat(facility): FACILITY_DEF v2 8設施 + slot制 + 三級成本 (Task 1)"
```

---

## Task 2: outpost 本體成本 + 建造路徑去 coin

**Files:**
- Modify: `scripts/simulation/outpost_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_outpost_cost_no_finite() -> void:
	print("--- Facility Task2: outpost 本體成本守恆 ---")
	for lvl_cost in OutpostSystem.OUTPOST_COST["civilian"]:
		assert(not lvl_cost.has("coin") or int(lvl_cost.get("coin", 0)) == 0)
		assert(int(lvl_cost.get("weapon", 0)) == 0)
		assert(int(lvl_cost.get("tools", 0)) == 0, "civilian 純 mat")
	for lvl_cost in OutpostSystem.OUTPOST_COST["military"]:
		assert(int(lvl_cost.get("coin", 0)) == 0)
		assert(int(lvl_cost.get("weapon", 0)) == 0, "weapon 成本移除")
		assert(int(lvl_cost.get("tools", 0)) > 0, "military 要 tools")
	print("Facility Task2 OK")
```

- [ ] **Step 2: 改 OUTPOST_COST**

```gdscript
const OUTPOST_COST: Dictionary = {
	"civilian": [
		{ "material": 50,  "tools": 0 },
		{ "material": 150, "tools": 0 },
		{ "material": 400, "tools": 0 },
	],
	"military": [
		{ "material": 80,  "tools": 3 },
		{ "material": 200, "tools": 6 },
		{ "material": 500, "tools": 10 },
	],
}
```

`start_build` / 升級扣款路徑同步改（扣 material+tools，刪 coin/weapon 扣除）。

- [ ] **Step 3: 跑 + Commit**

```powershell
git add scripts/simulation/outpost_system.gd scripts/debug/headless_test.gd
git commit -m "feat(outpost): 本體成本 civilian 純mat / military mat+tools, 去 coin/weapon (Task 2)"
```

---

## Task 3: manufacturing 拆 4 配方組 + 缺口排序

**Files:**
- Modify: `scripts/simulation/manufacturing_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_workshop_recipes() -> void:
	# workshop（manufacturing_level）只產 goods/tools/arrows
	# tools = 4 mat（純可再生）；arrows = 3 mat
	# ...
	print("Facility Task3a OK")

func _test_armorsmith_recipes() -> void:
	# armorsmith_level > 0 → armor_low（2 iron+2 mat）/ armor_high（2 steel+3 mat）
	# ...
	print("Facility Task3b OK")

func _test_recipe_deficit_ordering() -> void:
	# workshop：arrows 存量 / target 最低 → 先做 arrows
	# ...
	print("Facility Task3c OK")

func _test_smeltery_separate() -> void:
	# 冶煉只在 smelter_level > 0 的 tile 跑；workshop tile 無冶煉
	# ...
	print("Facility Task3d OK")
```

- [ ] **Step 2: 拆 `_run_recipes` 為 4 組**

```gdscript
const RECIPE_GROUPS: Dictionary = {
	"manufacturing_level": [   # 工坊
		{ "out": "goods",  "rate_const": "GOODS_RATE",  "in": { "material": 3.0 } },
		{ "out": "tools",  "rate_const": "TOOLS_RATE",  "in": { "material": 4.0 } },
		{ "out": "arrows", "rate_const": "ARROWS_RATE", "in": { "material": 3.0 } },
		{ "out": "goods",  "rate_const": "CRAFT_RATE",  "in": { "gem": 1.0, "material": 4.0 } },  # 工藝品（高價值優先嘗試）
	],
	"smelter_level": [
		{ "out": "ore_steel", "rate_const": "SMELT_RATE", "in": { "ore_iron": 2.0, "material": 1.0 } },
	],
	"weaponsmith_level": [
		{ "out": "weapon_melee_low",   "rate_const": "MELEE_LOW_RATE",   "in": { "ore_iron": 2.0, "material": 3.0 } },
		{ "out": "weapon_ranged_low",  "rate_const": "RANGED_LOW_RATE",  "in": { "ore_iron": 2.0, "material": 4.0 } },
		{ "out": "weapon_melee_high",  "rate_const": "MELEE_HIGH_RATE",  "in": { "ore_steel": 2.0, "material": 3.0 } },
		{ "out": "weapon_ranged_high", "rate_const": "RANGED_HIGH_RATE", "in": { "ore_steel": 2.0, "material": 4.0 } },
	],
	"armorsmith_level": [
		{ "out": "armor_low",  "rate_const": "ARMOR_LOW_RATE",  "in": { "ore_iron": 2.0, "material": 2.0 } },
		{ "out": "armor_high", "rate_const": "ARMOR_HIGH_RATE", "in": { "ore_steel": 2.0, "material": 3.0 } },
	],
}
```

組內選擇：依 `stock(out) / (TARGET_PER_POP[out] × pop)` 最低者先做（缺口排序）；原料不足跳下一個。每設施每 tick 跑一條配方（worker_rate 乘產出沿用既有）。

新 rate consts：`TOOLS_RATE` / `ARROWS_RATE` / `ARMOR_LOW_RATE` / `ARMOR_HIGH_RATE`（TEST VALUE 比照同級 rate）。`TARGET_PER_POP` 加 `tools: 0.5` / `arrows: 2.0`（interaction_system 的 dict 同步或本檔自帶）。

固定優先序 `_run_recipes` 廢除。`process` 入口改掃 4 個 level key，各自有 level 才跑該組。

- [ ] **Step 3: 跑 + 修既有製造測試 + Commit**

```powershell
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
git add scripts/simulation/manufacturing_system.gd scripts/debug/headless_test.gd
git commit -m "feat(manufacturing): 拆 4 配方組 + 缺口排序 + tools/arrows/armor 配方 (Task 3)"
```

---

## Task 4: 需求迴路（_evaluate_infrastructure 重寫）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_terrain_fit_scores() -> void:
	# 鄰格有 ore_iron → weaponsmith terrain_fit = 3.0；無 herb → apothecary = 0.0
	# ...
	print("Facility Task4a OK")

func _test_hunger_override() -> void:
	# food < pop×2.4×7 → farming score 強制最高
	# slot 滿且無 farming → 回傳拆遷目標（score 最低設施）
	# ...
	print("Facility Task4b OK")

func _test_military_outpost_builds_weaponsmith() -> void:
	# military outpost + 鄰格 ore + 武裝缺口 → 評估選 weaponsmith
	# ...
	print("Facility Task4c OK")
```

- [ ] **Step 2: 重寫 `_evaluate_infrastructure` 步驟 (2)**

```gdscript
# (2) 擴建設施（軍民皆可；slot 制 + score 公式）
for tile_id in state.world.tiles:
	var tile: HexTileData = state.world.tiles[tile_id]
	if tile.outpost_owner != leader_team.team_id: continue
	if tile.construction_team_id != -1: continue
	var pick: Dictionary = _pick_facility(state, leader_team, tile, leader)
	if pick.is_empty(): continue
	if pick.has("demolish_first"):
		OutpostSystem.new().demolish_facility(state, tile, pick["demolish_first"])
	if _dispatch_facility_builder(state, leader_team, tile.tile_pos, pick["facility"]):
		return
```

```gdscript
func _pick_facility(state: WorldState, team: TeamData, tile: HexTileData,
		leader: PersonData) -> Dictionary:
	var os := OutpostSystem.new()
	var slot_full: bool = OutpostSystem.slots_used(tile) >= OutpostSystem.slot_cap(tile)
	var hungry: bool = float(team.resources.get("food", 0)) \
		< float(team.population) * 2.4 * 7.0
	# 飢餓 override：缺糧 → 農田最優先
	if hungry and tile.outpost_type == "civilian" \
			and int(tile.farming_level) == 0:
		if not slot_full:
			return { "facility": "farming" }
		var lowest: String = _lowest_score_facility(state, team, tile, leader)
		if lowest != "":
			return { "facility": "farming", "demolish_first": lowest }
		return {}
	var best: String = ""
	var best_score: float = 0.05   # 門檻：score 太低不蓋
	for f in OutpostSystem.FACILITY_DEF:
		var def: Dictionary = OutpostSystem.FACILITY_DEF[f]
		if not (tile.outpost_type in def["allowed_outpost"]): continue
		if def.has("required_terrain") and tile.terrain != def["required_terrain"]: continue
		var current: int = int(tile.get(def["current_level_key"]))
		if current > 0: continue          # 已有 → 升級走另一路徑
		if slot_full: continue
		var s: float = _facility_terrain_fit(state, f, tile) \
			* (1.0 + _facility_deficit(state, team, f)) \
			* _facility_personality(leader, def)
		if s > best_score:
			best_score = s
			best = f
	if best == "": return {}
	return { "facility": best }
```

`_facility_terrain_fit`（本格+鄰 6 格掃資源，照 spec 表）/ `_facility_deficit`（threshold 照 spec 表）/ `_facility_personality`（沿用 leader_pref dict：1.0 + Σ values×pref）。

注意：步驟 (2) 的 `tile.outpost_type != "civilian"` 過濾**刪除**（軍用開放）。

- [ ] **Step 3: demolish_facility helper（若不存在）**

outpost_system 加（既有 demolish 邏輯擴展）：歸零該設施 level key + log print。

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/simulation/outpost_system.gd scripts/debug/headless_test.gd
git commit -m "feat(faction_ai): 設施需求迴路 (地利×缺口×個性 + 飢餓override + 拆遷) (Task 4)"
```

---

## Task 5: 軍屯 filter + 生產人力 gate

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（軍屯）
- Modify: `scripts/simulation/outpost_system.gd` + `scripts/simulation/manufacturing_system.gd`（人力 gate）
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_military_residency_dispatch_only() -> void:
	# military tile 無居民 → residency 評估只走 dispatch，不 invite
	# ...
	print("Facility Task5a OK")

func _test_production_requires_resident() -> void:
	# mint/stable/manufacturing tile 無居民團 → 不產
	# 有 PRODUCE 居民團 → 產
	# ...
	print("Facility Task5b OK")
```

- [ ] **Step 2: 軍屯 filter**

`_try_dispatch_or_invite` 開頭：

```gdscript
if tile.outpost_type == "military":
	# 軍屯：只信任自己人（軍火庫不交給流民）
	if dispatch_score_ok and team.population >= 8:
		_dispatch_subteam_settle(state, team, tile)
	return
```

（dispatch 條件沿用既有個性判斷，僅去掉 invite fallback）

- [ ] **Step 3: 人力 gate**

`outpost_system.tick_all` 的 mint/stable 產出前 + `manufacturing_system.process` tile 過濾加：

```gdscript
if not _has_resident_on_tile(state, tile): continue
# helper: tile 上有 PRODUCE tag team（仿 faction_ai._has_resident_team_on_tile）
```

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/simulation/outpost_system.gd scripts/simulation/manufacturing_system.gd scripts/debug/headless_test.gd
git commit -m "feat(facility): 軍屯限子隊 + 生產人力 gate (Task 5)"
```

---

## Task 6: 守恆審計（升等/招募 coin 轉移化）

**Files:**
- Modify: `scripts/simulation/anon_tier_system.gd`
- Modify: `scripts/simulation/player_command_system.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 測試**

```gdscript
func _test_promotion_coin_to_treasury() -> void:
	# try_promote 後：team coin 減 X、anon_treasury 增 X（總量不變）
	# ...
	print("Facility Task6a OK")

func _test_recruit_coin_to_target() -> void:
	# 玩家招募：pt coin -50、tgt coin +50
	# ...
	print("Facility Task6b OK")
```

- [ ] **Step 2: 改**

`anon_tier_system.try_promote` 扣款 loop（:195-196）改：

```gdscript
for res in cost:
	var amt: float = float(cost[res]) * float(count)
	team.resources[res] = float(team.resources.get(res, 0)) - amt
	if res == "coin":
		team.anon_treasury += amt   # 守恆：訓練餉銀入公庫，不蒸發
```

`player_command_system` 招募扣款（:918 / :1038）後加目標 team 入帳：

```gdscript
tgt.resources["coin"] = float(tgt.resources.get("coin", 0)) + RECRUIT_COST_ANON  # / NAMED
```

- [ ] **Step 3: 武器/護甲銷毀路徑 audit**

```powershell
grep -rn "weapon_melee\|weapon_ranged\|armor_low\|armor_high" scripts/simulation/ | Select-String "= .* - |-= "
```

逐處確認是「轉移」（loot / 歸還 / 配發）非「銷毀」。發現銷毀點 → 改 loot/abandoned 轉移並記 handback。

- [ ] **Step 4: 跑 + Commit**

```powershell
git add scripts/simulation/anon_tier_system.gd scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat(economy): 有限資源守恆 (升等coin→treasury, 招募coin→對方) (Task 6)"
```

---

## Task 7: config 適配 + 整合驗證 + handback

**Files:**
- Modify: `config/*.json`（如需 tools 種子）
- Create: `docs/superpowers/handbacks/2026-06-12-facility-overhaul.md`

- [ ] **Step 1: config 檢查**

民用 outpost 純 mat → 開局不需 tools 種子。但 config 有 military outpost 預設者（tyrant/warzone/game_sim_test Team2）為既存建物不受影響。確認 config 解析無 coin/weapon 成本殘留假設。

- [ ] **Step 2: 跑全測試 + multi**

```powershell
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
.\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd > godot_multi.log 2>&1
Get-Content godot_multi.log | Select-String "蓋|建|facility|完工|拆除" | Group-Object | Select-Object Count, Name | Sort-Object Count -Descending | Select-Object -First 15
```

驗收：
- NPC 設施建造 > 0（baseline 0）
- 村莊設施組合差異度 ≥ 2 種（log 統計各 outpost 的設施 set）
- coin 總量恆定（multi 前後 sum(teams.coin + persons.coin + anon_treasury + public_storage.coin + abandoned_coin) 不變 — 可在 game_sim_multi 加統計）
- ALL INVARIANTS PASSED × 4 config

- [ ] **Step 3: handback**

```markdown
# Hand Back: 設施改制 A 期

## 實作摘要
[7 task 各檔]

## 行為變化
- NPC 建造數 [baseline 0 → 實測]
- 村莊組合差異 [列各村設施 set]
- coin 總量恆定驗證 [前後對比]
- 軍用 outpost 設施 / 軍屯派駐情況

## 驗證
[headless + invariants + multi]

## 待主 session 確認
- slot 數 / 地利係數 / 缺口門檻 / 成本 全 TEST VALUE tune
- 武器/護甲銷毀 audit 結果
- B 期（herb/野馬群/戰馬分離）依賴確認
```

- [ ] **Step 4: Commit**

```powershell
git add docs/superpowers/handbacks/2026-06-12-facility-overhaul.md config/
git commit -m "docs: facility overhaul handback (Task 7)"
```
