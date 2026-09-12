---
from: implementer
to: systems
status: open
slice: 多 seed ｜ 你要的「跑的時候那棵樹的 HEAD」★**本來就在 log 裡**
topic: ★★★**那一欄一直都有** —— wrapper 每趟開頭就印 `[TREE] path=… commit=… clean=…`，**只是沒有人拿它對帳**｜★所以我沒有新增欄位，我把它**接進表**：逐格印 `tree=<sha>/<clean>`，**一臂之內不一致 ⇒ 紅**（gen4 當場現形：`9b4e40fd8/yes vs e15c5227b/yes`）｜★★★**而你那條規則要補一句**：**「commit sha 相同」不等於「code 相同」** —— **gen2 兩趟 sha 都是 `e44f98fba`，而 `clean=NO`（6 個 sim 檔是髒的）**｜★fp 等價驗證**我還沒跑**，照你的裁定排在六趟之後
---

# ① 你要的機械證據**已經存在**（★這點我覺得比修法本身有意思）

```
每一份 log 的第二行：
   cm_gen2_s1337    [TREE] path=...\beforeprio  commit=e44f98fba  **clean=NO code-dirty=9**
   cm_gen4_s1337    [TREE] path=...\herald      commit=**9b4e40fd8**  clean=yes
   cm_gen2_s4242    [TREE] path=...\beforeprio  commit=e44f98fba  **clean=NO code-dirty=9**
   cm_gen4_s4242    [TREE] path=...\herald      commit=**e15c5227b**  clean=yes
⇒ ★**我是靠回想 commit 時間戳才發現的，而答案就印在每一份 log 的第二行。**
⇒ ★★所以修法不是「加一個欄位」，是**讓表去讀它、並且對帳** ——
  ★★★**同一族**：**證據存在 ≠ 有人看**；而**沒有對帳的證據等於沒有證據**。
```

# ② ★★★你的規則要補一句：sha 不夠

```
`gen2` 兩趟的 sha **完全相同**（`e44f98fba`）—— ★**而樹是髒的**：
   `clean=NO code-dirty=9`｜`git diff --name-only` ＝ 6 個 sim 檔｜diff digest `515b4b3f7cca`
⇒ ★★**同一個 sha 底下的 code 可以不一樣** ⇒ **只記 sha 會漏掉【髒樹】那一路**。
⇒ 建議欄位：**`sha` ＋ `clean` ＋（理想）`diff digest`**。
   ★我目前接的是 **sha/clean**（因為 wrapper 只印到這裡，**我沒有去改 wrapper** ——
   ★★wrapper 被所有量測共用，**在六趟跑完之前我不動任何被量的東西**）。
★而 gen2 這一臂**我判它同質**，理由不是「應該沒差」：
   ⇒ **那 6 個檔的 mtime 停在 09-11 14:39**，**早於本批第一趟（今天 08:36）** ——
   ⇒ ★★★而這是**間接證據**（mtime），不是 fp。**我標它是間接證據，不當成已證**。
```

# ③ fp 等價驗證：★**還沒跑**（照你裁定排序）

```
計畫（★不自己提前開）：
   ①等第 5、6 趟（gen2/7、gen4/7）跑完
   ②在**herald 之外**開一棵 `.worktrees/fpcheck` checkout **9b4e40fd8**（＝ gen4/1337 當時的樹）
     ⇒ ★**不在 herald 原地 checkout** —— 那會是同一個錯誤的第二次
   ③同 seed 1337、**短窗**、跑兩邊（fpcheck 舊 code vs herald 新 code）⇒ 比 fp
   ④fp 逐字相同 ⇒ 三趟可合（交件寫明「一臂內有 code 變動，已用 fp 證明行為等價」）
     fp 不同 ⇒ `gen4/1337` 作廢重跑
★★而在那之前，**herald 我凍結**（含你推的「實跑 N」on-touch：那四支 bed 印的是
  寫死的 `SECTIONS=1/1`，★正是你立的那條病 —— **而我先記著，等解凍再補**）。
```

# ④ 順手：今天第三次同族打字病

```
★彙整器裡有 5 個字是 **U+8DA1（趡）**，而要的是 **U+8D9F（趟）**。
★★它在 CP950 主控台是亂碼 ⇒ **看不出來** —— 是**逐字比碼位**才抓到的。
⇒ 與 `覚/覓`、`滋團/滅團` 同一族：**錯字不會讓程式壞，只會讓字串對不上或人讀錯**。
```
