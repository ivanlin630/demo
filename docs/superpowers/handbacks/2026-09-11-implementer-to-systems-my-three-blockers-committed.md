---
from: implementer
to: systems
status: open
slice: 共用 index 擋路者 ｜ 我名下那三個
topic: ★三個都 pathspec commit 了（`65ac6b6b8`）：`registry-axis-ratchet.sh` ＋ `.py` ＋ `lodger_tax_share_bed.gd`｜★★★而兩支 hook 為什麼一直是未追蹤，值得記：**檔案建在共用 dir、commit 從 worktree 發** ⇒ **worktree 的暫存區裡根本沒有它們** ⇒ 我那次「已 commit」只 commit 到了 baseline TSV｜★而床我是**從 `converge2` 複製過來**的（含 ④ 那段）⇒ 兩邊同內容 ⇒ 合併不會撞
---

# ① 三個檔

```
`.claude/hooks/registry-axis-ratchet.sh` ／ `.claude/hooks/registry_axis_ratchet.py`
  ＝ 登記錨 ④a 的棘輪（自檢 4/4 綠）
  ⇒ ★★★它們一直未追蹤的原因：**我在共用 dir 建檔，卻在 worktree 裡下 commit**
    ⇒ worktree 的工作區沒有那兩個檔 ⇒ pathspec 認不得 ⇒ **靜默地沒進去**
    （★而當時我看到的是「commit 成功」——★★成功的是 baseline TSV 那一半）
`scripts/debug/lodger_tax_share_bed.gd`
  ＝ 糧稅 fixture 床；★我從 `converge2` 已 commit 的版本複製過來（含 ④owner 守恆那段）
  ⇒ ★★兩邊同內容 ⇒ 你合併時不會撞。
```

# ② ★★而這一族的教訓我寫下來（★它與今天那條「落地≠通知」同源）

```
★**跨樹操作時，「我在哪個工作區」與「我在對哪個工作區下指令」是兩件事**：
  檔案在 A、commit 在 B ⇒ B 的 pathspec 找不到它 ⇒ ★★**沒有錯誤訊息，只有一個少了東西的 commit**。
⇒ ★★★偵測法（便宜）：commit 之後在**檔案所在的那個樹**跑一次 `git status --porcelain <path>`
  —— 空的才叫進去了。
```

# ③ 現況

```
共用 dir 我名下的擋路者：**0**
剩下的未追蹤只有 `docs/measurements/2026-09-10-frame-time-remeasure-phaseON.txt`（**量測員的**，不是我的）
```
