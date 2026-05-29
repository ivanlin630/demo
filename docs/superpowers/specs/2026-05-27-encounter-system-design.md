# 遭遇戰系統 Design

## 依賴

本 spec 依賴：
- `2026-05-27-data-structure-update-design.md`（equipment 8 格、armor_config、arrows）
- `2026-05-27-day-night-cycle-design.md`（夜間視野減半）

---

## Goal

定義遭遇戰的觸發、地圖、時間整合、NPC 個人單位行為、裝備分配、俘虜、傳令兵、撤退機制。**僅玩家參與的衝突進入遭遇戰**；純 NPC 衝突維持大地圖快速結算。

---

## 1. 觸發條件

- 玩家所在 team 與另一 team 在同一 tile 發生衝突（InteractionSystem 判定）
- 衝突類型：攻擊、追擊、伏擊
- 觸發後暫停 SimRunner 大地圖 tick，啟動 EncounterSystem

---

## 2. 地圖規格

- **六角形地圖**，邊長 10 格（含邊：271 個 hex）
- Hex 座標系：offset-q（flat-top）
- 地形與障礙物：繼承大地圖 tile 地形，隨機生成額外障礙物（樹木/岩石）
- 每 hex 可有 0/1 個障礙物（blocking 或 cover）

### Hex 距離

```gdscript
func hex_dist(a: Vector2i, b: Vector2i) -> int:
    var dx := b.x - a.x; var dy := b.y - a.y
    return (abs(dx) + abs(dx + dy) + abs(dy)) / 2
```

---

## 3. 進場位置

### 一般交戰

- 雙方各從對側邊緣進入（3 列深）
- 先手方選邊；後手方放對側

### 追擊戰

- **被追方**放地圖中央（3×3 hex 範圍內隨機）
- **追擊方**從連續三條邊進入（每次方向輪換，避免固定化）
- 輪換序列：`[上、右上、右、下右、下、下左、左、左上]`（每場 +2）

```gdscript
var pursuit_edge_offset: int = 0   # WorldState 記錄，每場 +2 mod 8

func _get_pursuit_entry_edges(offset: int) -> Array:
    # 返回 3 條連續邊的索引（0–7 共 8 個方向區段）
    return [(offset) % 8, (offset + 1) % 8, (offset + 2) % 8]
```

### 援軍進場

大地圖上援軍從哪個方向抵達遭遇戰 tile，就從遭遇戰地圖對應方向的邊緣進入。

```gdscript
# 大地圖 hex 6 方向 → 遭遇戰地圖邊緣索引（0=上, 1=右上, 2=右下, 3=下, 4=左下, 5=左上）
const WORLD_DIR_TO_EDGE: Dictionary = {
    Vector2i( 0, -1): 0,   # 北
    Vector2i( 1, -1): 1,   # 東北
    Vector2i( 1,  0): 2,   # 東南
    Vector2i( 0,  1): 3,   # 南
    Vector2i(-1,  1): 4,   # 西南
    Vector2i(-1,  0): 5,   # 西北
}

func get_reinforcement_entry_edge(
        encounter_tile: Vector2i, reinforcement_tile: Vector2i) -> int:
    var delta: Vector2i = encounter_tile - reinforcement_tile
    # 正規化為 6 方向之一
    var best_edge: int = 0
    var best_dot: float = -99.0
    for dir in WORLD_DIR_TO_EDGE:
        var dot: float = float(delta.x * dir.x + delta.y * dir.y)
        if dot > best_dot:
            best_dot = dot
            best_edge = WORLD_DIR_TO_EDGE[dir]
    return best_edge
```

援軍在遭遇戰地圖對應邊緣隨機選 3 個 hex 進場（與一般進場同規則）。

---

## 4. 時間整合

- 遭遇戰每回合 = 1 大地圖 tick
- SimRunner 在遭遇戰進行中不推進大地圖 tick
- 遭遇戰結束（撤退/殲滅/投降）後：
  - 結算傷亡、俘虜
  - 更新雙方 team population/named_members
  - **負面狀態結算**（**雙方**所有進入遭遇戰的成員，優先順序由重到輕）：
    - 各方用**自己 team 的資源**結算（medicine/tools）
    1. `bleeding_major` → 消耗 medicine ×2 清除；不足 → 醫療技能判定；仍不足 → 一次扣 blood 大量（`blood = maxf(blood - deduct, 1.0)`）→ 清除 flag
    2. `bleeding_minor` → 消耗 medicine ×1；不足 → 技能判定；仍不足 → 一次扣 blood 少量（同底線）→ 清除 flag
    3. `poisoned` → 消耗 medicine ×3；不足 → 技能判定；仍不足 → 一次扣各部位 HP（`hp = maxf(hp - deduct, 1.0)`）→ 清除 flag
    4. `fracture` → 消耗 tools ×1；不足 → **保留 flag 帶入大地圖**（唯一持續負面狀態）
    - 底線規則：blood 最低 1、部位 hp 最低 1（結算本身不殺人，留臨界狀態）
  - **匿名成員結算**（無 PersonData，轉回 team pool）：
    1. `status == dead`（torso critical 判定失敗）→ `team.population -= N`
    2. 有 `bleeding` → 按比例消耗 `team.resources["medicine"]`；不足 → 未治療比例加入 `team.wounded`
    3. 有 `fracture` → 直接加入 `team.wounded`（不帶入大地圖）
    4. 有 `poisoned` → 一次扣 HP 重算 status → 再按 status 計入 wounded/dead
    5. 其餘存活但 status != healthy → 加入 `team.wounded`
  - 大地圖骨折治療：玩家物品欄 → tools 使用 → 選目標部位 → fracture = false
  - 恢復 SimRunner 推進

---

## 5. 個人單位

**所有成員一人一 unit**，含具名 NPC 與匿名成員。

### 具名 NPC unit

直接引用 PersonData，body_parts 在遭遇戰中實時更新：

```gdscript
# EncounterUnit（遭遇戰臨時結構，不存入 WorldState）
{
    "person_id": int,       # 具名 NPC：對應 PersonData；匿名：-1
    "team_id": int,
    "pos": Vector2i,
    "stamina": float,       # 0.0–1.0，受 team.fatigue 上限限制
    "is_messenger": bool,
    "has_exited": bool,     # 已撤退出地圖
    # 具名 NPC 無 body_parts 欄位，直接讀 state.persons[person_id].body_parts
    # 匿名 NPC 有臨時 body_parts（見下）
    "body_parts": Dictionary,   # 僅匿名 NPC 使用
}
```

死亡與戰鬥不能判斷（分開處理）：

| 狀態 | 條件 | 後果 |
|---|---|---|
| **死亡** | torso == `"severed"` | 從地圖移除，裝備掉落/歸還 |
| **戰鬥不能** | torso == `"critical"`，或兩腿皆 `"critical"` | 原地無法行動，仍存活；可被俘虜 |

```gdscript
func _get_body_parts(unit: Dictionary, state: WorldState) -> Dictionary:
    if unit["person_id"] != -1:
        var p: PersonData = state.persons.get(unit["person_id"])
        return p.body_parts if p else {}
    return unit["body_parts"]

func is_dead(unit: Dictionary, state: WorldState) -> bool:
    var bp := _get_body_parts(unit, state)
    return bp.get("torso", {}).get("status", "healthy") == "severed"

func is_combat_capable(unit: Dictionary, state: WorldState) -> bool:
    if is_dead(unit, state): return false
    var bp := _get_body_parts(unit, state)
    if bp.get("torso", {}).get("status", "healthy") == "critical": return false
    var legs_critical: int = 0
    if bp.get("right_leg", {}).get("status") == "critical": legs_critical += 1
    if bp.get("left_leg",  {}).get("status") == "critical": legs_critical += 1
    if legs_critical >= 2: return false   # 兩腿皆重傷，無法移動/攻擊
    return true
```

攻擊選部位：
- 玩家：UI 選擇目標部位（預設 torso）
- AI：依技能/策略選部位（高戰術→腿部牽制；一般→torso）

### 匿名成員 unit

無 PersonData，臨時生成通用屬性：

```gdscript
func _create_anon_unit(team: TeamData, pos: Vector2i) -> Dictionary:
    return {
        "person_id": -1,
        "team_id": team.team_id,
        "pos": pos,
        "stamina": 1.0 - team.fatigue,
        "is_messenger": false,
        "has_exited": false,
        "body_parts": {
            # 完整格式（對齊 health-system-design 定義）
            "head":      { "hp": 20.0, "max_hp": 20.0, "status": "healthy", "poisoned": false, "bleeding": "none", "fracture": false },
            "torso":     { "hp": 50.0, "max_hp": 50.0, "status": "healthy", "poisoned": false, "bleeding": "none", "fracture": false },
            "right_arm": { "hp": 25.0, "max_hp": 25.0, "status": "healthy", "poisoned": false, "bleeding": "none", "fracture": false },
            "left_arm":  { "hp": 25.0, "max_hp": 25.0, "status": "healthy", "poisoned": false, "bleeding": "none", "fracture": false },
            "right_leg": { "hp": 30.0, "max_hp": 30.0, "status": "healthy", "poisoned": false, "bleeding": "none", "fracture": false },
            "left_leg":  { "hp": 30.0, "max_hp": 30.0, "status": "healthy", "poisoned": false, "bleeding": "none", "fracture": false },
        },
        # 技能依 team 匿名基準值（無個體差異）
        "skills": { "戰鬥": team.get("anon_combat_skill", 0.2) },
    }
```

---

## 6. 裝備分配（遭遇戰前）

### 具名 NPC

遭遇戰前依 `person.equipment` 8 格決定戰鬥能力。若某格為 `"none"` 則從 team pool 臨時借用（優先具名 NPC）：

```gdscript
func _equip_named_npc(p: PersonData, team: TeamData) -> void:
    # 武器：優先裝 hand_1（hand_1/hand_2 無左右區分）
    if p.equipment["hand_1"].get("type", "none") == "none":
        if int(team.resources.get("weapon_melee_low", 0)) > 0:
            p.equipment["hand_1"] = { "type": "pool", "grade": "weapon_melee_low" }
            team.resources["weapon_melee_low"] -= 1
    # torso armor
    if p.equipment["torso"].get("type", "none") == "none":
        var cfg: String = team.armor_config.get("torso", "none")
        if cfg == "low" and int(team.resources.get("armor_low", 0)) > 0:
            p.equipment["torso"] = { "type": "pool", "grade": "armor_low" }
            team.resources["armor_low"] -= 1
        elif cfg == "high" and int(team.resources.get("armor_high", 0)) > 0:
            p.equipment["torso"] = { "type": "pool", "grade": "armor_high" }
            team.resources["armor_high"] -= 1
    # 其他部位類推（head, right_arm, left_arm, right_leg, left_leg）
```

死亡後 pool 裝備歸還 `team.resources[grade]`；unique 裝備掉落（後續 spec 定義）。

### 匿名成員

依 `team.armor_config` 與 team resources 數量平均分配。超過資源數量的匿名成員無裝備。

---

## 7. 箭矢系統

- 遭遇戰開始時：`archer_arrows = team.resources["arrows"] / num_archers`（整除）
- 每次射擊消耗 `ItemAttributes.ARROW_COST_PER_SHOT` 箭（個人追蹤）
- 無箭不可射擊
- 遭遇戰結束：`team.resources["arrows"] -= 遭遇戰總消耗`

---

## 8. 視野系統（迷霧）

### 基礎視野

- 每單位視野半徑：`2 + round(avg_偵查(team) × 2)` hex（TEST VALUE）
- 障礙物阻擋 line-of-sight（使用 ray-cast 檢查）

### 日夜視野差

- 白天：正常視野半徑
- 夜晚：視野半徑 × 0.5（無守夜者時遭遇戰前已進入）
- 黎明/黃昏：視野半徑 × 0.75

### 地形視野修正（觀察者所在地形）

| terrain | 視野乘數 |
|---|---|
| plains | 1.0 |
| forest | 0.6 |
| mountain | 0.8 |

---

## 9. 傳令兵系統

### 戰場內通訊

任意具名 NPC 可執行傳令動作：
- 傳令到同 team 其他單位（距離 ≤ 5 hex，TEST VALUE）
- 接收者執行傳令指令（移動目標/集火目標/撤退）

### 跑出地圖傳令

傳令兵移動至地圖邊緣並標記 `has_exited = true`：
- 離開遭遇戰地圖
- 成為獨立子團（SubteamSystem 處理）
- 可在大地圖 tick 中傳遞訊息至其他 team（MessageSystem）

```gdscript
func _messenger_exit(state: WorldState, unit: Dictionary,
        parent_team: TeamData) -> void:
    unit["has_exited"] = true
    # 建立子團
    var sub := SubteamData.new()
    sub.leader_id = unit["person_id"]
    sub.parent_team_id = parent_team.team_id
    sub.tile_pos = parent_team.tile_pos   # 地圖邊緣對應大地圖位置
    state.subteams[sub.id] = sub
```

---

## 10. 撤退機制

### 個人撤退

- 單位移動至地圖任意邊緣 hex → `has_exited = true`
- 撤退不需要全隊同意（個人可先撤）

### 全隊撤退完成條件

- **所有未死亡單位** `has_exited = true` → 該 team 撤退成功
- 退出後不再參與本場遭遇戰
- 大地圖上被標記為「已交戰，移動懲罰 2 tick」

### AI 撤退判斷

```gdscript
func _should_retreat(unit: Dictionary, state: WorldState,
        team_incapable_ratio: float, p: PersonData) -> bool:
    if team_incapable_ratio > 0.7: return true   # 全隊七成戰鬥不能
    var bp := _get_body_parts(unit, state)
    if bp.get("torso", {}).get("status") == "critical": return true   # 個人瀕危
    if p.values.get("求生欲", 0.5) > 0.7 and team_incapable_ratio > 0.5:
        return randf() < 0.3
    return false
```

---

## 11. 俘虜系統

單位 `is_combat_capable = false`（戰鬥不能，但未死亡）後，每隔 `PRISONER_CHECK_INTERVAL` tick 掃描一次：若鄰近 hex 有 ≥2 敵方 unit → 成為俘虜。

**`PRISONER_CHECK_INTERVAL` TEST VALUE 待定**：需先確認遭遇戰基礎行動速率後再設定。

- 俘虜歸入勝方 team
- 戰後可選：處決 / 外交談判 / 招募
- 處決觸發 `witnessed_atrocity` 記憶（全 named_members）

---

## 12. 戰術 AI（NPC 行為）

每 NPC unit 每行動回合依以下優先序決定行動（行動時間依速度與體力計算 tick 數，非固定 1 tick）：

1. **撤退判斷**（torso critical 或 leader 傳令撤退）→ 朝邊緣移動
2. **傳令任務**（若被指派傳令，優先執行）
3. **護送判斷**（見下方）
4. **集火目標**（有 leader 指定目標 → 優先攻擊）
5. **接近最近敵人**（無指定目標）
6. **技能行動**：
   - 弓手：保持距離 3–5 hex，射擊
   - 近戰：接近並攻擊
   - 醫療：尋找受傷友方，使用 medicine

### 俘虜相關：進攻方 AI

- 目標已戰鬥不能 → 停止攻擊，轉移目標或留在旁邊等俘虜判定
- 若己方數量優勢（敵方 ≤ 自方 × 0.5）：留人看守，其餘繼續戰鬥

### 護送邏輯

**觸發條件**（每 unit 行動時評估）：
- 距離 ≤ `ESCORT_DETECT_RANGE` hex 內有友方戰鬥不能單位（TEST VALUE）
- 自身 `is_combat_capable = true`
- 附近敵方數量 ≤ `ESCORT_MAX_NEARBY_ENEMIES`（TEST VALUE）
- `p.values["義氣"] > 0.4`，或目標為 leader（優先觸發）

**執行**：
- 移動到戰鬥不能者旁（依正常移動速度計算 tick）
- 抵達後每行動攜帶傷者朝邊緣移動（速度 × 0.5，stamina 持續消耗）
- 到達邊緣：兩人一起算撤退成功

**中斷條件**：
- 護送途中被 ≥2 敵包圍 → 放下傷者，依 `_should_retreat` 判斷戰鬥或逃跑；傷者留原地繼續等俘虜判定
- 自身 stamina 耗盡 → 放下傷者，原地休息或撤退

```gdscript
func _should_escort(unit: Dictionary, state: WorldState,
        p: PersonData) -> int:   # 返回傷者 unit index，-1=不護送
    if not is_combat_capable(unit, state): return -1
    var nearby_enemies: int = _count_nearby_enemies(unit, state, 2)
    if nearby_enemies > ESCORT_MAX_NEARBY_ENEMIES: return -1
    if p.values.get("義氣", 0.5) < 0.4: return -1
    # 搜尋附近戰鬥不能友方
    for i in range(state.encounter_units.size()):
        var target := state.encounter_units[i]
        if target["team_id"] != unit["team_id"]: continue
        if is_dead(target, state): continue
        if is_combat_capable(target, state): continue
        if hex_dist(unit["pos"], target["pos"]) <= ESCORT_DETECT_RANGE:
            return i
    return -1
```

### 包圍邏輯

當敵方人數 ≤ 自方 × 0.5 時，AI team 分散包圍（2+ 個方向接近）。

### 撤退路線

選擇最少敵人方向朝邊緣移動。

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- 含玩家的衝突觸發遭遇戰（不含玩家的衝突不觸發）
- 遭遇戰結束後大地圖 tick 正確恢復
- 俘虜在 team 資源中出現
- 傳令兵退出後在 subteams 有記錄
- 箭矢消耗正確從 team.resources["arrows"] 扣除
