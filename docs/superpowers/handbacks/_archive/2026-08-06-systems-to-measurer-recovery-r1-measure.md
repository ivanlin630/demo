---
from: systems
to: measurer
status: consumed
topic: "[量 recovery-path Slice R1(feat/recovery-r1 commit 84ef8682)·systems R² merge-gate 已 CLEAN(逐行核 _inflow_est 簽名結構防線+_village_est 建構點:pop 走 belief best_estimate/自身真值、結構欄 own-faction owner-gated 行政記錄、零敵 live-state 讀;三態 REGEN 主導零 if-terrain;determinism byte-identical;r1_test 6/6 含 god-view 硬驗)·★核心量:移民只去『邊際正』的地=三態湧現分化——需自然床有 plains(REGEN8 欠人村 pop<sweet)+forest(REGEN3)+mountain(REGEN0.5)並存、領主有 holding ledger 監看 + anon 池(pop≥CONVOY_MIN_PARENT_POP+BATCH+2=足源)·驗:①plains 欠人村(pop 遠<20 breakeven)→migrant_marginal>0→領主派 migrant(migrant.dispatched fire、migrant.arrived 併入 target)②forest/mountain 村→migrant_marginal≤0→從不派移民(即使 distress、加人加速惡化=正確不救)③migrant.marginal/migrant.mini_util tap dump per-target 真值確認 sign 三態(plains 正/forest·mountain 負)④分化:同領主同機制、plains 村獲移民回補 vs forest/mountain 村不獲(命運分岔由地不由腳本)·★禁靜態斷言、dump 真 per-option util(migrant.marginal note)·MIGRANT_EXPECT_DAYS=30/BATCH=3 TEST VALUE(你校準:sign 三態不依賴此、只 gate 正邊際村值不值移動成本)·避 warring perf、落地 docs/measurements/·回 systems→QA→merge·R2(投資)/R3(遷村)後續·地基 KEEP"
---

# 量 recovery-path Slice R1（移民只去邊際正地=三態湧現分化）

feat/recovery-r1 commit `84ef8682`。**systems R² merge-gate 已 CLEAN**（逐行核：`_inflow_est` 簽名結構防線拿不到 live target；`_village_est` 建構點 pop 走 `BeliefSystem.best_estimate`/自身真值、結構欄 own-faction owner-gated 行政記錄、零敵 live-state；三態 REGEN 主導零 if-terrain；determinism byte-identical；r1_test 6/6 含 god-view 硬驗）。

## ★核心量：移民只去「邊際正」的地（三態湧現分化）
床需求：自然床有 **plains(REGEN8) 欠人村（pop 遠 < 20 breakeven）** + **forest(REGEN3)** + **mountain(REGEN0.5)** 並存；領主有 holding ledger 監看自家村 + anon 池足（pop≥`CONVOY_MIN_PARENT_POP+BATCH+2`）。

驗：
1. **plains 欠人村** → `migrant_marginal>0` → 領主派 migrant（`migrant.dispatched` fire、`migrant.arrived` 併入 target=P2 共址即產能）。
2. **forest/mountain 村** → `migrant_marginal≤0` → **從不派移民**（即使 distress、加人加速惡化=正確不救、非 bug）。
3. **`migrant.marginal` / `migrant.mini_util` tap dump per-target 真值** 確認 sign 三態（plains 正 / forest·mountain 負）。
4. **分化**：同領主同機制、plains 村獲移民回補 vs forest/mountain 村不獲（命運分岔**由地不由腳本**）。

## 守 / 序
- ★**禁靜態斷言**、dump 真 per-option util（`migrant.marginal` note）——同 measure-first 先例。
- `MIGRANT_EXPECT_DAYS=30` / `MIGRANT_BATCH=3` = TEST VALUE（你校準：sign 三態**不依賴**此、只 gate 正邊際村值不值一次性移動成本）。
- 避 warring perf。落地 `docs/measurements/`。回 systems → QA → merge。R2(投資)/R3(遷村)後續 slice。地基 KEEP。
