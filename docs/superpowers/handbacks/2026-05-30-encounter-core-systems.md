# Hand Back: 遭遇戰核心系統

## 實作摘要

- `scripts/data/item_attributes.gd` — 新建：ITEM_REGISTRY 靜態查詢（傷害/射程/重量/格擋/減傷）
- `scripts/data/encounter_templates.gd` — 新建：archer/melee/medic/default 模板，根據裝備自動分類並填充 inventory
- `scripts/simulation/health_system.gd` — 新建：HP/blood/status/fracture 計算；tick_status_effects、tick_natural_regen、resolve_negative_flags、resolve_anon_units
- `scripts/data/person_data.gd` — 改：equipment 改 hand_1/hand_2；新增 blood 欄位；body_parts 加 hp/max_hp 格式
- `scripts/data/world_state.gd` — 改：新增 `encounter_tick: int = 0`
- `scripts/simulation/equipment_system.gd` — 改：right_hand → hand_1；裝備格式改 {type, grade}
- `scripts/simulation/skill_system.gd` — 改：right_hand → hand_1
- `scripts/simulation/interaction_system.gd` — 改：right_hand → hand_1；加 HealthSystem.tick_natural_regen 呼叫
- `scripts/simulation/faction_ai_system.gd` — 改：right_hand → hand_1
- `scripts/simulation/encounter_system.gd` — 改（大）：
  - unit 新增 equipment/inventory/action_timer/stance/pending_dodge
  - _init_named_unit / _init_anon_unit：spawn 時從 team 資源分配裝備並呼叫 EncounterTemplates
  - setup_arrows 移除，改 _has_arrows / _consume_arrow（讀 inventory）
  - _sync_back_units：戰鬥結束同步 pool 裝備回 team.resources
  - resolve_encounter_end 加 sync-back + HealthSystem.resolve_negative_flags/resolve_anon_units
  - 新增 BASE_ACTION_TICKS/BLOCK_WINDOW 等常數，stance 速度/耗耐力表
  - advance_encounter_tick：tick-based 行動計時器替代 round-based
  - resolve_attack：命中判定、格擋/閃避/招架、傷害計算（武器傷害 × 姿態乘數 × 護甲減傷）
- `scripts/simulation/player_system.gd` — 改：移除 ITEM_WEIGHT/PLAYER_MAX_WEIGHT，改 PLAYER_INVENTORY_MAX_SLOTS；equip_item 改新格式；加 use_splint 委派 HealthSystem
- `scripts/debug/headless_test.gd` — 改：加 ItemAttributes/HealthSystem/EncounterTemplates/EncounterCombat/PlayerSystem weight/EncounterSystem unit equipment 驗證斷言

### 與 spec 的差異

- advance_round 保留（未重命名為 _advance_round_legacy）——舊測試仍呼叫它，保持相容
- `state.get("player_id", -1)` 改為 `state.player_id`（GDScript 4 的 Object.get() 只接受 1 參數）
- `_equip_named_npc` / `_distribute_anon_equipment` 已被 `_init_named_unit` / `_init_anon_unit` 取代，舊函式移除
- 測試斷言 `armor_low×2 >= 10.0` 改為 `>= 8.0`（ItemAttributes armor_low weight = 4.0，非舊 ITEM_WEIGHT 的 5.0）

## 連動風險

- `interaction_system.gd`：`tick_natural_regen` 插入 `process_on_arrival` 末尾。若 on_arrival 被多次呼叫（同 tick 多次到達），regen 會多次觸發。目前測試無此情況，但主 session 需確認架構是否允許。
- `equipment_system.gd`：裝備格式改為 `{type, grade}`，`on_named_death` 接收 wtype 字串的呼叫方已在 interaction_system 同步更新。其他呼叫點（若有）需確認。
- `player_system.gd`：`add_to_inventory` 回傳型別從 `void` 改為 `bool`。若其他系統無回傳值地呼叫它（忽略回傳），GDScript 4 可接受，不會出錯，但語意改變。
- `resolve_encounter_end`：`_sync_back_units` + `_return_pool_equipment` 同時執行。_return_pool_equipment 只處理死亡 unit，_sync_back_units 處理存活 unit，理論上無重複回收。但若 unit 在 resolve 期間死亡狀態不一致，可能重複回收裝備到 team.resources。

## 待主 session 確認

- `advance_round` 是否可以正式移除（或重命名）？目前保留是為了讓舊 sim_runner/interaction_system 的呼叫繼續工作，需主 session 確認哪些系統仍用 round-based 流程。
- `interaction_system.gd` 的 encounter 處理路徑目前仍呼叫 `advance_round`，是否要切換到 `advance_encounter_tick`？
- 建議後續：將 `advance_encounter_tick` 整合到 sim_runner 的主 tick 循環（目前仍由 interaction_system 呼叫 advance_round）。
