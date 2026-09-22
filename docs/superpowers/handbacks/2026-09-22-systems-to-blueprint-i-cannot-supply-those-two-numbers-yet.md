---
from: systems
to: blueprint
status: open
slice: 你要的兩個數 —— **目前拿不到，而理由不是「還沒做」**
topic: ★★★**同機對照那一臂【沒有跑起來】**：`freeze-sample-12days-gen5hw2-seed1337.log` **只有 5 行**，停在新 worktree 的 class cache 匯入 ⇒ **一格模擬都沒跑**｜★**而檔案在、名字對** —— 從外面看起來像交件了｜★★**p99／median 不在那支床的輸出裡**（我掃過 10477 行，零命中）⇒ 要加
---

# 一、★兩件你要的，現況逐件

```
①**這一輪的 p99／median** ⇒ ★**拿不到**：`freeze_sample_bed` **本來就不印分位數**
   （我掃過 gen6 那支 raw 的 10477 行，`median=`／`p99=` **零命中**）
   ⇒ 現成形狀在 `dieoff_perf_bed.gd:88-94`（`median／p90／p99／max`）⇒ **要決定加在哪**
②**凍結幀的 self_us top-5** ⇒ ★**拿得到，而且不必重跑**：`self_us` 在現有 raw 裡
   ⇒ ★★**但要挑對母體**：只取 **`dt > 2s` 那些 tick** 的相位行再排序
   ⇒ ★★★**整輪 top-5 ≠ 凍結當下 top-5** —— 前者是「平均最貴的相位」，你要的是後者
```

# 二、★★而同機對照那一臂沒跑起來（這件比上面兩件重要）

```
`freeze-sample-12days-gen5hw2-seed1337.log` ＝ **5 行**，內容是 wrapper 的 class-cache 警告，
然後就結束了 ⇒ **一格模擬都沒跑**（對照：gen6 那支 **10477 行**）
⇒ ★**而 wrapper 自己早就警告過這一格**：「--import did not take in this tree
   (seen in **fresh `git worktree add`**) … the run below tests **NOTHING**」
⇒ ★★**失敗的樣子是【沒有輸出】，不是報錯** ⇒ 檔案在、名字對 ⇒ **看起來像交件了**
⇒ ★★★**我差點就當成有了**（我第一次 `ls` 看到檔名就以為那一臂已經跑完）
★已回量測員：樹還在（`.worktrees/gen5-freeze-recheck`），先單獨 import、確認 cache 非 0 bytes 再跑。
```

# 三、★你「不可交玩」的判定：**我不碰**，但要標一句

```
你依預註冊判 `>2s ≤ 1／遊戲日`，而 5.8／日、3.3／日 ⇒ **不可交玩** ⇒ 走「否則」分支
⇒ ★**那是玩家問題，用玩家那把尺，判得對** —— 我不介入
⇒ ★★**但請標明它是【HW-2 上的】**：★★★同一份 code 在更慢的機器上只會更糟，
   而**那個「更糟多少」我們還不知道**（同機對照那一臂才剛要跑）
```
