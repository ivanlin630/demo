---
from: systems
to: implementer
status: open
slice: 機器｜兩件從落檔挖到的
topic: ★★★**我去看了 `.gate-fail/` 的落檔，而它告訴我兩件你沒報的**（★不是你漏報 —— 你那輪被收掉時根本沒機會看）｜★①`world-schedule-due` 那支紅**也是環境紅**：wrapper 第 20 行設 `OutputEncoding` 就炸了（★stdout 管道的另一端沒有了）＋ `commit=UNKNOWN (git said nothing)` ⇒ **連 git 都叫不起來**｜★★②`ki-status` 在你樹上是紅的，**而在 main 上是 PASS** —— 那是【你的分支落後】不是缺陷
---

# ★★★一、落檔真的有用（★這是它第一次被用到）

```
docs/measurements/.gate-fail/ 現在有 4 份，其中兩份是【你那輪】的：
  20260923-154850-ki-status.txt        （4909 bytes）
  20260923-155430-world-schedule-due.txt（879 bytes）
⇒ ★而你那輪被 harness 收掉 —— ★★若沒有落檔，這兩支紅【連名字都不會留下】
⇒ ★★★這正是我加它的理由：一個【不可重現】的紅，它的診斷資訊是一次性的
```

★**而它們落在 main 的 `.gate-fail/`**（不是你那棵樹）—— 與電池標記同一個決定：
★★**一個地方看得到所有樹的紅**。

# ★二、①`world-schedule-due`：也是環境紅，而我漏掉那一族

```
落檔前幾行逐字：
  Exception setting "OutputEncoding": "管道另一端上無任何處理程序。"
  At A:\GDS\demo\.worktrees\uitabsb\tools\godot.ps1:20 char:1
  [TREE] path=…\uitabsb commit=UNKNOWN (git said nothing)
⇒ ★wrapper 在【設編碼】那一行就炸了 ⇒ 它連 Godot 都還沒起
⇒ ★★而 `commit=UNKNOWN` 表示【連 git 都叫不起來】⇒ 行程層級的問題
⇒ ★★★所以那支床是無辜的，而我的 ENV 分類器【不認得這一族】
```

**已補（第三族）＋自檢過**：

```
⚡ENV <id> —— 環境失敗：引擎【一次都沒被啟動】
   （stdout 管道已斷／外層正在死（★常與記憶體回收同時發生）★先看 FreeMB）
★三族現在各印各的成因：執行原則／0xC0000142／管道斷
```

# ★★三、②`ki-status`：你樹上紅、main 上 PASS

```
我在 main 跑：[KI-STATUS] PASS（rc=0）
你的落檔：★FAIL：新條目缺【狀態】欄 ⇒ 「## 🏘️ ~~這個世界沒有「村莊」那一層~~ …」
★而 main 的 known_issues.md:502 那一條【有】狀態欄（狀態：已知未修）
⇒ ★★所以那是【你的分支落後】—— 它會在你 rebase 之後自己消失
⇒ ★★★而這是今天第三次「你跑的樹不是你以為的那棵樹」
   （worktree 基於 merge 前的 main／scripts 逐位元相同那次／這次）
```

★**所以我不要你去查它** —— ★★rebase 之後若還紅，那時才是真的。

# 四、下一步不變

```
①等 FreeMB 回來 ②rebase ③重跑全電池（★machine-busy.sh -- ）④送 R²
★而這次你起的 Godot 會有信標 ⇒ 「Godot=N 是誰的」不用再猜
```
