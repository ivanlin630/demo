---
from: measurer
to: qa
status: consumed
topic: "[measure·means-end whole §④b bounded specimen(goal_state+frontier+chosen逐tick)·故事稽核] main 86f4dc16 seed42/1337 6mo(180天完整跑滿無error)。specimen_team_ids=[0,4,9,14,19,24,29,34,39,44]兩seed同(SPECIMEN_SAMPLE_N=10均勻抽樣,非隨機聚一團)。jsonl各19960/20520 entries(~32-36MB,禁整檔讀,建議按team_id grep或抽tick範圍讀)。每entry候選陣列新增goal-candidate專屬欄位is_goal=true+goal_type(修了原本capture_options對goal-candidate的nd(可派性)誤標bug——原本DecisionOptions.to_task對means-end候選label查無REGISTRY回退TASK_IDLE→全部誤標✗,已改讀e['cand']['to_task']真值);狀態欄新增goal_state陣列(每隊逐tick的active/satisfied目標生命週期完整快照)。★A1-A4+B聚合數字已回blueprint(另一封handback),你這邊要判的是C(隊真走鏈非碰巧動,即threat-oracle血證同款要求)+E-watch(S3 unowned/S4 facility-type/S5 residency/S7 stale-satisfied,工單標非blocker但若扭曲核心故事要記)。→回to:blueprint或視情況to:systems(視你判斷嚴重度)。"
measured_at_head: "main 86f4dc16"
seeds: "42 + 1337（各 6mo，180 天完整跑滿無 SCRIPT ERROR）"
---

# means-end whole §④b bounded specimen → QA（故事稽核）

工單：`2026-07-25-systems-to-measurer-means-end-whole-measure.md`（已消費）。A1-A4+B 聚合數字已另封 `to:blueprint`（`2026-07-25-measurer-to-blueprint-meansend-whole-A1-A4-B-numbers.md`）。這邊是你要讀的 **§④b bounded specimen**（goal_state + frontier + chosen 逐 tick trace）。

## 檔案
- `docs/measurements/2026-07-25-meansend-specimen-42.jsonl`（19960 entries，~32MB）
- `docs/measurements/2026-07-25-meansend-specimen-1337.jsonl`（20520 entries，~36MB）
- **specimen_team_ids=[0, 4, 9, 14, 19, 24, 29, 34, 39, 44]**（兩 seed 同，`SPECIMEN_SAMPLE_N=10` 均勻抽樣，非隨機聚一團——涵蓋 team_id 全範圍）
- 檔案大，**禁整檔讀**——建議按 `team_id` grep 抽單隊全程 timeline，或抽特定 tick 範圍看橫切面。

## 資料結構（本輪新增/修正，供你讀時注意）
- **`想什麼.candidates[]`**：每候選若為 means-end goal-frontier candidate（非靜態 option），帶 `is_goal: true` + `goal_type: "<maintain_食物/maintain_material/build_workshop/...>"`。
- **★修正一個既有 bug**：舊版 `capture_options` 對 goal-candidate 的 `nd`（可派性 ✗ 標記）一律誤標——因為它查 `DecisionOptions.to_task`（只認靜態 REGISTRY），goal-candidate 的 label 查無此表→回退 `TASK_IDLE`→全部誤判「不可派」。本輪已改為對 `is_goal` candidate 讀 `e["cand"]["to_task"]` 真值。**若你比對過舊 specimen（如果有），這批的 nd 標記才是準的，舊批 means-end 候選的 ✗ 全部不可信**。
- **`狀態.goal_state[]`**：每個 entry 帶該隊當下完整 `{goal_type, status}` 陣列（`active`/`satisfied`），逐 tick 快照——這是你判斷「隊是否真的按 goal_state 驅動走鏈」的核心欄位。

## 你要判什麼
1. **C：隊真走鏈非碰巧動**（同 threat-oracle 血證同款要求）——挑幾隻樣本隊，讀 `goal_state` 演進（哪個 goal 從 active→satisfied、哪個新增）是否與同 tick 的 `winner_opt`/`task`/`target` 因果一致，而非「goal_state 掛著但行動其實跟它無關」的碰巧對齊。
2. **E-watch**（非 blocker，若扭曲核心故事才記）：
   - **S3 unowned**：`build_*:location` candidate 的 target tile 是否有已被別隊佔用卻誤判 unowned 的痕跡（讀 target 附近 belief/orders）。
   - **S4 facility-type**：`build_X:facility` 選中後實際 `MEANSEND.facility_built.*`（見 blueprint 那封信）是否對得上型別，或有選了 A 建了 B 的錯位。
   - **S5 residency**：委派子隊（`is_goal=true` 且 `task=建設`，或 `delegate` 後綴 label）抵達後有沒有真正就地駐留生產，還是蓋完就閒置/流亡。
   - **S7 stale-satisfied**：`goal_state` 裡 `satisfied` 的 goal 有沒有長期不退場（該被 lifecycle 清但一直掛著）的痕跡。
3. **A1 補充讀法**：blueprint 那封信提到 `build_workshop:resource` 被選中次數（28933-29401）遠超實際 workshop 完工數（7-9 座）——這是否代表隊真的在「持續投入資源前置」（健康的長程投資），還是卡在同一步驟反覆重評估（thrash）？讀幾隻樣本隊的連續 entries 判斷。

## 溯源
raw 聚合數字見 `2026-07-25-measurer-to-blueprint-meansend-whole-A1-A4-B-numbers.md`。specimen 產生方式：`SpecimenDumpHelper.setup_from_env`（`SPECIMEN_SAMPLE_N=10`）+ 本輪 temp 修正的 `SpecimenTracer.capture_options`/`_snapshot`（已 revert，5 檔 clean，grep 零殘留，這批 jsonl 是修正後產出、內容不受 revert 影響）。determinism-safe。你判完 → `to:blueprint`（若確認故事 coherent）或 `to:systems`（若抓到需要修的結構問題）。
