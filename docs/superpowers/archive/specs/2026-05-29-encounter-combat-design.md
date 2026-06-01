# 遭遇戰戰鬥機制 Design

## 依賴

- `2026-05-27-encounter-system-design.md`（unit 結構、stamina、body_parts、hex 移動）
- `2026-05-29-health-system-design.md`（apply_hit、speed 乘數公式）
- `2026-05-29-item-attributes-design.md`（武器傷害、射程、護甲減傷、盾牌格擋）
- `2026-05-27-player-system-design.md`（裝備欄格式、2H 武器判定）

---

## Goal

定義遭遇戰內每個 unit 的行動時序（action timer）、姿態系統、攻擊解算，以及基於 timer 的反應格擋機制。本 spec **擴充** encounter-system-design，不取代既有觸發/地圖/撤退邏輯。

---

## 1. EncounterUnit 結構擴充

在原有欄位基礎上新增：

```gdscript
# EncounterUnit 新增欄位（原有欄位不變）
{
    "action_timer": int,    # 倒數至 0 時行動，初始 = _max_timer()
    "stance": String,       # "walk" / "sprint" / "crouch" / "prone"，預設 "walk"
    "pending_dodge": bool,  # 本次被攻擊前已選閃避，解算後清除
}
```

`_create_anon_unit` 補上這三個欄位（預設 action_timer=max, stance="walk", pending_dodge=false）。

---

## 2. Action Timer 系統

### 速度計算

```gdscript
const BASE_ACTION_TICKS: int = 10   # TEST VALUE

func _base_speed(unit: Dictionary, state: WorldState) -> float:
    var p: PersonData = state.persons.get(unit.get("person_id", -1))
    var body: float = float(p.attributes.get("體力", 0.5)) if p else 0.5
    return 1.0 + body * 0.2   # TEST VALUE：體力=1.0 → 速度 1.2

func _effective_speed(unit: Dictionary, state: WorldState) -> float:
    var base: float   = _base_speed(unit, state)
    var stance: float = STANCE_SPEED_MULT.get(unit.get("stance", "walk"), 1.0)
    # HealthSystem.get_speed_mult = stamina_mult × blood_mult × fracture_mult
    # （定義於 health-system-design Section 3）
    var health: float = HealthSystem.get_speed_mult(unit, state)
    return base * stance * health

func _max_timer(unit: Dictionary, state: WorldState) -> int:
    return maxi(roundi(float(BASE_ACTION_TICKS) / _effective_speed(unit, state)), 1)
```

### Tick 流程

```gdscript
# encounter_system.gd — 每個 encounter tick
func _advance_encounter_tick(state: WorldState) -> void:
    for unit in state.encounter_units:
        if is_dead(unit, state): continue
        unit["action_timer"] -= 1
        if unit["action_timer"] <= 0:
            _on_action_frame(unit, state)   # 行動幀
```

### 行動幀

```gdscript
func _on_action_frame(unit: Dictionary, state: WorldState) -> void:
    # 玩家 unit → 定格，等待 UI 輸入（由 UI 系統呼叫 execute_action）
    # NPC unit → AI 決定行動
    var action: Dictionary = _decide_action(unit, state)   # NPC
    execute_action(unit, action, state)
    unit["action_timer"] = _max_timer(unit, state)   # 重算（速度可能已變）
```

---

## 3. 姿態系統

```gdscript
const STANCE_SPEED_MULT: Dictionary = {
    "walk":   1.0,
    "sprint": 1.5,   # TEST VALUE
    "crouch": 0.5,   # TEST VALUE
    "prone":  0.1,   # TEST VALUE（爬行）
}

const STANCE_MOVE_STAMINA: Dictionary = {
    "walk":   0.02,    # TEST VALUE
    "sprint": 0.05,    # TEST VALUE
    "crouch": 0.005,   # TEST VALUE
    "prone":  0.0,
}

# 遠程攻擊受到的傷害乘數（姿態降低被彈面積）
const STANCE_RANGED_DMG_MULT: Dictionary = {
    "walk":   1.0,
    "sprint": 1.0,
    "crouch": 0.7,   # -30% TEST VALUE
    "prone":  0.4,   # -60% TEST VALUE
}
```

**姿態限制：**
- `prone`：只能以 `weapon_melee_low` 或 `unarmed` 攻擊（無法使用長武器/弓）
- 換姿態 = 行動幀消耗一次，stamina 不扣

---

## 4. 行動類型（action_timer = 0 時擇一）

| 行動 | Stamina 消耗 | 說明 |
|---|---|---|
| 移動（1 hex） | 依姿態（見 STANCE_MOVE_STAMINA）× 重量乘數 | 移動至相鄰 hex |
| 攻擊 | 0.05 × 重量乘數 | 見 Section 6 |
| 換姿態 | 0 | 切換至任意姿態 |
| 使用物品 | 0 | medicine / tools |

重量 stamina 乘數：`HealthSystem.get_weight_stamina_drain_mult(unit, state)`

---

## 5. 格擋系統（Reactive Block）

### 格擋視窗

```gdscript
const BLOCK_WINDOW: int  = 8   # TEST VALUE — timer ≤ 此值可格擋
const BLOCK_PENALTY: int = 5   # TEST VALUE — 格擋後 timer += 此值

func _can_block(unit: Dictionary) -> bool:
    return int(unit.get("action_timer", 999)) <= BLOCK_WINDOW
```

### 觸發時機

```
任意 tick，unit 被攻擊時（攻擊解算前）：
  if _can_block(defender):
    玩家 → 跳出格擋提示視窗
    NPC  → _npc_auto_block() 自動決定
  else:
    直接進入攻擊解算（無格擋機會）
```

### 格擋選項

**所有選項：成功 = 0 傷害；失敗 = 全傷害。**

| 選項 | 條件 | 成功機率 |
|---|---|---|
| 盾牌格擋 | hand_1 或 hand_2 裝備 armor_* | `SHIELD_BLOCK_CHANCE[grade] + 戰鬥×0.3` |
| 武器架擋 | 裝備任意近戰武器（含 unarmed） | `PARRY_BASE[weapon] + 戰鬥×0.4` |
| 閃避 | 無條件可選，消耗 stamina -0.1 | `0.2 + 求生×0.4×(0.5+體力×0.5)` |

玩家格擋提示顯示各選項機率（如「盾牌格擋 62%」），方便決策。

```gdscript
# 基礎格擋機率全部由 ItemAttributes 提供：
# ItemAttributes.get_block_chance(armor_grade)  → 盾牌
# ItemAttributes.get_parry_chance(weapon_grade) → 武器架擋

func _shield_block_chance(unit: Dictionary, state: WorldState) -> float:
    var grade: String   = _get_shield_grade(unit, state)   # "armor_low" / "armor_high"
    var base: float     = ItemAttributes.get_block_chance(grade)   # 0.30 / 0.50
    var combat: float   = _get_skill(unit, state, "戰鬥")
    return clampf(base + combat * 0.3, 0.0, 0.90)   # TEST VALUE

func _parry_chance(unit: Dictionary, state: WorldState) -> float:
    var weapon: String  = _get_weapon_grade(unit, state)
    var base: float     = ItemAttributes.get_parry_chance(weapon)
    var combat: float   = _get_skill(unit, state, "戰鬥")
    return clampf(base + combat * 0.4, 0.0, 0.85)   # TEST VALUE

func _dodge_chance(unit: Dictionary, state: WorldState) -> float:
    var p: PersonData   = state.persons.get(unit.get("person_id", -1))
    var survival: float = _get_skill(unit, state, "求生")
    var body: float     = float(p.attributes.get("體力", 0.5)) if p else 0.5
    return clampf(0.2 + survival * 0.4 * (0.5 + body * 0.5), 0.0, 0.80)   # TEST VALUE

func _resolve_block(unit: Dictionary, state: WorldState,
        choice: String) -> bool:   # 返回 true = 格擋成功（無傷）
    match choice:
        "shield": return randf() < _shield_block_chance(unit, state)
        "parry":  return randf() < _parry_chance(unit, state)
        "dodge":
            unit["stamina"] = maxf(float(unit.get("stamina", 0.0)) - 0.1, 0.0)
            return randf() < _dodge_chance(unit, state)
    return false
```

格擋執行後（無論成功/失敗）：
```gdscript
unit["action_timer"] = mini(unit["action_timer"] + BLOCK_PENALTY,
                            _max_timer(unit, state))
```

### NPC 自動格擋

NPC 選擇成功率最高的選項；低於門檻直接受擊：

```gdscript
func _npc_auto_block(unit: Dictionary, state: WorldState) -> String:
    var options: Dictionary = {}
    if _has_shield(unit, state):
        options["shield"] = _shield_block_chance(unit, state)
    if _has_melee_weapon(unit, state):
        options["parry"] = _parry_chance(unit, state)
    if float(unit.get("stamina", 0.0)) > 0.1:
        options["dodge"] = _dodge_chance(unit, state)

    var best: String = "none"; var best_val: float = 0.3   # TEST VALUE 最低門檻
    for opt in options:
        if options[opt] > best_val: best_val = options[opt]; best = opt
    return best
```

---

## 6. 攻擊解算

### 射程檢查（遠程攻擊前）

```gdscript
func _check_range(attacker: Dictionary, target: Dictionary,
        state: WorldState) -> bool:
    var weapon: String = _get_weapon_grade(attacker, state)
    return hex_dist(attacker["pos"], target["pos"]) \
           <= ItemAttributes.get_range(weapon)
```

### 命中判定

```gdscript
func _hit_chance(attacker: Dictionary, state: WorldState) -> float:
    var p: PersonData = state.persons.get(attacker.get("person_id", -1))
    var weapon: String = _get_weapon_grade(attacker, state)
    var base: float = 0.6   # TEST VALUE
    var skill: float = 0.0
    if p:
        if weapon.contains("ranged"):
            skill = float(p.skills.get("弓箭", 0.0)) * 0.4
        else:
            skill = float(p.skills.get("戰鬥", 0.0)) * 0.4
    return clampf(base + skill, 0.05, 0.95)
```

### 完整攻擊流程

```gdscript
func _resolve_attack(attacker: Dictionary, target: Dictionary,
        state: WorldState, target_part: String) -> void:
    var weapon: String = _get_weapon_grade(attacker, state)
    var is_ranged: bool = weapon.contains("ranged")

    # 射程（遠程）
    if is_ranged and not _check_range(attacker, target, state): return

    # 閃避 miss 判定（target 已選閃避，由格擋視窗觸發）
    if target.get("pending_dodge", false):
        target["pending_dodge"] = false
        if _resolve_block(target, state, "dodge"):
            print("[Dodge] %s 閃避成功" % str(target["person_id"]))
            return

    # 命中判定
    if randf() > _hit_chance(attacker, state):
        print("[Miss]")
        return

    # 基礎傷害
    var raw_dmg: float = ItemAttributes.get_damage(weapon)

    # 遠程：姿態減傷
    if is_ranged:
        raw_dmg *= STANCE_RANGED_DMG_MULT.get(target.get("stance","walk"), 1.0)

    # 護甲減傷（命中部位）
    var armor: String = _get_armor_grade_at(target, state, target_part)
    var reduction: float = ItemAttributes.get_damage_reduction(armor)
    var final_dmg: float = raw_dmg * (1.0 - reduction)

    # 套用至 HealthSystem（只負責扣 HP + 更新 status，不再計算傷害）
    HealthSystem.receive_damage(target, state, target_part, final_dmg)
    print("[Hit] part=%s dmg=%.1f" % [target_part, final_dmg])
```

### Stamina 耗盡效果

```gdscript
# stamina = 0 時，攻擊傷害乘數
const STAMINA_EXHAUSTED_ATK_MULT: float = 0.5   # TEST VALUE
# 速度乘數已由 HealthSystem.get_speed_mult 處理（stamina_mult）
```

---

## 7. 輔助函數

所有裝備查詢讀 `unit["equipment"]`（進場時已從 PersonData 複製或由 EncounterTemplates 填入），不再直接存取 PersonData.equipment。

```gdscript
func _get_weapon_grade(unit: Dictionary, _state: WorldState) -> String:
    var equip: Dictionary = unit.get("equipment", {})
    var h1: Dictionary = equip.get("hand_1", {})
    if h1.get("type", "none") not in ["none", "2h_ref", ""]:
        return h1.get("grade", "unarmed")
    return "unarmed"

func _get_armor_grade_at(unit: Dictionary, _state: WorldState,
        part: String) -> String:
    var equip: Dictionary = unit.get("equipment", {})
    var slot: Dictionary = equip.get(part, {})
    if slot.get("type", "none") in ["none", ""]: return "none"
    return slot.get("grade", "none")

func _get_shield_grade(unit: Dictionary, _state: WorldState) -> String:
    var equip: Dictionary = unit.get("equipment", {})
    for hand in ["hand_1", "hand_2"]:
        var s: Dictionary = equip.get(hand, {})
        if s.get("grade", "").begins_with("armor_"): return s.get("grade", "")
    return ""

func _has_shield(unit: Dictionary, state: WorldState) -> bool:
    return _get_shield_grade(unit, state) != ""

func _has_melee_weapon(unit: Dictionary, state: WorldState) -> bool:
    var grade: String = _get_weapon_grade(unit, state)
    return grade.contains("melee") or grade == "unarmed"

# 技能讀取：具名 NPC 從 PersonData，匿名從 unit["skills"]
func _get_skill(unit: Dictionary, state: WorldState, skill: String) -> float:
    var p: PersonData = state.persons.get(unit.get("person_id", -1))
    if p: return float(p.skills.get(skill, 0.0))
    return float(unit.get("skills", {}).get(skill, 0.0))
```

---

## 修改檔案

| 檔案 | 動作 |
|---|---|
| `scripts/simulation/encounter_system.gd` | 加 action_timer / stance / 格擋 / 攻擊解算邏輯 |
| `scripts/debug/headless_test.gd` | 加 action_timer 初始化、格擋觸發驗證輸出 |

---

## 驗證標準

```powershell
.\tools\godot\Godot_v4.2.2-stable_win64_console.exe --headless --script scripts/debug/headless_test.gd
```

預期：
- 無 SCRIPT ERROR，`=== DONE ===`
- `[Hit]` 出現（攻擊命中）
- `[Miss]` 出現（命中判定失敗）
- `[Block]` / `[Dodge]` 出現（格擋觸發）
- unit stamina 在攻擊/移動後下降
- 倒地姿態 unit 遠程受傷減少

---

## ⚠️ TEST VALUE 清單

| 常數 | 值 | 備註 |
|---|---|---|
| `BASE_ACTION_TICKS` | 10 | 基礎行動週期 |
| `BLOCK_WINDOW` | 8 | 格擋視窗 tick 上限 |
| `BLOCK_PENALTY` | 5 | 格擋後 timer 增加量 |
| base_speed 體力係數 | ×0.2 | 體力=1.0 → 速度 1.2 |
| 衝刺速度乘數 | ×1.5 | |
| 蹲下速度乘數 | ×0.5 | |
| 倒地速度乘數 | ×0.1 | |
| 命中基礎率 | 60% | |
| 戰鬥/弓箭命中加成 | skill×0.4 | |
| 盾牌格擋基礎機率 | 見 item-attributes-design | armor_low=0.30, armor_high=0.50 |
| 盾牌格擋技能加成 | 戰鬥×0.3 | |
| 武器架擋基礎機率 | 見 item-attributes-design | melee_low=0.10, melee_high=0.20 |
| 武器架擋技能加成 | 戰鬥×0.4 | |
| 閃避 stamina 消耗 | 0.1 | |
| 閃避基礎成功率 | 20% | 求生=0 時 |
| NPC 格擋最低門檻 | 30% | 低於不格擋 |
| 攻擊 stamina 消耗 | 0.05 | |
| 蹲下遠程減傷 | ×0.7 | |
| 倒地遠程減傷 | ×0.4 | |
| stamina 耗盡攻擊乘數 | ×0.5 | |
