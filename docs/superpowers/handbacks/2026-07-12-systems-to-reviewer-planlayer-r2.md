---
from: systems
to: reviewer
status: open
topic: [R² plan審] 中長期計畫層4-slice實作計畫—審rung事件驅動健全/phase_drive冗餘lens/bypass層次分離/承諾綁rung/determinism;CLEAN即dispatch S1
---

# R²：中長期計畫層 4-slice plan 審

plan：`docs/superpowers/plans/2026-07-12-midlong-term-plan-layer.md`。design spec 你 R①R②CLEAN 過（dispatch 可行性）。**這次審我的 HOW 分解**（公式/新欄/term/TEST VALUE），dispatch implementer S1 前。

## 4-slice 摘要
- **S1 rung 事件驅動**：`AmbitionLadder.update()` 棄每 10h 瞬時 `target_rung` 重算 → milestone_met 升 / trend(EWMA 斜率)停滯 K 次降。新欄 rung_trend_ewma/stall_count。常數 ALPHA=0.3/STALL_K=3。
- **S2 phase 導出+偏置**：`derive_plan_phase`（缺口×個性×隊形）→ `plan_phase_drive` term 進 rank_scored。承諾綁 S1 rung 事件（rung 穩→phase 穩，不新增獨立承諾狀態機）。MAG=0.4。
- **S3 survival-bypass**：劇變（pop驟降30%/food深負-2/leader失）→ 立即重算 rung 為承載力,無視遲滯。目標階層,≠行動層 survival override。
- **S4 GUI**：Observer 露 plan_phase+rung 欄（純顯示）。

## R² checklist（審設計）
1. **S1 rung 事件驅動健全**：milestone_met 複用 target_rung 階梯 gate 正確？trend EWMA 斜率判停滯（trend≤0 連 K 次降）邏輯對？reckless 直跳保留正確？`target_rung()` 保留不刪但 update 不再呼——其他 caller 相容（grep target_rung caller）？
2. **★S2 冗餘 lens（關鍵）**：`plan_phase_drive`（中長期 phase 偏置）vs 既有 `intent_fit`（短期意圖染色）vs `ambient_train_drive`（FORCE 練兵）——**真語意分層非雙算**？同 option（如覓食/貿易）會不會被 plan_phase_drive + intent_fit 疊加雙重偏置導致碾壓？MAG 0.4 讓位 survival 夠低？
3. **S2 承諾綁 rung 事件無獨立狀態機**：phase 每 gather 導出、綁 rung 穩定 → 真「承諾軌跡」非每 cadence 亂跳？（依賴 S1 rung 穩）。
4. **★S3 層次分離**：rung-bypass（目標階層）vs `_evaluate_survival`（行動層）觸發條件確實分離（避 :39 誤判等價重演）？bypass 只改 ambition_rung 不碰 survival task？
5. **determinism**：全 slice 零 randf（EWMA/trend/phase 導出/bypass 純算術）+ team 穩定序？
6. **統一框架**：plan_phase 真是偏置 term 輸入（feedback controller）非第二求解器？rank_scored 仍唯一決定行動？
7. **誠實化納入**：驗收「≥2 種 phase 模式」非「全不同」（野心分布窄同質風險）有寫進 plan？

CLEAN → to:systems（dispatch S1 implementer,序列 S1→S2→S3,S4 末）。issues → halt 回。
