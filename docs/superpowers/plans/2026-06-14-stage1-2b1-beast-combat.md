# 階段1 Plan 2b-1：野獸戰鬥核心 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 危險野獸成為可獵的戰鬥對手 — 玩家進遭遇戰場景獵獸（激情時刻）、NPC 自動解算獵獸，勝得肉（食物緩衝），敗/傷走既有 body_parts。對稱、不破守恆。

**Architecture / 關鍵設計決策（reuse 人類戰鬥機制）：**
野獸 = 臨時 pseudo-team（`TAG_BEAST`，無 leader/外交/coin）。**不另寫戰鬥引擎** —
- **玩家路徑**（`encounter_system`）：beast unit = anon-like 單位，有 `body_parts`（自訂 HP）+ `戰鬥` skill（決命中）+ **「爪牙」偽武器 grade**（在 `ItemAttributes` 定 damage/range=1）裝在 `hand_1`。走既有 `resolve_attack` / `HealthSystem.receive_damage` / `is_dead` 不改。行為加 `_decide_action` beast 分支（逃型 retreat / 戰型 attack-nearest）。
- **NPC 路徑**（`npc_combat_system`）：beast team 有 `beast_strength` 欄位；`team_strength` 對 `TAG_BEAST` 回傳它；`population` = 獸數，傷亡走既有 `_apply_casualties`。
- **reward**：勝方得 `肉→food`（+ `皮→material`），分獸級；beast pseudo-team 戰畢清除（守恆：肉非 coin_eq 追蹤項，beast 無 coin/有限資源）。

**Tech Stack:** Godot 4.2.2 GDScript；headless 測試；`.\tools\godot.ps1` wrapper。

依據 spec：`docs/superpowers/specs/2026-06-14-stage1-survival-forage-hunt-design.md` §3（野獸）。伏擊偵測 + infamy 屬 **Plan 2b-2**（後續），本 plan 不做。

---

## 檔案結構

- `scripts/data/item_attributes.gd`（改）：ITEM_REGISTRY 加 `beast_claw_light` / `beast_claw_heavy`（武器類，range 1）。
- `scripts/data/team_data.gd`（改）：`TAG_BEAST` const + `beast_kind: String` + `beast_strength: float` 欄位。
- `scripts/simulation/world_generator.gd`（改）：`_apply_resources` 森林/山灑 `predator_density` + resource_cap。
- `scripts/simulation/harvest_system.gd`（改）：`_regen_predator`（月再生）。
- `scripts/simulation/beast_system.gd`（建）：`BeastSystem` — `build_beast_team(state, kind, pos)` 造臨時 pseudo-team；`BEAST_PROFILE`（獸級 → hp/戰鬥/claw/behavior/meat/strength/count）；`reward_and_cleanup(state, winner_id, beast_id)`。
- `scripts/simulation/encounter_system.gd`（改）：`_spawn_beast_units`；`_decide_action` beast 分支；`resolve_encounter_end` beast loser → reward+cleanup。
- `scripts/simulation/npc_combat_system.gd`（改）：`team_strength`/`_strength_raw` 認 beast；`_end_combat` beast loser → reward+cleanup。
- `scripts/simulation/player_command_system.gd`（改）：registry 加 `"hunt_beast"` → `_action_hunt_beast`（腳下有 predator → 起 beast 遭遇戰）。
- `scripts/debug/headless_test.gd`（改）：註冊測試。

---

## Task 1: ItemAttributes 爪牙 grade

**Files:**
- Modify: `scripts/data/item_attributes.gd`（ITEM_REGISTRY，`unarmed` 之後）
- Test: `scripts/debug/headless_test.gd`（新 `_test_beast_claw_damage`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_beast_claw_damage() -> void:
	print("--- 爪牙武器 grade ---")
	assert(ItemAttributes.get_damage("beast_claw_light") >= 10.0, "輕爪牙應有傷害")
	assert(ItemAttributes.get_damage("beast_claw_heavy") > ItemAttributes.get_damage("beast_claw_light"), "重爪牙傷害更高")
	assert(ItemAttributes.get_range("beast_claw_heavy") == 1, "爪牙近戰 range=1")
	print("beast claw OK")
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — 爪牙回 unarmed fallback（5.0），第二 assert 失敗（兩者相等）。

- [ ] **Step 3: 實作**

`item_attributes.gd` ITEM_REGISTRY，`"unarmed"` 區塊後加：

```gdscript
	"beast_claw_light": {
		"display_name": "爪牙",
		"category":     "weapon",
		"damage":       12.0,
		"range":        1,
		"is_2h":        false,
		"parry_chance": 0.0,
		"weight":       0.0,
	},
	"beast_claw_heavy": {
		"display_name": "巨爪利齒",
		"category":     "weapon",
		"damage":       22.0,
		"range":        1,
		"is_2h":        false,
		"parry_chance": 0.0,
		"weight":       0.0,
	},
```

- [ ] **Step 4: 跑測試確認通過** — `beast claw OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/data/item_attributes.gd scripts/debug/headless_test.gd
git commit -m "feat: ItemAttributes 爪牙武器 grade（beast_claw_light/heavy）"
```

---

## Task 2: TeamData beast 欄位 + predator world-gen + 月再生

**Files:**
- Modify: `scripts/data/team_data.gd`（`TAG_BEAST` + 欄位）
- Modify: `scripts/simulation/world_generator.gd`（`predator_density`）
- Modify: `scripts/simulation/harvest_system.gd`（`_regen_predator`）
- Test: `scripts/debug/headless_test.gd`（新 `_test_predator_seeded`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_predator_seeded() -> void:
	print("--- predator_density 灑點 + tag ---")
	assert(TeamData.TAG_BEAST != null and TeamData.TAG_BEAST != "", "需 TAG_BEAST const")
	var state := WorldState.new()
	state.world = WorldData.new()
	var gen = load("res://scripts/simulation/world_generator.gd").new()
	gen.generate(state, { "radius": 4, "seed": 11, "resource_multiplier": 1.0 })
	var any_pred: bool = false
	for tid in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tid]
		if int(tile.resources.get("predator_density", 0)) > 0:
			any_pred = true
			assert(tile.terrain != "plains", "predator 偏森林/山，不灑平原（TEST 假設）")
	assert(any_pred, "應有 tile 帶 predator_density")
	print("predator seeded OK")
```

- [ ] **Step 2: 跑測試確認失敗** — FAIL：`TAG_BEAST` 未定義 / 無 predator。

- [ ] **Step 3: 實作**

`team_data.gd`：
```gdscript
const TAG_BEAST := "野獸"
```
欄位區（`forage_today` 附近）：
```gdscript
var beast_kind: String = ""       # 非空 = 此 team 為野獸 pseudo-team（鹿/野豬/熊/狼群）
var beast_strength: float = 0.0   # npc_combat 用：beast team 的整體戰鬥力
```

`world_generator.gd` const 區：
```gdscript
const PREDATOR_FOREST_CHANCE: float = 0.12   # TEST VALUE
const PREDATOR_MOUNTAIN_CHANCE: float = 0.15 # TEST VALUE
const PREDATOR_MAX: int = 2
```
`_apply_resources`，wild_game 區塊後加（確保在 resource_cap duplicate 之後則補寫 cap，比照 Plan 2a Task1 做法）：
```gdscript
	match tile.terrain:
		"forest":
			if rng.randf() < PREDATOR_FOREST_CHANCE:
				tile.resources["predator_density"] = rng.randi_range(1, PREDATOR_MAX)
		"mountain":
			if rng.randf() < PREDATOR_MOUNTAIN_CHANCE:
				tile.resources["predator_density"] = rng.randi_range(1, PREDATOR_MAX)
	# 若上述在 resource_cap duplicate 之後：補 tile.resource_cap["predator_density"] = 初始值
```

`harvest_system.gd`：const `PREDATOR_REGEN_CHANCE: float = 0.10`；新增 `_regen_predator`（比照 `_regen_wild_game`，cap 用 `resource_cap["predator_density"]`，僅 forest/mountain）；`tick_all` 月邊界呼叫。

- [ ] **Step 4: 跑測試確認通過** — `predator seeded OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/data/team_data.gd scripts/simulation/world_generator.gd scripts/simulation/harvest_system.gd scripts/debug/headless_test.gd
git commit -m "feat: TAG_BEAST + beast 欄位 + predator_density 生成/再生"
```

---

## Task 3: BeastSystem.build_beast_team

**Files:**
- Create: `scripts/simulation/beast_system.gd`
- Test: `scripts/debug/headless_test.gd`（新 `_test_build_beast_team`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_build_beast_team() -> void:
	print("--- BeastSystem 造獸隊 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var bs := BeastSystem.new()
	var bid: int = bs.build_beast_team(state, "boar", Vector2i(4, 4))
	assert(state.teams.has(bid), "獸隊應入 state.teams")
	var bt: TeamData = state.teams[bid]
	assert(bt.tags.has(TeamData.TAG_BEAST), "應有 TAG_BEAST")
	assert(bt.beast_kind == "boar", "kind=boar")
	assert(bt.beast_strength > 0.0, "beast_strength>0")
	assert(bt.population >= 1, "獸數>=1")
	assert(bt.faction_id == -1, "野獸無 faction")
	print("build beast OK")
```

- [ ] **Step 2: 跑測試確認失敗** — FAIL：`BeastSystem` 不存在。

- [ ] **Step 3: 實作**

新建 `scripts/simulation/beast_system.gd`：

```gdscript
class_name BeastSystem

# 獸級 → 戰鬥/獎勵/行為。TEST VALUE 全待量測。
# behavior: "flee"(鹿,逃型) / "fight"(豬,戰型) / "predator"(熊狼,戰型且兇)
const BEAST_PROFILE: Dictionary = {
	"deer":  { "count": 1, "hp_mult": 0.6, "combat": 0.1, "claw": "beast_claw_light",
	           "behavior": "flee",  "meat": 25.0, "hide": 0.0,  "strength": 2.0 },
	"boar":  { "count": 1, "hp_mult": 1.0, "combat": 0.4, "claw": "beast_claw_light",
	           "behavior": "fight", "meat": 40.0, "hide": 5.0,  "strength": 8.0 },
	"bear":  { "count": 1, "hp_mult": 2.0, "combat": 0.7, "claw": "beast_claw_heavy",
	           "behavior": "predator", "meat": 80.0, "hide": 15.0, "strength": 20.0 },
	"wolves":{ "count": 4, "hp_mult": 0.7, "combat": 0.5, "claw": "beast_claw_light",
	           "behavior": "predator", "meat": 50.0, "hide": 10.0, "strength": 16.0 },
}

var _next_beast_id: int = -1000000   # 負區段 id，避開正常 team id

# 造臨時野獸 pseudo-team，入 state.teams，回傳 team_id。
func build_beast_team(state: WorldState, kind: String, pos: Vector2i) -> int:
	var prof: Dictionary = BEAST_PROFILE.get(kind, BEAST_PROFILE["boar"])
	var t := TeamData.new()
	t.team_id = _next_beast_id
	_next_beast_id -= 1
	t.tags = [TeamData.TAG_BEAST]
	t.beast_kind = kind
	t.beast_strength = float(prof["strength"])
	t.population = int(prof["count"])
	t.tile_pos = pos
	t.faction_id = -1
	t.leader_id = -1
	t.named_members = []
	t.anon_tiers = {}
	t.resources = {}
	t.armed_anon_ratio = 1.0   # 全員上場
	state.teams[t.team_id] = t
	state.team_known[t.team_id] = []
	state.team_discovered[t.team_id] = []
	return t.team_id

# 獸戰結束：勝方得肉(food)+皮(material)，清除獸隊。
func reward_and_cleanup(state: WorldState, winner_id: int, beast_id: int) -> void:
	var beast: TeamData = state.teams.get(beast_id)
	var winner: TeamData = state.teams.get(winner_id)
	if beast != null and winner != null:
		var prof: Dictionary = BEAST_PROFILE.get(beast.beast_kind, {})
		winner.resources["food"] = float(winner.resources.get("food", 0)) + float(prof.get("meat", 0))
		winner.forage_today = float(winner.forage_today) + float(prof.get("meat", 0))
		if float(prof.get("hide", 0)) > 0:
			winner.resources["material"] = float(winner.resources.get("material", 0)) + float(prof["hide"])
		print("[BeastHunt] Team%d 獵 %s 得肉%d" % [winner_id, beast.beast_kind, int(prof.get("meat", 0))])
	_cleanup(state, beast_id)

func _cleanup(state: WorldState, beast_id: int) -> void:
	state.teams.erase(beast_id)
	state.team_known.erase(beast_id)
	state.team_discovered.erase(beast_id)
	for obs in state.team_discovered:
		state.team_discovered[obs].erase(beast_id)
```

注意：確認 `TeamData` 有 `armed_anon_ratio` 欄位（既有，encounter spawn 用）。`_next_beast_id` 用負區段避免與正常 team id 衝突。

- [ ] **Step 4: 重建 class 快取 + 測試** — `.\tools\godot.ps1 --headless --import` 後跑，期 `build beast OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/beast_system.gd scripts/debug/headless_test.gd
git commit -m "feat: BeastSystem.build_beast_team + BEAST_PROFILE + reward/cleanup"
```

---

## Task 4: encounter beast 單位 spawn + 行為

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`（`_spawn_beast_units` + `_spawn_team_units` beast 分流 + `_decide_action` beast 分支）
- Test: `scripts/debug/headless_test.gd`（新 `_test_beast_encounter_resolve`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_beast_encounter_resolve() -> void:
	print("--- 獵獸遭遇戰解算 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4); tile.terrain = "forest"
	tile.resources = {}
	state.world.tiles[tile.tile_id] = tile
	# 獵人隊（強，應能勝）
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"戰鬥": 0.8}
	state.persons[0] = leader
	var hunter := TeamData.new()
	hunter.team_id = 0; hunter.leader_id = 0; hunter.population = 5; hunter.tile_pos = Vector2i(4,4)
	hunter.armed_anon_ratio = 1.0
	hunter.resources = {"food": 0.0, "weapon_melee_low": 5}
	state.teams[0] = hunter
	var bs := BeastSystem.new()
	var bid: int = bs.build_beast_team(state, "boar", Vector2i(4,4))
	var enc := EncounterSystem.new()
	enc.init_encounter(state, 0, bid, "normal")
	# 推進到結束
	var result: String = "ongoing"
	var guard: int = 0
	while result == "ongoing" and guard < 2000:
		result = enc.advance_encounter_tick(state)
		guard += 1
	assert(result != "ongoing", "遭遇戰應結束，實際=%s" % result)
	enc.resolve_encounter_end(state, result)
	# 獸隊應被清除
	assert(not state.teams.has(bid), "獸隊戰畢應清除")
	print("beast encounter OK (result=%s, hunter_food=%.0f)" % [result, float(hunter.resources.get("food",0))])
```

- [ ] **Step 2: 跑測試確認失敗** — FAIL：beast 無正確 spawn（無 body_parts/claw）→ 可能卡 ongoing 或不清除。

- [ ] **Step 3: 實作**

`encounter_system.gd`：

(a) `_spawn_team_units` 開頭加 beast 分流：
```gdscript
func _spawn_team_units(state: WorldState, team: TeamData, positions: Array) -> void:
	if team.beast_kind != "":
		_spawn_beast_units(state, team, positions)
		return
	# ...既有人類 spawn...
```

(b) 新增 `_spawn_beast_units`（beast 單位：claw 裝 hand_1、戰鬥 skill、body_parts、behavior）：
```gdscript
func _spawn_beast_units(state: WorldState, team: TeamData, positions: Array) -> void:
	var prof: Dictionary = BeastSystem.BEAST_PROFILE.get(team.beast_kind, {})
	var hp_mult: float = float(prof.get("hp_mult", 1.0))
	var pos_idx: int = 0
	for _n in range(team.population):
		if pos_idx >= positions.size(): break
		var pos: Vector2i = positions[pos_idx]; pos_idx += 1
		var unit: Dictionary = _create_anon_unit(team, pos)   # 取得 body_parts/equipment 骨架
		# 放大 body_parts HP（猛獸耐打）
		for part in unit["body_parts"].values():
			part["hp"] = part["hp"] * hp_mult
			part["max_hp"] = part["max_hp"] * hp_mult
		unit["equipment"]["hand_1"] = { "type": "innate", "grade": prof.get("claw", "beast_claw_light") }
		unit["skills"] = { "戰鬥": float(prof.get("combat", 0.3)) }
		unit["is_beast"] = true
		unit["beast_behavior"] = prof.get("behavior", "fight")
		state.encounter_units.append(unit)
	print("[Encounter] Beast %s spawn %d 隻" % [team.beast_kind, team.population])
```
注意：確認 `_create_anon_unit` 回傳含 `body_parts`（已讀：是）。`hand_1` 用 `type:"innate"` — 須確認 `_get_weapon_grade` 會讀 `grade`（讀該函數；若它只認 `type:"pool"`，beast 改用 `"pool"` 但 reward 時不歸還，或在 `_get_weapon_grade` 加 `innate` 分支回 grade）。

(c) `_decide_action` beast 分支（player 判定之後、人類戰術之前）：
```gdscript
	if unit.get("is_beast", false):
		var beh: String = unit.get("beast_behavior", "fight")
		if beh == "flee":
			return { "type": "retreat", "target_idx": -1,
				"move_to": _nearest_edge_pos(unit["pos"]), "attack_part": "" }
		var enemy_idx: int = _get_nearest_enemy_index(unit, state)
		if enemy_idx == -1:
			return { "type": "idle", "target_idx": -1, "move_to": unit["pos"], "attack_part": "" }
		var ep: Vector2i = state.encounter_units[enemy_idx]["pos"]
		if hex_dist(unit["pos"], ep) <= 1:
			return { "type": "attack", "target_idx": enemy_idx, "move_to": ep, "attack_part": "torso" }
		return { "type": "move", "target_idx": -1, "move_to": _calc_next_step(unit["pos"], ep), "attack_part": "" }
```

(d) `_get_weapon_grade`：確認/補 `innate` 分支回傳 `grade`（讓 resolve_attack 對 beast 取得爪牙傷害）。

- [ ] **Step 4: 重建快取 + 測試** — `build`/`import` 後跑，期 `beast encounter OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "feat: encounter beast 單位 spawn + 逃/戰行為 + 爪牙攻擊"
```

---

## Task 5: encounter resolve_encounter_end beast reward

**Files:**
- Modify: `scripts/simulation/encounter_system.gd`（`resolve_encounter_end` 加 beast 結算）
- Test: 併入 Task 4 的 `_test_beast_encounter_resolve`（已驗清除；本 task 補驗得肉）

- [ ] **Step 1: 擴充測試斷言**

在 `_test_beast_encounter_resolve` 末尾（resolve 後）加：
```gdscript
	if result == "attacker_win":
		assert(float(hunter.resources.get("food", 0)) > 0.0, "勝獵應得肉")
```

- [ ] **Step 2: 跑確認失敗** — 勝了但 food=0（reward 未接）。

- [ ] **Step 3: 實作**

`resolve_encounter_end`，在既有 loot/結算邏輯處，判斷 loser 是否 beast：
```gdscript
	# 野獸結算：勝方得肉，獸隊清除（取代一般 loot/subjugate）
	for pair in [[atk_id, def_id], [def_id, atk_id]]:
		var w: TeamData = state.teams.get(pair[0])
		var l: TeamData = state.teams.get(pair[1])
		if l != null and l.beast_kind != "":
			var won: bool = (result == "attacker_win" and pair[0] == atk_id) \
				or (result == "defender_win" and pair[0] == def_id)
			if won:
				BeastSystem.new().reward_and_cleanup(state, pair[0], pair[1])
			else:
				BeastSystem.new()._cleanup(state, pair[1])   # 獸贏/平 → 仍清除獸隊（不殘留）
```
注意：beast 隊**不可**走既有人類 loot（treasury/mount/subjugate/occupy outpost）。確認上述判斷在那些人類結算**之前** return/skip beast 隊（beast 無 treasury/outpost，但避免誤呼叫）。實作者：在 beast loser 分支處理後，跳過該對的人類 loot 邏輯。

- [ ] **Step 4: 測試通過** — `beast encounter OK` 且勝時得肉
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/encounter_system.gd scripts/debug/headless_test.gd
git commit -m "feat: 獵獸勝方得肉 + 獸隊戰畢清除（encounter）"
```

---

## Task 6: npc_combat beast strength + reward

**Files:**
- Modify: `scripts/simulation/npc_combat_system.gd`（`team_strength`/`_strength_raw` 認 beast；`_end_combat` beast reward/cleanup）
- Test: `scripts/debug/headless_test.gd`（新 `_test_npc_hunt_beast`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_npc_hunt_beast() -> void:
	print("--- NPC 自動獵獸 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4); tile.terrain = "plains"
	state.world.tiles[tile.tile_id] = tile
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader
	var band := TeamData.new()
	band.team_id = 0; band.leader_id = 0; band.population = 12; band.tile_pos = Vector2i(4,4)
	band.readiness = 1.0; band.resources = {"food": 0.0, "weapon_melee_low": 10}
	state.teams[0] = band
	var bs := BeastSystem.new()
	var bid: int = bs.build_beast_team(state, "deer", Vector2i(4,4))   # 弱獸，band 應勝
	var nc := NpcCombatSystem.new()
	# beast strength 應被 team_strength 認得
	assert(nc.team_strength(state, bid) > 0.0, "beast team_strength 應 >0")
	nc.start_combat(state, 0, bid)
	# 解算數回合
	for _r in range(10):
		if not state.teams.has(bid): break
		nc._resolve_combat_round(state, 0, bid)
	# deer 弱 → band 應勝、獸清除、band 得肉
	assert(not state.teams.has(bid) or band.resources.get("food", 0) > 0.0,
		"band 應獵得肉或獸已清除")
	print("NPC hunt beast OK")
```

- [ ] **Step 2: 跑確認失敗** — `team_strength` 對 beast 回 0（無 anon/weapon）。

- [ ] **Step 3: 實作**

`npc_combat_system.gd`：
- `team_strength` 開頭：
```gdscript
func team_strength(state: WorldState, team_id: int) -> float:
	var team: TeamData = state.teams.get(team_id)
	if team != null and team.beast_kind != "":
		return team.beast_strength
	var base: float = _strength_raw(state, team_id)
	# ...既有...
```
- `_end_combat`（winner/loser 結算處）：若 loser 是 beast → `BeastSystem.new().reward_and_cleanup(state, winner_id, loser_id)`，跳過既有 subjugate/loot；若 winner 是 beast（band 敗）→ `BeastSystem.new()._cleanup(state, loser_is_beast_id)`（獸不佔領/不擄掠，僅清除）。

注意：beast 隊**不可**走 `_try_subjugate` / `subjugate_team` / pursuit。確認 `_end_combat` 對 beast 隊跳過那些。`_apply_casualties` 對 beast 隊（population=獸數、無 named）會走 anon 分支（`team.wounded += 1`）— 可接受（獸傷亡抽象計）；獸 population 歸 0 → 既有滅團路徑會嘗試 `_route_extinct_assets`（beast 無資源，安全），但**確認 beast 隊不被 faction_ai cleanup 當正常隊處理**（beast id 為負、無 faction，應免疫；若有疑慮在 cleanup 加 `beast_kind != "" → skip`）。

- [ ] **Step 4: 測試通過** — `NPC hunt beast OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/npc_combat_system.gd scripts/debug/headless_test.gd
git commit -m "feat: npc_combat 認 beast_strength + 獵獸 reward/cleanup"
```

---

## Task 7: 玩家 hunt_beast 指令

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`（registry + `_action_hunt_beast`）
- Test: `scripts/debug/headless_test.gd`（新 `_test_player_hunt_beast`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_player_hunt_beast() -> void:
	print("--- 玩家 hunt_beast 指令 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4); tile.terrain = "forest"
	tile.resources = {"predator_density": 1}
	state.world.tiles[tile.tile_id] = tile
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader; state.player_id = 0
	var team := TeamData.new()
	team.team_id = 0; team.leader_id = 0; team.population = 5; team.tile_pos = Vector2i(4,4)
	team.armed_anon_ratio = 1.0; team.resources = {"weapon_melee_low": 5}
	state.teams[0] = team
	var cmd := PlayerCommandSystem.new()
	var r: Dictionary = cmd.execute_action(state, -1, "hunt_beast")
	assert(r.get("ok", false), "有 predator 應可發起獵獸，msg=%s" % str(r.get("msg","")))
	assert(state.encounter_active, "應進入遭遇戰")
	# 無 predator 的格應失敗
	tile.resources["predator_density"] = 0
	state.encounter_active = false
	var r2: Dictionary = cmd.execute_action(state, -1, "hunt_beast")
	assert(not r2.get("ok", true), "無 predator 不應發起")
	print("player hunt_beast OK")
```

- [ ] **Step 2: 跑確認失敗** — `未知行動: hunt_beast`。

- [ ] **Step 3: 實作**

`player_command_system.gd`，registry 加 `"hunt_beast": _action_hunt_beast,`，並新增（簽名比照 self-action）：
```gdscript
func _action_hunt_beast(state: WorldState, _target: int, pt: TeamData, pt_id: int) -> Dictionary:
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or int(tile.resources.get("predator_density", 0)) <= 0:
		return { "ok": false, "msg": "此地無猛獸可獵" }
	# 依地形/隨機選獸級（簡版：森林→boar、山→bear）。TEST：先固定 boar
	var kind: String = "bear" if tile.terrain == "mountain" else "boar"
	tile.resources["predator_density"] = int(tile.resources["predator_density"]) - 1   # 枯竭
	var bs := BeastSystem.new()
	var bid: int = bs.build_beast_team(state, kind, pt.tile_pos)
	EncounterSystem.new().init_encounter(state, pt_id, bid, "normal")
	return { "ok": true, "msg": "發起獵 %s" % kind, "requires_preview": false }
```
注意：確認 `EncounterSystem.new()` 與 sim_runner 既有 encounter 實例不衝突（玩家指令觸發 encounter 的既有路徑 — 讀既有 `attack` 指令怎麼起 encounter，比照接同一條，避免雙實例 state 不一致）。建議：`_action_hunt_beast` 比照既有 `_action_attack` 的 encounter 觸發方式（可能是設 flag 由 runner init，而非直接 new）。實作者依既有 attack 觸發模式對齊。

- [ ] **Step 4: 測試通過** — `player hunt_beast OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat: 玩家 hunt_beast 指令（predator 格起獵獸遭遇戰）"
```

---

## Task 8: 註冊測試 + 整合驗證

**Files:**
- Modify: `scripts/debug/headless_test.gd`（`_initialize`）

- [ ] **Step 1: 註冊**

```gdscript
	_test_beast_claw_damage()
	_test_predator_seeded()
	_test_build_beast_team()
	_test_beast_encounter_resolve()
	_test_npc_hunt_beast()
	_test_player_hunt_beast()
```

- [ ] **Step 2: 全測試**

Run: `.\tools\godot.ps1 --headless --import`
Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 6 新測試 OK，無**新增** SCRIPT ERROR（Bug8 baseline 可接受）。

- [ ] **Step 3: 2 年 multi**

```bash
$env:SIM_CONFIGS = "survival_start,tyrant,warzone"; .\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd *> godot_beast_verify.log
iconv -f UTF-16LE -t UTF-8 godot_beast_verify.log > godot_beast_verify_u8.log
grep -a "CoinAudit\|SCRIPT ERROR\|多配置對比\|BeastHunt" godot_beast_verify_u8.log
```
驗收：三 config died=no、`coin_eq delta=0.00`（beast 給肉非 coin_eq）、無新增 SCRIPT ERROR、beast 隊不殘留（無負 id team 累積 → 可在 multi 末檢 `state.teams` 無 beast_kind 隊）。

注意：本 plan 玩家 hunt_beast 在 multi 不會被 NPC 觸發（NPC 主動獵獸屬後續），但 npc_combat beast 路徑須確認不被誤觸（multi 無 beast 隊自然生成 → beast 戰鬥不會在 multi 出現，除非 2b-2 接入）。故 multi 主要驗 **無回歸 + 守恆**。

- [ ] **Step 4: handback**

`docs/superpowers/handbacks/2026-06-14-stage1-2b1-beast-combat.md`。

---

## 注意事項（給實作者）

- **新增 `class_name`（BeastSystem）必先 `--import`** 再跑測試。
- **beast 隊用負 id**，避開正常 team id；務必確認 `faction_ai` cleanup / vision / 各遍歷 `state.teams` 的系統不把 beast 隊當正常隊誤處理（beast 無 faction、戰畢即清；有疑慮處加 `beast_kind != ""` skip）。
- **beast 不走人類 loot**：encounter resolve / npc_combat _end 對 beast loser 只給肉 + 清除，**跳過 subjugate / treasury / mount / occupy outpost**。
- **`innate` 武器型**：確認 `_get_weapon_grade` 讀得到 beast 爪牙 grade（Task 4d）；爪牙不在 team.resources、不歸還。
- **守恆**：Task 8 coin_eq delta 必須 0（beast 無 coin/有限資源，肉=food 非審計項）。
- **TEST VALUE**：BEAST_PROFILE 全數值 + predator 生成率 → 待 2b-2 接入伏擊後一起量測 tune。
- **encounter 觸發對齊**：`hunt_beast` 起 encounter 須比照既有 `_action_attack` 模式（Task 7 注意），勿自建第二條 encounter 生命週期。
- 伏擊偵測 + infamy + NPC 主動獵獸 = **Plan 2b-2**，不在本 plan。
