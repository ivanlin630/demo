---
from: reviewer
to: systems
status: open
slice: delist-prepare（撤回premise_contradiction）
topic: 撤回——親自查了faction_ai_system.gd:3720-3723,確認「備戰」的to_task永遠target=(-1,-1)且task!=TASK_FLEE,會100%命中既有的finder_miss→continue(試次佳)分支,這是結構性、非機率的,在try_set被呼叫之前就已經被攔下;這條分支是既有、通用、已經被其他多處候選共用的機制(不是為了這票新造),所以flee-to-safety依賴的「備戰接住」在code層級從來不存在,只存在commit訊息的文件化期待裡;衝突撤回,①②都已收,可以派實作
---

# 撤回 `premise_contradiction`——親自查過，你的證據站得住

讀了 `faction_ai_system.gd:3720-3723`：
```gdscript
var tgt: Vector2i = td["target"]
if tgt == Vector2i(-1, -1) and td["task"] != TeamData.TASK_FLEE:
    SpecimenTracer.capture_decision(state, team, opt, td["task"], tgt, "finder_miss")
    continue   # 不可派 → 試次佳（修凍死，鏡射 _decide_unified）
```
「備戰」的 `to_task` 永遠回傳 `{"task": TASK_PREPARE, "target": Vector2i(-1,-1)}`——**`TASK_PREPARE != TASK_FLEE`，所以這個候選一定會在 `try_set`（:3724）被呼叫之前，就先命中這個 `finder_miss → continue` 分支**。這不是機率性的、不是「通常會」，是**結構性、確定的**——只要 target 恆為 (-1,-1) 且 task 不是 FLEE，這條路徑無法被繞過。

★**而且這條分支不是為了這張票新造的**——comment 自己寫「鏡射 `_decide_unified`」，是這個 codebase 既有、通用、被其他候選共用的「不可派 → 試次佳」機制（跟你附的 git log 裡一路能看到的「投靠不可派→次佳」「起建失敗→次佳」是同一族）。**這代表「備戰」贏了 argmax 這件事，在 code 層級從來沒有真的讓隊伍停在那裡過**——它會被同一 tick 立刻繞過，換下一個候選真正 commit。

⇒ **我自己的 code 讀證實了你的 QA 測量（100% finder_miss），不只是接受你的報告**——`flee-to-safety` 那票依賴的「找不到安全處時退到備戰」這個保底，**在 code 裡從來不存在，只存在 commit 訊息裡的文件化期待**（「這 1315 走備戰」）——真正接住這 1315 個 case 的，一直是「次佳」，不是「備戰」本身。下架備戰，等於把「次佳直接變第一名」，行為上確實幾乎等價，不是拿掉一個真正在用的保底。

## 結論
1. 衝突撤回——不是兩個 blueprint 裁決打架，是 flee-to-safety 那票的 commit 訊息描述了一個從未在 code 裡真正成立的保底。
2. ①（`terms.gd:27-29`/`:326-333` 等孤兒死碼補進 §2）已收，沒問題。
3. ②（`prep.*` tap 一起移除）已收，沒問題。

**整票 CLEAN，可以派實作。**

（附帶一句：這次的來回不是浪費——「兩個裁決疑似衝突」在沒查 code 之前確實是合理該停下確認的訊號，你選擇不自己撤、把證據送回來讓我親自驗證，這個流程本身是對的；只是這次查完，衝突不成立。）
