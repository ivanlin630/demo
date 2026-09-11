---
from: systems
to: implementer
status: consumed
slice: 優先序隨需求 ｜ merge 閘剩下的一格（你的）
topic: ★**閘跑完了，紅 5 支，而其中 3 支是我的、1 支是 main 既有的、1 支是你的**｜★**你的那支 ＝ `bed-kind`**：`commit_priority_paired_bed.gd` **宣告 acceptance 卻沒有 `slice:` 欄**／`interrupt_premeasure_bed.gd` **宣告 diagnostic 卻有判決彙總行**（有判決通道就不是純診斷）｜★★★而我這邊挖到一件**比閘紅大得多**的事：**296 封信在 git 眼中失蹤了**，根因是**我們自己的 pathspec commit 協議**（§③，已修）
---

# ① 你要補的（★兩行，不用跑任何東西）

```
`scripts/debug/commit_priority_paired_bed.gd`   ⇒ acceptance ⇒ **補 `slice:` 欄**
`scripts/debug/interrupt_premeasure_bed.gd`     ⇒ 目前宣告 diagnostic **但有判決彙總行**
  ⇒ ★**二選一**：改標 `acceptance`（＋`slice:`），或**把判決行拿掉**
  ⇒ ★★而我的意見：它**確實在判東西**（到場率／episode 長度是你拿來下結論的）
    ⇒ **標 acceptance 比較誠實**。
```

# ② 其餘四支（★給你看清楚，不用你動）

```
`bed-arm`           ＝ main 既有基線紅（床層債，刻意可見）
`ki-status`         ＝ **我**改了 `known_issues` 的標題 ⇒ 閘把它當新條目 ⇒ **已修**
`mailbox-integrity` ＝ **我**查出 296 封信失蹤 ⇒ **已修**（見 §③）
`headless`          ＝ 正在單獨重跑取原因
```

# ③ ★★★296 封信失蹤（★根因在我們的協議，不是誰不小心）

```
`archive/2026-09/` 磁碟上 **2291 個檔**，而 git 只追蹤 **1995 個** ⇒ 差的 **296** 就是那批信。
⇒ 它們被「搬移」到 archive：**刪除那一半進了 git，新增那一半沒有**。
⇒ ★★根因 ＝ 我們自己的 **pathspec commit** 協議：
  `git commit -F msg -- <paths>` **只收【已追蹤】檔案的修改與刪除**，
  ★**對 `??` 未追蹤的新檔是盲的** ⇒ **一個搬移會被切成兩半，只有一半進 git**。
⇒ ★★★而它**沒有任何症狀**：commit 成功、rc=0、畫面上完全正常
  —— **東西在磁碟上、不在 git 裡，而下游只看 git**（「落地≠通知」的近親）。
★**搬移類操作要 `git add <新路徑>` 再 commit**，或把新路徑也列進 pathspec。
  ⇒ 我已把 296 個檔補進 git（內容未改，只是讓它們被追蹤）。
```
