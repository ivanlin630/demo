# 階段1 Plan 2a：小獵物食物層 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** tile 生成可獵小獵物（`wild_game`），隊伍能抽象狩獵得食物（求生技能 roll、枯竭、月再生），玩家有 `hunt` 指令、NPC 覓食時被動小獵。對稱、不破守恆。

**Architecture:** 純加值層，**不碰戰鬥系統**。`wild_game` 比照既有 `wild_horses`（tile 活物資源）生成 + 月再生。新增 `HuntSystem.hunt_small_game()` 做抽象 roll（求生 vs 獵物量 → 食物 + 枯竭）。玩家經 `hunt` 指令主動獵；NPC 覓食 tick 被動低率小獵。危險野獸戰鬥 / 伏擊偵測屬 Plan 2b，不在本 plan。

**Tech Stack:** Godot 4.2.2 GDScript；headless 測試（SceneTree + `assert`）；`.\tools\godot.ps1` wrapper。

依據 spec：`docs/superpowers/specs/2026-06-14-stage1-survival-forage-hunt-design.md` §2（小獵物）、§3 世界基底（`wild_game` 部分）。

---

## 檔案結構

- `scripts/simulation/world_generator.gd`（改）：`_apply_resources` 為平原/森林灑 `wild_game` + `resource_cap` 標記（比照 `wild_horses` 既有區塊，line 76-85 附近）。
- `scripts/simulation/harvest_system.gd`（改）：新增 `_regen_wild_game()`，`tick_all` 月邊界呼叫（比照 `_regen_wild_horses` line 31）。
- `scripts/simulation/hunt_system.gd`（建）：`HuntSystem.hunt_small_game(state, team, tile, active)` — 求生 roll → 食物 + 枯竭 `wild_game`。
- `scripts/simulation/resource_system.gd`（改）：`collect_resources` forage 分支後，若腳下 tile 有 `wild_game` → 被動低率呼叫 `hunt_small_game(active=false)`。
- `scripts/simulation/player_command_system.gd`（改）：registry 加 `"hunt"` → `_action_hunt`（主動狩獵）。
- `scripts/debug/headless_test.gd`（改）：註冊新測試。

---

## Task 1: world_generator 灑 wild_game

**Files:**
- Modify: `scripts/simulation/world_generator.gd`（`_apply_resources`，`wild_horses` 區塊附近 line 76-85）
- Test: `scripts/debug/headless_test.gd`（新 `_test_wild_game_seeded`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_wild_game_seeded() -> void:
	print("--- world_gen wild_game 灑點 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var gen = load("res://scripts/simulation/world_generator.gd").new()
	gen.generate(state, { "radius": 4, "seed": 7, "resource_multiplier": 1.0 })
	var any_game: bool = false
	var bad_terrain: bool = false
	for tid in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tid]
		var wg: int = int(tile.resources.get("wild_game", 0))
		if wg > 0:
			any_game = true
			if tile.terrain == "mountain":
				bad_terrain = true   # wild_game 只該在平原/森林
	assert(any_game, "應有 tile 帶 wild_game")
	assert(not bad_terrain, "wild_game 不應出現在 mountain")
	print("wild_game seeded OK")
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `any_game` false（尚未灑 wild_game）。

- [ ] **Step 3: 實作**

`world_generator.gd` const 區（`WILD_HORSE_*` 附近）加：

```gdscript
const WILD_GAME_PLAINS_CHANCE: float = 0.20   # TEST VALUE — 平原帶獵物機率
const WILD_GAME_FOREST_CHANCE: float = 0.30   # TEST VALUE — 森林獵物更多
const WILD_GAME_MIN: int = 2
const WILD_GAME_MAX: int = 6
```

`_apply_resources`，在既有 `wild_horses` match 區塊之後（line 85 附近、`tile.resource_cap = tile.resources.duplicate()` 計算之前須確保 cap 含 wild_game）加：

```gdscript
	# 野味（鹿/兔/豬）：平原/森林帶可獵小獵物，計入 resource_cap（月再生上限）
	match tile.terrain:
		"plains":
			if rng.randf() < WILD_GAME_PLAINS_CHANCE:
				tile.resources["wild_game"] = rng.randi_range(WILD_GAME_MIN, WILD_GAME_MAX)
		"forest":
			if rng.randf() < WILD_GAME_FOREST_CHANCE:
				tile.resources["wild_game"] = rng.randi_range(WILD_GAME_MIN, WILD_GAME_MAX)
```

**重要**：確認此區塊在 `tile.resource_cap = tile.resources.duplicate()`（line 73 附近）**之後**執行，則 wild_game 須另外寫入 cap。讀 `_apply_resources` 確認順序：
- 若 wild_game 在 `resource_cap` duplicate 之後加 → 補一行 `tile.resource_cap["wild_game"] = int(tile.resources.get("wild_game", 0))`（比照 wild_horses 富點寫 cap 的做法）。
- 若在之前 → duplicate 已涵蓋，免補。

（實作者：依實際行序處理，確保 `resource_cap["wild_game"]` = 初始值，供月再生 cap 判定。）

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `wild_game seeded OK`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/world_generator.gd scripts/debug/headless_test.gd
git commit -m "feat: world_generator 灑 wild_game（平原/森林，計入 resource_cap）"
```

---

## Task 2: harvest_system 月再生 wild_game

**Files:**
- Modify: `scripts/simulation/harvest_system.gd`（新 `_regen_wild_game`，`tick_all` 呼叫）
- Test: `scripts/debug/headless_test.gd`（新 `_test_wild_game_regen`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_wild_game_regen() -> void:
	print("--- wild_game 月再生 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.world.current_tick = WorldState.TICKS_PER_MONTH   # 月邊界
	var tile := HexTileData.new()
	tile.tile_id = 4 * 1000 + 4; tile.tile_pos = Vector2i(4, 4)
	tile.terrain = "forest"
	tile.resources = {"wild_game": 1}
	tile.resource_cap = {"wild_game": 5}
	state.world.tiles[tile.tile_id] = tile
	var hs := HarvestSystem.new()
	# 跑多次月邊界（再生有機率），統計是否會增長至 cap 附近
	var grew: bool = false
	for _m in range(200):
		var before: int = int(tile.resources["wild_game"])
		hs._regen_wild_game(state)
		if int(tile.resources["wild_game"]) > before:
			grew = true
		assert(int(tile.resources["wild_game"]) <= 5, "不應超過 cap")
	assert(grew, "月再生應曾使 wild_game 增長")
	print("wild_game regen OK")
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `_regen_wild_game` 未定義。

- [ ] **Step 3: 實作**

`harvest_system.gd` const 區加：

```gdscript
const WILD_GAME_REGEN_CHANCE: float = 0.30   # TEST VALUE — 每月增長機率（比野馬快，獵物繁殖快）
```

新增（比照 `_regen_wild_horses`）：

```gdscript
# 每月（month 邊界）平原/森林 tile 機率 +1 wild_game，上限 resource_cap["wild_game"]
func _regen_wild_game(state: WorldState) -> void:
	if state.world.current_tick % WorldState.TICKS_PER_MONTH != 0:
		return
	for tile_id in state.world.tiles:
		var tile: HexTileData = state.world.tiles[tile_id]
		var cap: int = int(tile.resource_cap.get("wild_game", 0))
		if cap <= 0:
			continue
		var cur: int = int(tile.resources.get("wild_game", 0))
		if cur >= cap:
			continue
		if randf() < WILD_GAME_REGEN_CHANCE:
			tile.resources["wild_game"] = cur + 1
```

`tick_all` 內，月邊界區塊（`_regen_wild_horses` / `_regen_herb` 呼叫附近）加 `_regen_wild_game(state)`。

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `wild_game regen OK`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/harvest_system.gd scripts/debug/headless_test.gd
git commit -m "feat: wild_game 月再生（harvest_system）"
```

---

## Task 3: HuntSystem.hunt_small_game

**Files:**
- Create: `scripts/simulation/hunt_system.gd`
- Test: `scripts/debug/headless_test.gd`（新 `_test_hunt_small_game`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_hunt_small_game() -> void:
	print("--- 小獵物狩獵 roll ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4 * 1000 + 4; tile.tile_pos = Vector2i(4, 4)
	tile.terrain = "plains"; tile.resources = {"wild_game": 5}
	state.world.tiles[tile.tile_id] = tile
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"求生": 0.9}   # 高求生 → 高命中
	state.persons[0] = leader
	var team := TeamData.new()
	team.team_id = 0; team.leader_id = 0; team.tile_pos = Vector2i(4, 4)
	team.resources = {"food": 0.0}
	state.teams[0] = team
	var hunt := HuntSystem.new()
	# 主動狩獵多次：應得食物 + 枯竭 wild_game
	var got_food: bool = false
	for _i in range(20):
		var r: Dictionary = hunt.hunt_small_game(state, team, tile, true)
		if float(team.resources["food"]) > 0.0:
			got_food = true
	assert(got_food, "高求生隊主動獵應得食物")
	assert(int(tile.resources["wild_game"]) < 5, "獵物應被枯竭，實際=%s" % str(tile.resources["wild_game"]))
	assert(int(tile.resources["wild_game"]) >= 0, "獵物不應為負")
	print("hunt_small_game OK")
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `HuntSystem` 不存在（parse error / 找不到 class）。

- [ ] **Step 3: 實作**

新建 `scripts/simulation/hunt_system.gd`：

```gdscript
class_name HuntSystem

# 小獵物抽象狩獵：求生技能 roll → 成功得食物 + 枯竭 1 隻。無場景（危險野獸戰鬥屬 Plan 2b）。
const FOOD_PER_GAME: float = 12.0          # TEST VALUE — 每隻小獵物食物
const ACTIVE_BASE_CHANCE: float = 0.4      # TEST VALUE — 主動狩獵基礎命中
const PASSIVE_BASE_CHANCE: float = 0.08    # TEST VALUE — 覓食被動小獵命中（低）

# active=true 玩家/NPC 主動狩獵；active=false 覓食 tick 被動。回傳 {success, food, msg}
func hunt_small_game(state: WorldState, team: TeamData, tile: HexTileData, active: bool) -> Dictionary:
	var game: int = int(tile.resources.get("wild_game", 0))
	if game <= 0:
		return { "success": false, "food": 0.0, "msg": "無獵物" }
	var survival: float = _avg_survival(state, team)
	var base: float = ACTIVE_BASE_CHANCE if active else PASSIVE_BASE_CHANCE
	var chance: float = clampf(base + survival * 0.4, 0.0, 0.95)
	if randf() >= chance:
		return { "success": false, "food": 0.0, "msg": "空手而回" }
	tile.resources["wild_game"] = game - 1   # 枯竭 1 隻
	var food: float = FOOD_PER_GAME * (1.0 + survival * 0.3)
	team.resources["food"] = float(team.resources.get("food", 0)) + food
	team.forage_today = float(team.forage_today) + food   # 併入覓食 episode 日彙整
	return { "success": true, "food": food, "msg": "獵得野味 +%d 糧" % int(round(food)) }

func _avg_survival(state: WorldState, team: TeamData) -> float:
	var total: float = 0.0; var count: int = 0
	for pid in ([team.leader_id] as Array) + team.named_members:
		var p: PersonData = state.persons.get(pid)
		if p: total += float(p.skills.get("求生", 0.0)); count += 1
	return total / maxf(float(count), 1.0)
```

- [ ] **Step 4: 重建 class 快取 + 跑測試**

新增 `class_name` 檔，**先 import**：
Run: `.\tools\godot.ps1 --headless --import`
再 Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `hunt_small_game OK`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/hunt_system.gd scripts/debug/headless_test.gd
git commit -m "feat: HuntSystem.hunt_small_game（求生 roll → 食物 + 枯竭）"
```

---

## Task 4: NPC 覓食時被動小獵

**Files:**
- Modify: `scripts/simulation/resource_system.gd`（`collect_resources` forage 分支）
- Test: `scripts/debug/headless_test.gd`（新 `_test_passive_hunt_on_forage`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_passive_hunt_on_forage() -> void:
	print("--- 覓食被動小獵 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4 * 1000 + 4; tile.tile_pos = Vector2i(4, 4)
	tile.terrain = "plains"; tile.productivity = 1.0; tile.harvest_factor = 1.0
	tile.outpost_level = 0
	tile.resources = {"food": 100.0, "wild_game": 5}
	state.world.tiles[tile.tile_id] = tile
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"求生": 0.9}
	state.persons[0] = leader
	var team := TeamData.new()
	team.team_id = 0; team.leader_id = 0; team.population = 3; team.tile_pos = Vector2i(4, 4)
	team.resources = {"food": 0.0}
	state.teams[0] = team
	var rs := ResourceSystem.new()
	var game_before: int = int(tile.resources["wild_game"])
	for _i in range(50):
		rs.collect_resources(state, [0])
	# 覓食 tick 多次 → 被動小獵應曾枯竭 wild_game
	assert(int(tile.resources["wild_game"]) < game_before,
		"覓食 tick 應被動獵掉部分 wild_game，實際=%d" % int(tile.resources["wild_game"]))
	print("passive hunt OK")
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — forage 分支未呼叫狩獵，wild_game 不變。

- [ ] **Step 3: 實作**

`resource_system.gd`，`collect_resources` 的 `outpost_level == 0` forage 分支內，`_forage_from_tile(...)` 之後加：

```gdscript
			if int(tile.resources.get("wild_game", 0)) > 0:
				HuntSystem.new().hunt_small_game(state, team, tile, false)   # 被動低率小獵
```

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `passive hunt OK`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/resource_system.gd scripts/debug/headless_test.gd
git commit -m "feat: 覓食 tick 被動小獵（有 wild_game 時）"
```

---

## Task 5: 玩家 hunt 指令

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`（registry + `_action_hunt`）
- Test: `scripts/debug/headless_test.gd`（新 `_test_player_hunt_action`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_player_hunt_action() -> void:
	print("--- 玩家 hunt 指令 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4 * 1000 + 4; tile.tile_pos = Vector2i(4, 4)
	tile.terrain = "plains"; tile.resources = {"wild_game": 5}
	state.world.tiles[tile.tile_id] = tile
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"求生": 0.9}
	state.persons[0] = leader
	state.player_id = 0
	var team := TeamData.new()
	team.team_id = 0; team.leader_id = 0; team.tile_pos = Vector2i(4, 4)
	team.resources = {"food": 0.0}
	state.teams[0] = team
	var cmd := PlayerCommandSystem.new()
	var got_food: bool = false
	for _i in range(20):
		var r: Dictionary = cmd.execute_action(state, -1, "hunt")
		if float(team.resources["food"]) > 0.0:
			got_food = true
	assert(got_food, "hunt 指令應得食物")
	print("player hunt OK")
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `未知行動: hunt`，food 維持 0。

- [ ] **Step 3: 實作**

`player_command_system.gd`，`_setup_registry()` 加：

```gdscript
		"hunt":                   _action_hunt,
```

新增（簽名比照其他 `_action_*`，如 `_action_build_outpost`）：

```gdscript
func _action_hunt(state: WorldState, _target: int, pt: TeamData, _pt_id: int) -> Dictionary:
	var tile: HexTileData = state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
	if tile == null or int(tile.resources.get("wild_game", 0)) <= 0:
		return { "ok": false, "msg": "此地無獵物" }
	var r: Dictionary = HuntSystem.new().hunt_small_game(state, pt, tile, true)
	return { "ok": true, "msg": r.get("msg", "") }
```

注意：`execute_action(state, target_id, action)` 的 self 行動用 `target_id=-1`；`_action_hunt` 收 `(state, _target, pt, _pt_id)` — `pt` 為玩家 team（由 dispatcher 注入，比照既有 self-action 如 extract_treasury）。確認 dispatcher 對 `target=-1` 行動會傳入 pt（讀 `execute_action` 既有實作確認簽名一致）。

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `player hunt OK`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_command_system.gd scripts/debug/headless_test.gd
git commit -m "feat: 玩家 hunt 指令（主動小獵）"
```

---

## Task 6: 註冊測試 + 全綠

**Files:**
- Modify: `scripts/debug/headless_test.gd`（`_initialize()`）

- [ ] **Step 1: 註冊**

`_initialize()` 末段加：

```gdscript
	_test_wild_game_seeded()
	_test_wild_game_regen()
	_test_hunt_small_game()
	_test_passive_hunt_on_forage()
	_test_player_hunt_action()
```

- [ ] **Step 2: 跑全套**

Run: `.\tools\godot.ps1 --headless --import`
Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 新增 5 測試全 OK；既有測試不回歸（baseline 既有失敗 Bug8 `food 應進公庫` 仍存可接受，無新增 FAIL）。

- [ ] **Step 3: Commit**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test: 註冊小獵物食物層測試"
```

---

## Task 7: 整合驗證（2 年 multi + 守恆）

- [ ] **Step 1: 跑 2 年 multi**

```bash
$env:SIM_CONFIGS = "survival_start,tyrant,warzone"; .\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd *> godot_hunt_verify.log
```

- [ ] **Step 2: 驗收**

```bash
iconv -f UTF-16LE -t UTF-8 godot_hunt_verify.log > godot_hunt_verify_u8.log
grep -a "CoinAudit\|SCRIPT ERROR\|多配置對比\|wild_game" godot_hunt_verify_u8.log
```

驗收標準：
- 三 config `died=no`、`[CoinAudit] delta=0.00`（小獵物給食物，食物不在 coin_eq，守恆不破）
- 無**新增** `SCRIPT ERROR`（Bug7 interaction:233 baseline 可能仍在，非本 plan 引入）
- `MaterialStats` 或自加 print 確認 wild_game 有被獵（枯竭）且月再生（不歸零滅絕）— 若無現成統計，可在 `game_sim_multi` 加一行 tile wild_game 總量 print，或接受單元測試覆蓋

- [ ] **Step 3: 達標 → handback；未達 → 記症狀回報主 session**

調 `WILD_GAME_*` / `FOOD_PER_GAME` / 命中率前先量測。若 survival_start 小隊因小獵物變太肥（食物通膨）→ 降 `FOOD_PER_GAME` 或命中率。**先量測再 tune**。

- [ ] **Step 4: 寫 handback**

`docs/superpowers/handbacks/2026-06-14-stage1-2a-small-game-hunt.md`：摘要、與 spec 差異、驗收結果、連動風險、待主 session 確認項。

---

## 注意事項（給實作者）

- **編碼**：godot 一律 `.\tools\godot.ps1` wrapper。新增 `class_name`（HuntSystem）後**必先 `--import`** 再跑測試。
- **守恆**：小獵物產出是食物（非 coin_eq 追蹤項），但 Task 7 仍須確認 coin_eq delta=0（確保沒誤動其他資源）。
- **TEST VALUE**：`WILD_GAME_*` / `FOOD_PER_GAME` / 命中率為粗值 → Task 7 量測 tune，勿空想（「避免鑽牛角尖」）。
- **forage_today 併入**：`hunt_small_game` 把獵得食物併入 `team.forage_today` → 自動走 Plan 1 的覓食 episode 日彙整，玩家隊會見訊息。
- **不碰戰鬥系統**：危險野獸戰鬥 + 伏擊偵測屬 Plan 2b。本 plan 只做抽象小獵物食物層。
- **`predator_density` 不在本 plan**：留 Plan 2b 與伏擊/戰鬥一起。
