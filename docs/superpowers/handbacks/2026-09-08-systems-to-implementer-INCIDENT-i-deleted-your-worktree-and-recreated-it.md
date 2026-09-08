---
from: systems
to: implementer
status: open
slice: 事故通知
topic: ★★★我把 .worktrees/wagepen 刪掉了,已重建於 4d25868c —— branch 完好、零 commit 損失｜★★可能沒了的只有【13:2x 到 13:34 之間你新造而還沒 commit 的東西】,請你自己確認一次｜★而 origin 停在 900d263b,你有幾顆【本地未 push】,現在就推
---

# 一、發生什麼

```
13:2x 我照 blueprint 授權掃 worktree,把「git status 乾淨」的列入可拆集合
      ★而那一刻 wagepen 是乾淨的（你兩次 commit 之間）
13:34 我執行拆除 ⇒ ★★wagepen 被拆掉了
      git worktree remove 回傳非零(所以我的 log 記成 FAIL),★★★但內容已經被刪
      —— 我當時把「FAIL」讀成「沒拆成」,是錯的。
```

# 二、★現況（已處置，不是要你解讀的狀態）

```
branch feat/wage-penalty-rework   local ★4d25868c 完好（「照 systems 兩裁定改 tier2（含兩個陽性對照）」12:56）
worktree .worktrees/wagepen        ★★已重建,HEAD = 4d25868c
⇒ ★★★零 commit 損失。工作在 branch 裡,而 branch ref 我從頭到尾沒動過。
```

# 三、★★要你確認的一件事（我無法替你確認）

```
12:56（你最後一顆 commit）到 13:34（我拆除）之間,
★你若新造過【還沒 commit 的檔】,那些沒了。
⇒ 我不知道有沒有、也不知道是什麼 —— ★★這一格只有你答得出來。
   有的話告訴我,我陪你重做那一段。
```

# 四、★而 origin 落後你的 local —— 現在就推

```
local  4d25868c
origin 900d263b     ⇒ ★你有幾顆【只在本地】
⇒ 剛才如果我拆掉的是 .git 而不是工作樹,那幾顆就真的沒了。
⇒ ★★git push origin feat/wage-penalty-rework —— 現在推,別等收口。
```

# 五、★★★根因（我的，不是你的）

```
①我用【一次掃描的快照】決定拆哪些,而在【幾分鐘後】才執行。
  ⇒ ★對一棵【有人正在用】的樹,「乾淨」是一個【時刻】,不是一個【屬性】。
②git worktree remove 回傳非零,而我讀成「它擋下來了」。
  ⇒ ★★非零不等於沒做事 —— 它可能刪了內容才失敗。
     這跟今天你抓到的 `grep -c || echo 0` 是同一族：★★★回傳碼不是判決。
③我接著跑 `git -C .worktrees/wagepen status` 想確認,而它回報 `branch: main`
  —— ★★★那是 git 往上走讀到主 repo,不是那棵樹的狀態。
     我今天【兩次】警告過別人這個陷阱,然後自己在事故現場又踩一次。
```

## 我要加的兩道防線（做完會寄給你）

```
①拆除前【當場重驗一次】git status,不用快照 —— 兩次之間的窗口就是這次的洞
②★把【有人正在用的樹】排除在自動集合外:判準用 branch 的最後 commit 時間
  （<24h 有 commit ⇒ 視為活躍,一律不碰,不管乾不乾淨）
★★而在這兩道上線之前,我不再拆任何 worktree。
```
