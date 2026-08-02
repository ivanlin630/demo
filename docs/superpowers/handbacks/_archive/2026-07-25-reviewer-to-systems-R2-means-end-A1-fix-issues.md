---
from: reviewer
to: systems
status: consumed
topic: "[R②異質框外審 ISSUES] means-end A1 forest founding 修——S4 build_F 藏著同款未修死路(我親驗，S4是我核准過的)，別再一次性漏修"
---

# R②判決：means-end A1 forest founding 修 — issues（用 Sonnet 代跑，明確 refute）

## 核心診斷 + 修法方向：確認 CLEAN
`_dispatch_builder` 複用對——generic over any leader_team、既有 mountain-bootstrap 案例已驗證同款 pattern、自帶重複派遣 guard。移除自己 in-place TASK_BUILD/TASK_MIGRATE 不算退化——**該路本來就是死路**（agent + 我都親驗：`start_build` 全專案僅 3 個 production caller：`begin_subteam_construction`/`TASK_CONSTRUCT` 分支、玩家指令、測試——沒有任何路徑讓普通隊 `current_task==TASK_BUILD` 走到 `start_build`），拿掉一個「argmax 選中但必炸」的假 candidate 是淨改善非砍真覆蓋。決定性/憲法無新風險。

## ★must-fix①（HIGH）：S4 build_F 藏著同款未修死路，spec 沒碰
我親自複驗（非只信 agent）：`goal_resolver.gd:171`（`_resolve_build_facility` unowned-track 自建 outpost）+ `:178`（build_F action，在自家 outpost 建設施）**兩處都發 `{"task":TeamData.TASK_BUILD,...}`**——同款死路。line 178 的 target 是 own_tile（隊不一定站在那，若隊真移動過去、真觸發 arrival，`_on_arrival`（`movement_system.gd:290`）比對表仍是 `[TASK_CONSTRUCT,TASK_UPGRADE,TASK_EXPAND]`——**沒有 TASK_BUILD**，一樣建不成。這是**我自己 S4 merge-gate 核准放行時漏掉的同根缺陷**——當時我驗過 `_resolve_build_facility` 遞迴鏈邏輯正確、TDD 對數，但沒往下追 `TASK_BUILD` 這個 to_task 字串在執行端到底有沒有 consumer（跟這次 A1 是同一個盲點）。★這正是 whole-system-first 紀律要抓的——如果這次只修 `_resolve_resource_prereq` 不順手把 `_resolve_build_facility` 的同款死路也修了/至少明確追蹤，下一輪 whole-measure 幾乎篤定會再挖出一個「A2」blocker，重演一次「候選贏了 argmax 但蓋不出東西」。

**要求**：這次一併修（用同一招：founding-type candidate 標 delegate+build_type，接 `_dispatch_builder`；build_F action candidate 若隊已在自家 outpost=真 in-place 建設施，非新建 outpost，語意不同——需要一個對應「原地升級/擴建自家設施」的執行路徑，可能是 `TASK_UPGRADE`/`TASK_EXPAND` 而非 `TASK_CONSTRUCT`，你判斷哪個既有 task 對應「在自家 outpost 蓋新設施」語意，別又派一個新 outpost 建造子隊去蓋設施）。若判斷這超出本輪範圍要延後，**至少在 spec 明文列成本輪已知、下一刀立刻接的 blocker**，不能讓它悄悄留到下次 measure 才意外撞見。

## must-fix②（MEDIUM）：TDD 深度不夠打中原始 bug 面
`headless_test.gd` 已有近似覆蓋（Infra Task6/8，直呼 `_dispatch_builder`→模擬抵達→驗 `begin_subteam_construction`）。若 spec §5②的「執行端硬驗」抄同款寫法（直接手構 `_dispatch_builder` 呼叫，繞過 `GoalResolver.frontier_candidates`→argmax 選中→`_dispatch_goal_delegate` 的 founding-type 判斷分支），**測試會綠，但完全沒驗到 A1 真正壞掉的那段管線**（candidate 生成正確 + 決策引擎真選中 + delegate dispatcher 真正確判斷 founding-type 走對路）——跟原本 A1 逃過 R②/TDD 是同一種「測了鄰居沒測本人」漏洞。

**要求**：TDD 明文要求從「隊有真 material 缺口的 goal_state」出發，呼 `GoalResolver.frontier_candidates` 拿到真 candidate，餵給真 `_dispatch_goal_delegate`（測 founding-type 判斷分支本身，非繞過它），才算真迴歸測。

## 次要（記錄，非阻擋）
- `_delegate_variant`（`goal_resolver.gd:121-125`）filter 只認 `task==TASK_BUILD/SETTLE`，**沒有「已是 delegate 候選就別再委派一次」的 guard**——founding candidate 若仍保留 `task==TASK_BUILD`（只加 build_type key），會被 `_delegate_variant` 再包一層變成委派的委派，多一個近乎重複的 rank 池 entry。非崩潰（兩者最終都走同一 `_dispatch_builder`），但плumbing 該講清楚——implementer 落地時請幫 `_delegate_variant` 加 `if self_cand.get("delegate",false): return {}` 早退。
- `_dispatch_builder` 的 unowned-擋 只查 `construction_team_id!=-1`（`faction_ai_system.gd:2609-2611`），不查 `outpost_level>0`——若目的地在子隊在途中被別隊搶建，子隊撲空要等 10 天殭屍逾時才釋放（`faction_ai_system.gd:1721-1728` 既有機制）。這是 `_dispatch_builder` 既有行為（mining bootstrap 案例共用），非本刀新增，spec 講「自然擋」措辭可以更精確（有代價非零代價），不影響判決。

## 判決
**issues** → 回你修：must-fix①（build_F 同款死路，至少明文追蹤成立刻接的下一刀）+ must-fix②（TDD 打中真管線非抄近似測試）。次要兩點記錄供 implementer 落地時參考。修完再 R②。
