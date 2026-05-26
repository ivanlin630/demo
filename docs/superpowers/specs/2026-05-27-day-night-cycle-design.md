# 日夜循環 Design

## 依賴

本 spec 依賴 `2026-05-27-data-structure-update-design.md`（ticks_per_day、guard_ratio、fatigue）。

---

## Goal

實裝日夜循環：時間段判斷、各系統日夜修正（移動速度/視野/疲勞累積）、紮營守夜機制。

---

## 1. 時間計算

```gdscript
# WorldState（不儲存 time_of_day，由 current_tick 衍生）
var ticks_per_day: int = 24   # TEST VALUE

func get_time_of_day(state: WorldState) -> float:
    return float(state.current_tick % state.ticks_per_day) / \
        float(state.ticks_per_day)
# 0.0 = 午夜起點

func get_time_period(state: WorldState) -> String:
    var t: float = get_time_of_day(state)
    if t < 0.1:   return "dawn"    # 黎明
    if t < 0.75:  return "day"     # 白天
    if t < 0.9:   return "dusk"    # 黃昏
    return "night"                  # 夜晚
```

---

## 2. 移動速度修正

MovementSystem 讀取：

```gdscript
func get_time_speed_mult(state: WorldState) -> float:
    match get_time_period(state):
        "day":   return 1.0
        "dawn":  return 0.8
        "dusk":  return 0.8
        "night": return 0.5
    return 1.0
```

夜間移動懲罰可由高偵查技能部分抵消（VisionSystem 處理，此處不額外計算）。

---

## 3. 疲勞累積（SimRunner 每 tick）

```gdscript
func get_time_fatigue_mult(state: WorldState) -> float:
    match get_time_period(state):
        "day":   return 1.0
        "dawn":  return 1.2
        "dusk":  return 1.2
        "night": return 1.5
    return 1.0

# 套用（team-ai-redesign spec 的 fatigue 累積呼叫此函數）
# team.fatigue += FATIGUE_PER_TICK * terrain_mult * get_time_fatigue_mult(state)
```

---

## 4. 視野修正

VisionSystem / 遭遇戰視野皆讀取此修正：

```gdscript
func get_vision_range_mult(state: WorldState) -> float:
    match get_time_period(state):
        "day":   return 1.0
        "dawn":  return 0.75
        "dusk":  return 0.75
        "night": return 0.5
    return 1.0
```

無守夜者（`guard_ratio == 0`）的 team 在夜間視野額外 × 0.5（等效夜間偵測機率極低）。

---

## 5. 守夜機制

紮營（task: "rest"）時守夜人數由 `team.guard_ratio` 決定：

```gdscript
# guard_count 計算
var guard_count: int = ceili(team.population * team.guard_ratio)

# 守夜者：從 named_members 取最高偵查技能前 guard_count 名
func _get_guards(state: WorldState, team: TeamData) -> Array:
    var scored: Array = []
    for pid in team.named_members:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        scored.append({ "id": pid, "scout": float(p.skills.get("偵查", 0.0)) })
    scored.sort_custom(func(a, b): return a["scout"] > b["scout"])
    var guards: Array = []
    for i in range(mini(guard_count, scored.size())):
        guards.append(scored[i]["id"])
    return guards
```

### 守夜對視野的影響

紮營中視野由守夜者貢獻：

```gdscript
func get_camp_vision_range(state: WorldState, team: TeamData) -> int:
    var guards: Array = _get_guards(state, team)
    if guards.size() == 0: return 0   # 無人守夜 = 視野 0

    var total_scout: float = 0.0
    for pid in guards:
        var p: PersonData = state.persons.get(pid)
        if p: total_scout += float(p.skills.get("偵查", 0.0))
    var avg_scout: float = total_scout / guards.size()

    var base: int = VISION_RADIUS   # 來自 VisionSystem
    return roundi((base + avg_scout * SCOUT_BONUS) * \
        get_vision_range_mult(state))
```

**視野 0 後果：夜間突襲必然觸發追擊戰**（無法偵測到逼近敵人）。

### 守夜對疲勞恢復的影響

```gdscript
# 守夜比例越高 → 全隊休息效率越低
var rest_mult: float = 1.0 - team.guard_ratio * 0.5
team.fatigue -= FATIGUE_RECOVERY * rest_mult
# FATIGUE_RECOVERY TEST VALUE: 0.01/tick
team.fatigue = maxf(team.fatigue, 0.0)
```

---

## 6. 夜間突襲觸發

InteractionSystem 在每 tick 判斷：若 team A 移動至 team B 相鄰，且 team B 正在紮營且視野 = 0：

```gdscript
func _check_night_raid(state: WorldState, attacker: TeamData,
        defender: TeamData) -> bool:
    if defender.current_task != "rest": return false
    if get_camp_vision_range(state, defender) > 0: return false
    # 觸發追擊戰（被追方=defender 放中央）
    return true
```

---

## 7. SimRunner 整合

在 `advance_tick` 開頭取得時間段，作為 context 傳遞給各系統：

```gdscript
func advance_tick(state: WorldState) -> void:
    var time_period: String = get_time_period(state)
    var time_speed_mult: float = get_time_speed_mult(state)
    var time_fatigue_mult: float = get_time_fatigue_mult(state)
    var vision_mult: float = get_vision_range_mult(state)

    # 傳遞給 MovementSystem、FatigueSystem、VisionSystem
    # ...（各系統已定義接收參數）
```

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `get_time_period` 在 tick 0–2 返回 `"dawn"`（ticks_per_day=24，前 2.4 tick）
- 夜間 tick 時 `time_fatigue_mult = 1.5`
- 無守夜 team 在紮營時 `get_camp_vision_range = 0`
- 紮營 team 疲勞在 guard_ratio=0 時恢復最快（rest_mult=1.0），guard_ratio=1.0 時最慢（rest_mult=0.5）
- `[DayNight]` print 出現（每天週期切換時）
