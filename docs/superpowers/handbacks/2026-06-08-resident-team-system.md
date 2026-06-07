# Hand Back: Resident Team System (E+F+起義+移民)

> 日期：2026-06-08
> Plan：`docs/superpowers/plans/2026-06-08-resident-team-system.md`
> Spec：`docs/superpowers/specs/2026-06-08-resident-team-system-design.md`
> Branch：`feat/resident-team-system`

## 實作摘要

全 14 Task 完成，每 Task TDD（先失敗測試 → 實作 → 通過 → commit）。

- **TeamData**：加 `tax_rate`（預設 0.3）、`pending_owner_change_tick`（預設 -1）
- **faction_ai_system**：
  - `_is_resident_team` 動態偵測（PRODUCE + 在 outpost + 同 faction）
  - `_outpost_pop_cap` + `OUTPOST_POP_CAP` 常數（civilian [20,50,100] / military [15,35,70]）
  - `_evaluate_uprising` + helper `_avg_named_loyalty`、`_count_stress_sources`
  - `_evaluate_owner_contact` + 常數 `CONTACT_TIMEOUT_DAYS=30`、`OWNER_CHANGE_BUFFER_DAYS=7`
  - `_trigger_defection_evaluation`（a/b/c 路徑）+ `_has_memory_type`
  - `evaluate_all` team loop 整合居民評估
- **population_system**：`check_overflow_for_team` 對 PRODUCE 用 outpost cap，無 outpost 的 PRODUCE 流民 fallback leader cap
- **movement_system**：居民鎖（PRODUCE + `_is_resident_team` + task 非 逃跑/投靠/起義/遷徙 → skip）
- **salary_system**：`_pay_salary` 對 PRODUCE team 早退（村民自食其力）
- **interaction_system**：
  - `_resolve_tribute` 用 team.tax_rate（PRODUCE 路徑早退，不經 faction guard）+ 重稅 stress/loyalty/fear 效果
  - `_execute_settlement`、`_find_existing_resident`、`_convert_to_resident`、`_resolve_pacify`
  - `_try_interact` same_faction 分支加 task=安頓/安撫 判斷
- **diplomatic_ai_system**：`handle_diplomacy_message` 加 `invite_settle` case（求生欲/rep/飢餓/野心評分）
- **player_command_system**：加 `invite_settle` action + `_action_invite_settle` handler

## 行為變化

- PRODUCE + 在自家 outpost + 同 faction = 居民（動態偵測，無新 tag）
- 居民不被 movement_system 處理（除 task=逃跑/投靠/起義/遷徙）
- 居民不付匿名薪水、不付 named NPC 薪水
- 收稅依 team.tax_rate（0.1-0.7），重稅累加 named NPC stress/loyalty/fear；rate>0.5 累加 unrest_turns
- 起義條件：avg_named_loyalty<0.2 + unrest_turns>=60 + stress_sources>=2 → 整村變敵（faction=-1、erase 生產、加流亡、task=起義）；鄰格 PRODUCE cascade fear +0.1（半徑 2）；玩家為 owner → forced_event uprising_alert
- 失聯 30 天 或 owner leader 異動 7 天無反駁 → 居民自決 a/b/c（留 faction / 投降強鄰 / 獨立）
- 移民招攬：`invite_settle` 流民/弱隊接受 → 移到 outpost、加 PRODUCE、erase 流亡、入 faction；同 outpost 已有 PRODUCE 且 pop 不超 cap → 合併
- 子隊 task=安頓 抵達同 faction outpost → 自動轉居民；task=安撫 同 tile → 降 stress、升 loyalty、降 unrest

## 驗證

- `headless_test.gd`：13 個新測試（Resident Task1~Task12）全過，無 regression
- `game_sim_test.gd`：`ALL INVARIANTS PASSED (violations=0)`，7200 tick 無 resident 相關 runtime error
- 既有 Trade / Message feature 失敗為 **pre-existing**（main branch 同樣 8/10），與本系統無關

## 連動風險 / 待主 session 確認

- `_is_resident_team` 每次呼叫掃 tile + owner → 多次計算成本（evaluate_all / movement / population 各會呼叫）
- 7 天緩衝期 `cached_owner_leader` 用 `known_reputations` dict 暫存（key=`_cached_owner_leader_<owner_id>` 字串，避免和 team_id int key 衝突）
- 玩家 `forced_event` uprising_alert 後端寫入，**UI 未實作**
- NPC 主動發 invite_settle（spec 提及的簡化版自動招攬）**未實作**——目前只有玩家 action + diplomatic 評估路徑
- `_evaluate_owner_contact` 依賴 `state.team_intel` snapshot 有 `last_tick`/`leader_id`，需 intel 系統正常更新才會觸發失聯/異動判定
- 起義 cascade fear 半徑(2)/強度(0.1) 為估值，平衡待調
- defection path B（投降強鄰）無測試 case（plan 只列 a/c）
- D 攻佔 outpost spec 啟動時，居民歸屬如何重算（owner 轉手）需後續 spec

## Commits

```
Task 1  feat(team): add tax_rate + pending_owner_change_tick fields
Task 2  feat(faction_ai): _is_resident_team detection + _outpost_pop_cap helper
Task 3  feat(population): PRODUCE team uses outpost cap, overflow → 流亡 team
Task 4  feat(movement): lock 居民 team
Task 5  feat(salary): PRODUCE team skipped (villagers self-sustain)
Task 6  feat(tribute): use team.tax_rate + heavy tax stress
Task 7  feat(settle): invite_settle action + diplomatic eval + execute
Task 8  feat(settle): subteam task=安頓 auto-converts to resident
Task 9  feat(uprising): _evaluate_uprising for resident team
Task 10 feat(contact): _evaluate_owner_contact + 7-day buffer
Task 11 feat(defection): a/b/c paths based on leader values + memory
Task 12 feat(pacify): subteam task=安撫 reduces stress/unrest
Task 13 feat(faction_ai): integrate resident evaluation into evaluate_all
Task 14 docs: resident team system handback
```
