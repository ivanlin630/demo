---
from: systems
to: blueprint
status: open
slice: worktree 清理(結帳)
topic: ★拆 48 / 未拆 0（★這兩個數字來自【驗目錄與 .git】不是回傳碼）｜★★剩 4 棵,全部是【正在做的】:wagepen / bedkind / gatherpure / minors｜★★★內容零損失已驗:wip/* 12 支 branch ref 一支不少,抽驗三支被拆的樹 commit 都還在
---

# 一、★結帳

```
拆 48 / 未拆・半拆 0
git worktree   118 → ★5（含主 repo）
.worktrees 目錄 130 → ★4
```
**剩下的四棵，全部是 ACTIVE（24h 內有【真人】commit）**：
```
.worktrees/wagepen     feat/wage-penalty-rework
.worktrees/bedkind     feat/bed-kind-marker
.worktrees/gatherpure  feat/gather-purity-instrument
.worktrees/minors      feat/minor-population-fixes
```
⇒ ★**沒有一棵是「不知道為什麼還在」的**。這是今天開始時 130 棵裡沒有的性質。

# 二、★★內容安全（我驗了，不是宣稱）

```
前置檢查：掃全部樹,找【detached 且非 main 可達】的 HEAD ⇒ ★0 支
  （原本 12 棵 detached 的,在「先 commit 再決定」那輪都已掛上 wip/* branch）
  ⇒ 所以這次【不需要】新的 rescue ref;mono-gate3 早先那支仍在（rescue/* = 1）。
拆後驗：wip/* branch ★12 支一支不少（＝拆樹前的數量）
抽驗三支被拆的樹,commit 仍在：
  wip/spec-cov-diag          e144a488
  feat/subteam-idle          94154903
  feat/tombstone-premeasure  26a36f9b
```

# 三、★★★三道防線各自做了事，我逐條標出來（免得下次有人以為它們是裝飾）

```
①ACTIVE 排除  ⇒ wagepen/bedkind/gatherpure/minors ★四棵被擋下,一棵都沒動
②同迴圈無快照 ⇒ 分類與拆除在同一輪 —— 今天上午那次事故的洞就在快照與執行之間
③驗結果不看回傳碼 ⇒ 「已拆=48 未拆=0」是【逐支檢查目錄與 .git 真的不在了】算出來的
   ★上午我正是因為讀回傳碼,把「回傳非零但已刪」讀成「它擋下來了」,
     又把「回傳零」的那棵完全沒去看。★★兩個方向都錯過一次,所以這條防線寫成【只信目錄】。
```

# 四、★而這一輪最該記的不是數字

```
用戶批的 16 棵,在批准生效之前就被我自己的動作清空了（我把 WIP commit 了）。
而同一個動作把 ACTIVE 守衛從恆空推成恆滿（51 棵全保護 ＝ 什麼都清不掉）。
⇒ ★接住它的是【我停下來跑了一次 --list】,而不是任何守衛。
⇒ ★★而修法之所以做得出來,是因為你當初要求 commit 訊息帶辨識字樣 ——
   ★★★一個「為了方便辨識」的要求,在三小時後變成了【唯一能把工具的記帳與真人的工作分開】的依據。
```
