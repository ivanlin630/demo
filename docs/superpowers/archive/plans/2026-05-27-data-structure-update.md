# 資料結構更新 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 為 PersonData / TeamData / WorldState 補齊薪水、記憶、裝備、疲勞等後續系統所需欄位，並將 advisors+members 合併為 named_members。

**Architecture:** 分步遷移：先加新欄位、再更新所有呼叫方、最後移除舊欄位。每步確認 headless test 仍通過。

**Tech Stack:** Godot 4.2.2 GDScript, headless test via `scripts/debug/headless_test.gd`

---

## File Structure

| 動作 | 檔案 |
|---|---|
| Modify | `scripts/data/person_data.gd` |
| Modify | `scripts/data/team_data.gd` |
| Modify | `scripts/data/world_state.gd` |
| Modify | `scripts/debug/headless_test.gd` |
| Modify | `scripts/debug/data_test.gd` |
| Modify | `scripts/simulation/faction_ai_system.gd` |
| Modify | `scripts/simulation/subteam_system.gd` |
| Modify | `scripts/simulation/population_system.gd` |
| Modify | `scripts/simulation/interaction_system.gd` |
| Modify | `scripts/simulation/movement_system.gd` |
| Modify | `scripts/simulation/skill_system.gd` |
| Modify | `scripts/simulation/manufacturing_system.gd` |
| Modify | `scripts/simulation/equipment_system.gd` |
| Modify | `scripts/simulation/event_system.gd` |
| Modify | `scripts/simulation/vision_system.gd` |
| Modify | `scripts/simulation/person_generator.gd` |
| Modify | `scripts/simulation/events/event_unrest_replace.gd` |
| Modify | `scripts/simulation/events/event_unrest_split.gd` |

---

### Task 1: PersonData — 加入 salary / coin / relations

**Files:**
- Modify: `scripts/data/person_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: headless_test.gd 加驗證（測試先行）**

在 `headless_test.gd` 末尾（`=== DONE ===` print 之前）加入：

```gdscript
# === 資料結構驗證 ===
var _dsp: PersonData = state.persons.get(0)
assert(_dsp != null, "Person0 不存在")
assert("salary" in _dsp, "缺少 salary 欄位")
assert("coin" in _dsp, "缺少 coin 欄位")
assert("relations" in _dsp, "缺少 relations 欄位")
assert(_dsp.relations is Dictionary, "relations 應為 Dictionary")
print("[DataStruct] salary/coin/relations 欄位驗證通過")
```

- [ ] **Step 2: 執行測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DataStruct|SCRIPT ERROR|assert"
```

預期：看到 assert 失敗或 `缺少 salary 欄位`

- [ ] **Step 3: person_data.gd 加欄位**

在 `var memory: Array = []` 行之後加入：

```gdscript
var salary: float = 0.0
var coin: float = 0.0
var relations: Dictionary = {}
```

- [ ] **Step 4: 執行測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DataStruct|SCRIPT ERROR|DONE"
```

預期：`[DataStruct] salary/coin/relations 欄位驗證通過`，`=== DONE ===`，無 SCRIPT ERROR

- [ ] **Step 5: Commit**

```powershell
git add scripts/data/person_data.gd scripts/debug/headless_test.gd
git commit -m "feat(data): add salary, coin, relations to PersonData"
```

---

### Task 2: PersonData — 更新 equipment 為 8 格

**Files:**
- Modify: `scripts/data/person_data.gd`
- Modify: `scripts/debug/headless_test.gd`

> **注意**：現有 `equipment: Dictionary = { "weapon": "" }` 需遷移為 8 格格式。現有系統讀取 `equipment["weapon"]` 的地方需改為 `equipment["right_hand"]`。

- [ ] **Step 1: headless_test.gd 加驗證**

```gdscript
var _dep: PersonData = state.persons.get(0)
assert(_dep.equipment.has("right_hand"), "缺少 right_hand 裝備格")
assert(_dep.equipment.has("torso"), "缺少 torso 裝備格")
assert(_dep.equipment["right_hand"] is Dictionary, "right_hand 應為 Dictionary")
print("[DataStruct] equipment 8格驗證通過")
```

- [ ] **Step 2: 執行測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DataStruct|SCRIPT ERROR"
```

- [ ] **Step 3: person_data.gd 更新 equipment**

將：
```gdscript
var equipment: Dictionary = { "weapon": "" }
```
改為：
```gdscript
var equipment: Dictionary = {
	"head":       { "type": "none", "grade": "" },
	"torso":      { "type": "none", "grade": "" },
	"right_arm":  { "type": "none", "grade": "" },
	"left_arm":   { "type": "none", "grade": "" },
	"right_leg":  { "type": "none", "grade": "" },
	"left_leg":   { "type": "none", "grade": "" },
	"right_hand": { "type": "none", "grade": "" },
	"left_hand":  { "type": "none", "grade": "" },
}
```

- [ ] **Step 4: 搜尋並更新 equipment["weapon"] 的讀取**

```powershell
Select-String -Path "scripts/**/*.gd" -Pattern 'equipment\["weapon"\]' -Recurse
```

找到的每處改為 `equipment["right_hand"]`（grade 欄位存武器型別）。

- [ ] **Step 5: 執行測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DataStruct|SCRIPT ERROR|DONE"
```

- [ ] **Step 6: Commit**

```powershell
git add scripts/data/person_data.gd scripts/debug/headless_test.gd
git commit -m "feat(data): update PersonData.equipment to 8-slot dict format"
```

---

### Task 3: PersonData — 更新 goals 格式（String → Dictionary）

**Files:**
- Modify: `scripts/data/person_data.gd`（無需改，goals 已是 Array，格式靠呼叫方）
- Modify: `scripts/debug/headless_test.gd`
- Modify: `scripts/debug/data_test.gd`

> **現況**：headless_test.gd 設定 `person.goals = ["逃離", "求生"]`（字串陣列）。新格式為 `[{"type": String, "target_id": int, "active": bool}]`。

- [ ] **Step 1: headless_test.gd 更新 goals 設定**

找到：
```gdscript
person.goals = ["逃離", "求生"]
```
改為：
```gdscript
person.goals = [
    { "type": "escape_war", "target_id": -1, "active": true },
    { "type": "wealth",     "target_id": -1, "active": true },
]
```

找到：
```gdscript
person.goals = ["擴張", "繁榮"]
```
改為：
```gdscript
person.goals = [
    { "type": "domination", "target_id": -1, "active": true },
    { "type": "wealth",     "target_id": -1, "active": true },
]
```

- [ ] **Step 2: headless_test.gd 加 goals 格式驗證**

```gdscript
var _dgp: PersonData = state.persons.get(0)
assert(_dgp.goals.size() > 0, "goals 不應為空")
assert(_dgp.goals[0] is Dictionary, "goals[0] 應為 Dictionary")
assert(_dgp.goals[0].has("type"), "goals[0] 缺少 type")
assert(_dgp.goals[0].has("active"), "goals[0] 缺少 active")
print("[DataStruct] goals 格式驗證通過")
```

- [ ] **Step 3: data_test.gd 同步更新 goals 設定**

搜尋 data_test.gd 中所有 `goals = [` 的設定，改為 dict 格式（與 Step 1 相同模式）。

- [ ] **Step 4: 執行測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DataStruct|SCRIPT ERROR|DONE"
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/debug/headless_test.gd scripts/debug/data_test.gd
git commit -m "feat(data): migrate goals format to dict array"
```

---

### Task 4: TeamData — 加入 named_members（保留 advisors/members）

**Files:**
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/debug/headless_test.gd`

> 先加 named_members，暫時保留 advisors/members，下一個 Task 再遷移。

- [ ] **Step 1: headless_test.gd 加驗證**

```gdscript
var _dtm: TeamData = state.teams.get(0)
assert("named_members" in _dtm, "缺少 named_members 欄位")
assert(_dtm.named_members is Array, "named_members 應為 Array")
print("[DataStruct] named_members 欄位驗證通過")
```

- [ ] **Step 2: 執行測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DataStruct|SCRIPT ERROR"
```

- [ ] **Step 3: team_data.gd 加欄位**

在 `var members: Array = []` 行之後加入：

```gdscript
var named_members: Array = []   # 合併 advisors+members；遷移完成後移除舊欄位
```

- [ ] **Step 4: 執行測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DataStruct|SCRIPT ERROR|DONE"
```

- [ ] **Step 5: Commit**

```powershell
git add scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(data): add named_members field to TeamData"
```

---

### Task 5: TeamData — 加入其他新欄位

**Files:**
- Modify: `scripts/data/team_data.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: headless_test.gd 加驗證**

```gdscript
var _dte: TeamData = state.teams.get(0)
assert("fatigue" in _dte, "缺少 fatigue")
assert("guard_ratio" in _dte, "缺少 guard_ratio")
assert("anon_wage" in _dte, "缺少 anon_wage")
assert("armor_config" in _dte, "缺少 armor_config")
assert("known_reputations" in _dte, "缺少 known_reputations")
assert("strategic_assignments" in _dte, "缺少 strategic_assignments")
print("[DataStruct] TeamData 新欄位驗證通過")
```

- [ ] **Step 2: 執行測試確認失敗**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DataStruct|SCRIPT ERROR"
```

- [ ] **Step 3: team_data.gd 加欄位**

在 `var armed_anon_ratio: float = 0.0` 行之後加入：

```gdscript
var anon_wage: float = 1.0
var fatigue: float = 0.0
var guard_ratio: float = 0.2
var armor_config: Dictionary = {
	"head":       "none",
	"torso":      "low",
	"right_arm":  "none",
	"left_arm":   "none",
	"right_leg":  "none",
	"left_leg":   "none",
}
var known_reputations: Dictionary = {}
var strategic_assignments: Dictionary = {}
```

- [ ] **Step 4: TeamData — 加入新 resource keys 預設值**

在 `team_data.gd` 的 `resources` Dictionary 加入新 key：

```gdscript
var resources: Dictionary = {
	"food": 0.0, "material": 0, "coin": 0, "goods": 0, "gem": 0,
	"ore_gold": 0, "ore_silver": 0, "ore_iron": 0, "ore_steel": 0,
	"weapon_melee_low": 0, "weapon_melee_high": 0,
	"weapon_ranged_low": 0, "weapon_ranged_high": 0,
	"mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
	"armor_low": 0, "armor_high": 0,
}
```

> **注意**：headless_test.gd 在初始化 team 時明確設定 resources dict，會覆蓋預設值。需在 headless_test.gd 所有 `team.resources = {...}` 處補上新 key（設為 0）。搜尋 headless_test.gd 中所有 `"weapon_ranged_high": 0,` 結尾的 resources dict，每處加上：
> ```gdscript
> "mounts": 0, "wagons": 0, "arrows": 0, "medicine": 0, "tools": 0,
> "armor_low": 0, "armor_high": 0,
> ```

- [ ] **Step 5: headless_test.gd 加 resources 新 key 驗證**

```gdscript
var _dtr: TeamData = state.teams.get(0)
assert(_dtr.resources.has("mounts"), "resources 缺少 mounts")
assert(_dtr.resources.has("arrows"), "resources 缺少 arrows")
assert(_dtr.resources.has("medicine"), "resources 缺少 medicine")
print("[DataStruct] resources 新 key 驗證通過")
```

- [ ] **Step 6: 執行測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DataStruct|SCRIPT ERROR|DONE"
```

- [ ] **Step 7: Commit**

```powershell
git add scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "feat(data): add fatigue, guard_ratio, armor_config, new resource keys to TeamData"
```

---

### Task 6: WorldState — 加入 player_id / player_state / ticks_per_day

**Files:**
- Modify: `scripts/data/world_state.gd`
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: headless_test.gd 加驗證**

```gdscript
assert("player_id" in state, "WorldState 缺少 player_id")
assert(state.player_id == -1, "player_id 預設應為 -1")
assert("ticks_per_day" in state, "WorldState 缺少 ticks_per_day")
assert(state.ticks_per_day == 24, "ticks_per_day 應為 24")
print("[DataStruct] WorldState 新欄位驗證通過")
```

- [ ] **Step 2: world_state.gd 加欄位**

在 `var _next_faction_id: int = 0` 行之後加入：

```gdscript
var player_id: int = -1
var player_state: Dictionary = {}
var ticks_per_day: int = 24
```

- [ ] **Step 3: 執行測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DataStruct|SCRIPT ERROR|DONE"
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/data/world_state.gd scripts/debug/headless_test.gd
git commit -m "feat(data): add player_id, player_state, ticks_per_day to WorldState"
```

---

### Task 7: 遷移所有 advisors+members → named_members（第一批）

**Files:**
- Modify: `scripts/simulation/vision_system.gd`
- Modify: `scripts/simulation/skill_system.gd`
- Modify: `scripts/simulation/manufacturing_system.gd`
- Modify: `scripts/simulation/movement_system.gd`
- Modify: `scripts/simulation/person_generator.gd`
- Modify: `scripts/simulation/equipment_system.gd`

遷移模式：
```gdscript
# 舊
([team.leader_id] as Array) + team.advisors + team.members
# 新
([team.leader_id] as Array) + team.named_members
```

```gdscript
# 舊
team.advisors + team.members
# 新
team.named_members
```

```gdscript
# 舊
1 + team.advisors.size() + team.members.size()
# 新
1 + team.named_members.size()
```

- [ ] **Step 1: vision_system.gd — 更新 _avg_skill 與 _grow_skill**

`scripts/simulation/vision_system.gd` 第 56 行（`for pid in ([team.leader_id] as Array) + team.advisors + team.members:`）改為：
```gdscript
for pid in ([team.leader_id] as Array) + team.named_members:
```
第 63 行同樣更新。

- [ ] **Step 2: skill_system.gd — 更新兩處**

`scripts/simulation/skill_system.gd` 第 32、42 行 `team.advisors + team.members` 各改為 `team.named_members`，並在前面補 `([team.leader_id] as Array) +` 若原本有的話。

- [ ] **Step 3: manufacturing_system.gd — 更新兩處**

第 101、109 行 `([team.leader_id] as Array) + team.advisors + team.members` 改為 `([team.leader_id] as Array) + team.named_members`

- [ ] **Step 4: movement_system.gd — 更新 named_ids**

第 56 行 `var named_ids: Array = team.advisors + team.members` 改為：
```gdscript
var named_ids: Array = team.named_members
```

- [ ] **Step 5: person_generator.gd — 更新 named_count**

第 23–24 行改為：
```gdscript
var named_count: int = (1 if team.leader_id != -1 else 0) \
    + team.named_members.size()
```

- [ ] **Step 6: equipment_system.gd — 更新 _get_named_ids**

第 108 行 `var ids: Array = team.advisors + team.members` 改為：
```gdscript
var ids: Array = team.named_members
```

- [ ] **Step 7: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "SCRIPT ERROR|DONE"
```

預期：無 SCRIPT ERROR，`=== DONE ===`

- [ ] **Step 8: Commit**

```powershell
git add scripts/simulation/vision_system.gd scripts/simulation/skill_system.gd scripts/simulation/manufacturing_system.gd scripts/simulation/movement_system.gd scripts/simulation/person_generator.gd scripts/simulation/equipment_system.gd
git commit -m "refactor(data): migrate advisors+members to named_members (batch 1: sim systems)"
```

---

### Task 8: 遷移 advisors+members → named_members（第二批）

**Files:**
- Modify: `scripts/simulation/interaction_system.gd`
- Modify: `scripts/simulation/event_system.gd`
- Modify: `scripts/simulation/population_system.gd`
- Modify: `scripts/simulation/events/event_unrest_replace.gd`
- Modify: `scripts/simulation/events/event_unrest_split.gd`

- [ ] **Step 1: interaction_system.gd — 更新所有 advisors/members 參照**

以下每處皆更新（共 ~10 處）：

```gdscript
# 第 120 行
var named_ids: Array = team.named_members
# 第 193–194 行（all_npcs 組建）
all_npcs.append_array(abs_team.named_members)
# 第 475 行
var named_ids: Array = ([team.leader_id] as Array) + team.named_members
# 第 504 行（同上）
# 第 522 行
var named_ids: Array = team.named_members
# 第 571 行
var named_ids: Array = team.named_members
# 第 606–607 行（死亡時移除）
team.named_members.erase(p.id)
# 第 674–675 行（all_npcs 組建）
all_npcs.append_array(absorbed_team.named_members)
# 第 728 行
var named_ids: Array = team.named_members
# 第 804 行
for pid in ([team.leader_id] as Array) + team.named_members:
# 第 865 行
for pid in ([team.leader_id] as Array) + team.named_members:
# 第 869 行
var named_count: int = 1 + team.named_members.size()
```

- [ ] **Step 2: event_system.gd — 更新 spare_id 搜尋**

第 48–54 行（從 advisors+members 找備用 leader）改為：
```gdscript
for mid in team.named_members:
    if mid != team.leader_id:
        spare_id = mid
        break
```

- [ ] **Step 3: population_system.gd — 更新 spare_id 搜尋**

第 17–22 行改為：
```gdscript
for mid in team.named_members:
    if mid != team.leader_id:
        spare_id = mid
        break
```

- [ ] **Step 4: event_unrest_replace.gd — 更新 advisor 角色**

第 43–44 行（舊 leader 變 advisor）改為：
```gdscript
old_leader.role = "member"
if not team.named_members.has(old_leader.id):
    team.named_members.append(old_leader.id)
```

- [ ] **Step 5: event_unrest_split.gd — 更新 new_team.members**

第 80 行 `new_team.members.append(p.id)` 改為：
```gdscript
new_team.named_members.append(p.id)
```

- [ ] **Step 6: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "SCRIPT ERROR|DONE"
```

- [ ] **Step 7: Commit**

```powershell
git add scripts/simulation/interaction_system.gd scripts/simulation/event_system.gd scripts/simulation/population_system.gd scripts/simulation/events/event_unrest_replace.gd scripts/simulation/events/event_unrest_split.gd
git commit -m "refactor(data): migrate advisors+members to named_members (batch 2: events)"
```

---

### Task 9: 遷移 faction_ai_system.gd 與 subteam_system.gd

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/simulation/subteam_system.gd`

- [ ] **Step 1: faction_ai_system.gd — 更新 advisors 參照（4 處）**

第 177 行：`leader_team.advisors.size() > 0` → `leader_team.named_members.size() > 0`
第 178 行：`leader_team.advisors[0]` → `leader_team.named_members[0]`
第 318 行：`for aid in sub.advisors:` → `for aid in sub.named_members:`
第 527 行：`([team.leader_id] as Array) + team.advisors + team.members` → `([team.leader_id] as Array) + team.named_members`
第 531 行：`1 + team.advisors.size() + team.members.size()` → `1 + team.named_members.size()`

- [ ] **Step 2: subteam_system.gd — 更新所有 advisors/members 參照**

```gdscript
# 第 13 行：dispatch 驗證
if not parent.named_members.has(sub_leader_id):
# 第 44–45 行：派出時從 named_members 移除
parent.named_members.erase(sub_leader_id)
# 第 50 行：extra advisors 驗證
if not parent.named_members.has(aid):
# 第 55–58 行：移除並加入子團
parent.named_members.erase(aid)
sub.named_members.append(aid)
# 第 64–65 行：print
print("[Sub] Team%d 派出子隊 Team%d leader=P%d named_members=%s (pop=%d cap=%d task=%s)" % [
    parent_id, sub.team_id, sub_leader_id, str(sub.named_members), pop_count, sub_cap, task])
# 第 97–98 行：named_in_absorbed
var named_in_absorbed: int = (1 if absorbed.leader_id != -1 else 0) \
    + absorbed.named_members.size()
# 第 123–129 行：merge_teams
if not absorber.named_members.has(pid):
    absorber.named_members.append(pid)
# 第 126–129 行：舊 advisors/members erase
absorbed.named_members.erase(pid)
# 第 178–188 行：歸還子團 named_members
if not absorber.named_members.has(absorbed.leader_id):
    absorber.named_members.append(absorbed.leader_id)
for aid in absorbed.named_members:
    ...
    if not absorber.named_members.has(aid):
        absorber.named_members.append(aid)
absorbed.named_members.clear()
```

- [ ] **Step 3: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "SCRIPT ERROR|DONE|Sub"
```

預期：`=== 子隊派遣：scout_id=7 ===`（或其他 id），無 SCRIPT ERROR

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/simulation/subteam_system.gd
git commit -m "refactor(data): migrate advisors+members to named_members (batch 3: faction_ai, subteam)"
```

---

### Task 10: headless_test.gd — 遷移測試初始化

**Files:**
- Modify: `scripts/debug/headless_test.gd`

- [ ] **Step 1: 更新 team 初始化（members → named_members）**

找到以下模式並更新：

```gdscript
# 舊（第 76 行）
team.members.append(person.id)
# 新
team.named_members.append(person.id)
```

```gdscript
# 舊（第 137–141 行）
state.teams[0].advisors.append(1)
state.teams[0].members.erase(1)
state.teams[0].advisors.append(2)
state.teams[0].members.erase(2)
# 新（advisors 概念消失，直接操作 named_members）
# Person1, Person2 已在 named_members，無需再 erase/append
# 確保他們在 named_members 中即可（初始化時已 append）
```

```gdscript
# 舊（第 296 行）
state.persons[42] = mb_m; mb.members.append(42)
# 新
state.persons[42] = mb_m; mb.named_members.append(42)
```

```gdscript
# 舊（第 307–311 行）
if ma.advisors.has(41):
    print("  [OK] MB_leader(41) 成為 Team11 advisor")
else:
    print("  [FAIL] MB_leader(41) 未進入 advisors")
if ma.members.has(42):
# 新
if ma.named_members.has(41):
    print("  [OK] MB_leader(41) 成為 Team11 named_member")
else:
    print("  [FAIL] MB_leader(41) 未進入 named_members")
if ma.named_members.has(42):
```

```gdscript
# 舊（第 361 行）
state.persons[51] = ov1_adv; ov1.advisors.append(51)
# 新
state.persons[51] = ov1_adv; ov1.named_members.append(51)
```

```gdscript
# 舊（第 815 行）
for pid in ([t.leader_id] as Array) + t.advisors + t.members:
# 新
for pid in ([t.leader_id] as Array) + t.named_members:
```

- [ ] **Step 2: data_test.gd 同步更新**

搜尋 `data_test.gd` 中 `team.members.append`，改為 `team.named_members.append`

- [ ] **Step 3: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "SCRIPT ERROR|DONE|FAIL"
```

預期：`=== DONE ===`，無 SCRIPT ERROR，無 `[FAIL]`

- [ ] **Step 4: Commit**

```powershell
git add scripts/debug/headless_test.gd scripts/debug/data_test.gd
git commit -m "refactor(test): migrate headless_test to use named_members"
```

---

### Task 11: 移除 advisors / members 欄位

**Files:**
- Modify: `scripts/data/team_data.gd`

> 只在確認所有前述 task 測試通過後執行此 task。

- [ ] **Step 1: 搜尋確認無殘留參照**

```powershell
Select-String -Path "scripts/**/*.gd" -Pattern '\.advisors|\.members' -Recurse | Where-Object { $_.Line -notmatch '# ' }
```

預期：只剩 `team_data.gd` 本身的宣告

- [ ] **Step 2: team_data.gd 移除舊欄位**

移除：
```gdscript
var advisors: Array = []
var members: Array = []
```

移除 `named_members` 的 migration 注解：
```gdscript
# 合併 advisors+members；遷移完成後移除舊欄位
```
改為空注解或移除。

- [ ] **Step 3: 執行測試確認通過**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "SCRIPT ERROR|DONE"
```

預期：`=== DONE ===`，無 SCRIPT ERROR

- [ ] **Step 4: headless_test.gd 加最終驗證 print**

在驗證段加：
```gdscript
print("[DataStruct] named_members 非空: Team0=%d" % state.teams[0].named_members.size())
print("[DataStruct] person.salary 型別: %s" % typeof(state.persons[0].salary))
print("[DataStruct] state.ticks_per_day=%d" % state.ticks_per_day)
```

- [ ] **Step 5: 執行完整測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "DataStruct|SCRIPT ERROR|DONE"
```

- [ ] **Step 6: Commit**

```powershell
git add scripts/data/team_data.gd scripts/debug/headless_test.gd
git commit -m "refactor(data): remove deprecated advisors/members fields from TeamData"
```
