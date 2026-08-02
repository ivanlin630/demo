---
from: systems
to: implementer
status: consumed
topic: "[dispatch·verification-gate build·結構強制 QA·用戶定] 用戶 rule:有 sim 量測→QA 故事稽核必跑(fail-closed,沒 QA verdict 不准 merge);沒 sim 量測→免(量測 discretionary)。build:(1)verdict schema:.measure.json 加 is_sim 欄、新 .qa.json 格式 (2)verification_gate.gd(sibling constitution_gate):sim-measure 缺 QA PASS→FAIL (3)接 pre-commit hook fail-closed。spec 全文 `specs/2026-07-18-verification-gate-sim-qa-coupling.md`。★R② 先過(gate edge case:stale verdict 誤擋/branch-scoping)。worktree feat/verification-gate off origin/main。"
---

# verification-gate build（結構強制 QA，用戶定 rule）

spec `docs/superpowers/specs/2026-07-18-verification-gate-sim-qa-coupling.md`（讀全）。用戶定：**有 sim 量測就要跑 QA 故事性，沒有就不用**；量測 discretionary（費時）。只堵「sim 量測了卻沒 QA 讀故事」的衰減（attrition 誤讀病）=fail-closed 結構強制非 doc 意圖。

## 交付（讀 spec §交付切片）
- **S1 verification_gate.gd**：掃 `verdicts/*.measure.json`，`is_sim:true` 缺對應 `.qa.json` PASS → `[VERIFICATION-GATE] FAIL`。branch-scoped 優先（避 stale 誤擋）。
- **S2 pre-commit hook**：merge commit 跑 verification_gate，FAIL 擋（同 constitution_gate fail-closed 運輸層）。
- **verdict schema**：`.measure.json` 加 `is_sim` 欄；新 `.qa.json` 格式（見 spec）。
- S3（次階）multi-seed 欄折入——本輪先做 sim→QA coupling。

## ★先 R²（gate 邏輯 edge case）
dispatch 前 to:reviewer R²（stale 舊 verdict 誤擋/branch-scoping/is_sim 判定/hook 繞過）。我另發 R² 工單，你 standby 或先起 verdict schema（低風險部分）。

## 完成 → 下一站
done → to:measurer/QA（採 verdict schema，handback 通知）+ to:systems 判 merge。這 gate 本身 byte-identical（純加工具+hook，不動 sim 行為）→ 免 QA（is_sim=false，正好自證 rule）。

## 溯源
用戶 rule（sim→QA/discretionary）;blueprint fail-closed 結構修法;spec 全文;constitution_gate 先例。
