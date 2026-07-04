# Outpost 居民派駐 AI — Design

> 日期：2026-06-11
> 議題：trade 接公庫已實作，但 multi 配置中沒「PRODUCE+在 outpost」的居民團 → 沒人 absorb 公庫 → trade 成交 0。需 NPC AI 主動派駐居民 / 招募流民填補 outpost。

## 不變量

- 子隊安頓後 = SUBTEAM + PRODUCE dual tag（暫時派駐，流民替代後可 try_merge_back 回母團）
- 居民鎖規則保留（PRODUCE+在自家 faction outpost → 不可主動移動，例外白名單既有）
- 既有 `_auto_settle_builder`（建造子隊完工 → 永久居民）行為不變
- `invite_settle` 既有玩家命令路徑保留，本 spec 新增 NPC AI 自動觸發

## 目標

1. `faction_ai` 加 `_evaluate_outpost_residency`：3 天 cadence，自家 outpost 沒居民團 → 依 owner leader 個性選派駐管道
2. 管道 A：dispatch subteam（既有 subteam_system + 新 settle 行為）
3. 管道 B：NPC 自動 invite_settle 視野內流亡團（既有 diplomatic_ai 套用）
4. 流民駐紮 → 既有子隊（SUBTEAM+PRODUCE）try_merge_back 回母團

## 設計

### 觸發

```gdscript
const RESIDENCY_CADENCE: int = 720   # 3 天
const RESIDENCY_COOLDOWN: int = 1680  # 7 天（失敗後）

func _evaluate_outpost_residency(state: WorldState, team: TeamData) -> void:
    if state.world.current_tick < team.residency_eval_next_tick: return
    team.residency_eval_next_tick = state.world.current_tick + RESIDENCY_CADENCE
    var leader: PersonData = state.persons.get(team.leader_id)
    if leader == null: return
    # 找自家 outpost 沒居民團的
    for tile_id in state.world.tiles:
        var tile: HexTileData = state.world.tiles[tile_id]
        if tile.outpost_owner != team.team_id: continue
        if _has_resident_team(state, tile): continue
        _try_dispatch_or_invite(state, team, tile, leader)

func _has_resident_team(state: WorldState, tile: HexTileData) -> bool:
    for tid in state.teams:
        var t: TeamData = state.teams[tid]
        if t.tile_pos != tile.tile_pos: continue
        if "生產" in t.tags: return true
    return false
```

### 個性選擇管道

```gdscript
func _try_dispatch_or_invite(state, team, tile, leader) -> void:
    var ambition: float = float(leader.values.get("野心", 0.5))
    var military: float = float(leader.values.get("好戰", 0.5))
    var commerce: float = float(leader.skills.get("商業", 0.0))
    var caution: float = float(leader.values.get("慎重", 0.5))
    var dispatch_score: float = ambition * 0.5 + military * 0.3
    var invite_score: float = commerce * 0.4 + caution * 0.3
    if dispatch_score > invite_score and team.population >= 8:
        _dispatch_subteam_settle(state, team, tile)
    else:
        _try_invite_nearby_exile(state, team, tile)
```

### A：派子隊安頓

```gdscript
func _dispatch_subteam_settle(state, owner, tile) -> void:
    var settler_count: int = clampi(owner.population / 4, 2, 5)
    if owner.population < settler_count + 1: return   # 留至少 1 人在母團
    # leader 來源
    var leader_id: int = -1
    if owner.named_members.size() > 2:
        leader_id = owner.named_members[0]   # 抽一個 named
        owner.named_members.erase(leader_id)
    else:
        # PersonGenerator 升 anon
        var new_leader: PersonData = PersonGenerator.generate_for_team(
            state, owner, "member")
        if new_leader != null:
            leader_id = new_leader.id
    if leader_id == -1: return
    # 建子隊
    var subteam: TeamData = SubteamSystem.new().dispatch(
        state, owner, settler_count, leader_id)
    if subteam == null: return
    subteam.tags = ["子團"]   # SUBTEAM tag，settle 後加 PRODUCE
    subteam.current_task = "安頓"
    subteam.move_target = tile.tile_pos
    print("[Residency] Team%d 派子隊 Team%d 安頓 outpost (%d,%d) pop=%d" % [
        owner.team_id, subteam.team_id, tile.tile_pos.x, tile.tile_pos.y, settler_count])
```

子隊抵達 outpost tile → `_try_interact` 路徑既有 `"安頓"` task handler → 加 PRODUCE tag → 變居民團（但保 SUBTEAM tag）。

### B：invite 流亡

```gdscript
func _try_invite_nearby_exile(state, team, tile) -> void:
    # 視野內找流亡 team
    for tid in state.team_discovered.get(team.team_id, []):
        var t: TeamData = state.teams.get(tid)
        if t == null: continue
        if not ("流亡" in t.tags): continue
        if state.world.current_tick < team.invite_cooldown.get(tid, 0): continue
        # 透過 diplomatic_ai 發 invite_settle
        var resp: String = DiplomaticAiSystem.new().handle_diplomacy_message(
            state, t, team, "invite_settle")
        if resp == "accept":
            t.current_task = "安頓"
            t.move_target = tile.tile_pos
            print("[Residency] Team%d 邀請 Team%d 安頓 outpost" % [
                team.team_id, tid])
            return
        team.invite_cooldown[tid] = state.world.current_tick + RESIDENCY_COOLDOWN
```

### 流民駐紮 → 子隊 merge_back

interaction_system `_settle` 既有處理。新加：若 tile 已有 SUBTEAM+PRODUCE 子隊，新流民安頓後 trigger 子隊 try_merge_back 回母團：

```gdscript
# _settle 結尾
var existing_subteam_resident: TeamData = _find_subteam_resident(state, tile)
if existing_subteam_resident != null:
    SubteamSystem.new().try_merge_back(state, existing_subteam_resident.team_id)
```

### 新欄位

`team_data.gd`：

```gdscript
var residency_eval_next_tick: int = 0
var invite_cooldown: Dictionary = {}   # { tid: tick_until }
```

## 測試

1. **自家 outpost 沒居民團 → 觸發評估**
2. **野心高 + pop 夠 → 派子隊**
3. **商業/慎重高 → invite 流亡**
4. **流亡 accept → 走過去安頓**
5. **流亡 reject → cooldown 7 天**
6. **流民駐紮 → 既有子隊 merge_back 回母團**
7. **outpost 已有居民團 → 不重複派**
8. **multi 4 config × 90 天：trade 成交 > 0**

## 風險

- **派子隊掏空 owner team**：max 5 + 至少留 1，但仍可能弱化母團
- **invite spam**：cooldown 7 天，但多 outpost 可能同時邀同一流亡
- **子隊抵達前 leader 死亡**：subteam_system 既有 fallback？需驗
- **流民 accept 機率**：diplomatic_ai 邏輯，可能太嚴拒大多
- **trade 成交達標但配置仍依賴 multi 隨機性**：若 NPC AI 不夠積極派駐，trade 仍可能少
