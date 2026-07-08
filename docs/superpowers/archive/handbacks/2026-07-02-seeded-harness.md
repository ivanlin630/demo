# Hand Back: seeded warring 回歸 harness

branch: `feat/seeded-harness`（已 push，未 merge）
spec: `specs/2026-07-02-seeded-warring-harness-design.md`
plan: `plans/2026-07-02-seeded-warring-harness.md`
性質：純 debug/infra，**零 sim 邏輯變**（seed 只定 RNG 序，不改機制）。

## 實作摘要
- `scripts/debug/warring_harness.gd`（新）：`WarringHarness.run(world_seed, total_ticks, config_path)` 共用 seeded runner。`seed(world_seed)` 播 global RNG + `config["seed"]=world_seed` 播 setup RNG → 逐 tick 逐隊確定。回結構化 metric dict（`curve` 月快照[teams/factions/established/pop/intent] + final `intent` + `final` + `probe` 子集 + `attrition_pct`）。檔頭載完整 RNG 盤點。
- `scripts/debug/seeded_warring_bed.gd`（新）：before/after 對照床。env `WARRING_SEEDS`(逗號多 seed,default `1337,42,7`)/`WARRING_MONTHS`(default 3)/`WARRING_OUT`(dump baseline JSON)/`WARRING_BASELINE`(讀回逐葉 pointwise diff)。遞迴 `_diff_recursive` 印每 seed 每葉 `path: base → cur`，`total_diffs=0` = 零行為變證。
- `scripts/debug/warring_states_seed.gd`：加 `WARRING_SEED` env（default 1337）+ `seed()` 開頭 + `config.seed` 覆寫 → 既有 harness 亦重現。保留原有 rich print/probe dump。
- `scripts/debug/headless_test.gd`：`_test_seeded_warring_reproducible`（同 seed 兩跑 curve/intent/probe/final 逐點相同）+ 註冊入 `_initialize`。

## 驗收證據
- **重現性（TDD）**：RED = 未 seed 時 run 2 續 run 1 global RNG 流 → metric drift → assert 觸發（已親見 SCRIPT ERROR@15325）。GREEN = 加 `seed()`+`config.seed` → `seeded warring reproducible OK`。
- **對照床**：seed=1337 1月 dump baseline → 同 seed 重跑 compare → `[same] total_diffs=0`（determinism + diff 路徑雙證）。
- **守恆閘（Task 4）**：headless `=== DONE ===`、新 FAIL=0、SCRIPT_ERR=0；coin_eq(投靠守恆) 清；framework S1-S6 = **PASS=7 DORMANT=0**。
- **baseline 現況**：headless 有 **1 個 preexisting FAIL**＝`弱目標未加入攻擊 goal`（headless_test.gd:15325 一帶的 `_ad_*` 攻擊決策 scenario），**與本軌無關**（我 checkout 前即在、改動前 3/3 復現）、屬 sim-logic（faction_ai `_update_goals` 意圖層）非 debug/infra。**未修**（越界）。呈報主 session 裁。

## RNG 盤點結果（Task 2）
- setup（`game_setup.gd:29` / `world_generator.gd:34` / `person_generator.gd:45,118`）：local `RandomNumberGenerator`，seed 自 `config.seed` → 已確定。
- runtime：72 處 bare global `randf()/randi()`（sim 全系統）→ `seed()` 播 global RNG 全納。
- `world_generator.gd:36 rng.randomize()`：僅 `config.seed==-1` 走；harness 覆寫 config.seed → **不走**。
- `Time.get_ticks_usec()`（`sim_runner.gd:76,78`）：僅 perf 計時，不入 sim state/metric → 不影響確定性（metric 亦不含 TickPerf）。
- **未納**：`scaling_bed.gd:71` 自有 `RandomNumberGenerator.new()` = 獨立 debug 床（非 warring harness）→ scope 外，誠實記。
- 無 wall-clock/hash-order 進 sim（spec 風險項清）。

## means-end over-war 4pp 重測結論（訊號/噪）
- 直接跨 pre/post-means-end code 的 4pp 重測**需 pre-change ref dump**（該 code 已 merged 上 main，本軌無此 ref）→ 未直接出數。
- **但 demo 已成立**：同 seed 同 code → `total_diffs=0`（noise floor = **0**）。故 seeded 下任何跨 code-change 的 over-war metric delta **必為訊號非噪**。harness 交付「4pp 可硬斷」的能力；實際 4pp 判定＝主 session 於 means-end 前 commit dump `WARRING_OUT` baseline，切後 branch `WARRING_BASELINE` diff 即得。

## 連動風險
- `warring_states_seed.gd`：改為 seeded（default 1337）。行為機制不變，僅 RNG 序固定 → 該 harness 輸出數字自此可重現（前不可）。無下游 consumer 依賴其舊 drift 數字（[[reference_multi_sanity_unseeded]] 早記 warring drift 不可重現、回歸閘不靠它）。
- `headless_test.gd`：+2×1200 tick 重現性測 → suite 跑時略增（數秒級）。
- 與 capture(軌1)/combat_target(軌2)：純 debug/infra，disjoint（僅 headless_test 各加測，auto-merge 友善）。
- 無 sim 系統受影響（seed()/config.seed 僅測試腳本內設，不入生產路徑）。

## 待主 session 確認
1. **preexisting FAIL `弱目標未加入攻擊 goal`**：sim-logic bug（faction_ai 意圖層），非本軌。是否開單修？（諷刺：正是此 harness 要硬斷的 emergence 類問題——seeded 後可判其穩定性。）
2. **bed default 值**：`WARRING_SEEDS="1337,42,7"` × `WARRING_MONTHS=3` 全跑於 105-team 規模 ~32ms/tick → 單 invocation 遠超 360s default timeout。bed = 手動 opt-in infra（非 auto gate），需 `GODOT_TIMEOUT` 拉 + 按需縮 seed/月。是否要我加更保守 default 或文件警語？
3. **回歸閘化（spec C，可選）**：關鍵 emergence metric（CONQUER>0/over-war<閾/capture>閾/不 mass-starve）seeded 斷言常駐閘——spec 標「先 harness 出數,閘化按需」→ 未做。要否後續補？
4. **docs 更新**：progress.md / known_issues.md（統一矩陣、reference_multi_sanity_unseeded 相關）由系統 session owner 更新——本 handback 帶資訊，未動 owned docs。
