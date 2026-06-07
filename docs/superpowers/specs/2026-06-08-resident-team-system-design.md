# 居民 Team 系統（E + F + 起義 + 移民招攬）— Design

> 日期：2026-06-08
> 議題：E 被動產出（owner 不在也產糧）+ F coin 稅收 + 農民起義機制

## 背景

當前 outpost 的食物產出靠「team 站在 tile 上」採集。商隊型 team 需移動賺錢，離開 outpost 即沒糧。生產村型 team 雖能定居採集，但**沒有「居民/農民」實體**——所有人口都在 team.population 內，不區分「打仗的家臣」與「種田的農民」。

遊戲核心之一是「**農民起義**」，但目前沒有真實農民實體可起義（只能依賴整 team 的 N1_flee/N3_defect 個人反應）。

需要建立「**居民 team**」概念：每個 outpost 有一個獨立的 PRODUCE tag team 駐守，由 outpost owner 管理。商隊離家時，居民繼續產糧上繳。重稅或久不聞訊則起義。

## 目標

1. 引入「居民 team」實體：以 PRODUCE tag team 表示，駐守特定 outpost
2. 收稅機制重用既有 `_resolve_tribute`：owner 派人 task=徵收 到 outpost
3. 招攬移民：新 diplomacy action `invite_settle`（流民/弱隊變居民）
4. 流民 AI：找空 outpost 自主進駐（連動 B spec NPC 生存決策）
5. 起義：faction_ai 評估 PRODUCE team 滿意度，達閾值整村變敵
6. 失聯保護：用 intel snapshot last_tick + 7 天緩衝抵抗假消息
7. 任何有 outpost 的 team 離家後仍有穩定資源供給（不只食物，含 material/coin），避免資源過於匱乏崩潰

## 不在範圍

- 攻佔 outpost 系統（D） → 獨立 spec
- 升級 outpost 自動化 coin 產出（純被動稅）→ 暫不做，靠居民+收稅替代
- 詳細移民團多 leader merge UI → 自動處理（最高統領）
- 玩家設稅率的 UI → 後續 spec（後端先做，UI 後補）
- 商隊「商品庫存」（A spec） → 獨立

## 架構

### 居民 = PRODUCE tag team

複用既有 `TeamData` + `tags: ["生產"]`。**無新 team 型別**。

關鍵特性：
- 自己有 leader、named_members、population
- 自己有 person.stress/loyalty/needs
- tile_pos 固定為某個 outpost 的位置（不主動移動）
- pop 上限由 outpost level 決定（不是 leader 統領）

### 資源產出（多元）

居民在 outpost tile 上：
1. **既有 `collect_resources`** 採集 tile 全部資源（food、material、ore_*）— 因 outpost_level > 0 而觸發
2. **既有 `P2_produce` reaction** 對食物加成（取決於生產 skill + farming_level）
3. **既有 `manufacturing_system`** 可在 civilian L2+ outpost 製造 goods/weapons（owner 派 named NPC 駐守 manufacturing slot）
4. coin 來源：商業 outpost 升級（既有 `OUTPOST_TYPE` 概念可後續擴充），或 owner 收稅後自身轉化（簡化：稅收以 food/material 為主，coin 靠玩家貿易）

→ 居民幫 owner 累積 food + material + goods + 偶發 ore；owner 收稅後可用於招兵/升級/交易換 coin。

### Owner 關係

不存獨立欄位。靠 **`tile.outpost_owner` + 同 tile + 同 faction** 三條件推導。

- 居民 team 站 outpost tile 上
- `tile.outpost_owner` 指向 owner team_id
- 居民與 owner 同 faction

### Movement 鎖定

`movement_system.process` 加判斷：

```gdscript
if team.tags.has("生產") and team.current_task not in ["逃跑", "投靠", "起義", "遷徙"]:
    continue   # 不處理移動
```

### Pop cap 公式

`team_data.pop_cap_from_leadership` 不變（其他 team 仍用此），居民 team 在 `population_system.check_overflow_for_team` 判斷時用 outpost cap：

```gdscript
const OUTPOST_POP_CAP: Dictionary = {
    "civilian": [20, 50, 100],   # L1, L2, L3
    "military": [15, 35, 70],    # 軍事 outpost 容量稍低
}
```

`check_overflow_for_team` 加分支：

```gdscript
var cap: int
if team.tags.has("生產"):
    cap = _outpost_pop_cap(state, team.tile_pos)
else:
    cap = TeamData.pop_cap_from_leadership(cmd)
```

`_outpost_pop_cap(state, pos)` 找 tile.outpost_type/level 對應 OUTPOST_POP_CAP。

## 新欄位

```gdscript
# TeamData
var tax_rate: float = 0.3                   # 收稅率（居民 team 用，0.1-0.7）
var pending_owner_change_tick: int = -1     # 偵測 owner 異動的緩衝倒數（7 天）
```

## 收稅機制（重用既有 _resolve_tribute）

無新函數。owner 派 team task=徵收 到居民 tile：

```
條件（既有）：
- 同 tile
- 同 faction
- 一方 task == "徵收"
→ 觸發 _resolve_tribute
```

### 修改 `_resolve_tribute`（使用 team.tax_rate）

當前用 `faction.tribute_rate` 全勢力同稅率。改為：

```gdscript
func _resolve_tribute(state, collector_id, payer_id):
    var payer: TeamData = state.teams[payer_id]
    # 優先 per-team tax_rate（PRODUCE team 必設），fallback faction default
    var rate: float = payer.tax_rate if payer.tags.has("生產") \
        else float(state.factions[payer.faction_id].tribute_rate)
    # 既有資源轉移邏輯
    var surplus_food = float(payer.resources.get("food", 0)) - float(payer.population) * 14.0
    var taken_food = maxf(surplus_food, 0.0) * rate
    # ... 同 food，對 material/coin/goods
```

### 重稅後果（新邏輯）

`_resolve_tribute` 結算後對 payer team named NPCs 套用：

```gdscript
var stress_gain: float  = maxf(0.0, (rate - 0.3) * 0.3)
var loyalty_loss: float = maxf(0.0, (rate - 0.2) * 0.1)
var fear_gain: float    = maxf(0.0, (rate - 0.6) * 0.5)
for pid in ([payer.leader_id] as Array) + payer.named_members:
    var p: PersonData = state.persons.get(pid)
    if p == null: continue
    p.stress  = minf(p.stress + stress_gain, 1.0)
    p.loyalty = maxf(p.loyalty - loyalty_loss, 0.0)
    p.fear    = minf(p.fear + fear_gain, 1.0)
if rate > 0.5:
    payer.unrest_turns += 1   # 重稅累計不穩
```

## 招攬移民（新 diplomacy action `invite_settle`）

### 玩家發起

`player_command_system` 加 action `invite_settle`：

```gdscript
"invite_settle": _action_invite_settle,
```

實作：

```gdscript
func _action_invite_settle(state, target_id, pt, pt_id) -> Dictionary:
    var tgt: TeamData = state.teams.get(target_id)
    if tgt == null: return { "ok": false, "msg": "目標不存在" }
    var target_pos: Vector2i = state.player_state.get("settle_pos", Vector2i(-1, -1))
    if target_pos == Vector2i(-1, -1):
        return { "ok": false, "msg": "未指定 outpost 位置" }
    var tile: HexTileData = state.world.tiles.get(target_pos.x * 1000 + target_pos.y)
    if tile == null or tile.outpost_level == 0 or tile.outpost_owner != pt_id:
        return { "ok": false, "msg": "目標非自家 outpost" }
    # 走 diplomatic_ai 評估
    var resp: String = _diplomatic.handle_diplomacy_message(state, tgt, pt, "invite_settle")
    if resp == "accept":
        _execute_settlement(state, target_id, target_pos, pt.faction_id)
        return { "ok": true, "msg": "Team%d 接受邀請" % target_id }
    else:
        return { "ok": true, "msg": "Team%d 拒絕邀請" % target_id }
```

### `_execute_settlement`（合併 / 新居民）

```gdscript
func _execute_settlement(state, team_id, outpost_pos, faction_id):
    var t: TeamData = state.teams[team_id]
    t.tile_pos = outpost_pos
    t.tags = ["生產"]   # 強制變生產
    t.faction_id = faction_id
    t.current_task = "生產"
    t.move_target = Vector2i(-1, -1)
    # 若該 outpost 已有 PRODUCE team → 合併
    var existing: int = _find_existing_resident(state, outpost_pos)
    if existing != -1 and existing != team_id:
        var existing_team: TeamData = state.teams[existing]
        var cap: int = _outpost_pop_cap(state, outpost_pos)
        if existing_team.population + t.population > cap:
            return { "ok": false, "msg": "pop 將超 cap" }
        # 合併：取統領最高為 leader
        SubteamSystem.new().merge_teams(state, existing, team_id, t.named_members)
```

### NPC 發 invite_settle

`faction_ai_system` 在 PRODUCE pop < cap × 0.5 + 同 faction 內有獨立流民時，可主動發 invite_settle（簡化版）：

```gdscript
# evaluate_all 內 PRODUCE team check
if team.tags.has("生產") and team.population < cap * 0.5:
    var roving_id = _find_nearby_roving(state, team)
    if roving_id != -1:
        _diplomatic.send_diplomacy_message(state, owner_team, state.teams[roving_id], "invite_settle")
```

### diplomatic_ai 評估接受

新 message type `invite_settle`：

```gdscript
"invite_settle":
    var accept_score = leader.values.get("求生欲", 0.5) \
        + clampf(rep_with_inviter - 0.5, -0.5, 0.5) \
        + (0.3 if float(team.resources.get("food", 0)) < team.population * 7.0 else 0.0) \
        - leader.values.get("野心", 0.5) * 0.4
    if accept_score > 0.5:
        return "accept"
    return "refuse"
```

## 起義機制（faction_ai 評估）

無新 event 檔。在 `faction_ai_system.evaluate_all` 加：

```gdscript
# team loop 內，PRODUCE 限定
if team.tags.has("生產"):
    _evaluate_uprising(state, team)
```

### `_evaluate_uprising`

```gdscript
func _evaluate_uprising(state, team):
    if team.current_task == "起義": return
    if team.current_task in SURVIVAL_TASKS: return
    var avg_loy: float = _avg_named_loyalty(state, team)
    if avg_loy >= 0.2: return
    if team.unrest_turns < 60: return
    var stress_sources: int = _count_stress_sources(state, team)
    if stress_sources < 2: return
    # 觸發起義
    var old_owner_id: int = _get_outpost_owner(state, team.tile_pos)
    team.faction_id = -1
    team.tags = ["流亡"]
    team.current_task = "起義"
    team.move_target = Vector2i(-1, -1)   # 暫不動
    _msg.emit_message(state, "uprising",
        "Team%d 居民起義！" % team.team_id, team,
        { "origin": str(team.team_id), "old_owner": str(old_owner_id) })
    # 對原 owner 寫 enemy memory
    if old_owner_id != -1:
        var leader = state.persons.get(team.leader_id)
        if leader: _npc_ai.write_memory(leader, "enemy", old_owner_id,
            state.world.current_tick, 1.0)
    # 鄰格 PRODUCE team cascade fear
    _cascade_uprising_fear(state, team.tile_pos)
    # 若玩家是 owner → forced event
    if old_owner_id != -1 and state.teams[old_owner_id].leader_id == state.player_id:
        state.player_forced_event = {
            "from_id": team.team_id, "action": "uprising_alert",
            "outpost_pos": team.tile_pos,
        }
```

### Helper functions

```gdscript
func _avg_named_loyalty(state, team) -> float:
    var sum: float = 0.0
    var cnt: int = 0
    for pid in ([team.leader_id] as Array) + team.named_members:
        var p = state.persons.get(pid)
        if p:
            sum += p.loyalty
            cnt += 1
    return sum / maxf(cnt, 1)

func _count_stress_sources(state, team) -> int:
    var sources: int = 0
    if team.tax_rate > 0.5: sources += 1
    if float(team.resources.get("food", 0)) < team.population * 7.0: sources += 1
    if team.unrest_turns > 40: sources += 1
    # 鄰格戰火/被劫（檢查最近 N tick encounter history）
    if _recent_warfare_near(state, team.tile_pos): sources += 1
    return sources

func _cascade_uprising_fear(state, origin_pos):
    for tid in state.teams:
        var t: TeamData = state.teams[tid]
        if not t.tags.has("生產"): continue
        if _hex_dist(origin_pos, t.tile_pos) > 2: continue
        for pid in ([t.leader_id] as Array) + t.named_members:
            var p = state.persons.get(pid)
            if p: p.fear = minf(p.fear + 0.1, 1.0)
```

### 起義後行為

起義 team 變流亡 → 走 B spec 的 NPC 生存決策（投奔敵 faction、找空 outpost、被剿等）。

無新 path。

## 失聯判定（intel snapshot + 7 天緩衝）

`faction_ai` 每輪 PRODUCE team check 加：

```gdscript
if team.tags.has("生產"):
    _evaluate_owner_contact(state, team)
```

```gdscript
const CONTACT_TIMEOUT_DAYS: int = 30
const OWNER_CHANGE_BUFFER_DAYS: int = 7

func _evaluate_owner_contact(state, team):
    var owner_id: int = _get_outpost_owner(state, team.tile_pos)
    if owner_id == -1 or not state.teams.has(owner_id):
        return _trigger_defection_evaluation(state, team, "owner_gone")
    var intel: Dictionary = state.team_intel.get(team.team_id, {})
    var snap: Dictionary = intel.get(owner_id, {})
    var last_tick: int = int(snap.get("last_tick", -1))
    var days_since: int = -1
    if last_tick != -1:
        days_since = (state.world.current_tick - last_tick) / WorldState.TICKS_PER_DAY
    # 1. 完全失聯
    if days_since == -1 or days_since > CONTACT_TIMEOUT_DAYS:
        _trigger_defection_evaluation(state, team, "no_contact")
        return
    # 2. 偵測 owner leader 異動 → 7 天緩衝
    var owner_leader_now: int = int(snap.get("leader_id", -1))
    var cached_owner_leader: int = int(team.known_reputations.get("_cached_owner_leader", -2))
    if cached_owner_leader != -2 and cached_owner_leader != owner_leader_now:
        if team.pending_owner_change_tick == -1:
            team.pending_owner_change_tick = state.world.current_tick + OWNER_CHANGE_BUFFER_DAYS * WorldState.TICKS_PER_DAY
        elif state.world.current_tick >= team.pending_owner_change_tick:
            # 7 天後仍無反駁 → 接受變化
            _trigger_defection_evaluation(state, team, "owner_changed")
            team.pending_owner_change_tick = -1
    elif team.pending_owner_change_tick != -1:
        # 變化被反駁 → 取消倒數
        team.pending_owner_change_tick = -1
    team.known_reputations["_cached_owner_leader"] = owner_leader_now
```

注意：用 `known_reputations` dict 暫存 cache 避免新欄位（key 用底線字串避免和 team_id 衝突）。

### `_trigger_defection_evaluation`

依 leader values + memory 自決 a/b/c：

```gdscript
func _trigger_defection_evaluation(state, team, reason):
    var leader = state.persons.get(team.leader_id)
    if leader == null: return
    var honor: float = float(leader.values.get("義氣", 0.5))
    var prudence: float = float(leader.values.get("慎重", 0.5))
    var ambition: float = float(leader.values.get("野心", 0.5))
    # 計分（a/b/c）
    var a_score = honor + _has_memory_type(leader, "benefactor") * 0.3
    var b_score = prudence + _fear_of_strongest_neighbor(state, team)
    var c_score = ambition - honor * 0.3
    # 選最高
    if a_score >= b_score and a_score >= c_score:
        _path_follow_original(state, team)        # 留 faction、找新 owner family
    elif b_score >= c_score:
        _path_surrender_conqueror(state, team)    # 投降強鄰
    else:
        _path_become_independent(state, team)     # faction=-1
```

各 path 細節（簡化）：
- `_path_follow_original`：team.faction_id 維持，task=等待新 owner
- `_path_surrender_conqueror`：team.faction_id = 強鄰 faction，emit propose_alliance
- `_path_become_independent`：team.faction_id = -1, tags 保留生產

## 子隊安撫（既有 dispatch + 新 task "安撫"）

`subteam_system.dispatch` 可指定 task="安撫"。安撫子隊到達居民 tile 後：

```gdscript
# interaction_system._resolve_pair 加判斷
if a.current_task == "安撫" and b.tags.has("生產"):
    _resolve_pacify(state, a, b)
elif b.current_task == "安撫" and a.tags.has("生產"):
    _resolve_pacify(state, b, a)
```

```gdscript
func _resolve_pacify(state, pacifier, village):
    # 每 tick 同 tile 駐留 → stress 降、loyalty 升
    for pid in ([village.leader_id] as Array) + village.named_members:
        var p = state.persons.get(pid)
        if p:
            p.stress = maxf(p.stress - 0.05, 0.0)
            p.loyalty = minf(p.loyalty + 0.02, 1.0)
    village.unrest_turns = maxi(village.unrest_turns - 1, 0)
```

## 不變量

- PRODUCE team 永遠 tile_pos == 某 outpost 位置（除非 task in ["逃跑", "投靠", "起義", "遷徙"]）
- pop cap = outpost level cap，超過 → 既有 overflow → 流亡
- 起義後 team.faction_id = -1, tags 含 "流亡"
- 收稅後若 tax_rate > 0.5，team.unrest_turns 累加
- snapshot 緩衝 7 天內任何反駁訊息 → pending_owner_change_tick = -1

## 測試

`headless_test.gd` 加：

1. **PRODUCE team movement 鎖定**：設 task=生產 → movement skip
2. **PRODUCE pop cap by outpost**：L1 outpost → cap=20，超過觸發 overflow
3. **invite_settle 接受**：求生欲高 target → accept、tags 變生產
4. **invite_settle 拒絕**：野心高 target → refuse
5. **多移民合併**：兩 team 都到同 outpost → merge_teams 觸發、最高統領為 leader
6. **收稅重稅後果**：rate=0.7 收稅 → village named NPCs stress 升
7. **起義觸發條件**：avg_loyalty<0.2 + unrest_turns>60 + 2 stress sources → uprising
8. **起義行為**：team.faction_id=-1、tags=["流亡"]、emit uprising message
9. **起義 cascade fear**：鄰格 PRODUCE team fear +0.1
10. **失聯 30 天 → 評估自決**：snapshot.last_tick 老 → trigger defection
11. **owner 異動 + 7 天緩衝**：snapshot leader_id 變 → 7 天內反駁 → cancel；7 天後仍變 → trigger
12. **安撫子隊**：dispatch task=安撫 → 同 tile → village stress 降
13. **玩家 forced event**：玩家擁 outpost、居民起義 → forced event 寫入

## 風險

- **大量 helper functions**：`_get_outpost_owner`、`_find_existing_resident`、`_outpost_pop_cap`、`_recent_warfare_near` 等需新增，code 量大
- **重用既有 _resolve_tribute 改 tax_rate** 影響非 PRODUCE 收稅行為 → 加判斷分支防 regression
- **cascade fear** 可能讓「一場起義引發連鎖」過快 → 限制半徑 + 強度 + 冷卻
- **snapshot 緩衝期** 玩家不易理解（為何敵國 7 天前 leader 死了我村還沒反應）→ UI 後續加提示
- **invite_settle 評估公式**過簡 → 後續可加 memory、rep history
- **起義後續沒新 task**，靠 B spec 生存決策。若 B 失敗 → 居民團無頭蒼蠅

## 解決的 known_issues

- **所有有 outpost 的 team 離家資源匱乏**（不限商隊，涵蓋軍隊出征、商隊跑商、宗教朝聖等場景）
- coin 收入來源：透過收稅 + 居民產出（food + material + coin）
- 「農民」遊戲核心無實體 → 補上
- outpost owner 不在無人產資源 → 居民解決

## 後續延伸

- 攻佔 outpost 系統（D） → 居民隨之轉手
- 升級 outpost：影響 pop cap + 增加 farming/manufacturing slot
- 商隊 inventory（A） → 居民可採購商隊商品
- 玩家 UI：稅率 slider、居民忠誠儀表板、起義警報視覺
- aid 系統（B 後續）→ 居民可主動 request aid
- coin 稅特定機制：除 food，居民也產 coin 上繳（市集稅）
