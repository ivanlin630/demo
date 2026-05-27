# 個人 NPC AI Design

## 依賴

本 spec 依賴 `2026-05-27-data-structure-update-design.md`（memory、relations、goals 欄位）。

---

## Goal

實裝 PersonData 的記憶系統（memory[]）、關係追蹤（relations{}）、個人目標（goals[]），使 NPC 行為受過去事件影響，並讓目標干預 leader 決策。

---

## 1. 記憶事件寫入

### 觸發時機

| 事件 | type | subject_id | 受影響對象 | intensity |
|---|---|---|---|---|
| 被當前 team leader 背叛（defect/split_hard） | `"betrayal"` | leader_id | 受害 NPC 個人 | 0.8 |
| 收到禮物/薪水超付 | `"kindness"` | 給予者 person_id | 受益 NPC | 0.4 |
| 加入主人 team（master memory check） | `"master"` | master person_id | 成員 | 1.0 |
| 目睹屠殺/處決俘虜 | `"witnessed_atrocity"` | -1 | 目擊全 named_members | 0.6 |
| team 執行 loot | `"looted"` | leader_id | 受害 team 所有 named_members | 0.7 |
| team 勒索 | `"extorted"` | leader_id | 受害 team 所有 named_members | 0.6 |
| 遭遇戰中被支援 | `"aided_in_battle"` | 支援者 leader_id | 受援全 named_members | 0.5 |

```gdscript
func write_memory(p: PersonData, type: String, subject_id: int,
        tick: int, intensity: float) -> void:
    p.memory.append({
        "type": type,
        "subject_id": subject_id,
        "tick": tick,
        "intensity": intensity,
    })
    _update_relations(p, type, subject_id, intensity)
    _trigger_goals(p, type, subject_id)
```

### 記憶上限與清除

```gdscript
const MEMORY_MAX: int = 20   # TEST VALUE

func _trim_memory(p: PersonData) -> void:
    while p.memory.size() > MEMORY_MAX:
        p.memory.pop_front()   # 移除最舊
```

---

## 2. relations 更新

```gdscript
func _update_relations(p: PersonData, type: String,
        subject_id: int, intensity: float) -> void:
    if subject_id == -1: return
    var delta: float
    match type:
        "betrayal":       delta = -intensity * 0.8
        "kindness":       delta = intensity * 0.4
        "master":         delta = intensity * 0.5
        "witnessed_atrocity": delta = -0.1   # 對 leader 輕微惡化
        "looted":         delta = -intensity * 0.6
        "extorted":       delta = -intensity * 0.5
        "aided_in_battle": delta = intensity * 0.5
        _:                delta = 0.0
    var cur: float = float(p.relations.get(subject_id, 0.0))
    p.relations[subject_id] = clampf(cur + delta, -1.0, 1.0)
```

---

## 3. 個人目標系統

### 出生時目標生成（PersonGenerator 或初始化時呼叫）

```gdscript
func generate_birth_goals(p: PersonData) -> void:
    # 依 values 決定哪些目標 active=true
    if p.values.get("貪婪", 0.5) > 0.6:
        p.goals.append({ "type": "wealth", "target_id": -1, "active": true })
    if p.values.get("求生欲", 0.5) > 0.6:
        p.goals.append({ "type": "escape_war", "target_id": -1, "active": true })
    if p.values.get("野心", 0.5) > 0.65:
        p.goals.append({ "type": "domination", "target_id": -1, "active": true })
    if p.values.get("好戰", 0.5) > 0.55:
        p.goals.append({ "type": "merit", "target_id": -1, "active": true })
    if p.values.get("義氣", 0.5) > 0.65:
        p.goals.append({ "type": "peace", "target_id": -1, "active": true })
```

目標類型說明：

| type | 說明 | 干預強度 |
|---|---|---|
| `wealth` | 追求財富 | ★ |
| `escape_war` | 遠離戰亂 | ★★ |
| `domination` | 掌控/擴張 | ★ |
| `merit` | 立功表現 | ★ |
| `peace` | 和平共存 | ★ |
| `revenge` | 復仇（記憶觸發） | ★★ |
| `gratitude` | 報恩（記憶觸發） | ★ |
| `protect` | 保護某人（記憶觸發） | ★★★ |

### 記憶觸發目標

```gdscript
func _trigger_goals(p: PersonData, type: String, subject_id: int) -> void:
    match type:
        "betrayal", "looted", "extorted":
            _activate_goal(p, "revenge", subject_id)
        "kindness", "aided_in_battle":
            _activate_goal(p, "gratitude", subject_id)
        "master":
            _activate_goal(p, "protect", subject_id)

func _activate_goal(p: PersonData, goal_type: String, target_id: int) -> void:
    # 已有同類型同目標者略過
    for g in p.goals:
        if g["type"] == goal_type and g["target_id"] == target_id:
            g["active"] = true
            return
    p.goals.append({ "type": goal_type, "target_id": target_id, "active": true })
```

---

## 4. 目標衝突判斷（供 team-ai-redesign 呼叫）

### Task → 目標 alignment 對照

```gdscript
func check_goal_alignment(p: PersonData, task: String) -> float:
    # 返回 delta：正=aligned, 負=conflict
    var delta: float = 0.0
    for g in p.goals:
        if not g.get("active", false): continue
        delta += _goal_task_delta(g["type"], task)
    return delta

func _goal_task_delta(goal_type: String, task: String) -> float:
    match goal_type:
        "wealth":
            if task in ["trade", "harvest", "manufacture"]: return 0.005
            if task in ["loot", "raid"]: return 0.003
        "escape_war":
            if task in ["attack", "raid", "loot"]: return -0.015
            if task in ["move", "rest", "trade"]: return 0.005
        "domination":
            if task in ["attack", "raid"]: return 0.005
        "merit":
            if task in ["attack"]: return 0.005
        "peace":
            if task in ["attack", "raid", "loot"]: return -0.01
            if task in ["diplomacy", "trade"]: return 0.005
        "revenge":
            # 目標人物在敵 team：attack=aligned, 其他=輕微 conflict
            if task in ["attack", "raid"]: return 0.005
        "gratitude":
            if task in ["diplomacy", "trade"]: return 0.003
        "protect":
            # 目標人物在同 team：無衝突；在敵 team：attack=aligned
            if task in ["attack"]: return 0.008
    return 0.0
```

---

## 5. 目標干預 Leader 決策

### Leader 目標影響 task 選擇（FactionAI / SoloAI 呼叫前置）

```gdscript
func get_goal_task_override(state: WorldState, p: PersonData,
        current_task: String) -> String:
    # 僅 leader 呼叫；返回 "" 表示不覆蓋
    for g in p.goals:
        if not g.get("active", false): continue
        match g["type"]:
            "protect":
                # 目標在其他 team → 強制移向目標
                var tgt: PersonData = state.persons.get(g["target_id"])
                if tgt != null and tgt.team_id != p.team_id:
                    return "move_to_protect"   # 特殊 task，MovementSystem 處理
            "revenge":
                var tgt: PersonData = state.persons.get(g["target_id"])
                if tgt != null and tgt.team_id != p.team_id:
                    if randf() < p.values.get("好戰", 0.5) * 0.3:
                        return "attack"
            "escape_war":
                if state.teams.get(p.team_id, null) != null:
                    var t: TeamData = state.teams[p.team_id]
                    if float(t.resources.get("food", 0)) < 20:
                        return "move"   # 逃離
    return ""
```

### 同 team 仇人處理

若 named_member 有 `revenge` 目標且目標人在同 team：

```gdscript
func handle_intra_team_vendetta(state: WorldState, p: PersonData,
        team: TeamData, tick: int) -> void:
    for g in p.goals:
        if g["type"] != "revenge" or not g["active"]: continue
        var tgt_id: int = g["target_id"]
        if tgt_id in team.named_members or tgt_id == team.leader_id:
            # 發送訊息通知（MessageSystem）
            # 忠誠度持續下降
            p.loyalty -= 0.002   # TEST VALUE per tick
```

---

## 6. 目標對象消失處理

```gdscript
func cleanup_goals(state: WorldState, p: PersonData) -> void:
    for g in p.goals:
        if g["target_id"] == -1: continue
        if not state.persons.has(g["target_id"]):
            # 目標死亡/消失：依目標類型處理
            match g["type"]:
                "revenge":
                    # 嘗試轉移至同 team/faction 的新目標（仇人的同伴）
                    var new_target: int = _find_revenge_redirect(state, p, g["target_id"])
                    if new_target != -1:
                        g["target_id"] = new_target
                    else:
                        # 無可轉移 → 退化為出生目標（依最高 value 選）
                        g["type"] = _fallback_birth_goal(p)
                        g["target_id"] = -1
                        # g["active"] 維持 true
                "gratitude", "protect":
                    # 退化為出生目標
                    g["type"] = _fallback_birth_goal(p)
                    g["target_id"] = -1

func _fallback_birth_goal(p: PersonData) -> String:
    # 依最高 value 對應出生目標
    var candidates: Array = [
        { "type": "wealth",      "value": p.values.get("貪婪",  0.5) },
        { "type": "escape_war",  "value": p.values.get("求生欲",0.5) },
        { "type": "domination",  "value": p.values.get("野心",  0.5) },
        { "type": "merit",       "value": p.values.get("好戰",  0.5) },
        { "type": "peace",       "value": p.values.get("義氣",  0.5) },
    ]
    candidates.sort_custom(func(a, b): return a["value"] > b["value"])
    return candidates[0]["type"]

func _find_revenge_redirect(state: WorldState, p: PersonData,
        dead_id: int) -> int:
    # 找已死者所在 team 的 leader 作為新仇恨對象
    for tid in state.teams:
        var t: TeamData = state.teams[tid]
        if t.leader_id == dead_id or dead_id in t.named_members:
            if t.leader_id != p.id:
                return t.leader_id
    return -1
```

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `person.memory` 在 loot / aided_in_battle 事件後有對應記錄
- `person.relations[leader_id]` 在背叛後為負值
- 目標 `revenge` 在 looted 後 `active=true`
- `check_goal_alignment` 對 escape_war + attack task 返回負值
