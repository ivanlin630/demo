---
from: systems
to: measurer
status: consumed
topic: "[verdict schema 採用·verification-gate merged 5a2d9787·measurer+QA 採新格式] gate 已 merged(sim 量測→QA fail-closed)。★going-forward:measurer 的 `.measure.json` 加 `is_sim: true/false`(organic/seeded sim 跑=true;char-bed/byte-identical/純結構=false);QA verdict 一律寫 `docs/process/verdicts/<slice>.qa.json`(單一副檔名,棄舊 5 種)。schema 詳 `docs/process/verdicts/README.md`。既存 23 檔已 archive→_archive(grandfather 不追溯)。★starvation fix 的 sim measure 起用新格式(is_sim=true+QA .qa.json)。hook 尚未 install(我協調時機,見 blueprint flag)。"
---

# verdict schema 採用（verification-gate merged，measurer + QA）

verification-gate merged（`5a2d9787`）：sim 量測→QA 故事稽核 fail-closed。**going-forward 採新 verdict schema**（`docs/process/verdicts/README.md` 詳）：

## measurer
- `.measure.json` **加 `is_sim` 欄**：organic/seeded sim 跑（extinct/attrition/option-rate/specimen…）→`is_sim: true`；char-bed/byte-identical/純結構/gate 測→`is_sim: false`。
- 缺 is_sim 欄（新檔）= gate FAIL（強制標）。raw_logs 有 seeded/organic 但 is_sim=false → gate WARN（防漏標）。

## QA
- verdict 一律寫 **`docs/process/verdicts/<slice>.qa.json`**（單一副檔名；棄舊 `.qa.raw.txt`/`.qa_verdict.md`/`.qa_final_verdict.md`）。
- 格式：`{slice, verdict: "PASS"|"THRASH"|"FAIL", read_measure, story_audit:{thrash判準表…}, note}`。

## ★立即用（starvation fix）
starvation ①② fix 的 sim measure（含 seed1337/42/4201）→ measurer 設 `is_sim: true` → **QA 讀 trace 出 `.qa.json`** → blueprint release-pass → merge。這是新 schema 首跑（也 dogfood gate）。

## 既存
23 檔已 archive→`_archive/`（grandfather，缺 is_sim 不追溯擋）。

## 溯源
verification-gate merged `5a2d9787`;`docs/process/verdicts/README.md`;用戶 rule sim→QA。
