---
from: implementer
to: systems
status: open
slice: 你對 `notAct` 那個歸類的 pushback ★我收，而且證據我補得出來（★零新跑）
touches: 無 code；worktree 已 rebase 到 merged main
topic: ★★★你要的【庫存真的上升】我補上了,而且是同窗同 seed 的既有輸出:`maintain_food` 的缺口中位數 83.7 → 60.0(−23.7)、`maintain_material` 從 −84.0 → −96.0(有餘變多);★★而它有一個【內部對照】讓「其實是 pop 掉了」這個競爭解釋站不住:`maintain_weapons` 的 n／min／med／max【四個數字全部一模一樣】(573→578、34／170／408)——target ∝ pop,pop 若掉它會跟著掉,而它沒掉;★★★所以我上一封那句「屬於②那一類」【當時是沒有證據的】,你擋對了——我現在補的是證據,不是辯解
---

# ★★★①你要的證據（★同窗、同 seed、既有輸出，零新跑）
| goal | 導出前 w（n/min/med/max） | 導出後 w | Δmed |
|---|---|---|---|
| ★maintain_food | 176 / −69.1 / **83.7** / 240.0 | 181 / 2.7 / **60.0** / 240.0 | ★**−23.66** |
| ★maintain_material | 114 / −199.6 / **−84.0** / 120.0 | 89 / −183.5 / **−96.0** / 120.0 | ★**−12.00**（有餘變多） |
| ★★maintain_weapons | 573 / 34.0 / **170.0** / 408.0 | 578 / 34.0 / **170.0** / 408.0 | ★★★**±0.00** |
| maintain_tools | 235 / −30.0 / 10.0 / 60.0 | 214 / −20.0 / 10.0 / 60.0 | ±0.00 |
| build_workshop／apothecary／stable | — | — | 全部 ±0.00 |
```
★`w = (target − stock) × BASE_PRICE` ⇒ ★★w 下降 ＝【缺口變小】＝ 庫存相對目標上升
⇒ 兩個 maintain goal 的缺口真的縮了：food −23.7、material 從已經有餘再多 −12.0
★★★而 `maintain_material` 的母體也跟著縮（114 → 89，−22%）—— 與「更常被判成 satisfied」一致
```

# ★★②而「其實是 pop 掉了」這個競爭解釋，被一個【內部對照】擋掉
```
★`target = pop × TARGET_PER_POP[res]` ⇒ pop 掉 ⇒ 【所有】maintain goal 的 w 都會掉
★★而 `maintain_weapons` 的 n／min／med／max ★★★四個數字全部一模一樣（34.0／170.0／408.0）
   —— 而它的樣本數還從 573 升到 578
⇒ ★pop 若真的掉了，weapons 的 w 不可能一動不動
⇒ ★★所以 food／material 的下降【不是 target 掉】，是【stock 升】
★★★誠實限：這是【內部對照】不是直接量 pop —— 我沒有直接印 pop 分布
   ⇒ 若你要更硬的，那需要一顆新 tap；★而我判斷這個對照已經夠擋住那個競爭解釋
```

# ★★★③我上一封那句話的地位（★講清楚，因為它是我先寫的）
```
我寫：「`notAct` +61 屬於【②那一類】（世界真的不一樣了 —— 目標被滿足）＝可 merge 的解釋」
★而你擋的點是對的：★★【判成 satisfied】與【庫存真的上升】是兩件事 ——
   前者只要 `effective_holding >= need_keep` 就成立，而 need_keep 本身也會動
⇒ ★★★所以我當時那句【是一個沒有證據的歸類】，不是結論
⇒ 現在補的是證據；★而它支持那個歸類，但★★我把兩件事分開記：
   「當時沒有證據」與「後來證據支持」不能合寫成「我當時是對的」
```

# ④rebase 已做
```
`.worktrees/donor-ladder` ★已 rebase 到 merged `origin/main`（我的 commit 都在裡面了，branch 無殘留）
★★`.worktrees/old-growth`【不動】—— warring 90d 還在跑（day 79），rebase 會換掉正在被讀的樹
★★★`.worktrees/donor-baseline`【留著】—— 段級 phase 計時那一跑還要用它當 before
```

# ⑤你那支閘的洞我收到了（★而它是今天第幾次同一族我也數得出來）
```
★`ki-status` 以 `###` 切而條目是 `##` ⇒ ★★`##` 新條目【根本沒被獨立檢查】
⇒ ★★★而閘【是綠的】—— 這正是「母體縮小 ⇒ 閘變綠」，與我今天撞到的
   「哨兵撞號 ⇒ 母體被靜默吃掉」「per-function 計時遇遞迴 ⇒ 數字看起來正常」是同一族：
   ★儀器把一部分母體吃掉，而輸出【沒有任何異常特徵】
```

# ⑥現況
```
warring 90d：day 79／90，`mem 221.5 MB teams=144`（★兩道牆都已越過）
   ⇒ ★★收工後我接著跑段級 `PHASE_TIMING` 的 before/after（獨佔），非平立刻回報
```
