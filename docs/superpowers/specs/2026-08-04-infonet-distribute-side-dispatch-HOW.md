# 資訊網 distribute side-dispatch — HOW spec（症1 雙端 side-action 對稱、完成）

**from**: systems | **status**: FINALIZED → reviewer R²（blueprint RATIFY） | **branch**: `feat/info-network-whole`（續）
**root（RE-measure #5 confirmed）**：de-scan 解候選生成（`distribute.candidate_eval 0→680`）**但 dispatch 仍 0**、T0 領主恆覓食＝**distribute 留主 argmax 跟覓食競爭輸**（同 herald/scout 移出主 argmax 前的「applicable 但輸主 argmax」signature、measure 坐實 candidate_eval=680+dispatch=0+T0 恆覓食）。
**WHAT 裁**：blueprint RATIFY——distribute=side-action 家族（領主下令派賑濟 convoy=directive、body 照覓食、「下令」思考層不佔身體、同求援對稱）。

## ★★side-action 類邊界正式化（blueprint 定、防 creep、寫進 spec）
- **side-dispatch = 「detach 子單位/物件、而母隊主 task 不變」的 directive 類**——現三型：**herald（求援）/ scout（偵察）/ distribute-convoy（賑濟）**。各自人格 mini-util。**主 argmax = 身體做什麼、零改動**。
- **★每新增 side-action 型需 blueprint sign-off**（防全部決策遷出 argmax、掏空主秤紀律）。
- **note（別動、非本批）**：trade deliver-convoy 仍在主 argmax；若日後量到同 signature（candidate 多 dispatch 0）=同家族候選、先量再議。

## 修（distribute 脫主 argmax → 平行 side-dispatch）
1. **移除主 argmax**：`goal_resolver frontier_candidates:117` **刪 `out.append_array(_distribute_candidates(...))`**（distribute 不再進 rank_scored 主池）→ 主決策 winner 不變（determinism-neutral、移 loser）。
2. **新 `_try_distribute_side`**（`faction_ai`、side-dispatch pass、置 `_try_herald_side/_try_scout_side` 旁 `:1648-1649`）：每 team（**faction 領主**）：
   - **reuse `_distribute_candidates`** 算最佳賑濟候選（已 de-scan：belief received_buy_orders + 人格 relief、零 god-view、零死常數）。
   - **mini-util = 該候選 util（relief_term 仁慈/責任 × need_signal + coin_term greed）**——**> 0** 且 **not throttled**（無 in-flight distribute convoy）→ **`_dispatch_convoy(state, lord, to_task)`**（reuse `:3311`、kind="distribute"）。
   - **throttle**：一領主一 in-flight distribute convoy（鏡射既有 convoy throttle、`task_extra_data.convoy_phase` kind=distribute 在則不重派）。
3. **mini-util 人格非死常數**：仁慈/責任感（relief honor）+ greed（coin）vs convoy 成本（送 convoy 的 pop/機會成本）；連續 weigh、無門檻閘。

## 完成症1 雙端對稱
`resident 求援（side ✓）→ letter → 領主聞 team_known → 領主賑濟（side、本 fix）→ convoy → 糧真到 resident`。

## 守（reviewer R²）
- **★主 argmax 零改動**：移 `_distribute_candidates` 出 frontier → 主決策 winner 不變（determinism byte-identical、除 relief convoy 世界效果）。confirm 移 loser 中性。
- **genuine 非 crank**：mini-util=既有 de-scanned distribute util（belief relief + 人格）、**一字不改只換觸發路徑**（主 argmax → side-dispatch）。非藉機 crank。
- **scope 硬限（side-action 邊界）**：只 herald/scout/distribute 三型明列、**非泛化 side-task 框架**；distribute=第三型已 blueprint sign-off。
- **de-patch 非增殖**：distribute 從「假裝主 argmax option」→ 還原真實 directive side-action（同 herald/scout 家族正解）、非新平行求解器。
- **determinism 零新 randf** + **economy 不爆**（food_surplus 守 reserve 不變、convoy 空手邏輯既有）。

## 驗收（re-measure 症1 端到端 on FACTION bed）
- **`distribute.dispatch / food_delivered > 0`**（領主現平行派賑濟 convoy、不再輸主 argmax）。
- **★糧真到 resident runway 回升**（端到端真效果、[[feedback_verify_execution_end]]、症1 首次閉環）。
- 人格分化（仁慈/責任高領主救子民）+ 主 argmax determinism + letter delivered/scout/Part1+3 不退 + economy 不爆 + 不凍。

**路 reviewer R²（審 主argmax零改/mini-util genuine既有util只換路徑/side-action邊界scope硬限三型/de-patch非增殖/determinism）→ CLEAN → build → re-measure 症1 端到端（糧真到 resident）→ QA 故事稽核（回溯三因果+whole、verdict ref）→ blueprint 推用戶驗收。**
