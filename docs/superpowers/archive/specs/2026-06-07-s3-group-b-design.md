# S3 Group B — 技能成長整合 + 溢出整合 設計

*Spec written: 2026-06-07*

## Goal

1. 消除 4 個位置的重複技能成長 inline 邏輯，統一走 `SkillSystem.cap_add()`
2. 消除 `event_system.gd` 的 ad-hoc overflow split，統一走 `PopulationSystem.check_overflow_for_team()`

---

## Fix 1 — 技能成長整合

### 現況（4 個位置各自 inline）

| 位置 | 技能 | 模式 |
|---|---|---|
| `skill_system.gd:_grow()` | 戰鬥/弓箭/戰術 | `p.skills[k] = minf(cur + delta, MAX_SKILL)` |
| `interaction_system.gd:_grow_commerce_skill()` | 商業 | `p.skills[k] = minf(cur + growth, 1.0)` |
| `manufacturing_system.gd:_grow_skills()` | 製造 | `p.skills[k] = minf(cur + growth, 1.0)` |
| `vision_system.gd:_grow_skill()` | 偵查/潛行 | `p.skills[k] = minf(cur + growth, 1.0)` |

`skill_system.gd` 已有 `_grow(person, skill, attr)` 私有函式。問題：其他系統各自實作相同邏輯，且用不同上限（有些 1.0，有些 MAX_SKILL）。

### Fix

`skill_system.gd` 新增公開靜態函式：

```gdscript
const MAX_SKILL: float = 1.0   # 已存在，確認統一用這個

static func cap_add(person: PersonData, skill: String, delta: float) -> void:
    if person == null or delta <= 0.0:
        return
    person.skills[skill] = minf(float(person.skills.get(skill, 0.0)) + delta, MAX_SKILL)
```

### 各呼叫點改動

**`interaction_system.gd:_grow_commerce_skill()`：**
```gdscript
# Before:
p.skills["商業"] = minf(float(p.skills.get("商業", 0.0)) + growth, 1.0)

# After:
SkillSystem.cap_add(p, "商業", growth)
```

**`manufacturing_system.gd:_grow_skills()`：**
```gdscript
# Before:
p.skills["製造"] = minf(float(p.skills.get("製造", 0.0)) + growth, 1.0)

# After:
SkillSystem.cap_add(p, "製造", growth)
```

**`vision_system.gd:_grow_skill()`：**
```gdscript
# Before:
p.skills[skill] = minf(float(p.skills.get(skill, 0.0)) + growth, 1.0)

# After:
SkillSystem.cap_add(p, skill, growth)
```

**`skill_system.gd:_grow()`（內部）：**
```gdscript
# Before:
person.skills[skill_key] = minf(current + growth, MAX_SKILL)

# After:
SkillSystem.cap_add(person, skill_key, growth)
```

---

## Fix 2 — 溢出整合

### 現況

**`population_system.gd:check_overflow()`** — 掃所有隊伍，對每隊做：
1. 計算 leader 統領 → 人口上限 cap
2. overflow = population - cap
3. 若有 spare named member → dispatch 子隊
4. 否則 → `_create_overflow_team()`

**`event_system.gd` lines 43-59** — leader 死亡後 ad-hoc：
```gdscript
var overflow: int = team.population - new_cap
if overflow > 0:
    # 手動 dispatch 或 print 逃亡
    SubteamSystem.new().dispatch(state, team.team_id, spare_id, overflow, ...)
```

問題：`event_system` 重複了 `population_system` 的部分邏輯，且沒有走 `_create_overflow_team` 路徑。

### Fix

`population_system.gd` 將 `check_overflow` 的單隊邏輯拆為公開函式：

```gdscript
func check_overflow_for_team(state: WorldState, tid: int) -> void:
    if not state.teams.has(tid):
        return
    var team: TeamData = state.teams[tid]
    var leader = state.persons.get(team.leader_id)
    var cmd: float = float(leader.skills.get("統領", 0.0)) if leader else 0.0
    var cap: int   = TeamData.pop_cap_from_leadership(cmd)
    var overflow: int = team.population - cap
    if overflow <= 0:
        return
    var spare_id: int = -1
    for nid in team.named_members:
        if nid != team.leader_id:
            spare_id = nid
            break
    if spare_id != -1:
        SubteamSystem.new().dispatch(state, tid, spare_id, overflow, "idle", team.tile_pos)
        print("[PopMgmt] Team%d 超額 %d 人，advisor Team%d 帶走" % [tid, overflow, spare_id])
    else:
        _create_overflow_team(state, team, overflow)
```

現有 `check_overflow()` 改為：

```gdscript
func check_overflow(state: WorldState) -> void:
    for tid in state.teams.keys():
        check_overflow_for_team(state, tid)
```

**`event_system.gd`** 的 leader 死亡 overflow 區塊（lines 43-59）改為：

```gdscript
# Before: ad-hoc dispatch
var overflow: int = team.population - new_cap
if overflow > 0:
    ...手動邏輯...

# After: 委託 population_system
PopulationSystem.new().check_overflow_for_team(state, team.team_id)
```

---

## Files to Modify

| File | Change |
|---|---|
| `scripts/simulation/skill_system.gd` | 新增 `static func cap_add()` |
| `scripts/simulation/interaction_system.gd` | `_grow_commerce_skill` 用 `SkillSystem.cap_add()` |
| `scripts/simulation/manufacturing_system.gd` | `_grow_skills` 用 `SkillSystem.cap_add()` |
| `scripts/simulation/vision_system.gd` | `_grow_skill` 用 `SkillSystem.cap_add()` |
| `scripts/simulation/population_system.gd` | 拆出 `check_overflow_for_team()` |
| `scripts/simulation/event_system.gd` | leader 死 overflow 改呼叫 `check_overflow_for_team()` |

---

## Testing

在 `headless_test.gd` 加測試：

```gdscript
# ── skill cap_add test ────────────────────────────────────────────
var _sk_p := PersonData.new()
_sk_p.skills["商業"] = 0.9
SkillSystem.cap_add(_sk_p, "商業", 0.5)
assert(_sk_p.skills["商業"] <= 1.0,
    "[SkillTest] cap_add must not exceed 1.0")
SkillSystem.cap_add(_sk_p, "商業", 0.0)
assert(_sk_p.skills["商業"] <= 1.0,
    "[SkillTest] cap_add delta=0 must be safe")
print("[SkillTest] SkillSystem.cap_add ok")
# ── end skill cap_add test ────────────────────────────────────────
```
