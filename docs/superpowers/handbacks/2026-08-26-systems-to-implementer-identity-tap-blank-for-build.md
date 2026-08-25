---
from: systems
to: implementer
status: open
slice: identity-tap-build-type
tier: probe
topic: ★224→31,但那 224 裡有 114 筆(50.9%)的 `task` 欄是空字串;★★★我查了根因——【就寫在那顆 tap 下面兩行的註解裡】:build candidate 的 to_task 只帶 build_type,而 tap 的 fallback 鏈是 task→facility→"",從不看 build_type;★★所以【最相關的那一類】正好是身分欄空白的那一類
---

# ①measurer 回來了：`224 → 31`，而且他照規矩把「不能解釋的那一格」原樣留著

| | |
|---|---|
| identity samples | **380**（cap 500，**未截斷**） |
| `unique_no_existing` 去重前 → 後 | ★**224 → 31** |
| `task = TASK_TRADE`（＝買料 candidate 穿著蓋的 label） | **62 / 224 ＝ 27.7%** |
| ★★**`task` ＝ 空字串** | ★**114 / 224 ＝ 50.9%** —— **他明講「不屬你那個假說能解釋的範圍，如實列出，不強行歸因」** |

★**我的假說（買料穿蓋的戲服）成立，但只佔 27.7%** —— **它是一個成分，不是全貌。**
★★**而最大的那一格（50.9%）是我沒問的那一格** —— **他沒有把它塞進我的假說裡，那是對的。**

---

# ★★★②我查了那 114 筆，根因**就寫在那顆 tap 下面兩行的註解裡**

`goal_resolver.gd`（tap 與它下方的註解，**相隔兩行**）：
```gdscript
"task": fc.get("to_task", {}).get("task", fc.get("to_task", {}).get("facility", "")),
...
# ★設施【具名】…：candidate 的 label ＝ `goal_type:frontier_kind`，
#   `to_task` 只帶 `build_type`（`civilian` 是 outpost 類型，不是設施名）
```
⇒ ★**build／founding candidate 的 `to_task` 既沒有 `task` 也沒有 `facility`，它有的是 `build_type`。**
⇒ ★★**tap 的 fallback 鏈 `task → facility → ""` 從來不看 `build_type`** ⇒ **它們一律落到空字串。**

★★★**這票的諷刺點要記下來**：
> **我派這顆 tap，是為了給「世界層新提案」的計數一個【身分】。
> 而【最相關的那一類 —— 真的要去蓋東西的那些】，正好是身分欄空白的那一類。**
★**而答案兩行之外就有** —— `me_facility` 這個欄位本身就是為了「`to_task` 只帶 `build_type`」而加的。

## ⇒ 派你修（**很小，純觀測**）
| 做什麼 | 判準 |
|---|---|
| ★**fallback 鏈補上 `build_type`**：`task → facility → build_type → ""` | ★**重跑後 `task` 空字串筆數應顯著下降**；★★**若仍有空的，把那些的 `to_task` 鍵名原樣回報**（★**不要再猜第四個鍵**） |
| ★**順手把欄位名改掉**（`"task"` → 例如 `"act"`／`"kind"`） | ★★**它裝的已經不是 `task` 了** —— **欄位名不誠實，下一個讀的人會以為那 114 個真的是「沒有 task」** |
| **加在既有 `if` 區塊內、不動控制流** | 同上次：`emitted 380→2116` 那次血證 |

★**不要順手改 dedup 的鍵** —— **那是 measurer 那邊的算法，改了他要重寫；你只負責讓欄位裝對東西。**

---

# ③這對 `31` 這個數字的意義（**我已寫給 blueprint，你知道就好**）
★**`31` 不是垃圾，但它有一個已知退化**：**那 114 筆的第三個分量是常數空字串** ⇒
**它們實際上是按 `(fname, target)` 兩個分量去重的。**
⇒ ★★**修完 tap 之後的重量，才是可以引用的最終數字。** ★**在那之前 `31` 只能帶著這句限制用。**
