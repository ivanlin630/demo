---
from: implementer
to: measurer
status: open
topic: 計畫層 S3 實作交付 — survival-bypass劇變立即重算rung;branch feat/plan-layer-s3已push,待驗收
---
# Hand Back: 計畫層 S3（survival-bypass）

branch `feat/plan-layer-s3`（已 push，疊 main cbfe36f 含 S1+S2）。plan `docs/superpowers/plans/2026-07-12-midlong-term-plan-layer.md` **Task 3**。

## 實作摘要
- `scripts/data/team_data.gd`：+`rung_pop_last: int`（算單期 pop 驟降）。
- `scripts/simulation/ambition_ladder.gd`：
  - 常數 `RUNG_CRASH_POP_DROP_PCT=0.30` / `RUNG_CRASH_FOOD_DEEP=-2.0`。
  - `update()` 開頭（leader 取得後、正常升降前）加 bypass：劇變（`pop 驟降>30%` / `food_flow<-2.0` / `leader==null`）→ 立即重算 rung 為承載力（`RUNG_SURVIVE` 起連續 `milestone_met` 爬到最高，capped）→ set + `return`（跳過正常升降/stall）。非劇變則更新 `rung_pop_last` 續走正常路。+`g2.ambition_crash_bypass` probe。
- `scripts/debug/headless_test.gd`：+`_test_plan_rung_bypass`（pop 20→10 驟降 + food -3.0 → rung EXPAND→SURVIVE 立即，`rung_stall_count==0` 不經遲滯）。

## ★層次分離（R² 驗過）
- bypass **只改 `ambition_rung`（目標階層）**，不碰 `_evaluate_survival`（行動層插隊覓食）、不碰 task/option 派工。
- 觸發條件各自獨立（bypass=劇變幅度 vs survival override=當下飢餓）→ 避 :39 誤判等價重演。
- bypass = S1 milestone demote 的補充（demote=連續 K 失守含 plateau；bypass=單 cadence 劇變立即，跳 K 遲滯）。

## 我方自驗（供參）
- headless `=== DONE ===`，`[OK] _test_plan_rung_bypass` + `[OK] _test_plan_rung_event_driven`（S1 未回歸）。
- **0 新增 SCRIPT ERROR**：3 = pre-existing（`_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`，S1 已對照 main baseline 同集）。
- **determinism byte-identical**（`WARRING_SEEDS=1337 WARRING_MONTHS=1` 兩跑 `cmp`；純算術零 randf）。
- constitution_gate PASS（sites=29，removed=0）。

## 待驗收（plan §驗收）
1. **劇變隊 rung 立即反映**：不卡舊高階持續失敗到 K；`g2.ambition_crash_bypass` probe 計數。
2. **崩潰矩陣**：加 bypass 後死磕原地減少（re-plan 遷移/投靠苗頭）——rung 立即下修 → phase（S2 每 gather 導出）自動跟 → 決策偏置改。對照 pre-S3 baseline。
3. **determinism** byte-identical（我初驗 1seed×1mo；你擴）。baseline 位移標記（plan-layer S3 位移）。
4. **融合閘**：constitution（我綠）/coin/framework/sanity 綠。

## 連動風險
- bypass 立即下修 rung → S2 phase 導出隨之變（rung 讀入 derive_plan_phase 間接）→ 決策偏置位移（baseline 位移）。
- 與 survival 行動層獨立（不同觸發），無雙重插隊。
- 序列：S3 merge 後 systems dispatch S4（GUI，最後）。
