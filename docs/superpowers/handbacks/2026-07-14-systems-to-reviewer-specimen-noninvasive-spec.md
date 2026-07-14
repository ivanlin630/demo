---
from: systems
to: reviewer
status: consumed
topic: "[R② 審設計] specimen 觀測非侵入化——移 LOD-exemption + force_full_hd + jsonl;修觀測不變量違反;CLEAN 才 dispatch"
---

# R② 請審：specimen 觀測非侵入化

spec：`docs/superpowers/specs/2026-07-14-specimen-observer-noninvasive.md`
blueprint 意圖：`2026-07-14-blueprint-to-systems-execlock-verdict.md`（Q2+⚠️，系統優先修，擋 execlock release）

## 一段話根因
measurer side-finding + 我查證坐實：SpecimenTracer 的 specimen 標記把被標記隊強制升 near-LOD（`sim_runner:458/470`）→ 決策 cadence far→near、多跑 pipeline 消耗全域 RNG → 軌跡分化 + 連帶改其他隊（Team20 消失）＝**觀測者改變被觀測物,違剛立的全量暫態可觀測性不變量**,故事性 QA 工具鏈不可信。

## 設計摘要
- **Fix 1**：移 `sim_runner._get_near_teams/_get_far_teams` 的 specimen LOD-exemption → specimen 對 LOD 零影響（player 豁免不動）。
- **Fix 2**：acceptance 故事-trace 床設 `force_full_hd=true`（全隊統一 near→specimen 不特殊→零 per-team 分化 + 零連帶 RNG；完整 trace + 自洽 + determinism）。
- **Fix 3**：`specimen_tracer.gd` 加 `write_jsonl`（純讀，補 Q2a「.specimen.jsonl 產不出」gap）。

## 請你 refute 的點
1. **真根治？**：移 exemption + force_full_hd 是否確保「換 specimen id → 非-specimen 隊 byte-identical」（觀測不變量操作定義）？還是有其他 specimen-gated 侵入路徑我漏了（除 sim_runner LOD，還有沒有別處讀 specimen_team_ids 改行為）？
2. **jsonl writer 純讀？**：`write_jsonl` 是否只讀 entries/append 檔、零 state mutation？
3. **force_full_hd acceptance 的世界對不對**：judged 全-HD 世界 vs 生產 LOD 世界的 story-fidelity 取捨——blueprint 已接受（全-HD=機制 ground truth；LOD-fidelity 另議）。你認同此範圍界定否？
4. **不回歸**：既有 specimen 用途（headless_test specimen=[0]）移 exemption 後在 force_full_hd/team0-near 仍捕？determinism 改善（消 RNG 岔開）？

## 框外審評估
非三對齊（工具修，engage 既有 force_full_hd，非強結論 redirect 大工/非難逆）→ 標準 R②。異議請指出。

CLEAN → dispatch implementer（TDD：先寫「換 specimen→非-specimen byte-identical」failing test）。
（寄件 open，你讀後改 consumed。）
