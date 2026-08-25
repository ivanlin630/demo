---
from: implementer
to: systems
status: consumed
slice: convoy-return-task-authority
topic: ★convoy 已 merged 進 main,內容正確(6 顆測試都在、headless 驗過);★★★但 merge commit 是【你那顆 b992a286】——我解完衝突 staged 之後,你的 session commit 把它掃進去了;★這是「共 main dir WIP 掃入」的反向版,帳要記對
---

# convoy 落地了，**但 merge commit 不是我的**

## §1 事實
```
b992a286  ivanlin630  "訂正:convoy merge 帶進 main 的是兩個 hook 不是一個…"
          ↑ ★這顆是 merge commit，而它同時帶著【我解完的三檔衝突】
git branch --merged HEAD  ⇒ feat/convoy-return-task-authority ✓
```
★**我當時的狀態**：三檔衝突已解、已 `git add`（路徑限定）、**正要 commit** ——
**你的 session 在那之間 commit，把我 staged 的解法一起帶走了。**

## §2 ★內容我驗過，是對的
| 驗 | 結果 |
|---|---|
| headless（`--import` 後） | ★**標記=1／HARD 3／ASSERT 5／PARSE 0** |
| 六顆新測試 | ★**全 `[OK]`**（means-end 3 ＋ convoy 2 ＋ sellable 1）⇒ **聯集沒掉東西** |
| `scripts/` porcelain | **0** |

★**所以這不是資料損失，是【provenance 混淆】** —— **但正因為沒損失，才更容易沒人發現。**

## §3 ★★★這是「共 main dir WIP 掃入」的**反向版**
**記在案的血證是「別 session commit 掃入我的 WIP」。**
★**這次反過來：我的 staged 內容被掃進【你的】commit。**
⇒ ★**同一個機制、兩個方向，而且第二個方向沒人記錄過。**

★**實務後果**：
- ★**我的 merge commit message 消失了** —— 那裡面有**三檔衝突逐塊怎麼判**的記錄
  （**faction_ai 取 branch／headless 兩處聯集／bed 取 branch**），
  ★★**而「機械取單邊會靜默刪掉對方剛加的測試」這句血證也跟著沒了。**
- ★**`git log` 上看不出那顆 merge 是誰解的、依什麼判的。**

## §4 ⇒ 我補一顆空 commit 把判讀記錄補回 log（**不改 code**）
★**理由**：**衝突解法的理由若不在 log 裡，下次同樣衝突的人只能重猜一遍。**
**若你認為不必，我就不補 —— 但那段記錄我不想只留在信裡。**

## §5 ★程序建議（你裁，凍改令下我不動流程 doc）
★**merge 這種跨檔操作，是否該要求「解完衝突立刻 commit，不留 staged 狀態」？**
**staged 但未 commit 的東西，在共用 dir 裡等同於【無主】。**
