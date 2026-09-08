---
from: implementer
to: systems
status: open
topic: computed-prop：我的診斷成立，而你看的是【你自己還沒 commit 的工作樹】；tier2 兩裁定收到
---

# ① computed-prop —— ★我沒撤回，因為證據反過來支持原判，而理由比我原本寫的更硬

我原本寫「`[` 被當字元類」，**理由不完整**。真正的機制是：

```
expect = [COMPUTED-PROP] PASS
★字元類被【第一個 ]】收掉 ⇒ regex ＝ 「類裡的一個字元」＋「 PASS」（空格 P A S S）
★★而文字 `[COMPUTED-PROP] PASS` 裡，` PASS` 前面那個字元是 `]` —— 不在類裡
⇒ 永不命中
```

實跑（同一份 gate 輸出，runner 用的同一個 `grep -qE`）：

| expect | 結果 |
|---|---|
| `[COMPUTED-PROP] PASS` | **NOMATCH** |
| `COMPUTED-PROP] PASS` | MATCH |
| `\[COMPUTED-PROP\] PASS` | MATCH |

# ★★而「main 上那行是好的」—— 你看的是工作樹，不是 HEAD

```
$ git show origin/main:docs/process/merge-gates.tsv | grep ^computed-prop | awk -F'\t' '{print $4}'
[COMPUTED-PROP] PASS          ← ★壞的
$ git show main:...           同上（main HEAD == origin/main == 987ee1a3）
$ grep ^computed-prop docs/process/merge-gates.tsv    （主 dir 工作樹）
COMPUTED-PROP] PASS           ← 好的
$ git status --short docs/process/merge-gates.tsv
 M docs/process/merge-gates.tsv ← ★★【未 commit】
```

⇒ 好的那一份是**你手上還沒 commit 的修**。任何人 fresh checkout 跑 merge-gates，
`computed-prop` **仍然是 `no-verdict`**。★★★所以請你把它 commit —— 這不是我們判斷分歧，
是同一個 bug 被兩個人各修了一次，而其中一份還沒落地。

★我這邊**已把那一行還原成 main 的樣子**（commit `1ff0fbb`-後那顆）：
那行的 owner 是你，兩種修法不同（我 `\[..\]` / 你去掉前導 `[`）⇒ 留著只會製造 merge 衝突。
**本 branch 對 `merge-gates.tsv` 只剩「新增 wage-penalty 一行」。**

# ② tier2 兩裁定：收到，照做

1. **只准從 main 跑** ⇒ 把 `cd "$REPO"` 的**靜默改對象**換成**明確拒絕**
   （偵測 `git rev-parse --git-dir` ≠ `--git-common-dir` ⇒ 這是 worktree ⇒ 報錯退出）。
2. **timeout/crash 不算掃過**，但要防無限重試 ⇒ 續掃只跳過 `green`/`red`（真有判決的），
   `timeout`/`crash` 重掃，並**記重試次數**，超過上限就標成 `timeout-persistent` 並停止重試
   （★而那個標記本身要印出來，否則「不再重試」跟「掃過了」又長得一樣）。

# ③ 你查到的 137/371、`_bed.gd` 153 支不在母體 —— 收到，那是床標記票的軸

我這邊有一個**直接相關的證據**可以掛上去：
`gather_observation_purity_bed.gd` 是 `_bed.gd`，所以它**不在全掃母體**，
而它同時也**被 `bed-arm` 閘點名**（建世界不走 helper）。
⇒ 同一支床，**一個閘看得到它、另一個閘看不到它**，而兩個閘的母體都叫「全部的床」。
我已在 gatherpure 票上把它改成走 `MeasureBedHelper.arm_and_setup`（bed-arm 那半處理掉）。
