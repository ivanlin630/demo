# 外交 AI Design

## 依賴

本 spec 依賴：
- `2026-05-27-data-structure-update-design.md`（known_reputations、relations、goals）
- `2026-05-27-npc-ai-design.md`（NPC 個人目標影響 leader 決策）

---

## Goal

實裝 NPC leader 的外交決策：主動提出結盟/貿易/投降、被動響應外交請求、依 5 個輸入計算接受/拒絕傾向、更新 known_reputations。外交結果透過 MessageSystem 傳播。

---

## 1. 外交 5 輸入模型

每次外交評估（主動或被動）皆計算一個 `diplomacy_score`，高→傾向接受/主動，低→拒絕。

```gdscript
func _calc_diplomacy_score(state: WorldState,
        self_team: TeamData, other_team: TeamData) -> float:
    var self_leader: PersonData = state.persons.get(self_team.leader_id)
    if self_leader == null: return 0.0

    # 1. 資源壓力（自身資源緊張 → 更願意外交）
    var food_ratio: float = float(self_team.resources.get("food", 0)) / \
        maxf(self_team.population * 5.0, 1.0)
    var resource_need: float = clampf(1.0 - food_ratio, 0.0, 1.0)

    # 2. 軍事實力差（對方明顯強於自己 → 更願意外交）
    var self_pop: int  = self_team.population
    var other_pop: int = other_team.population
    var power_gap: float = clampf(
        float(other_pop - self_pop) / maxf(self_pop, 1.0), -1.0, 1.0)
    # 若己方更強：power_gap < 0 → 減分；若對方更強：power_gap > 0 → 加分

    # 3. 對方信譽（己方視角 known_reputations）
    var rep: float = float(self_team.known_reputations.get(
        other_team.team_id, 0.5))

    # 4. 個人關係（leader 對 other leader 的 relations）
    var other_leader_id: int = other_team.leader_id
    var relation: float = float(self_leader.relations.get(
        other_leader_id, 0.0))  # -1~1

    # 5. Values 相容（信義×義氣 → 避免衝突）
    var self_peace: float = self_leader.values.get("義氣", 0.5) * \
        self_leader.values.get("信義", 0.5)

    var score: float = \
        resource_need * 0.3 + \
        power_gap     * 0.2 + \
        rep           * 0.2 + \
        relation      * 0.15 + \
        self_peace    * 0.15
    return clampf(score, 0.0, 1.0)
```

---

## 2. 外交動作類型

| action | 觸發條件（主動） | 響應條件（被動） |
|---|---|---|
| `"propose_alliance"` | diplomacy_score > 0.6 且 same faction 不存在 | score > 0.55 |
| `"propose_trade"` | 有交易意願且 discovered | score > 0.4 |
| `"demand_tribute"` | 實力差 > 0.5 且 貪婪 > 0.6 | — |
| `"offer_surrender"` | 自身瀕危（food<5，pop<3） | — |
| `"reject"` | — | score < 0.3 |

---

## 3. 外交動作執行（FactionAISystem 呼叫）

### 主動外交

```gdscript
func _try_diplomacy_proactive(state: WorldState, self_team: TeamData) -> void:
    var self_leader: PersonData = state.persons.get(self_team.leader_id)
    if self_leader == null: return
    # 慎重壓低主動外交頻率
    if randf() > self_leader.values.get("慎重", 0.5) * 0.5 + 0.2: return

    for other_id in state.team_discovered.get(self_team.team_id, []):
        var other: TeamData = state.teams.get(other_id)
        if other == null or other.faction_id == self_team.faction_id: continue
        var score: float = _calc_diplomacy_score(state, self_team, other)

        if score > 0.6 and self_team.faction_id != -1:
            _send_diplomacy_message(state, self_team, other, "propose_alliance")
            return
        elif score > 0.4:
            _send_diplomacy_message(state, self_team, other, "propose_trade")
            return

        var self_leader_v := self_leader.values
        var power_gap: float = float(other.population - self_team.population) / \
            maxf(self_team.population, 1.0)
        if power_gap > 0.5 and self_leader_v.get("貪婪", 0.5) > 0.6:
            _send_diplomacy_message(state, self_team, other, "demand_tribute")
            return
```

### 被動外交（接收訊息時呼叫）

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
                return "accept"
            return "reject"
        "demand_tribute":
            # 抵抗或屈服
            var self_leader: PersonData = state.persons.get(self_team.leader_id)
            var resist: float = 1.0 - score
            if self_leader != null:
                resist += self_leader.values.get("好戰", 0.5) * 0.3
            if resist > 0.5: return "reject"
            # 支付 tribute
            var tribute: float = self_team.resources.get("coin", 0) * 0.1
            self_team.resources["coin"] = float(self_team.resources.get("coin", 0)) - tribute
            sender_team.resources["coin"] = float(sender_team.resources.get("coin", 0)) + tribute
            return "accept"
        "offer_surrender":
            if score > 0.3:
                _absorb_team(state, self_team, sender_team)
                return "accept"
            return "reject"
    return "reject"
```

---

## 4. 結盟邏輯

```gdscript
func _form_alliance(state: WorldState, team_a: TeamData, team_b: TeamData) -> void:
    # 若 team_a 有 faction：team_b 加入
    if team_a.faction_id != -1:
        team_b.faction_id = team_a.faction_id
        var faction: FactionData = state.factions.get(team_a.faction_id)
        if faction: faction.member_team_ids.append(team_b.team_id)
    elif team_b.faction_id != -1:
        team_a.faction_id = team_b.faction_id
        var faction: FactionData = state.factions.get(team_b.faction_id)
        if faction: faction.member_team_ids.append(team_a.team_id)
    # 兩方皆獨立：新建 faction（FactionAI 另處理）
    _update_reputation(team_a, team_b.team_id, 0.2)
    _update_reputation(team_b, team_a.team_id, 0.2)
```

---

## 5. known_reputations 更新

信譽由 MessageSystem 傳遞外交事件時更新，非全知。

```gdscript
func _update_reputation(team: TeamData, other_id: int, delta: float) -> void:
    var cur: float = float(team.known_reputations.get(other_id, 0.5))
    team.known_reputations[other_id] = clampf(cur + delta, 0.0, 1.0)
```

觸發時機（外交事件後由外交系統呼叫）：

| 事件 | delta |
|---|---|
| 結盟 | +0.2 |
| 成功貿易 | +0.05 |
| 拒絕外交 | -0.1 |
| 攻擊 | -0.3 |
| 背叛結盟（defect） | -0.5 |
| 支援盟友 | +0.15 |

MessageSystem 傳播外交事件時，收到訊息的 team 也更新對應信譽（帶訊息失真）。

---

## 6. 背叛判斷

勢力 AI 每 BETRAY_CHECK_INTERVAL tick（TEST VALUE: 50）評估是否背叛盟友：

```gdscript
func _consider_betrayal(state: WorldState, self_team: TeamData,
        ally_team: TeamData) -> bool:
    var self_leader: PersonData = state.persons.get(self_team.leader_id)
    if self_leader == null: return false
    var betrayal_score: float = \
        self_leader.values.get("野心", 0.5) * 0.4 + \
        (1.0 - self_leader.values.get("信義", 0.5)) * 0.4 + \
        (1.0 - self_leader.values.get("義氣", 0.5)) * 0.2
    # 對方強大時降低背叛意願
    var power_gap: float = float(ally_team.population - self_team.population) / \
        maxf(self_team.population, 1.0)
    if power_gap > 0.5: betrayal_score -= 0.3
    if betrayal_score > 0.65 and randf() < 0.1:   # TEST VALUE
        _execute_betrayal(state, self_team, ally_team)
        return true
    return false

func _execute_betrayal(state: WorldState, self_team: TeamData,
        ally_team: TeamData) -> void:
    self_team.faction_id = -1
    _update_reputation(ally_team, self_team.team_id, -0.5)
    # 寫入記憶（betrayal）至 ally_team 所有 named_members
    var ally_leader: PersonData = state.persons.get(ally_team.leader_id)
    if ally_leader:
        ally_leader.memory.append({
            "type": "betrayal", "subject_id": self_team.leader_id,
            "tick": state.current_tick, "intensity": 0.8
        })
```

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `[Diplomacy]` print 出現
- `known_reputations` 在外交事件後更新
- 結盟後兩 team 在同 faction
- 背叛後信譽 -0.5，memory 寫入
