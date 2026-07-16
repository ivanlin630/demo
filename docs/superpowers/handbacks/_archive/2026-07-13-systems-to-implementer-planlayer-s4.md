---
from: systems
to: implementer
status: consumed
topic: [工單 S4·末] 計畫層 GUI可讀性—Observer露plan_phase+rung欄(純顯示);plan Task4;疊新worktree feat/plan-layer-s4
---

# 工單 S4：GUI 可讀性（計畫層末 slice，純顯示層）

plan：`docs/superpowers/plans/2026-07-12-midlong-term-plan-layer.md` **Task 4**（R² CLEAN）。S1+S2+S3 已 merged main。S4:Observer GUI 露 `plan_phase`+`rung` 欄——看得見各隊攀爬軌跡。**純顯示,零 sim 邏輯。新 worktree `feat/plan-layer-s4` 疊當前 main（已 push，含 S1-S3）。**

## 做（照 plan Task 4 Step 1-6）
- `observer_query_api.gd` team_stats 回傳加 `plan_phase`/`ambition_rung`/`ambition_archetype`。
- Observer 隊詳情面板加一行「計畫: 階N phase (archetype)」——沿用既有 observer inspect panel 結構（`observer_inspect_panel.gd` 等，grep 實名）。
- TDD:`observer_inspect_test.gd` `_test_query_includes_plan_phase`。

## 守（Global Constraints）
- **純顯示,零 sim 邏輯改**（不碰 AmbitionLadder/decision）。
- determinism 不受影響（觀測層）。

## 驗收（handback to:measurer + 用戶手驗）
- query 含 plan_phase/rung（32/32 或既有 observer 測全過）+ 截圖 fidelity（`ObserverMain --obs-*`,見 reference_screenshot_harness）顯攀爬軌跡 + 純觀測零 sim 動。
- **整體驗收（S4 後,to:blueprint）**：GUI 跑幾 seed 顯不同攀爬軌跡（≥2 種 phase 模式，誠實非全不同）+ established 狀態（爬到立國門口但機械 B-gate 仍擋=已知,立國-redesign 後續）+ 階分布上移。

## 註
- **plan-layer 末 slice**——S4 merge = 中長期計畫層 S1-S4 全收齊。
- 收齊後序:立國-redesign（填 ESTABLISH phase 空偏置=加立國意圖層,前查已備）→ 繁殖/pop arc（多路 measure）= established>0 最後兩哩（blueprint 排）。
- 卡點 → to:systems。
