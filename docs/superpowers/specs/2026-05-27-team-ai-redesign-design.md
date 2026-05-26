# Team AI 重構 Design

## 依賴

本 spec 依賴 `2026-05-27-data-structure-update-design.md`（named_members、salary、fatigue 欄位）。

---

## Goal

重構 Team 層 AI：合併 advisors/members 為 named_members、加入薪水系統、更新 split 機制（依統領×魅力帶走人數）、定義 team 轉移時 loyalty 刷新規則、加入疲勞後果。

---

## 1. named_members 重構

### 子隊派遣（SubteamSystem）

原邏輯：取 `team.advisors[0]` 為子隊 leader。

新邏輯：依任務類型從 `named_members` 選最高對應技能者：

| task | 選擇技能 |
|---|---|
| `"attack"` / `"raid"` | `"統領"` |
| `"trade"` | `"商業"` |
| `"diplomacy"` | `"交涉"` |
| `"harvest"` | `"生產"` |
| `"manufacture"` | `"製造"` |
| `"scout"` | `"偵查"` |
| 其他 | `"統領"` |

```gdscript
func _pick_subteam_leader(state: WorldState, team: TeamData, task: String) -> int:
    var skill_map := {
        "attack": "統領", "raid": "統領", "trade": "商業",
        "diplomacy": "交涉", "harvest": "生產", "manufacture": "製造",
        "scout": "偵查"
    }
    var skill: String = skill_map.get(task, "統領")
    var best_id: int = -1
    var best_val: float = -1.0
    for pid in team.named_members:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        var v: float = float(p.skills.get(skill, 0.0))
        if v > best_val:
            best_val = v; best_id = pid
    return best_id
```

### 成員決策影響 leader

每次 team 執行 task 後，比對 named_members 目標（goals）與 task：
- 目標 aligned → `loyalty += GOAL_ALIGN_BONUS`（TEST VALUE: 0.005）
- 目標 conflict → `loyalty -= GOAL_CONFLICT_PENALTY`（TEST VALUE: 0.01）

詳細衝突判斷見 `2026-05-27-npc-ai-design.md`。

### 極端事件不滿

以下 task/事件觸發全 named_members loyalty 懲罰：

| 事件 | 觸發條件 | loyalty delta |
|---|---|---|
| loot | team 執行 loot task | `-(1.0 - p.values["義氣"]) × 0.05` |
| execute_prisoner | 處決俘虜事件 | `-(p.values["義氣"]) × 0.08` |

---

## 2. 薪水系統

### 結算週期

每 `SALARY_INTERVAL` tick 結算一次（TEST VALUE: 30）。

### fair_salary 計算

```gdscript
func _calc_fair_salary(p: PersonData) -> float:
    var total: float = 0.0
    for v in p.skills.values():
        total += float(v)
    return total * SALARY_PER_SKILL_POINT  # TEST VALUE: 2.0
```

### 結算邏輯

```gdscript
func _pay_salary(state: WorldState, team: TeamData) -> void:
    # Named members
    for pid in team.named_members:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        # 主人記憶者免薪
        if _has_master_memory(p, team.leader_id): continue
        var fair: float = _calc_fair_salary(p)
        var ratio: float = p.salary / maxf(fair, 0.01)
        team.resources["coin"] = float(team.resources.get("coin", 0)) - p.salary
        p.coin += p.salary
        if ratio >= 1.0:
            p.loyalty = minf(p.loyalty + (ratio - 1.0) * OVERPAY_BONUS, MAX_LOYALTY)
            # OVERPAY_BONUS TEST VALUE: 0.02  MAX_LOYALTY: 0.95
        else:
            p.loyalty -= (1.0 - ratio) * SALARY_LOYALTY_PENALTY
            # SALARY_LOYALTY_PENALTY TEST VALUE: 0.03
    # 匿名成員
    var anon_count: int = team.population - team.named_members.size() - 1  # -1 for leader
    var anon_total: float = team.anon_wage * maxf(anon_count, 0)
    team.resources["coin"] = float(team.resources.get("coin", 0)) - anon_total
    if float(team.resources.get("coin", 0)) < 0:
        team.unrest_turns += 1

func _has_master_memory(p: PersonData, leader_id: int) -> bool:
    for m in p.memory:
        if m.get("type") == "master" and m.get("subject_id") == leader_id:
            return true
    return false
```

---

## 3. Loyalty on Team Transfer

任何 NPC 換 team 時（招募、雇傭、split、戰敗收編）呼叫：

```gdscript
func reset_loyalty_on_transfer(p: PersonData, transfer_type: String) -> void:
    match transfer_type:
        "split_hard":      p.loyalty = 0.5   # loyalty < 0.35 強制走
        "split_soft":      p.loyalty = 0.65  # 魅力吸引跟隨
        "split_leader":    p.loyalty = 1.0   # 新 team 的 leader
        "conquered":       p.loyalty = 0.25  # 戰敗被強制收編
        "voluntary":       p.loyalty = 0.5   # 外交談判自願加入
        "master":          p.loyalty = 0.9   # 加入主人 team
```

### Split 機制更新（event_unrest_split.gd）

```gdscript
func _split_team(state: WorldState, parent: TeamData, dissenters: Array) -> TeamData:
    var new_team := TeamData.new()
    # ... 基本初始化 ...

    # 選 new leader（dissenters[0]）
    var new_leader: PersonData = dissenters[0]
    new_leader.team_id = new_team.team_id
    new_leader.role = "leader"
    new_team.leader_id = new_leader.id
    reset_loyalty_on_transfer(new_leader, "split_leader")

    # Hard dissenters（loyalty < 0.35，全帶走）
    for i in range(1, dissenters.size()):
        var p: PersonData = dissenters[i]
        p.team_id = new_team.team_id
        new_team.named_members.append(p.id)
        reset_loyalty_on_transfer(p, "split_hard")
        parent.named_members.erase(p.id)
        parent.population -= 1
        new_team.population += 1

    # Soft followers（loyalty 0.35–0.55，依魅力決定）
    var charisma: float = float(new_leader.attributes.get("魅力", 0.5))
    for pid in parent.named_members.duplicate():
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        if p.loyalty >= 0.35 and p.loyalty <= 0.55:
            if randf() < charisma * 0.6:
                p.team_id = new_team.team_id
                new_team.named_members.append(p.id)
                reset_loyalty_on_transfer(p, "split_soft")
                parent.named_members.erase(p.id)
                parent.population -= 1
                new_team.population += 1

    # 匿名跟隨者（依統領×魅力）
    var leadership: float = float(new_leader.skills.get("統領", 0.0))
    var anon_in_parent: int = parent.population - parent.named_members.size() - 1
    var anon_split: int = roundi(leadership * charisma * anon_in_parent * 0.3)  # TEST VALUE
    anon_split = mini(anon_split, parent.population / 3)  # 上限 1/3
    new_team.population += anon_split
    parent.population -= anon_split

    state.teams[new_team.team_id] = new_team
    state.team_known[new_team.team_id] = []
    state.team_discovered[new_team.team_id] = []
    parent.unrest_turns = 0
    return new_team
```

---

## 4. 疲勞系統

### 疲勞累積（SimRunner 每 tick）

```gdscript
# 正常 tick
team.fatigue += FATIGUE_PER_TICK * terrain_mult * time_mult
# FATIGUE_PER_TICK TEST VALUE: 0.002
# terrain_mult: plains=1.0, forest=1.2, mountain=1.4
# time_mult: 白天=1.0, 夜晚=1.5

# 上限
team.fatigue = minf(team.fatigue, 1.0)
```

### 疲勞後果（每 tick 檢查）

```gdscript
if team.fatigue >= 1.0:
    # 移動速度懲罰（MovementSystem 讀取）
    # team_speed_mult = 0.3 when fatigue >= 1.0

    # Loyalty 懲罰
    for pid in team.named_members:
        var p: PersonData = state.persons.get(pid)
        if p: p.loyalty -= FATIGUE_LOYALTY_PENALTY  # TEST VALUE: 0.005/tick
```

遭遇戰體力上限：`stamina_cap = 1.0 - team.fatigue * 0.5`（疲勞=1.0 → cap=0.5）

### 紮營休息（task: "rest"）

```gdscript
# 疲勞回復
var guard_count: int = ceili(team.population * team.guard_ratio)
var rest_mult: float = 1.0 - team.guard_ratio * 0.5
team.fatigue -= FATIGUE_RECOVERY * rest_mult  # TEST VALUE: 0.01/tick
team.fatigue = maxf(team.fatigue, 0.0)

# 視野：只有守夜者貢獻（guard_count 個最高偵查技能的 named_members）
# 0 守夜 = 視野 0 = 夜襲必進追擊戰
```

---

## 5. 負重系統

### 有效馱獸/車輛

```gdscript
func get_effective_mounts(team: TeamData) -> int:
    return mini(int(team.resources.get("mounts", 0)), team.population)

func get_effective_wagons(team: TeamData) -> int:
    return mini(int(team.resources.get("wagons", 0)), team.population)
```

超額馱獸每 N tick 流失：

```gdscript
var unmanaged: int = int(team.resources.get("mounts", 0)) - team.population
if unmanaged > 0:
    team.resources["mounts"] = int(team.resources["mounts"]) - ceili(unmanaged * STRAY_RATE)
    # STRAY_RATE TEST VALUE: 0.1
```

### 攜帶上限與速度懲罰

```gdscript
var capacity: float = team.population * BASE_CARRY \
    + get_effective_mounts(team) * MOUNT_BONUS \
    + get_effective_wagons(team) * WAGON_BONUS
# BASE_CARRY TEST VALUE: 10.0, MOUNT_BONUS: 15.0, WAGON_BONUS: 40.0

var current_weight: float = _calc_total_weight(team)
if current_weight > capacity:
    # MovementSystem 套用速度懲罰
    # speed_mult *= (capacity / current_weight)
```

車輛地形速度修正（在 MovementSystem 套用）：

| terrain | wagon_speed_mult |
|---|---|
| plains | 0.9 |
| forest | 0.4 |
| mountain | 0.2 |

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- 無 SCRIPT ERROR，`=== DONE ===`
- `[Salary]` 結算 print 出現
- Team split 後新 team 的 named_members loyalty 符合 transfer 規則
- Team fatigue 累積並在 rest 後下降
- SubteamSystem 派遣使用 named_members（無 advisors 存取）
