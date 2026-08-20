---
from: systems
to: implementer
slice: failure-feedback
tier: full
status: consumed
topic: "[派工·執行失敗反饋機制 Phase 0(用戶立法:執行失敗=事件必反饋決策層、禁靜默丟棄、同因禁無記憶反覆撞)·R② CLEAN(判決檔 2026-08-21-reviewer-to-systems-R2-failure-feedback-CLEAN.md)·★★排序:convoy RETURN 那張【先】做完收尾再開這張,別同時開兩個 worktree·★這支是 A1 五族的形狀來源,請當【通用機制】做不是單點修——形狀對了後面四族是照抄,形狀錯代價乘以五·★兩個 R² 要求已摺進 spec:①gate6 回報 order.abandoned 變化的【同一份】報告必須【並排】附 failure.suppressed.<option> 變化量(tap 存在≠有人看;折價會降低嘗試頻率而頻率下降本身就會把症狀數字沖淡,即使 GATE-B 沒修好)②新失敗事件必須在 world_events.gd 登記 kind(FUNC_KINDS 或 STATE_KINDS),沒登記 T0 對帳守衛抓不到這個新來源·四裁定全確認:連續折價非硬cooldown/recent_failures掛隊層非leader p.memory/失效升T0劣勢只折價/反射弧三段同語彙"
---

# 派工：執行失敗反饋機制（Phase 0）

**spec**：`docs/superpowers/specs/2026-08-21-failure-feedback-mechanism-HOW.md`（**R² CLEAN**，判決 `2026-08-21-reviewer-to-systems-R2-failure-feedback-CLEAN.md`）
**branch/worktree**：`feat/failure-feedback`（新建）

## ★★排序：這張排在 convoy RETURN 之後
**先把 `feat/convoy-return-conservation` 做完並 handback 收尾，再開這張。** 別同時開兩個 worktree。

## ★這支要當「通用機制」做，不是單點修
它是 **A1 五族的形狀來源**：形狀對了，**後面四族是照抄**；形狀錯，**代價乘以五**。
示範族 ＝ `order.abandoned`（該世界 94.4%）。

## R² 要求（已摺進 spec，動工照 spec 即可，這裡再點名兩件別漏）
1. **gate 6 的並排要求**：回報 `order.abandoned` 變化的**同一份**報告，**必須並排附上 `failure.suppressed.<option>` 的變化量**。
   理由：**tap 存在 ≠ 有人會去看它**。**折價會降低嘗試頻率，而頻率下降本身就會把症狀數字沖淡**——
   即使底層 GATE-B 完全沒修好，`order.abandoned` 也會變好看。綁同一份報告，「症狀降了但 suppressed 飆高」才會**自動被看見**。
2. **新失敗事件要在 `world_events.gd` 登記 kind**（`FUNC_KINDS` 或 `STATE_KINDS`）。
   **沒登記 → T0 的對帳守衛抓不到這個新來源。**

## 四裁定（R² 全確認，照做別自己改）
- **連續折價，不是硬 cooldown**（硬 cooldown ＝ 補丁閘，會 pre-empt 引擎）。
- **`recent_failures` 掛隊層**，不是 leader 的 `p.memory`（失敗根因是結構性的，**換頭不該失憶**）。
- **失效升 T0；單純劣勢只折價**（失效＝已承諾任務被仲裁拒絕／路不通／目標消失；劣勢＝資源不足／暫時 throttle）。
- **反射弧三段同語彙**（偵測／記錄／重想用同一組名詞——降低後面四族照抄的認知負擔）。

## ★spec §2 是本 spec 最重要的一段，動工前讀
**折價在世界結構性壞掉時，會讓 agent 安靜地放棄** —— 症狀消失、病還在，而且從此量不到。
兩道防線：**floor**（不得歸零）＋ **`failure.recorded.*` / `failure.suppressed.*` 雙 tap**。
**floor 防的是「選項被鎖死」，不防「症狀數字被沖淡」**——後者靠上面那條並排要求擋。

## 新規矩（恢復日起）
長跑前寫 `.claude/hooks/.busy.implementer` beacon（跑完 `rm`）；量測數字帶 **commit＋日期＋重跑指令**；產物 frontmatter 帶 `slice: failure-feedback`（`tier` 我已定 `full`，**不要改**）。
