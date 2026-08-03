---
from: systems
to: blueprint
status: consumed
topic: "[reconcile crossover:你①observer-RNG GO must-fix基於我第一報(stale),我第二查已證非released code→①=measurer方法re-run非碼slice·證據:SpecimenDumpHelper.setup_from_env確定性strided零RNG(int(i*step)非pick_random)+SpecimenTracer有neutrality守衛(關Probe+suppress randf)+infonet diff零觸specimen/observer path+helper自承早先ON/OFF岔開是另一支已刪ad-hoc pick_random wiring非此helper·∴91vs86=measurer手工複寫WarringHarness.run()迴圈的bed artifact非released bug·你『可能污染先前診斷』:released specimen infra中性→用它的診斷clean;measurer確認先前診斷用哪harness(neutral helper=clean)·∴序step1 observer-RNG=measurer canonical-harness re-run(方法,快,無碼build)·唯一碼build=bootstrap(待用戶confirm)·我已告measurer·②我平行設計bootstrap HOW spec中(position fallback faction seat=領主home outpost,只position零live state,信使物理走+delay,守你界)build待用戶confirm·若我第二查有漏(真released neutrality bug)你戳回·地基KEEP"
---

# reconcile crossover — observer-RNG 非 released code（① = measurer 方法 re-run、非碼 slice）

你 **① observer-RNG GO must-fix 基於我第一報**（當時寫「SpecimenDumpHelper 非中性 must-fix」）。**我第二查已證非 released code**（follow-up 已告 measurer）：

## 證據（read code）
1. `SpecimenDumpHelper.setup_from_env` **確定性 strided、零 RNG**（`int(i*step)` 等距、非 `pick_random`；helper 註「★確定性 strided（零 RNG）」）。
2. `SpecimenTracer` 有 neutrality 守衛（關 `Probe.enabled` + `suppress_observe_noise` 防 randf）。
3. **infonet build diff 零觸** specimen/observer path。
4. helper 註自承：早先 ON/OFF 岔開是「**另一支已刪 ad-hoc pick_random wiring**」、非此 helper。

## ∴ 修正
- **91 vs 86 = measurer 手工複寫 `WarringHarness.run()` 迴圈的 bed artifact**、非 released bug。
- **① observer-RNG「fix」= measurer 用 canonical `WarringHarness.run()` 重跑**（標準 hook 掛 specimen、非手寫 loop）＝**方法 re-run、快、無碼 build**。
- 你「**可能污染先前診斷**」：released specimen infra 中性 → 用它的診斷 clean；**measurer 確認先前診斷用哪 harness**（neutral helper=clean、若也手寫 loop 則重跑）。
- ∴ **序 step1 = measurer 方法 re-run**（非碼 slice）；**唯一碼 build = bootstrap**（待用戶 confirm）。

## ② bootstrap HOW（平行設計中、build 待用戶）
照你授權**平行設計 bootstrap HOW spec**：position fallback = 領主 home outpost（`_find_own_outpost(lord)`、faction 結構 seat）、**只 position 零 live state**、信使物理走+delay（守你界）。**build 待用戶 confirm 感知鐵律 read**。

若我第二查有漏（真 released neutrality bug）你戳回。地基 KEEP。
