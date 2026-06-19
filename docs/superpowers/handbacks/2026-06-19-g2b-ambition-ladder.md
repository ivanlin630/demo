# Hand Back: G2b 野心階梯狀態 + 統一 seam

Branch: `feat/g2b-ambition-ladder`（已 push，未 merge）。Plan `docs/superpowers/plans/2026-06-19-g2b-ambition-ladder-seam.md` 全 4 Task 完成。

## 實作摘要

- `scripts/simulation/ambition_ladder.gd`（新，`class_name AmbitionLadder`）：static helper。`derive_archetype`（leader values 最高軸→武力/商業/定居）、`derive_cap`（野心→封頂 rung）、`target_rung`（隊安全 proxy：糧盈餘/人口/faction 規模，capped by cap）、`update`（重 derive + rung 朝 target 移動：躁進直跳/否則一步、安全崩一步退；變動 print `[Ambition]`；設 cadence）。
- `scripts/data/team_data.gd`：加 `ambition_archetype/cap/rung/eval_next_tick`（單一真值源欄位，prosperity_eval 附近）。
- `scripts/simulation/faction_ai_system.gd`：evaluate_all 迴圈，leader 補位後、survival 前注入 cadence `AmbitionLadder.update`。
- `scripts/simulation/strategic_ai_system.gd`：`_update_faction_goals` 重構——expand/trade_net 改**讀 faction-leader 階梯 gate**（武力+rung≥擴張→expand；商業+rung≥積累→trade_net），取代原 raw value 計分。defend 不變。**ambition_rung 的真 consumer（非 dormant）**。
- `scripts/debug/headless_test.gd`：5 測（derive、預設、rung 升降/躁進+安全崩、cap 封頂、strategic 讀階梯 gate）。
- `docs/invariants.md`：加「隊目標單一 owner = leader 野心階梯」不變量。
- `docs/known_issues.md`：G2 進度段（G2a/G2b ✅、G2c/G2d 待）。

## 與 spec 的差異

- **強化 strategic 測試（偏離 plan 測試碼）**：plan 原測無獨立鄰團 → `_nearest_independent` 回 -1 → expand 永不 append → 低 rung assert **不論實作對錯都過**（假綠，pre-impl 也不 fail）。我加了 discovered 獨立鄰團 + 高 rung 應 expand 斷言，讓 gate 真被走查（pre-impl 確實 fail、post-impl 過）。語意與 plan 意圖一致，只是測得更實。其餘照 plan。

## 回歸結果

`=== DONE ===`、0 assertion/SCRIPT ERROR、5 個 ambition 測全 OK、InvariantAudit population/faction/subteam 全 OK、1000 Tick 無崩潰、sim 中 `[Ambition]` rung 變動 20 次（多階弧可觀測）。coin_eq 守恆無破（無 assert fail）。

## 連動風險

- `strategic_ai`：戰略目標**來源換**（raw values→階梯）= **預期行為位移**。原低門檻（expand_score>0.4、trade_score>0.35 幾乎全隊觸發）現改階梯 gate（需 archetype 對 + rung 達標）→ NPC faction 主動 expand/trade 變少、變條件化。骨架求 TEST-VALUE 等價非平衡；multi drift 位移不 gate（plan 明示）。**藍圖需確認 feel**。
- `faction_ai`：每 cadence（100 tick）多一次 `AmbitionLadder.update` 全隊掃，含 `team.population`（cohort getter 投影）。負荷量級同既有 prosperity/threat cadence，無新 O(n²)。
- **換 leader → 階梯重 derive**：繼承後 archetype/cap 可能劇變（方向不連續）。符合 invariant 設計意圖，但藍圖若要平滑過渡需另設計（非本 plan）。
- `prosperity_attack`（faction_ai 內）仍走自己的野心 raw 計分，**未**接階梯——本 plan 只統一 faction strategic_goals 來源。隊級 task override（`get_goal_task_override`）+ prosperity 對齊階梯 = G2c。

## 待主 session 確認

1. **TEST VALUE 全待藍圖磨 feel**（handback `systems-to-blueprint-g2b-feel` 應由系統 session 開）：archetype 軸權重（0.5/0.5）、cap 野心切點（0.3/0.55/0.8）、rung 安全門檻（SURPLUS_DAYS=7/EXPAND_MIN_POP=8/faction teams 2/4）、躁進條件（野心>0.65 且慎重<0.4）、surplus_need 的 2.4 日餐量量級。
2. **strategic 行為位移**是否符藍圖預期（見連動風險）——expand/trade 變稀疏條件化。
3. 後續：G2c（`get_goal_task_override` caller + 每階 task/tag 全表 + prosperity 接階梯）、G2d（私驅動 / `killed` 血仇鏈，用 G2a relation_edges）。
4. 強化測試的偏離（見上）是否接受。
