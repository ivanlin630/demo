# 健康系統 Design

## 依賴

- `2026-05-27-data-structure-update-design.md`（PersonData、body_parts 基礎）
- `2026-05-27-encounter-system-design.md`（遭遇戰觸發、unit 結構）
- `2026-05-27-player-system-design.md`（medicine/tools 物品）

---

## Goal

重設計遭遇戰健康邏輯：命中扣部位 HP（非直接降 status）、加入血液值、負面狀態 flags（出血/中毒/骨折）、遭遇戰結束後雙方結算、骨折帶入大地圖。

---

## 1. PersonData 新欄位

```gdscript
# scripts/data/person_data.gd

var blood: float = 100.0   # TEST VALUE — 全身血液值（0=死亡，<30=昏迷）

# body_parts 完整格式（遭遇戰 named NPC + 玩家）
# var body_parts: Dictionary = {
#   "head":      { "hp": 20.0, "max_hp": 20.0, "status": "healthy",
#                  "poisoned": false, "bleeding": "none", "fracture": false },
#   "torso":     { "hp": 50.0, "max_hp": 50.0, ... },
#   "right_arm": { "hp": 25.0, "max_hp": 25.0, ... },
#   "left_arm":  { "hp": 25.0, "max_hp": 25.0, ... },
#   "right_leg": { "hp": 30.0, "max_hp": 30.0, ... },
#   "left_leg":  { "hp": 30.0, "max_hp": 30.0, ... },
# }
```

**部位 max_hp（TEST VALUE）：**

| 部位 | max_hp |
|---|---|
| head | 20.0 |
| torso | 50.0 |
| right_arm / left_arm | 25.0 |
| right_leg / left_leg | 30.0 |

---

## 2. HP → Status 門檻

```gdscript
# status 由 hp 比例自動計算（不手動設定）
func _calc_status(hp: float, max_hp: float, part: String) -> String:
    var ratio: float = hp / max_hp
    if ratio > 0.75:   return "healthy"
    if ratio > 0.25:   return "wounded"
    if ratio > 0.0:    return "critical"
    # hp == 0
    if part in ["head", "torso"]: return "critical"  # head/torso 不 severed（瀕死上限）
    return "severed"
```

---

## 3. 血液系統

```gdscript
const BLOOD_MAX: float       = 100.0   # TEST VALUE
const BLOOD_COMA_THRESHOLD   = 30.0    # TEST VALUE — 低於此值昏迷
const BLOOD_REGEN_PER_TICK   = 0.2     # TEST VALUE — 自然回復（無出血時）

# 昏迷：blood < BLOOD_COMA_THRESHOLD → 無法行動（_decide_action 返回 incapable）
# 死亡：blood <= 0.0
# 速度影響：get_effective_speed() × clampf(blood / BLOOD_MAX, 0.0, 1.0)
```

---

## 4. 命中傷害計算

```gdscript
const WEAPON_DAMAGE: Dictionary = {
    "weapon_melee_low":   10.0,   # TEST VALUE
    "weapon_melee_high":  15.0,
    "weapon_ranged_low":   8.0,
    "weapon_ranged_high": 12.0,
    "unarmed":             5.0,
}

const ARMOR_REDUCTION: Dictionary = {
    "armor_low":  0.4,   # 傷害 × (1 - 0.4) = × 0.6
    "armor_high": 0.6,
}

const SHIELD_BLOCK_CHANCE: Dictionary = {
    "armor_low":  0.30,  # TEST VALUE — 格擋機率
    "armor_high": 0.50,
}

func _apply_hit(attacker: Dictionary, target: Dictionary,
        part: String, state: WorldState) -> void:
    # 1. 格擋判定（target 副手有盾牌）
    var shield_grade := _get_hand_shield(target, state)
    if shield_grade != "" and randf() < SHIELD_BLOCK_CHANCE.get(shield_grade, 0.0):
        return   # 格擋，無傷害

    # 2. 基礎傷害
    var weapon_grade := _get_weapon_grade(attacker, state)
    var dmg: float = WEAPON_DAMAGE.get(weapon_grade, 5.0)

    # 3. 護甲減傷（該部位護甲槽）
    var armor_grade := _get_armor_at_slot(target, part, state)
    if armor_grade != "":
        dmg *= (1.0 - ARMOR_REDUCTION.get(armor_grade, 0.0))

    # 4. 扣 HP，更新 status
    var bp: Dictionary = _get_body_parts(target, state)
    bp[part]["hp"] = maxf(bp[part]["hp"] - dmg, 0.0)
    bp[part]["status"] = _calc_status(bp[part]["hp"], bp[part]["max_hp"], part)
```

---

## 5. 負面 Flags

### 5a. 每 round 效果

```gdscript
const BLEEDING_MINOR_DRAIN: float = 3.0    # TEST VALUE — blood/round
const BLEEDING_MAJOR_DRAIN: float = 10.0   # TEST VALUE — blood/round
const POISON_HP_DRAIN: float      = 5.0    # TEST VALUE — hp/round 各部位

func _tick_status_effects(unit: Dictionary, state: WorldState) -> void:
    var bp: Dictionary = _get_body_parts(unit, state)
    var blood_drain: float = 0.0
    for part in bp:
        # 出血 → 扣血液
        match bp[part].get("bleeding", "none"):
            "minor": blood_drain += BLEEDING_MINOR_DRAIN
            "major": blood_drain += BLEEDING_MAJOR_DRAIN
        # 中毒 → 扣部位 HP
        if bp[part].get("poisoned", false):
            bp[part]["hp"] = maxf(bp[part]["hp"] - POISON_HP_DRAIN, 0.0)
            bp[part]["status"] = _calc_status(bp[part]["hp"], bp[part]["max_hp"], part)

    # 血液扣值
    if blood_drain > 0.0:
        _drain_blood(unit, state, blood_drain)

func _drain_blood(unit: Dictionary, state: WorldState, amount: float) -> void:
    if unit["person_id"] != -1:
        var p: PersonData = state.persons.get(unit["person_id"])
        if p: p.blood = maxf(p.blood - amount, 0.0)
    else:
        unit["blood"] = maxf(unit.get("blood", 100.0) - amount, 0.0)
```

### 5b. 骨折效果

骨折在 `_decide_action` / `get_effective_speed` 中檢查：

| 部位 | 效果 |
|---|---|
| head | 每 round `randf() < 0.3` → 跳過行動；智力屬性 ×0.5 |
| torso | 疲勞消耗 ×2；速度 −20% |
| arm（其一）| **裝備自動掉落**（hand slot 清空，物品落地）；hand slot 無法使用 |
| leg（其一）| 速度 −50%；無法衝刺 |
| leg（兩隻）| 速度 −90%；無法主動移動 |

```gdscript
# 骨折速度計算（取代 get_effective_speed 腿部邏輯）
func _fracture_speed_mult(bp: Dictionary) -> float:
    var broken_legs: int = 0
    if bp.get("right_leg", {}).get("fracture", false): broken_legs += 1
    if bp.get("left_leg",  {}).get("fracture", false): broken_legs += 1
    if broken_legs >= 2: return 0.1    # −90%
    if broken_legs == 1: return 0.5    # −50%
    return 1.0
```

---

## 6. 遭遇戰結算（結束後）

### 6a. Named NPC + 玩家

```gdscript
const RESOLVE_BLOOD_MAJOR: float = 30.0   # TEST VALUE — 未治大出血扣血
const RESOLVE_BLOOD_MINOR: float = 10.0   # TEST VALUE — 未治小出血扣血
const RESOLVE_POISON_HP:   float = 10.0   # TEST VALUE — 未治中毒扣各部位 HP

func _resolve_negative_flags(state: WorldState, team: TeamData) -> void:
    var all_ids: Array = team.named_members.duplicate()
    if state.player_id != -1 and state.persons.has(state.player_id):
        if state.persons[state.player_id].team_id == team.team_id:
            all_ids.append(state.player_id)

    var best_med: float = _best_skill(state, team, "醫療")

    for pid in all_ids:
        var p: PersonData = state.persons.get(pid)
        if p == null: continue
        for part in p.body_parts:
            var bp = p.body_parts[part]
            # 大出血
            if bp.get("bleeding") == "major":
                if int(team.resources.get("medicine", 0)) >= 2:
                    team.resources["medicine"] = int(team.resources["medicine"]) - 2
                elif randf() < best_med * 0.5:   # 技能判定
                    pass
                else:
                    p.blood = maxf(p.blood - RESOLVE_BLOOD_MAJOR, 1.0)
                bp["bleeding"] = "none"
            # 小出血
            if bp.get("bleeding") == "minor":
                if int(team.resources.get("medicine", 0)) >= 1:
                    team.resources["medicine"] = int(team.resources["medicine"]) - 1
                elif randf() < best_med * 0.5:
                    pass
                else:
                    p.blood = maxf(p.blood - RESOLVE_BLOOD_MINOR, 1.0)
                bp["bleeding"] = "none"
            # 中毒
            if bp.get("poisoned", false):
                if int(team.resources.get("medicine", 0)) >= 3:
                    team.resources["medicine"] = int(team.resources["medicine"]) - 3
                elif randf() < best_med * 0.5:
                    pass
                else:
                    for p2 in p.body_parts:
                        p.body_parts[p2]["hp"] = maxf(p.body_parts[p2]["hp"] - RESOLVE_POISON_HP, 1.0)
                        p.body_parts[p2]["status"] = _calc_status(
                            p.body_parts[p2]["hp"], p.body_parts[p2]["max_hp"], p2)
                bp["poisoned"] = false
            # 骨折（唯一帶入大地圖）
            if bp.get("fracture", false):
                if int(team.resources.get("tools", 0)) >= 1:
                    team.resources["tools"] = int(team.resources["tools"]) - 1
                    bp["fracture"] = false
                # else: 保留 flag，帶入大地圖
```

### 6b. 匿名成員（轉回 team pool）

```gdscript
func _resolve_anon_units(state: WorldState, team_id: int) -> void:
    var team: TeamData = state.teams[team_id]
    var anon_units := state.encounter_units.filter(
        func(u): return u["team_id"] == team_id and u["person_id"] == -1)

    for unit in anon_units:
        var bp: Dictionary = unit.get("body_parts", {})
        # 中毒 → 一次扣 HP
        for part in bp:
            if bp[part].get("poisoned", false):
                bp[part]["hp"] = maxf(bp[part]["hp"] - RESOLVE_POISON_HP, 1.0)
                bp[part]["status"] = _calc_status(bp[part]["hp"], bp[part]["max_hp"], part)
                bp[part]["poisoned"] = false
        # 死亡
        if _is_unit_dead(bp): team.population = maxi(team.population - 1, 0); continue
        # 出血 → 消耗 medicine，不足 → 加入 wounded
        var has_bleed: bool = bp.values().any(func(x): return x.get("bleeding","none") != "none")
        if has_bleed:
            var cost: int = 1 if bp.values().any(func(x): return x.get("bleeding")=="minor") else 2
            if int(team.resources.get("medicine", 0)) >= cost:
                team.resources["medicine"] = int(team.resources["medicine"]) - cost
            else:
                team.wounded += 1
        elif bp.values().any(func(x): return x.get("status","healthy") != "healthy"):
            team.wounded += 1
        # 骨折 → 加入 wounded（不追蹤）
        if bp.values().any(func(x): return x.get("fracture", false)):
            team.wounded += 1
```

---

## 7. 大地圖骨折持續效果

骨折 flag 在 PersonData 保留。影響：
- `get_effective_speed()`：呼叫 `_fracture_speed_mult()`
- arm fracture：hand slot 鎖定（EquipmentSystem 檢查）

骨折治療（玩家物品欄 → tools）：
```gdscript
func use_splint(state: WorldState, pid: int, part: String) -> bool:
    var inv: Array = state.player_state.get("inventory", [])
    for item in inv:
        if item["grade"] == "tools" and item.get("qty", 0) >= 1:
            item["qty"] -= 1
            if item["qty"] <= 0: inv.erase(item)
            var p: PersonData = state.persons.get(pid)
            if p and p.body_parts.has(part):
                p.body_parts[part]["fracture"] = false
            return true
    return false
```

---

## 8. 自然恢復（大地圖）

```gdscript
const HP_REGEN_PER_TICK:    float = 0.5    # TEST VALUE — 部位 HP/tick（無骨折）
const HP_REGEN_FRACTURE:    float = 0.05   # TEST VALUE — 骨折時 HP 恢復極慢
const BLOOD_REGEN_PER_TICK: float = 0.2    # TEST VALUE — blood/tick（無出血）

# 在 SimRunner tick 中對所有 named + player 執行
func _tick_natural_regen(state: WorldState) -> void:
    for pid in state.persons:
        var p: PersonData = state.persons[pid]
        if p.team_id == -1: continue
        # blood
        var has_bleeding: bool = p.body_parts.values().any(
            func(x): return x.get("bleeding","none") != "none")
        if not has_bleeding:
            p.blood = minf(p.blood + BLOOD_REGEN_PER_TICK, BLOOD_MAX)
        # hp per part
        for part in p.body_parts:
            var bp = p.body_parts[part]
            var regen: float = HP_REGEN_FRACTURE if bp.get("fracture", false) else HP_REGEN_PER_TICK
            bp["hp"] = minf(bp["hp"] + regen, bp["max_hp"])
            bp["status"] = _calc_status(bp["hp"], bp["max_hp"], part)
```

---

## 修改檔案

| 檔案 | 動作 |
|---|---|
| `scripts/data/person_data.gd` | 加 `blood`；`body_parts` 新格式 |
| `scripts/simulation/encounter_system.gd` | `_default_body_parts` 新格式；`_apply_body_part_damage` 改為扣 HP；加 `_apply_hit`、`_tick_status_effects`、`_resolve_negative_flags`、`_resolve_anon_units` |
| `scripts/simulation/interaction_system.gd` | `tick()` 加 `_tick_natural_regen`；post-encounter hook 呼叫 `_resolve_negative_flags` |
| `scripts/simulation/player_system.gd`（新） | `use_splint()`；`get_effective_speed` 加骨折修正 |
| `scripts/debug/headless_test.gd` | 更新 body_parts 初始格式；加 blood 欄位；加結算驗證 |
| `docs/person.md` | 已更新 |

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- `body_parts` 格式含 hp/max_hp/bleeding/fracture/poisoned
- 命中後 hp 減少，status 依門檻更新
- 遭遇戰結束：bleeding/poisoned flag 清除，blood 扣至最低 1
- 骨折無 tools → fracture flag 保留至大地圖
- 大地圖 tick：blood/hp 自然回升

---

## ⚠️ TEST VALUES

| 常數 | 值 | 備註 |
|---|---|---|
| 各部位 max_hp | 20/50/25/30 | 平衡期調整 |
| WEAPON_DAMAGE | 5–15 | 依武器 grade |
| ARMOR_REDUCTION | 0.4/0.6 | 皮/鐵甲 |
| SHIELD_BLOCK_CHANCE | 0.30/0.50 | 皮/鐵盾 |
| BLEEDING_MINOR_DRAIN | 3.0/round | |
| BLEEDING_MAJOR_DRAIN | 10.0/round | |
| POISON_HP_DRAIN | 5.0/round | |
| RESOLVE_BLOOD_MAJOR | 30.0 | 一次扣 |
| RESOLVE_BLOOD_MINOR | 10.0 | 一次扣 |
| HP_REGEN_PER_TICK | 0.5 | |
| BLOOD_REGEN_PER_TICK | 0.2 | |
