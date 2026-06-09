# NPC 主動征服系統（Prosperity Attack）— Design

> 日期：2026-06-10
> 議題：4 config × 90 天測試發現 0 戰鬥。survival Path 2 掠奪需「無 outpost + 缺糧 + 殘忍/好戰」全到位才觸發，所有 team 有 outpost 永遠回家。需 prosperity 路徑：野心驅動的主動征服，獨立於 survival

## 背景

當前狀態：
- `_trigger_survival` 有 Path 2 掠奪，但條件包含「無 own outpost」→ 配置每 team 都有 outpost 時永不觸發
- `_evaluate_attack` 有 `attack_score = ambition*0.4 + martial*0.4 - honor*0.4`，僅用於 faction goal 評估，**不會 schedule 實際 attack 任務 / encounter**
- 4 config × 90 天合計 0 encounter / 0 戰鬥 / 0 死亡

需求：
1. **A 主機制**：野心驅動的 prosperity attack，獨立於 survival
2. **B 條件分支**：survival 中若 outpost ETA > 5 日 且 殘忍>0.5 或 好戰>0.6 → 允許就近掠
3. **C 條件分支**：軍隊 tag → readiness 門檻 −0.1 + 評估頻率加倍
4. 戰敗無硬性 cooldown，純 reaction（loyalty / stress）
5. 攻佔 outpost 走既有 5 條 ownership 路徑，居民拒投靠依 leader 個性決定 屠/放棄/強佔

## 目標

1. `faction_ai_system._evaluate_prosperity_attack(state, team)` 新函數
2. 整合 B 條件入 `_trigger_survival`
3. 整合 C 條件入 readiness / cadence
4. 攻佔 outpost 三 path（屠/放棄/強佔）入 `encounter_system` 結束 callback
5. 戰敗 reaction（loyalty / stress）走既有 reaction 系統 event tag

## 不在範圍

- 多 team 聯合攻打（後續）
- 戰場戰術（既有 encounter）
- 防守方主動退守 outpost（後續）
- 戰俘交易（後續）

## A 主機制：prosperity attack 決策

### 評估時機

```gdscript
const PROSPERITY_CADENCE: int = 720          # 3 天 (3 × TICKS_PER_DAY)
const PROSPERITY_CADENCE_MILITARY: int = 360 # 軍隊 tag 1.5 天
```

每 leader_team 每 cadence 評估一次 + 事件驅動立即重評：

**事件觸發重評：**
- (a) 鄰國（discovered list）pop 暴跌 > 30%（送上門的肉）
- (b) 發現新 team（`team_discovered` 變動）
- (d) leader values 變動（reaction 改性格）

**事件 (c) anon_treasury 滿**：不重評，改為 `attack_score +0.1` 加成（soft）

### 入口函數

```gdscript
func _evaluate_prosperity_attack(state: WorldState, team: TeamData) -> void:
    # 過濾：玩家、已忙、被打中、survival 中
    if team.leader_id == state.player_id and state.player_id != -1: return
    if team.combat_target != -1: return
    if team.current_task != TeamData.TASK_IDLE: return
    if team.current_task in SURVIVAL_TASKS: return

    var leader: PersonData = state.persons.get(team.leader_id)
    if leader == null: return

    # 1. attack_score = 個性 + anon_treasury 加成
    var score: float = _calc_attack_score(team, leader)
    if score < ATTACK_SCORE_THRESHOLD: return

    # 2. readiness 個性 + tag 修正
    var threshold: float = _calc_readiness_threshold(team, leader)
    var readiness: float = _calc_readiness(team)
    if readiness < threshold: return

    # 3. prey 選擇（個性權重）
    var prey_id: int = _find_prosperity_prey(state, team, leader)
    if prey_id == -1: return

    # 4. trigger TASK_ATTACK
    team.current_task = TeamData.TASK_ATTACK
    team.move_target = state.teams[prey_id].tile_pos
    team.combat_target = prey_id
    # 事件 log
    state.log_event("ProsperityAttack", {
        "attacker": team.team_id, "prey": prey_id, "score": score
    })
```

### attack_score 公式

```gdscript
func _calc_attack_score(team: TeamData, leader: PersonData) -> float:
    var ambition: float = float(leader.values.get("野心", 0.5))
    var martial: float = float(leader.values.get("好戰", 0.5))
    var honor: float = float(leader.values.get("信義", 0.5))
    var base: float = ambition * 0.4 + martial * 0.4 - honor * 0.4
    # anon_treasury 滿加成 (soft)
    if team.anon_treasury > 200.0:
        base += 0.1
    return base

const ATTACK_SCORE_THRESHOLD: float = 0.3
```

### readiness 門檻（個性修正 + 軍隊 tag）

```gdscript
func _calc_readiness_threshold(team: TeamData, leader: PersonData) -> float:
    var ferocity: float = maxf(
        float(leader.values.get("殘忍", 0.5)),
        float(leader.values.get("好戰", 0.5))
    )
    var caution: float = float(leader.values.get("慎重", 0.5))
    var threshold: float = 0.55 - ferocity * 0.15 + caution * 0.15
    # 軍隊 tag 降 0.1
    if "軍隊" in team.tags:
        threshold -= 0.1
    return clampf(threshold, 0.3, 0.85)

func _calc_readiness(team: TeamData) -> float:
    # pop / anon_combat_skill / food / weapon 加權
    var pop_factor: float = clampf(float(team.population) / 10.0, 0.0, 1.0)
    var skill: float = team.anon_combat_skill
    var food_days: float = float(team.resources.get("food", 0)) \
        / maxf(float(team.population) * FOOD_PER_PERSON_PER_DAY_SURVIVAL, 0.001)
    var food_factor: float = clampf(food_days / 14.0, 0.0, 1.0)
    var weapon: float = float(team.resources.get("weapon_melee_low", 0))
    var weapon_factor: float = clampf(weapon / float(team.population), 0.0, 1.0)
    return (pop_factor + skill + food_factor + weapon_factor) / 4.0
```

### prey 選擇（個性權重公式）

```gdscript
func _find_prosperity_prey(state: WorldState, team: TeamData, leader: PersonData) -> int:
    var greed: float = float(leader.values.get("貪婪", 0.5))
    var cruelty: float = float(leader.values.get("殘忍", 0.5))
    var ambition: float = float(leader.values.get("野心", 0.5))

    var best_id: int = -1
    var best_score: float = 0.0
    for tid in state.team_discovered.get(team.team_id, []):
        if tid == team.team_id: continue
        var prey: TeamData = state.teams.get(tid)
        if prey == null: continue
        # 同 faction 跳過
        if prey.faction_id != -1 and prey.faction_id == team.faction_id: continue
        # ETA 過遠跳過
        var catch_result = PathSystem.estimate_catch_up(state, team, tid)
        if not catch_result.reachable: continue

        # 3 維度 score
        var richness: float = (float(prey.resources.get("coin", 0))
            + float(prey.resources.get("food", 0))
            + float(prey.resources.get("material", 0))) / 100.0
        var weakness: float = clampf(
            1.0 - float(prey.population) / maxf(float(team.population), 1.0),
            0.0, 1.0)
        var border: float = _is_border_adjacent(state, team, prey) ? 1.0 : 0.3

        var eta_days: float = maxf(float(catch_result.eta) / 240.0, 1.0)
        var score: float = (richness * greed
            + weakness * cruelty
            + border * ambition) / eta_days

        if score > best_score:
            best_score = score
            best_id = tid
    return best_id

func _is_border_adjacent(state: WorldState, attacker: TeamData, prey: TeamData) -> bool:
    # 簡化：兩 team 的 tile_pos 距離 <= 2 即接壤
    var dx: int = prey.tile_pos.x - attacker.tile_pos.x
    var dy: int = prey.tile_pos.y - attacker.tile_pos.y
    return (abs(dx) + abs(dx + dy) + abs(dy)) / 2 <= 2
```

## B 條件分支：survival 缺糧 + 遠 outpost 允掠

`_trigger_survival` Path 1 修改：

```gdscript
# Path 1: 有 own outpost
var own_pos: Vector2i = _find_own_outpost(state, team)
if own_pos != Vector2i(-1, -1):
    var own_eta_days: float = float(_estimate_own_eta(state, team, own_pos)) / 240.0
    var leader: PersonData = state.persons.get(team.leader_id)
    var ferocity_ok: bool = leader != null and (
        float(leader.values.get("殘忍", 0.5)) > 0.5
        or float(leader.values.get("好戰", 0.5)) > 0.6
    )
    # 遠 outpost + 殘忍/好戰 → 試掠奪
    if own_eta_days > 5.0 and ferocity_ok:
        var prey_id: int = _find_weakest_prey(state, team)
        if prey_id != -1:
            team.current_task = TeamData.TASK_LOOT
            team.move_target = state.teams[prey_id].tile_pos
            team.combat_target = prey_id
            return
    # 否則照舊回家
    if severity == "warning" and not _should_abandon_current_task(team, own_pos):
        team.previous_task = ""
        return
    team.current_task = "return_home"
    team.move_target = own_pos
    return
# ... Path 2/3/4 原樣
```

## C 條件分支：軍隊 tag

已整合：
- readiness 門檻 −0.1（見 `_calc_readiness_threshold`）
- 評估頻率：cadence 從 720 → 360（在 sim_runner 處）

## 攻佔 outpost：5 條 ownership 路徑 + 居民處置

`encounter_system._resolve_encounter_end` 結束 callback 增：

```gdscript
func _on_attack_victory(state: WorldState, attacker_id: int, prey_id: int) -> void:
    var attacker: TeamData = state.teams.get(attacker_id)
    var prey: TeamData = state.teams.get(prey_id)
    if attacker == null or prey == null: return

    # 既有 5 條 ownership 路徑（capture, abandon, ...）已處理 prey 滅團 / 撤退情境
    # 此處只處理「prey outpost 上有居民團 PRODUCE tag 且戰後仍存活」的情況

    var occupied_tile: HexTileData = _find_prey_outpost(state, prey)
    if occupied_tile == null: return
    var resident: TeamData = _find_resident_team(state, occupied_tile)
    if resident == null: return  # 既有路徑已處理

    # 居民拒投靠判定（既有 reputation/known_reputations + reaction）
    var rep: float = float(resident.known_reputations.get(attacker_id, 0.5))
    var resident_leader: PersonData = state.persons.get(resident.leader_id)
    var fear: float = clampf(1.0 - rep, 0.0, 1.0)
    var caution: float = float(resident_leader.values.get("慎重", 0.5)) if resident_leader else 0.5
    var accept: bool = (fear > caution + 0.2) and rep > 0.3

    if accept:
        # 接受新主：outpost 轉手，居民團不變
        occupied_tile.outpost_owner = attacker_id
        state.log_event("ResidentAccept", {
            "attacker": attacker_id, "resident": resident.team_id })
        return

    # 拒投靠 → 攻城方 leader 個性決定
    var atk_leader: PersonData = state.persons.get(attacker.leader_id)
    if atk_leader == null:
        # 默認放棄
        _abandon_occupation(state, occupied_tile, resident)
        return
    var cruelty: float = float(atk_leader.values.get("殘忍", 0.5))
    var martial: float = float(atk_leader.values.get("好戰", 0.5))
    var honor: float = float(atk_leader.values.get("義氣", 0.5))
    var faith: float = float(atk_leader.values.get("信義", 0.5))
    var ambition: float = float(atk_leader.values.get("野心", 0.5))
    var caution2: float = float(atk_leader.values.get("慎重", 0.5))

    if cruelty > 0.7 or martial > 0.7:
        # 屠：居民團解散 pop → anon_treasury 收貨，outpost 空殼
        _massacre_residents(state, attacker, resident, occupied_tile)
    elif honor > 0.6 or faith > 0.6:
        # 放棄佔領
        _abandon_occupation(state, occupied_tile, resident)
    elif ambition > 0.7 and caution2 > 0.5:
        # 強佔：outpost 易主，居民 pop −20% 鎮壓 cost
        _force_occupy(state, attacker, resident, occupied_tile)
    else:
        _abandon_occupation(state, occupied_tile, resident)
```

`_massacre_residents` / `_force_occupy` / `_abandon_occupation` 三 helper 新檔。

## 戰敗 reaction

`encounter_system._resolve_encounter_end` 戰敗 callback：

```gdscript
func _on_attack_defeat(state: WorldState, attacker: TeamData, pop_loss_ratio: float) -> void:
    var leader: PersonData = state.persons.get(attacker.leader_id)
    if leader == null: return
    var honor: float = float(leader.values.get("義氣", 0.5))
    var faith: float = float(leader.values.get("信義", 0.5))
    var caution: float = float(leader.values.get("慎重", 0.5))

    var loyalty_delta: float = -0.1 * (honor + faith) / 2.0
    var stress_delta: float = 0.2 * caution
    if pop_loss_ratio > 0.3:
        loyalty_delta *= 2.0
        stress_delta *= 1.5

    # 走既有 reaction 系統 event tag
    state.log_event("AttackDefeat", {
        "team": attacker.team_id,
        "pop_loss_ratio": pop_loss_ratio,
        "loyalty_delta": loyalty_delta,
        "stress_delta": stress_delta
    })
    # reaction_system 收 AttackDefeat tag → 套用到所有 named members
```

`reaction_system` 加 `AttackDefeat` event 處理（既有反應系統 hook）。

## 不變量

- 玩家 team 不被 prosperity 評估
- combat_target != -1 不重評
- 同 faction 不互攻
- prey 不可達 → 跳過
- ATTACK_SCORE_THRESHOLD = 0.3 為硬下限
- readiness 公式回值 [0, 1]
- threshold 公式回值 [0.3, 0.85]
- 戰敗無 cooldown，只走 reaction
- 居民拒投靠 → 三 path 必走一條

## 測試

1. **無野心 leader 不評估**（野心 0.1, 好戰 0.1 → score < 0.3）
2. **野心 leader + 弱 prey → trigger TASK_ATTACK**
3. **無 prey 可達 → 不 trigger**
4. **同 faction 排除**
5. **軍隊 tag → threshold 降 0.1 + cadence 加倍**
6. **anon_treasury 高 → score +0.1 加成**
7. **B 分支：outpost ETA > 5 日 + 殘忍 → TASK_LOOT 觸發**
8. **B 分支：outpost ETA < 5 日 → 走回家**
9. **攻佔 outpost：居民接受 → outpost 易主**
10. **攻佔 outpost：殘忍 leader 拒受 → 屠**
11. **攻佔 outpost：義氣 leader 拒受 → 放棄**
12. **攻佔 outpost：野心+慎重 拒受 → 強佔 pop −20%**
13. **戰敗 → reaction 套用（loyalty 降、stress 升）**
14. **prey 評分：高貪婪 → 偏富 prey；高野心 → 偏接壤 prey**
15. **multi runner 4 config × 90 天 → encounter > 0**

## 風險

- **戰爭過頻**：score threshold + readiness 個性修正都需測平衡
- **個性公式參數需 tune**：0.3 / 0.5 / 0.15 等魔法數待測試
- **居民拒投靠的 fear 公式**：用 `1 - rep` 過簡，可能誤判
- **anon_treasury 加成**：可能與既有 promotion ×3 路徑衝突
- **A* path query 量增加**：每 prey 候選都查 catch_up，多 team × 多 prey × 3 日 cadence ~ 可接受
- **B 分支讓有 outpost team 也可能掠奪**：與既有 game_sim_test 行為差異需驗證
- **TASK_ATTACK 既有用途**：grep 確認無衝突
- **屠村機制與既有 5 path ownership 互動**：需驗證不重複處理

## 解決

- NPC 主動發動戰爭（核心玩法）
- 個性 values 對戰爭頻率有實際影響
- 軍隊 tag 有差異化行為
- outpost 缺糧的彈性處理

## 後續

- 多 team 聯合攻打
- 防守方 active 行為（守城 / 撤退）
- 戰俘交易
- 戰爭疲勞累積（不同於 stress）
- 大規模 raid（faction-level）
