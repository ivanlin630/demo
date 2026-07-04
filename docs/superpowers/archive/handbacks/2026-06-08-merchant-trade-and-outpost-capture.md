# Hand Back: Merchant Trade (A) + Outpost Capture (D)

實作 plan：`docs/superpowers/plans/2026-06-08-merchant-trade-and-outpost-capture.md`
分支：`feat/merchant-trade-outpost-capture`

## 實作摘要（每檔一行）

- `scripts/data/team_data.gd`：新欄位 `merchant_inventory: Array`、`occupying_outpost_since: int`
- `scripts/simulation/interaction_system.gd`：
  - 新 `_resolve_market(a, b)` 雙向結算（取代舊 `_resolve_trade`）
  - 新 `_attempt_trade_direction(seller, buyer)`：商隊賣 inventory + buyer 商隊買進 inventory + 賣 surplus
  - 新 `_execute_transfer`、`_calc_reserve`
  - `_try_interact` 貿易分支改呼叫 `_resolve_market`
  - `resolve_trade_direct` 改用雙向 `_attempt_trade_direction`
  - 移除 `_resolve_trade`（`_grow_commerce_skill` 保留但目前無呼叫者）
- `scripts/simulation/faction_ai_system.gd`：
  - `_find_trade_target` 改用「最大價差 / 距離」評分（`MERCHANT_MAX_RANGE=20`）
  - 新 `_evaluate_outpost_takeover`（無人 outpost 駐留 3 天接管），整合進 `evaluate_all` team loop
  - 改寫 `_evaluate_uprising`：依 leader values 走 Path A 守城（奪 outpost、保留 PRODUCE）或 Path B 流亡
- `scripts/simulation/encounter_system.gd`：`resolve_encounter_end` 加 B1 武力佔領（敗方所在格 outpost 易主給勝方）
- `scripts/simulation/diplomatic_ai_system.gd`：`_form_alliance` 加居民團（PRODUCE）投降 → outpost 轉給結盟方
- `scripts/simulation/player_command_system.gd`：加 `abandon_outpost` action（棄置自家 outpost）
- `scripts/debug/headless_test.gd`：加 Trade Task1-10 共 9 個新測試 + 修既有 `_test_uprising_trigger`

## 與 spec/plan 的差異（實作判斷）

1. **`_calc_reserve` 改為 target 需求量保留**（plan 原本只處理 food/coin、其他回 0）。
   原因：雙向 market 下，剛買到武器的非商隊團會立刻以自身高 local_value 回賣給商隊（即買即賣 round-trip），導致 Task3 測試失敗且行為不合理。改為其他資源保留至 `pop × TARGET_PER_POP`，teams 不會賣掉自己短缺的物資。
   **副作用**：整體貿易較保守（teams 囤積到 target 才賣）。game_sim 的 Trade FEATURE 仍為 FAIL，但這是 **baseline 既有狀態**（main 上也是 trade_success=0），非本次 regression。

2. **修正 3 個 plan 測試 setup bug**（否則測試無法通過自身設定）：
   - Task6（encounter capture）：plan 測試未建立任何 team，但佔領邏輯需 `state.teams.get(loser_id)` 找敗方所在格。已補建 attacker(0)/defender(99) 於 (4,4)。
   - Task9（uprising paths）：plan 測試未建立 owner team 99，導致 `_is_resident_team` 回 false、起義不觸發。已補建 owner team 99（faction 10）於兩個 state。
   - 既有 `_test_uprising_trigger`：rewrite 後預設 values 會走 Path A，斷言（起義/流亡）會壞。已給 leader 高求生欲 values 使其續走 Path B，保留原斷言。

3. **`_evaluate_uprising` 保留玩家通知與記仇**：plan 的 replacement 片段省略了原本的 `uprising_alert` forced event 與對舊領主的 enemy memory。為避免 regression（玩家失去 outpost 起義提示），兩條皆保留並套用於 A/B 兩路徑。

## 驗證

- `headless_test.gd`：全綠，0 SCRIPT ERROR，DONE，Trade Task1-10 全 OK，既有測試無 regression。
- `game_sim_test.gd`：`ALL INVARIANTS PASSED (violations=0)`，Feature 9/10（baseline main 為 8/10，本分支 Message FEATURE 由 FAIL 變 OK）。Trade FEATURE FAIL 為 baseline 既有，非本次造成。

## 連動風險（主 session 評估是否補修）

- **`_resolve_market` 雙向 + target 保留**：trade 量整體下降，可能影響經濟平衡與商隊獲利曲線。Trade FEATURE 在 game_sim 仍未觸發（seed 下兩團未走進貿易遭遇），建議獨立調 game_sim 劇本驗證真實跑商。
- **`守城` task（Uprising Path A）**：新 task 字串，`_tag_weight` 未列入（回 1.0），但 strategic_ai/其他系統可能覆蓋 `current_task`，需確認守城團不被改回普通 task。
- **encounter 後 outpost 易主**：用 `loser.tile_pos` 找據點；若敗方在易主前已移動/被消滅可能找不到。現實多數情況敗方守在據點格，OK。易主後居民團 owner 變更 → 觸發 spec E `_evaluate_owner_contact` 的 7 天緩衝，連動需觀察。
- **`_evaluate_outpost_takeover` 每 tick 對所有 team 跑**：成本低（單格查詢），但無人 outpost + 多團駐留時最後接管者為 loop 順序最後達標者。
- **商隊買進 inventory**：surplus 段 `_execute_transfer` 已把物品加進 buyer.resources，再從 resources 扣回並 append inventory；已驗證淨額正確（Task3）。
- **`_grow_commerce_skill` 變孤兒函數**：舊 `_resolve_trade` 移除後無呼叫者；新 market 未growth商業技能。若需保留商業成長，主 session 決定是否接回 `_attempt_trade_direction`。

## 待主 session 確認

- 商隊 inventory 上限（連動 wagons）—— 獨立 spec，本次未做。
- 純無人且無居民 outpost 自動棄置 —— 本 spec 未做。
- 殖民/開拓新 outpost（連動 C spec NPC 基建）—— 未做。
- 是否恢復商業技能成長（接回 `_grow_commerce_skill`）。
- 相關 docs（team.md / faction.md / glossary.md）尚未更新新行為，留主 session merge 後補。
