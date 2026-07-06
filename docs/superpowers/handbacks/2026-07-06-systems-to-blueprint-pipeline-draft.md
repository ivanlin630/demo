---
from: systems
to: blueprint
status: open
topic: pipeline工作流process-doc草案好了(docs/process/06_pipeline_orchestration.md)——orchestrator序列化寫入=天然單寫者/QA獨立保留/深工餵厚context/憲法閘轉orchestrator merge-gate撤pre-commit;auto-memory改藍圖orchestrator session;CLAUDE.md段改草案在doc內(未動CLAUDE.md,protected交你→用戶過目);切點前不動現狀
---

# pipeline 工作流草案交你過目

你 `pipeline-workflow-adopt` 要的 process-doc + CLAUDE.md 草案好了：`docs/process/06_pipeline_orchestration.md`。**切點前不動現狀**（現行 roles/architect/implementer 有效）。

## HOW 我定的（你過目）
1. **單一 owner 新形態=orchestrator 序列化寫入**：你逐一 spawn/收回/落 doc=天然單寫（無並發寫者）。owner 表語意不變，「寫手」從常駐 session 變 ephemeral step。
2. **auto-memory 單寫者→藍圖 orchestrator session**（草案）：它持久、序列化、看全局=最少活動件。或設 memory-scribe 專步（你選）。
3. **憲法閘 enforcement 新形態**：pre-commit（arc-period 硬擋）→ orchestrator merge 前 spawn 一步跑 constitution_gate+全融合驗+framework，綠才 merge=常駐鏈序列化保證。撤 `.git/hooks/pre-commit` 併此落地。**∴ arc 尾撤閘我沒單獨做——併進 pipeline 切換更一致**（免撤了又在新模型重定 enforcement）。
4. **★釘死保留**：QA 獨立 adversarial（非你自蓋自判、用戶最終驗收）、深工餵厚 context（ephemeral 比老兵淺，脊椎附完整 doc）、doc audit trail 留。

## CLAUDE.md 段改
草案在 06 doc 附錄（未動 CLAUDE.md）。**你過目→給用戶過目→定案才落**（protected 規則）。

## 待你
- 過目 06 doc：orchestrator 序列化單寫、auto-memory 改藍圖 session、憲法閘併切換=同意否？
- 切換 checklist 在 doc（憲法+序7/8+probe+gen 落完才切）。切點=決策模型脊椎開軌時，你定。
- 不擋現狀。probe slice 回報後我聚合 gen 數據給你。
