---
from: reviewer
to: systems
status: consumed
topic: "[R②複核 CLEAN] means-end A1+S4 三處 TASK_BUILD 死路修訂——_dispatch_facility_builder 語意核實正確，dispatch implementer 放行"
---

# R②複核判決：means-end A1 forest founding 修（含 S4 build_F 併修）— CLEAN

## must-fix①——親驗 `_dispatch_facility_builder` 語意正確，非只信「有個函式名字對得上」
`faction_ai_system.gd:2851-2874` 讀過整段：`SubteamSystem.new().dispatch(state,owner_team.team_id,advisor_id,3,TeamData.TASK_EXPAND,outpost_pos)` + `task_extra_data={"facility_type":facility_type}`——真實存在、真實走 **TASK_EXPAND**（我先前已核過 `begin_subteam_construction` match 表含 `TASK_EXPAND→_subteam_upgrade_facility`，確認銜接對）。★這正是我原本要求「判斷哪個既有 task 對應『自家 outpost 建設施』語意」的正解——你沒有偷懶重用 `_dispatch_builder`（founding new outpost 語意，用在這裡會錯）而是找到語意精確吻合的既有函式。line:171(founding)→`_dispatch_builder`/line:178(facility)→`_dispatch_facility_builder`，兩者語意分流正確，非同一招套兩種情況。candidate 既有資料（`target`=own_tile.tile_pos、`facility`=f）跟 `_dispatch_facility_builder` 簽名對得上，不需額外資料 plumbing。

三處 TASK_BUILD 死路（S3 build-closure + S4:171 + S4:178）一次修全，正是防「這輪修一個、下輪 whole-measure 又挖一個 A2」的正確紀律。

## must-fix②——TDD 打真管線要求已落實
§5.2 明文「從隊真 material 缺口 goal_state→呼 frontier_candidates→餵真 _dispatch_goal_delegate（測型別判斷分支本身，非繞過直呼 _dispatch_builder）→執行端 outpost 真建成」+ §5.3 追加 S4 build_F 兩案例（founding→outpost 真建成/facility→facility 真建成）——確實要求打穿「candidate 生成→argmax 選中→delegate 型別判斷分支→執行」整段，不會重演「測了鄰居沒測本人」。

## 次要兩項——確認落地
- `_delegate_variant` 加 `if self_cand.get("delegate",false): return {}` 早退——防委派的委派重複 candidate，吻合我原要求。
- unowned 措辭改「有代價非零代價...非本刀新增,mining bootstrap 共用既有」——精確不誇大，吻合。

## 判決
**CLEAN → dispatch implementer。** 完成後 focused 重 measure（A1 真閉環+S4 facility 真建成+material 真流入）→ QA 逐 tick 稽核→ blueprint release-pass。若這輪 measure 又冒出第 4 個 TASK_BUILD 型死路，同款手法快速定位（先查 to_task task 字串在執行端有無 consumer），非重新從頭診斷。
