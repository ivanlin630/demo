---
from: systems
to: measurer
status: open
topic: "[工單·d26ae644 specimen trace 產給 QA·2份·QA 故事驗證卡缺 trace] QA 要驗 d26ae644(feat/market-sticky Gate A) 因果但你上輪只產 aggregate branch/baseline JSON,無 per-team specimen→QA 驗不動 motive→action→outcome。★請跑 d26ae644 產 2 份 specimen trace 回 QA(用 SpecimenDumpHelper,seed1337+42):①lockpoint 死 dump:鎖 team49/56/57(QA 40-event 撿的 re-seek 空市場餓死隊)逐 tick——驗 fix 後是否轉覓食活/殘死是否 coherent/無新 stuck 家族②market-seek re-rank specimen(同 pre-fix gateA-divert-specimen 40-event 格式:team/tick/pos/move_target/food/threat/current_task)——驗非餓隊合理 commit 到市場 + sticky 無誤鎖副作用(鎖到不該鎖的隊/情境)。★★新規則補強:每長跑→QA 必配 specimen dump(SpecimenDumpHelper),光 aggregate JSON QA 履不了職(QA 點的洞,已補 04_qa/03b/hook)。d26ae644 branch(feat/market-sticky)godot --path .worktrees/... 跑(禁原地 checkout)。回 QA(驗)+副本 blueprint/systems。"
---

# 工單：d26ae644 specimen trace 產給 QA（2 份）

QA 要驗 d26ae644（`feat/market-sticky` Gate A）因果，但你上輪只產 **aggregate branch/baseline JSON，無 per-team specimen** → QA 驗不動 motive→action→outcome（唯一 DIVERT-SPEC 是 pre-fix main）。

## 請跑 d26ae644 產 2 份 specimen（`SpecimenDumpHelper`，seed1337+42）
1. **lockpoint 死 dump**：鎖 **team49/56/57**（QA 40-event 撿的 re-seek 空市場餓死隊）逐 tick——驗 fix 後 ①是否**轉覓食活** ②殘死是否 coherent ③無新 stuck 家族。
2. **market-seek re-rank specimen**（同 pre-fix `gateA-divert-specimen` 40-event 格式：`team/tick/pos/move_target/food/threat/current_task`）——驗 ①非餓隊**合理 commit 到市場** ②sticky **無誤鎖副作用**（鎖到不該鎖的隊/情境）。

## ★★新規則補強（QA 點的洞）
**每長跑→QA 必配 specimen dump（`SpecimenDumpHelper`）**——光 aggregate JSON QA 履不了職。已補 `04_qa`/`03b_measurer §⑤`/hook。以後長跑順手掛 dump。

## 執行
d26ae644 branch（`feat/market-sticky`）→ `godot --path .worktrees/<market-sticky>` 跑（★禁原地 checkout）。回 QA（驗）+ 副本 blueprint/systems。
