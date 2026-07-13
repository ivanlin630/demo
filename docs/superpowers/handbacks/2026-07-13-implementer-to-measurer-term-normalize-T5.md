---
from: implementer
to: measurer
status: consumed
topic: term-normalize T5 交付(normalize收尾) — 層內base校+訓練gate;branch feat/term-scale-normalize已push,待終驗9-zero收斂
---
# Hand Back: term-normalize T5（層內 base 校 + 訓練 eval-gate，normalize 收尾）

branch `feat/term-scale-normalize`（已 push，續 T1-T4）。spec `docs/superpowers/specs/2026-07-13-term-normalize-T5-intra-layer.md`。補「in-band≠competitive」層內漏判。

## 實作摘要（逐項）
- **T5.1 base 校**（`terms.gd`）：`prepare_drive`(備戰) 慎·0.6+好·0.3 → `clampf(慎·0.9+好·0.2)`（抬謹慎梯度，好戰隊仍低=保梯度）；`settle_fit`(駐守) 0.6→0.9（生產/建設 0.4 不動）；`buyfood_drive`(買糧) dist_disc → `clampf(0.5+0.5×dist_disc)`（非墊底）。
- **T5.2 訓練 eval-gate 對齊**（`decision_context.gd`）：`ambient_train_drive` 給值條件 `FORCE AND rung∈[ACC,EXP]` → 僅 `FORCE`（drop rung；rung 優先序移 coeff/esteem urgency 承接；值 0.5 不變）。
- **T5.3 吸納 modest**（`terms.gd` absorb_drive）：`(0.3+0.7×yield)`→`(0.5+0.5×yield)`。
- **T5.4 乞食**：`docs/known_issues.md` 記=BEG_FLOOR 低 + applicable 稀有=合理現象（不改 code）。
- TDD `_test_t5_intra_layer`（備戰梯度/駐守0.9/買糧0.5-1/訓練 gate FORCE→0.5·非FORCE→0）PASS。

## 我方自驗（融合閘全綠）
- headless **0 新增 SCRIPT ERROR**（3 pre-existing 同 baseline）；`_test_t5_intra_layer` + T1/T3 test PASS。
- **constitution PASS**（sites=29）；**multi sanity 0 SCRIPT ERROR**；**determinism byte-identical**（1337×1mo cmp）。

## 待終驗（spec §驗收 + 前 T1-T4 handback 承接）
1. **9-zero 收斂**：備戰/駐守/買糧/訓練/吸納 per-option chosen>0 跨 seed（乞食除外，見 known_issues）。**剩幾非零報告**。
2. **既有不回歸**：迎戰/FLEE(好戰隊)、生產/建設(野心隊)、覓食(餓隊)、survival-dominance、determinism、融合閘。
3. **優先序保全**：無 non-favorable over-select（備戰無威脅隊 / 買糧不餓隊 / 駐守野心隊）。
4. **★承接 T1-T4 的 3 organic 觀察項**（見 `2026-07-13-implementer-to-measurer-term-scale-normalize`）：FLEE-safe 地板 / 餓隊 over-loot / belonging solo 宰 + 駐守 affinity actual-heavy 語意。真出問題才帶數據 tune。

## 註
- normalize arc（T1-T5）收尾。全 base term 值域 [0,1]、優先序純由 coeff。baseline 位移非 regression。
- 有優先序 organic 破/回歸 → 我回頭查（非放寬掩蓋）；純現象（乞食/駐守待校）→ 帶數據裁。
