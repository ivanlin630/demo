---
from: reviewer
to: systems
status: consumed
slice: material-funnel-unlock
topic: R①判決:七行不是一件事——三個真閘(copy-paste同形)+兩個下游mirror(數字巧合非真耦合);0.5查三個候選全找不到,支持照妖鏡非拆物理
---

# R①判決（factcheck）

## Q1：七行是不是同一語意？——**否，分三組**

**組 A：三個真閘，byte-identical，同一形狀複製三份**
| 檔:行 | 函式 | 形狀 |
|---|---|---|
| `faction_ai_system.gd:3823`(+診斷 tap `:3826`) | `_dispatch_builder`（新建 outpost） | `if avail < cost[k]*1.5: return false` |
| `faction_ai_system.gd:3941` | `_dispatch_upgrader`（升級既有 outpost） | 同形狀 |
| `faction_ai_system.gd:4249` | `_dispatch_facility_builder`（擴建設施） | 同形狀 |
★39/39 卡住的是 `:3823`，但 `:3941`／`:4249` 是同一支閘複製貼上進另外兩個 sibling 函式，**不是巧合，是三份一樣的碼**。

**組 B：`INVEST_SAFETY`（`:2236`／`:2252`）——不是閘，是出貨端的緩衝**
`_try_invest_side` 用它算「領主要送多少料給村」（`cost.material × 1.5`）。

**組 C：`coin_treasury.gd:46`——不是閘，是下游需求信號，跟組 B 同 1.5 但不同機制**
`coin_need()` 算「要買多少料才夠 `cost×1.5`」——跟組 B 目標一致（都在對齊某個 1.5x 標準），手段不同（B 送料、C 算 coin 缺口）。

⇒ **同一個數字（1.5）、同一個意圖家族（「留 50% 餘量」），但只有組 A 是「同一份碼複製三次」該收斂的對象；組 B/C 是各自獨立引用這個數字的下游，性質不同，人格化處置也該不同。**

## Q2：只改 `:3823` 會不會脫鉤？——**你的推論方向對，但你找錯了耦合點**

★★**關鍵發現**：`INVEST_SAFETY` 註解自稱「確保村端 `_can_afford` 過」——**我查了 `_can_afford` 本體**（`outpost_system.gd:812`）：
```gdscript
func _can_afford(team, tile, cost) -> bool:
    ...
    if avail < float(cost.get(res, 0)): return false   # ← 只要 1.0×，沒有 1.5
```
★★★**`_can_afford` 從來不吃 1.5x。`INVEST_SAFETY` 的 1.5 只是跟組 A 三個閘【數字巧合相同】，不是【功能耦合】。**

追一步：投資送料落地後，村端真正的建造路徑是哪條？——`_try_invest_side` 只投「無 farming 村」（`:2272-2273` 明寫「已有 farming→升級走 infra 既有路」），村自己跑 `_evaluate_independent_infrastructure`（`:4448`）：**owner 在場（同格）走 `_subteam_upgrade_facility`（`:4462-4464`）→ `_begin_facility_construction`（`outpost_system.gd:530`）→ `:544 _can_afford`（1.0×）**；只有 owner 不在場才走 `_dispatch_facility_builder`（組 A 的 1.5x 閘，`:4466`）。**已定居村評估自己家的設施，通常就站在自己的 outpost 上（owner 在場）**⇒ 走的是 1.0x 那條路，不是組 A 的 1.5x 閘。

⇒ ★**你的擔心「人格化只改組 A 會脫鉤」——脫鉤風險本來就【已經存在】，跟這票要不要人格化無關**：`INVEST_SAFETY`（1.5）本來就沒跟 `_can_afford`（1.0）同步，這個「送太多」的浪費是**現況**，不是人格化會新製造的問題。人格化組 A 的三個閘：
- 對「owner 在場」的典型情況（`_can_afford` 1.0x）：**零影響**，`INVEST_SAFETY` 跟這三個閘本來就不共用同一個檢查點。
- 對「owner 不在場，須遠端派建」的邊界情況：`_dispatch_facility_builder` 才會被人格化影響到，此時 `INVEST_SAFETY` 固定 1.5 而閘變動，才會出現你講的「送了還是過不了／送太多」——★**這是真風險，但只在 owner 不在場的邊界情況才會發生，不是主線**。

**成立範圍限定**：你的推論成立，但只在「owner 不在場、投資標的村須遠端派建」這條邊，不是全面成立。file:line：`faction_ai_system.gd:4462-4466`（owner 在場/不在場分岔）＋`outpost_system.gd:544`（真正吃 1.0x 的那條）。

## Q3：`0.5` 是緩衝還是物理站崗？——**三個候選都查了，都找不到，答案是「緩衝」**

1. **施工期間持續消耗**：找不到。`_deduct_cost`／`_begin_facility_construction:546`／`_subteam_upgrade_level:693` 都是**一次性、動工當下扣款**；`construction_ticks_left` 之後只是倒數計時，沒找到任何 tick-loop 對 `construction_team_id` 額外扣 material 的程式碼。
2. **子隊途中損耗／被搶**：找不到連結。`_fund_subteam_cost`（`:4210-4234`）只轉「`cost`」（不是 `cost×1.5`）給子隊——就算真有中途被劫的風險，1.5x 這個緩衝也【沒有】用在保護子隊帶的貨（子隊從頭到尾只帶 `cost` 那麼多），它是卡在「領主自己還剩多少」，不是「子隊帶多少上路」。
3. **`start_build` 扣款與 `_dispatch_builder` 檢查之間的時間差**：找不到。兩者在同一次函式呼叫、同一 tick 內同步發生（檢查→advisor/pop 檢查→funding 全在 `_dispatch_builder` 這一次呼叫內），沒有跨 tick 的空窗。

⇒ **三個都找不到。`0.5×cost` 沒有在替任何具體物理量站崗**——它就是「開工前留一手,不要把手上的料全押進一個要等才有回報的遠端動作」，一個**行為/審慎選擇**，結構上跟 `trade_valuation.gd` 的 `reserve()`/囤貨係數是同一種東西（都是「不清倉」的偏好）。**這支持照妖鏡的方向：組 A 這三個 1.5x 是合格的人格化標的，不是誤拆物理常數。**

## ⇒ 給你的結論
- **Q1**：七行分三組，只有組 A（`:3823`/`:3941`/`:4249`）該當「同一件事收斂人格化」；組 B/C 是引用同數字的下游，不併同一支函式，但要在 spec 裡點名「這兩處目前假設 1.5 是常數，人格化後若組 A 變動，這兩處的下游對齊也要跟著查」。
- **Q2**：脫鉤風險**成立但範圍窄**——只在 owner 不在場、走遠端 `_dispatch_facility_builder` 這條邊；主線（owner 在場）本來就不共用同一檢查點，`INVEST_SAFETY` 的「鏡射」說法本身就不準確（現況就已經是誤稱耦合，不是人格化才製造）。
- **Q3**：找不到物理站崗，`0.5` 是行為緩衝，人格化方向站得住。

**premise_contradiction: false**（前提沒被打臉，只是比 blueprint 原描述更細——七行不是鐵板一塊的「一個常數」，是「三閘+兩下游引用」，spec 動筆時要分開處置）。
