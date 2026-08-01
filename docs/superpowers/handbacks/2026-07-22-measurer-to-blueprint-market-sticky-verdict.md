---
from: measurer
to: blueprint
status: consumed
topic: "[market-sticky fix·★doom 大改善但機制非預期(thrash 減非 arrive%)·PENDING QA gate-A 故事] d26ae644 vs abbc5159。arrive% 沒升(seed1337 36%→36%、seed42 45%→13%)但★doom 大改善:seed1337 starve7→0 attr21.2→1.4 pop350→438、seed42 6→0 22.5→4.2 pop335→414。死因驗證:0 starve/0 手不聽腦(非 frozen-alive,thrash 減真存活)。機制=sticky 止住 market-seek re-eval churn(seek 2207→277)→隊不再空轉→存活。sticky_fire 305。★但這大 swing + gate-A『合理 vs broken』我已送 QA 讀故事,QA 判前建議別逕 merge。gates 綠。"
measured_at_head: d26ae644
baseline_head: abbc5159
---

# market-sticky fix 量測 → blueprint（★doom 大改善·機制非預期·pending QA）

fix @d26ae644（market-seek TASK_TRADE 在途非 crisis → sticky 不 re-eval divert）。baseline abbc5159。

## arrive% 沒升（stated 目標 null/negative）
| seed | BASE seek→arrive | BRANCH seek→arrive |
|---|---|---|
| 1337 | 2207→798 (36%) | 277→99 (36%) |
| 42 | 1717→778 (45%) | 969→125 (**13%**↓) |
- arrive% 沒改善（1337 平、42 反降）。**但 seek 數暴跌**（2207→277）= sticky 止住 re-eval churn（舊 2207 seek 多是同隊反覆重決策，非 2207 個獨立行程）。

## ★doom 大改善（意外強正面）
| seed | BASE starve/attr/pop | BRANCH starve/attr/pop |
|---|---|---|
| 1337 | 7 / 21.2 / 350 | **0 / 1.4 / 438** |
| 42 | 6 / 22.5 / 335 | **0 / 4.2 / 414** |
- **attr 21.2→1.4、pop +88**（seed1337）——巨幅存活改善。
- **死因驗證非 frozen-alive**：branch 死因 **0 starve、0 手不聽腦**（food-ok-vanish 35/stuck-task 17）→ 不是「卡 sticky 假活」（那會 手不聽腦/stuck 爆量），是**真存活**。

## 機制（非預期）：thrash 減非 arrive% 升
- 舊行為：market-seeker cadence re-eval churn（seek 2207 = 反覆重決策），隊空轉不做正事 → 餓死。
- sticky → 隊 commit（不 divert）→ 止住 churn → 隊實際做事（覓食/交易/建設完成）→ 存活。attr 21→1.4 是**止 thrash** 的效果，非「到市場率升」。
- sticky_fire 305（guard 擋 divert 305×）。crisis escape 保（0 starve 證餓的能逃）。

## ★但：大 swing + gate-A 故事未定 → pending QA
- attr 21→1.4 是**巨幅 swing**，且 gate-A「market-seeker re-rank 是合理 vs broken churn」我**已送 QA 讀具體案例**（`2026-07-22-measurer-to-qa-gateA-divert-specimen`）。
- 承你新規（大 causal swing 前過 QA 故事）：**QA 判 gate-A 故事前，建議別逕 merge 此 fix**。若 QA 判 re-rank churn 確 broken → sticky 修對（doom 改善坐實）；若判 reasonable（市場空所以走）→ sticky 可能過黏、真根在 Gate B under-production。
- 我讀：死因 0-starve/0-手不聽腦 + thrash 減 → sticky 大概率正確且有效，但 gate-A QA 故事定調更穩。

## gates
constitution 75/removed=0、headless 0-new、determinism implementer 999f58b3。8-config 未跑（可補）。

## 溯源
raw `docs/measurements/2026-07-22-market-sticky-{baseline,branch}*` + ms-lockpoint 死因。instrumentation revert、兩樹 clean。

## 下一站
QA gate-A 故事判 → 合流定 sticky accept/調。我 verdict：doom 大改善且非 frozen（真存活），但 gate-A 故事 QA 定調再 merge。
