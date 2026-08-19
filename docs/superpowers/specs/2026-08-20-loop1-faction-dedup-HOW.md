# perf/pipeline：loop1 faction 決策雙跑去重（tick-stamp）（HOW / systems）

status: DRAFT→R²（2026-08-20）
owner: systems（HOW）← blueprint 裁定 2026-08-20（方案 (c)、**WHAT 定性=接管語意上的事故非設計**、意圖語意=**每 faction 每 tick 決策一次**、修=**歸正非新設計**）
溯源：perf 線索包① → `near.faction_ai` 獨占 93.1% wall、`loop1.factions`+`loop1.assign_tasks` 合計 **37.8%** 相對占比 → measurer 指出 + **systems code-read 坐實**雙跑。

## §0 命門
- **★這是行為影響道**（perf 憲章）：faction 決策頻率 **2×/tick → 1×/tick** = **fp intended-change** + **全故事審**（憲章①「每改→full sim→Story QA 不降」）。
- **禁降 fidelity**：去重**不減決策深度/廣度**（每 faction 仍每 tick 決策、只是不重複跑第二次）——這正是「歸正」而非「降頻」：**降頻=行為影響道的另一種（每 N tick 才決策），本 slice 不做**。
- **零新旋鈕**：tick-stamp 是機制、非參數。
- **世界若顯著變樣 → Story QA 判、變壞回退重議**（blueprint 裁）。

## §1 現況（grounded、我 code-read 坐實）
- `_evaluate_all_body(state, _team_ids)`（`faction_ai_system.gd:712`）：參數 **`_team_ids` 底線前綴=刻意未用**；迴圈 `for fid in state.factions`=**全量 factions**。每 faction 依序跑 `member_snap`(BeliefSystem.best_estimate per member) → `_update_goals` → `_assign_tasks` → `_evaluate_infrastructure`(interval-gated `% INFRA_INTERVAL`) → `try_proactive_diplomacy`(interval-gated `% FACTION_UPDATE_INTERVAL`)。
- `sim_runner.gd:152`：`{"name":"faction_ai", "fn":"_step6b_faction_ai", **"lod": LOD_BOTH**, "shape":"teams", "tl":"near.faction_ai"}` → **near set 與 far set 各呼一次** → loop1 **每 tick 全量跑兩次**、**LOD 近遠分流對 loop1 完全不生效**。
- **副作用**：interval-gated 的 infra/diplo 在同一 tick **也 fire 兩次**。
- 既有 instance 狀態先例：`_last_site_sig`/`_last_dispatch_fail`（instance 欄、sim_runner 持有穩定 instance）=**同款 bookkeeping pattern 可複用**。

## §2 Task（單一小 slice）
- **T1 tick-stamp 去重（方案 c）**：`FactionAISystem` 加 instance bookkeeping（如 `_loop1_done_tick: Dictionary`，`faction_id → tick`，比照既有 `_last_site_sig` pattern）；`_evaluate_all_body` 迴圈內**每 faction 先檢查**：`if _loop1_done_tick.get(fid, -1) == state.world.current_tick: continue`，處理後蓋章。
  - **語意=first-pass-wins**（同 tick 第二次呼叫全 skip）。
  - **★死團清理**：faction 消滅時清 stamp（or 用 `state.world.current_tick` 比對天然失效、無需清=**優先無需清的寫法**，避免新 leak 面）。
  - **determinism**：dict 只讀寫自身 tick 比對、無 RNG、iteration 序不變（仍 `for fid in state.factions`）。
- **T2 驗雙跑消失**：`loop1.*` phase 計數/呼叫數對半（temp tap 或 TDD 計數）；infra/diplo 同 tick 只 fire 一次。

## §3 gate
1. **★fp intended-change**（預期會變、標注；**非 byte-identical**）。
2. **★全故事審（blueprint 硬要求）**：full sim + Story QA——**世界是否顯著變樣**（faction 目標/任務指派節奏、外交/基建頻率）；**變壞=回退重議**。
3. **regression**：headless 0-new、constitution 75 不回升、既有 slice（settlement/agri/labor/churn）不破。
4. **perf 實收**：`near.faction_ai` 占比 / per-tick 成本前後（期望 loop1 兩桶約省一半≈**19% 量級**、以 measurer ③ 順帶量到的雙跑實際份額為準）。
5. **fidelity 不降**（憲章③）：每 faction 仍**每 tick 決策一次**（非降頻）。

## §4 界外
`unified.rank`(17.5%)/`assign.leader_unified`(12.8%)/`gather.market`(6.7%) 等其餘熱點=後續刀（待 ③scaling 正式版 + hotspot 地圖）。降頻/deferred 類=行為影響道另議。

序：R² → CLEAN → 待 measurer ③ 量到雙跑份額 → dispatch → gate（含全故事審）→ merge。**修好後 blueprint 於 `mechanism-intents` 加 row「faction 決策=每 tick 一次」**（他 owner）。地基 KEEP。
