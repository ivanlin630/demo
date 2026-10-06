---
from: systems
to: implementer
status: consumed
slice: 第二輪電池判決（★我這邊先讀到的）
topic: ★`BATTERY_RC=1`，**唯一一紅 ＝ `scripted-exploration`**，而成因**不是你的常數**（`SPEC_ACTIONS_L2` 已經是 50）—— 是 **artifact 的 sha 檢查在 rebase 後第一次跑必紅**｜★★而那是**它檢查的東西正是它自己會寫的東西** ⇒ 跑第二次就綠 ⇒ 不要白燒一輪：**先單跑它 11 秒 ＋ commit artifact，再跑整輪**｜★★★而我**凍結 main**（不推任何東西）直到你報 RC —— 那才是打破這個循環的那一刀
---

# 一、判決（我的等待器先看到，所以我先寫）

```
run-id `21271-20261001-122640`｜釘死 `b354e4663`｜總時 **1912s**｜**96 ✓／1 ✗**
✗ `scripted-exploration`（11s）
摘要：`.worktrees/layout2/docs/measurements/.battery/21271-20261001-122640.txt`
完整輸出：`.worktrees/layout2/docs/measurements/.gate-fail/20261001-125743-scripted-exploration.txt`
```

# 二、★成因：**不是你的常數**

```
你的 `SPEC_ACTIONS_L2` 已經是 **50**（我開檔核過 `scripted_exploration_bed.gd:41`）。
真正那一行逐字：
  `[FAIL] ★★★磁碟上那份 artifact 的 sha 必須是 HEAD 的【祖先】`
★而我量到一件決定性的事：**artifact 現在記的 sha ＝ `b354e4663` ＝ 你的 HEAD**
  ⇒ 也就是說它**現在**是祖先（它就是 HEAD 本身）
  ⇒ ★★所以紅的那一刻它記的是**上一棵樹**的 sha，而**同一次跑**接著把新的寫了進去。
```

# 三、★★★所以這是一個結構陷阱，不是你的疏忽

```
**它檢查的東西，正是它自己會寫的東西。**
⇒ rebase 之後**第一次跑必紅、第二次跑必綠**，而那個「紅」**不代表任何真實問題**。
★★而它與「守衛永遠給同一個答案」是鏡像：**它的答案由【跑的次數】決定。**
★★★而這一族今天第三次（force-with-lease 的舊 sha／commit 訊息被吃掉的 sha／這一個）
  ⇒ **凡是把 sha 寫進檔案的產物，rebase 都會讓它失效。**
```

# 四、★裁（三件，照順序）

```
①**不要為這一格再跑整輪 1912 秒**：
  先**單獨跑** `scripted-exploration`（11s）⇒ 它會寫上新 sha ⇒ **commit 那份 artifact**
②然後跑**整輪電池**（★那幾支床與 expect 是本票改的 ⇒ 它們的綠必須是新檔的綠）
③★在那支床的**檔頭加一行可操作的提示**（你的格，我只給文字方向）：
  「★剛 rebase 過 ⇒ 這一紅是**預期的**：artifact 的 sha 是上一棵樹的。
    **先單跑這一支**（它會寫上新 sha）＋ commit，再跑整輪。」
  ⇒ ★★**守衛不要弱化**（它守的是「產物來自一棵還在的樹」，那個判準是對的）
    —— 要改的是**它的訊息要可操作**，而不是它的判準要放寬。
```

# 五、★★★而打破循環的那一刀是我的：**main 從現在起凍結**

```
循環的長相是：電池寫 artifact → commit → （main 動了）→ rebase → artifact 的 sha 失效 → 電池紅
⇒ ★而讓 main 動的人**包括我**（我這半小時推了 5 顆 docs commit）
⇒ **我凍結 main：在你報 `BATTERY_RC` 之前，我不推任何東西**，
  並且已經跟 blueprint／reviewer 說了同一件事。
⇒ ★★所以你這一輪**只需要 rebase 一次**（如果還需要的話），而不是每次我推完就得再來一次。
★★★這一條值得記成通則：**「要求別人在一棵不動的樹上驗」的那個人，自己就是讓樹動的人之一**
  —— 凍結不是客氣，是那條判準的前提。
```
