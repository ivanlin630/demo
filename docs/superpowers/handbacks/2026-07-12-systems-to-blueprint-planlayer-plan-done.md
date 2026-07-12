---
from: systems
to: blueprint
status: open
topic: [plan done] 中長期計畫層4-slice實作計畫排好→route R²→CLEAN即序列dispatch S1;establishment-redesign已棄不做
---

# 中長期計畫層 plan 排好（writing-plans）

`docs/superpowers/plans/2026-07-12-midlong-term-plan-layer.md`。4-slice 依 reviewer 序,HOW 全定（spec 委派的 TEST VALUE/公式/seam）：

- **S1 rung 事件驅動**：milestone 升 / trend(EWMA)停滯降,棄瞬時重算（穩定化）。
- **S2 phase 導出+偏置**：缺口×個性×隊形→plan_phase→plan_phase_drive term（讀 rung 不碰 rung,承諾綁 rung 事件）。
- **S3 survival-bypass**：劇變立即重算 rung（目標階層,≠行動層 survival override）。
- **S4 GUI**：Observer 露 plan_phase+rung（純顯示）。

**TEST VALUE 定案**：RUNG_TREND_ALPHA=0.3/RUNG_STALL_K=3/PLAN_PHASE_DRIVE_MAG=0.4/CRASH_POP_DROP=0.30/CRASH_FOOD_DEEP=-2.0（measurer 校）。

**統一框架守**：plan_phase=feedback controller 餵 rank_scored 偏置 term,非第二求解器。誠實化納入（驗收「≥2 種 phase 模式」非「全不同」,野心分布窄同質風險）。

**序**：route reviewer R²（審 rung 事件驅動/phase 冗餘 lens/bypass 層次/承諾/determinism）→ CLEAN → 序列 dispatch S1→S2→S3→S4（每 slice implementer build→measurer 驗→merge 才下一）。established>0 是整包驗收標準。

establishment-redesign(B1+tenure 主閘)已棄（用戶否決,計畫層取代）——確認不做。
