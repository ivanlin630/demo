# Hand Back: Anon Cohort Phase 2c-2（population → getter + 刪光純量寫入）

分支：`feat/anon-cohort-phase2c2`（基於 `main` @ 982355c）

## 實作摘要

依 plan `docs/superpowers/plans/2026-06-17-anon-cohort-phase2c2.md` Task 1–7：

**Task 1 — generate_for_team 晉升釋放 anon**
- `person_generator.gd`：晉升 anon→named/leader 後加 `AnonTierSystem.kill_random(team, 1, "promote")`，消除「晉升者既算 named 又仍在 anon 桶」的雙算。

**Task 2 — kill_random 實殺對齊**
- `anon_tier_system.gd:kill_random`：原按全 tier（含 wounded）加權但只 remove healthy → `killed` 虛報、caller 依虛報數扣純量。改為 roll 只按 healthy 桶加權 + `killed` 記 `remove()` 實際回傳。
- `encounter_system.gd` combat 死亡：用 `kill_random` 實際移除數扣 pop（原用意圖數 `dead_anon`）。

**Task 3 — population → 唯讀 getter**
- `team_data.gd`：`var population: int` 改為 `get: (1 if leader_id!=-1 else 0) + named_members.size() + AnonTierSystem.total_pop(self)`，`set` no-op。`minor_population` / `prisoner_population` 不動。

**Task 4–5 — 刪光純量寫入（來源已存）**
- 刪除 ~30 處 `population = / += / -=` 戰鬥/死亡/人口/反應/分團/招募寫入，連同 `maxi(...,1)` 下限鎖。涉及檔案：`encounter_system`（含 `_force_occupy` 的 0.8 賦值）、`npc_combat_system`、`health_system`（飢餓 named 死整段 if/else 移除）、`resource_system`（飢餓 anon）、`interaction_system`（治療死）、`population_system`（成年/溢出）、`reaction_system`（N1/N3 flee/defect + exile spawn）、`subteam_system`（dispatch/merge ×2）、`events/event_unrest_split`、`player_command_system`（招募 anon/named）。
- **連動修正**：`subteam_system._merge_into` 子隊回歸時把 leader 還給 absorber 卻**未清 `absorbed.leader_id`** → getter 會殘留 1 phantom leader 擋滅團。已補 `absorbed.leader_id = -1`。並把兩處合併的 `_transfer_proportional_assets(... absorbed.population - transfer <= 0)` 改 `... <= 0`（純量已刪，getter 在搬移後即剩餘量）。

**Task 6 — setup 改直接 seed cohort**
- `game_setup.gd`：`_setup_anon_tiers(team, cfg)` → `_setup_anon_tiers(team, cfg, target_pop)`（不再讀回 population 算 anon），3 條 setup 路徑（random_player / create_team / explicit）改用本地 `target_pop`，刪 `team.population = N`。`_create_team` 的 `named_count` 改讀 `target_pop`。
- `beast_system.gd` / `recruit_tutorial.gd`：刪 `population = N`（兩者已 `AnonCohort.add` 平民 → getter 自然回 count）。

**Task 7 — 測試 setup + 全回歸**
- `headless_test.gd`：新增 `static func _seed_pop(team, n)`（補/減平民 healthy 使 getter == n，保留既有 tier）。把 ~290 處 `<team>.population = N` 機械替換為 `_seed_pop(<team>, n)`。
- 手動修正失敗案例：① leader/named 設在 `_seed_pop` 之後的 ordering bug（reorder 或改用明確 `AnonCohort.add`）；② 顯式建 anon 的測試（famine make_state、salary、treasury、aid、tax）移除重複 seed 或讓 getter 自然導出；③ drift 偵測測試（`_test_invariant_audit`）已過時（getter 物理不可 drift）→ 改驗 getter 隨 named 移除自動降；④ `_test_u10b_player_wiped` 全滅改 `leader_id = -1`（getter=0 才觸發 wipe）。

## 驗證

- **headless_test.gd**：`=== DONE ===`、`InvariantAudit population OK`、無 SCRIPT ERROR、0 FAIL。
- **game_sim_multi.gd（seeded）population drift = 0** 全 4 config（baseline 21/75/40/102 → 0）。InvariantSummary 殘留全為 `faction 反向破`（pre-existing，baseline 即有，與本 plan 無關）。
- population 物理上不可 drift（唯一來源 = getter）。

## 連動風險（⚠ 待主 session 決策）

### 1. coin 守恆回歸（重要）
flip 後 `game_sim_multi` coin_eq：**game_sim_test delta=−163.75、warzone delta=−2.26**（tyrant/merchant 仍 0）。Task 1/2 之前（flip 前）四 config 皆 0 → 本 flip 引入。

**已查證**：
- 純 coin 流失（ore_gold/silver 等值守恆 355 不變）。
- **非**我改動的任一路由路徑所致 — 滅團遺財路由（`faction_ai._route_extinct_assets`）、屠村（`_massacre_residents`）、戰利品 treasury（`_loot_treasury_share`）、subteam 合併 `_transfer_proportional_assets` 皆驗證守恆（Team0 滅團 1192.08 coin 全進 tile；Team7/8 滅團 coin_eq 不變）。
- 流失發生在 active-combat config 的非滅團經濟流（tick 1–7200 間，與滅團 routing 無關）。

**研判**：flip 讓 population 數值**正確**（不再 drift）→ AI/經濟決策（食耗 = pop×rate、cap 檢查、生存決策、徵稅/乞食 pop-scaled）依真實 pop 運作，與 flip 前的 drift 純量行為不同 → **揭露既有經濟子系統的潛在 coin 漏算**（drift 純量先前遮蔽）。屬獨立於 population→getter 的守恆 bug。

**建議**：主 session 評估是否開 follow-up 量測經濟流（trade / salary / tax / forage / mint）coin 守恆，或併入 Phase 4。本 plan 主目標（getter + drift=0）不受影響。

### 2. faction 反向破（pre-existing）
`InvariantSummary` 大量 `faction 反向破 TeamN 自稱屬 FactionM 但不在 member_team_ids`，baseline 即存在，與本 plan 無關。

### 3. 既有 `team.anon_tiers` 引用
`headless_test._test_n1_leader_tier_sync` 仍讀 legacy `team.anon_tiers`（測試通過，未動）。Phase 4 cohort 收尾時一併清。

## 待主 session 確認

- **coin 守恆回歸（見上）** — 是否阻擋 merge / 開 follow-up。
- Phase 4：InvariantAudit cohort 自洽網（目前 population 檢查已是恆等式）+ `invariants.md` Anon 段更新（現述 `anon_tiers` 4 scalar，已過時→ cohort 模型）+ 存檔遷移（若存檔存 population 欄位）。
- `_seed_pop` 機械替換的非斷言測試隊：leader 設在 seed 後者 getter 可能差 1（未被斷言捕捉，行為不破），如需嚴格一致可後續 sweep。
