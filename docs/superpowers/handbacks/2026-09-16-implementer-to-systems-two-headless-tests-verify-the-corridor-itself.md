---
from: implementer
to: systems
status: consumed
slice: `conquest-scout-corridor` ｜ 閘一輪跑完（橫幅 1 份）**紅 3**：基線 ＋ `defer-open`（鬧鐘）＋ ★**兩條 headless 在驗【走廊本身】**
topic: ★**`[TREE] HEAD=2ce8f36a4 clean`｜`註冊表 55 支｜總時 538s`｜`FAIL：bed-arm headless defer-open`｜★橫幅只有 1 份**（先確認再讀數）｜★★★**兩條新紅【直接呼叫 `_commit_conquest_attack`】並斷言 `current_task == TASK_SCOUT`** —— **它們驗的就是本票刪掉的那條走廊**（`headless_test.gd:1299`／`:1024`）｜★★**而它們想驗的【意圖】仍然成立**（慎重者面對未驗情報不該直接打），**只是那件事的發生地點搬走了** ⇒ **這是「改 fixture 的數字」與「改我們在驗什麼」之外的第三種** —— **驗收點搬家**｜★**我不自己改，兩個選項列給你**
---

# ① 閘（★先確認橫幅只有 1 份，再讀數）

```
[MERGE-GATES] [TREE] HEAD=2ce8f36a4 registry=clean runner=clean code-dirty=0
[MERGE-GATES] 註冊表 55 支｜總時 538s
[MERGE-GATES] FAIL：bed-arm  headless  defer-open
★橫幅出現次數 ＝ **1**（★兩輪疊一檔那顆今天發生過，所以先數這個）
```
- `bed-arm`：★**基線**。
- `defer-open`：★**鬧鐘響了** —— `conquest-scout-corridor` 的解除條件已達成（**我把那條 `try_set` 拆了**）
  ⇒ **照上次同一個處置：做完 ⇒ 收行**（★而我先問你，因為**上次我是自己收的**）。
- `headless`：★★**兩條新紅，見下。**

# ② ★★★那兩條 headless 驗的是**走廊本身**

```
`headless_test.gd:1299`（G3d-2 scout 查證迴路）
   FactionAISystem.new()._commit_conquest_attack(st_a, tm_a, 1)
   assert(tm_a.current_task == TeamData.TASK_SCOUT and tm_a.prosperity_target_id == 1,
          "慎重者未驗情報→派斥候…")

`headless_test.gd:1024`（A) 慎重 leader + 矛盾多源 belief）
   FactionAISystem.new()._commit_conquest_attack(st_a, tm_a, 1)
   assert(tm_a.prosperity_target_id == 1 and tm_a.current_task == TeamData.TASK_SCOUT,
          "慎重者矛盾情報→派斥候查證…")
```
⇒ ★**兩條都【直接呼叫 `_commit_conquest_attack`】並斷言它會把 task 設成 SCOUT**
⇒ ★★**那正是本票刪掉的那條走廊** —— **所以它們必然紅，而且是【正確地紅】。**

# ③ ★★而這是第三種情況（★與今天處理過的兩種都不同）

| 今天遇過的 | 判準 | 修法 |
|---|---|---|
| 前 6 條 | **fixture 想驗的事在新制下【不成立】** | ★改 code（spec 錯） |
| 第 7 條 | **意圖成立、數字寫在舊尺上** | ★改 fixture 的**數字**，斷言不動 |
| ★**這 2 條** | ★★**意圖成立、而【發生地點搬走了】** | ❓**要你裁** |

★**它們想驗的意圖仍然成立**：**慎重者面對未驗／矛盾情報，不該直接開打。**
★★**而新制裡那件事發生在別的地方**：
```
舊：`_commit_conquest_attack` 把 task 改成 SCOUT（走廊）
新：①`attack_scan` **不產生**那個攻擊 candidate（不可行）
    ②「所以去偵查」由**偵查 option 在 argmax 上贏**
```
⇒ ★★★**而這兩條測試【不跑 argmax】** —— 它們直接呼叫 `_commit_conquest_attack`
⇒ **它們看不到新制的那一半** ⇒ **就算行為完全正確，它們也會紅。**

# ④ 兩個選項（★我不自己做）

| | 做法 | 代價／意義 |
|---|---|---|
| **甲** | **把斷言改成驗新的發生地點**：呼 `attack_scan`，斷言**那個 prey 不在 feasible 裡**（＋ `why["thin_intel_refused"] >= 1`） | ★**意圖不變、驗收點跟著搬家**；★★而它**真的在驗新機制**，不是把紅塗掉 |
| **乙** | **退役那兩條**，改由 `scout_on_the_scale_bed` 的 ⑥⑦（人格 × 薄情報）承擔 | ★★★**但那兩格是【轉述】情報，而這兩條是【未驗／矛盾】情報 ⇒ 不是同一件事** ⇒ **我不建議** |

★**我傾向甲**，理由：**那兩條驗的是「慎重者不會盲打」，而那條性質本票【保留】了** ——
★★**它只是換了實現** ⇒ **測試該跟著換位置，而不是消失。**
★★★**但改斷言 ＝ 改我們在驗什麼** ⇒ **你按。**

# ⑤ 順帶

★**本票的驗收數字不受這兩條影響**（它們是既有測試，不是本票的驗收格）：
`docs/measurements/2026-09-16-corridor-removed-10day-before-after.md` 已交，含四格 ＋ (4a)/(4b) ＋ 觀測中性。
