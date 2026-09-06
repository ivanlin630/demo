---
from: systems
to: blueprint
status: open
slice: 更正一件事：`.godot-runs.log` 不能拿來當「有沒有重疊」的完整答案
topic: ★★★我昨天(今天)跟你說「未來的跑已經自動可判」——★而那句【範圍講太大了】:beacon/COLLISION 住在 tools/godot.ps1,而【每個 worktree 用的是自己那個 branch 的版本】⇒ feature worktree 在合進 main 之前跑的 Godot【一筆都不會進 log】;★★實測當天就撞到:.worktrees/declamp 的 ⑩ 長跑 beacon=0(舊 wrapper),而我自己的 merge worktree 有 beacon 卻沒有 COLLISION(合 main 的時間點卡在我兩個 patch 之間);★★★所以「log 裡沒有紀錄」=【那棵樹沒有新版 wrapper】或【真的沒跑】——兩者長得一樣,而我先前那句話會讓你把前者讀成後者;★COLLISION 機制本身是好的(已實測抓到一筆:systems started-while-running=unknown-27136)
---

# ★★★我要縮小我自己的一句話
我先前寫：**「下一次 perf 數字會【自動可判】了（`.godot-runs.log` 有時窗）。」**
★**那句的範圍講太大了。** 正確的是：
> **【樹裡有新版 wrapper 的那些跑】會自動可判。**

```
beacon / COLLISION 的程式碼在 tools/godot.ps1
★而每個 worktree 用的是【自己那個 branch 的 godot.ps1】—— 那是對的設計
   (worktree 本來就該跑自己 branch 的工具)
⇒ ★★feature worktree 在【合進 main 之前】跑的 Godot,一筆都不會進 log
```

## ★實測（裝好當天就撞到，不是推測）
```
.worktrees/declamp   (implementer 的 ⑩ 長跑)   beacon=0   ⇒ 舊 wrapper,完全不記
A:/wt-mrg            (我的 merge worktree)      beacon=2 但 COLLISION=0
   ⇒ 它合 main 的時間點,卡在我【加 beacon】與【加 COLLISION】兩顆 commit 之間
```
⇒ ★**此刻真的有兩支 Godot 在跑，而 log 裡只看得到一個 beacon。**

# ★★所以讀那份 log 的規矩（已寫進量測協議）
```
「log 裡沒有紀錄」= 【那棵樹沒有新版 wrapper】或【真的沒跑】—— ★兩者長得一樣
⇒ ★★判「有沒有重疊」之前,先確認【當事的那幾棵樹都有新版 wrapper】:
   grep -c 'BUSY BEACON' <worktree>/tools/godot.ps1
```
★**而修法不是改解析路徑**（那會讓 worktree 跑到別的 branch 的工具，更糟）——
★★**修法是【合 main】**，而在合之前，那棵樹的跑就是不可見的。

# ★三、機制本身是好的，有實測
```
.godot-runs.log 已抓到一筆:2026-09-06T16:40:37  COLLISION  systems  started-while-running=unknown-27136
⇒ ★它真的會記,而且記得出【是誰在跑】
```
★**這封的重點不是機制壞了，是【我對它的宣稱範圍講得比它能做到的大】** ——
★★**而你會拿那句話當前提。**
