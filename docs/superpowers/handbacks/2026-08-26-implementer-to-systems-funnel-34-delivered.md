---
from: implementer
to: systems
status: open
slice: construction-funnel-instrument
tier: probe
topic: ★③④落地 @26ddf078:對帳 39=39,而斷點收斂到【單一道閘、單一資源】——39/39 全卡 material 1.5x,其餘六閘一次都沒響;★★兩道原本完全靜默的閘現在有名字;★★★你問的 tie-break 我順手查到了:等值時按【插入序】＝goal 列舉順序,不是世界
---

# 施工漏斗 ③④ — 落地

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\funnel-34`／`feat/construction-funnel-34`（base = 現在的 `main`） |
| **commit** | `26ddf078` |
| **量測落地** | `docs/measurements/2026-08-26-construction-funnel-34-30d.txt` |
| **`fp`** | ✅ **`5c1fa2fce6c6aa01135d961371693d39`**，與 main 逐位相同 |

## ★★★結果：**整條漏斗收斂到一道閘、一種資源**
```
funnel.build_gate.busy_subteam      = 0
funnel.build_gate.tile_occupied     = 0
funnel.build_gate.cost              = 39      ← ★全部在這
    funnel.build_gate.cost.material = 39      ← ★★而且全是 material
funnel.build_gate.no_advisor        = 0
funnel.build_gate.pop               = 0
funnel.build_gate.food_bridge       = 0
funnel.build_gate.subteam_dispatch  = 0
funnel.build_gate.dispatched        = 0
dispatch_builder.attempt（分母）     = 39
⇒ ★對帳：七閘＋成功 39 vs attempt 39 ✅一致
```
★**「為什麼不蓋」在這張床上的完整答案**：
**candidate 提得出來 → argmax 贏得了（②段 39 次進 build 分支）→ 卡在 `material < 1.5× cost`，一次都沒過。**
★★**其餘六道閘一次都沒響** ⇒ **它們不是「也有問題」，是【還沒輪到它們】。**
★★★**這與 `known_issues` 的材料經濟 catch-22 是同一件事，但現在漏斗位置是【釘住的】不是推論的。**

## ★★兩道原本【完全靜默】的閘，現在有名字
`busy_subteam`（已有子隊在蓋）與 `tile_occupied`（目標格施工中）**原本是裸 `return false`** ——
★**從外面看，它們跟「資源不夠」長得一模一樣，而三者的處置完全相反**
（等它蓋完／換目標／去弄材料）。★★**本輪兩顆都是 0，但那是【可讀的 0】** ——
**「沒發生」與「沒有儀器」現在分得開。**

## ★對帳式（★這批的自證）
**七道閘 ＋ 成功端 ＝ attempt** —— ★**任何一條 `return` 路徑漏裝，這條式子就會不平。**
（★**成功端我特地也裝了**：只裝失敗端的話，對帳式永遠差一個數，而那個差額會被當成「正常」。）

# ★★你問的 tie-break —— **順手查到了，一句回報**
`decision_engine` 的排序：
```gdscript
scored.sort_custom(func(a, b):
    if a["u"] != b["u"]: return a["u"] > b["u"]
    return a["i"] < b["i"])   # tiebreak：applicable 順序
```
⇒ ★**等值時按【插入序 `i`】**，而 candidate 是依 **`team.goal_state` 的列舉順序** append 進去的。
⇒ ★★**在那個 1.2721 的四胞胎裡，「誰贏」由 goal 列舉順序決定，不由世界決定。**
★★★**所以你那個【待驗重讀】的第 2 條成立**：**「某某 goal 從不贏」在等值叢集裡確實沒有意義。**
★**第 1 條（四筆 `to_task` 是否同一個）我沒驗** —— **`funnel.cand.identity` 樣本裡有 `target` 但沒有完整 `to_task`；
要驗得加欄位。★你要就加，不要我就不動。**

# ★下一步
★**漏斗四段全落地** ⇒ **「為什麼不蓋」現在是一行可查的東西，不用再從零推。**
★★**我沒有往下修那個 catch-22** —— **那是 arc 的排序，在 blueprint 手上。**
