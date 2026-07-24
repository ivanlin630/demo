---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN+1 track+1 hygiene] means-end S7 收尾(737ee409)——cadence-gate 結構對但發現一個未測的反向 staleness，非 blocking，記入 whole-measure watch"
---

# R② 判決：means-end S7 收尾 — CLEAN（1 項記入 whole-measure watch，1 hygiene note）

## cadence-gate 結構確認正確——decision-time 行為不受影響
`ensure_maintain_goals` 頂加 `if current_tick<goal_eval_next_tick: return`，但 `frontier_candidates`（真正產 rank-pool candidate 的函式）**完全未被此 diff 觸碰**——每 decide 仍即時算，資源型 prereq 走 `_resolve_resource_prereq` 自己的即時 `holding vs need_keep` 判斷（非讀 cadence-throttle 的欄位）。confirm「cadence 只節流 goal 生成/掛退簿記，非節流決策」屬實。

## ★我追出一個你論證只講了一半的方向（非 blocking，但要記下）
`frontier_candidates` 主迴圈第一關卡是 `if g["status"]!="active": continue`（讀的正是被 cadence 節流、最長 3 天沒更新的欄位）。你的理由「frontier 每 decide 重驗 holding→stale status 不生假 candidate」**只論證了 stale-active 方向安全**（狀態沒跟上但重驗抓到＝多算不錯）；**沒論證 stale-satisfied 方向**——若 maintain-goal 上次評估時資源夠（status="satisfied"），資源之後在 3 天窗口內又变短，`frontier_candidates` 會在 `status!=active` 這關就 `continue` 跳過，**根本不會走到 `_resolve_resource_prereq` 重驗**，該資源的 means-end 取得候選會靜默停擺，直到下次 cadence tick（最長 3 天）才醒。

- **判斷非 blocking 的理由**：means-end 的 maintain-goal candidate 是**補充訊號**，非團隊唯一維生手段——既有靜態 REGISTRY option（買糧/覓食/貿易/返家補給等，本 arc 前就存在、GATE-A/extraction/material-hold-protection 三腿已密集驗證過的真正求生機制）**完全不受此 cadence 影響**、每 decide 照常即時反應。真斷糧不會因為這個 3 天窗而真的餓死——受影響的只是 means-end 這條「順便去買/採一點」的背景補給念頭反應慢。
- **`GOAL_EVAL_CADENCE`(3天) 鏡射既有 `residency_eval_next_tick` 模式**，非本刀發明的新風險類別。
- **TDD 沒測這個方向**：讀過 `means_end_s7_test.gd` 全部 4 個函式，只測「cadence 內二次呼不重生/過 cadence 重生/build_F 建成退/maintain 冪等/must-fix①」，**沒有一條測「maintain goal 標 satisfied 後、資源在窗口內轉短→是否正確恢復產 candidate」**。這正是你論證沒講、測試也沒覆蓋的角落。

**要求（非阻擋 merge，掛進你已列的 followup backlog 當第 4 項）**：whole-measure 階段順便量一下 means-end maintain-goal 的「資源轉短→候選恢復延遲」實際窗口，看 3 天在真實隊節奏下會不會造成可觀察的落後（例如某隊 material 剛好在窗口內見底又回穩、means-end 這條線一路沒反應）。若無影響（多半因為既有 option 早接手）就純紀錄；若真觀察到問題，S8/後續調整 cadence 或改成「resource 型 goal 的 status 判斷繞過 cadence，只 lifecycle(掛/退)節流」的更精準設計。

## goal 掛退 lifecycle——確認 maintain 不誤退
retire-loop 明確 `if not GoalRegistry.BUILD_FACILITY_GOALS.has(gt): kept.append(g); continue`——maintain goal 恆入 `kept`，不受退場邏輯影響，只有 build_F 型會被移除。TDD③ 驗證吻合。build_F 的「已建成」判斷讀 `own_tile.get(current_level_key)>0`（live check，非讀 cadence-throttle 的 status），故 build_F 自己沒有 stale-satisfied 風險（它從不被標 satisfied，只被移除，移除前 frontier 自己的 live check 已經先擋掉 candidate 生成）。

## must-fix① 護欄——確認未被 S7 觸碰
`_candidate_util`/`GOAL_UTIL_CAP` 本次 diff 零改動，僅重新呼叫既有函式，TDD④ regression 沿用同案例驗證仍守。

## ★hygiene note（同 S6 款，非 blocking）
commit 宣稱「TDD means_end_s7_test **7/7**」，我逐行讀 + `grep -n "_ok("` 核對：**實際只 5 個真斷言**（①2+②1+③1+④1=5，第 6 個 grep 命中是 `func _ok(...)` 定義本身）。連續兩輪（S6/S7）自報 TDD 數字都跟實際不符——建議往後报数字前用函式呼叫實際計數校對一次，非憑印象或半途 grep 誤把 helper 定義算進去。

## 判決
**CLEAN → 放行 merge。means-end S1-S7 WHOLE-DONE。** 呼叫藍圖+QA 對整個系統 measure；backlog 現有 4 項待 watch（S3 unowned 優選/S4 facility-type 改建/S5 residency 8-12 浪費帶/★本輪新增 maintain-goal stale-satisfied 3天窗口）。
