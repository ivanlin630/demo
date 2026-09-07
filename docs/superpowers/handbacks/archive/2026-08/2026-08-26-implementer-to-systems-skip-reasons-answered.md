---
from: implementer
to: systems
status: consumed
slice: goal-skip-reason
tier: probe
topic: ★對帳每天都平(六類互斥且窮盡);★★答案不是三選一是【三格都有量】:not_active 937 全是 satisfied、facility_resolve_empty 448、emitted_facility day2-5 為 0 但 day6 起回來;★★★而最後那一欄是【讀法陷阱】,我先講:它算的不是「生出 build 候選」;交付 @e4665428
---

# `goal.skip.*` — 落地

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\skip-reason`／`feat/goal-skip-reason` |
| **commit** | `e4665428` |
| **量測落地** | `docs/measurements/2026-08-26-goal-skip-reason-30d.txt` |
| **`fp`** | ✅ **`07285478…`**，與 main 相同 |
| ★**對帳** | ✅ ★**每一天都加得回 `seen`**（六類互斥且窮盡） |

# ★★答案：**不是三選一，三格都有量**
```
goal.skip.not_active                = 937  ★而且 status 全部是 "satisfied"
goal.skip.facility_resolve_empty    = 448  build_stable 157／build_apothecary 152／build_workshop 125／build_farming 14
goal.skip.no_def                    = 0
```
| 你問的三格 | 實測 |
|---|---|
| **不在清單裡了** | ★**否**（`no_def = 0`，goal 都在） |
| ★**在但被判 satisfied** | ★★**937 筆，最大宗** |
| ★**active 但解不出候選** | ★★**448 筆，第二大** |

⇒ ★★★**兩個機制同時在讓 build 沉默，而它們的修法不同** ——
**一個是「被判定為已滿足」，一個是「試著解但解不出來」。**

# ★★★讀法陷阱（**我先講，因為它會把人帶反方向**）
```
emitFac：day0 39 ｜ day1 27 ｜ day2-5 0 ｜ ★day6 起又回來（9/6/9/3/9/9/3…）
```
★**乍看像「build 候選 day6 又活了」，而漏斗那份說 `funnel.cand.build` day1 起恆 0** —— **兩者看似矛盾。**
★★**不矛盾**：`emitted_facility` 算的是 **`_resolve_build_facility` 回了非空**，
**而它在缺料時回的是【去買材料】的 candidate（`task = TASK_TRADE`），不是 build 候選。**
⇒ ★★★**這一欄回升 ＝【又開始想買料了】，不是【又開始想蓋了】。**
★**這正是戲服那顆的時間軸版本** —— **同一個機制，第三次以不同面貌出現。**
★★**我把這段寫進 commit 與床的註解**，**因為單看任一欄都會得到錯的故事。**

# ★形狀
- **六類一對一對應迴圈的每個出口**（`not_active`／`no_def`／`facility_resolve_empty`／
  `prereq_all_empty`／`emitted_facility`／`emitted_prereq`）＋ **分母 `seen`**
- ★**逐日對帳、每天各自平**（不是總數平就好 —— **總數平可以掩蓋兩天互相抵消**）
- ★★**細分只在總量層**（`status.*`／`gt.*`），**不進日桶** ⇒ key 不爆
- ★**註解寫壞掉會長什麼樣**：**日後有人加 `continue` 沒加 reason ⇒ 對帳差一個數，
  而差額會被當成正常** —— **那正是「習慣了的異常」。**

# ★下一步（**不自己開**）
★**兩條線，處置不同，建議分開派**：
1. ★**`satisfied` 937**：**build goal 憑什麼被判 satisfied？** —— 若判準是「facility_level > 0」之類，
   那 **day 0 蓋完一座就全家族 satisfied** 是可能的；★**這要讀 `ensure_maintain_goals`／`GoalRegistry` 的 satisfied 判定。**
2. ★**`facility_resolve_empty` 448**：**答案在 `_resolve_build_facility` 內部** ——
   ★**它有多個 return 空的出口，同一招（互斥且窮盡）可以再用一次。**
★★**我傾向先做 2**（★**同一個對帳形狀、風險低**），**但 1 可能才是 937 那個大數的所在。★你排。**
