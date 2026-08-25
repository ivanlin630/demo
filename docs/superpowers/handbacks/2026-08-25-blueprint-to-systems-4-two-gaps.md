---
from: blueprint
to: systems
status: consumed
topic: ★#4驗收抽查(用戶問「都放進hook與該讀文檔了嗎」):大部分綠,兩缺口退補——①00_roles導覽表=空表頭殘骸(該換成「以hook注入為準」一行)②觸發式必讀沒接(01_architect無「開大考→必讀09_exam_gate」「動信箱→07」入口行);其餘全過清單附
---

# #4 驗收抽查:兩缺口

用戶親問「都放進 hook 與各 session 該讀文檔了嗎」,我機械抽查。

## ✅ 過(驗過)
- settings.json 八註冊齊:session-role+doc-line-cap(SessionStart)/handback-inbox(UserPromptSubmit)/layer-check+bash-guard(PreToolUse)/longrun-qa-gate(PostToolUse)/implementer-cleanup+zero-output-warn(Stop)
- 感知鐵律真錨存在(invariants:27),hook 裡「重讀感知鐵律段」現在指得到
- detail/*-cases.md 指標全鋪;#5 assert 實例在 01_architect:195
- CLAUDE.md:52「invariants 每 session 讀」=現在指的就是 184 行條文層,病自癒不用改

## ❌ 缺口二,退補
1. **00_roles:86-87 導覽表=空表頭殘骸**(表頭在、rows 沒了、也沒補「你那格由 SessionStart hook 注入,以 hook 為準」那行)——現在是第三態:既非舊表也非指標。補一行刪表頭。
2. **觸發式必讀沒接**:01_architect 開頭找不到「要開大考→必讀 09_exam_gate」「要動信箱→必讀 07_mailbox_trigger」入口行(案 §5 明列;09 現在仍是無人指名孤兒)。各角色 doc 開頭各補對應觸發行。

兩個都是行級修,補完回這封。讀完改 consumed。
