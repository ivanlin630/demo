# 絕境驅動多元生存行為 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 把 `_trigger_survival` 從「個性閘」改「絕境放寬閘 × 個性偏好」+ 補紮營選項，讓求生型流民絕境時有多元活路（不餓死、不只當獵人），且不誤觸發正常 team。

**Architecture:** 保留既有觸發（`days_left < WARNING_DAYS(3)` 才進、`<URGENCY_DAYS(1)` urgent）。重構 cascade：values → 各選項 pref 分數；severity → `gate_mult`（warning=1 個性門檻 / urgent=0 解閘）；依 pref 高到低試「可行 + 門檻×gate_mult」的選項（掠奪/投靠/紮營/狩獵/乞討）。新增紮營（認領無主可農地 → 即時 crude camp）。圖利掠奪（`_evaluate_prosperity_attack`）不動。

**Tech Stack:** Godot 4.2.2 GDScript；headless 測試；`.\tools\godot.ps1` wrapper。

依據 spec：`docs/superpowers/specs/2026-06-14-desperation-survival-behavior-design.md`。

---

## 檔案結構

- `scripts/data/team_data.gd`（改）：`TASK_CAMP` const。
- `scripts/simulation/faction_ai_system.gd`（改）：pref helpers（`_loot_pref`/`_join_pref`/`_camp_pref`）；`_find_unowned_farmable_tile`；`establish_crude_camp`；`_trigger_survival` 重構。
- `scripts/simulation/interaction_system.gd` 或 sim_runner（改）：TASK_CAMP 到達 → `establish_crude_camp`（比照既有 survival task 到達結算）。
- `scripts/debug/headless_test.gd`（改）：測試。

---

## Task 1: 選項 pref helpers + gate_mult

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Test: `scripts/debug/headless_test.gd`（新 `_test_survival_prefs`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_survival_prefs() -> void:
	print("--- 生存選項 pref ---")
	var fai := FactionAISystem.new()
	var ferocious := PersonData.new()
	ferocious.values = {"殘忍": 0.9, "好戰": 0.8, "義氣": 0.1, "野心": 0.2, "求生欲": 0.5}
	var honorable := PersonData.new()
	honorable.values = {"殘忍": 0.1, "好戰": 0.1, "義氣": 0.9, "信義": 0.8, "野心": 0.2}
	var ambitious := PersonData.new()
	ambitious.values = {"殘忍": 0.2, "野心": 0.9, "統領": 0.6, "求生欲": 0.7, "義氣": 0.3}
	assert(fai._loot_pref(ferocious) > fai._loot_pref(honorable), "兇者掠奪 pref 較高")
	assert(fai._join_pref(honorable) > fai._join_pref(ferocious), "義氣者投靠 pref 較高")
	assert(fai._camp_pref(ambitious) > fai._camp_pref(ferocious), "野心者紮營 pref 較高")
	print("survival prefs OK")
```

- [ ] **Step 2: 跑確認失敗** — helpers 未定義。

- [ ] **Step 3: 實作**

`faction_ai_system.gd` 新增（簡單 values 線性組合，非決策樹）：

```gdscript
# 生存選項個性傾向（0~1），values 線性組合。TEST VALUE 權重待量測。
func _loot_pref(leader: PersonData) -> float:
	return clampf(float(leader.values.get("殘忍", 0.5)) * 0.5
		+ float(leader.values.get("好戰", 0.5)) * 0.3
		+ float(leader.values.get("貪婪", 0.5)) * 0.2, 0.0, 1.0)

func _join_pref(leader: PersonData) -> float:
	return clampf(float(leader.values.get("義氣", 0.5)) * 0.4
		+ float(leader.values.get("信義", 0.5)) * 0.3
		+ float(leader.values.get("求生欲", 0.5)) * 0.3, 0.0, 1.0)

func _camp_pref(leader: PersonData) -> float:
	return clampf(float(leader.values.get("野心", 0.5)) * 0.4
		+ float(leader.values.get("統領", 0.0)) * 0.3
		+ float(leader.values.get("求生欲", 0.5)) * 0.3, 0.0, 1.0)
```

const 區加門檻（warning 用；urgent ×gate_mult=0 解閘）：
```gdscript
const LOOT_GATE: float = 0.55   # TEST VALUE
const JOIN_GATE: float = 0.55   # TEST VALUE
const CAMP_GATE: float = 0.50   # TEST VALUE
```

- [ ] **Step 4: 跑確認通過** — `survival prefs OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat: 生存選項 pref helpers（values 線性）+ 門檻 const"
```

---

## Task 2: 找無主可農地 helper

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_find_unowned_farmable_tile`）
- Test: `scripts/debug/headless_test.gd`（新 `_test_find_unowned_farmable`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_find_unowned_farmable() -> void:
	print("--- 找無主可農地 ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new(); state.world = WorldData.new()
	# 本格 mountain（不可農）、鄰格 (5,4) plains 無主 → 選 (5,4)
	for p in [Vector2i(4,4), Vector2i(5,4)]:
		var tile := HexTileData.new()
		tile.tile_id = p.x*1000+p.y; tile.tile_pos = p
		tile.terrain = ("mountain" if p == Vector2i(4,4) else "plains")
		tile.outpost_owner = -1; tile.outpost_level = 0
		state.world.tiles[tile.tile_id] = tile
	var team := TeamData.new(); team.team_id = 0; team.tile_pos = Vector2i(4,4)
	state.teams[0] = team
	var pos: Vector2i = fai._find_unowned_farmable_tile(state, team)
	assert(pos == Vector2i(5,4), "應選無主平原鄰格，實際=%s" % str(pos))
	# 鄰格被佔 → 無可農 → (-1,-1)
	state.world.tiles[5*1000+4].outpost_level = 1
	state.world.tiles[5*1000+4].outpost_owner = 9
	assert(fai._find_unowned_farmable_tile(state, team) == Vector2i(-1,-1), "已佔不可選")
	print("find unowned farmable OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

```gdscript
# 找本格+鄰格 無主(owner==-1, level==0) 可農(plains/forest) tile；無 → (-1,-1)。
func _find_unowned_farmable_tile(state: WorldState, team: TeamData) -> Vector2i:
	var dirs: Array = [Vector2i.ZERO, Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1),
		Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,1)]
	for d in dirs:
		var p: Vector2i = team.tile_pos + d
		var tile: HexTileData = state.world.tiles.get(p.x*1000 + p.y)
		if tile == null: continue
		if tile.outpost_level > 0 or tile.outpost_owner != -1: continue
		if tile.terrain == "mountain": continue   # 山不可農（見山村特化待 spec）
		return p
	return Vector2i(-1, -1)
```

- [ ] **Step 4: 跑確認通過** — `find unowned farmable OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat: _find_unowned_farmable_tile（紮營選址）"
```

---

## Task 3: TASK_CAMP + 即時 crude camp + 到達結算

**Files:**
- Modify: `scripts/data/team_data.gd`（`TASK_CAMP`）
- Modify: `scripts/simulation/faction_ai_system.gd`（`establish_crude_camp`）
- Modify: 到達 hook（見 Step 3）
- Test: `scripts/debug/headless_test.gd`（新 `_test_crude_camp`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_crude_camp() -> void:
	print("--- 即時 crude camp ---")
	var fai := FactionAISystem.new()
	var state := WorldState.new(); state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4*1000+4; tile.tile_pos = Vector2i(4,4); tile.terrain = "plains"
	tile.outpost_owner = -1; tile.outpost_level = 0
	tile.resource_cap = {"food": 50.0}
	state.world.tiles[tile.tile_id] = tile
	# 和平流民 leader → 民營 + 生產 tag
	var peaceful := PersonData.new(); peaceful.id = 0; peaceful.team_id = 0
	peaceful.values = {"好戰": 0.2, "野心": 0.5, "求生欲": 0.9}
	state.persons[0] = peaceful
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 0; team.tile_pos = Vector2i(4,4)
	team.population = 3; team.resources = {"material": 0}; team.tags = ["流亡"]   # 流民無建材、流亡身分
	state.teams[0] = team
	var ok: bool = fai.establish_crude_camp(state, team)
	assert(ok, "無主可農地應能立 crude camp（免建材）")
	assert(tile.outpost_level == 1 and tile.outpost_owner == 0, "tile 應成 team0 L1")
	assert(tile.outpost_type == "civilian", "和平流民 → 民營")
	assert(team.tags.has("生產") and not team.tags.has("流亡"), "和平流民紮營 → 升生產、清流亡")
	assert(float(tile.resource_cap.get("food", 0)) >= 50.0, "食物 cap 不降")
	assert(not fai.establish_crude_camp(state, team), "已佔格不可再立")
	# 好戰 leader → 軍營 + 軍隊 tag（不一律生產）
	var tile2 := HexTileData.new()
	tile2.tile_id = 5*1000+4; tile2.tile_pos = Vector2i(5,4); tile2.terrain = "plains"
	tile2.outpost_owner = -1; tile2.outpost_level = 0; tile2.resource_cap = {"food": 50.0}
	state.world.tiles[tile2.tile_id] = tile2
	var raider := PersonData.new(); raider.id = 1000; raider.team_id = 1
	raider.values = {"好戰": 0.9, "野心": 0.8, "殘忍": 0.7}
	state.persons[1000] = raider
	var t2 := TeamData.new(); t2.team_id = 1; t2.leader_id = 1000; t2.tile_pos = Vector2i(5,4)
	t2.tags = ["流亡"]
	state.teams[1] = t2
	fai.establish_crude_camp(state, t2)
	assert(tile2.outpost_type == "military", "好戰流民 → 軍營")
	assert(t2.tags.has("軍隊"), "好戰流民紮營 → 升軍隊（非一律生產）")
	print("crude camp OK")
```

- [ ] **Step 2: 跑確認失敗**

- [ ] **Step 3: 實作**

`team_data.gd`：`const TASK_CAMP := "紮營"`。

`faction_ai_system.gd` 新增（**即時**立 crude camp，免建材 — 反映流民搭棚；非走 `OutpostSystem.start_build` 的成本/工期）。**營地類型依個性**（好戰/野心→軍營→軍隊；其餘→民營→生產），**升對應 tag + 清流亡**（比照 `_auto_settle_builder` 的身分躍遷，完成「流浪→定居」攀爬，但**非一律生產**）：

```gdscript
const CRUDE_CAMP_FOOD_SEED: float = 40.0   # TEST VALUE — 紮營種子糧（+同抬 cap）

# 在腳下無主可農地即時立 crude L1 camp（求生豁免，免建材/免工期）。
# 類型 + tag 依 leader 個性：好戰/野心 → 軍營/軍隊；其餘 → 民營/生產。回傳成功否。
func establish_crude_camp(state: WorldState, team: TeamData) -> bool:
	var tile: HexTileData = state.world.tiles.get(team.tile_pos.x*1000 + team.tile_pos.y)
	if tile == null or tile.outpost_level > 0 or tile.outpost_owner != -1:
		return false
	if tile.terrain == "mountain":
		return false
	var leader: PersonData = state.persons.get(team.leader_id)
	var martial: float = float(leader.values.get("好戰", 0.5)) if leader else 0.5
	var ambition: float = float(leader.values.get("野心", 0.5)) if leader else 0.5
	var is_military: bool = (martial > 0.6 or ambition > 0.7)   # TEST VALUE 門檻
	tile.outpost_type = "military" if is_military else "civilian"
	tile.outpost_level = 1
	tile.outpost_owner = team.team_id
	tile.resources["food"] = maxf(float(tile.resources.get("food", 0)), CRUDE_CAMP_FOOD_SEED)
	tile.resource_cap["food"] = maxf(float(tile.resource_cap.get("food", 0)), CRUDE_CAMP_FOOD_SEED)
	# 身分躍遷（比照 _auto_settle_builder）：升軍/生產 tag、清流亡（流浪→定居）
	var new_tag: String = TeamData.TAG_MILITARY if is_military else TeamData.TAG_PRODUCE
	if not team.tags.has(new_tag):
		team.tags.append(new_tag)
	team.tags.erase("流亡")
	print("[CrudeCamp] Team%d 紮營 @(%d,%d) → %s" % [
		team.team_id, team.tile_pos.x, team.tile_pos.y, tile.outpost_type])
	return true
```

到達結算（Step：確認既有 survival task 到達 hook）：team `current_task == TASK_CAMP` 移動到 move_target 後 → 呼叫 `establish_crude_camp`，成功則 `TaskArbiter.release(team)`（脫離 survival、轉正常 collect）。**實作者確認到達 hook 位置**：讀 movement arrived 回傳 / `interaction_system.process_on_move` / sim_runner 移動結算，比照既有 survival task（return_home/投靠）到達如何被處理，於同處加 TASK_CAMP 分支。若無現成 per-task 到達 hook，最小法：在 `_evaluate_survival`（每輪求生評估）開頭檢查 `current_task==TASK_CAMP and 已在無主可農地 → establish_crude_camp + release`。

- [ ] **Step 4: 跑確認通過** — `crude camp OK`
- [ ] **Step 5: Commit**

```bash
git add scripts/data/team_data.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat: TASK_CAMP + establish_crude_camp（求生即時立營，免建材）"
```

---

## Task 4: _trigger_survival 重構（desperation × values）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_trigger_survival` Path 2 起重構）
- Test: `scripts/debug/headless_test.gd`（新 `_test_desperation_cascade`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_desperation_cascade() -> void:
	print("--- 絕境 cascade：urgent 解閘 ---")
	var fai := FactionAISystem.new()
	# 求生型流民（不兇不義，warning 下舊邏輯無活路）：urgent 應拿到某可行 survival task
	var leader := PersonData.new(); leader.id = 0; leader.team_id = 0
	leader.values = {"殘忍": 0.2, "好戰": 0.2, "義氣": 0.3, "信義": 0.3, "野心": 0.6, "求生欲": 0.9}
	var state := WorldState.new(); state.world = WorldData.new()
	# 鄰格無主平原（可紮營）
	for p in [Vector2i(4,4), Vector2i(5,4)]:
		var tile := HexTileData.new()
		tile.tile_id = p.x*1000+p.y; tile.tile_pos = p; tile.terrain = "plains"
		tile.outpost_owner = -1; tile.outpost_level = 0; tile.resource_cap = {"food": 50.0}
		state.world.tiles[tile.tile_id] = tile
	state.persons[0] = leader
	var team := TeamData.new(); team.team_id = 0; team.leader_id = 0; team.population = 3
	team.tile_pos = Vector2i(4,4); team.resources = {"food": 0.0}
	state.teams[0] = team
	fai._trigger_survival(state, team, "urgent")
	# urgent + 野心0.6 + 無主可農地 → 應選紮營（或至少非 idle release）
	assert(team.current_task != TeamData.TASK_IDLE and team.current_task != "",
		"urgent 求生型流民應有活路，實際 task=%s" % team.current_task)
	print("desperation cascade OK (task=%s)" % team.current_task)
```

- [ ] **Step 2: 跑確認失敗** — 舊邏輯：不兇(跳 loot)、honor 0.6<1.2(跳投靠)、無 game(跳狩獵)、無施主(乞食失敗)→ release idle → assert 失敗。

- [ ] **Step 3: 實作**

`_trigger_survival`，將 **Path 2 起（殘忍/好戰掠奪）到 Path 4（乞食）之間**重構為 pref×gate 分流。保留 Path 0（蓋農田不中斷）、Path 1（own outpost 回家）不動。

```gdscript
	# === desperation × values 分流（取代舊 Path 2/3 + 併 3.4/3.5/4）===
	var gate: float = 1.0 if severity == "warning" else 0.0   # urgent 解閘

	# 蒐集 (pref, 可行性 callable, 設定 callable)，依 pref 由高到低試
	var options: Array = []   # [{pref, gate_min, action}]
	options.append({"pref": _loot_pref(leader), "gate_min": LOOT_GATE,
		"kind": "loot"})
	options.append({"pref": _join_pref(leader), "gate_min": JOIN_GATE,
		"kind": "join"})
	options.append({"pref": _camp_pref(leader), "gate_min": CAMP_GATE,
		"kind": "camp"})
	options.sort_custom(func(a, b): return a["pref"] > b["pref"])

	# 狩獵不受 gate，先嘗試（隨時可墊）；但若有更高 pref 的可行選項先走？
	# 設計：依 pref 試 loot/join/camp（過 gate×gate_mult 才行）；途中無一可行 → 狩獵 → 乞食 → idle
	for opt in options:
		if opt["pref"] < opt["gate_min"] * gate:
			continue   # 個性門檻未過（warning）；urgent gate=0 → 必過
		match opt["kind"]:
			"loot":
				var prey_id: int = _find_weakest_prey(state, team)
				if prey_id != -1 and TaskArbiter.try_set(state, team, TeamData.TASK_LOOT,
						state.teams[prey_id].tile_pos, TaskArbiter.PRIO_SURVIVAL, "survival"):
					team.combat_target = prey_id
					return
			"join":
				var ally_id: int = _find_strong_neighbor(state, team)
				if ally_id != -1 and TaskArbiter.try_set(state, team, "投靠",
						state.teams[ally_id].tile_pos, TaskArbiter.PRIO_SURVIVAL, "survival"):
					team.combat_target = ally_id
					return
			"camp":
				var camp_pos: Vector2i = _find_unowned_farmable_tile(state, team)
				if camp_pos != Vector2i(-1, -1) and TaskArbiter.try_set(state, team,
						TeamData.TASK_CAMP, camp_pos, TaskArbiter.PRIO_SURVIVAL, "survival"):
					print("[SurvivalCamp] team=Team%d → 紮營 @(%d,%d)" % [
						team.team_id, camp_pos.x, camp_pos.y])
					return

	# 墊底序：主動獵獸 → 覓食 → 乞食 → idle（既有 Path 3.4/3.5/4 邏輯保留於此後）
	if try_hunt_predator(state, team):
		print("[BeastHunt] team=Team%d 主動獵腳下掠食者" % team.team_id)
		return
	if team.population <= FORAGE_VIABLE_POP:
		var forage_pos: Vector2i = _find_forage_tile(state, team)
		if forage_pos != Vector2i(-1, -1) and TaskArbiter.try_set(state, team,
				TeamData.TASK_FORAGE, forage_pos, TaskArbiter.PRIO_SURVIVAL, "survival"):
			print("[SurvivalForage] team=Team%d → 覓食" % team.team_id)
			return
	var aid_target: int = _find_aid_target(state, team)
	if aid_target != -1 and TaskArbiter.try_set(state, team, "乞食",
			state.teams[aid_target].tile_pos, TaskArbiter.PRIO_SURVIVAL, "survival"):
		team.combat_target = aid_target
		return
	TaskArbiter.release(team)
	team.previous_task = ""
```

刪除被取代的舊 Path 2 / Path 3 / Path 3.4 / 3.5 / 4 區塊（避免重複）。保留 Path 0 / Path 1。

注意：`TASK_CAMP` 須加入 `SURVIVAL_TASKS`（釋放判定）— `const SURVIVAL_TASKS` 補 `TeamData.TASK_CAMP`。

- [ ] **Step 4: 跑確認通過** — `desperation cascade OK`，且既有 survival 測試（`_test_survival_decision_tree` 等）不回歸（必要時微調 fixture，記錄）。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat: _trigger_survival 重構為 desperation×values（urgent 解閘人人有活路）"
```

---

## Task 5: 註冊 + 重量測

**Files:**
- Modify: `scripts/debug/headless_test.gd`（`_initialize`）

- [ ] **Step 1: 註冊** `_test_survival_prefs` / `_test_find_unowned_farmable` / `_test_crude_camp` / `_test_desperation_cascade`。

- [ ] **Step 2: 全測試** — `--import` 後跑，無新增 SCRIPT ERROR；既有 survival 測試綠（如改 fixture 記錄於 handback）。

- [ ] **Step 3: 重量測 2 年 ×3**

```bash
$env:SIM_CONFIGS = "survival_start,tyrant,warzone"; .\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd *> godot_desperation.log
iconv -f UTF-16LE -t UTF-8 godot_desperation.log > godot_desperation_u8.log
grep -a "多配置對比\|CoinAudit\|SCRIPT ERROR" godot_desperation_u8.log
for m in SurvivalLoot 投靠 SurvivalCamp CrudeCamp SurvivalForage 乞食 Famine; do printf "%-14s " "$m"; grep -ac "$m" godot_desperation_u8.log; done
grep -a "Extinct\|Person0.*餓\|Team0 滅" godot_desperation_u8.log | head
```

**驗收（核心）：**
- 三 config `died=no`、`coin_eq delta=0.00`、無新增 SCRIPT ERROR
- **survival_start team0 不再餓死滅團**（有活路 — 紮營/投靠/覓食擇一）
- **行為分佈多元**：SurvivalLoot / 投靠 / SurvivalCamp / SurvivalForage / 乞食 **多項 >0**（非全擠一種）
- **正常 team 不誤觸**：tyrant/warzone 高糧 team 不出現 survival task（survival 印只在低糧隊）
- **建村率合理**：CrudeCamp 不爆量（非遍地建村）
- pop 較 2c 改善（team0 有活路 → survival_start 不崩到個位數）

- [ ] **Step 4: 判斷 + tune（一次一變因）**

| 觀測 | 動作 |
|---|---|
| team0 仍餓死 | urgent 解閘未生效 / 無任何可行選項 → 查 cascade gate 邏輯 |
| 行為單一（全紮營/全投靠） | 調 pref 權重或 *_GATE 平衡多樣性 |
| 遍地建村 | 升 CAMP_GATE / 限 camp 僅 urgent |
| 正常 team 誤觸 | 不該發生（觸發未改）；若有 → 查是否誤動觸發 |

- [ ] **Step 5: handback** — `docs/superpowers/handbacks/2026-06-14-desperation-survival-behavior.md`，附行為分佈 + team0 命運 + pop 對比。

---

## 注意事項（給實作者）

- **觸發不可改**：`days_left < WARNING_DAYS` 進求生的條件**不動**。只重構觸發後的選項分流。測試含「正常高糧 team 不觸發」。
- **latch 防護**：`TASK_CAMP` 加入 `SURVIVAL_TASKS`；所有選項走既有糧恢復釋放（`SURVIVAL_RECOVER_DAYS`）。勿造 sticky（W5）。
- **守恆**：crude camp 認領無主地、免建材（求生豁免，反映搭棚）；coin_eq delta=0 必驗。
- **勿膨脹**：pref = 簡單 values 線性；全在 `_trigger_survival` + helpers。非戰略引擎。
- **圖利掠奪不動**：`_evaluate_prosperity_attack` 維持（流浪盜匪不餓也搶）。
- **數值全 TEST VALUE**：pref 權重 / *_GATE / CRUDE_CAMP_FOOD_SEED → Step 4 量測 tune，一次一變因（避免鑽牛角尖）。
- **injury/medicine 不在本 plan**（狩獵受傷→醫療為另案）。
- 到達 hook（Task 3）若無現成 per-task 處理，用 `_evaluate_survival` 開頭檢查 TASK_CAMP 到位即立營的 fallback。
