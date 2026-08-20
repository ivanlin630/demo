---
from: blueprint
to: reviewer
status: consumed
topic: "[R²設計審(大框program、升異質框外審):框架收尾兩硬綠spec=docs/superpowers/specs/2026-08-07-framework-completion-two-hard-green-design.md·前提已grounding file:line坐實(R①免、grounding doc做過re-verify)→本審=設計對抗非factcheck·審點:①兩硬綠完成標準可證得出否(硬綠②『可擴充』的擴充性稽核=加mock新行為域只動一模組——這判準夠operational嗎?會不會空泛無法machine-verify?)②守則2『純結構重構byte-identical』夠不夠擋『refactor偷夾行為變更』(還缺啥安全網?)③序A→B『先行為抽引擎再切模組』真的反序=白工嗎、有無反例(某模組先切更省)?④scope邊界『WorldState re-arch不做』=正當park還是逃避真問題(god-object消滅但62系統仍共讀WorldState,可擴充硬綠達得成嗎)?⑤§5照妖鏡分類判準physical-viability vs death-constant會不會有灰色地帶大到判準失效(FORAGE_VIABLE_POP該留該化)?CLEAN→鎖→systems slice F1 HOW·框外框:這program框對嗎、有無更省的attack順序"
---

# R² 設計審（大框、升異質框外審）：框架收尾兩硬綠 program

spec：`2026-08-07-framework-completion-two-hard-green-design.md`。前提已 grounding file:line 坐實（R① 免）→ 本審 = **設計對抗**。

## 審點
1. **兩硬綠可證得出否**：硬綠②「可擴充」判準 = 加 mock 新行為域只動一模組 + 引擎註冊——**夠 operational 嗎？會不會空泛無法 machine-verify？**
2. **守則2 byte-identical 夠不夠擋「refactor 偷夾行為變更」**？還缺啥安全網？
3. **序 A→B 真反序=白工嗎**？有無反例（某模組先切更省）？
4. **★scope 邊界「WorldState re-arch 不做」= 正當 park 還是逃避**？god-object 消滅但 62 系統仍共讀 WorldState，**可擴充硬綠達得成嗎**？
5. **§5 照妖鏡分類判準**（physical-viability vs death-constant）會不會灰色地帶大到判準失效（FORAGE_VIABLE_POP 該留該化）？

★**框外框**：這 program 框對嗎、有無更省的 attack 順序。CLEAN → 鎖 → systems slice F1 HOW。
