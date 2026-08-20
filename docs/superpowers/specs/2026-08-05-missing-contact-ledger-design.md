# 失聯帳本 — 預期聯絡＝通例（所有派出單位一個系統）（WHAT / vision）

status: LOCKED（R① CLEAN 2026-08-05 + 1 整併義務已納：與既有 _evaluate_owner_contact 同原語處理）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-05
★LOCKED 未排程(backlog)。
溯源：用戶定 2026-08-05「不只求援——所有信使與子隊都應有同個系統,感知人怎麼太久沒消息」；資訊網補完批。

## ★核心原則（用戶定）：通例非特例
**所有派出單位共用一張「預期聯絡帳本」**——信使/斥候/商隊/賑濟隊/子隊/開墾隊…任何 detach 出去的單位；**加上遠方自家據點/村莊的定期音訊預期**（領主對「久沒消息的村」）= 同一系統。**禁各處散建特例**（信使一套、子隊一套 = 又是 3 旋鈕病）。

## 設計（WHAT）
1. **帳本**：母隊每派出一個單位（或對每個自家遠方 holding）記一筆 `預期回報時間`——依距離/任務**機械估**（估算是物理、非人格；允許公式）。
2. **逾時 → belief 標「失聯」**：純自我記憶推理（「我派過誰 + 過了多久」）——**零 god-view**（不知道對方真死活，只知道逾時）。
3. **反應 = 思考層人格決策**（★人格非死常數）：
   - 務實 → 再派 / 派 scout 去查（接既有 side-action 家族）。
   - 多疑 → 當作出事、防禦準備。
   - 重情（義氣高）→ 派人探救。
   - 冷酷/野心 → 註銷、當沒了。
   - 領主對久無音訊的村 → 派信使查（= 既有「派信使查」決策 = 本系統的反應端）。
4. **反應走既有機制**：再派 = herald side-dispatch；去查 = scout side-dispatch;不新建動詞（除非 diagnostic 證缺）。
5. **失聯單位真相**：死了就死了（不通知——沉默即資訊）；活著回來 → 帳本清、belief 更新。

## 界
- 帳本 = **自我記憶**（own dispatch log + elapsed），非世界狀態查詢。
- 預期時間 = 機械估（距離/任務）；**反應傾向 = 人格**（何時慌/派/放棄——**禁「逾時 X tick 必派」死常數**；逾時程度進 mini-util、人格秤）。
- scope：本批只做「帳本 + 失聯 belief + 接既有反應動詞」；「探救隊」等新動詞不在本批（若人格反應需要、flag 我）。

## 現況前提（★pending R①）
- **P1** 派出單位現況**無統一 tracking**：herald/scout 有 lifecycle taps（arc 內建）但**母隊側無預期回報帳**；subteam/convoy 各自機制、無失聯感知。
- **P2** 「派信使查」（scout side-dispatch）已 merged 活（35/40 fire）= 反應端既有。
- **P3** belief 系統可承載「失聯」標記（team_known/belief store 既有,加 flag 類型即可、非新 store）。

> R① verdict：CLEAN。P1 比 claim 更嚴重——**10+ 個獨立 timeout 常數散落**（FOUNDING/TRADE/STATION/SCOUT/FLEE/CONTACT/CONSTRUCT_TRANSIT/letter/envoy…全是**子單位側自我到期**、非母隊側帳本）＝統一標的清單。
## ★整併義務（R① 定、防第 4 散落點）
既有 **反方向失聯偵測**：`_evaluate_owner_contact` + `_trigger_defection_evaluation`（faction_ai:4651-4664）＝「**村發現領主久無音訊** → 叛離評估」，用同款原語（`BeliefSystem.best_estimate().last_tick` + `_DAYS` 門檻）。**R²/HOW 必須明確處理關係**：帳本應 **reuse 同款原語**（last_tick 推理）、雙方向（母→子、子→母）收斂同一套失聯感知——**否則新帳本自己就是第 4 個散落知識點**（正撞本 spec 要解的病）。note：該處 `_DAYS` 門檻＝死常數照妖鏡候選（同 DEFECT threshold、記 faction-balance 批、非本批）。

## 守
通例統一非特例／人格非死常數／零 god-view（自我記憶推理）／反應走既有 side-action／determinism。

## 量測（湧現式）
- 失聯事件 → 反應 fire（再派/派查）且**人格分化**（務實派查多、冷酷註銷多）。
- 領主對久無音訊村的查訪 fire。
- 無 god-view 洩漏（失聯 belief 不含對方真實狀態）。determinism。
