# Headless Play Architecture Implementation Plan (Phase 1)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實作 spec `docs/superpowers/specs/2026-06-01-headless-play-architecture-design.md` Phase 1：GameSetup 統一世界初始化、PersonGenerator 隨機人物、PlayerCommandSystem 補基礎 API、text_ui_main 重構為純 UI skin、playtest_minimal 給 session 驗證。

**Architecture:** 三層分離 —— Config (JSON) → GameSetup → Core (WorldState/SimRunner/PlayerCommandSystem) → UI skin（text_ui / playtest_minimal）。UI 不持邏輯。

**Tech Stack:** Godot 4.2.2 GDScript。驗證：headless_test + playtest_minimal 跑通；TextUI.tscn 手動啟動確認地圖有 NPC。

**Prerequisite:** Sub-session text-ui-renderer-fix 已 merge。SimBridge 有 `request_advance/tick_step/cancel_advance/is_advancing`；text_ui_main 有 `_process()`；TextMapRenderer 為 one-line-per-Y 版本。

---

## Task 1：PersonGenerator

**Files:**
- Create: `scripts/simulation/person_generator.gd`

- [ ] **Step 1：建立 PersonGenerator 檔案**

寫入 `scripts/simulation/person_generator.gd`：

```gdscript
class_name PersonGenerator

const SURNAMES: Array = [
    "趙", "錢", "孫", "李", "周", "吳", "鄭", "王",
    "馮", "陳", "褚", "衛", "蔣", "沈", "韓", "楊",
    "朱", "秦", "尤", "許", "何", "呂", "施", "張"
]
const GIVEN_NAMES: Array = [
    "明", "華", "強", "勇", "剛", "毅", "智", "誠",
    "信", "義", "禮", "仁", "孝", "忠", "和", "平",
    "風", "雷", "雲", "山", "海", "天", "玄", "靈"
]

# 生成一個 PersonData，seed_offset 決定隨機結果
# role: "leader" / "member"（leader 技能 +0.1 bonus）
static func generate(state: WorldState, seed_offset: int,
        role: String = "member") -> PersonData:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_offset

    var p := PersonData.new()
    p.id = _next_id(state)
    p.person_name = _random_name(rng, state)
    p.role = role
    p.age = rng.randi_range(18, 50)
    p.loyalty = 1.0 if role == "leader" else rng.randf_range(0.5, 1.0)
    p.stress = 0.0
    p.fear = 0.0

    # Values（直接 iterate PersonData 預設 8 鍵）
    for v in p.values.keys():
        p.values[v] = rng.randf_range(0.2, 0.8)

    # Attributes 0.4~0.8（PersonData 預設 4 鍵：體力/智力/魅力/毅力）
    for a in p.attributes.keys():
        p.attributes[a] = rng.randf_range(0.4, 0.8)

    # Skills 0.0~0.3（leader +0.1）
    for s in p.skills.keys():
        var base: float = rng.randf_range(0.0, 0.3)
        if role == "leader": base += 0.1
        p.skills[s] = clampf(base, 0.0, 1.0)

    return p

static func _next_id(state: WorldState) -> int:
    var max_id: int = -1
    for pid in state.persons:
        if int(pid) > max_id: max_id = int(pid)
    return max_id + 1

static func _random_name(rng: RandomNumberGenerator, state: WorldState) -> String:
    var attempts: int = 10
    while attempts > 0:
        var s: String = SURNAMES[rng.randi() % SURNAMES.size()]
        var g: String = GIVEN_NAMES[rng.randi() % GIVEN_NAMES.size()]
        var name: String = s + g
        var dup := false
        for pid in state.persons:
            if state.persons[pid].person_name == name:
                dup = true; break
        if not dup: return name
        attempts -= 1
    return "%s%s%d" % [SURNAMES[rng.randi() % SURNAMES.size()],
                       GIVEN_NAMES[rng.randi() % GIVEN_NAMES.size()],
                       state.persons.size()]
```

- [ ] **Step 2：重建 class 快取**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
```

預期：無 ERROR 訊息（新 class_name 註冊）。

- [ ] **Step 3：Commit**

```bash
git add scripts/simulation/person_generator.gd
git commit -m "feat(simulation): add PersonGenerator for random person creation"
```

---

## Task 2：WorldGenerator resource_multiplier 支援

**Files:**
- Modify: `scripts/simulation/world_generator.gd`

- [ ] **Step 1：generate() 加參數**

打開 `scripts/simulation/world_generator.gd`，修改 `generate()` 函式：

```gdscript
func generate(state: WorldState, config: Dictionary) -> void:
    var rng := RandomNumberGenerator.new()
    if config.get("seed", -1) == -1:
        rng.randomize()
    else:
        rng.seed = int(config.get("seed", 0))
    var radius: int = config.get("radius", 4)
    var mult: float = float(config.get("resource_multiplier", 1.0))
    for qx in range(-radius, radius + 1):
        for ry in range(-radius, radius + 1):
            if _hex_dist(Vector2i(qx, ry), Vector2i.ZERO) > radius:
                continue
            var ox: int = qx + radius
            var oy: int = ry + radius
            var tile = load("res://scripts/data/tile_data.gd").new()
            tile.tile_id  = ox * 1000 + oy
            tile.tile_pos = Vector2i(ox, oy)
            tile.terrain  = _random_terrain(rng)
            _apply_resources(tile, rng, mult)
            state.world.tiles[tile.tile_id] = tile
```

- [ ] **Step 2：_apply_resources 套用 mult**

修改 `_apply_resources`：

```gdscript
func _apply_resources(tile, rng: RandomNumberGenerator, mult: float = 1.0) -> void:
    tile.resources = {}
    var profile: Dictionary = RESOURCE_PROFILE[tile.terrain]
    for res in profile:
        var r: Array = profile[res]
        tile.resources[res] = int(rng.randi_range(r[0], r[1]) * mult)
    var prod_r: Array = PRODUCTIVITY_RANGE[tile.terrain]
    tile.productivity = rng.randf_range(prod_r[0], prod_r[1])
    if tile.terrain == "mountain":
        if rng.randf() < ORE_GOLD_CHANCE:
            tile.resources["ore_gold"] = int(rng.randi_range(5, 30) * mult)
        elif rng.randf() < ORE_SILVER_CHANCE:
            tile.resources["ore_silver"] = int(rng.randi_range(10, 60) * mult)
        if rng.randf() < GEM_CHANCE:
            tile.resources["gem"] = int(rng.randi_range(1, 8) * mult)
        if rng.randf() < ORE_IRON_MOUNTAIN_CHANCE:
            tile.resources["ore_iron"] = int(rng.randi_range(50, 150) * mult)
    elif tile.terrain == "plains":
        if rng.randf() < ORE_IRON_PLAINS_CHANCE:
            tile.resources["ore_iron"] = int(rng.randi_range(20, 60) * mult)
    tile.resource_cap = tile.resources.duplicate()
```

- [ ] **Step 3：headless test 驗證**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 SCRIPT ERROR。

- [ ] **Step 4：Commit**

```bash
git add scripts/simulation/world_generator.gd
git commit -m "feat(world): add resource_multiplier param to WorldGenerator.generate"
```

---

## Task 3：config/default.json

**Files:**
- Create: `config/default.json`

- [ ] **Step 1：建 config 目錄 + 預設檔**

確認 config 目錄存在：

```powershell
if (-not (Test-Path config)) { New-Item -ItemType Directory config }
```

寫入 `config/default.json`：

```json
{
  "seed": 42,

  "map": {
    "radius": 8,
    "resource_richness": 5
  },

  "outposts": {
    "total_count": 10,
    "type_ratio": { "civilian": 0.8, "military": 0.2 },
    "independent_ratio": 0.3,
    "min_spacing": 2
  },

  "factions": {
    "count": 3,
    "weights": [3, 2, 1],
    "teams_per_faction_range": [2, 4]
  },

  "independent_teams": {
    "roving_count_range": [2, 4]
  },

  "teams": {
    "population_range": [8, 25],
    "named_ratio": 0.3
  },

  "player": {
    "join_mode": "independent",
    "population": 10,
    "starting_named_count": 1,
    "starting_resources": {
      "food": 50.0, "material": 5.0, "coin": 50,
      "weapon_melee_low": 5
    },
    "leader_name": "玩家"
  }
}
```

- [ ] **Step 2：Commit**

```bash
git add config/default.json
git commit -m "feat(config): add default world config (radius 8, 10 outposts, 3 factions)"
```

---

## Task 4：PlayerCommandSystem 擴充

**Files:**
- Modify: `scripts/simulation/player_command_system.gd`

- [ ] **Step 1：加 get_player_person**

打開 `scripts/simulation/player_command_system.gd`，找到 `_get_player_team` 區域。**已有 `_get_player_team` private helper，新增 public `get_player_team` + `get_player_person`：**

在檔案適當位置（例如 helpers 區段）加：

```gdscript
# Public API：取得玩家 team
func get_player_team(state: WorldState) -> TeamData:
    return _get_player_team(state)

# Public API：取得玩家 person
func get_player_person(state: WorldState) -> PersonData:
    return state.persons.get(state.player_id)
```

若 `_get_player_team` 不存在，改寫為：

```gdscript
func get_player_team(state: WorldState) -> TeamData:
    var p: PersonData = state.persons.get(state.player_id)
    if p == null: return null
    return state.teams.get(p.team_id)

func get_player_person(state: WorldState) -> PersonData:
    return state.persons.get(state.player_id)
```

並把現有 `_get_player_team` 內部呼叫改為 `get_player_team`（如有重複定義刪除舊的）。

- [ ] **Step 2：加 move_to / cancel_move**

在 `clear_pending_targets` 上方加：

```gdscript
# 設定玩家 team 移動目標（SimRunner 推進時實際移動）
func move_to(state: WorldState, target_pos: Vector2i) -> Dictionary:
    var pt: TeamData = get_player_team(state)
    if pt == null:
        return { "ok": false, "msg": "玩家 team 不存在" }
    var key: int = target_pos.x * 1000 + target_pos.y
    if not state.world.tiles.has(key):
        return { "ok": false, "msg": "目標格不在地圖內" }
    if pt.tile_pos == target_pos:
        return { "ok": true, "msg": "已在目標格" }
    pt.move_target = target_pos
    return { "ok": true, "msg": "設定目標 (%d,%d)" % [target_pos.x, target_pos.y] }

func cancel_move(state: WorldState) -> Dictionary:
    var pt: TeamData = get_player_team(state)
    if pt == null:
        return { "ok": false, "msg": "玩家 team 不存在" }
    pt.move_target = Vector2i(-1, -1)
    return { "ok": true, "msg": "取消移動" }
```

- [ ] **Step 3：加 inspect_team / inspect_member**

在 `move_to` 上方加查詢 API 區段：

```gdscript
# ── 查詢 API ─────────────────────────

# 取得 team 摘要 dict
func inspect_team(state: WorldState, team_id: int) -> Dictionary:
    var t: TeamData = state.teams.get(team_id)
    if t == null: return {}
    var leader: PersonData = state.persons.get(t.leader_id)
    var members: Array = []
    for pid in t.named_members:
        var p: PersonData = state.persons.get(pid)
        if p:
            members.append({
                "id": p.id, "name": p.person_name, "role": p.role,
                "loyalty": p.loyalty, "fatigue": p.stress
            })
    var leader_info: Dictionary = {}
    if leader:
        leader_info = { "id": leader.id, "name": leader.person_name }
    return {
        "team_id": t.team_id, "tile_pos": t.tile_pos, "population": t.population,
        "fatigue": t.fatigue, "current_task": t.current_task,
        "faction_id": t.faction_id, "tags": t.tags,
        "leader": leader_info, "named_members": members,
        "resources": t.resources
    }

# 取得 person 完整 dict
func inspect_member(state: WorldState, person_id: int) -> Dictionary:
    var p: PersonData = state.persons.get(person_id)
    if p == null: return {}
    return {
        "id": p.id, "name": p.person_name, "role": p.role,
        "team_id": p.team_id, "age": p.age,
        "loyalty": p.loyalty, "stress": p.stress, "fear": p.fear,
        "values": p.values, "attributes": p.attributes, "skills": p.skills,
        "equipment": p.equipment
    }
```

- [ ] **Step 4：headless test 驗證**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 SCRIPT ERROR。

- [ ] **Step 5：Commit**

```bash
git add scripts/simulation/player_command_system.gd
git commit -m "feat(player-cmd): add move_to, cancel_move, inspect_team, inspect_member, get_player_person"
```

---

## Task 5：GameSetup 模組（核心，較大）

**Files:**
- Create: `scripts/simulation/game_setup.gd`

- [ ] **Step 1：建立 GameSetup 骨架 + setup() + load_config()**

寫入 `scripts/simulation/game_setup.gd`：

```gdscript
class_name GameSetup

const RICHNESS_MULT: Dictionary = {
    1: 0.2, 2: 0.4, 3: 0.6, 4: 0.8, 5: 1.0,
    6: 1.5, 7: 2.5, 8: 4.0, 9: 6.5, 10: 10.0
}

const TEAM_RESOURCE_PRESET: Dictionary = {
    "faction_main": {
        "food": 300.0, "material": 80.0, "coin": 50,
        "weapon_melee_low": 8, "armor_low": 4
    },
    "faction_branch": {
        "food": 150.0, "material": 30.0, "coin": 15,
        "weapon_melee_low": 4, "armor_low": 1
    },
    "independent_settled": {
        "food": 200.0, "material": 60.0, "coin": 20
    },
    "independent_roving": {
        "food": 80.0, "coin": 8, "weapon_melee_low": 2
    }
}

const FLOAT_RES_KEYS: Array = ["food", "material"]

static func setup(state: WorldState, config: Dictionary) -> void:
    var seed_val: int = int(config.get("seed", 42))
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_val

    _generate_map(state, config, rng)
    var outpost_plan: Dictionary = _plan_outposts(state, config, rng)
    _generate_factions(state, outpost_plan, config, rng)
    _generate_independent_teams(state, outpost_plan, config, rng)
    _setup_player(state, config, rng)

    print("[GameSetup] 完成：%d teams, %d factions, %d persons" %
        [state.teams.size(), state.factions.size(), state.persons.size()])

static func load_config(path: String) -> Dictionary:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Config not found: " + path)
        return {}
    var json := JSON.new()
    var err := json.parse(file.get_as_text())
    if err != OK:
        push_error("Config JSON parse error at line %d: %s" % [
            json.get_error_line(), json.get_error_message()])
        return {}
    return json.data

# ── 子步驟（後續 step 補完） ──
static func _generate_map(state, config, rng) -> void: pass
static func _plan_outposts(state, config, rng) -> Dictionary: return {}
static func _generate_factions(state, plan, config, rng) -> void: pass
static func _generate_independent_teams(state, plan, config, rng) -> void: pass
static func _setup_player(state, config, rng) -> void: pass
```

- [ ] **Step 2：補 _generate_map**

替換 `_generate_map` stub：

```gdscript
static func _generate_map(state, config, rng) -> void:
    var map_cfg: Dictionary = config.get("map", {})
    var richness_level: int = int(map_cfg.get("resource_richness", 5))
    var richness_mult: float = RICHNESS_MULT.get(richness_level, 1.0)

    var gen = load("res://scripts/simulation/world_generator.gd").new()
    gen.generate(state, {
        "radius": int(map_cfg.get("radius", 4)),
        "seed": rng.randi(),
        "resource_multiplier": richness_mult
    })
```

- [ ] **Step 3：補 helpers（內部 ID/位置工具）**

在檔案結尾加：

```gdscript
# ── 內部 helpers ──────────────────────────────────────

static func _next_team_id(state: WorldState) -> int:
    var m: int = -1
    for tid in state.teams:
        if int(tid) > m: m = int(tid)
    return m + 1

static func _next_person_id(state: WorldState) -> int:
    var m: int = -1
    for pid in state.persons:
        if int(pid) > m: m = int(pid)
    return m + 1

static func _hex_dist(a: Vector2i, b: Vector2i) -> int:
    var dx := b.x - a.x; var dy := b.y - a.y
    return (abs(dx) + abs(dx + dy) + abs(dy)) / 2

static func _is_tile_occupied(state: WorldState, pos: Vector2i) -> bool:
    for tid in state.teams:
        if state.teams[tid].tile_pos == pos: return true
    return false

static func _random_near(positions: Array, rng) -> Vector2i:
    if positions.is_empty(): return Vector2i(0, 0)
    var origin: Vector2i = positions[rng.randi() % positions.size()]
    var dirs: Array = [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1),
                       Vector2i(0,-1), Vector2i(1,-1), Vector2i(-1,1)]
    return origin + dirs[rng.randi() % dirs.size()]

static func _random_empty_tile(state: WorldState, rng) -> Vector2i:
    var keys: Array = state.world.tiles.keys()
    if keys.is_empty(): return Vector2i(0, 0)
    var attempts: int = 50
    while attempts > 0:
        var k: int = keys[rng.randi() % keys.size()]
        var pos := Vector2i(k / 1000, k % 1000)
        if not _is_tile_occupied(state, pos):
            return pos
        attempts -= 1
    return Vector2i(keys[0] / 1000, keys[0] % 1000)

static func _build_outpost_tile(state: WorldState, pos: Vector2i,
        type_str: String, level: int, owner_team_id: int) -> void:
    var key: int = pos.x * 1000 + pos.y
    var tile: HexTileData = state.world.tiles.get(key)
    if tile == null: return
    tile.outpost_type  = type_str
    tile.outpost_level = level
    tile.outpost_owner = owner_team_id

static func _default_full_resources() -> Dictionary:
    return {
        "food": 0.0, "material": 0.0, "coin": 0, "goods": 0,
        "gem": 0, "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
        "weapon_melee_low": 0, "weapon_melee_high": 0,
        "weapon_ranged_low": 0, "weapon_ranged_high": 0,
        "mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
        "armor_low": 0, "armor_high": 0
    }

static func _apply_preset_resources(team: TeamData, preset_key: String,
        richness_mult: float) -> void:
    var preset: Dictionary = TEAM_RESOURCE_PRESET[preset_key]
    for k in preset:
        if k in FLOAT_RES_KEYS:
            team.resources[k] = float(preset[k]) * richness_mult
        else:
            team.resources[k] = int(round(float(preset[k]) * richness_mult))
```

- [ ] **Step 4：補 _create_team helper**

在 helpers 區段加：

```gdscript
# 建一個 team（含 leader + named members），加入 state，回傳 TeamData
static func _create_team(state: WorldState, rng, pop_range: Array,
        named_ratio: float, richness_mult: float, preset_key: String) -> TeamData:
    var team := TeamData.new()
    team.team_id = _next_team_id(state)
    team.population = rng.randi_range(pop_range[0], pop_range[1])

    match preset_key:
        "faction_main":         team.tags = ["統領"]
        "faction_branch":       team.tags = ["獨立軍隊"]
        "independent_settled":  team.tags = []
        "independent_roving":   team.tags = ["獨立軍隊"]

    team.resources = _default_full_resources()
    _apply_preset_resources(team, preset_key, richness_mult)

    var leader := PersonGenerator.generate(state, rng.randi(), "leader")
    leader.team_id = team.team_id
    state.persons[leader.id] = leader
    team.leader_id = leader.id

    var named_count: int = maxi(0, int(round(team.population * named_ratio)) - 1)
    for _i in range(named_count):
        var m := PersonGenerator.generate(state, rng.randi(), "member")
        m.team_id = team.team_id
        state.persons[m.id] = m
        team.named_members.append(m.id)

    state.teams[team.team_id] = team
    state.team_known[team.team_id] = []
    state.team_discovered[team.team_id] = []
    return team
```

- [ ] **Step 5：補 _plan_outposts**

替換 stub：

```gdscript
# 回傳：{
#   "faction_outposts": Dictionary { faction_idx: Array[Vector2i] },
#   "independent_outposts": Array[Vector2i],
#   "outpost_types": Dictionary { Vector2i: String (civilian/military) }
# }
static func _plan_outposts(state, config, rng) -> Dictionary:
    var ocfg: Dictionary = config.get("outposts", {})
    var total: int = int(ocfg.get("total_count", 10))
    var min_sp: int = int(ocfg.get("min_spacing", 2))
    var indep_ratio: float = float(ocfg.get("independent_ratio", 0.3))
    var type_ratio: Dictionary = ocfg.get("type_ratio",
        { "civilian": 0.6, "military": 0.4 })

    var gen = load("res://scripts/simulation/world_generator.gd").new()
    var positions: Array = gen.pick_start_positions(state, total, min_sp)
    if positions.size() < total:
        push_warning("Only %d outposts placed (wanted %d)" % [positions.size(), total])

    var types: Dictionary = {}
    var civ_ratio: float = float(type_ratio.get("civilian", 0.6))
    for pos in positions:
        types[pos] = "civilian" if rng.randf() < civ_ratio else "military"

    var indep_count: int = int(round(positions.size() * indep_ratio))
    var indep_outposts: Array = positions.slice(0, indep_count)
    var faction_pool: Array = positions.slice(indep_count)

    var fcfg: Dictionary = config.get("factions", {})
    var fcount: int = int(fcfg.get("count", 2))
    var weights: Array = fcfg.get("weights", [])
    if weights.size() < fcount:
        weights = []
        for i in range(fcount):
            weights.append(1)

    var total_w: int = 0
    for w in weights: total_w += int(w)
    if total_w == 0: total_w = 1

    var faction_outposts: Dictionary = {}
    var assigned: int = 0
    for fi in range(fcount):
        var share: int
        if fi == fcount - 1:
            share = faction_pool.size() - assigned
        else:
            share = int(faction_pool.size() * float(weights[fi]) / float(total_w))
        faction_outposts[fi] = faction_pool.slice(assigned, assigned + share)
        assigned += share

    return {
        "faction_outposts": faction_outposts,
        "independent_outposts": indep_outposts,
        "outpost_types": types
    }
```

- [ ] **Step 6：補 _generate_factions**

替換 stub：

```gdscript
static func _generate_factions(state, plan, config, rng) -> void:
    var fcfg: Dictionary = config.get("factions", {})
    var range_per: Array = fcfg.get("teams_per_faction_range", [2, 4])
    var tcfg: Dictionary = config.get("teams", {})
    var pop_range: Array = tcfg.get("population_range", [8, 25])
    var named_ratio: float = float(tcfg.get("named_ratio", 0.3))
    var richness_mult: float = RICHNESS_MULT.get(
        int(config.get("map", {}).get("resource_richness", 5)), 1.0)

    for fi in plan.faction_outposts:
        var outposts: Array = plan.faction_outposts[fi]
        if outposts.is_empty(): continue

        var main_pos: Vector2i = outposts[0]
        var main_type: String = plan.outpost_types[main_pos]

        var team_count: int = rng.randi_range(range_per[0], range_per[1])
        var this_faction_team_ids: Array = []
        for ti in range(team_count):
            var team: TeamData = _create_team(state, rng, pop_range,
                named_ratio, richness_mult,
                "faction_main" if ti == 0 else "faction_branch")
            if ti == 0:
                team.tile_pos = main_pos
            else:
                team.tile_pos = _random_near(outposts, rng)
            this_faction_team_ids.append(team.team_id)

        var first_team_id: int = this_faction_team_ids[0]
        var faction_id: int = state.create_faction(first_team_id)

        for tid in this_faction_team_ids.slice(1):
            state.factions[faction_id].member_team_ids.append(tid)
            state.teams[tid].faction_id = faction_id

        _build_outpost_tile(state, main_pos, main_type, 1, first_team_id)
        for opos in outposts.slice(1):
            _build_outpost_tile(state, opos, plan.outpost_types[opos], 1, first_team_id)
```

- [ ] **Step 7：補 _generate_independent_teams**

替換 stub：

```gdscript
static func _generate_independent_teams(state, plan, config, rng) -> void:
    var indep_cfg: Dictionary = config.get("independent_teams", {})
    var tcfg: Dictionary = config.get("teams", {})
    var pop_range: Array = tcfg.get("population_range", [8, 25])
    var named_ratio: float = float(tcfg.get("named_ratio", 0.3))
    var richness_mult: float = RICHNESS_MULT.get(
        int(config.get("map", {}).get("resource_richness", 5)), 1.0)

    for opos in plan.independent_outposts:
        _build_outpost_tile(state, opos, plan.outpost_types[opos], 1, -1)
        if rng.randf() < 0.5:
            var team: TeamData = _create_team(state, rng, pop_range,
                named_ratio, richness_mult, "independent_settled")
            team.tile_pos = opos
            var key: int = opos.x * 1000 + opos.y
            state.world.tiles[key].outpost_owner = team.team_id

    var roving_range: Array = indep_cfg.get("roving_count_range", [2, 4])
    var roving_count: int = rng.randi_range(roving_range[0], roving_range[1])
    for _i in range(roving_count):
        var team: TeamData = _create_team(state, rng, pop_range,
            named_ratio, richness_mult, "independent_roving")
        team.tile_pos = _random_empty_tile(state, rng)
```

- [ ] **Step 8：補 _setup_player + _find_weakest_faction**

替換 stub：

```gdscript
static func _setup_player(state, config, rng) -> void:
    var pcfg: Dictionary = config.get("player", {})
    var join_mode: String = pcfg.get("join_mode", "independent")
    var richness_mult: float = RICHNESS_MULT.get(
        int(config.get("map", {}).get("resource_richness", 5)), 1.0)

    var team := TeamData.new()
    team.team_id = _next_team_id(state)
    team.population = int(pcfg.get("population", 10))
    team.tags = ["統領"]
    team.resources = _default_full_resources()
    var starting: Dictionary = pcfg.get("starting_resources", {})
    for k in starting:
        if k in FLOAT_RES_KEYS:
            team.resources[k] = float(starting[k]) * richness_mult
        else:
            team.resources[k] = int(round(float(starting[k]) * richness_mult))

    var leader := PersonData.new()
    leader.id = _next_person_id(state)
    leader.person_name = pcfg.get("leader_name", "玩家")
    leader.role = "leader"
    leader.team_id = team.team_id
    leader.age = 30
    leader.loyalty = 1.0
    state.persons[leader.id] = leader
    team.leader_id = leader.id
    state.player_id = leader.id

    var named_count: int = int(pcfg.get("starting_named_count", 1))
    for _i in range(named_count):
        var m := PersonGenerator.generate(state, rng.randi(), "member")
        m.team_id = team.team_id
        state.persons[m.id] = m
        team.named_members.append(m.id)

    state.teams[team.team_id] = team
    state.team_known[team.team_id] = []
    state.team_discovered[team.team_id] = []
    state.player_state = { "inventory": [],
                           "coin": float(starting.get("coin", 0)) }

    match join_mode:
        "independent":
            team.tile_pos = _random_empty_tile(state, rng)

        "new_faction":
            var weakest_fid: int = _find_weakest_faction(state, config)
            if weakest_fid == -1:
                team.tile_pos = _random_empty_tile(state, rng)
                push_warning("No faction to take over, fallback to independent")
            else:
                var faction = state.factions[weakest_fid]
                var old_leader_team: TeamData = state.teams.get(faction.leader_team_id)
                if old_leader_team:
                    team.tile_pos = old_leader_team.tile_pos
                else:
                    team.tile_pos = _random_empty_tile(state, rng)
                team.faction_id = weakest_fid
                var old_leader_tid: int = faction.leader_team_id
                faction.leader_team_id = team.team_id
                if not faction.member_team_ids.has(team.team_id):
                    faction.member_team_ids.append(team.team_id)
                print("[GameSetup] 玩家成為勢力 %d 統領（原 leader_team=%d 保留為下屬）" %
                    [weakest_fid, old_leader_tid])

        _:
            if join_mode.begins_with("join:"):
                var fi: int = int(join_mode.substr(5))
                if state.factions.has(fi):
                    team.faction_id = fi
                    state.factions[fi].member_team_ids.append(team.team_id)
                    var lt: TeamData = state.teams.get(state.factions[fi].leader_team_id)
                    if lt:
                        team.tile_pos = _random_near([lt.tile_pos], rng)
                    else:
                        team.tile_pos = _random_empty_tile(state, rng)
                else:
                    team.tile_pos = _random_empty_tile(state, rng)
                    push_warning("Faction %d not found, fallback to independent" % fi)
            else:
                team.tile_pos = _random_empty_tile(state, rng)
                push_warning("Unknown join_mode: %s" % join_mode)

static func _find_weakest_faction(state, config) -> int:
    var weights: Array = config.get("factions", {}).get("weights", [])
    if weights.is_empty() or state.factions.is_empty():
        return -1
    var min_w: int = 999999; var min_idx: int = -1
    for i in range(weights.size()):
        if int(weights[i]) < min_w:
            min_w = int(weights[i])
            min_idx = i
    var sorted_fids: Array = state.factions.keys()
    sorted_fids.sort()
    if min_idx >= 0 and min_idx < sorted_fids.size():
        return sorted_fids[min_idx]
    return -1
```

- [ ] **Step 9：重建 class 快取 + headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，無 SCRIPT ERROR。GameSetup 還未被 headless_test 呼叫，但 class 載入必須無誤。

- [ ] **Step 10：Commit**

```bash
git add scripts/simulation/game_setup.gd
git commit -m "feat(simulation): add GameSetup for config-driven world initialization"
```

---

## Task 6：playtest_minimal.gd（驗證 GameSetup + PlayerCommandSystem）

**Files:**
- Create: `scripts/debug/playtest_minimal.gd`

- [ ] **Step 1：建立 playtest_minimal**

寫入 `scripts/debug/playtest_minimal.gd`：

```gdscript
extends SceneTree

func _init() -> void:
    print("=== playtest_minimal 開始 ===")
    var state := WorldState.new()
    var runner := SimRunner.new()
    var bridge := SimBridge.new(runner, state)
    var cmd := PlayerCommandSystem.new()

    var config := GameSetup.load_config("res://config/default.json")
    if config.is_empty():
        push_error("Config 載入失敗")
        quit(); return

    GameSetup.setup(state, config)
    print("世界建立：%d teams, %d factions, %d persons" %
        [state.teams.size(), state.factions.size(), state.persons.size()])

    var pt: TeamData = cmd.get_player_team(state)
    if pt == null:
        push_error("玩家 team 不存在"); quit(); return
    print("玩家 team: id=%d, pos=%s, faction=%d, pop=%d, named=%d" %
        [pt.team_id, str(pt.tile_pos), pt.faction_id,
         pt.population, pt.named_members.size()])
    print("玩家 leader: %s" % cmd.get_player_person(state).person_name)

    # 列出已生成 teams
    print("--- Teams ---")
    for tid in state.teams:
        var t: TeamData = state.teams[tid]
        var leader_name: String = ""
        var leader: PersonData = state.persons.get(t.leader_id)
        if leader: leader_name = leader.person_name
        print("  Team%d: pos=%s, fid=%d, pop=%d, leader=%s" %
            [tid, str(t.tile_pos), t.faction_id, t.population, leader_name])

    # 推進 7 天
    print("--- 推進 7 天 ---")
    bridge.advance_ticks(WorldState.TICKS_PER_DAY * 7)
    print("Tick: %d (Day %d)" % [state.world.current_tick,
        state.world.current_tick / WorldState.TICKS_PER_DAY])

    # inspect 玩家 team
    print("--- 玩家 inspect ---")
    var info: Dictionary = cmd.inspect_team(state, pt.team_id)
    print("  fatigue=%.3f, task=%s, faction=%d" %
        [info.get("fatigue"), info.get("current_task"), info.get("faction_id")])
    print("  food=%.1f, coin=%d" %
        [info.get("resources", {}).get("food", 0.0),
         info.get("resources", {}).get("coin", 0)])
    print("  已發現 teams: %s" % str(state.team_discovered.get(pt.team_id, [])))

    # 測試移動
    print("--- 測試 move_to ---")
    var target: Vector2i = pt.tile_pos + Vector2i(1, 0)
    var r: Dictionary = cmd.move_to(state, target)
    print("  move_to(%s): %s" % [str(target), str(r)])
    bridge.advance_ticks(WorldState.TICKS_PER_DAY * 3)
    print("  3 天後位置：%s（目標 %s, move_target=%s）" %
        [str(pt.tile_pos), str(target), str(pt.move_target)])

    print("=== playtest_minimal 完成 ===")
    quit()
```

- [ ] **Step 2：跑 playtest_minimal 驗證**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/playtest_minimal.gd
```

**驗收：**
- `=== playtest_minimal 完成 ===` 出現
- 世界 teams 數 ≥ 5（玩家 + 至少 4 NPC）
- factions 數 ≥ 1（依 config 為 3，但 weights[2]=1 可能 share=0 → 至少 1）
- 玩家 leader 名稱顯示為「玩家」
- 7 天後 fatigue 有數值（非 0.0）
- 玩家有發現至少一個 team（move 3 天後）

無 SCRIPT ERROR。

- [ ] **Step 3：Commit**

```bash
git add scripts/debug/playtest_minimal.gd
git commit -m "feat(debug): add playtest_minimal for GameSetup + PlayerCommandSystem verification"
```

---

## Task 7：text_ui_main 重構（使用 GameSetup + PlayerCommandSystem）

**Files:**
- Modify: `scripts/ui/text_ui_main.gd`

Task 5 + 6 必須先完成。

- [ ] **Step 1：_ready() 改用 GameSetup**

打開 `scripts/ui/text_ui_main.gd`，找到 `func _ready() -> void:`。

**替換整個 `_ready` 內容（保留簽名）為：**

```gdscript
func _ready() -> void:
    _state  = WorldState.new()
    _runner = SimRunner.new()
    _bridge = SimBridge.new(_runner, _state)
    _player_cmd = PlayerCommandSystem.new()

    var config := GameSetup.load_config("res://config/default.json")
    GameSetup.setup(_state, config)

    _player_tid = _state.persons[_state.player_id].team_id
    var pt: TeamData = _state.teams[_player_tid]
    _cursor = pt.tile_pos
    _refresh()
```

**注意：** 原本手動建立的 `team` / `leader` / `state.player_state` 程式碼整段移除（由 GameSetup 處理）。

確認 `_player_cmd` 變數已宣告。若無，於檔案頂部 var 區段加：

```gdscript
var _player_cmd: PlayerCommandSystem
```

- [ ] **Step 2：KEY_M 改呼叫 PlayerCommandSystem.move_to**

找到 `KEY_M:` 段落（在 `_input` 內），**替換為：**

```gdscript
		KEY_M:
			var r: Dictionary = _player_cmd.move_to(_state, _cursor)
			if r.get("ok"):
				_log_event(r.get("msg", ""))
				_bridge.request_advance(99999)
				_input_bar.text = "移動中 [Esc]停止"
			else:
				_log_event(r.get("msg", "移動失敗"))
			_refresh()
```

- [ ] **Step 3：刪除 _do_move_auto 函式**

找到 `func _do_move_auto() -> void:`，**整段刪除**（從 `func` 到下一個 `func` 之前）。

- [ ] **Step 4：_process() 加移動完成偵測**

找到 `func _process(_delta: float) -> void:`，**替換為：**

```gdscript
func _process(_delta: float) -> void:
    if not _bridge.is_advancing(): return
    var result := _bridge.tick_step()
    _events.append_array(result.get("events", []))
    if _events.size() > 100:
        _events = _events.slice(_events.size() - 100)

    # 移動完成偵測（move_target=-1,-1 表示到達或取消）
    var pt: TeamData = _state.teams.get(_player_tid)
    if pt and pt.move_target == Vector2i(-1, -1) \
            and _input_bar.text.begins_with("移動中"):
        _bridge.cancel_advance()
        _input_bar.text = ""
        _log_event("Team%d 到達 (%d,%d)" %
            [_player_tid, pt.tile_pos.x, pt.tile_pos.y])

    if result.get("done", false):
        _input_bar.text = ""
    elif not _input_bar.text.begins_with("移動中"):
        _input_bar.text = "推進中 Tick:%d [Esc]停止" % _state.world.current_tick
    _refresh()
    if _state.encounter_active:
        _bridge.cancel_advance()
```

- [ ] **Step 5：headless test + 手動 TextUI 驗證**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`。

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --scene scenes/TextUI.tscn
```

**人工驗收：**
- 開啟後地圖出現多個 team 數字標記（不再只有 `@`）
- WASD 移動游標
- M 鍵移到鄰格 → input_bar 顯示「移動中」→ 到達後變空 + log 顯示「到達 (x,y)」
- Esc 中途停止 → input_bar 清空
- T 鍵：若游標旁有 NPC，按 T 可看到目標列表（無則「無可互動目標」）

- [ ] **Step 6：Commit**

```bash
git add scripts/ui/text_ui_main.gd
git commit -m "refactor(ui): text_ui_main uses GameSetup + PlayerCommandSystem (remove _do_move_auto, _process detects move complete)"
```

---

## Task 8：最終驗收

- [ ] **Step 1：完整 headless test**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --import
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：`=== DONE ===`，0 SCRIPT ERROR。

- [ ] **Step 2：playtest_minimal**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/playtest_minimal.gd
```

預期：`=== playtest_minimal 完成 ===`，0 SCRIPT ERROR，所有驗收項通過。

- [ ] **Step 3：手動 TextUI**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --scene scenes/TextUI.tscn
```

預期：地圖有 NPC、能 M 移動、T 互動有目標。

- [ ] **Step 4：寫 hand-back**

寫 `docs/superpowers/handbacks/2026-06-01-headless-play-architecture.md`：

```markdown
# Hand Back: Headless Play Architecture (Phase 1)

## 實作摘要
- `scripts/simulation/person_generator.gd` 新建：24 漢字隨機人物生成
- `scripts/simulation/world_generator.gd` 擴充：generate() 加 resource_multiplier
- `config/default.json` 新建：預設世界 config
- `scripts/simulation/player_command_system.gd` 擴充：get_player_team/get_player_person/move_to/cancel_move/inspect_team/inspect_member
- `scripts/simulation/game_setup.gd` 新建：從 config 統一建世界（地圖 + 據點 + 勢力 + teams + 玩家）
- `scripts/debug/playtest_minimal.gd` 新建：session 驗證腳本
- `scripts/ui/text_ui_main.gd` 重構：_ready 改用 GameSetup；KEY_M 改呼叫 move_to；_do_move_auto 刪除；_process 加移動完成偵測

## 與 spec 差異
- （列出實作中遇到的偏離）

## 連動風險
- ...

## 待主 session 確認
- ...
```

- [ ] **Step 5：Commit hand-back**

```bash
git add docs/superpowers/handbacks/2026-06-01-headless-play-architecture.md
git commit -m "docs: hand-back for headless play architecture Phase 1"
```
