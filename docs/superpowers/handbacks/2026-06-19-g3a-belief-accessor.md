# Hand Back: G3a belief accessor seam

branch: `feat/g3a-belief-accessor`（已 push origin）
plan: `docs/superpowers/plans/2026-06-19-g3a-belief-accessor-seam.md`

## 實作摘要

- `scripts/simulation/belief_system.gd`（新）：`class_name BeliefSystem`，static 單一讀 accessor。
  - `best_estimate(state, obs, tgt) -> Dictionary` = `team_intel.get(obs,{}).get(tgt,{})`（現單 entry 語義）。
  - `has_belief` / `uncertainty`（stub = `1.0 - confidence`，無資料回 1.0）。
- 決策讀者遷 `BeliefSystem.best_estimate`（單 entry 讀，機械等價）：
  - `diplomatic_ai_system.gd`（_get_pop_est）/ `strategic_ai_system.gd`（_get_pop_est + target_pos）/ `threat_assessment.gd` / `faction_ai_system.gd`（5 處：攔截 last_pos / known_member_states / 攻擊 tgt_snap / 商隊 snap / defection 接觸 snap）/ `player_api_mapper.gd`（2 處 intel DTO）。
  - `inquiry_system.gd`：obs-level **key 迭代保留**（讀「對所有 tgt」非單 tgt），僅取 entry 改 `best_estimate`（3 處）。
- `scripts/debug/headless_test.gd`：`_test_belief_accessor()`（新，註冊 _initialize）。
- `docs/invariants.md`：Information 段加「belief 單一 accessor」不變量。
- `docs/known_issues.md`：加「G3 殘缺情報進度」段（G3a ✅ + G3b/c/d OUT）。

## 與 spec 的差異

- **無功能差異**。行為完全保留：accessor 回現單 entry，讀者純機械替換。
- plan 行號為近似（檔案漂移），實際以 grep 定位等價站點。
- plan §118 把 inquiry 列為「`.get(obs).get(tgt)` 同模式」，實際 inquiry 三處是 obs-level **key 迭代**（非單 entry）→ 依 plan §121 指示：保留迭代 keys，僅內部取 entry 改 accessor。故 grep 仍見 inquiry:45/60/89 的 `team_intel.get(obs,{})`（取 key 集），屬預期、非遺漏。

## 回歸

- `headless_test`：`=== DONE ===`、`belief accessor OK`、0 SCRIPT ERROR / assert fail、InvariantAudit 全 OK。**既有測試零變動**（行為等價閘通過）。
- `game_sim_multi`：4 config 全 coin_eq delta=0.00、無 SCRIPT ERROR、跑滿 schedule（warzone 21600 tick）無崩潰。

## 連動風險

- `scripts/ui/sim_bridge.gd:185`：UI 層仍直讀 `_state.team_intel.get(player_tid,{}).get(tid,{})`（單 entry）。**不在本 plan 6 檔讀者清單**（UI bridge 非決策端）。新不變量措辭為「決策讀者」，sim_bridge 屬 UI→DTO。**建議主 session 裁**：是否一併遷（一致性）或留待 UI 邊界批 / G3b。
- 寫端（`message_system` / `vision_system` / `interaction_system` 的 `team_intel[x][y]=...` / `team_intel.has`）**刻意保留**，G3b 改 storage 時一起遷 — 符合 plan OUT。

## 待主 session 確認

- 設計決策：`BeliefSystem.uncertainty` G3a 為 stub（`1 - confidence`），決策端尚無 reader（G3d 才接）。確認此 stub 語義可接受。
- 建議後續 task：
  - sim_bridge.gd:185 遷移歸屬（上述連動風險）。
  - G3b：multi-claim 儲存 + 寫端遷移 + uncertainty 實質（claim 分歧）；屆時只改 `BeliefSystem` 內部，~11 讀者站點零動（de-risk 已達成）。
  - 若 G3 要求迭代「某 obs 的所有 tgt」也走 seam，可加 `BeliefSystem.targets_of(state, obs) -> Array` 收尾 inquiry 的 obs-level 直讀（本 plan 未定義，留 G3b）。
