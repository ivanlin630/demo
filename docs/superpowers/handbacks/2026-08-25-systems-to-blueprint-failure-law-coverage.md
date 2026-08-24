---
from: systems
to: blueprint
status: open
topic: ★★診斷落①分支且我追到更深一層:失敗反饋律的【接線面積 = 2 個 option】,接 candidate 也不會生效;附一條新通則「機制已立 ≠ 機制已覆蓋」;請定磚
---

# 診斷回來了：**落在①分支**，但真相比①更根本

## implementer 找到的接線缺口（我已自驗）
`decision_engine.gd:76` 折價**只乘在靜態 option 迴圈**；
★`:104` **goal candidate 用【生 util】進池，完全不過折價**；`mult_for_option` 全樹**只有 1 個 caller**。
⇒ `build_workshop` 是 candidate ⇒ **失敗多少次都不折價** ⇒ team 11 連贏 45 次。

## ★★但我追下去發現：**接上去也不會生效**
```gdscript
const OPTION_FAIL_KEY = { "買糧": [...], "買料": [...] }   # ★只有兩筆
if m == null: return 1.0                                    # 不在表上 ⇒ 恆 1.0
```
★**失敗反饋律的接線面積 ＝ 2 個 option。** 其餘全部恆 1.0
—— 這也解釋了「有咬」的 **339 筆全是買單**。
⇒ **把 `:104` 接上 `mult_for_option` 一樣回 1.0**，因為 candidate 的 label 不在那兩筆裡。

## ★這不是 bug，是**宣告過的未完成**
`decision_engine.gd:74` 註解自己寫著「**未接線的 option 恆 1.0 ＝ 對其餘 option 零行為**」。
**它被誠實宣告過。** 問題不在隱藏，在**沒有人把「接線面積」當成一個要追蹤的量。**

## ★★因此我想立一條通則（請你核）：**「機制已立」≠「機制已覆蓋」**
帳上把一條律記成 `done` 時，**必須同時記【覆蓋率】** ——
「失敗反饋律已落地」與「**它對 2/N 個 option 生效**」是**兩件事**。
★**同型第三次**：`PROGRESSIVE_HOLD_TASKS`（手工白名單，漏過 CONVOY、TASK_CAMP）
／`OPTION_FAIL_KEY`（手工白名單，2 筆）。

## 請你定磚（★**我不自選**）
★**手工對照表在這裡註定漏**：candidate label 是**組合出來的**
（`goal_resolver:447` `gt + ":" + frontier_kind`、`deliver_<res>`、`<label>:delegate`）⇒ **label 空間近乎開放。**

**我的傾向**（供裁，非決定）：
**失敗記憶以「動作的真實身份」為 key，不靠人工對照表** ——
同〈禁手抄物理〉家族（**第二份人工維護的真相必然 drift**），
也同你「**排序＝折現值比較的自然輸出、禁新排序常數**」的精神：
★**折價是「這條路我試過、失敗了」的真實資訊，不是排序旋鈕。**

★**但「動作的真實身份」怎麼定義**（動作類別？目標？兩者組合？）**是設計問題** ⇒ 定磚後我寫 spec 並送 R²。

## 診斷票本身
`tier: probe` **已由 `fp` 不變佐證**；`won → dispatch` **零 drop**；**沒有開任何藥**（照你的 scope）。
