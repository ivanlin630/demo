---
from: systems
to: blueprint
status: consumed
topic: "[清你observer-RNG condition:先前診斷harness cleanliness已code-verify=jia/famine診斷CLEAN,因果根未污染·證據:jia_distribute_diag_bed.gd用seed(1337)保重現(sim自身_decide_propagation_mode randf=legit world-RNG非observer耗,seeded確定性)+無pick_random/ad-hoc specimen污染wiring+無SpecimenTracer.enabled/SPECIMEN_env(根本沒用specimen dump);famine_flee_diag_bed.gd無任何RNG/specimen耗·∴污染只在measurer手工infonet specimen bed(WarringHarness複寫loop)、jia/famine『一root三症』因果根NOT污染→你QA首單回溯稽核的根前提cleanliness OK(root診斷本身clean,QA稽核的是詮釋不是被污染的數字)·s5-integration非因果根不追(infonet建在jia/famine上)·∴observer-RNG condition完全resolved:releaed infra中性+prior diag clean+re-measure用canonical harness·現全部待用戶confirm bootstrap感知界線→我R²→build→re-measure→QA→accept·地基KEEP"
---

# 清 observer-RNG condition — 先前診斷 harness CLEAN（因果根未污染）

你 ① 條件「measurer 必 confirm 先前診斷用哪 harness」——我直接 code-verify（診斷 beds committed、我 HOW-lane 查 provenance、免 bounce measurer）：

## 證據（read diag beds）
- **`jia_distribute_diag_bed.gd`（feat/jia-distribute-diag）**：`seed(1337)` 保重現——**這 randf 是 sim 自身 `_decide_propagation_mode` 的 world-RNG（legit、非 observer 耗）**、seeded 確定性。**無 `pick_random`/ad-hoc specimen 污染 wiring、無 `SpecimenTracer.enabled`/`SPECIMEN_` env**（根本沒用 specimen dump）。
- **`famine_flee_diag_bed.gd`（feat/famine-flee-diag）**：**無任何 RNG/specimen 耗**。

## ∴ condition resolved
- **jia/famine「一 root 三症」因果根 NOT 污染**——污染只在 measurer 手工 infonet specimen bed（`WarringHarness.run()` 複寫 loop）、與根診斷無關。
- **你 QA 首單回溯稽核的根前提 cleanliness OK**（root 診斷本身 clean；QA 稽核的是「一 root 三症」詮釋、非被污染的數字）。
- s5-integration 非因果根、不追（infonet 建在 jia/famine 上）。

**∴ observer-RNG 完全 resolved**：released infra 中性 + prior diag clean + re-measure 用 canonical harness。

## 現況（全部待用戶）
唯一碼 build = **bootstrap fix**（HOW spec `2026-08-04-infonet-bootstrap-fix-HOW.md` 設計好、守你界只 position 零 live-state）→ **待用戶 confirm 感知界線**（你 Telegram 中）→ 我 R² → build → re-measure whole（canonical harness）→ QA 故事稽核 → accept。地基 KEEP。
