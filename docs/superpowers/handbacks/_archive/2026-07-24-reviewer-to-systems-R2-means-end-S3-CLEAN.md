---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN+1 track] means-end S3 定位型(135a2e3f+660a9506 REDO)——must-fix②親驗守住+unowned edge case 追蹤，merge 放行→dispatch S4"
---

# R② 判決：means-end S3 定位型 + build-closure — CLEAN

讀完兩個 commit（base `135a2e3f` + REDO `660a9506`，非只信摘要），逐行核心臟部位：

## ★must-fix②——親讀兩個 resolver 函式本體，非只信註解
- `find_nearest_terrain_tile`（goal_resolver.gd）：`for tid in state.world.tiles` 全圖迭代，**只比對 `t.terrain`**，全函式無任何 `outpost_owner`/`outpost_level` 讀取——確認是純靜態地形查詢，`# gate-ok` 標註屬實非裝飾。✓
- `find_nearest_known_tile`：`for tid in known`（`state.team_tile_known[team_id]`），**不碰 `state.world.tiles` 做迭代**（只用已知 tid 查物件）——真 belief-scoped。✓
- `_resolve_location_prereq` 分流：`if need_control: find_nearest_known_tile(...) else: find_nearest_terrain_tile(...)`——精準對應我 must-fix② 要求的「control 走 belief / 純地形走 gate-ok」分野，非含混。✓
- `_harvest_tile_known`：兩源皆 bounded——vision-radius 迴圈（`VisionSystem.VISION_RADIUS=3`，我核實真常數）+ relay `team_known` 訊息（`_msg_market_pos` 我核實真既有函式，非杜撰）。零 randf。✓

**must-fix② 真正守住，非只是文件寫辭漂亮**。

## ★build-closure（REDO）——親算 TASK_BUILD 語意
`{"task":TeamData.TASK_BUILD, "target":team.tile_pos}`——我對照既有 `options.gd:44-45`「建設」option 的 `to_task`，**完全同構**（in-place build 既有慣例，非新語意）。d=0 guard（`pos != team.tile_pos`）正確防自我 migrate。

## ★我自己追出一個邊界情境（非 blocking，但要記下）
`find_nearest_terrain_tile` 是純地形查詢，**不排除已被別隊佔有的 forest tile**（这在 `_resolve_resource_prereq` 的 material harvest-terrain 分支裡，非 `_resolve_location_prereq`）。若最近 forest 剛好被別隊佔（`outpost_level>0`）：隊會 migrate 過去、抵達後發現 occupied（build-closure 因 `outpost_level==0` 檢查不成立而不 fire）、REDO 的 d=0 guard 這時也會壓下重複 MIGRATE candidate（`pos==team.tile_pos`）——**淨結果=該 goal thread 這輪靜默無 candidate，非 churn/crash**，隊落回其他 static option 正常運作（跟本 arc 開始前的行為一致，非退化）。此邊界 systems 已在 REDO commit message 明講「真需 unowned 優選=S4 精修」——**確認有追蹤非漏**，接受本輪 whole-system-first 暫緩，S4/whole 後測真值時記得撿。

## 其餘
- unowned 過濾（既有 start_build「目標格已有據點」自然擋失敗 attempt）：合理，非本刀責。
- label 有界（`PREREQ_LOCATION`/`PREREQ_FACILITY`）：吻合。
- util 護欄沿用 S2（`_candidate_util` 未改動，我 S2 已驗證過數學）。
- TDD 10/10（base 7+REDO 補 3，我數過測試函式數對上）；determinism/gate 數字合理。

## 判決
**CLEAN → 放行 merge → dispatch S4**（設施發展 goal-set+設施/人力型前置）。★追蹤項（unowned forest 優選）非本輪擋點，記進你的 S4/whole-measure 待辦，別漏。
