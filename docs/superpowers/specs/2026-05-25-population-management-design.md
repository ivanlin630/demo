# Population Management Design

## Goal

實作兩個互補機制：
1. **超額強制分裂**：team population 超出 pop_cap_from_leadership 時自動切出溢出人口
2. **小隊合併整合**：FactionAI 主動整合過小的 team，或在戰前集結附近兵力

---

## 架構決定

| 機制 | 位置 | 理由 |
|---|---|---|
| 超額強制分裂 | 新 `PopulationSystem` + SimRunner 步驟 | 純機械判斷，不需策略上下文 |
| 小隊合併整合 | FactionAI `_assign_tasks` | 需感知 goals（攻擊/idle）|

---

## 修改檔案

| 檔案 | 動作 |
|---|---|
| `scripts/simulation/population_system.gd` | 新建 |
| `scripts/simulation/sim_runner.gd` | 加 `_step1d_population_overflow`，每 `OVERFLOW_CHECK_INTERVAL` tick 呼叫 |
| `scripts/simulation/faction_ai_system.gd` | `_assign_tasks` 加閾值合併 + 戰前集結邏輯 |
| `scripts/debug/headless_test.gd` | 加溢出分裂 + 小隊合併驗證場景 |
| `docs/progress.md` | 加入完成項目 |

---

## Part 1：PopulationSystem（超額強制分裂）

### 觸發時機

SimRunner 每 `OVERFLOW_CHECK_INTERVAL`（TEST VALUE = 10）tick 呼叫一次，掃所有 active teams。主要為安全網（補漏網之魚：leader 換人後溢出、未來自然人口增長）。注意 `on_leader_death` 已有即時 overflow dispatch，此處為週期性補掃。

### 分裂邏輯

```
for each team in state.teams:
  leader = state.persons.get(team.leader_id)
  cmd = leader.skills["統領"] if leader else 0.0
  cap = TeamData.pop_cap_from_leadership(cmd)
  overflow = team.population - cap
  if overflow <= 0: continue

  if team has usable advisor (not leader_id):
    # 有 advisor → dispatch 子隊
    advisor_id = first available advisor
    SubteamSystem.dispatch(state, team.team_id, advisor_id,
      overflow, "idle", team.tile_pos)
  else:
    # 無 advisor → 獨立溢出 team（流亡）
    _create_overflow_team(state, team, overflow)
```

### `_create_overflow_team(state, origin, overflow_pop)`

```gdscript
var ot := TeamData.new()
ot.team_id   = _next_team_id(state)
ot.tile_pos  = origin.tile_pos
ot.faction_id = -1
ot.tags      = ["流亡"]
ot.population = overflow_pop
ot.current_task = "idle"

# 資源比例轉移
var frac = float(overflow_pop) / float(origin.population)
for res in origin.resources:
  var amt = float(origin.resources[res]) * frac
  ot.resources[res]     = amt
  origin.resources[res] = float(origin.resources.get(res, 0)) - amt

origin.population -= overflow_pop
state.teams[ot.team_id]          = ot
state.team_known[ot.team_id]     = []
state.team_discovered[ot.team_id] = []

# PersonGenerator 晉升匿民為 leader
var gen := PersonGenerator.new()
var promoted := gen.generate(ot, state)
if promoted != null:
  ot.leader_id  = promoted.id
  promoted.role = "leader"
```

### 常數

```gdscript
const OVERFLOW_CHECK_INTERVAL: int = 10  # TEST VALUE
```

---

## Part 2：FactionAI 小隊合併整合

加在 `_assign_tasks` 開頭（before 徵收/攻擊等 goal 處理）。

### 常數

```gdscript
const SMALL_TEAM_RATIO: float  = 0.3   # TEST VALUE — pop < cap × 0.3 視為小隊
const SMALL_VS_LARGE: float    = 0.33  # TEST VALUE — pop < target.pop × 1/3 才合併
const CONSOLIDATE_MAX_DIST: int = 3    # TEST VALUE — 戰前集結距離上限（hex）
```

### A. 閾值合併（任何時候）

```
for each faction member team mt (not leader_team, not in combat):
  mt_cap = pop_cap_from_leadership(mt.leader)
  if mt.pop >= mt_cap × SMALL_TEAM_RATIO: continue
  
  best = _find_absorber(state, mt)  # 同 faction，有容量，dist ≤ CONSOLIDATE_MAX_DIST，dist > 1
  if best == null: continue
  if mt.pop >= state.teams[best].pop × SMALL_VS_LARGE: continue  # C 條件
  
  mt.current_task    = TeamData.TASK_MERGE
  mt.order_target_id = best
  mt.move_target     = state.teams[best].tile_pos
```

dist > 1 排除：距離 0–1 的 team 碰面時已由 interaction_system idle auto-merge 自動處理。

跳過條件：mt.current_task 已為 TASK_MERGE → 不重複指派。

### `_find_absorber(state, mt) -> int`

```gdscript
func _find_absorber(state: WorldState, mt: TeamData) -> int:
  var best_id: int = -1
  var best_d: int  = 999
  for tid in state.factions[mt.faction_id ?? -1].member_team_ids ?? []:
    if tid == mt.team_id: continue
    var t: TeamData = state.teams.get(tid)
    if t == null or t.combat_target != -1: continue
    var absorber_leader = state.persons.get(t.leader_id)
    var cmd = float(absorber_leader.skills.get("統領", 0.0)) if absorber_leader else 0.0
    var cap = TeamData.pop_cap_from_leadership(cmd) - t.population
    if cap <= 0: continue
    var d: int = _hex_dist(mt.tile_pos, t.tile_pos)
    if d <= 1 or d > CONSOLIDATE_MAX_DIST: continue
    if d < best_d: best_d = d; best_id = tid
  return best_id
```

### B. 戰前集結（"攻擊" in goals）

```
if "攻擊" not in f.goals: skip

enemy_id = _nearest_independent(state, leader_team)
if enemy_id == -1: skip

for each faction member mt (not leader_team, not in combat, task==idle):
  dist_to_leader = hex_dist(mt.tile_pos, leader_team.tile_pos)
  
  if dist_to_leader <= CONSOLIDATE_MAX_DIST:
    leader_cap = pop_cap_from_leadership(leader) - leader_team.pop
    if leader_cap > 0:
      mt.current_task    = TeamData.TASK_MERGE
      mt.order_target_id = f.leader_team_id
      mt.move_target     = leader_team.tile_pos
    else:
      # leader_team 已滿 → 信使通知協同
      _dispatch_coordinate_herald(state, f.leader_team_id, mt.team_id, enemy_id)
  else:
    # 太遠合不到 → 信使通知協同
    _dispatch_coordinate_herald(state, f.leader_team_id, mt.team_id, enemy_id)
```

### `_dispatch_coordinate_herald`

從 leader_team dispatch 信使子隊前往 target_team，送達後 target_team 收到 TASK_ATTACK + enemy 位置。

```gdscript
func _dispatch_coordinate_herald(state, from_id, target_id, enemy_id) -> void:
  var from: TeamData = state.teams[from_id]
  if from.advisors.is_empty(): return
  var herald_leader: int = from.advisors[0]
  var target_pos: Vector2i = state.teams[target_id].tile_pos
  SubteamSystem.new().dispatch(state, from_id, herald_leader,
    1, TeamData.TASK_HERALD, target_pos,
    target_id, TeamData.TASK_ATTACK)
```

依賴 `_deliver_order`（interaction_system.gd）在信使抵達時，將 `order_task`（TASK_ATTACK）和 `order_target_id`（enemy_id）寫入目標 team。實作前需確認 `_deliver_order` 已正確設定 `target.current_task = herald.order_task` 且 `target.move_target = state.teams[herald.order_target_id].tile_pos`；若未實作則需補上。

另注意：戰前集結跳過條件 — mt.current_task 已為 TASK_MERGE 或 TASK_ATTACK → 不重複指派。

---

## 驗證

### 溢出分裂驗證
- 建 Team A（pop=10，leader 統領=0.3 → cap≈19，不會溢出... 改用統領=0.0 → cap=1，pop=5 → overflow=4）
- 有 advisor → 驗證 dispatch 子隊 pop=4
- 無 advisor → 驗證 create 流亡 team，PersonGenerator 晉升

### 小隊合併驗證
- 建 faction（leader Team L pop=20，成員 Team S pop=2）
- Team S pop < cap×0.3 → 閾值合併觸發 → Team S 收到 TASK_MERGE
- 戰前集結：goals 加 "攻擊"，Team S 在 dist 2 → Task MERGE；Team S 在 dist 5 → 信使派出

---

## 測試值（平衡期調整）

| 常數 | 值 | 備註 |
|---|---|---|
| `OVERFLOW_CHECK_INTERVAL` | 10 | TEST VALUE |
| `SMALL_TEAM_RATIO` | 0.3 | TEST VALUE |
| `SMALL_VS_LARGE` | 0.33 | TEST VALUE |
| `CONSOLIDATE_MAX_DIST` | 3 | TEST VALUE |
