---
from: blueprint
to: systems
status: consumed
topic: "[用戶裁乙·手統一 general=下個arc(執行持守統一)·A1供料defer(之後恢復要先診斷哪環慢,別盲加速率=用戶質疑對,under-diagnosed)·latch健康valid可考慮merge(construction-persistence真修,會folds進手統一general)·tap-fix續(observer-RNG)·★第一步用戶要先看資料:產『現有散持守/commitment機制』盤點清單當設計底稿→我再跟用戶brainstorm手統一general] 用戶裁乙:手統一general=下個arc,先看資料再brainstorm。★先做:產一份『現有散落的持守/commitment/anti-落跑機制』盤點清單當設計底稿。每筆列:①機制名②cover哪個落跑case③type(flat-bonus/timeout/priority-preempt-gate/latch/immunity-window/guard/…)④file:line⑤層(決策層rank偏置 vs 執行層task-arbitration)⑥扁平還是累積/情境感知。已知起頭(用戶2026-07-19筆記+本場):COMMITMENT_BONUS(COMMANDER/FOUND/SOLO全0.15 flat,faction_ai:886/1213 rank偏置)、各task timeout(SCOUT/FLEE/TRADE/STATION/FOUNDING距離縮放)、TaskArbiter priority層preempt(COMBAT100/SURVIVAL80/THREAT70/…)、crisis-override免疫窗(本場)、TaskArbiter.transition補guard(本場)、construction-commitment latch+resume(本場A1,5b166eb1)、subteam-idle-latch(known_issues待)。盤點目的=看這堆散機制的共同模型是什麼→收成一套統一『執行持守』(隊commit多tick動作→留守到完成或真更高優先危機,一致,取代散補丁)。★這是design底稿非spec,盤點完交我+用戶brainstorm手統一general設計(brainstorm→design→build,像means-end)。★序:①產盤點清單(你或派investigator)②tap-fix收尾(observer-RNG,照鐵律+查observability_gate為何沒攔)③A1供料/build clean重量=defer到手統一general後(且先診斷哪環)④latch valid,merge與否等手統一general設計看它怎麼folds進去再定(別急merge一個即將被統一取代的點修)。material PARK。用戶要先看盤點資料。"
---

# 用戶裁乙：手統一 general = 下個 arc（先看資料再 brainstorm）

## 定案
- **用戶裁乙**：手統一 general（執行持守統一）= 下個 arc。
- **A1 供料 defer**：之後恢復要**先診斷哪一環慢**（不在料地形/無據點/採率/買太慢/採到又賣掉），**別盲加速率**（用戶質疑對，我原甲 under-diagnosed）。
- **latch 健康 valid**：construction-persistence 真修，**會 folds 進手統一 general**——merge 與否等設計看它怎麼併再定（別急 merge 一個即將被統一取代的點修）。
- **tap-fix 續**（observer-RNG，照鐵律 + 查 observability_gate 為何沒攔）。

## ★第一步（用戶要先看資料）：產「現有散持守機制」盤點清單
當設計底稿。每筆列：
1. 機制名
2. cover 哪個落跑 case
3. type（flat-bonus / timeout / priority-preempt-gate / latch / immunity-window / guard / …）
4. `file:line`
5. 層（決策層 rank 偏置 vs 執行層 task-arbitration）
6. 扁平 vs 累積/情境感知

**已知起頭**（用戶 2026-07-19 筆記 + 本場）：
- `COMMITMENT_BONUS`（COMMANDER/FOUND/SOLO 全 0.15 flat，`faction_ai:886/1213` rank 偏置）
- 各 task **timeout**（SCOUT/FLEE/TRADE/STATION/FOUNDING，距離縮放）
- **TaskArbiter priority 層 preempt**（COMBAT100/SURVIVAL80/THREAT70/…）
- **crisis-override 免疫窗**（本場）
- **TaskArbiter.transition 補 guard**（本場）
- **construction-commitment latch + resume**（本場 A1，5b166eb1）
- **subteam-idle-latch**（known_issues 待）

## 盤點目的
看這堆散機制的**共同模型**是什麼 → 收成一套統一「執行持守」（隊 commit 多 tick 動作 → 留守到完成或真更高優先危機，一致，取代散補丁）。

## 序
1. **產盤點清單**（你或派 investigator）→ 交我 + 用戶 brainstorm 手統一 general 設計（brainstorm→design→build，像 means-end）。
2. tap-fix 收尾。
3. A1 供料/build clean 重量 = defer 到手統一 general 後（且先診斷哪環）。
4. latch merge 與否 = 等手統一設計定。
- material PARK。

## 溯源
用戶「偏乙 + 先看資料」+「前面落跑怎處理」；連 [[project_unification_matrix]]、[[project_hand_obeys_brain_arc]]、`docs/notes/2026-07-19-long-range-planning-brainstorm.md`（commitment 現況起頭）。
