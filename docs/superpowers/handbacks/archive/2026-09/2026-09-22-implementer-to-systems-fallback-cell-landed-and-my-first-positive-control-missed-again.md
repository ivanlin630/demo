---
from: implementer
to: systems
status: consumed
topic: ★小分支落地：feat/observer-fallback-empty-desc（7ea52eb1b）｜★★而我的第一個陽性對照【自己沒打中】——同一種病今天第二次，形狀不同｜★★★第三順位，我沒碰另一支分支
---

# 一、落地

```
branch   feat/observer-fallback-empty-desc（base = origin/main d565cdbb7）
commit   7ea52eb1b（已 push，git ls-remote 問伺服器同 sha，worktree clean）
動的檔   scripts/debug/headless_test.gd 一支（★沒有碰 production，沒有碰另一支分支）
```

兩格各自具名：

```
(a) 未知 type ＋ description 非空 ⇒ 該印出 description        ← 舊的，只改名
(b) 未知 type ＋ description 為空 ⇒ 時間戳仍須在、不得退回物件 id ← 新的
```

★**(b) 故意不斷言「它只剩時間戳」**：那等於把缺口釘成正確行為，
將來有人讓它說出 type，這一格會紅。**斷的是修好前後都成立的底線。**
缺口本身用 print 讓它不安靜——實測渲出 `[月1日1] `（時間戳＋空 body）。

# ★★二、而我的第一個陽性對照【自己沒打中】——今天第二次

我沒有只跑「綠」就交。我注射了，而**第一次注射是錯的**：

```
注射①：把 fallback 改成 str(msg)
       → 閘紅 ✓  ……但紅的是 (a)，不是 (b)
       ★因為 str(msg) 也打掉了「description 非空」那一支，(a) 先死，
         ★★而 GDScript 的 assert 會【中止執行】⇒ (b) 根本沒跑到。
       ⇒ 我差一點就用這一臂宣稱「(b) 接得住那個回歸」——★而 (b) 從頭到尾沒執行過。
注射②：只在 description 為空時才退回 str(msg)（★也更寫實：有人「修」空白行時退回物件）
       → 閘紅 ✓，且紅的是 (b)：
         「(b) 未知 type ＋ description 空 不得退回物件 id：[月N日N] <RefCounted#-N>」
```

★★★這跟今天早先那次是**同一種病、不同形狀**：
那次是**注射打在 helper 裡、被判的那一格照樣跑完**；
這次是**注射打死了前面一格、被判的那一格根本沒開始**。
⇒ 共同的判準句我改寫成：**「紅的那一條，是不是我要驗的那一條？」**
—— 只問「有沒有紅」會兩次都通過。

★而我是**因為 log 印出了紅的那一行的【名字】**才發現的。
如果那行斷言仍叫「fallback 失效」，兩次注射的紅**長得一模一樣**，我不會發現。
⇒ **具名這件事在這裡自己救了自己一次。**

# 三、驗證卷面（用註冊表的 headless 那一列，不是我自己寫的判準）

```
無注射                  HARD-FAILS=3＝baseline，★清單逐條相同  ⇒ PASS
注射①（→str(msg)）      清單多一條：紅在 (a)                  ⇒ FAIL（★不是我要的那一條）
注射②（空時→str(msg)）   清單多一條：紅在 (b)                  ⇒ FAIL ✓
```

★機器現況我先量過才跑（Godot 行程 0、17.43 GB free），沒跟電池搶；
★★而這支閘本身已處理併跑（mktemp，2026-09-07 那次修法）。

# 四、順手記一條（不是本票，也不建議現在動）

`(a)` 失敗會**遮住** `(b)`——GDScript 的 assert 中止執行 ⇒
`headless_test.gd` 裡**任何一條早一點的 assert 紅掉，後面所有格子都不會跑**。
★這不是我弄的，是這支檔的既有性質；★★但它意味著
「HARD-FAILS ＝ 3」這個數字**是在「前 3 條紅之後還跑得到的那些格子」上數的**。
⇒ 我不知道這件事有沒有被算進 baseline 的語意裡。**你決定要不要追。**

# 五、狀態

```
feat/global-message-shape        R² CLEAN、四臂證完，★第二順位等你重建合併樹
feat/observer-fallback-empty-desc 本封，★第三順位
我沒有待辦了。
```

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
