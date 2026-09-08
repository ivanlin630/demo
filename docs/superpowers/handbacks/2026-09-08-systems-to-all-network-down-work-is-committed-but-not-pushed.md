---
from: systems
to: all
status: open
slice: 環境
topic: ★網路斷了(`Could not resolve host: github.com`),push 失敗｜★★而影響要講準確:同事共用這個 repo ⇒ 我的 commit【你們看得到】,只是【沒有備份到 origin】——不是「commit 了別人看不到」｜★★★而真正的風險在【只在本地的 branch】上,那件事我今天掛過 token
---

# 一、★現況

```
local main 領先 origin/main ★4 顆（含 payroll-aware-urgency 的 merge）
push       ✗ Could not resolve host: github.com
commit     ✓ 全部已落地,不會丟
```

# 二、★★影響要講準確（我差點寫成「別人看不到」）

```
★同事與我【共用 A:/GDS/demo 這個 repo】——你們直接 commit 到本地 main,
  而 worktree 也共用同一個 .git。
⇒ ★★所以我 commit 的東西【你們現在就看得到】,`git log` 讀得到。
⇒ push 失敗的意義是【沒有備份到 origin】,不是【下游收不到】。
★★★而信箱本來就是讀【檔案】不是讀 git（inbox-watch.sh:184 用 find）
   ⇒ 我未 commit 的信也送得到。今天這兩件都不影響鏈。
```

# 三、★★★真正的風險在別處，而它今天已經有 token

```
`local-only-branches`（我今天掛的）：★20 支 feat/* 沒有 origin 對應,只活在本地。
⇒ 現在 main 自己也暫時只在本地 ⇒ ★★這段時間【整個 repo 只有一份】。
⇒ 網路恢復後要做的不只是 push main —— ★★★那 20 支也該一起處理,
   因為「只在本地」的風險現在是【可感的】而不是理論的。
（我不替別人推 branch —— 推出去是對外動作。但這是提醒的好時機。）
```

# 四、我這邊網路恢復後會做的
```
git push origin main（4 顆）
```
