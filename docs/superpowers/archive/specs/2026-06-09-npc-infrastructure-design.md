# NPC 基建系統（蓋/升級 outpost + 設施擴建）— Design

> 日期：2026-06-09
> 議題：C — NPC AI 不會主動蓋 / 升級 / 擴建 outpost，戰略停滯

## 背景

當前 `faction_ai_system` / `strategic_ai_system` 沒有任何呼叫 `outpost_system.start_build` / `upgrade`。`start_build` 只在 player command 觸發。

結果：
- NPC 開局有 outpost 就有，沒就沒（依 world_generator）
- 戰略遊戲缺少「擴張領土」自主行為
- 商業 faction 不會擴市集網、軍事 faction 不會築前線堡壘
- 既有 farming/manufacturing 設施擴建機制無 NPC 使用

## 目標

1. NPC faction leader 自主評估蓋新 outpost / 升級既有 / 擴建設施
2. 派子隊執行（task="建造"/"升級"/"擴建"）
3. Data-driven 設施註冊（`FACILITY_DEF` const），未來加新設施不改 AI 主邏輯
4. 玩家可手動 `upgrade_outpost` + `build_facility`（補既有 player_command）
5. 副官系統可向玩家 leader 建議蓋哪
6. 蓋完 outpost NPC 自動派人安頓（連動 E spec 居民系統）
7. 起義中 outpost cancel construction
8. 獨立 team 也可蓋（faction 不變）

## 不在範圍

- 新設施類型（城牆 / 市集 / 廟宇 / 礦坑 / 學校 / 港口 / 兵營）→ 後續「設施擴充包」spec
- outpost 建造期間擾民 stress → 後續優化
- AI 蓋 outpost 路線規劃（pathing）→ 連動速度評估系統 spec
- 玩家立國（establish_faction）→ 既有不動
- 升級 outpost 期間居民流失 → 後續

## 架構

### 1. FACILITY_DEF 註冊表（在 outpost_system 或 facility_system）

```gdscript
const FACILITY_DEF: Dictionary = {
    "farming": {
        "cost":             { "material": 30, "coin": 0, "ticks": 50 },
        "cap_by_outpost":   { "civilian": [1, 2, 3], "military": [0, 0, 0] },
        "category":         "生產",
        "trigger_check":    "_check_food_shortage",
        "leader_pref":      { "慎重": 0.3, "野心": -0.1 },
        "current_level_key": "farming_level",
    },
    "manufacturing": {
        "cost":             { "material": 60, "coin": 20, "ticks": 100 },
        "cap_by_outpost":   { "civilian": [0, 1, 3], "military": [0, 0, 0] },
        "category":         "經濟",
        "trigger_check":    "_check_goods_shortage",
        "leader_pref":      { "野心": 0.2, "貪婪": 0.3 },
        "current_level_key": "manufacturing_level",
    },
}
```

新設施未來加 entry 即可（+ 寫 `_check_*` 函數 + 在某 system 實作效果）。

### 2. NPC 基建決策樹（`faction_ai_system._evaluate_infrastructure`）

每 `STRATEGIC_INTERVAL`（10h）跑：

```
For each faction:
    leader_team = faction.leader_team
    if leader_team is null or leader is player: skip (副官 path)
    
    # 優先順序
    # (1) 升級既有 outpost level (L1→L2→L3)
    candidate_upgrade = _evaluate_outpost_upgrade(faction)
    
    # (2) 擴建設施 (FACILITY_DEF iter, score by trigger + leader_pref)
    candidate_facility = _evaluate_facility(faction)
    
    # (3) 蓋新 outpost (戰略擴張)
    candidate_new = _evaluate_new_outpost(faction)
    
    # 依 priority 數值選最高
    best = max(upgrade=120, facility=80~150, new=60~100)
    if best.score > MIN_PRIORITY:
        _dispatch_builder(...)
```

### 3. 三種 dispatch

#### `_dispatch_builder` (蓋新 outpost)

```gdscript
func _dispatch_builder(state, leader_team, target_pos, outpost_type, level):
    var cost = OutpostSystem.BUILD_COST[outpost_type][level - 1]
    # 1.5x 安全餘量
    for k in cost:
        if leader_team.resources.get(k, 0) < cost[k] * 1.5: return false
    var advisor_id = _pick_advisor(leader_team)
    if advisor_id == -1: return false
    var pop = max(10, level * 5)
    if leader_team.population < pop * 2: return false   # leader 不能空
    SubteamSystem.new().dispatch(state, leader_team.team_id, advisor_id,
        pop, "建造", target_pos, { "build_type": outpost_type, "level": level })
    return true
```

#### `_dispatch_upgrader` (升級 outpost level)

```gdscript
func _dispatch_upgrader(state, owner_team, outpost_pos, target_level):
    var tile = state.world.tiles[...]
    if tile.outpost_owner != owner_team.team_id: return false
    var cost = OutpostSystem.BUILD_COST[tile.outpost_type][target_level - 1]
    # 檢查資源、派子隊 task=升級
    ...
    SubteamSystem.new().dispatch(state, owner_team.team_id, advisor_id,
        5, "升級", outpost_pos, { "target_level": target_level })
```

#### `_dispatch_facility_builder` (擴建設施)

```gdscript
func _dispatch_facility_builder(state, owner_team, outpost_pos, facility_type):
    var def = FACILITY_DEF[facility_type]
    var cost = def.cost
    # 檢查資源
    ...
    SubteamSystem.new().dispatch(state, owner_team.team_id, advisor_id,
        3, "擴建", outpost_pos, { "facility_type": facility_type })
```

### 4. 子隊抵達觸發（`interaction_system` 或 `subteam_system` arrival callback）

子隊抵達 target_pos 時依 task 觸發：

```gdscript
match subteam.current_task:
    "建造":
        var extra = subteam.task_extra_data
        OutpostSystem.new().start_build(subteam, extra.build_type, extra.level)
    "升級":
        OutpostSystem.new().start_build(subteam, tile.outpost_type, subteam.task_extra_data.target_level)
    "擴建":
        OutpostSystem.new().upgrade(subteam, subteam.task_extra_data.facility_type)
    "安頓":
        # E spec 既有 _convert_to_resident
```

新欄位 `TeamData.task_extra_data: Dictionary = {}`（已暗用，需明文加）。

### 5. 蓋 location 選擇（B+D 之前討論）

```gdscript
func _evaluate_new_outpost_location(state, faction):
    var leader_team = state.teams[faction.leader_team_id]
    var candidates = []
    # 鄰 5 hex 內掃描
    for tile in _get_nearby_empty_tiles(state, leader_team.tile_pos, 5):
        var score = _score_outpost_location(state, leader_team, tile)
        if score > MIN_BUILD_SCORE:
            candidates.append({ "pos": tile.tile_pos, "score": score })
    candidates.sort_custom(by score desc)
    return candidates[0] if candidates else null

func _score_outpost_location(state, leader_team, tile):
    var score = tile.productivity * 100
    score += TERRAIN_BONUS.get(tile.terrain, 0)
    var dist_own = _min_dist_to_own_outpost(state, leader_team, tile.tile_pos)
    score -= dist_own * 5
    score += clamp(10 - dist_own, 0, 10) * 2
    var dist_enemy = _min_dist_to_enemy_outpost(state, leader_team, tile.tile_pos)
    score -= max(0, 5 - dist_enemy) * 10   # 太近敵
    if _has_rare_resource(tile):
        score += 50
    return score
```

### 6. Outpost 類型選擇（依 leader 個性）

```gdscript
func _pick_outpost_type(leader):
    var military_score = leader.values.get("好戰", 0.5) + leader.values.get("野心", 0.5)
    var civilian_score = leader.values.get("慎重", 0.5) + leader.values.get("貪婪", 0.5)
    return "military" if military_score > civilian_score else "civilian"
```

### 7. 副官建言（玩家 leader 時）

```gdscript
func _evaluate_infrastructure(state, faction):
    var leader_team = state.teams[faction.leader_team_id]
    if leader_team.leader_id == state.player_id:
        # 副官 path
        AdvisorSystem.new().push_outpost_advice(state, leader_team, _calc_best_candidates(state, faction))
        return
    # NPC path: 直接執行
    ...
```

`AdvisorSystem.push_outpost_advice`：依副官個性給 tone 不同建議。

### 8. 蓋完 outpost 自動安頓（連動 E spec）

`outpost_system.start_build` 完工時 callback：

```gdscript
# outpost_system 完工 trigger
func _on_construction_complete(state, team, tile):
    tile.outpost_owner = team.team_id
    # 若為新蓋 outpost（非升級），且 builder team 是子隊（parent != -1）
    if team.parent_team_id != -1:
        # 通知 parent: 自動派人來安頓
        var parent = state.teams[team.parent_team_id]
        _auto_dispatch_settler(state, parent, tile.tile_pos, tile.outpost_type)
```

`_auto_dispatch_settler` 從 parent 撥子隊 task="安頓"。

玩家 leader：不自動，玩家自決。

### 9. 起義 cancel construction（連動 D spec）

`faction_ai._evaluate_uprising` 觸發 Path A/B 時加：

```gdscript
# 若 outpost 在建造中 → cancel
var tile = state.world.tiles[...]
if tile.construction_target != {}:
    tile.construction_target = {}
    tile.construction_progress = 0
    print("[Uprising] 起義中斷 outpost 建造")
```

### 10. 獨立 team 蓋 outpost

獨立 team（faction=-1）可走同樣 `_evaluate_infrastructure` path：
- 不在 faction 框架內，直接 team 自決
- 條件較嚴：team.resources >= cost × 2.0、team.population >= 15
- 蓋完 outpost owner = self，faction 仍 -1（不立國）

獨立 NPC 較少蓋 outpost（資源不足），但允許。

## 新欄位

```gdscript
# TeamData
var task_extra_data: Dictionary = {}   # 子隊任務附加數據（build_type, level, facility_type 等）
```

## 玩家新 actions

### `upgrade_outpost`

```gdscript
"upgrade_outpost": _action_upgrade_outpost,

func _action_upgrade_outpost(state, _target, pt, pt_id):
    var pos = Vector2i(pt.tile_pos)   # 必在自家 outpost
    var tile = state.world.tiles.get(pos.x * 1000 + pos.y)
    if tile == null or tile.outpost_level == 0:
        return { "ok": false, "msg": "目標無 outpost" }
    if tile.outpost_owner != pt_id:
        return { "ok": false, "msg": "非自家 outpost" }
    if tile.outpost_level >= 3:
        return { "ok": false, "msg": "已滿級" }
    var target_level = tile.outpost_level + 1
    var result = OutpostSystem.new().start_build(pt, tile.outpost_type, target_level)
    return result
```

### `build_facility`

```gdscript
"build_facility": _action_build_facility,

func _action_build_facility(state, _target, pt, pt_id):
    var facility = state.player_state.get("facility_type", "farming")
    if not OutpostSystem.FACILITY_DEF.has(facility):
        return { "ok": false, "msg": "未知 facility" }
    var pos = pt.tile_pos
    var tile = state.world.tiles.get(pos.x * 1000 + pos.y)
    if tile == null or tile.outpost_owner != pt_id:
        return { "ok": false, "msg": "非自家 outpost" }
    var result = OutpostSystem.new().upgrade(pt, facility)
    return result
```

## 不變量

- NPC 蓋 outpost 前 leader_team 資源 ≥ cost × 1.5
- 子隊抵達後資源不足 → 不執行（task 重置 idle）
- 玩家 leader 不被 forced event 推銷 outpost（副官 path）
- 蓋完 outpost 立即 emit message（透過 outpost_system 既有）
- 同類型最小距離 11、任意類型距離 2（既有 outpost_system 規則）

## 測試

`headless_test.gd`：

1. **FACILITY_DEF 註冊**：has farming + manufacturing entries
2. **NPC 蓋新 outpost**：建 faction + 資源充足 → 跑 strategic AI → 派子隊 task=建造
3. **子隊抵達觸發建造**：subteam task=建造 + position → start_build 被呼叫
4. **NPC 升級 outpost L1→L2**：自家 outpost + 資源 → 派子隊 task=升級
5. **NPC 擴建 farming**：civilian L2 outpost + 缺糧 → 派子隊 task=擴建
6. **副官建言路徑**：玩家 leader + 候選 → push to advisor messages
7. **玩家 upgrade_outpost action**：自家 L1 + 資源 → start_build(2)
8. **玩家 build_facility action**：自家 civilian L1 + farming cap=1 → upgrade farming
9. **蓋完自動安頓**：NPC 蓋完 → 自動派子隊 task=安頓
10. **起義 cancel construction**：起義時 outpost 進度歸 0
11. **獨立 team 蓋 outpost**：faction=-1 + 資源足 → 可蓋，shareholding 不變
12. **資源不足不蓋**：leader_team 庫存 < cost × 1.5 → 不派

## 風險

- **strategic_ai vs faction_ai 衝突**：兩處可能評估蓋 outpost，要選哪個放 → 建議放 faction_ai（更頻繁、reactive）
- **子隊 task_extra_data 序列化**：JSON 設定無 task_extra_data 欄位，但需用到 → 需在 dispatch API 加參數
- **callback `_on_construction_complete`**：既有 outpost_system 是否有 hook? 需檢查
- **獨立 team 蓋 outpost**：可能造成地圖滿是小 outpost → 加 cooldown / 全局上限
- **副官建言頻率**：每 STRATEGIC_INTERVAL 推一次可能太煩 → 加冷卻

## 解決的 known_issues

- NPC 不會主動蓋 outpost → 戰略停滯
- NPC 不會升級 / 擴建設施 → 經濟發展停滯
- 玩家無 `upgrade_outpost` / `build_facility` action

## 後續延伸

- **設施類型擴充包**（spec）：城牆 / 市集 / 廟宇 / 礦坑 / 學校 / 港口 / 兵營 / 競技場
- **建造期間擾民 stress** 細節
- **獨立 team 蓋 outpost cooldown / 上限**
- **AI 戰略長期規劃**：殖民、補給路線、領土合併
- **prosperity 評分**：依 NPC 領土完善度給 faction score
