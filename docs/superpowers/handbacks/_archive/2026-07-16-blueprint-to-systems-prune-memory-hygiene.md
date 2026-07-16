---
from: blueprint
to: systems
status: consumed
topic: "[請prune memory·用戶問垃圾]用戶問memory會不會積垃圾+自動清否。誠實:無自動GC,靠單寫者守紀律,現有stale(我flag過project_unification_matrix)。請系統(memory單寫者)趁記路線圖順手audit+prune:①合併重疊project_*memory(economy_arc/causal_spine/unification_matrix/combat_unification等多條重疊)②刪已完成arc的③更新stale。MEMORY.md每session載入,bloat燒context。project類最會stale(arc推進舊狀態過期);user/feedback/reference穩定保留"
---

# 請 prune memory（用戶問垃圾累積 + 自動清）

用戶問「memory 會不會積垃圾?Claude 自己清嗎?」——誠實答:**無自動 GC,靠你(單寫者)守 dedupe/prune 紀律,現有 stale**（我剛 flag `project_unification_matrix` stale）。**趁你記路線圖,順手做一次 memory 衛生。**

## 請 audit + prune（你單寫者地盤）
1. **合併重疊 project_* memory**：`project_economy_arc` / `project_causal_spine` / `project_unification_matrix` / `project_combat_unification` / `project_desperation_economy` / `project_established_chain` / `project_reverse_engineering_arc` 等**多條重疊/過期**——合併成少數 current-truth 條（統一路線圖那條可當經濟/架構主線）。
2. **刪已完成 arc 的**：merged 完、狀態已進 git/progress 的 project memory（副本無用,git 才是真值源）。
3. **更新 stale**：`project_unification_matrix`（stale）→ 併入新統一路線圖。

## 保留（別動）
- **user / feedback / reference 類**穩定,幾乎不 stale（禁韓文、台灣繁中、工作流偏好、量測協議…）——保留。
- prune 只針對 **project 類（arc 狀態,隨進度過期）**。

## 為何值得（成本）
- MEMORY.md **每 session 載入 → bloat 每次燒 context**。
- 過期 project memory 誤導（memory 規則本身警告「recalled memory 反映寫入當時,可能過期,file:line 要先驗」）。

## 紀律建議（給你單寫者，長期）
- project memory **原地更新**（一 arc 一條,別每次新開）。
- **arc 做完即刪/歸檔**（狀態進 git/progress 後 memory 副本無用）。

## 下一站
不擋 Arc 1 進度。你方便時 prune（記路線圖時順手）→ 回報清了哪些即可。
