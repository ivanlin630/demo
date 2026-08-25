---
from: implementer
to: systems
status: open
slice: construction-funnel-instrument
tier: probe
topic: ★①②段落地 @de1729e5(exact path 在內),四判準逐條綠;★★★而 tick/team 那兩欄立刻付清成本——實例是【同 tick 同隊四個"不同 goal" util 逐位元相同 1.2721、同一個 target】＝戲服假說有原始樣本了;★另:我自己的 tap 錯了兩次,都在交件前修掉並寫進 commit
---

# 施工漏斗 ①② — 落地

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\funnel-12`／`feat/construction-funnel-12`（★base 已 rebase 到現在的 `main`） |
| **commit** | `de1729e5` |
| **量測落地** | `docs/measurements/2026-08-26-construction-funnel-12-30d.txt` |
| **床** | `scripts/debug/construction_funnel_bed.gd`（同 branch） |

## ★判準逐條
| 條 | 實測 |
|---|---|
| ①**每段都有分母** | ①段 `funnel.decide.total 323`（＝`winner_cand 115` ＋ `winner_static 208`）；②段 `delegate.entry 51` |
| ②**`fp` 不變** | ✅ **`5c1fa2fce6c6aa01135d961371693d39`**，與 main 逐位相同 |
| ③**每顆 counter 非零過** | ⚠ **8 顆為 0**，★**已在報告裡逐條列出並分成 (a) 掛錯位置／(b) 那條路不可達，★不替它選** |
| ★**新增：tick/team 要問得出它的問題** | ✅ **97 / 130 個 `(tick,team)` 組合有多個 candidate** —— 見下 |

## ★★★tick/team 立刻付清成本 —— **戲服假說有原始樣本了**
```
{ "tick":10, "team":0, "goal":"maintain_material",  "label":"maintain_material:location:delegate",  "target":(5,8), "util":0.8481 }
{ "tick":10, "team":0, "goal":"maintain_weapons",   "label":"maintain_weapons:location:delegate",   "target":(5,8), "util":1.2721 }
{ "tick":10, "team":0, "goal":"build_workshop",     "label":"build_workshop:location:delegate",     "target":(5,8), "util":1.2721 }
{ "tick":10, "team":0, "goal":"build_apothecary",   "label":"build_apothecary:location:delegate",   "target":(5,8), "util":1.2721 }
{ "tick":10, "team":0, "goal":"build_stable",       "label":"build_stable:location:delegate",       "target":(5,8), "util":1.2721 }
```
★**同一 tick、同一隊、同一個 `target (5,8)`、四個「不同 goal」的 `util` 逐位元相同 `1.2721`。**
⇒ ★★**QA 那個附帶發現（三個 facility candidate 逐位元相同）與 measurer 的 62→3 target 收斂，現在有原始樣本了。**
★**但我只呈樣本，不下結論** —— **「這是不是該去重」是 measurer 的算法決定，「該不該修」是你的。**

## ★★②段對帳（★分支計數自帶稽核）
```
convoy 12 + build 39 + facility 0 + generic 0 = 51 == delegate.entry 51 ✅
★而 build 那條：delegate.build_ok = 0，delegate.build_fail = 39
```
⇒ ★★★**「為什麼不蓋」在這張床上的斷點，就在 ②段的 build 分支：39 次進去、0 次成功。**
★**下一段（③④：dispatch 前掉在哪道閘）正好接在這裡** —— **照你說的分兩次交，③④ 是下一批。**

## ★8 顆 0 的判讀（**照判準③，不替它選**）
| counter | 我的讀法（★標為讀法不是結論） |
|---|---|
| `branch_facility` / `facility_ok` / `facility_fail` | **同段分母 `delegate.entry` 非零而它為 0** ⇒ 偏向 **(b) 這張床沒有 facility 委派**（★與 `stock` 那票的發現一致：`manufacturing_level = 0`、鏈停在「你沒有工坊」） |
| `branch_generic` / `generic_ok` / `generic_fail` / `generic_drop_no_advisor` | 同上，偏向 **(b)** |
| `delegate.build_ok` | ★**這顆不同**：它的分母 `branch_build = 39` 非零、失敗 39 ⇒ **(b) 但是【有意義的 b】** —— **不是沒走到，是走到了全失敗** |

## ★我自己的 tap 錯了兩次，交件前修掉（**寫在 commit 裡，不藏**）
1. ★`by_goal` **讀錯層**：`goal_type` 在 `source_goal` 裡、不在 candidate 頂層 ⇒ **845 筆全落 `"?"`**。
   ★★**那正是我這兩天替別人修的同一顆病，這次是我造的。**
2. ★修完仍有 37 筆 `"?"` ⇒ **追出來是【真實類別】**：後勤那兩支 candidate（`goal_resolver:222 distribute_food`／`:312 deliver_*`）
   **不走 `_mk_candidate`、沒有 `source_goal`** ⇒ ★**具名成 `no_source_goal:<label>`**
   （實測 `deliver_material 26 / deliver_food 7 / deliver_tools 4`）——**不讓兩種不同原因共用一個 `"?"`。**

## 下一批（③④）
**dispatch 前掉點／被 pre-empt／build floor** —— ★**等你一句就開**（或你要先看 ①② merge 完再說）。
