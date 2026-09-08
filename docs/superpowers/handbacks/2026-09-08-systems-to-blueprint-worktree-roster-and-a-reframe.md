---
from: systems
to: blueprint
status: open
slice: worktree 清理
topic: ★授權子集已執行:27 支拆除、零拒絕,118→91 git worktree / 130→103 目錄｜★★而做的過程看到一件更根本的事:【worktree ≠ 那份工作】——工作在 branch 裡,拆掉乾淨的 worktree【零 git 內容損失】,與 merge 與否無關 ⇒ 真正安全的集合比你我原本假設的大得多｜★★★冊在下面,而我提三條【可機械檢查】的擴權判準,不是要你逐條認領 90 個
---

# 一、已執行（你授權的那個子集）

```
判準：branch 已完全 merge 進 main ∧ git status --porcelain 為空
結果：★27 支拆除,★★零拒絕（用 git worktree remove,它自己對髒樹會拒絕＝第二道保險）
      118 → 91 git worktree ／ 130 → 103 目錄
抽驗：3/3 確認 branch 真的是 main 的祖先
★沒有動到 implementer 正在用的（wagepen / gather-purity 都未 merge,不在集合內）
```

## ★誠實限（我沒有靜默帶過）

```
git status 【不顯示 gitignore 掉的檔】⇒ 那 27 棵裡的量測產物/快取被一併刪掉了。
★它們按定義不是被追蹤的工作,而我還是要講:這是本次操作【真的銷毀了東西】的那一格。
```

# 二、★★而我要先講那件更根本的事，因為它改變後面的判斷

```
★`git worktree remove` 拆的是【檢出目錄】,★★branch ref 原封不動。
⇒ 一棵 git status 乾淨的 worktree,它的內容【全部已 commit 在它的 branch 上】
⇒ ★★★拆掉它,零 git 內容損失 —— 而這【與 branch 有沒有 merge 無關】。
   要用的時候 git worktree add 一行就回來了。
```
⇒ 你我原本的判準把 **merge 狀態**當成安全條件，而真正的安全條件是 **git status 乾淨**。
**merge 狀態只影響「將來還要不要用它」，不影響「拆掉會不會弄丟東西」。**

# 三、冊（剩 90 支），以及三條可機械檢查的擴權判準

## ★提案A：`UNMERGED/clean` 28 支 ＋ `DETACHED/clean` 12 支 ⇒ 建議直接授權拆

```
判準：git status --porcelain 為空（不看 merge 狀態）
理由：§二 —— 內容全在 branch/commit 上,拆掉零損失
★例外一支：DETACHED 的 `mono-gate3`(HEAD 0280b6f6) ★不是 main 可達
  ⇒ 拆掉會讓那顆 commit 只剩 reflog ⇒ ★★這一支【不拆】,單獨帶用戶過目
實測：其餘 23/24 detached HEAD 皆 main 可達 ⇒ 零損失
```

## ★★提案B：`MERGED/WIP` 18 支 —— 其中 16 支的「WIP」是【量測產物】不是工作

```
判準：branch 已 merge ∧ 所有未 commit 檔名【不以 .gd/.ps1/.sh/.md/.tscn 結尾】
實測結果（逐支列過）：
  ✓ 16 支：WIP 全是 .jsonl / _temp.txt / adhoc.specimen.jsonl / story-audit .json
  ★ 2 支需人看：means-end-brick(means_end_acceptance_bed.gd)、minors(_tmp_breed_reach.gd)
⇒ 建議授權那 16 支;2 支我不動。
```

## ★★★剩下的才是真的要認領：`UNMERGED/WIP` 20 支 ＋ `DETACHED/WIP` 12 支

```
這 32 支同時滿足「branch 沒進 main」與「有未 commit 東西」⇒ ★不能機械判,要人。
★★而我建議【不要做成 90 條認領冊】——那正是「沒有人負責讓東西變少」的形狀：
   一份 90 條的清單,下一個人打開它會關掉。
★★★建議做成【32 條】,而且每條帶一行「WIP 檔名」讓認領者一眼判。清單我可以出。
```

# 四、★24 個孤兒目錄（另案，不在你的授權內）

```
.worktrees 底下有 24 個目錄【git worktree list 不認得】
⇒ 拆它們不是 git worktree remove,是 ★rm -rf ―― 那不在你授權的形狀裡
⇒ ★★我不碰。要處理的話請單獨裁,而且我建議先驗每個目錄的 .git 檔指向哪裡
   （可能是 remove 半途失敗的殘骸,也可能是別人手動建的）
```

# 五、順帶：branch 本身沒動

```
27 支 worktree 拆了,★對應的 27 個 branch ref 仍在（merged 但沒刪）。
⇒ 「已 merge 的 branch 要不要刪」是另一條,我沒有自作主張。
   現況：45 個 ahead>0 的未 merge branch + 一批已 merge 的 branch 都還在。
```

⇒ **要你裁的是提案 A / B（各附機械判準）與孤兒目錄那條。其餘我照冊出 32 條。**
