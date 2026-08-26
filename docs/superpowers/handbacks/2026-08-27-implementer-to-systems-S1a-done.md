---
from: implementer
to: systems
status: open
slice: S1a-bare-tick-scanner
tier: refactor
topic: ★做完 @160936b5（已 push）:候選 143 筆、走訪 118 檔、★一顆字面量都沒改;★★驗收①我用【production diff 為空】直接證明(比 fp 更直接),而 peaceful_economy 的 fp 是【新基線不是驗證未變】——那張床從來沒量過,我說明理由;★★★誠實限寫進【輸出頭】不是只寫在信裡
---

# ★①清單落地 — **exact path**

```
A:\GDS\demo\.worktrees\old-growth\docs\measurements\2026-08-27-bare-tick-candidates.txt
git show 160936b5:docs/measurements/2026-08-27-bare-tick-candidates.txt
掃描器：scripts/debug/bare_tick_scanner.gd
```
★**每筆一行、ASCII `|` 分隔、可 grep**：`path|line|literal|symbol|note|source`
★★**無 emoji 當欄位錨**（★今天那條血證：emoji 打進 grep pattern 會回假 0）。

## ★★數字
```
走訪 118 檔｜★候選 143 筆
依檔  ：faction_ai 46｜sim_runner 12｜team_data 11｜harvest 6｜order 5｜world_state 5…
依符號：current_tick 78｜TICKS_PER_DAY 21｜TICKS_PER_HOUR 12｜TICKS_PER_MONTH 8…
★note ：const_def 28｜decl_init 27｜未標 88
```
★**`note` 是【標籤不是過濾】** —— ★★**一筆都沒丟，母體完整**；標籤只是讓你 S1b 分流便宜一點。
**（`decl_init` ＝ `var x_eval_next_tick: int = 0` 這種宣告初值；`const_def` ＝ `const X = 240` 這種。）**

---

# ★★★②spec 的那個死前提，我開檔驗過了
★**LOCKED spec 寫「擴充 `time_const_check.gd`」** —— **那支 `wc -l` = 25，內容是 10 顆具名常數的硬編數值比對表，零掃描能力。**
⇒ ★★**掃描能力從零建，照你信裡的判斷。**

---

# ★★★③驗收①：我用【production diff 為空】直接證明，而不是只靠 `fp`
```
git diff HEAD -- scripts/simulation scripts/data scripts/ui config   → ★空
本票改的檔：scripts/debug/bare_tick_scanner.gd（新）＋ scripts/debug/a4_determinism_check.gd
```
★**這比 `fp` 更直接**：**S1a 只新增 debug 掃描器 ⇒ 「有沒有動到不該動的」用 diff 一句就答完。**

## ★★而 `peaceful_economy` 的 `fp` 是【新基線】，不是「驗證未變」——我要講清楚
```
warring_states   : 06580e7fbaaa4dedc184cb721ffe24f6   ←★逐位元不變
peaceful_economy : 533ebf6842420fa4673bda039ad0dad2   ←★★【新基線】
```
★**理由**：`a4_determinism_check` **先前硬編 `warring_states`** ⇒ ★★**那張床從來沒量過 `fp`，沒有 before 可比。**
⇒ 我加了 `FP_CONFIG` env（★**預設仍 `warring_states`** ⇒ **既有呼叫端一行不變**）才量得到。
★★★**所以「兩張床都不變」這句我【不能】說** —— **我只能說「一張不變、另一張今天才有基線」。**

# ★④陽性＋陰性對照（★走同一支 `_scan_line`）
```
CONTROL|mod     |hits=1|if current_tick % 5 == 0:
CONTROL|cmp     |hits=1|if team.order_eval_next_tick > 120:
CONTROL|addsub  |hits=1|var n: int = state.world.current_tick + 240
CONTROL|negative|hits=0|var hp: int = 100 + 5
```
★**陽性 3/3**（`%`／比較／加減 三種位置）——**證明它【有看那裡】。**
★★**而我加了你沒要求的【陰性】**：**沒有 tick 符號的行必須 0 hit** ——
★★★**否則掃描器等於全抓，143 這個數字就毫無資訊。**（**兩者都印在輸出頭。**）

# ★★★★⑤誠實限寫進【輸出頭】
> **本掃描器是文字比對，看不到「把 tick 存進改名變數後再比裸值」**
> `var t = current_tick` ← 看不到／`if t % 5 == 0:` ← 這顆裸 5 逃掉
> ⇒ ★**清單【不是完備的】。**

★**寫在輸出頭而不是只寫在這封信** —— ★★**讀清單的人未必讀過這封信，而他會以為清單是完備的。**

# ★⑥我【沒有】做的（照你列的）
★**沒改任何字面量**／★**沒判 (a)/(b)/(c)**／★★**沒把守衛掛進 merge 流程**（清單還沒結案，掛了會對著一堆未處置的東西狂紅）。

# ★⑦下一步
★**S1b 的母體已經在那個檔裡** —— ★★**143 筆，逐顆結案時可以直接對帳「每一筆都有處置」。**
