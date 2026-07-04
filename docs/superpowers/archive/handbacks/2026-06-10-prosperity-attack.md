# Hand Back: NPC Prosperity Attack（野心驅動主動征服）

> 日期：2026-06-10　branch：`feat/prosperity-attack`
> Plan：`docs/superpowers/plans/2026-06-10-prosperity-attack.md`
> Spec：`docs/superpowers/specs/2026-06-10-prosperity-attack-design.md`

## 實作摘要（每檔一行）

- `scripts/data/team_data.gd`：加 `prosperity_eval_next_tick`（cadence）+ `prosperity_target_id`（追擊目標）
- `scripts/simulation/faction_ai_system.gd`：
  - static helper `calc_readiness_threshold` / `calc_readiness` / `calc_attack_score` / `find_prosperity_prey` / `_is_border_adjacent`
  - 入口 `_evaluate_prosperity_attack`（過濾 → score → readiness → prey → TASK_ATTACK）
  - cadence 整合進 `evaluate_all` per-team loop（**非 sim_runner**，見「與 plan 差異」）
  - `_is_prosperity_candidate`（faction leader 或獨立團）/ `mark_prosperity_recheck`（事件重評）/ `_refresh_attack_pursuit`（追擊刷新）/ `_estimate_eta_to`
  - `_trigger_survival` Path 1 加 B 分支（遠 outpost ETA>5日 + 殘忍>0.5/好戰>0.6 → TASK_LOOT）
- `scripts/simulation/vision_system.gd`：新發現 team（`is_new`）→ `mark_prosperity_recheck`（事件觸發 b）
- `scripts/simulation/encounter_system.gd`：
  - `resolve_encounter_end` 勝方接 `_process_occupied_residents`（屠/放棄/強佔）；敗方接 `on_attack_defeat` reaction
  - helper `_find_prey_outpost` / `_find_resident_team_on_tile` / `_massacre_residents` / `_abandon_occupation` / `_force_occupy`
- `scripts/simulation/reaction_system.gd`：`on_attack_defeat`（named loyalty 降、leader stress 升，pop_loss>0.3 加倍）
- `scripts/debug/headless_test.gd`：16 個 prosperity 測試（全綠）

## 與 spec/plan 差異（需主 session 知悉）

1. **`state.log_event` 不存在** → 全部事件改用 `print("[ProsperityAttack]…")` 等。理由：codebase 用 print 觀測，game_sim grep stdout。
2. **`team.is_faction_leader` 不存在** → cadence 改放 `evaluate_all` per-team loop，候選用 `_is_prosperity_candidate`（faction leader_team_id 或 faction_id==-1 獨立團）。plan 原寫 sim_runner，效果相同。
3. **PersonData 欄位是 `id` 非 `person_id`；class_name 是 `FactionAISystem` 非 `FactionAiSystem`**（plan code 筆誤，已修正）。
4. **`combat_target` 不可預設**（plan/spec 都寫 `team.combat_target = prey_id`）：
   - `movement_system.gd:51` → combat_target!=-1 的 team **不移動**
   - `interaction_system.gd:188` → 任一方 combat_target!=-1 **直接 return 不交戰**
   - 正確契約：只設 `current_task="攻擊"/"掠奪"` + `move_target`，到達後由 `interaction_system` 的 `start_combat` 設 combat_target。已照此修正。
5. **新增「追擊刷新」`_refresh_attack_pursuit`**（plan/spec 未提）：攻擊/掠奪 中每 tick 依 `team_intel` 最後已知位置刷新 move_target（移動目標會跑）。模式同 `strategic_ai_system.gd:107`，非新世界規則。
6. **事件觸發 (a) pop 暴跌 / (d) leader values 變動 未接線**：只接了 (b) 新發現。cadence（3日/軍隊1.5日）已保證重評，(a)(d) 屬優化，留待主 session 決定是否補。

## 連動風險

- `vision_system`：新增對 `FactionAISystem.mark_prosperity_recheck` 的 static 呼叫（每次新發現）。極輕量，僅寫一個 int 欄位。
- `movement_system` / `interaction_system`：未改，但本功能依賴其既有契約（同格才交戰、combat_target 語意）。
- `_trigger_survival` Path 1：B 分支讓**有 outpost 的飢餓團**也可能掠奪，與既有 game_sim 行為有差異（spec 風險清單已列）。已驗證 invariant 無違反。
- `encounter_system` occupy 路徑：`_process_occupied_residents` 只在 `attacker_win` 且 prey outpost 上有**第三方居民團**時動作，與既有 5 路 ownership（D B1 capture，line 1138）不重疊。

## 驗證結果

- `headless_test.gd`：**16/16 prosperity 測試綠**，0 SCRIPT ERROR，0 Assertion failed，既有測試無回歸。
- `game_sim_test.gd`：`ALL INVARIANTS PASSED (violations=0)`，0 error，`ProsperityAttack` 事件出現。
- `game_sim_multi.gd`（4 config × 90 天 / 21600 tick）：0 error、**0 invariant violation**、`ProsperityAttack` 觸發 4 次、4 config 全部存活到 21600 tick。

## ★ 待主 session 確認（關鍵）

1. **NPC-NPC 遭遇戰未成形（encounter = 0）** — 最重要：
   - 決策層全通：`ProsperityAttack` 正確排程、task 持續（`_assign_tasks:405` / `_evaluate_solo:611` 都保留「攻擊」）、追擊刷新已加。
   - **瓶頸在 engine 接觸機制**：`interaction_system.process_on_arrival` 只在「兩團同一 hex 且該 tick arrived」才 `start_combat`。漫遊/追擊團極少剛好同格；prey 離開視野後 `team_intel` 凍結，追擊撲向舊位置永遠收不攏。這也是**改版前 baseline 同樣 0 encounter** 的根因。
   - 這需要**新世界規則**（例：相鄰即接戰 / 進入 prey 格即 snap 觸發 / 防守方停留判定），超出本 spec 範圍、屬 architect 決策，故未自行發明。
   - 建議下一個 spec：NPC 交戰「接觸範圍」機制（含防守方 active 行為，spec 已列為後續）。
2. 個性公式魔法數（0.3 / 0.55 / 0.15 / readiness 權重）待 tune — 目前皆 TEST VALUE。
3. 居民拒投靠 `fear = 1 - rep` 過簡，可能誤判（spec 風險已列）。
4. 事件觸發 (a)(d) 是否要補線。
5. B 分支對「有 outpost 飢餓團」行為改變是否符合預期。

## 後續（spec 已列 + 本次發現）

- **★ NPC 交戰接觸機制**（本次發現，阻擋 encounter 成形）
- 多 team 聯合攻打 / 防守方守城撤退 / 戰俘交易 / 戰爭疲勞
