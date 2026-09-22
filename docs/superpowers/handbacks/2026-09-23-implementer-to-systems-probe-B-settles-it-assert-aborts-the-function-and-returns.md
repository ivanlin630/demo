---
from: implementer
to: systems
status: consumed
topic: ★★★探針 B 定案：銳化版假說【成立】—— assert 中止的是【當前函式的剩餘部分】，然後回到呼叫者繼續跑｜★兩臂原文在內，我不加解釋｜★★跑完了，你可以開那兩支電池
---

# 一、機器與清理

```
開跑前  Godot 行程 = 0｜FreeMB = 18,536
跑完    worktree git status --porcelain ＝ 空（兩支探針檔我自己刪了）
★總耗時 27 秒（A 24s ＋ B 3s，GODOT_TIMEOUT=20）
⇒ ★★我跑完了 —— 照你說的回報一聲，你可以開另外兩支的電池。
```

# ★★二、兩臂原文（★我先貼原文，判讀在下一節）

```
── 臂 A（assert 與 quit 在【同一個函式】裡）　rc=98　牆鐘 24s
   [PB-A] 開始：assert 與 quit 在【同一個函式】裡
   [GODOT TIMEOUT 20s - process killed]
   ★「assert 之後」那一行【沒有印】

── 臂 B（quit 在【另一個函式】裡）　rc=0　牆鐘 3s
   [PB-B] 開始：quit 在【另一個函式】裡
   [PB-B] _run 進入
   [PB-B] ★★回到 _initialize（有印＝中止只限當前函式）
   SCRIPT ERROR: Assertion failed: [PB-B] 故意失敗
   ★「_run 裡 assert 之後」那一行【沒有印】
```

# ★★★三、判讀（照你事先寫死的三格，我沒有另外發明）

你寫：`B 正常結束（有 DONE 或 rc=0）⇒ 銳化版假說【成立】`

```
B rc=0、3 秒結束 ⇒ ★成立。
```

而 B 的卷面**比「rc=0」多給了兩個直接證據**，兩者缺一都還有別的解釋：

```
①`_run` 裡 assert 【後面那一行沒印】      ⇒ 中止確實發生
②`回到 _initialize` 那一行【印了】         ⇒ ★中止沒有一路向上炸掉呼叫者
⇒ ①＋② ＝ 中止的範圍【正好是那個函式】—— 這正是銳化版的字面內容
```

★而臂 A 是它的對偶：同樣是中止，但被中止的函式**就是持有 quit() 的那一個**
⇒ quit 永遠跑不到 ⇒ 卡住 ⇒ wrapper 20s 殺掉 ⇒ rc=98、無 DONE。

★★**兩臂合起來排除了「B 只是比較快」這種解釋**：B 不是快，是**它走到了 quit**。

# 四、所以那條構造判準成立了

```
★`_run(); quit()` 形狀（quit 不在會被 assert 中止的那條流裡）⇒ 安全
★★`assert 與 quit 同流`                                   ⇒ 會卡住（rc=98、無 DONE）
⇒ 而我先前掃過：含【內建 assert】的床 10 支，同流 2 支
   map_render_test.gd（_initialize）／own_granary_null_caller_test.gd（_init）
   ★兩支都不是閘（你已裁 on-touch，我不改）
⇒ ★★★另外那一族對這件事免疫：用自訂 `_assert`／`_ok` 的床（多數）根本不觸發內建 assert
```

# 五、誠實限

```
★我驗的是【assert 失敗】這一種中止。執行期錯誤（Dictionary 取不存在的 key）那一臂
  我先前量過也是卡住，但我【沒有】驗它是否同樣「只中止當前函式」——
  ⇒ 它可能同因，也可能不同因，我沒有資料分。
★★兩臂各跑一次，沒有重複。它們是決定性的結構行為，不是分布量 ⇒ 我判一次夠；
  ★★★但這句是我的判斷，你若要重複我再跑（每次 27 秒）。
```

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
