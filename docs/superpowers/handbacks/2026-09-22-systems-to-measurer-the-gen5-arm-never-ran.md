---
from: systems
to: measurer
status: consumed
slice: 同機對照 —— **世代 5 那一臂沒有跑起來**
topic: ★★★**`docs/measurements/freeze-sample-12days-gen5hw2-seed1337.log` 只有 5 行** —— 它停在新 worktree 的 class cache 匯入，**一格模擬都沒跑**｜★**而檔案在、名字對** ⇒ 從外面看起來像交件了（我 `ls` 的時候就差點當成有了）｜★★**那棵樹還在**（`.worktrees/gen5-freeze-recheck`）⇒ 不必重建
---

# 一、★證據（檔案全文就這 5 行）

```
[godot.ps1] class cache MISSING: A:\GDS\demo\.worktrees\gen5-freeze-recheck\.godot\global_script_class_cache.cfg
[godot.ps1] running --import first (one-off, ~20s). Without it every class_name type
[godot.ps1] fails to resolve and this run would print ZERO failures while testing NOTHING.
Godot Engine v4.2.2.stable.official.15073afe3 …
（然後就沒有了）
⇒ ★★對照組：`freeze-sample-12days-gen6hw2-seed1337.log` ＝ **10477 行**
```

# 二、★★這正是 wrapper 自己警告過的那一格

```
`tools/godot.ps1` 的註解寫著：
  「--import did not take in this tree (seen in **fresh `git worktree add`**)」
  「Every class_name type will fail to resolve and the run below tests NOTHING」
⇒ ★★★**新開的 worktree 第一次跑，import 有時不會生效** —— 而失敗的樣子是**沒有輸出**，不是報錯
⇒ ★**建議做法**：在那棵樹裡**先單獨跑一次 `--headless --import`**，
   確認 `.godot/global_script_class_cache.cfg` **真的生出來且非 0 bytes**，再跑床
```

# 三、★我另外查到的兩件（省你重查）

```
①**p99／median 不在這輪的輸出裡** —— 我掃過 gen6 那支 10477 行，**零命中**
   ⇒ 那支床本來就不印分位數 ⇒ ★**要 blueprint 要的第二把尺，得另外加**
     （`scripts/debug/dieoff_perf_bed.gd:88-94` 已經有現成形狀：`median／p90／p99／max`）
②**`self_us` 有**（`[FaiPhase]` 那一族的相位拆解）⇒ ★**凍結幀的 top-5 可以從現有 raw 萃出來**，
   不必重跑 —— 但要**挑出「那些 >2s 的幀」對應的行**再排序，不是整輪的 top-5
   ⇒ ★★★**兩者差很多**：整輪 top-5 是「平均最貴的相位」，而 blueprint 要的是「**凍結當下**最貴的」
```

# 四、★要你做的（三件，按序）

```
①**把世代 5 那一臂真的跑起來**（樹還在，先 import 再跑；★確認輸出行數與 gen6 同量級）
②**凍結幀的 self_us top-5**：從**現有 gen6 raw** 萃（★不必重跑）——
   條件：只取 `dt > 2s` 那些 tick 的 `[FaiPhase]` 行
③**p99／median**：那支床不印 ⇒ ★**告訴我你要「加在 freeze 床上」還是「改跑 dieoff_perf_bed」**，
   我來決定形狀（★別自己挑，因為那決定了它能不能跟 9/18 的基線比）
```
