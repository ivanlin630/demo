# die-off erase spike 批次化 — Plan（L2，root 已定位）

> 藍圖 guard ③（`r1-amendment-guards`）：raid 解鎖 → 滅團潮更頻 → spike 更常咬,**與 R1 同波修**。
> 違反硬不變量「凡 tick 早晚期成本無延遲差」（invariants 效能域,die-off=必收,known_issues 標紅）。
> **Root**（code 已定位,known_issues「★compute」條）：`world_state.gd erase_team` 步 3（全隊 ref-sweep）/步 4（team_known/team_discovered 交叉）/步 4b（team_intel 交叉）= 每 erase ~4 趟 O(N) 全掃;`cleanup_extinct_teams`（faction_ai:1859）滅團潮 K 隊/tick 逐隊呼 → O(K·N) spike,大戲時刻（滅團潮）最會爆。

## 修向：批次 erase（collect dead set → 單趟 sweep）

**零行為變更**：erase 語意/順序完全保留,純複雜度改。seeded pointwise diff 必須 CLEAN（= 最強驗證）。

## Task 1 — baseline measure（先量,不動 code）

seeded warring 長跑（`WarringHarness`,全窗,`GODOT_TIMEOUT=3000` 背景）:
- 每 tick 時間曲線（P0 已有 tick 計時 instrument,沿用）+ 該 tick erase 數（`teams_pending_erase` 大小,加 harness 內觀測,零 production 侵入）。
- 記：中位 tick-time、max spike、spike tick 的 erase K 值（證 spike↔die-off 相關）。
- 產出：baseline 數字進 handback（修後對照）。

## Task 2 — `erase_teams` 批次 API

**檔**：`scripts/data/world_state.gd`、`scripts/simulation/faction_ai_system.gd`（僅 `cleanup_extinct_teams` 函數）

1. `world_state.gd` 新 `erase_teams(tids: Array) -> void`：
   - **每隊局部步驟照舊順序逐隊做**（步1 母子 detach/孤兒化、步2 faction 退出/盟主 disband）——語意不變。
   - **步3/4/4b 合一單趟**：dead set 建 Dictionary（O(1) membership）→ 一趟 `for otid in teams` 清 combat/social/order/strategic/known_reputations/invite/diplomacy_reject 中指向**任一** dead tid 的 ref;一趟 team_known/team_discovered/team_intel 交叉 erase（對每 observer row 逐 dead tid erase,row 內 erase O(1)）。
   - 自身條目（team_known/discovered/intel row + teams.erase）逐 dead tid 收尾。
   - **O(K·N) → O(N + K)**。
2. `erase_team(tid)` 改薄 wrapper：`erase_teams([tid])`（單點呼叫端 beast/encounter/subteam 零改動,語意同）。
3. `cleanup_extinct_teams`：遺財路由迴圈照舊（`_route_extinct_assets` 逐隊,守恆）,結尾一次 `state.erase_teams(pending)` 取代逐隊 erase。print 照舊逐隊印。

## Task 3 — 驗證（修後）

1. **seeded pointwise diff CLEAN**：同 seed WarringHarness 修前/修後逐 tick diff = 0（純 perf 改,行為位元不變——不 CLEAN 即語意破,打回）。
2. **spike 收斂**：Task 1 同 seed 重量,die-off 波 tick-time spike 顯著降（目標:spike ≤ ~2× 中位,TEST 目標;早晚期曲線平 = 不變量達成）。
3. 回歸：headless 全綠（erase 語意測群:懸空 ref 清/子隊孤兒/faction disband/1523/6753 等,1 FAIL pre-existing 容忍）+ 0 SCRIPT ERROR、framework 7/7、coin_eq delta=0（遺財路由守恆不動）、InvariantAudit 0。

## Handback

`docs/superpowers/handbacks/2026-07-02-dieoff-erase-batch.md`（實作→系統）：baseline vs 修後 spike 數字、pointwise CLEAN 證明、偏離處。

## 注意

- Godot 跑一律 `.\tools\godot.ps1` wrapper;重型 seed `GODOT_TIMEOUT=3000` + 背景。
- **scope guard（與 R1R2 軌平行,防衝突）**：本軌只碰 `world_state.gd`（erase 區）+ `faction_ai_system.gd` **僅 `cleanup_extinct_teams` 一函數**。R1R2 軌碰 faction_ai 的 gate/prey/intent 函數——**disjoint 函數,ort auto-merge 慣例**。勿越界。
- 基準：headless 現有 1 FAIL（弱目標未加入攻擊 goal）= pre-existing。
