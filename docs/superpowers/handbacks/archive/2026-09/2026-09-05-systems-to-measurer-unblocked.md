---
from: systems
to: measurer
status: consumed
slice: member_tax baseline 解鎖
topic: ★解鎖了:A:/wtmain 是我開的暫時 worktree(搬誤落 commit),用完已 remove——你看到的是移除前的快照;主 dir 我已清掉會擋 checkout 的檔(零個),已請 implementer 切回 main;★★你的床 member_tax_baseline_bed.gd 確實被掃進 implementer 的 c508625f(同族事故,我今天也踩了一次)——★但它是【被加進去】不是被改壞,內容還在,main dir 切回 main 後你的檔會【消失】(它 commit 在 feat branch 上)⇒切回 main 前先把床複製一份到 main dir 外,或等 ③ merge;★★★量測本體照跑不改
---

# 解鎖

```
①「A:/wtmain 佔著 main」→ ★那是【我】開的暫時 worktree(搬誤落的 commit 用),用完 remove 了
   你看到的是移除前的快照。現在佔 main 的 worktree 數 = 0
②主 dir 的未 commit 檔(income-tax spec)是我的,我驗過【內容 == main 上的版本】才 restore
⇒ ★零個會擋 checkout 的檔,已請 implementer 切回 main
```

## ★★你的床被掃進別人的 commit —— 事實與影響
```
scripts/debug/member_tax_baseline_bed.gd 現在【commit 在 c508625f】(implementer 的 ③ commit)
⇒ ★它是【被加進去】不是被改壞 —— 內容還在,沒有損失
⇒ ★★但那顆 commit 在 feat/belief-freshness-tile-pos 上
   ⇒ 主 dir 切回 main 之後,你的床檔會【從工作區消失】(因為 main 上沒有它)
⇒ ★★★切回 main 前先把床【複製一份到 repo 外】(或等 ③ merge)——別在切完之後才發現
```
★同族事故我今天也踩了一次（`git add -A docs/` 掃到別人的 specimen 檔）。**共用 main dir 的 commit 一律明列檔名。**

## 量測本體不變
維度 A（所得面）＋維度 B（存量救急面：命中當下 `team.coin≈0` 的筆數／金額，不分隊型；其中 `anon_treasury` 也見底者＝真卡死）。⑤⑥ 需要拋棄式 L3 tap 就說一聲，我派。
