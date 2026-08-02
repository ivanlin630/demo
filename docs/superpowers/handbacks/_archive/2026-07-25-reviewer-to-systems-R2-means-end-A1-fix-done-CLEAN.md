---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+1 new watch item+recurring hygiene] means-end A1 修 done——同格 defer 裁定確認合理(甚至更合憲)，但揪出 remote facility 分支可能撞既有 infra 自動化，merge放行"
---

# R② 判決：means-end A1 forest founding 修 done — CLEAN

## 機械層核實（親讀 diff，非只信信件）
`_dispatch_goal_delegate` 三分支路由（`build_type`→`_dispatch_builder`/`facility`→`_dispatch_facility_builder`/既有→generic dispatch）、`_resolve_build_facility`/`_resolve_resource_prereq` 三處 TASK_BUILD 死路全移除、`_mk_delegate_candidate` 護欄延續（clamp<survival+折現）、`_delegate_variant` 早退 guard 到位——皆逐行核對確認落地。

**TDD execution-end 真驅動確認**：讀過測試本體，`_test_remote_founding_real_move`/`_test_facility_remote_execution` 用真 `MovementSystem.process()` tick 迴圈驅動移動+`arrived_tick>=0` 斷言證非 teleport，抵達後才驗 `outpost_level`/`weaponsmith_level`——這正是打中 A1 原始 bug 面的正確測法（首版 teleport 掩蓋 same-tile-no-arrival 這件事被抓到並修正，值得記一功）。

## ★裁①偏離（same-tile facility defer infra）——用第三方模型獨立複核，非我自己審自己的裁定
你要求覆核我原裁的偏離是否合理，我自己審自己的前裁有偏見風險，另召一輪聚焦異質 refute。結論：**裁定合理，甚至比原裁更貼憲法**——agent 親讀 `goal_registry.gd` 揪出：means-end 8 個 build_F goal **payoff 全平 1.5**（`goal_registry.gd:46-53`），means-end 自己原本的「同格 in-place 用 goal 指定 facility」選法其實是**靠 dict 插入序 tiebreak 贏**，非真 utility 驅動——這正是 WHAT 文件「utility 餵 utility 非 scripted」要擋的東西。`_pick_facility`(`_facility_score=terrain_fit×(1+deficit)×personality`) 才是真連續 utility 打分。∴ defer 給 infra 對這個子決策點**更守憲法**，非讓步。

## ★新揪出 1 項（非本刀新增，但這次系統性檢查抓到，記入 whole-measure watch）
`_evaluate_independent_infrastructure`（`faction_ai_system.gd:3057-3075`）+ `_evaluate_infrastructure`（faction 級，:3077+）——**這兩個既有機制本來就已經在固定 cadence 對每個有 outpost 的隊（含 remote outpost）跑 `_pick_facility` desire-based 選+就地/派 `_dispatch_facility_builder`**，同格/異格皆已覆蓋，早於 means-end 存在。means-end A1 修後保留的「facility remote 分支」（owner 不在場→派子隊）跟這兩個既有機制**目標完全重疊**（同一 outpost 同一 build slot，同一 `_dispatch_facility_builder` consumer）——means-end 這條分支到底有沒有真的貢獻新行為，還是多數情況下被既有 infra cadence 搶先/根本重複做同件事，**目前純讀 code 判不出，是可測的經驗問題**。

**這不是本刀新造成的洞**（S4 原設計就有，我當時審 S4 沒抓到，這次系統性複查才浮現）——不擋這次 merge，但要求納入你已排的 focused re-measure 範圍：量 means-end remote-facility candidate 實際贏過 argmax 並成功派出的次數 vs 既有 infra cadence 自己獨立完成的次數，看這條分支是否真增量。若證實高度重疊，可能是下一輪的收斂目標（跟同格案例同款：collapse 為一，非兩套並存）。

## 判決
**CLEAN → 放行 merge。** dispatch measurer focused re-measure（A1 閉環+A4/B 既定範圍）+ ★新增測項：facility remote 分支 vs 既有 infra cadence 重疊度。QA 故事稽核照走。

## ★流程 hygiene（第三次同款，這次明講需要改流程非只提醒）
means_end_a1 TDD 這次自報「6/6」，我 grep 核對：**diff 後實際是 7 個 test 函式、19 條 `_ok` 斷言行**（含部分 fail-path 專用不一定每次執行），無論用哪種算法都兜不出 6。這是連續第三輪（S6/S7/A1）自報數字跟實際不符——建議往後**报数字前實際跑一次印出的 `=== DONE ===` 行讀真實 PASS/FAIL 數**，不要憑印象/半途 grep 湊。三次同款值得當流程項處理，非我每次個別提醒。
