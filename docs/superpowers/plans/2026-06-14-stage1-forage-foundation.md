# 階段1 覓食地基 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 讓無據點的流民小隊能從腳下 tile 低率覓食食物活下來，NPC 對稱（小隊覓食、大軍不亂覓食），開局可玩。

**Architecture:** 覓食 = 現有 `ResourceSystem.collect_resources` 的小 delta（無 outpost 時走食物 only、低率、會枯竭的 forage 分支）。NPC 側在 `faction_ai_system._trigger_survival` cascade 插一條 forage path + pop 門檻（小群覓食、大群掉下去走現有掠奪/乞食）。新增開局 config。野獸狩獵屬 Plan 2，不在本 plan。

**Tech Stack:** Godot 4.2.2 GDScript；headless 測試（SceneTree + `assert`）；`.\tools\godot.ps1` wrapper（UTF-8）。

依據 spec：`docs/superpowers/specs/2026-06-14-stage1-survival-forage-hunt-design.md`（§1 覓食、§4 NPC forage path、§5 開局 config）。

---

## 檔案結構

- `scripts/simulation/resource_system.gd`（改）：新增 `FORAGE_RATE` const + `_forage_from_tile()`；`collect_resources` 的 `outpost_level==0` 分支改呼叫 forage（原為 `continue`）。日邊界覓食 episode 彙整。
- `scripts/data/team_data.gd`（改）：新增 `TASK_FORAGE` const + `forage_today` 累積欄位。
- `scripts/simulation/faction_ai_system.gd`（改）：`_trigger_survival` 插 forage path（乞食 Path4 之前）+ `FORAGE_VIABLE_POP` 門檻 + `_find_forage_tile()` helper。
- `config/survival_start.json`（建）：開局流民小隊劇本（無 outpost、少糧）。
- `scripts/debug/headless_test.gd`（改）：註冊新單元測試。

---

## Task 1: FORAGE_RATE + 無據點覓食食物（食物 only、枯竭）

**Files:**
- Modify: `scripts/simulation/resource_system.gd`（`collect_resources` line 47 分支 + 新增 `_forage_from_tile`）
- Test: `scripts/debug/headless_test.gd`（新 `_test_forage_no_outpost`）

- [ ] **Step 1: 寫失敗測試**

在 `headless_test.gd` 末尾加：

```gdscript
func _test_forage_no_outpost() -> void:
	print("--- Forage: 無 outpost 採食物 ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4 * 1000 + 4
	tile.tile_pos = Vector2i(4, 4)
	tile.terrain = "plains"
	tile.productivity = 1.0
	tile.harvest_factor = 1.0
	tile.outpost_level = 0   # 無 outpost
	tile.resources = {"food": 200.0, "material": 50.0}
	state.world.tiles[tile.tile_id] = tile
	var team := TeamData.new()
	team.team_id = 0
	team.population = 5
	team.tile_pos = Vector2i(4, 4)
	team.resources = {"food": 0.0, "material": 0.0}
	state.teams[0] = team
	var rs := ResourceSystem.new()
	rs.collect_resources(state, [0])
	# 食物應增加（forage），material 不變（覓食限食物）
	assert(float(team.resources["food"]) > 0.0, "無 outpost 應能覓食得食物，實際=%s" % str(team.resources["food"]))
	assert(float(team.resources.get("material", 0)) == 0.0, "覓食不應得 material，實際=%s" % str(team.resources.get("material", 0)))
	# tile 食物應被扣（枯竭）
	assert(float(tile.resources["food"]) < 200.0, "tile 食物應被扣，實際=%s" % str(tile.resources["food"]))
	print("Forage no-outpost OK")
```

並在 `_initialize()` 適當位置加 `_test_forage_no_outpost()`（見 Task 7）。

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — 無 outpost 時 `collect_resources` 現行 `continue`，food 維持 0 → 第一個 assert 失敗。

- [ ] **Step 3: 實作 forage 分支**

`resource_system.gd`：在 const 區（COLLECT_RATE 附近）加：

```gdscript
# 覓食：無據點隊從腳下 tile 低率採食物（只食物，不繞過據點經濟）。
# 率 < COLLECT_RATE：只減緩餓死、不餵飽 → 逼遷徙/定居。收入隨 pop_mult(≤2)封頂 + burn 線性 → 大群人均趨零。
const FORAGE_RATE: float = 0.02   # TEST VALUE
```

`collect_resources` 內，將 line 47-48：

```gdscript
		if tile.outpost_level == 0:
			continue
```

改為：

```gdscript
		if tile.outpost_level == 0:
			var pop_mult_f: float = clampf(sqrt(float(team.population) / 5.0), 0.5, 2.0)
			var leader_f = state.persons.get(team.leader_id)
			var prod_skill_f: float = float(leader_f.skills.get("生產", 0.0)) if leader_f else 0.0
			_forage_from_tile(state, team, tile, pop_mult_f, prod_skill_f)
			continue
```

在 `_collect_from_tile` 函數後新增：

```gdscript
# 覓食：無 outpost 隊採腳下 tile 食物（食物 only、FORAGE_RATE、枯竭、無稅無公庫）。
func _forage_from_tile(state: WorldState, team: TeamData, tile: HexTileData,
		pop_mult: float, prod_skill: float) -> void:
	var current: float = float(tile.resources.get("food", 0))
	if current <= 0.0:
		return
	var gain: float = tile.productivity * current * FORAGE_RATE
	gain *= pop_mult * team.work_morale
	gain *= (1.0 + prod_skill * 0.3)
	gain *= tile.harvest_factor
	team.resources["food"] = float(team.resources.get("food", 0)) + gain
	tile.resources["food"] = maxf(current - gain, 0.0)   # 枯竭
	team.forage_today = float(team.forage_today) + gain   # episode 日彙整（見 Task 3）
```

注意：`team.forage_today` 欄位在 Task 2 加；若先跑本測試會缺欄位 → 本 task 同時在 `team_data.gd` 加 `var forage_today: float = 0.0`（或先把該行註解，Task 2 補）。建議直接在本 step 一併加欄位（見下方 team_data 片段）。

`team_data.gd`：加欄位（與 resources 等並列）：

```gdscript
var forage_today: float = 0.0   # 當日覓食累積（episode 日彙整用，日邊界歸零）
```

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `Forage no-outpost OK`，無 assert 失敗。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/resource_system.gd scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat: 無據點隊覓食食物（FORAGE_RATE，食物only，枯竭）"
```

---

## Task 2: scale 鎖驗證（大群覓食人均趨零）

**Files:**
- Test: `scripts/debug/headless_test.gd`（新 `_test_forage_scale_cap`）

純驗證既有 `pop_mult` 封頂 vs burn 線性的性質 — 確保大軍不能靠覓食活。本 task 不改實作（性質已由 Task 1 + pop_mult clamp 提供），只加守護測試。

- [ ] **Step 1: 寫測試**

```gdscript
func _test_forage_scale_cap() -> void:
	print("--- Forage: 大群人均收入趨零 ---")
	var rs := ResourceSystem.new()
	# 同 tile、同設定，比較 pop=5 與 pop=60 的人均覓食收入
	var gains: Dictionary = {}
	for pop in [5, 60]:
		var state := WorldState.new()
		state.world = WorldData.new()
		var tile := HexTileData.new()
		tile.tile_id = 4 * 1000 + 4
		tile.tile_pos = Vector2i(4, 4)
		tile.terrain = "plains"; tile.productivity = 1.0; tile.harvest_factor = 1.0
		tile.outpost_level = 0
		tile.resources = {"food": 200.0}
		state.world.tiles[tile.tile_id] = tile
		var team := TeamData.new()
		team.team_id = 0; team.population = pop; team.tile_pos = Vector2i(4, 4)
		team.resources = {"food": 0.0}
		state.teams[0] = team
		rs.collect_resources(state, [0])
		gains[pop] = float(team.resources["food"]) / float(pop)   # 人均收入
	# pop=60 的人均收入應遠低於 pop=5（pop_mult 封頂 2.0，但人均 ÷pop）
	assert(gains[60] < gains[5] * 0.2,
		"大群人均應遠低於小群：pop5=%.3f pop60=%.3f" % [gains[5], gains[60]])
	print("Forage scale-cap OK (人均 pop5=%.3f pop60=%.3f)" % [gains[5], gains[60]])
```

- [ ] **Step 2: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `Forage scale-cap OK`。（pop_mult: sqrt(5/5)=1.0 vs sqrt(60/5)=3.46→clamp 2.0，總收入僅 2× 但人均 ÷12 → pop60 人均 ≈ pop5 的 1/6。）若失敗代表 pop_mult clamp 被破壞，須修。

- [ ] **Step 3: Commit**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test: 覓食 scale 鎖守護（大群人均趨零）"
```

---

## Task 3: 覓食 episode（日彙整 + 玩家隊訊息）

**Files:**
- Modify: `scripts/simulation/resource_system.gd`（新 `flush_forage_episodes`）
- Test: `scripts/debug/headless_test.gd`（新 `_test_forage_episode_daily`）

覓食所得日邊界彙整成一條 episode（避免 per-tick spam）。為避免全世界 NPC 洗版，**只對玩家 team 發訊息**；其餘隊僅歸零累積。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_forage_episode_daily() -> void:
	print("--- Forage: 日彙整 episode ---")
	var state := WorldState.new()
	state.world = WorldData.new()
	state.player_id = 100
	var leader := PersonData.new(); leader.id = 100; leader.team_id = 0
	state.persons[100] = leader
	var team := TeamData.new()
	team.team_id = 0; team.leader_id = 100; team.forage_today = 15.0
	state.teams[0] = team
	var rs := ResourceSystem.new()
	var msgs: Array = rs.flush_forage_episodes(state, [0])
	assert(team.forage_today == 0.0, "彙整後應歸零，實際=%s" % str(team.forage_today))
	assert(msgs.size() == 1, "玩家隊有覓食應產 1 條 episode，實際=%d" % msgs.size())
	print("Forage episode OK")
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `flush_forage_episodes` 未定義。

- [ ] **Step 3: 實作**

`resource_system.gd` 新增：

```gdscript
# 日邊界：覓食累積彙整成 episode（只玩家隊發訊息，其餘僅歸零防 spam）。回傳產生的訊息文字陣列（供測試/UI）。
func flush_forage_episodes(state: WorldState, team_ids: Array) -> Array:
	var out: Array = []
	for tid in team_ids:
		if not state.teams.has(tid):
			continue
		var team: TeamData = state.teams[tid]
		var got: float = float(team.forage_today)
		team.forage_today = 0.0
		if got <= 0.0:
			continue
		var is_player: bool = false
		var leader = state.persons.get(team.leader_id)
		if leader != null and leader.id == state.player_id:
			is_player = true
		if is_player:
			out.append("覓食所得 +%d 糧" % int(round(got)))
	return out
```

接入點（呼叫者）：在 `sim_runner` 日邊界（`current_tick % TICKS_PER_DAY == 0`）呼叫 `flush_forage_episodes` 並把回傳訊息餵給玩家事件流。**本 task 只實作 + 單元測試函數本身**；sim_runner 接入由 Task 8 整合驗證時確認（若 sim_runner 已有日邊界 hook 則加一行）。

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `Forage episode OK`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/resource_system.gd scripts/debug/headless_test.gd
git commit -m "feat: 覓食 episode 日彙整（玩家隊訊息）"
```

---

## Task 4: TASK_FORAGE const + NPC forage path 門檻

**Files:**
- Modify: `scripts/data/team_data.gd`（`TASK_FORAGE` const）
- Modify: `scripts/simulation/faction_ai_system.gd`（`_trigger_survival` 插 path + `FORAGE_VIABLE_POP` + `_find_forage_tile`）
- Test: `scripts/debug/headless_test.gd`（新 `_test_npc_forage_viability`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_npc_forage_viability() -> void:
	print("--- NPC forage path 門檻 ---")
	var fai := FactionAISystem.new()
	# 小隊（無 outpost、無獵物、低義氣）→ 應選 TASK_FORAGE
	var small := _mk_starving_team(0, 5)
	var st1 := _mk_state_with(small)
	fai._trigger_survival(st1, small, "urgent")
	assert(small.current_task == TeamData.TASK_FORAGE,
		"小隊應覓食，實際 task=%s" % small.current_task)
	# 大軍（同條件但 pop 大）→ 門檻擋掉，不應 forage（掉到乞食/idle）
	var big := _mk_starving_team(0, 60)
	var st2 := _mk_state_with(big)
	fai._trigger_survival(st2, big, "urgent")
	assert(big.current_task != TeamData.TASK_FORAGE,
		"大軍不應覓食，實際 task=%s" % big.current_task)
	print("NPC forage viability OK")

# helper：造一個飢餓、無 outpost、低義氣、無鄰隊的隊
func _mk_starving_team(tid: int, pop: int) -> TeamData:
	var t := TeamData.new()
	t.team_id = tid; t.population = pop; t.tile_pos = Vector2i(4, 4)
	t.resources = {"food": 0.0}
	return t

func _mk_state_with(team: TeamData) -> WorldState:
	var s := WorldState.new()
	s.world = WorldData.new()
	var tile := HexTileData.new()
	tile.tile_id = 4 * 1000 + 4; tile.tile_pos = Vector2i(4, 4)
	tile.terrain = "plains"; tile.productivity = 1.0; tile.harvest_factor = 1.0
	tile.outpost_level = 0; tile.resources = {"food": 200.0}
	s.world.tiles[tile.tile_id] = tile
	var leader := PersonData.new(); leader.id = team.team_id * 1000
	leader.team_id = team.team_id
	leader.values = {"殘忍": 0.2, "好戰": 0.2, "義氣": 0.2, "信義": 0.2}
	s.persons[leader.id] = leader
	team.leader_id = leader.id
	s.teams[team.team_id] = team
	return s
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `TeamData.TASK_FORAGE` 未定義 / forage path 未實作 → 小隊 task 非 forage。

- [ ] **Step 3: 實作**

`team_data.gd`：在 TASK_* const 區加：

```gdscript
const TASK_FORAGE: String = "覓食"
```

`faction_ai_system.gd`：const 區加：

```gdscript
const FORAGE_VIABLE_POP: int = 15   # TEST VALUE — pop ≤ 此值覓食划算（income/burn 比的粗略 proxy，待量測 tune）
```

`_trigger_survival` 內，於 **Path 4（乞食）之前**插入：

```gdscript
	# Path 3.5: 小群 → 覓食（pop 門檻 proxy income/burn；大軍不划算 → 掉下去走乞食/idle）
	if team.population <= FORAGE_VIABLE_POP:
		var forage_pos: Vector2i = _find_forage_tile(state, team)
		if forage_pos != Vector2i(-1, -1):
			if TaskArbiter.try_set(state, team, TeamData.TASK_FORAGE,
					forage_pos, TaskArbiter.PRIO_SURVIVAL, "survival"):
				print("[SurvivalForage] team=Team%d pop=%d → 覓食 @(%d,%d)" % [
					team.team_id, team.population, forage_pos.x, forage_pos.y])
			return
```

新增 helper（找視野內食物最多、無 outpost 的 tile；找不到回本格）：

```gdscript
# 找最佳覓食格：team_discovered 視野內食物池最高的無 outpost tile；無則回本格（原地覓食）。
func _find_forage_tile(state: WorldState, team: TeamData) -> Vector2i:
	var best_pos: Vector2i = team.tile_pos
	var best_food: float = -1.0
	# 本格 + 鄰格掃描（視野不足時退化為就近）
	var dirs: Array = [Vector2i.ZERO, Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1),
		Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,1)]
	for d in dirs:
		var p: Vector2i = team.tile_pos + d
		var tile: HexTileData = state.world.tiles.get(p.x * 1000 + p.y)
		if tile == null or tile.outpost_level > 0:
			continue
		var f: float = float(tile.resources.get("food", 0))
		if f > best_food:
			best_food = f
			best_pos = p
	return best_pos if best_food >= 0.0 else team.tile_pos
```

注意：`TaskArbiter.PRIO_SURVIVAL` 與 `try_set` 簽名沿用既有用法（同檔 Path1-4）。`_find_forage_tile` 不依賴 PathSystem，避免新耦合。

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `NPC forage viability OK`。

- [ ] **Step 5: Commit**

```bash
git add scripts/data/team_data.gd scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat: NPC survival forage path + pop 門檻（防大軍蟑螂）"
```

---

## Task 5: TASK_FORAGE 釋放條件（糧恢復則退出）

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`（`_evaluate_survival` 或 SURVIVAL_TASKS 釋放邏輯）
- Test: `scripts/debug/headless_test.gd`（新 `_test_forage_release`）

依 invariants「每個高優先 task 必須有釋放條件」：覓食吃飽（糧恢復）須釋放，否則 latch（重蹈 W5）。`TASK_FORAGE` 須加入 survival 釋放判定。

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_forage_release() -> void:
	print("--- Forage 釋放：糧恢復退出 ---")
	var fai := FactionAISystem.new()
	var team := _mk_starving_team(0, 5)
	team.current_task = TeamData.TASK_FORAGE
	var st := _mk_state_with(team)
	# 糧已恢復充足（> pop × 7 天份）→ 應釋放（task 不再是 FORAGE）
	team.resources["food"] = float(team.population) * 2.4 * 10.0
	fai._evaluate_survival(st, team)
	assert(team.current_task != TeamData.TASK_FORAGE,
		"糧恢復應釋放覓食，實際 task=%s" % team.current_task)
	print("Forage release OK")
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — `TASK_FORAGE` 未納入釋放判定 → 仍 sticky。

- [ ] **Step 3: 實作**

先讀 `faction_ai_system.gd` `_evaluate_survival`（約 line 1974）與 `SURVIVAL_TASKS` const（line 30）。將 `TASK_FORAGE` 納入「糧恢復則釋放」的既有邏輯：

- 若 `SURVIVAL_TASKS` 是釋放判定的依據，加入 forage：
```gdscript
const SURVIVAL_TASKS: Array = ["return_home", "乞食", "投靠", TeamData.TASK_FORAGE]
```
- 確認 `_evaluate_survival` 對糧充足（如 `food >= pop × FOOD_PER_PERSON_PER_DAY × 釋放天數`，沿用既有 hysteresis 門檻）的隊呼叫釋放（清 task 回 idle / previous_task）。若既有釋放只針對特定 task 名，補上 `TASK_FORAGE` 分支，行為比照 `return_home` 的糧恢復釋放。

（實作者：以既有 return_home 的釋放路徑為樣板，最小化新增邏輯。）

- [ ] **Step 4: 跑測試確認通過**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `Forage release OK`。

- [ ] **Step 5: Commit**

```bash
git add scripts/simulation/faction_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat: TASK_FORAGE 釋放條件（糧恢復退出，防 latch）"
```

---

## Task 6: 開局 config survival_start.json

**Files:**
- Create: `config/survival_start.json`
- Test: `scripts/debug/headless_test.gd`（新 `_test_survival_start_config`）

- [ ] **Step 1: 寫失敗測試**

```gdscript
func _test_survival_start_config() -> void:
	print("--- survival_start config 載入 ---")
	var state := WorldState.new()
	var config: Dictionary = GameSetup.load_config("res://config/survival_start.json")
	assert(not config.is_empty(), "config 載入失敗")
	GameSetup.setup(state, config)
	# 玩家隊存在、人少、站的格無 outpost
	var pid: int = state.player_id
	assert(pid != -1, "無玩家")
	var p: PersonData = state.persons[pid]
	var t: TeamData = state.teams[p.team_id]
	assert(t.population <= 5, "開局應小隊，實際 pop=%d" % t.population)
	var tile: HexTileData = state.world.tiles.get(t.tile_pos.x * 1000 + t.tile_pos.y)
	assert(tile != null and tile.outpost_level == 0, "開局玩家不應有 outpost")
	print("survival_start config OK")
```

- [ ] **Step 2: 跑測試確認失敗**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: FAIL — config 不存在。

- [ ] **Step 3: 建立 config**

`config/survival_start.json`（用 Edit/Write 工具，**勿用 PowerShell -replace**，會毀中文編碼）：

```json
{
  "seed": 7,
  "mode": "explicit",
  "max_ticks": 21600,
  "map": { "radius": 4, "resource_richness": 5 },
  "teams": [
    {
      "id": 0, "name": "流民", "tile_pos": [4, 4], "population": 3,
      "tags": ["流亡"], "faction_id": -1,
      "anon_tiers": { "平民": 2 },
      "resources": { "food": 30, "coin": 5, "weapon_melee_low": 1 },
      "leader": {
        "name": "頭目", "age": 28, "loyalty": 0.7,
        "skills": { "求生": 0.4, "偵查": 0.3 },
        "values": { "求生欲": 0.9, "義氣": 0.4 }
      },
      "named_members": []
    },
    {
      "id": 1, "name": "野村", "tile_pos": [2, 5], "population": 20,
      "tags": ["生產"], "faction_id": -1,
      "anon_tiers": { "平民": 18 },
      "resources": { "food": 150, "coin": 30 },
      "leader": {
        "name": "村長", "age": 50, "loyalty": 0.6,
        "skills": { "生產": 0.5 },
        "values": { "慎重": 0.7 }
      },
      "named_members": [],
      "outpost": { "type": "civilian", "level": 1, "tile_food_init": 400 }
    }
  ],
  "player": { "team_id": 0, "is_leader": true }
}
```

（座標驗證：(4,4) 中心 dist 0 ✓；(2,5) → q=-2,r=1 → dist=(2+1+1)/2=2 ✓。野村提供開局世界有個非玩家據點作互動/求助對象。）

- [ ] **Step 4: 跑測試確認通過**

先建 class 快取（雖無新 class_name，保險）再跑：
Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: `survival_start config OK`。

- [ ] **Step 5: Commit**

```bash
git add config/survival_start.json scripts/debug/headless_test.gd
git commit -m "feat: 開局 survival_start config（流民小隊無據點）"
```

---

## Task 7: 註冊測試 + 全測試綠燈

**Files:**
- Modify: `scripts/debug/headless_test.gd`（`_initialize()`）

- [ ] **Step 1: 註冊新測試**

在 `_initialize()` 末段加（其他測試之後）：

```gdscript
	_test_forage_no_outpost()
	_test_forage_scale_cap()
	_test_forage_episode_daily()
	_test_npc_forage_viability()
	_test_forage_release()
	_test_survival_start_config()
```

- [ ] **Step 2: 跑全套測試**

Run: `.\tools\godot.ps1 --headless --script scripts/debug/headless_test.gd`
Expected: 全部 OK，無 `SCRIPT ERROR`、無 assert 失敗。

- [ ] **Step 3: Commit**

```bash
git add scripts/debug/headless_test.gd
git commit -m "test: 註冊覓食地基單元測試"
```

---

## Task 8: 整合驗證（2 年 multi + 守恆 + team_trace）

**Files:**
- Modify（按需）: `scripts/simulation/sim_runner.gd`（日邊界呼叫 `flush_forage_episodes`，若尚未接）
- 驗證用，無新單元測試

- [ ] **Step 1: 接 episode flush（若 sim_runner 有日邊界 hook）**

讀 `sim_runner.gd`，在日邊界（`state.world.current_tick % WorldState.TICKS_PER_DAY == 0`）near-zone team 結算後，加：

```gdscript
	if state.world.current_tick % WorldState.TICKS_PER_DAY == 0:
		var ep: Array = _resource_system.flush_forage_episodes(state, near_team_ids)
		# ep 餵入玩家事件流（既有 events 管道；若無則暫存 state 供 UI 拉）
```

（實作者：依 sim_runner 既有事件管道接入；若管道複雜，最小化為 print + 留 TODO 給 UI plan。不可阻塞 tick。）

- [ ] **Step 2: 跑 2 年 multi（含 survival_start）**

```bash
$env:SIM_CONFIGS = "survival_start,tyrant,warzone"; .\tools\godot.ps1 --headless --script scripts/debug/game_sim_multi.gd *> godot_forage_verify.log
```

- [ ] **Step 3: 檢驗收標準**

轉 UTF-8 後檢查：
- `survival_start` died=no 或至少不在開局數日內全滅（小隊靠覓食撐過開局）
- 三 config `[CoinAudit] delta` ≈ 0.00（覓食不破守恆）
- 無 `SCRIPT ERROR`
- （若 game_sim_test 的 team_trace 可用）大軍（tyrant/warzone 軍隊隊）**不出現 TASK_FORAGE**（門檻有效）；小隊出現 forage

```bash
iconv -f UTF-16LE -t UTF-8 godot_forage_verify.log > godot_forage_verify_u8.log
grep -a "CoinAudit\|SCRIPT ERROR\|多配置對比\|SurvivalForage" godot_forage_verify_u8.log
```

- [ ] **Step 4: 達標 → handback；未達 → 記錄症狀回報主 session**

若 survival_start 小隊仍開局全滅 → 量測 forage 率是否過低（調 `FORAGE_RATE`）；若大軍出現 forage → 調 `FORAGE_VIABLE_POP`。**先量測再 tune（交接「避免鑽牛角尖」）**，調完重跑。

- [ ] **Step 5: Commit（如有 sim_runner 改動）**

```bash
git add scripts/simulation/sim_runner.gd
git commit -m "feat: sim_runner 日邊界接覓食 episode flush"
```

---

## 注意事項（給實作者）

- **編碼**：改 `config/*.json` 用 Edit/Write 工具，**勿用 PowerShell -replace**（毀中文）。godot 一律 `.\tools\godot.ps1` wrapper。
- **faction_ai_system 2000+ 行**：本 plan 只「插一條 path + helper + const」，**勿趁機重構**（另案）。改動限 `_trigger_survival` / `_evaluate_survival` / const 區局部。
- **TEST VALUE**：`FORAGE_RATE`(0.02)、`FORAGE_VIABLE_POP`(15) 為粗值 → Task 8 量測 tune，勿空想。
- **釋放條件**（Task 5）是 invariants 硬要求 — 覓食 latch = 重蹈 W5，務必過。
- **守恆**：Task 8 coin_eq delta 必須 ≈ 0。
- 野獸狩獵不在本 plan（Plan 2）。
