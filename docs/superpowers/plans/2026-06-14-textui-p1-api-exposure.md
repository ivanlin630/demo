# 文字 UI 翻新 Phase 1：API 暴露 + 邊界清理 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 stage-1 玩家需要的 sim 資訊 map 進 player API DTO（precarity / tile 獵物獸情 / hunt 動作），並清 UI 直存 sim 的洩漏 — 讓 DTO 成 UI-agnostic 契約。**純 API 暴露層 + 邊界，不改 sim 規則、不改 UI 渲染（chrome/互動屬 Phase 2/3）。**

**Architecture:** 補 `player_api_mapper`（DTO mapping）+ `player_query_api`（available_actions 加 self/tile 動作層）；審 `scripts/ui/*` 直存 `WorldState`/`_player_cmd` → 改走 `SimBridge`。

**Tech Stack:** Godot 4.2.2 GDScript；headless 測試；`.\tools\godot.ps1` wrapper。

依據 spec：`docs/superpowers/specs/2026-06-14-textui-overhaul-design.md`（§1 API 暴露、§2 邊界）。Phase 2（chrome）/ Phase 3（stage-1 互動渲染）後續。

---

## 檔案結構

- `scripts/simulation/player_api_mapper.gd`（改）：`map_controlled_team`/`map_player_summary` 加 precarity；`map_location_context` 加 wild_game/predator/food。
- `scripts/simulation/player_query_api.gd`（改）：`_build_available_actions` 加 self/tile 動作層（hunt/hunt_beast）。
- `scripts/ui/*.gd`（改）：清直存 sim 洩漏 → 走 bridge。
- `scripts/debug/headless_test.gd`（改）：DTO + actions 單元測試。

---

## Task 1: location_context 暴露 wild_game / predator / food

**Files:**
- Modify: `scripts/simulation/player_api_mapper.gd`（`map_location_context` 回傳 dict）
- Test: `scripts/debug/headless_test.gd`（新 `_test_location_game_predator`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_location_game_predator() -> void:
	print("--- location_context 獵物獸情 ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4); tile.terrain = "forest"
	tile.resources = {"food": 80.0, "wild_game": 4, "predator_density": 1}
	state.world.tiles[tile.tile_id] = tile
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.skills = {"偵查": 0.9}
	state.persons[0] = leader; state.player_id = 0
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 0; team.tile_pos = Vector2i(4,4)
	state.teams[0] = team
	var lc: Dictionary = PlayerApiMapper.map_location_context(state, 4, 4)
	assert(int(lc.get("wild_game", -1)) == 4, "應暴露 wild_game，實際=%s" % str(lc.get("wild_game")))
	assert(lc.has("predator"), "應有 predator 旗")
	assert(int(lc.get("food", -1)) == 80, "應暴露 tile food")
	print("location game/predator OK")
```

- [ ] **Step 2: 跑確認失敗** — DTO 無 wild_game/predator/food key。

- [ ] **Step 3: 實作**

`map_location_context` 的 `visible` 回傳 dict 加（在 `return {...}` 內）：

```gdscript
		"food": int(tile.resources.get("food", 0)),
		"wild_game": int(tile.resources.get("wild_game", 0)),
		"predator": _predator_intel(state, tile),
```

新增 helper（predator 偵測分級，認知≠真實 — 復用 AmbushSystem.detect 語意）：

```gdscript
# 玩家對該 tile 掠食者的認知：none(無) / detected(偵測到，預警) / lurking(有但沒察覺)
static func _predator_intel(state: WorldState, tile: HexTileData) -> String:
	if int(tile.resources.get("predator_density", 0)) <= 0:
		return "none"
	var pid: int = state.player_id
	var p: PersonData = state.persons.get(pid) if pid != -1 else null
	var pt: TeamData = state.teams.get(p.team_id) if p != null else null
	if pt != null and pt.tile_pos == tile.tile_pos:
		if AmbushSystem.new().detect(state, pt, tile):
			return "detected"
		return "lurking"
	return "lurking"   # 非腳下格 → 預設未察覺（認知不透明）
```

- [ ] **Step 4: 跑確認通過** — `location game/predator OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_api_mapper.gd scripts/debug/headless_test.gd
git commit -m "feat(api): location_context 暴露 wild_game/predator/food"
```

---

## Task 2: 糧 precarity 暴露（controlled_team / player_summary）

**Files:**
- Modify: `scripts/simulation/player_api_mapper.gd`
- Test: `scripts/debug/headless_test.gd`（新 `_test_precarity_dto`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_precarity_dto() -> void:
	print("--- 糧 precarity DTO ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader; state.player_id = 0
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 0
	team.population = 5; team.resources = {"food": 24.0}   # 5×2.4=12/day → 2 天
	state.teams[0] = team
	var ct: Dictionary = PlayerApiMapper.map_controlled_team(state)
	assert(ct.has("food_days"), "controlled_team 應有 food_days")
	assert(abs(float(ct["food_days"]) - 2.0) < 0.2, "food_days≈2，實際=%s" % str(ct["food_days"]))
	assert(ct.get("starving", false) == true, "2 天 < WARNING(3) → starving")
	print("precarity DTO OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

`map_controlled_team` 的回傳 dict 加（pop/resources 既有變數）：

```gdscript
		"food_days": _food_days(t),
		"starving": _food_days(t) < 3.0,   # WARNING_DAYS=3
```

helper：
```gdscript
const FOOD_PER_PERSON_PER_DAY: float = 2.4
static func _food_days(t: TeamData) -> float:
	var burn: float = maxf(float(t.population) * FOOD_PER_PERSON_PER_DAY, 0.001)
	return float(t.resources.get("food", 0)) / burn
```

（`map_player_summary` 同樣可加 `food_days`/`starving`，比照；本 task 至少 controlled_team。）

- [ ] **Step 4: 跑確認通過** — `precarity DTO OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_api_mapper.gd scripts/debug/headless_test.gd
git commit -m "feat(api): controlled_team 暴露 food_days/starving precarity"
```

---

## Task 3: available_actions 加 self/tile 動作層（hunt/hunt_beast）

**Files:**
- Modify: `scripts/simulation/player_query_api.gd`（`_build_available_actions`）
- Test: `scripts/debug/headless_test.gd`（新 `_test_self_actions`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_self_actions() -> void:
	print("--- available_actions self 動作(hunt/hunt_beast) ---")
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4); tile.terrain = "forest"
	tile.resources = {"wild_game": 3, "predator_density": 1}
	state.world.tiles[tile.tile_id] = tile
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	state.persons[0] = leader; state.player_id = 0
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 0; team.tile_pos = Vector2i(4,4)
	state.teams[0] = team
	var qa := PlayerQueryApi.new()
	var res: Dictionary = qa.get_available_actions(state, {})
	var ids: Array = []
	for a in res.get("data", {}).get("actions", []):
		ids.append(a.get("action_id", ""))
	assert("hunt" in ids, "腳下有 wild_game 應列 hunt，實際=%s" % str(ids))
	assert("hunt_beast" in ids, "腳下有 predator 應列 hunt_beast")
	print("self actions OK")
```

注意：確認 `PlayerQueryApi.get_available_actions` 回傳結構（`data.actions`）；若不同依實際調整斷言路徑（讀該函數）。

- [ ] **Step 2: 跑確認失敗** — 無 self 動作層，hunt 不在清單。

- [ ] **Step 3: 實作**

`_build_available_actions`，於 Layer 4 之後加 **Layer 5：玩家隊 self/tile 動作**：

```gdscript
	# Layer 5: 玩家隊 self/tile 動作（hunt/hunt_beast，依腳下 tile）
	if pt_tile_self(state, ptid) != null:
		var self_tile: HexTileData = pt_tile_self(state, ptid)
		if int(self_tile.resources.get("wild_game", 0)) > 0:
			actions.append(PlayerApiMapper.map_available_action(
				"hunt", _action_label("hunt"), true, "",
				{ "allowed_kinds": PackedStringArray(["none"]),
				  "requires_visible_target": false, "requires_forced_interaction": false,
				  "allows_self_target": false },
				"execute_action",
				{ "action_id": "hunt", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1} }))
		if int(self_tile.resources.get("predator_density", 0)) > 0:
			actions.append(PlayerApiMapper.map_available_action(
				"hunt_beast", _action_label("hunt_beast"), true, "",
				{ "allowed_kinds": PackedStringArray(["none"]),
				  "requires_visible_target": false, "requires_forced_interaction": false,
				  "allows_self_target": false },
				"execute_action",
				{ "action_id": "hunt_beast", "target": {"kind": "none", "team_id": -1, "member_id": -1, "tile_q": -1, "tile_r": -1} }))
```

helper：
```gdscript
func pt_tile_self(state: WorldState, ptid: int) -> HexTileData:
	if ptid == -1 or not state.teams.has(ptid): return null
	var pt: TeamData = state.teams[ptid]
	return state.world.tiles.get(pt.tile_pos.x * 1000 + pt.tile_pos.y)
```

`_action_label` 補 `"hunt": "狩獵"`, `"hunt_beast": "獵猛獸"`。

注意：`execute_action` dispatch 對 `kind:"none"` 會以 target_id=-1 呼叫 `cmd_sys.execute_action(state, -1, "hunt")` → 既有 `_action_hunt`（self-action 收 pt）。確認 command_api 的 none-kind 路徑傳入 pt（讀 `PlayerCommandApi.execute_action` 的 "none" 分支，已存在）。

- [ ] **Step 4: 跑確認通過** — `self actions OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/player_query_api.gd scripts/simulation/player_api_mapper.gd scripts/debug/headless_test.gd
git commit -m "feat(api): available_actions 加 self/tile 層（hunt/hunt_beast）"
```

---

## Task 4: 邊界清理（UI 直存 sim → 走 bridge）

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`（+ 其他 `scripts/ui/*` 直存）
- Test: grep 驗 + 既有 UI 測試

- [ ] **Step 1: 審查直存點**

Run grep（記錄所有命中）：
```bash
grep -rnE "_player_cmd|_runner\.|state\.(teams|persons|world)|WorldState" scripts/ui/*.gd | grep -v "_bridge"
```
重點：progress 記的 `text_ui_main` 互動模式直呼 `_player_cmd.get_available_actions`（應改走 `_bridge`）。列出每個直存 sim 物件處。

- [ ] **Step 2: 確認 bridge 有對應 facade**

讀 `scripts/ui/sim_bridge.gd`：每個 UI 需要的查詢/指令是否有 bridge 方法。缺的補 bridge facade（轉呼 PlayerQueryApi/PlayerCommandApi）。**不讓 UI 繞過 bridge。**

- [ ] **Step 3: 改直存 → 走 bridge**

逐點把 `_player_cmd.X` / 直存 `state.*` 改為 `_bridge.X`。互動模式的 available_actions 改 `_bridge.query_available_actions(...)`（若無此 facade 則補）。

- [ ] **Step 4: 驗證無回歸**

```bash
.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd
.\tools\godot.ps1 --headless --script scripts/debug/team_ui_test.gd
```
Expected：無新增 SCRIPT ERROR；UI 測試綠。
再 grep 確認 `scripts/ui/` 已無 `_player_cmd` / 直存 `state.teams|persons|world`（除 bridge 內部）。

- [ ] **Step 5: Commit**

```bash
git add scripts/ui/
git commit -m "refactor(ui): 清直存 sim 洩漏，一律經 SimBridge（UI 邊界）"
```

---

## Task 5: 註冊 + 全測試

**Files:**
- Modify: `scripts/debug/headless_test.gd`（`_initialize`）

- [ ] **Step 1: 註冊** `_test_location_game_predator` / `_test_precarity_dto` / `_test_self_actions`。

- [ ] **Step 2: 全測試** — headless_test + team_ui_test + ui_logic_test，無新增 SCRIPT ERROR、無回歸。

- [ ] **Step 3: handback** — `docs/superpowers/handbacks/2026-06-14-textui-p1-api-exposure.md`，附 DTO 新欄位清單 + 邊界 grep 結果（清乾淨證據）。

---

## 注意事項（給實作者）

- **純 API 暴露 + 邊界，不改 sim 規則、不改 UI 渲染**（chrome / 互動選單 = Phase 2/3）。
- **DTO 是 UI 契約**：玩家 UI 要的 sim 資訊一律 map 進 DTO，不讓 UI 繞道（invariants「UI 邊界」）。
- **邊界鐵律**：改完 `scripts/ui/` 不得直存 `WorldState`/`_player_cmd`/`_runner` sim 物件；只經 `SimBridge`。
- `AmbushSystem.detect` 為 instance method（`.new().detect(...)`）；predator intel 認知分級復用其語意。
- 確認 `PlayerCommandApi.execute_action` 的 `kind:"none"` 路徑對 hunt 傳入 pt（既有 self-action 如 build_outpost 已走此路）。
- 不碰圖形 Main.tscn。
