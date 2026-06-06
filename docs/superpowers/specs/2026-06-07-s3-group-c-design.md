# S3 Group C — InteractionSystem 拆分 設計

*Spec written: 2026-06-07*

## Goal

`interaction_system.gd`（1099 行）拆分為兩個職責清晰的檔案：
- 保留 `interaction_system.gd`（協調 + 非戰鬥邏輯，目標 ~550 行）
- 新建 `npc_combat_system.gd`（NPC 自發戰鬥解算，目標 ~500 行）

外部 API 不變，不影響任何呼叫方。

---

## 職責劃分

### `npc_combat_system.gd`（新檔）

class_name: `NpcCombatSystem`

負責所有 NPC 自發戰鬥的解算邏輯：

| 函式 | 說明 |
|---|---|
| `process_ongoing_combat(state, all_team_ids)` | 主迴圈（原 `_process_ongoing_combat`） |
| `start_combat(state, atk_id, def_id)` | 發起戰鬥（原 `_start_combat`） |
| `resolve_volley(state, id_a, id_b)` | 弓箭齊射（原 `_resolve_volley`） |
| `resolve_combat_round(state, id_a, id_b)` | 一輪戰鬥（原 `_resolve_combat_round`） |
| `end_combat(state, winner_id, loser_id)` | 戰鬥結束（原 `_end_combat`） |
| `force_retreat(state, retreater_id, pursuer_id)` | 強制撤退（原 `_force_retreat`） |
| `apply_pursuit(state, winner_id, loser_id)` | 追擊（原 `_apply_pursuit`） |
| `try_retreat(state, team_id, enemy_id)` | 嘗試撤退（原 `_try_retreat`） |
| `apply_casualties(state, team_id, count)` | 施加傷亡（原 `_apply_casualties`） |
| `hit_person(state, team_id, p)` | 命中記名 NPC（原 `_hit_person`） |
| `random_part()` | 隨機受傷部位（原 `_random_part`） |
| `check_night_raid(state, attacker, defender, tick)` | 夜襲判斷（原 `_check_night_raid`） |
| `calc_armed(state, team)` | 計算武裝人數（原 `_calc_armed`） |
| `team_strength(state, team_id)` | 綜合戰力（原 `_team_strength`） |
| `strength_raw(state, team_id)` | 原始戰力（原 `_strength_raw`） |
| `ranged_strength(state, team_id)` | 遠程戰力（原 `_ranged_strength`） |
| `terrain_defense_mult(state, team)` | 地形防禦乘數（原 `_terrain_defense_mult`） |
| `tick_critical_npcs(state, all_team_ids)` | NPC 重傷/死亡 tick（原 `_tick_critical_npcs`） |
| `kill_named_npc(state, team_id, p)` | 殺死記名 NPC（原 `_kill_named_npc`） |
| `best_medicine(state, team)` | 最佳治療能力（原 `_best_medicine`） |

**注意：** 這些函式原本有底線前綴（私有），移到新檔後改為無底線（公開）。`InteractionSystem` 作為呼叫方。

所有常數從 `interaction_system.gd` 移動到 `npc_combat_system.gd`：
- `ROUND_CASUALTY_RATE`, `VOLLEY_CASUALTY_RATE`, `PURSUIT_RATE`
- `COMBAT_THRESHOLD`, `COMBAT_ABANDON_THRESHOLD`
- `ROUND_READINESS_DRAIN`, `MORALE_CASCADE_THRESHOLD`
- `CRITICAL_DEATH_CHANCE_BASE`, `CRITICAL_RECOVER_CHANCE_BASE`

---

### `interaction_system.gd`（保留，重構）

負責：進入點協調、NPC 互動決策、非戰鬥解算。

**保留的常數（`interaction_system.gd` 頂部）：**
- `FOOD_RESERVE_TICKS`, `MAX_COIN_PER_TRADE`（被 `faction_ai_system.gd` 外部引用）
- `WOUNDED_TREATMENT_RATE`, `TRIBUTE_RATE`, `LOOT_RATE`
- `READINESS_RECOVERY_BASE`, `READINESS_FOOD_COST`

**保留的函式：**

| 函式 | 說明 |
|---|---|
| `process_on_arrival(state, arrived_ids, all_team_ids)` | 主進入點（sim_runner 呼叫） |
| `_tick_readiness(state, team_ids)` | 備戰度 tick |
| `_treat_wounded(state, team)` | 治療傷員 |
| `_try_interact(state, id_a, id_b)` | 決定互動類型 |
| `_should_pay_tribute(state, def_id, atk_id)` | 納貢決策 |
| `_should_attack(state, atk_id, def_id)` | 攻擊決策 |
| `_try_diplomacy(state, initiator_id, target_id)` | 外交 |
| `_try_merge(state, id_a, id_b)` | 合併 |
| `_try_subjugate(state, winner_id, loser_id)` | 收編 |
| `subjugate_team(state, winner_id, loser_id)` | 公開收編（player_command_system 呼叫） |
| `_resolve_tribute(state, collector_id, payer_id)` | 解算納貢 |
| `_resolve_trade(state, seller, buyer)` | NPC 自發貿易 |
| `_resolve_extortion(state, atk_id, def_id)` | 勒索解算 |
| `resolve_trade_direct(state, initiator_id, target_id)` | 玩家貿易直呼（公開） |
| `resolve_extortion_direct(state, from_id, target_id)` | 玩家勒索直呼（公開） |
| `_grow_commerce_skill(state, team)` | 商業技能成長 |
| `_local_value(team, res)` | 本地資源價值 |
| `_deliver_order(state, messenger_id, target_id)` | 傳令 |
| `execute_prisoner(state, team_id)` | 處決俘虜 |
| `_write_tier2_intel(state, obs_id, tgt_id)` | 二級情報 |

**`_init()` 新增 NpcCombatSystem 實例：**

```gdscript
var _combat: NpcCombatSystem

func _init() -> void:
    _combat = NpcCombatSystem.new()
    _msg    = SimMessageSystem.new()
    _skill_sys = load("res://scripts/simulation/skill_system.gd").new()
```

**委託呼叫範例：**

```gdscript
# interaction_system.gd
func _try_interact(state, id_a, id_b):
    ...
    if should_fight:
        _combat.start_combat(state, id_a, id_b)
    ...

func process_on_arrival(state, arrived_ids, all_team_ids):
    _combat.process_ongoing_combat(state, all_team_ids)
    _combat.tick_critical_npcs(state, all_team_ids)
    ...
```

---

## 外部 API 保持不變

| 呼叫方 | 函式 | 所在 |
|---|---|---|
| `sim_runner.gd` | `process_on_arrival()` | `interaction_system.gd` |
| `player_command_system.gd` | `subjugate_team()` | `interaction_system.gd` |
| `player_command_system.gd` | `resolve_trade_direct()` | `interaction_system.gd` |
| `player_command_system.gd` | `resolve_extortion_direct()` | `interaction_system.gd` |
| `faction_ai_system.gd` | `InteractionSystem.FOOD_RESERVE_TICKS` | `interaction_system.gd` |
| `headless_test.gd` | `InteractionSystem.new()` | `interaction_system.gd` |

所有外部呼叫點**不需要修改**。

---

## Files to Modify

| File | Action |
|---|---|
| `scripts/simulation/npc_combat_system.gd` | **新建** — 從 interaction_system 移出的戰鬥邏輯 |
| `scripts/simulation/interaction_system.gd` | **修改** — 刪除移出的函式，加 `_combat` 委託 |

---

## Testing

現有 `headless_test.gd` 1000 tick 測試覆蓋所有路徑（戰鬥/合併/貿易/外交），無需額外測試。執行後確認：
- 零 SCRIPT ERROR
- `=== DONE ===`
- 既有的 `[MergeTest]`, `[DiploTest]`, `[BoundaryTest]` 測試全部通過
