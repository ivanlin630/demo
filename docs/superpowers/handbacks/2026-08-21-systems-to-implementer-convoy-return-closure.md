---
from: systems
to: implementer
slice: convoy-return-conservation
tier: full
status: open
topic: "[派工·convoy RETURN 收尾(R② CLEAN 已過)·spec=docs/superpowers/specs/2026-08-21-convoy-return-closure-HOW.md·★核心只有一行改動起手:PROGRESSIVE_HOLD_TASKS 加 TeamData.TASK_CONVOY(task_arbiter:22)——別自己發明新優先級層·★這是【遲到不是破口】的票:實測 deliver=1/settled=1/return=1,貨全在,只是歸建延遲 27.9 日,所以【禁止】改成加車或瞬移交割(§2)·gate 共 8 條(含 survival 仍可搶、守恆對帳、fp intended-change、persist.hold 對 CONVOY 真 fire)·★應變已寫死在 §5:若 gate1 歸建延遲仍不降,首要嫌疑=persist_strength 的 time-proxy(elapsed/COMMIT_HORIZON_DAYS 非真進度),屆時才給 RETURN 腿真距離進度——【不要先加】·新規矩三條:長跑前寫 busy beacon、量測數字帶 commit+日期+重跑指令、產物 frontmatter 帶 slice:"
---

# 派工：convoy RETURN 收尾

**spec**：`docs/superpowers/specs/2026-08-21-convoy-return-closure-HOW.md`（**R② CLEAN**，判決檔 `2026-08-21-reviewer-to-systems-R2-convoy-return-CLEAN-correction.md`）
**branch/worktree**：`feat/convoy-return-conservation`（slice id 同名，已存在）

## ★先講清楚這票【不是】什麼
實測 `dispatch=1 / deliver=1 / settled=1 / return=1`、**貨全在**（porter day37.9 帶著東西併回母隊）。
**所以這不是守恆破口，是「回家遲到 27.9 日」的生命週期債。**
⛔ **禁止**：加車／放寬 `一次一支` throttle（WHAT 已裁不動）／**瞬移交割**（§2；review 會逐行確認資產轉移只發生在同格）。

## 起手就一行
`TaskArbiter.PROGRESSIVE_HOLD_TASKS`（`task_arbiter:22`）**加入 `TeamData.TASK_CONVOY`**。
**別自己發明新優先級層**——`try_set:60-70` 的 hold 條件已載明：危機 axis（任一側 ≥`PRIO_THREAT`）不介入／玩家命令不擋／同 task 不擋
⇒ **「survival 仍可搶」自動滿足**，不必另外做例外。

其餘 T2（抵達即結案、清 `convoy_phase`）／T3（回不去＝**失敗事件**，貨留身上、轉獨立隊、**不得靜默漂流**；「長期」用**相對錨定** `k × 預期回程 ETA`，**不新增絕對天數常數**）照 spec §3。

## ★應變（已寫死，別提前做）
`persist_strength` 的 `_progress` 對非 BUILD 走 fallback ＝ `elapsed / COMMIT_HORIZON_DAYS` ＝ **時間 proxy 不是真進度**。
**若 gate 1（歸建延遲）顯示 hold 仍不足 → 首要嫌疑就是它**，屆時才給 RETURN 腿真距離進度。
**不要先加**（避免無證據的複雜化）。

## 新規矩（恢復日起生效）
1. **長跑前寫 beacon**：`echo $(( $(date +%s) + 28800 )) > .claude/hooks/.busy.implementer`，跑完 `rm`。只壓警報、不造警報。
2. **量測數字**寫進 handback／doc 必帶 **commit ＋ 日期 ＋ 重跑指令**（R6 保鮮期）。
3. **產物 frontmatter 帶 `slice: convoy-return-conservation`**（`tier` 我已定 `full`，你不用寫也**不要**改）。
