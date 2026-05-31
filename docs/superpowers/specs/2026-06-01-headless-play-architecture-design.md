# Headless Play Architecture Design Spec

**Date:** 2026-06-01
**Status:** Draft → Awaiting Review
**Scope:** Phase 1（最小可玩 + 架構基礎）

---

## 目標

讓遊戲核心**完全脫離 UI**，可在無 GUI 環境下用 config + 終端指令遊玩。仿 GNU 模擬軟體模式：

- Config 檔定義世界初始狀態
- 核心模擬與顯示分離
- 任意前端（terminal / 文字 UI / 圖形 UI / AI playtest）接入相同 API

**主要動機：**
- AI session 能獨立測試整個遊戲功能（不需 UI）
- UI bug 與遊戲邏輯 bug 可分離診斷
- 換 UI 不需動任何遊戲邏輯
- 文字 UI 目前無 NPC → GameSetup 立即解決

---

## 架構分層

```
┌───────────────────────────────────────────┐
│  config/*.json                            │  ← 世界初始狀態
└─────────────┬─────────────────────────────┘
              ↓
┌───────────────────────────────────────────┐
│  GameSetup                                │  ← 讀 config 建世界
│  scripts/simulation/game_setup.gd         │
└─────────────┬─────────────────────────────┘
              ↓
┌───────────────────────────────────────────┐
│  Core（UI-independent）                   │
│   WorldState   SimRunner   SimBridge     │
│   PlayerCommandSystem（完整 Player API）  │
│   PersonGenerator                         │
└─────────────┬─────────────────────────────┘
              ↓
┌────────────┬──────────────┬───────────────┐
│ Text UI    │ playtest_min │ (Phase 2/3)   │
│ skin       │ (測試用)     │ terminal / AI │
└────────────┴──────────────┴───────────────┘
```

**規則：** UI skin 只做兩件事 — 讀 WorldState 顯示、收輸入呼叫 PlayerCommandSystem。**任何計算都不能在 UI 層**。

---

## Phase 切分

| Phase | 範圍 | 解決問題 |
|---|---|---|
| **1（本 spec）** | GameSetup / PersonGenerator / PlayerCommandSystem 基礎 API / text_ui 重構 / playtest_minimal | 文字 UI 立即有 NPC 可玩；session 能 spawn 測試 |
| 2（之後 spec）| play_terminal.gd / PlayerCommandSystem 補完所有 API（salary/task/equip） | 無 UI 終端可遊玩 |
| 3（之後 spec）| playtest_session.gd 自動決策 AI / scenarios | AI session 自動 playtest |

---

## 1. Config 檔格式

**檔案位置：** `config/*.json`

**Phase 1 範例：** `config/default.json`

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
    "weights": [3, 2, 1]
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
    "starting_named_count": 1,
    "starting_resources": {
      "food": 50.0, "material": 5.0, "coin": 50,
      "weapon_melee_low": 5
    },
    "leader_name": "玩家"
  }
}
```

### 1.1 欄位說明

- **seed**：全域隨機種子（地圖、NPC、人物全用同一個）
- **map.resource_richness**：1-10 級豐裕度，對應乘數見 §1.2
- **outposts.type_ratio**：civilian / military 比例
- **outposts.independent_ratio**：保留給獨立的據點比例（不屬於任何勢力）
- **outposts.min_spacing**：任意兩據點最小 hex 距離（覆蓋 `OutpostSystem.MIN_DIST_ANY`）
- **factions.weights**：勢力據點數量加權（演算法見 §2.2 _plan_outposts）
- **independent_teams.roving_count_range**：除了據點獨立 team，再生成多少遊蕩獨立 team
- **teams.population_range**：每 team 隨機人口
- **teams.named_ratio**：人口中具名成員比例（剩下為匿名 → 反映 `population - leader - named_members.size()`）
- **player.join_mode**：`"independent"` / `"new_faction"` / `"join:<faction_index>"`
- **player.starting_named_count**：玩家 team 開局有幾個具名 NPC 成員（除 leader 外）

### 1.2 resource_richness 對應表

```gdscript
const RICHNESS_MULT: Dictionary = {
    1: 0.2, 2: 0.4, 3: 0.6, 4: 0.8, 5: 1.0,
    6: 1.5, 7: 2.5, 8: 4.0, 9: 6.5, 10: 10.0
}
```

乘數作用：
- 地圖 tile 資源（WorldGenerator 的 `RESOURCE_PROFILE` 範圍 × mult）
- Team preset 起始資源（§2.4）× mult

---

## 2. GameSetup 模組

**檔案：** `scripts/simulation/game_setup.gd`（新建）

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

# 從 config 建完整可玩世界
static func setup(state: WorldState, config: Dictionary) -> void:
    var seed: int = int(config.get("seed", 42))
    var rng := RandomNumberGenerator.new()
    rng.seed = seed
    
    # 1. 地圖
    _generate_map(state, config, rng)
    
    # 2. 據點位置 + 分配
    var outpost_plan: Dictionary = _plan_outposts(state, config, rng)
    
    # 3. 勢力 + 勢力 teams
    _generate_factions(state, outpost_plan, config, rng)
    
    # 4. 獨立 teams（據點型 + 遊蕩型）
    _generate_independent_teams(state, outpost_plan, config, rng)
    
    # 5. 玩家 team（依 join_mode 處理）
    _setup_player(state, config, rng)

# 從 JSON 檔載入 config
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
```

### 2.1 _generate_map

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

**注意：** `WorldGenerator` 需擴充支援 `resource_multiplier` 參數（乘到 `RESOURCE_PROFILE` 上）。

### 2.2 _plan_outposts

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
    var type_ratio: Dictionary = ocfg.get("type_ratio", { "civilian": 0.6, "military": 0.4 })
    
    # 從地圖選 total 個位置（依 min_spacing）
    var gen = load("res://scripts/simulation/world_generator.gd").new()
    var positions: Array = gen.pick_start_positions(state, total, min_sp)
    if positions.size() < total:
        push_warning("Only %d outposts placed (wanted %d)" % [positions.size(), total])
    
    # 隨機指定類型
    var types: Dictionary = {}
    for pos in positions:
        var roll: float = rng.randf()
        types[pos] = "civilian" if roll < float(type_ratio.get("civilian", 0.6)) else "military"
    
    # 分配：獨立 vs 勢力
    var indep_count: int = int(round(positions.size() * indep_ratio))
    var indep_outposts: Array = positions.slice(0, indep_count)
    var faction_outposts_pool: Array = positions.slice(indep_count)
    
    # 加權分給各勢力
    var fcfg: Dictionary = config.get("factions", {})
    var fcount: int = int(fcfg.get("count", 2))
    var weights: Array = fcfg.get("weights", [])
    if weights.size() < fcount:
        # 缺權重 → 平均
        weights = []
        for i in range(fcount):
            weights.append(1)
    
    var total_w: int = 0
    for w in weights: total_w += int(w)
    
    var faction_outposts: Dictionary = {}
    var assigned: int = 0
    for fi in range(fcount):
        var share: int = int(faction_outposts_pool.size() * float(weights[fi]) / float(total_w))
        if fi == fcount - 1:
            share = faction_outposts_pool.size() - assigned   # 最後一個吃剩下
        faction_outposts[fi] = faction_outposts_pool.slice(assigned, assigned + share)
        assigned += share
    
    return {
        "faction_outposts": faction_outposts,
        "independent_outposts": indep_outposts,
        "outpost_types": types
    }
```

### 2.3 _generate_factions

```gdscript
static func _generate_factions(state, plan, config, rng) -> void:
    var fcfg: Dictionary = config.get("factions", {})
    var range_per: Array = fcfg.get("teams_per_faction_range", [2, 4])
    var tcfg: Dictionary = config.get("teams", {})
    var pop_range: Array = tcfg.get("population_range", [8, 25])
    var named_ratio: float = float(tcfg.get("named_ratio", 0.3))
    var richness_mult: float = RICHNESS_MULT.get(int(config.get("map", {}).get("resource_richness", 5)), 1.0)
    
    for fi in plan.faction_outposts:
        var outposts: Array = plan.faction_outposts[fi]
        if outposts.is_empty(): continue
        
        # 1. 建主據點 tile（lvl 1）
        var main_pos: Vector2i = outposts[0]
        var main_type: String = plan.outpost_types[main_pos]
        _build_outpost_tile(state, main_pos, main_type, 1, -1)   # owner 暫設 -1，下面 set
        
        # 2. 生成 teams_per_faction_range 個 team，記錄 id 供後續加入勢力
        var team_count: int = rng.randi_range(range_per[0], range_per[1])
        var this_faction_team_ids: Array = []
        for ti in range(team_count):
            var team: TeamData = _create_team(state, rng, pop_range, named_ratio, richness_mult,
                "faction_main" if ti == 0 else "faction_branch")
            if ti == 0:
                team.tile_pos = main_pos
            else:
                team.tile_pos = _random_near(outposts, rng)
            this_faction_team_ids.append(team.team_id)
        
        var first_team_id: int = this_faction_team_ids[0]
        
        # 3. 建勢力（create_faction 已設 first_team.faction_id 並加入 member_team_ids）
        var faction_id: int = state.create_faction(first_team_id)
        
        # 4. 其餘 teams 加入勢力（明確用記錄的 id 清單）
        for tid in this_faction_team_ids.slice(1):
            state.factions[faction_id].member_team_ids.append(tid)
            state.teams[tid].faction_id = faction_id
        
        # 5. 主據點 owner 改為 leader team
        var main_tile: HexTileData = state.world.tiles[main_pos.x * 1000 + main_pos.y]
        main_tile.outpost_owner = first_team_id
        # 6. 其餘該勢力 outposts 建出來
        for opos in outposts.slice(1):
            _build_outpost_tile(state, opos, plan.outpost_types[opos], 1, first_team_id)
```

### 2.4 _generate_independent_teams

```gdscript
static func _generate_independent_teams(state, plan, config, rng) -> void:
    var indep_cfg: Dictionary = config.get("independent_teams", {})
    var tcfg: Dictionary = config.get("teams", {})
    var pop_range: Array = tcfg.get("population_range", [8, 25])
    var named_ratio: float = float(tcfg.get("named_ratio", 0.3))
    var richness_mult: float = RICHNESS_MULT.get(int(config.get("map", {}).get("resource_richness", 5)), 1.0)
    
    # 1. 每個獨立 outpost 50% 機率生成 team
    for opos in plan.independent_outposts:
        _build_outpost_tile(state, opos, plan.outpost_types[opos], 1, -1)
        if rng.randf() < 0.5:
            var team: TeamData = _create_team(state, rng, pop_range, named_ratio, richness_mult,
                "independent_settled")
            team.tile_pos = opos
            var tile: HexTileData = state.world.tiles[opos.x * 1000 + opos.y]
            tile.outpost_owner = team.team_id
    
    # 2. 遊蕩獨立 team
    var roving_range: Array = indep_cfg.get("roving_count_range", [2, 4])
    var roving_count: int = rng.randi_range(roving_range[0], roving_range[1])
    for _i in range(roving_count):
        var team: TeamData = _create_team(state, rng, pop_range, named_ratio, richness_mult,
            "independent_roving")
        team.tile_pos = _random_empty_tile(state, rng)
```

### 2.5 _create_team（核心 helper）

```gdscript
static func _create_team(state, rng, pop_range, named_ratio, richness_mult,
        preset_key: String) -> TeamData:
    var team := TeamData.new()
    team.team_id = _next_team_id(state)
    team.population = rng.randi_range(pop_range[0], pop_range[1])
    
    # Tags 依 preset
    match preset_key:
        "faction_main":         team.tags = ["統領"]
        "faction_branch":       team.tags = ["獨立軍隊"]
        "independent_settled":  team.tags = []
        "independent_roving":   team.tags = ["獨立軍隊"]
    
    # Resources（preset × richness）
    var preset: Dictionary = TEAM_RESOURCE_PRESET[preset_key]
    team.resources = _default_full_resources()
    for k in preset:
        team.resources[k] = preset[k] * richness_mult if k == "food" or k == "material" \
                            else int(preset[k] * richness_mult)
    
    # Leader（必有）
    var leader := PersonGenerator.generate(state, rng.randi(), "leader")
    leader.team_id = team.team_id
    state.persons[leader.id] = leader
    team.leader_id = leader.id
    
    # Named members（依 named_ratio）
    var named_count: int = int(round(team.population * named_ratio)) - 1   # 扣 leader
    named_count = maxi(0, named_count)
    for _i in range(named_count):
        var member := PersonGenerator.generate(state, rng.randi(), "member")
        member.team_id = team.team_id
        state.persons[member.id] = member
        team.named_members.append(member.id)
    
    state.teams[team.team_id] = team
    state.team_known[team.team_id] = []
    state.team_discovered[team.team_id] = []
    return team

static func _default_full_resources() -> Dictionary:
    return {
        "food": 0.0, "material": 0.0, "coin": 0, "goods": 0,
        "gem": 0, "ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
        "weapon_melee_low": 0, "weapon_melee_high": 0,
        "weapon_ranged_low": 0, "weapon_ranged_high": 0,
        "mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
        "armor_low": 0, "armor_high": 0
    }
```

### 2.6 _setup_player（依 join_mode）

```gdscript
static func _setup_player(state, config, rng) -> void:
    var pcfg: Dictionary = config.get("player", {})
    var join_mode: String = pcfg.get("join_mode", "independent")
    var richness_mult: float = RICHNESS_MULT.get(int(config.get("map", {}).get("resource_richness", 5)), 1.0)
    
    # 1. 建玩家 team
    var team := TeamData.new()
    team.team_id = _next_team_id(state)
    team.population = int(pcfg.get("population", 10))
    team.tags = ["統領"]
    team.resources = _default_full_resources()
    var starting: Dictionary = pcfg.get("starting_resources", {})
    for k in starting:
        team.resources[k] = float(starting[k]) * richness_mult if k == "food" or k == "material" \
                            else int(starting[k] * richness_mult)
    
    # 2. Leader（玩家）
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
    
    # 3. Named members（PersonGenerator）
    var named_count: int = int(pcfg.get("starting_named_count", 3))
    for _i in range(named_count):
        var m := PersonGenerator.generate(state, rng.randi(), "member")
        m.team_id = team.team_id
        state.persons[m.id] = m
        team.named_members.append(m.id)
    
    state.teams[team.team_id] = team
    state.team_known[team.team_id] = []
    state.team_discovered[team.team_id] = []
    state.player_state = { "inventory": [], "coin": float(starting.get("coin", 0)) }
    
    # 4. 位置 + join_mode 處理
    match join_mode:
        "independent":
            team.tile_pos = _random_empty_tile(state, rng)
        
        "new_faction":
            # 找最弱勢力（weights 最小）
            var weakest_fid: int = _find_weakest_faction(state, config)
            if weakest_fid == -1:
                team.tile_pos = _random_empty_tile(state, rng)
                push_warning("No faction to take over, falling back to independent")
                return
            var faction = state.factions[weakest_fid]
            # 找該勢力主據點位置（原 leader_team 位置）
            var old_leader_team: TeamData = state.teams.get(faction.leader_team_id)
            team.tile_pos = old_leader_team.tile_pos if old_leader_team else _random_empty_tile(state, rng)
            # 玩家加入勢力 + 變統領
            team.faction_id = weakest_fid
            faction.leader_team_id = team.team_id
            faction.member_team_ids.append(team.team_id)
            print("[GameSetup] 玩家成為勢力 %d 統領（原 leader_team=%d 保留為下屬）" %
                [weakest_fid, faction.leader_team_id])
        
        _:
            if join_mode.begins_with("join:"):
                var fi: int = int(join_mode.substr(5))
                if state.factions.has(fi):
                    team.faction_id = fi
                    state.factions[fi].member_team_ids.append(team.team_id)
                    var leader_team: TeamData = state.teams.get(state.factions[fi].leader_team_id)
                    team.tile_pos = _random_near([leader_team.tile_pos], rng) if leader_team \
                                    else _random_empty_tile(state, rng)
                else:
                    team.tile_pos = _random_empty_tile(state, rng)
                    push_warning("Faction %d not found, falling back to independent" % fi)
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
            min_w = int(weights[i]); min_idx = i
    # 注意：i 是 weights 索引，不是 faction_id。GameSetup 建勢力順序 = weights 順序
    var sorted_fids: Array = state.factions.keys()
    sorted_fids.sort()
    return sorted_fids[min_idx] if min_idx < sorted_fids.size() else -1
```

### 2.7 內部 helper signatures（實作必須提供）

```gdscript
# Team / Person ID 配發（從 state 找最大 + 1）
static func _next_team_id(state) -> int
static func _next_person_id(state) -> int

# 位置 helpers
static func _random_near(positions: Array, rng) -> Vector2i
# 從 positions 列表中隨機選一個，然後隨機選其 hex 鄰居（距離 ≤ 2），
# 需確認鄰居仍在地圖內

static func _random_empty_tile(state, rng) -> Vector2i
# 隨機選一個地圖內、沒有 team 站著、沒有 outpost 的 tile_pos

# 據點建立
static func _build_outpost_tile(state, pos: Vector2i, type_str: String,
        level: int, owner_team_id: int) -> void
# 直接設定 tile.outpost_type / outpost_level / outpost_owner，
# 跳過 OutpostSystem 的建造流程（GameSetup 是「天降」狀態）
```

---

## 3. PersonGenerator 模組

**檔案：** `scripts/simulation/person_generator.gd`（新建）

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

static func generate(state: WorldState, seed_offset: int, role: String = "member") -> PersonData:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_offset
    
    var p := PersonData.new()
    p.id = _next_id(state)
    p.person_name = _random_name(rng, state)
    p.role = role
    p.age = rng.randi_range(18, 50)
    p.loyalty = 1.0 if role == "leader" else rng.randf_range(0.5, 1.0)
    p.fatigue = 0.0
    
    # Values（直接 iterate 已初始化的 default keys）
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

static func _random_name(rng, state) -> String:
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

**PersonData 現有結構：**

- `values`：8 鍵（野心/求生欲/義氣/貪婪/慎重/好戰/殘忍/信義）
- `attributes`：4 鍵（體力/智力/魅力/毅力）
- `skills`：14 鍵（統領/戰鬥/弓箭/求生/生產/製造/工程/醫療/戰術/計謀/交涉/商業/偵查/潛行）

PersonGenerator 直接 `iterate p.values.keys()` 等 — 不需修改 PersonData。

---

## 4. PlayerCommandSystem 擴充

**檔案：** `scripts/simulation/player_command_system.gd`（擴充）

**Phase 1 需要的 API：**

```gdscript
# ── 查詢 ─────────────────────────
func get_player_team(state) -> TeamData
func get_player_person(state) -> PersonData

# Phase 1 必要：inspect_*（playtest_minimal 需要）
func inspect_team(state, team_id: int) -> Dictionary
func inspect_member(state, person_id: int) -> Dictionary

# ── 行動 ─────────────────────────
# Phase 1 必要：move_to（取代 _do_move_auto 邏輯）
func move_to(state, target_pos: Vector2i) -> Dictionary
func cancel_move(state) -> Dictionary

# 既有不動：execute_action, respond_forced_event, clear_pending_targets
```

### 4.1 move_to / cancel_move

```gdscript
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
    if pt == null: return { "ok": false, "msg": "玩家 team 不存在" }
    pt.move_target = Vector2i(-1, -1)
    return { "ok": true, "msg": "取消移動" }
```

### 4.2 inspect_team / inspect_member

```gdscript
func inspect_team(state: WorldState, team_id: int) -> Dictionary:
    var t: TeamData = state.teams.get(team_id)
    if t == null: return {}
    var leader: PersonData = state.persons.get(t.leader_id)
    var members: Array = []
    for pid in t.named_members:
        var p: PersonData = state.persons.get(pid)
        if p: members.append({
            "id": p.id, "name": p.person_name, "role": p.role,
            "loyalty": p.loyalty, "fatigue": p.fatigue
        })
    return {
        "team_id": t.team_id, "tile_pos": t.tile_pos, "population": t.population,
        "fatigue": t.fatigue, "current_task": t.current_task, "faction_id": t.faction_id,
        "leader": { "id": leader.id, "name": leader.person_name } if leader else {},
        "named_members": members, "resources": t.resources, "tags": t.tags
    }

func inspect_member(state: WorldState, person_id: int) -> Dictionary:
    var p: PersonData = state.persons.get(person_id)
    if p == null: return {}
    return {
        "id": p.id, "name": p.person_name, "role": p.role, "team_id": p.team_id,
        "age": p.age, "loyalty": p.loyalty, "fatigue": p.fatigue,
        "values": p.values, "attributes": p.attributes, "skills": p.skills,
        "equipment": p.equipment if "equipment" in p else {}
    }
```

---

## 5. Text UI Skin 重構

**檔案：** `scripts/ui/text_ui_main.gd`

### 5.1 `_ready()` 改用 GameSetup

```gdscript
func _ready() -> void:
    _state  = WorldState.new()
    _runner = SimRunner.new()
    _bridge = SimBridge.new(_runner, _state)
    _player_cmd = PlayerCommandSystem.new()
    
    var config := GameSetup.load_config("res://config/default.json")
    GameSetup.setup(_state, config)
    
    # _player_tid 從 state.player_id 反查
    _player_tid = _state.persons[_state.player_id].team_id
    var pt: TeamData = _state.teams[_player_tid]
    _cursor = pt.tile_pos
    _refresh()
```

**刪除：** 原 `_ready()` 內的 team / leader 手動建立程式碼（移交 GameSetup）。

### 5.2 KEY_M 改呼叫 PlayerCommandSystem

```gdscript
KEY_M:
    var r: Dictionary = _player_cmd.move_to(_state, _cursor)
    if r.get("ok"):
        _log_event(r.get("msg", ""))
        _bridge.request_advance(99999)   # 由 _process 持續推進
        _input_bar.text = "移動中 [Esc]停止"
    else:
        _log_event(r.get("msg", "移動失敗"))
    _refresh()
```

**刪除：** `_do_move_auto()` 整個函式（移至 PlayerCommandSystem.move_to + SimBridge 推進）。

### 5.3 移動完成自動停止（在 text_ui_main `_process()` 處理）

決策：**不動 SimBridge**，在 `_process()` 內偵測 player_team 是否還在移動。理由：移動完成判斷是 UI/玩家專屬邏輯，不該汙染通用的 SimBridge。

```gdscript
func _process(_delta):
    if not _bridge.is_advancing(): return
    var result := _bridge.tick_step()
    _events.append_array(result.get("events", []))
    if _events.size() > 100: _events = _events.slice(_events.size() - 100)
    
    # 移動完成偵測（move_target = (-1,-1) 表示已到達或被取消）
    var pt: TeamData = _state.teams.get(_player_tid)
    if pt and pt.move_target == Vector2i(-1, -1) and _input_bar.text.begins_with("移動中"):
        _bridge.cancel_advance()
        _input_bar.text = ""
        _log_event("Team%d 到達 (%d,%d)" % [_player_tid, pt.tile_pos.x, pt.tile_pos.y])
    
    if result.get("done", false): _input_bar.text = ""
    _refresh()
    if _state.encounter_active: _bridge.cancel_advance()
```

---

## 6. playtest_minimal.gd

**檔案：** `scripts/debug/playtest_minimal.gd`（新建）

最小驗證腳本，AI session 用來確認 GameSetup + PlayerCommandSystem 正常：

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
    print("玩家 team: id=%d, pos=%s, faction=%d, pop=%d" %
        [pt.team_id, str(pt.tile_pos), pt.faction_id, pt.population])
    
    # 推進 7 天
    bridge.advance_ticks(WorldState.TICKS_PER_DAY * 7)
    print("--- 7 天後 ---")
    print("玩家狀態：%s" % str(cmd.inspect_team(state, pt.team_id)))
    print("已發現 teams：%s" % str(state.team_discovered.get(pt.team_id, [])))
    
    # 測試移動
    var target: Vector2i = pt.tile_pos + Vector2i(1, 0)
    var r := cmd.move_to(state, target)
    print("移動指令：%s" % str(r))
    bridge.advance_ticks(WorldState.TICKS_PER_DAY * 3)
    print("3 天後位置：%s（目標 %s）" % [str(pt.tile_pos), str(target)])
    
    print("=== playtest_minimal 完成 ===")
    quit()
```

**跑法：**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/playtest_minimal.gd
```

---

## 7. 修改檔案清單

| 檔案 | 動作 |
|---|---|
| `config/default.json` | **新建** — 預設 config |
| `scripts/simulation/game_setup.gd` | **新建** — 統一世界初始化 |
| `scripts/simulation/person_generator.gd` | **新建** — 隨機生成 PersonData |
| `scripts/simulation/player_command_system.gd` | **擴充** — 加 move_to / cancel_move / inspect_team / inspect_member / get_player_person |
| `scripts/data/person_data.gd` | **檢查 + 補** — 確認 `VALUE_KEYS` / `ATTR_KEYS` / `SKILL_KEYS` const 存在 |
| `scripts/simulation/world_generator.gd` | **擴充** — `generate()` 支援 `resource_multiplier` 參數 |
| `scripts/ui/text_ui_main.gd` | **重構** — `_ready` 改用 GameSetup；移除 `_do_move_auto`；KEY_M 改呼叫 PlayerCommandSystem；`_process` 偵測移動完成 |
| `scripts/debug/playtest_minimal.gd` | **新建** — AI session 驗證腳本 |

**不動：**
- SimRunner / SimBridge（除非 SimBridge 需要 helper）
- 既有 system 檔（faction_ai / interaction / movement 等）
- `headless_test.gd`（保留現有手動 team 建立，做為對照測試）

---

## 8. 開發順序建議（給實作 session）

1. **PersonData const keys 補齊**（如缺）
2. **PersonGenerator** + 單元驗證（建 10 個人，print 確認屬性合理）
3. **WorldGenerator** 加 resource_multiplier 支援
4. **GameSetup**（核心，較大）
5. **PlayerCommandSystem 擴充**（move_to + inspect_*）
6. **config/default.json**
7. **playtest_minimal.gd** + 跑通驗證
8. **text_ui_main 重構** + 手動啟動 TextUI.tscn 確認 NPC 出現 + 能 M 鍵移動
9. **headless_test 跑通**

---

## 9. 註記事項 / 未來 Work

### 9.1 據點無 resource 儲存（待修）

- 目前 `HexTileData` 沒有 outpost-level 的資源儲存
- 所有資源在 `team.resources` 上
- 影響：team 離開據點 → 帶走全部資源；勢力資源實際上分散在各 team
- **未來應加 `HexTileData.outpost_storage: Dictionary`，影響：**
  - HarvestSystem：收成是否進據點儲存？
  - ManufacturingSystem：生產品是否進據點儲存？
  - FactionAISystem：勢力資源評估邏輯
  - PlayerCommandSystem：玩家操作據點存取
  - UI：據點 inspect 顯示
- **預估工作量大，需獨立 spec**

### 9.2 Player Phase 2/3 待補 API

Phase 2/3 spec 應補：
- `set_task` / `set_salary` / `equip` / `unequip` / `inventory_*` / `set_member_role`
- `play_terminal.gd`（stdin loop + 指令解析）
- `playtest_session.gd`（AI 自動決策）
- 多種 scenario config（war.json / peaceful.json / merchant.json）

### 9.3 PersonGenerator 簡易版

- 目前 Phase 1 用 24 個漢字組合，重複率高
- 未來加更多名字 / 加性別 / 加 race / 加職業傾向（影響 skill 初值）

### 9.4 join_mode = "new_faction" 細節

- 該勢力原 leader_team 仍存在，原 leader_person 仍是該 team leader
- 該勢力其他 teams 全部變玩家下屬
- 開局後該 NPC team 的 AI 行為由現有 FactionAISystem 處理（會服從新統領）
- 未來可加「叛變條件」（原 leader 對玩家 loyalty 低 → 可能脫離勢力）

### 9.5 Player team population 來源

- Phase 1 hardcode 10
- 未來應從 config.player.population 取，並支援 named_members.size() + anonymous

---

## 10. 驗收標準

Phase 1 完成定義：

1. ✅ `scripts/debug/playtest_minimal.gd` 跑無 SCRIPT ERROR，輸出顯示：
   - 世界有 ≥5 teams、≥2 factions
   - 玩家 team 有 leader_name 設定的名字
   - 7 天後玩家狀態完整輸出
   - 移動指令成功設定 move_target
2. ✅ `scripts/debug/headless_test.gd` 仍 `=== DONE ===` 無 ERROR
3. ✅ 開啟 `scenes/TextUI.tscn`：
   - 地圖出現 NPC team 標記（不再是空地圖）
   - M 鍵能成功移動（不再逾時）
   - T 鍵互動選單在玩家移動到 NPC 旁時有目標可選
