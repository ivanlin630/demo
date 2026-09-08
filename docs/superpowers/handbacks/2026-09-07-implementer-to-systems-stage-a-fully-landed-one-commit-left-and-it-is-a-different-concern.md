---
from: implementer
to: systems
status: consumed
topic: ★**stage-a 全部落地**（`computed-prop` 閘在 main、baseline **1 站**、cross-run 修也在）｜★★而 branch 上**還剩一顆** `1b73164d` —— ★★★它**不是 stage-a 的東西**，是觀測純度床，**要不要進由你判**
---

# 一、★我自己驗過的落地清單（★不採信「應該進去了」）
```
git show origin/main:docs/process/merge-gates.tsv | grep -c 'computed-prop'          ⇒ ★1
git show origin/main:docs/process/.computed-prop-write-baseline.txt（非註解行）      ⇒ ★★1 站
git show origin/main:scripts/data/team_data.gd | grep -c '_reset_cross_run'          ⇒ 1
git show origin/main:scripts/simulation/cross_run_reset.gd | grep -c 'TeamData._reset_cross_run' ⇒ ★★★1
   （★最後這一格是關鍵：只有前一個 = 過閘而不會被清）
```

# 二、★★而 branch 上剩的那一顆是【另一件事】
```
`1b73164d` 觀測純度床（`scripts/debug/gather_observation_purity_bed.gd`）
⇒ ★它跟 stage-a 的吞寫 setter【沒有關係】——它是接 measurer 的 gather 發現做的對照
⇒ ★★而我把它 commit 在同一個 branch 上，是因為那是我當時手上的樹
   —— ★★★而那正是我今天自己標過的「HELD work 別跟待 merge 的東西共 branch」
     （誤帶入／誤 bank 的血證）。我這次是【反過來】：不該帶的東西被我放進待 merge 的 branch。
⇒ 處置由你：(a)跟 stage-a 一起合（它零行為改動、只是一支床）
             (b)我把它挑到獨立 branch，stage-a 保持乾淨
   ★我傾向 (b)，因為它的歸屬是【gather 那條線】不是【吞寫 setter 那條線】，
     而合在一起會讓日後追「這支床為什麼在」時走錯線索。
```

# 三、★★★而我要主動說一件【我不做】的事
```
下一步最自然的是：量出 `a4_rout_witness_bed` 【實際】的擾動大小
★而我不做，理由不是邊界潔癖：
  ★★那支床的觀測是【潰逃事件觸發】的，不是每天固定 —— 要忠實鏡射它，
    我得複製它的觸發條件，★★★而我複製錯的話，會產生一個【看起來精確的錯數字】
⇒ 那比「沒有數字」更糟：沒有數字時大家知道要小心；有一個錯的精確數字時不會。
⇒ ★所以那一格該由【擁有那支床、知道它觸發條件】的人做（measurer），
  而我把工具交出去：`gather_observation_purity_bed.gd` 的 A/B 骨架可以直接改。
```
