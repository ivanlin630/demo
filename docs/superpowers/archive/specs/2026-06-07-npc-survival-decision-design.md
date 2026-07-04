# NPC 生存決策（飢餓回家／乞食／勒索／投靠）— Design

> 日期：2026-06-07（v2: 2026-06-08）
> 議題：B（known_issues 後續）— NPC team 食物枯竭時無自救行為

## 背景

`faction_ai_system` 為 NPC 隊伍指派 task 依據 leader values + faction strategic goals。**完全不檢查食物存量**，導致：

- 商隊 Team1 移動賺錢 → 離開 outpost → food 歸 0 → loyalty 崩 → N1_flee 大量流失
- 生產村 Team3 task=生產，但無 outpost → 採不到食 → 同樣崩潰
- 玩家觀察「整個地圖大半 team food=0 但無人主動找食」→ 不合理

需要 **survival override**：危機時把當前 task 改為求生行動。

## 目標

NPC team 每 NEAR_CADENCE（1h）評估生存危機，依嚴重程度 + leader 個性選擇行動，覆寫當前 task。

## 不在範圍

- 玩家 team 不受影響（玩家永遠是 leader，自主決策）
- Coin 危機、傷患危機 → 後續 spec
- D2 player 死亡保護 → 獨立 spec
- 分層評估頻率重構 → 見 `docs/superpowers/notes/2026-06-08-tiered-evaluation-frequency.md`
- 速度評估 / pathing 系統 → 獨立 spec（本 spec 用 simple workaround）

## 觸發條件（兩段）

```gdscript
const FOOD_PER_PERSON_PER_DAY: float = 2.4

const URGENCY_DAYS:   float = 1.0   # < 1 天份 = 緊急
const WARNING_DAYS:   float = 3.0   # < 3 天份 = 警戒

# faction_ai_system.evaluate_all 每個 team loop
if team.leader_id == state.player_id and state.player_id != -1:
    continue   # 玩家 team 跳過
var pop_eff: int = team.population
var food: float = float(team.resources.get("food", 0))
var food_per_day: float = pop_eff * FOOD_PER_PERSON_PER_DAY
var days_left: float = food / maxf(food_per_day, 0.001)

if days_left < URGENCY_DAYS:
    _trigger_survival(state, team, "urgent")    # 絕對優先
elif days_left < WARNING_DAYS:
    _trigger_survival(state, team, "warning")   # 考量距離差
# else: 正常 task 不動
```

### Sticky 規則（避免 strategic_ai 蓋過）

team 已在 survival task 中時，不重新觸發、不被 strategic_ai 蓋過：

```gdscript
const SURVIVAL_TASKS: Array = ["return_home", "乞食", "掠奪", "投靠"]
if team.current_task in SURVIVAL_TASKS:
    return   # 已在求生中
```

`strategic_ai_system` 設 task 前檢查同樣 SURVIVAL_TASKS 跳過。

## 決策樹

```
_trigger_survival(state, team, severity):
    leader = state.persons.get(team.leader_id)
    if leader == null: return
    
    # 1. 有自己 outpost → 回家
    own_pos = _find_own_outpost(state, team)
    if own_pos != Vector2i(-1, -1):
        # 警戒 + 出戰中 + outpost 太遠 → 衡量是否中斷
        if severity == "warning" and not _should_abandon_current_task(team, own_pos):
            return   # 順其自然，下次評估
        team.current_task = "return_home"
        team.move_target = own_pos
        return
    
    # 2. 殘忍/好戰 → 掠奪
    if leader.values.get("殘忍", 0.5) > 0.5 or leader.values.get("好戰", 0.5) > 0.6:
        prey_id = _find_weakest_prey(state, team)
        if prey_id != -1:
            team.current_task = TeamData.TASK_LOOT
            team.move_target = state.teams[prey_id].tile_pos
            team.combat_target = prey_id
            return
    
    # 3. 義氣 + 信義 → 投靠/結盟
    if leader.values.get("義氣", 0.5) + leader.values.get("信義", 0.5) > 1.2:
        ally_id = _find_strong_neighbor(state, team)
        if ally_id != -1:
            _diplomatic.send_diplomacy_message(state, team, state.teams[ally_id],
                "offer_surrender" if leader.values.get("求生欲", 0.5) > 0.6 else "propose_alliance")
            team.current_task = "投靠"
            team.move_target = state.teams[ally_id].tile_pos
            return
    
    # 4. 默認 → 乞食
    aid_target = _find_aid_target(state, team)
    if aid_target != -1:
        team.current_task = "乞食"
        team.move_target = state.teams[aid_target].tile_pos
        team.combat_target = aid_target
```

### `_should_abandon_current_task(team, target_pos)`

警戒等級才用。考量距離差：

```gdscript
func _should_abandon_current_task(team, survival_target) -> bool:
    if team.move_target == Vector2i(-1, -1):
        return true   # 無原任務目標
    var cur_dist: int = _hex_dist(team.tile_pos, team.move_target)
    var surv_dist: int = _hex_dist(team.tile_pos, survival_target)
    # survival 比原目標近或順路（差 ≤ 2 hex）→ 中斷
    return surv_dist <= cur_dist + 2
```

## 新組件

### `_find_own_outpost(state, team) -> Vector2i`

掃 `state.world.tiles` 找 `outpost_owner == team.team_id`。無則 `Vector2i(-1, -1)`。

### `_find_weakest_prey(state, team) -> int`

從 `state.team_discovered[team.team_id]` 找 pop < team.pop × 0.7 且 food > 20 的 team。

### `_find_strong_neighbor(state, team) -> int`

找 pop > team.pop × 1.5 且非敵對 faction 的 team。

### `_find_aid_target(state, team) -> int`

**不過濾 rep**（陌生 team 也能乞）。

優先序：
1. 同 faction
2. rep ≥ 0.5（中立以上）
3. 最近距離

過濾條件：目標 team food > pop × 14（兩週存糧）。

無符合 → 回 -1（任何 team 都沒餘糧 → 無解）。

## 乞食解析（`interaction_system._resolve_aid_request`）

新增於 `interaction_system._resolve_pair` 附近，trigger 條件：同 tile + 一方 `current_task == "乞食"` + `combat_target == 對方 id`。

```gdscript
func _resolve_aid_request(state: WorldState, beggar_id: int, target_id: int) -> Dictionary:
    var beggar: TeamData = state.teams.get(beggar_id)
    var target: TeamData = state.teams.get(target_id)
    if beggar == null or target == null: return { "ok": false }

    # 玩家 target → forced event
    if target.leader_id == state.player_id and state.player_id != -1:
        state.player_forced_event = {
            "from_id": beggar_id,
            "action": "aid_request",
            "beggar_food": float(beggar.resources.get("food", 0)),
            "beggar_pop": beggar.population,
            "max_giveable": _calc_player_surplus(target),
        }
        state.player_forced_event_id = "aid_%d_%d" % [beggar_id, state.world.current_tick]
        return { "ok": true, "pending": true }

    # NPC target 自決：用 leader 個性 + memory 累計
    var target_leader: PersonData = state.persons.get(target.leader_id)
    if target_leader == null: return { "ok": false }
    
    var honor: float  = float(target_leader.values.get("義氣", 0.5))
    var greed: float  = float(target_leader.values.get("貪婪", 0.5))
    var rep: float    = float(target.known_reputations.get(beggar_id, 0.5))
    var annoyance: float = _count_recent_begs(target_leader, beggar_id) * 0.2
    
    var give_score: float = honor + rep - greed * 0.5 - annoyance
    
    if give_score < 0.3:
        # 拒絕
        _msg.emit_message(state, "aid_refused", ..., target,
            { "origin": str(target_id), "target": str(beggar_id) })
        _update_reputation(beggar, target_id, -0.1)
        # 雙方 memory：beggar 記恨、target 記煩
        _npc_ai.write_memory(state.persons.get(beggar.leader_id), "rejected_aid", target_id,
            state.world.current_tick, 0.5)
        _npc_ai.write_memory(target_leader, "begged_at_me", beggar_id,
            state.world.current_tick, 0.3)
        beggar.current_task = beggar.previous_task   # 回原 task
        return { "ok": true, "accepted": false }

    # 接受：給多少 = min(需求, 餘糧 × give_score)
    var need: float = float(beggar.population) * FOOD_PER_PERSON_PER_DAY * WARNING_DAYS \
                     - float(beggar.resources.get("food", 0))
    var target_food: float = float(target.resources.get("food", 0))
    var target_reserve: float = float(target.population) * 14.0
    var surplus: float = maxf(target_food - target_reserve, 0.0)
    var give: float = minf(need, surplus * give_score)
    if give <= 0.0:
        _msg.emit_message(state, "aid_refused", ..., target, ...)
        return { "ok": true, "accepted": false }
    
    target.resources["food"] = target_food - give
    beggar.resources["food"] = float(beggar.resources.get("food", 0)) + give
    _msg.emit_message(state, "aid_given",
        "Team%d 援助 Team%d %.0f 食物" % [target_id, beggar_id, give], target, ...)
    _update_reputation(beggar, target_id, 0.15)
    # Memory：beggar 記恩、target 記煩（仍有）
    var intensity: float = clampf(give / need, 0.1, 1.0)
    _npc_ai.write_memory(state.persons.get(beggar.leader_id), "benefactor", target_id,
        state.world.current_tick, intensity)
    _npc_ai.write_memory(target_leader, "begged_at_me", beggar_id,
        state.world.current_tick, 0.2)
    beggar.current_task = beggar.previous_task
    return { "ok": true, "accepted": true, "amount": give }
```

### `_count_recent_begs(leader, beggar_id) -> int`

掃 `leader.memory`，數最近 N=30 天內 `type == "begged_at_me"` 且 `subject_id == beggar_id` 的條目。Memory decay 由既有系統處理。

### `previous_task` 暫存

`team.current_task` 改 survival 前先存：

```gdscript
team.previous_task = team.current_task   # 暫存
team.current_task = "乞食"               # 切換
```

`previous_task` 為新 TeamData 欄位（初始 `""`）。

## 玩家 forced event 處理

`player_command_system` 新增 `respond_aid_request`：

```gdscript
"respond_aid_request":
    var fe: Dictionary = state.player_forced_event
    var beggar_id: int = int(fe.get("from_id", -1))
    var response: Dictionary = state.player_state.get("aid_response", {})
    var beggar: TeamData = state.teams.get(beggar_id)
    var pt: TeamData = _get_player_team(state)
    if beggar == null or pt == null:
        state.player_forced_event = {}
        return { "ok": false }
    if response.get("refuse", false):
        _msg.emit_message(state, "aid_refused", "玩家拒絕援助", pt, ...)
        _update_reputation(beggar, pt.team_id, -0.1)
        _npc_ai.write_memory(state.persons.get(beggar.leader_id), "rejected_aid",
            pt.team_id, state.world.current_tick, 0.5)
    else:
        var amount: float = float(response.get("give_amount", 0.0))
        var actual: float = minf(amount, float(pt.resources.get("food", 0)))
        pt.resources["food"] = float(pt.resources.get("food", 0)) - actual
        beggar.resources["food"] = float(beggar.resources.get("food", 0)) + actual
        _msg.emit_message(state, "aid_given", ...)
        _update_reputation(beggar, pt.team_id, 0.15)
        _npc_ai.write_memory(state.persons.get(beggar.leader_id), "benefactor",
            pt.team_id, state.world.current_tick, clampf(actual / 50.0, 0.1, 1.0))
    beggar.current_task = beggar.previous_task
    state.player_forced_event = {}
    state.player_forced_event_id = ""
    return { "ok": true }
```

### 超時 = 拒絕

用既有 `forced_event` 超時邏輯（`sim_runner.gd:82-86`），1h 自動清掉。本 spec **不改超時機制**，超時後 beggar 視同被拒（state.player_forced_event 被清掉，下次乞食 again 觸發新 event）。

**已有 TODO：** 超時自動 emit refuse message + 寫 rejected_aid memory。可在超時邏輯加一段 callback。

## 觸發頻率

走 NEAR_CADENCE（每 1h，與 faction_ai 同層）。**未來若採分層方案（見 notes）**，survival 屬於「反應性層」仍是最高頻。

## 不變量

- 玩家 team 永不被 survival override
- aid 轉移後雙方 food >= 0
- survival 觸發後 task 為 SURVIVAL_TASKS 之一，不被 strategic_ai 改回
- 乞食 task 達 target 後若超過 24 tick 未 resolve → task 重置（避免卡住）
- `previous_task` 切回後清空

## 測試

`headless_test.gd` 加：

1. **緊急觸發**：team food=0、pop=10 → 必發 survival
2. **警戒觸發 + 順路**：food=20、pop=10、survival_target 與 current_task_target 同向 → 切換
3. **警戒觸發 + 反向**：food=20、survival_target 離很遠 → 不切換
4. **return_home**：有 own outpost → task=return_home + move_target=outpost
5. **掠奪**：殘忍 leader + 鄰弱隊 → task=掠奪
6. **乞食**：默認 → task=乞食 + aid_target 設定正確
7. **aid_resolve NPC 接受**：義氣高 target + 有 surplus → food 轉移、雙方 memory 寫入
8. **aid_resolve NPC 拒絕**：義氣低 target → emit refuse、beggar 寫 rejected_aid memory
9. **aid_resolve 玩家 forced event**：target=玩家 → forced_event 寫入
10. **反覆乞食**：beggar 對同 target 乞 4 次 → 第 4 次 give_score 應低於門檻 → 拒絕
11. **陌生 team 乞食**：beggar 與 target 從未互動（rep=0.5）→ 仍可乞，給 score 計算正確
12. **survival sticky**：team 設為「乞食」後 strategic_ai 跑 → task 仍是「乞食」
13. **previous_task 回復**：beggar 原 task=貿易 → 觸發乞食 → 解析後 task 回貿易

## 風險

- **strategic_ai 仍有可能蓋過**：strategic_ai_system 多處設 task，全部加 SURVIVAL_TASKS 檢查工作量大；漏一處 = 卡死
- **多個 beggar 同 target 同時抵達**：interaction_system 同 tile resolve 是序列處理，第二個 beggar 可能撲空（target food 已被第一個拿走）→ 改 beggar，find_aid_target 重評
- **「乞食抵達後目標移動」**：beggar 每 NEAR_CADENCE 重評 move_target（簡單 workaround，速度評估系統 spec 之後改善）
- **memory annoyance 累積無上限**：依賴 `npc_ai.write_memory` 既有 decay 機制處理
- **forced_event 超時改動範圍**：原超時純清空，現在加 callback 寫 memory → 微改 sim_runner

## 解決的 known_issues

- 商隊離家飢餓問題（Team1 demo 場景失血）
- 流亡盜匪無資源無自救（Team4）
- 「整個地圖大半 team food=0」不合理觀感

## 後續延伸

- E 被動產出（解 outpost 離開困境，可能減少 survival 觸發）
- D 攻佔/棄置 → 乞食對象可能變 owner
- C NPC 基建 → 解根本（自己蓋 outpost）
- 玩家被俘虜 → leader 暫時不是玩家（連動 D2 + 俘虜系統）
- aid 系統擴充：贈禮、結盟禮、戰後賠款
- 投靠後 faction 合併細節
