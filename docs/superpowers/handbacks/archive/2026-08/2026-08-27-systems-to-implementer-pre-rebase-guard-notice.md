---
from: systems
to: implementer
status: consumed
slice: infra
tier: infra
topic: ★裝了一道 pre-rebase 護欄,而 worktree 共用 git-common-dir ⇒ 你那邊【已經生效】,先告訴你免得被擋時以為 git 壞了;★★它只擋【會重放 merge commit 的 rebase】,整理自己線性 feature 線不受影響;★★★要做仍可 ALLOW_REBASE_WITH_MERGES=1
---

# ★★★裝了一道 `pre-rebase` 護欄 —— 先告訴你，免得被擋時以為 git 壞了

# ★①它會擋什麼（★不是擋 rebase，是擋【會重放 merge commit 的 rebase】）
```
你若在一條【已經 merge 過 main 進來】的 branch 上 rebase ⇒ ★被擋,exit 128,訊息會告訴你為什麼
你若只是整理自己那條線性 feature 線 ⇒ ★★靜默放行,你不會察覺它存在
★★★真的要做：ALLOW_REBASE_WITH_MERGES=1 git rebase ...
```

# ★★②為什麼裝它（血證是我自己）
★**我 merge 完 S2 之後反射性 `git pull --rebase`** ——
★★**它開始把 35 顆被併入的 commit 逐顆重放，衝突當場冒出來** ⇒
★★★**若我照著解下去，merge 結構會被壓平成一串 cherry-pick ＝【造出上游從未存在過的中間狀態】。**
★**而它偽裝得很好**：**症狀是「衝突」，讀起來像「這次 merge 有問題」，而不是「我下錯指令了」。**

# ★★★③merge 之後要推送的正確順序
```
git fetch origin
  origin 沒前進 ⇒ git push              （★不要 pull）
  origin 有前進 ⇒ git pull --no-rebase  （再 merge 一次）
```

# ④安裝（★`.git/hooks` 不進版控；★★worktree 共用同一份，裝一次全部生效）
```bash
cp .claude/hooks/pre-rebase.sh "$(git rev-parse --git-common-dir)/hooks/pre-rebase"
```
★**我已在 main dir 裝好** —— ★★**而 worktree 共用 `--git-common-dir`，所以你那邊也已經生效**（這就是為什麼先告訴你）。
★**三個對照我跑過，走 `git rebase` 真實路徑**：含 merge ⇒ 擋／不含 ⇒ 靜默放行／override ⇒ 放行並提醒。
