# Config-Driven 場景設定統一架構 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `GameSetup.setup` 支援 `mode: "explicit"` 明確列 teams；建立 `config/demo.json`、`config/game_sim_test.json`；`main.gd` 與 `game_sim_test.gd` 改為從 JSON 讀場景（含玩家指令時程）。

**Architecture:** `GameSetup` 加 `_setup_explicit_teams` + `_run_command_schedule` 兩個新函數；`config/default.json` 加 `mode` 欄位（預設 random 保持向後相容）；3 個新 config 檔。

**Tech Stack:** Godot 4.2.2 GDScript；JSON via `GameSetup.load_config`；headless test 驗證。

**Spec:** `docs/superpowers/specs/2026-06-07-config-driven-setup-design.md`

---

## 檔案結構

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/game_setup.gd` | 加 `_setup_explicit_teams`、`_setup_player`、`_make_person`、`run_command_schedule` |
| `config/default.json` | 加 `"mode": "random"` 欄位（保持原行為）|
| `config/demo.json` | **新建** — main.gd 用，3 team 簡單場景 |
| `config/game_sim_test.json` | **新建** — game_sim_test.gd 用，5 team + 玩家指令時程 |
| `scripts/ui/main.gd` | 移除手寫 setup（line 21-61）→ `GameSetup.load_config + setup` |
| `scripts/debug/game_sim_test.gd` | 移除 `_setup_teams` / `_setup_outposts` / `_inject_player_commands`（改讀 config）|
| `scripts/debug/headless_test.gd` | 加新測試 `_test_config_driven_setup` |

## 執行測試的標準命令

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd
```

---

## Task 1: `GameSetup.setup` 支援 `mode: "explicit"` 分支

**Files:**
- Modify: `scripts/simulation/game_setup.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加失敗測試**

`headless_test.gd` 末尾加：

```gdscript
func _test_setup_mode_explicit() -> void:
	print("--- Config Task1: GameSetup mode=explicit ---")
	var state := WorldState.new()
	var config: Dictionary = {
		"seed": 42,
		"map": { "radius": 4 },
		"mode": "explicit",
		"teams": [
			{
				"id": 0,
				"name": "玩家",
				"tile_pos": [4, 4],
				"population": 8,
				"tags": ["統領"],
				"faction_id": 0,
				"is_faction_leader": true,
				"resources": { "food": 96.0, "coin": 600 },
				"leader": { "name": "TestLeader", "skills": { "統領": 0.7 } },
				"named_members": []
			}
		],
		"player": { "team_id": 0, "is_leader": true }
	}
	GameSetup.setup(state, config)
	assert(state.teams.has(0), "Team 0 應建立")
	var t: TeamData = state.teams[0]
	assert(t.population == 8, "pop 應 8，實際=%d" % t.population)
	assert(t.tile_pos == Vector2i(4, 4), "tile_pos 應 (4,4)，實際=%s" % str(t.tile_pos))
	assert(float(t.resources.get("food", 0)) == 96.0, "food 應 96")
	assert(state.player_id == t.leader_id, "player_id 應 = team leader_id")
	print("Config Task1 OK")
```

於 `_initialize()` 加 `_test_setup_mode_explicit()`。

- [ ] **Step 2: 跑測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：assertion fail（`mode: explicit` 未實作，setup 仍走 random）

- [ ] **Step 3: 改 `GameSetup.setup` 加 mode 分支**

打開 `scripts/simulation/game_setup.gd`，找 `static func setup`，把原本內容包進 mode 判斷：

```gdscript
static func setup(state: WorldState, config: Dictionary) -> void:
	var mode: String = config.get("mode", "random")
	var rng := RandomNumberGenerator.new()
	rng.seed = int(config.get("seed", 42))
	_generate_map(state, config, rng)
	if mode == "explicit":
		_setup_explicit_teams(state, config)
	else:
		var plan := _plan_outposts(state, config, rng)
		_generate_factions(state, plan, config, rng)
		_generate_independents(state, plan, config, rng)
	_setup_player(state, config)
```

注意：原來 `setup` 內已有的 `_generate_map / _plan_outposts / _generate_factions / _generate_independents` 邏輯整段搬進 else 分支。`_setup_player` 提取出來給兩個 mode 共用（若舊邏輯有玩家設定散在 _generate_factions 內，搬到 _setup_player）。

- [ ] **Step 4: 新增 `_setup_explicit_teams` + `_setup_player` 函數**

加在 `game_setup.gd` 末尾：

```gdscript
static func _setup_explicit_teams(state: WorldState, config: Dictionary) -> void:
	var teams_cfg: Array = config.get("teams", [])
	if teams_cfg.is_empty():
		push_error("explicit mode 但 teams 陣列為空")
		return
	# 建 faction（從 teams 反推）
	var seen_factions: Dictionary = {}
	for t_cfg in teams_cfg:
		var fid: int = int(t_cfg.get("faction_id", -1))
		if fid == -1: continue
		if seen_factions.has(fid): continue
		seen_factions[fid] = true
		var leader_team_id: int = int(t_cfg.get("id", -1)) if t_cfg.get("is_faction_leader", false) else -1
		if leader_team_id != -1:
			state.create_faction(int(t_cfg["id"]))
	# 建 teams
	for t_cfg in teams_cfg:
		_build_explicit_team(state, t_cfg)
	# 雙向發現（測試/demo 場景假設互知）
	for ta_cfg in teams_cfg:
		var ta_id: int = int(ta_cfg["id"])
		state.team_discovered[ta_id] = []
		state.team_known[ta_id] = []
		for tb_cfg in teams_cfg:
			var tb_id: int = int(tb_cfg["id"])
			if ta_id != tb_id and not state.team_discovered[ta_id].has(tb_id):
				state.team_discovered[ta_id].append(tb_id)

static func _build_explicit_team(state: WorldState, t_cfg: Dictionary) -> void:
	var team := TeamData.new()
	team.team_id = int(t_cfg["id"])
	var pos_arr: Array = t_cfg.get("tile_pos", [0, 0])
	team.tile_pos = Vector2i(int(pos_arr[0]), int(pos_arr[1]))
	team.population = int(t_cfg.get("population", 1))
	team.tags = t_cfg.get("tags", []).duplicate()
	team.faction_id = int(t_cfg.get("faction_id", -1))
	var base_res: Dictionary = TeamData.new().resources.duplicate()
	for k in t_cfg.get("resources", {}):
		base_res[k] = t_cfg["resources"][k]
	team.resources = base_res
	state.teams[team.team_id] = team
	# leader
	var leader_cfg: Dictionary = t_cfg.get("leader", {})
	var leader: PersonData = _make_person(team.team_id, leader_cfg, true)
	state.persons[leader.id] = leader
	team.leader_id = leader.id
	# named members
	for nm_cfg in t_cfg.get("named_members", []):
		var nm: PersonData = _make_person(team.team_id, nm_cfg, false)
		state.persons[nm.id] = nm
		team.named_members.append(nm.id)
	# outpost on tile (若指定)
	var op_cfg: Dictionary = t_cfg.get("outpost", {})
	if not op_cfg.is_empty():
		var tile_id: int = team.tile_pos.x * 1000 + team.tile_pos.y
		var tile: HexTileData = state.world.tiles.get(tile_id)
		if tile:
			tile.outpost_type = op_cfg.get("type", "civilian")
			tile.outpost_level = int(op_cfg.get("level", 1))
			tile.outpost_owner = team.team_id
			if op_cfg.has("tile_food_init"):
				tile.resources["food"] = float(op_cfg["tile_food_init"])
	# 加入 faction member list
	if team.faction_id != -1 and state.factions.has(team.faction_id):
		var f: FactionData = state.factions[team.faction_id]
		if not f.member_team_ids.has(team.team_id):
			f.member_team_ids.append(team.team_id)

static func _make_person(team_id: int, p_cfg: Dictionary, is_leader: bool) -> PersonData:
	var p := PersonData.new()
	# id 自動配（用全域 counter；簡單做法：team_id*1000 + 序號）
	p.id = (team_id * 1000) + (0 if is_leader else _next_member_id(team_id))
	p.person_name = p_cfg.get("name", "P%d" % p.id)
	p.role = "leader" if is_leader else "civilian"
	p.team_id = team_id
	p.age = int(p_cfg.get("age", 30))
	p.loyalty = float(p_cfg.get("loyalty", 0.8))
	p.stress = float(p_cfg.get("stress", 0.0))
	p.salary = float(p_cfg.get("salary", 0.0))
	for k in p_cfg.get("skills", {}):
		p.skills[k] = float(p_cfg["skills"][k])
	for k in p_cfg.get("values", {}):
		p.values[k] = float(p_cfg["values"][k])
	for k in p_cfg.get("attributes", {}):
		p.attributes[k] = float(p_cfg["attributes"][k])
	return p

static var _member_counters: Dictionary = {}
static func _next_member_id(team_id: int) -> int:
	var n: int = int(_member_counters.get(team_id, 0)) + 1
	_member_counters[team_id] = n
	return n

static func _setup_player(state: WorldState, config: Dictionary) -> void:
	var pcfg: Dictionary = config.get("player", {})
	if pcfg.is_empty():
		return
	var pteam_id: int = int(pcfg.get("team_id", -1))
	if pteam_id == -1 or not state.teams.has(pteam_id):
		push_warning("player.team_id=%d 不存在" % pteam_id)
		return
	var pteam: TeamData = state.teams[pteam_id]
	state.player_id = pteam.leader_id
```

- [ ] **Step 5: 跑測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
```
--- Config Task1: GameSetup mode=explicit ---
Config Task1 OK
```

- [ ] **Step 6: Regression 檢查 — random mode 不破**

驗證 playtest_minimal 仍能跑（如果可用）：

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/playtest_minimal.gd
```

預期：照舊跑，無 error。

- [ ] **Step 7: Commit**

```powershell
git add scripts/simulation/game_setup.gd scripts/debug/headless_test.gd
git commit -m "feat(setup): GameSetup mode=explicit branch for hand-listed teams (Task 1)"
```

---

## Task 2: `config/default.json` 加 mode + 建 `config/demo.json`

**Files:**
- Modify: `config/default.json`
- Create: `config/demo.json`

- [ ] **Step 1: `default.json` 加 mode 欄位**

打開 `config/default.json`，在 `seed` 之後加：

```json
{
  "seed": 42,
  "mode": "random",
  ...
}
```

（如果 setup 已預設 random，這步可省，但寫明更清楚。）

- [ ] **Step 2: 建 `config/demo.json`**

新建 `config/demo.json`：

```json
{
  "seed": 42,
  "mode": "explicit",
  "map": { "radius": 4, "resource_richness": 5 },
  "teams": [
    {
      "id": 0,
      "name": "玩家隊",
      "tile_pos": [0, 0],
      "population": 10,
      "tags": ["統領"],
      "faction_id": 0,
      "is_faction_leader": true,
      "resources": {
        "food": 120.0,
        "material": 100,
        "coin": 200,
        "weapon_melee_low": 5,
        "armor_low": 2,
        "medicine": 5,
        "tools": 5
      },
      "leader": {
        "name": "玩家",
        "age": 25,
        "loyalty": 0.8,
        "skills": { "統領": 0.5, "生產": 0.3, "戰鬥": 0.2 }
      },
      "named_members": [
        { "name": "P0_1", "skills": { "統領": 0.2, "戰鬥": 0.3 }, "loyalty": 0.8 },
        { "name": "P0_2", "skills": { "統領": 0.2, "生產": 0.3 }, "loyalty": 0.8 }
      ],
      "outpost": { "type": "civilian", "level": 1, "tile_food_init": 1000 }
    },
    {
      "id": 1,
      "name": "鄰隊1",
      "tile_pos": [1, 0],
      "population": 10,
      "tags": ["統領"],
      "faction_id": 1,
      "is_faction_leader": true,
      "resources": {
        "food": 120.0,
        "material": 100,
        "coin": 200,
        "weapon_melee_low": 5,
        "armor_low": 2
      },
      "leader": {
        "name": "P1_0",
        "age": 27,
        "loyalty": 0.8,
        "skills": { "統領": 0.5, "戰鬥": 0.3 }
      },
      "named_members": [
        { "name": "P1_1", "skills": { "戰鬥": 0.3 }, "loyalty": 0.8 },
        { "name": "P1_2", "skills": { "戰鬥": 0.3 }, "loyalty": 0.8 }
      ]
    },
    {
      "id": 2,
      "name": "鄰隊2",
      "tile_pos": [2, 0],
      "population": 10,
      "tags": ["統領"],
      "faction_id": 2,
      "is_faction_leader": true,
      "resources": {
        "food": 120.0,
        "material": 100,
        "coin": 200,
        "weapon_melee_low": 5,
        "armor_low": 2
      },
      "leader": {
        "name": "P2_0",
        "age": 29,
        "loyalty": 0.8,
        "skills": { "統領": 0.5 }
      },
      "named_members": [
        { "name": "P2_1", "loyalty": 0.8 },
        { "name": "P2_2", "loyalty": 0.8 }
      ]
    }
  ],
  "player": { "team_id": 0, "is_leader": true }
}
```

- [ ] **Step 3: 驗證 `demo.json` JSON 合法**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script - <<EOF
extends SceneTree
func _initialize():
    var cfg = GameSetup.load_config("res://config/demo.json")
    print("teams: %d" % cfg.get("teams", []).size())
    quit()
EOF
```

或更簡單：跑一次測試確認 load 不報錯。

- [ ] **Step 4: Commit**

```powershell
git add config/default.json config/demo.json
git commit -m "config: add demo.json (3-team explicit) + default.json mode=random (Task 2)"
```

---

## Task 3: `main.gd` 改用 `config/demo.json`

**Files:**
- Modify: `scripts/ui/main.gd`

- [ ] **Step 1: 備份原 setup 邏輯（commit log 內留底）**

無實際動作，下一步直接改 code。git diff 會留歷史。

- [ ] **Step 2: 改 `_ready`**

打開 `scripts/ui/main.gd`，把 line 16-61 的 setup 邏輯改為：

```gdscript
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE   # 讓點擊穿透到地圖
	_runner = SimRunner.new()
	_state  = WorldState.new()
	var config := GameSetup.load_config("res://config/demo.json")
	GameSetup.setup(_state, config)
	PlayerSystem.new().init_player(_state, _state.player_id, _player_team_id())

	_bridge = SimBridge.new(_runner, _state)
	# ... 後續 UI setup 不動
```

注意 `_state.player_id` 已由 `GameSetup._setup_player` 設好。需要查 `PlayerSystem.init_player` 簽名，可能用 `(state, person_id, team_id)`。`_player_team_id()` helper：

```gdscript
func _player_team_id() -> int:
	var p: PersonData = _state.persons.get(_state.player_id)
	return p.team_id if p else 0
```

- [ ] **Step 3: 跑 Godot editor / runtime 確認 UI 能開**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe
# 開啟 scenes/Main.tscn 跑場景，確認 UI 正常顯示 3 teams
```

預期：地圖顯示 3 個 team flag，玩家在 Team0，可移動、看 sidebar。

- [ ] **Step 4: Commit**

```powershell
git add scripts/ui/main.gd
git commit -m "refactor(main): load demo scene from config/demo.json (Task 3)"
```

---

## Task 4: 建 `config/game_sim_test.json`（含 command_schedule）

**Files:**
- Create: `config/game_sim_test.json`

- [ ] **Step 1: 建 config**

新建 `config/game_sim_test.json`：

```json
{
  "seed": 77,
  "mode": "explicit",
  "max_ticks": 7200,
  "map": { "radius": 4, "resource_richness": 5 },
  "teams": [
    {
      "id": 0, "name": "玩家", "tile_pos": [4, 4], "population": 8,
      "tags": ["統領"], "faction_id": 0, "is_faction_leader": true,
      "resources": {
        "food": 96.0, "material": 200, "coin": 600, "weapon_melee_low": 12,
        "armor_low": 8, "medicine": 10, "tools": 5, "goods": 50
      },
      "leader": {
        "name": "T0_Leader", "age": 30, "loyalty": 0.9,
        "skills": { "統領": 0.7, "偵查": 0.4, "戰鬥": 0.4 },
        "values": { "義氣": 0.7, "信義": 0.7, "野心": 0.5 }
      },
      "named_members": [
        { "name": "T0_M1", "loyalty": 0.7, "salary": 3.0,
          "skills": { "戰鬥": 0.3 } },
        { "name": "T0_M2", "loyalty": 0.7, "salary": 3.0,
          "skills": { "戰鬥": 0.3 } }
      ],
      "outpost": { "type": "military", "level": 1, "tile_food_init": 2000 }
    },
    {
      "id": 1, "name": "友軍商隊", "tile_pos": [5, 4], "population": 6,
      "tags": ["商隊"], "faction_id": 0,
      "resources": {
        "food": 72.0, "material": 200, "coin": 600, "weapon_melee_low": 4,
        "armor_low": 2, "medicine": 10, "tools": 5, "goods": 50
      },
      "leader": {
        "name": "T1_Leader", "age": 31, "loyalty": 0.9,
        "skills": { "統領": 0.7, "商業": 0.5 },
        "values": { "義氣": 0.6, "信義": 0.7, "貪婪": 0.4 }
      },
      "named_members": [
        { "name": "T1_M1", "loyalty": 0.7 }
      ],
      "outpost": { "type": "civilian", "level": 1, "tile_food_init": 2000 }
    },
    {
      "id": 2, "name": "敵對軍隊", "tile_pos": [7, 5], "population": 10,
      "tags": ["軍隊"], "faction_id": 1, "is_faction_leader": true,
      "resources": {
        "food": 120.0, "material": 200, "coin": 600, "weapon_melee_low": 12,
        "armor_low": 8, "medicine": 10
      },
      "leader": {
        "name": "T2_Leader", "age": 32, "loyalty": 0.9,
        "skills": { "統領": 0.7, "戰鬥": 0.4 },
        "values": { "好戰": 0.8, "殘忍": 0.5, "義氣": 0.3 }
      },
      "named_members": [
        { "name": "T2_M1", "loyalty": 0.7, "skills": { "戰鬥": 0.3 } },
        { "name": "T2_M2", "loyalty": 0.7, "skills": { "戰鬥": 0.3 } }
      ],
      "outpost": { "type": "military", "level": 1, "tile_food_init": 2000 }
    },
    {
      "id": 3, "name": "生產村", "tile_pos": [5, 7], "population": 12,
      "tags": ["生產"], "faction_id": -1,
      "resources": {
        "food": 144.0, "material": 200, "coin": 600, "weapon_melee_low": 4,
        "medicine": 10
      },
      "leader": {
        "name": "T3_Leader", "age": 33, "loyalty": 0.9,
        "skills": { "統領": 0.7, "生產": 0.4 },
        "values": { "慎重": 0.6, "義氣": 0.5 }
      },
      "named_members": [
        { "name": "T3_M1", "loyalty": 0.7 },
        { "name": "T3_M2", "loyalty": 0.7 }
      ],
      "outpost": { "type": "civilian", "level": 1, "tile_food_init": 2000 }
    },
    {
      "id": 4, "name": "流亡盜匪", "tile_pos": [3, 3], "population": 5,
      "tags": ["流亡"], "faction_id": -1,
      "resources": {
        "food": 60.0, "coin": 600, "weapon_melee_low": 4
      },
      "leader": {
        "name": "T4_Leader", "age": 34, "loyalty": 0.9,
        "skills": { "統領": 0.7, "戰鬥": 0.4 },
        "values": { "好戰": 0.7, "貪婪": 0.8, "義氣": 0.2 }
      },
      "named_members": [
        { "name": "T4_M1", "loyalty": 0.7 },
        { "name": "T4_M2", "loyalty": 0.7 }
      ],
      "outpost": { "type": "military", "level": 1, "tile_food_init": 2000 }
    }
  ],
  "player": { "team_id": 0, "is_leader": true },
  "command_schedule": [
    { "tick": 240,  "action": "set_move_target",     "args": { "target_pos": [5, 4] } },
    { "tick": 720,  "action": "propose_alliance",    "args": { "team_id": 3 } },
    { "tick": 1200, "action": "submit_trade_offer",  "args": {
        "team_id": 3, "gives": { "food": 200.0 }, "wants": { "coin": 100.0 } } },
    { "tick": 2400, "action": "attack",              "args": { "team_id": 2 } },
    { "tick": 3600, "action": "recruit_named",       "args": { "team_id": 3 } },
    { "tick": 4800, "action": "build_outpost",       "args": { "type": "civilian" } }
  ]
}
```

注意：`args` 結構需符合 `player_command_system.execute_action` / `execute_action_with_target` 的真實簽名。Task 5 在執行 schedule 時要寫 adapter。

- [ ] **Step 2: 驗證 JSON 合法**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/playtest_minimal.gd
# 修改 playtest_minimal.gd 暫時 load game_sim_test.json 確認 setup OK
```

或更簡單：等 Task 5 完成後 game_sim_test 直接 load 驗證。

- [ ] **Step 3: Commit**

```powershell
git add config/game_sim_test.json
git commit -m "config: add game_sim_test.json (5-team + command_schedule) (Task 4)"
```

---

## Task 5: `game_sim_test.gd` 改讀 config + command_schedule 執行器

**Files:**
- Modify: `scripts/simulation/game_setup.gd`（加 `run_command_schedule_tick`）
- Modify: `scripts/debug/game_sim_test.gd`（移除手寫 setup，改讀 config）

- [ ] **Step 1: 加 `GameSetup.run_command_schedule_tick`**

於 `game_setup.gd` 末尾加：

```gdscript
static func run_command_schedule_tick(state: WorldState, cmd_sys,
		schedule: Array, current_tick: int) -> Dictionary:
	# 找符合 current_tick 的所有 entry，執行；回傳 {fired: [...], results: [...]}
	var fired: Array = []
	var results: Array = []
	for entry in schedule:
		if int(entry.get("tick", -1)) != current_tick:
			continue
		var action: String = entry.get("action", "")
		var args: Dictionary = entry.get("args", {})
		var r: Dictionary = _dispatch_command(state, cmd_sys, action, args)
		fired.append(action)
		results.append(r)
	return { "fired": fired, "results": results }

static func _dispatch_command(state: WorldState, cmd_sys, action: String, args: Dictionary) -> Dictionary:
	# 把 JSON args 轉成 player_command_system 的呼叫格式
	match action:
		"set_move_target":
			var pos_arr: Array = args.get("target_pos", [0, 0])
			state.player_state["move_target"] = Vector2i(int(pos_arr[0]), int(pos_arr[1]))
			return cmd_sys.execute_action(state, -1, "set_move_target")
		"propose_alliance", "attack", "submit_trade_offer", "recruit_named":
			var target_id: int = int(args.get("team_id", -1))
			# 處理特殊 args（trade）
			if action == "submit_trade_offer":
				state.player_state["trade_offer"] = {
					"player_gives": args.get("gives", {}),
					"player_wants": args.get("wants", {})
				}
			return cmd_sys.execute_action(state, target_id, action)
		"build_outpost":
			state.player_state["build_type"] = args.get("type", "civilian")
			return cmd_sys.execute_action(state, -1, "build_outpost")
		_:
			return { "ok": false, "msg": "未知 action: " + action }
```

注意：此 dispatcher 不是萬能，覆蓋常見 action。若 schedule 用到沒列的 action，需擴充。

- [ ] **Step 2: 改 `game_sim_test.gd` 走 config**

打開 `scripts/debug/game_sim_test.gd`，把 `_run_game_sim_test` 的 setup 改為：

```gdscript
func _run_game_sim_test() -> void:
	print("=== game_sim_test: 從 config 讀取場景 ===")
	var state := WorldState.new()
	var runner := SimRunner.new()
	var cmd := PlayerCommandSystem.new()
	var config := GameSetup.load_config("res://config/game_sim_test.json")
	if config.is_empty():
		print("[FAIL] config/game_sim_test.json 載入失敗")
		return
	GameSetup.setup(state, config)
	var max_ticks: int = int(config.get("max_ticks", 7200))
	var schedule: Array = config.get("command_schedule", [])
	# ... 主迴圈
	for tick in range(max_ticks):
		var player_pos: Vector2i = _player_pos(state)
		var advance_result: String = runner.advance_tick(state, player_pos)
		if state.encounter_active:
			_auto_drive_player_encounter(state, runner)
			if state.encounter_tick > 800:
				runner._encounter_system.resolve_encounter_end(state, "draw")
		# 玩家指令注入（從 schedule 讀）
		var sched_result: Dictionary = GameSetup.run_command_schedule_tick(
			state, cmd, schedule, tick + 1)
		for action in sched_result.get("fired", []):
			print("[Cmd] %s @ tick=%d" % [action, tick + 1])
		# ... 其餘印狀態/收集 stats 邏輯不動
```

移除原 `_setup_outposts`、`_setup_teams`、`_make_resources`、`_inject_player_commands`（這些都搬到 config / GameSetup）。

- [ ] **Step 3: 跑測試確認**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "ALL INVARIANTS|Feature 通過" | Select-Object -First 5
```

預期：`ALL INVARIANTS PASSED`、`Feature 通過：10/10`（或非 0/10）。

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/game_setup.gd scripts/debug/game_sim_test.gd
git commit -m "refactor(test): game_sim_test reads scene + command_schedule from JSON (Task 5)"
```

---

## Task 6: 整合驗證 + headless_test 加完整 config 測試

**Files:**
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 加完整 config 載入測試**

於 `headless_test.gd` 末尾加：

```gdscript
func _test_full_config_load() -> void:
	print("--- Config Task6: 完整 config 載入 ---")
	# demo.json
	var s1 := WorldState.new()
	var c1 := GameSetup.load_config("res://config/demo.json")
	assert(not c1.is_empty(), "demo.json 載入失敗")
	GameSetup.setup(s1, c1)
	assert(s1.teams.size() == 3, "demo 應 3 team，實際=%d" % s1.teams.size())
	assert(s1.player_id != -1, "demo player_id 應已設")
	# game_sim_test.json
	var s2 := WorldState.new()
	var c2 := GameSetup.load_config("res://config/game_sim_test.json")
	assert(not c2.is_empty(), "game_sim_test.json 載入失敗")
	GameSetup.setup(s2, c2)
	assert(s2.teams.size() == 5, "game_sim_test 應 5 team，實際=%d" % s2.teams.size())
	assert(c2.get("command_schedule", []).size() >= 6, "command_schedule 應有 ≥6 entries")
	# default.json 仍走 random
	var s3 := WorldState.new()
	var c3 := GameSetup.load_config("res://config/default.json")
	assert(c3.get("mode", "random") == "random", "default 應為 random mode")
	GameSetup.setup(s3, c3)
	assert(s3.teams.size() >= 2, "default 隨機應產生 >= 2 team")
	print("Config Task6 OK")
```

於 `_initialize()` 加 `_test_full_config_load()`。

- [ ] **Step 2: 跑全部測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：全部 OK，含 `Config Task1 OK`、`Config Task6 OK`。

- [ ] **Step 3: 跑 game_sim_test 整合驗證**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/game_sim_test.gd > godot_test.log 2>&1
Get-Content godot_test.log -Encoding UTF8 | Select-String "ALL INVARIANTS|Feature 通過" | Select-Object -First 3
```

預期：`ALL INVARIANTS PASSED`，Feature 通過率 ≥8/10（部分 feature 可能因 explicit setup 行為不同需調 assertion）。

- [ ] **Step 4: 撰寫 hand-back**

於 `docs/superpowers/handbacks/2026-06-07-config-driven-setup.md` 寫：

```markdown
# Hand Back: Config-Driven Setup

## 實作摘要

- `GameSetup.setup` 加 `mode` 分支：`random`（原行為）/ `explicit`（新）
- 新增 `_setup_explicit_teams`、`_build_explicit_team`、`_make_person`、`_setup_player`、`run_command_schedule_tick`、`_dispatch_command`
- 新 config：`config/demo.json`（3 team）、`config/game_sim_test.json`（5 team + 6 個 command schedule）
- `config/default.json` 加 `mode: "random"`（顯式標示）
- `main.gd` setup 70 行 → 5 行（load + setup）
- `game_sim_test.gd` setup 500+ 行 → load + schedule loop

## 連動風險

- `_dispatch_command` 只覆蓋常見 action（set_move_target、propose_alliance、attack、submit_trade_offer、recruit_named、build_outpost）。新 action 需手動加 case
- `_make_person` 用 `team_id*1000` 配 id，多 team 大規模時可能撞號
- `headless_test.gd` 未強制改（單元測試需精確控制）

## 待主 session 確認

- `_dispatch_command` 是否該移到 `player_command_system` 作為通用 router
- 多個 config 場景的 regression 測試是否要建 CI script
```

- [ ] **Step 5: Commit hand-back + 整合驗證**

```powershell
git add scripts/debug/headless_test.gd docs/superpowers/handbacks/2026-06-07-config-driven-setup.md
git commit -m "test+docs: config-driven setup full integration (Task 6)"
```

---

## 完成後狀態

| 項目 | 狀態 |
|---|---|
| `main.gd` setup | 5 行 load + setup |
| `game_sim_test.gd` setup | load + schedule loop |
| `playtest_minimal.gd` | 不動（已是 config 模式）|
| `headless_test.gd` | 單元測試仍手寫 setup（精確控制）|
| 3 個 config | `default.json` / `demo.json` / `game_sim_test.json` |
| 玩家指令時程 | JSON command_schedule |
| 全部測試 | OK |
