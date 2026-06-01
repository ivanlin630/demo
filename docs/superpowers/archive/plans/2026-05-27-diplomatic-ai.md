# 外交 AI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 實裝 NPC 外交決策：5 輸入評分、主動/被動外交動作、known_reputations 更新、結盟、背叛。

**Architecture:** 新建 `DiplomaticAiSystem`；`FactionAiSystem._update_faction` 每 tick 呼叫主動外交評估；被動外交由 MessageSystem 傳入訊息時呼叫。

**Tech Stack:** Godot 4.2.2 GDScript

**依賴：** `2026-05-27-data-structure-update.md`（known_reputations、relations）；`2026-05-27-npc-ai.md`（memory 寫入）。

---

## File Structure

| 動作 | 檔案 |
|---|---|
| Create | `scripts/simulation/diplomatic_ai_system.gd` |
| Modify | `scripts/simulation/faction_ai_system.gd` |
| Modify | `scripts/simulation/sim_runner.gd` |
| Modify | `scripts/debug/headless_test.gd` |

---

### Task 1: DiplomaticAiSystem — 評分函數與主動外交

**Files:**
- Create: `scripts/simulation/diplomatic_ai_system.gd`

- [ ] **Step 1: 建立 diplomatic_ai_system.gd**

```gdscript
# scripts/simulation/diplomatic_ai_system.gd
class_name DiplomaticAiSystem

const BETRAY_CHECK_INTERVAL: int = 50   # TEST VALUE

func _calc_diplomacy_score(state: WorldState,
        self_team: TeamData, other_team: TeamData) -> float:
    var self_leader: PersonData = state.persons.get(self_team.leader_id)
    if self_leader == null: return 0.0

    var food_ratio: float = float(self_team.resources.get("food", 0)) / \
        maxf(self_team.population * 5.0, 1.0)
    var resource_need: float = clampf(1.0 - food_ratio, 0.0, 1.0)

    var power_gap: float = clampf(
        float(other_team.population - self_team.population) / \
        maxf(self_team.population, 1.0), -1.0, 1.0)

    var rep: float = float(self_team.known_reputations.get(other_team.team_id, 0.5))

    var other_leader_id: int = other_team.leader_id
    var relation: float = float(self_leader.relations.get(other_leader_id, 0.0))

    var self_peace: float = self_leader.values.get("義氣", 0.5) * \
        self_leader.values.get("信義", 0.5)

    return clampf(
        resource_need * 0.3 +
        power_gap     * 0.2 +
        rep           * 0.2 +
        relation      * 0.15 +
        self_peace    * 0.15,
        0.0, 1.0)

func try_proactive_diplomacy(state: WorldState, self_team: TeamData) -> void:
    var self_leader: PersonData = state.persons.get(self_team.leader_id)
    if self_leader == null: return
    if randf() > self_leader.values.get("慎重", 0.5) * 0.5 + 0.2: return

    for other_id in state.team_discovered.get(self_team.team_id, []):
        var other: TeamData = state.teams.get(other_id)
        if other == null: continue
        if other.faction_id == self_team.faction_id and self_team.faction_id != -1: continue
        var score: float = _calc_diplomacy_score(state, self_team, other)

        if score > 0.6 and self_team.faction_id != -1:
            _send_diplomacy_message(state, self_team, other, "propose_alliance")
            return
        elif score > 0.4:
            _send_diplomacy_message(state, self_team, other, "propose_trade")
            return

        var power_gap: float = float(other.population - self_team.population) / \
            maxf(self_team.population, 1.0)
        if power_gap > 0.5 and self_leader.values.get("貪婪", 0.5) > 0.6:
            _send_diplomacy_message(state, self_team, other, "demand_tribute")
            return

func _send_diplomacy_message(state: WorldState, sender: TeamData,
        target: TeamData, action: String) -> void:
    print("[Diplomacy] Team%d → Team%d: %s" % [sender.team_id, target.team_id, action])
    # 透過 MessageSystem 發送（簡化：直接呼叫 handle）
    var response: String = handle_diplomacy_message(state, target, sender, action)
    print("[Diplomacy] Team%d 回應: %s" % [target.team_id, response])
```

- [ ] **Step 2: headless_test.gd 加驗證**

```gdscript
var _dip := DiplomaticAiSystem.new()
var _ds: float = _dip._calc_diplomacy_score(state, state.teams[0], state.teams[3])
print("[Diplomacy] Team0→Team3 score=%.3f" % _ds)
assert(_ds >= 0.0 and _ds <= 1.0, "diplomacy score 應在 0.0–1.0")
```

- [ ] **Step 3: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "Diplomacy|SCRIPT ERROR|DONE"
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/diplomatic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(diplomatic-ai): add DiplomaticAiSystem with 5-input score and proactive logic"
```

---

### Task 2: handle_diplomacy_message — 被動外交

**Files:**
- Modify: `scripts/simulation/diplomatic_ai_system.gd`

- [ ] **Step 1: 加入 handle_diplomacy_message、_form_alliance、_absorb_team、_update_reputation**

```gdscript
func handle_diplomacy_message(state: WorldState, self_team: TeamData,
        sender_team: TeamData, action: String) -> String:
    var score: float = _calc_diplomacy_score(state, self_team, sender_team)
    match action:
        "propose_alliance":
            if score > 0.55:
                _form_alliance(state, self_team, sender_team)
                return "accept"
            return "reject"
        "propose_trade":
            if score > 0.4:
                _update_reputation(self_team, sender_team.team_id, 0.05)
                _update_reputation(sender_team, self_team.team_id, 0.05)
                return "accept"
            return "reject"
        "demand_tribute":
            var self_leader: PersonData = state.persons.get(self_team.leader_id)
            var resist: float = 1.0 - score
            if self_leader != null:
                resist += self_leader.values.get("好戰", 0.5) * 0.3
            if resist > 0.5:
                return "reject"
            var tribute: float = float(self_team.resources.get("coin", 0)) * 0.1
            self_team.resources["coin"] = float(self_team.resources.get("coin", 0)) - tribute
            sender_team.resources["coin"] = float(sender_team.resources.get("coin", 0)) + tribute
            return "accept"
        "offer_surrender":
            if score > 0.3:
                return "accept"
            return "reject"
    return "reject"

func _form_alliance(state: WorldState,
        team_a: TeamData, team_b: TeamData) -> void:
    if team_a.faction_id != -1:
        team_b.faction_id = team_a.faction_id
        var f: FactionData = state.factions.get(team_a.faction_id)
        if f and not f.member_team_ids.has(team_b.team_id):
            f.member_team_ids.append(team_b.team_id)
    elif team_b.faction_id != -1:
        team_a.faction_id = team_b.faction_id
        var f: FactionData = state.factions.get(team_b.faction_id)
        if f and not f.member_team_ids.has(team_a.team_id):
            f.member_team_ids.append(team_a.team_id)
    _update_reputation(team_a, team_b.team_id, 0.2)
    _update_reputation(team_b, team_a.team_id, 0.2)
    print("[Diplomacy] Team%d 與 Team%d 結盟" % [team_a.team_id, team_b.team_id])

func _update_reputation(team: TeamData, other_id: int, delta: float) -> void:
    var cur: float = float(team.known_reputations.get(other_id, 0.5))
    team.known_reputations[other_id] = clampf(cur + delta, 0.0, 1.0)
```

- [ ] **Step 2: headless_test.gd 加驗證**

```gdscript
var _dip2 := DiplomaticAiSystem.new()
# Team6（商隊）主動提外交
_dip2.try_proactive_diplomacy(state, state.teams[6])
# 攻擊後信譽下降
_dip2._update_reputation(state.teams[0], 3, -0.3)
var _rep: float = float(state.teams[0].known_reputations.get(3, 0.5))
assert(_rep < 0.5, "攻擊後 known_reputations 應下降")
print("[Diplomacy] known_reputations 更新驗證通過")
```

- [ ] **Step 3: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "Diplomacy|SCRIPT ERROR|DONE"
```

- [ ] **Step 4: Commit**

```powershell
git add scripts/simulation/diplomatic_ai_system.gd scripts/debug/headless_test.gd
git commit -m "feat(diplomatic-ai): add passive diplomacy, alliance, tribute, reputation update"
```

---

### Task 3: 背叛邏輯

**Files:**
- Modify: `scripts/simulation/diplomatic_ai_system.gd`

- [ ] **Step 1: 加入 consider_betrayal 與 _execute_betrayal**

```gdscript
func consider_betrayal(state: WorldState, self_team: TeamData,
        ally_team: TeamData) -> bool:
    var self_leader: PersonData = state.persons.get(self_team.leader_id)
    if self_leader == null: return false
    var betrayal_score: float = \
        self_leader.values.get("野心", 0.5) * 0.4 + \
        (1.0 - self_leader.values.get("信義", 0.5)) * 0.4 + \
        (1.0 - self_leader.values.get("義氣", 0.5)) * 0.2
    var power_gap: float = float(ally_team.population - self_team.population) / \
        maxf(self_team.population, 1.0)
    if power_gap > 0.5: betrayal_score -= 0.3
    if betrayal_score > 0.65 and randf() < 0.1:
        _execute_betrayal(state, self_team, ally_team)
        return true
    return false

func _execute_betrayal(state: WorldState, self_team: TeamData,
        ally_team: TeamData) -> void:
    self_team.faction_id = -1
    _update_reputation(ally_team, self_team.team_id, -0.5)
    var ally_leader: PersonData = state.persons.get(ally_team.leader_id)
    if ally_leader:
        ally_leader.memory.append({
            "type": "betrayal", "subject_id": self_team.leader_id,
            "tick": 0, "intensity": 0.8
        })
    print("[Diplomacy] Team%d 背叛 Team%d" % [self_team.team_id, ally_team.team_id])
```

- [ ] **Step 2: 執行測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "Diplomacy|SCRIPT ERROR|DONE"
```

- [ ] **Step 3: Commit**

```powershell
git add scripts/simulation/diplomatic_ai_system.gd
git commit -m "feat(diplomatic-ai): add betrayal logic"
```

---

### Task 4: 整合到 FactionAISystem 與 SimRunner

**Files:**
- Modify: `scripts/simulation/faction_ai_system.gd`
- Modify: `scripts/simulation/sim_runner.gd`

- [ ] **Step 1: sim_runner.gd 加 DiplomaticAiSystem**

```gdscript
var _diplomatic_ai_system: DiplomaticAiSystem
# 在 _init() 加
_diplomatic_ai_system = DiplomaticAiSystem.new()
```

- [ ] **Step 2: faction_ai_system.gd — 在 _update_faction 加主動外交呼叫**

找到 `faction_ai_system.gd` 的 `_update_faction` 或每 team tick 函數，在末尾加：

```gdscript
# 每 20 tick 評估一次主動外交
if state.world.current_tick % 20 == 0:
    DiplomaticAiSystem.new().try_proactive_diplomacy(state, leader_team)
```

- [ ] **Step 3: faction_ai_system.gd — 結盟 team 評估背叛**

在 faction 更新末尾加：
```gdscript
if state.world.current_tick % BETRAY_CHECK_INTERVAL == 0:
    for tid in f.member_team_ids:
        if tid == f.leader_team_id: continue
        var member_team: TeamData = state.teams.get(tid)
        if member_team:
            DiplomaticAiSystem.new().consider_betrayal(state, member_team, leader_team)
```

- [ ] **Step 4: 執行 500 tick 測試**

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd 2>&1 | Select-String "Diplomacy|SCRIPT ERROR|DONE"
```

預期：`[Diplomacy]` print 至少出現一次

- [ ] **Step 5: Commit**

```powershell
git add scripts/simulation/faction_ai_system.gd scripts/simulation/sim_runner.gd
git commit -m "feat(diplomatic-ai): integrate proactive diplomacy and betrayal into FactionAI"
```
