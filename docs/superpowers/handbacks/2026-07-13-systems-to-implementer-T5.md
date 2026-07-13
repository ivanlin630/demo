---
from: systems
to: implementer
status: open
topic: [dispatch·T5] 層內base校+訓練eval-gate對齊——R②CLEAN,normalize收尾slice
---

# Dispatch：T5（層內 base 校 + 訓練 eval-gate 對齊）

R②CLEAN(`T5-r2-verdict`,applicable gate 獨立擋 spurious+人格梯度保+訓練 coeff 承接確認)。spec `docs/superpowers/specs/2026-07-13-term-normalize-T5-intra-layer.md`。normalize 收尾 slice（補「in-band≠competitive」層內漏判）。worktree `feat/term-scale-normalize`（續前 T1-T4）。

## 做什麼（spec 有完整公式）
- **T5.1 base 校**（`terms.gd`）：
  - `prepare_drive`(備戰)：`慎·0.6+好·0.3` → `clampf(慎·0.9 + 好·0.2, 0, 1)`。
  - `settle_fit`(駐守分支)：return `0.6` → `0.9`（生產/建設分支 0.4 **不動**）。
  - `buyfood_drive`(買糧)：`hunger×dist_disc`(已 T1 剝為 dist_disc) → `clampf(0.5 + 0.5×dist_disc, 0, 1)`。
- **T5.2 訓練 eval-gate 對齊**（`decision_context.gd` gather）：`ambient_train_drive` 給值條件 `archetype==FORCE AND rung∈[ACCUMULATE,EXPAND]` → **僅 `archetype==FORCE`**（drop rung；值 0.5 不變）。
- **T5.3 吸納 modest**（`terms.gd` absorb_drive）：`(0.3+0.7×yield)` → `(0.5+0.5×yield)`。
- **T5.4 乞食**→ `docs/known_issues.md` 記：乞食 chosen≈0 = BEG_FLOOR 故意低+applicable 稀有(appl_n 8-180)=合理現象非缺陷（不改 code）。

## 硬約束
- **值域 [0,1]**（clampf）、**零 randf**、逐項 commit。
- **禁 flat-floor 破人格梯度**（備戰好戰隊須仍低）。
- 只動這 4 term/gate + known_issues；不碰他 term、不 pre-tune 幅度（TEST VALUE 初值照 spec）。

## TDD（headless_test.gd）`_test_t5_intra_layer`
- 備戰：謹慎隊(慎0.9好0.2)eval>0.7；好戰隊(慎0.1好0.9)eval<0.4。
- 駐守：settle_fit("駐守")==0.9、settle_fit("生產"/"建設")==0.4。
- 買糧：dist_disc=1→1.0、dist_disc=0→0.5。
- 訓練：FORCE+rung=STATE+has_trainable→ambient_train_drive==0.5；非FORCE→0。

## 回報 → measurer
4 項完 + 融合閘綠 → handback to:measurer 終驗：
- **9-zero 收斂**：備戰/駐守/買糧/訓練/吸納 per-option chosen>0 跨 seed（乞食除外）。剩幾非零報告。
- **既有不回歸**：迎戰/FLEE(好戰隊)、生產/建設(野心隊)、覓食(餓隊)、survival-dominance、determinism、融合閘。
- **優先序保全**：無 non-favorable over-select（備戰無威脅隊/買糧不餓隊/駐守野心隊）。
有 blocker(優先序 organic 破/回歸)→to:systems，別自改。守：不 pre-tune、不問 user。
