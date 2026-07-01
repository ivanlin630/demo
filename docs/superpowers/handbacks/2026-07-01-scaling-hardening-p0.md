# Hand Back: 後期 scaling 加固 P0 + tick 計時 + scaling bed

branch: `feat/scaling-hardening-p0`（已推 origin，未 merge）
plan: `docs/superpowers/plans/2026-07-01-scaling-hardening-p0.md`

## 實作摘要（每檔一行）

- `scripts/simulation/sim_runner.gd`：**Task1** tick 計時 instrument。`advance_tick` 拆薄 wrapper + `_advance_tick_body`，包真 tick wall-time（含 encounter/ambush/常規三路徑，freeze guards 不計時），日邊界 flush `[TickPerf] avg/max us ticks/teams/factions`，無 per-tick spam。**Task3** 每次 `_step2_move_teams`（near+far 各一）後呼 `state.rebuild_team_tile_index()`。
- `scripts/data/world_state.gd`：**Task3** 加 `teams_by_tile` 空間索引 + `rebuild_team_tile_index()`/`teams_on_tile()`/`teams_within()`/`_tile_key()`。**Task4** `erase_team` 加 team_intel prune（`team_intel.erase(tid)` + 各 observer row 清死 target）。
- `scripts/simulation/faction_ai_system.gd`：**Task3** `_has_hostile_within` 全掃→`teams_within` 鄰域查；`_has_resident_team_on_tile` 全掃→`teams_on_tile`。皆保 live `has`+`hex_dist`/`tile_pos` 復驗（零行為變）。
- `scripts/simulation/interaction_system.gd`：**Task3** `process_on_move`/`process_on_arrival` 同格 co-location 全掃→`teams_on_tile`（保 live 復驗）。
- `scripts/debug/scaling_bed.gd`（新）：**Task2/5** 大 N 階梯測床（100/200/400）。量 evaluate_all / co-location(直量) / 整合 TickPerf / 滅團潮 erase。`_reindex` has_method guard → 同 bed 可量 before/after。
- `scripts/debug/headless_test.gd`：**Task3/4 測先**（`_test_teams_by_tile_index` / `_test_team_intel_prune_on_erase`，均綠）。既有 3 直呼 helper 的單測（`_test_update_guard_ratio`×5、co-location start_combat、`_has_resident_team_check`×3）補 `rebuild_team_tile_index()` 前置。

## 量測結果（Task 5 加固前後對照，同 seed 同 workload）

| 指標 | N | BEFORE(全掃) | AFTER(索引) | 判讀 |
|---|---|---|---|---|
| **co-location** process_on_move(all) | 100/200/400 | 16348/53644/180188 us | 9869/21590/55277 us | **O(N²)→O(N)**：前 3.3×/倍增，後 ~2.2×/倍增；N=400 快 **3.26×**，speedup 隨 N 拉大 |
| evaluate_all (hostile-within) | 100/200/400 | 362823/754261/1627003 us | 357099/754964/1451480 us | **中性**（dense 世界 hostile-within early-return 主導；N=400 −11%） |
| erase (die-off) | 100/200/400 | 241.5/546.6/1147.0 us/erase | 255.2/553.7/1582.0 us/erase | +小（team_intel prune sweep 成本；記憶體改為界住） |
| 整合 TickPerf avg | 400 | 192207 us | 193319 us | 中性（本 bed 隊多在 FAR zone → co-location 少觸發；直量已證增益） |

**核心結論**：空間索引把 **co-location O(N²) 收成 O(N)**（interaction 同格全掃是無 early-return 的真 O(N²)，索引 dict 查 = 最大受益處，且 speedup 隨 N 擴大）。`_has_hostile_within` 在 dense 世界本就 early-return（此 bed 從未真 O(N²)）→ 索引中性；但對 **sparse/frontier 孤立隊**（無鄰敵→全掃無 early-return）索引把 per-call 從 O(N) 壓成 O(鄰域37格)＝late-game 真正 crash tail 的保險。

**零行為變證**：加固前後 bed 三處隊數逐點相同（eval 100/203/411、TickPerf 112/226/455、erase 33/67/136）→ 軌跡一致。

**Task 6（honor-LOD）未觸發**：Task 5 顯 evaluate_all 已是誠實 O(N)（每隊固有 AI 工作，非病態 quadratic；唯一 O(N) inner=hostile-within 已索引化）。honor-LOD 是**行為變**（far 隊降 cadence 決策），measurement 無殘留病態 quadratic 需求 → 依 plan「沒量到不做」**不觸發**。索引已足。

**滅團潮 spike 未收**（誠實記）：erase O(N) ref-sweep 是 die-off 放大器，**不在 P0 三項**（known_issues 另列項）；team_intel prune 反略增 erase 常數（換無界記憶體洩漏修好）。die-off perf 需另案（erase O(N)→索引化/批次），非本輪 scope。

## 回歸閘（Task 7）

- `headless_test.gd`：**PASS ≥ 基準**。1 個 FAIL = **pre-existing baseline**（`弱目標未加入攻擊 goal`，IntelSystem 攻擊決策，與 scaling 無關；加固前即存在），0 SCRIPT ERROR，`=== DONE ===`。
- `game_sim_multi.gd warzone`（21600 ticks）：**CoinAudit delta=0.00**（coin_eq 守恆）、**InvariantSummary 違反=0**、0 SCRIPT ERROR、warring 行為正常（掠奪/徵收/備戰/逃跑 present、IntentThrash 0%、世界存活 14 隊/pop 99）。

## 連動風險（主 session 判是否補修）

- **軌 A（specimen-tracer）merge 衝突**：本軌同觸 `sim_runner`/`world_state`/`faction_ai`/`interaction`/`headless_test` 不同函數（plan 已警）。`advance_tick` 我拆成 wrapper+`_advance_tick_body`——軌 A 若也改 advance_tick 主體需協調。team_intel/erase_team 若軌 A 也動需對齊。**建議系統 session 定 merge 順序**。
- **`teams_by_tile` 新增 state 欄位**：非守恆量、非 InvariantAudit 對象（純加速 cache，每 move 重建）。若他系統直接 mutate `state.teams[x].tile_pos` 後、在同 tick 內於 rebuild 之前查索引 → 會拿 stale。現況所有消費端都在 `_step2_move`→rebuild 之後（faction_ai step6b / interaction step4），且保 live 復驗 → 安全。**新增 tile_pos 寫入點或新消費端須注意此契約**（查前索引須 fresh）。
- **`_has_inflight_settler`(:407) 未改**：它按 `move_target`（目的地）非 `tile_pos` 過濾，tile_pos 索引不適用；候選集本就經 faction+subteam+task 過濾＝極小，非 O(N²) 熱點 → 刻意留全掃。若日後要，需另建 move_target 索引。
- **process_on_arrival 已改索引但 production 未呼**（sim_runner 只用 process_on_move）→ 目前僅單測觸發；一併改保一致，無風險。

## 待主 session 確認

- **plan nit（team_known[obs].erase no-op，world_state:157-158）刻意未修**：invariants:17 記其為 no-op（array 存 MessageData 非 int），但 `_test_erase_team` 用 int 設 `team_known[2]=[1]` 並斷言其被清 → 移除會破該測。低優先＋無害（TTL 覆蓋）→ 保留。若要修需同改測。
- **建議 docs 更新（系統 session owns，我不越界改）**：
  - `known_issues.md`：P0 三項中 **tile→teams 索引 done**（co-location O(N²)→O(N)、hostile-within sparse tail 收）、**team_intel erase-prune done**（top leak 修）；**erase O(N) die-off 放大器仍 open**（未在 P0 收）；honor-LOD 標記「索引已足未觸發」。
  - `progress.md`：記本輪 P0 加固 + tick 計時 instrument + scaling bed 落地。
- **後續 task 建議**：(1) die-off erase O(N) 專案（若長跑滅團潮量到 freeze）；(2) scaling bed 加 sparse+high-movement near-zone 場景，讓整合 TickPerf 也顯 co-location 增益（本輪靠直量證，整合量因 LOD far-zone 稀釋）。
