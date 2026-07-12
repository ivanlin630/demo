---
from: implementer
to: measurer
status: open
topic: 計畫層 S4·末 實作交付 — Observer露plan_phase(純顯示);plan-layer S1-S4全收齊;branch feat/plan-layer-s4已push,待驗收+GUI手驗
---
# Hand Back: 計畫層 S4（GUI 可讀性，末 slice）

branch `feat/plan-layer-s4`（已 push，疊 main 456f110 含 S1-S3）。plan `docs/superpowers/plans/2026-07-12-midlong-term-plan-layer.md` **Task 4**。

## 實作摘要（純顯示層，零 sim 邏輯）
- `scripts/simulation/observer_query_api.gd`：`query_team` + `query_all_teams` 回傳 +`plan_phase`（`rung`/`archetype` 已在）。
- `scripts/ui/observer_inspect_panel.gd`：隊詳情加「計畫：<phase>」行（沿用既有 render pattern，接野心行後）。
- `scripts/debug/observer_inspect_test.gd`：+3 check（query_team plan_phase=求糧 + rung；query_all_teams 含 plan_phase）。

## 我方自驗（供參）
- `observer_inspect_test`：**35/35 PASS**（含 3 新 check）。
- headless regression：**0 新增 SCRIPT ERROR**（3 = pre-existing `_test_p2a_survival_terms`/`_test_beg_join_social_resolve`/`_test_strategic_reads_ladder`，S1 已對照 main baseline 同集）。
- constitution_gate PASS（sites=29，removed=0）。
- 純觀測層（query/panel read-only）→ determinism 不受影響（未觸 sim tick 路徑）。

## 待驗收（plan §驗收 + ★整體）
1. **query 含 plan_phase/rung**：observer 測 35/35 全過（我已綠）。
2. **★截圖 fidelity（你 + 用戶手驗）**：`ObserverMain --obs-*`（見 reference_screenshot_harness）顯攀爬軌跡「計畫：<phase>」行 + 純觀測零 sim 動。此為 fidelity 驗收義務（系統自扛截圖+dump+driver）。
3. **★整體驗收（S4 後 → 你彙整轉 blueprint）**：plan-layer **S1-S4 全收齊**（rung 事件驅動 / phase 偏置 / survival-bypass / GUI）。GUI 跑幾 seed 顯 **≥2 種 phase 模式**（誠實非全不同；併 plan_phase_dist probe 數據）+ established 狀態（爬到立國門口但機械 B-gate 仍擋=已知，立國-redesign 後續）+ 階分布上移。

## 連動風險
- 無（純顯示，read-only）。
- 序列末：S4 merge = 中長期計畫層完整收齊。收齊後 blueprint 排：立國-redesign（填 ESTABLISH phase 空偏置）→ 繁殖/pop arc = established>0 最後兩哩。
