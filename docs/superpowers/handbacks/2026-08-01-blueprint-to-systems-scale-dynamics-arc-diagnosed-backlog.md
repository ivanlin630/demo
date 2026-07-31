---
from: blueprint
to: systems
status: consumed
topic: "[勢力規模動態arc診斷DONE(QA現成資料坐實)+記backlog·別現在做別擋flow-fix·★診斷:世界塌全小(133隊全~2.9人無大團,rung≥2僅6隊)因『併小成大』根本沒運作·現跑的merge(322)是母隊自我回收臨時工子隊(Team40派Team61→完工併回,pop恢復原狀非變大)=錯的整併、對cross-lineage power consolidation零效果·★真正能併獨立小團進大隊的機制=join(投靠/併入),但dispatch 155→resolve僅24(85%半路蒸發)+accept僅46%=量小又卡·∴根=join dispatch→resolve瓶頸(85%蒸發)=同session『dispatch多completion少/決策fire卻不執行』家族(means-end/trade/founding/convoy同型)·★arc方向(backlog,logistics後):非build新整併,是de-patch join resolve瓶頸(measure-first查為何85%蒸發:gated?argmax輾?)+可能讓大團長得起來(rung卡)·記known_issues勢力規模動態·非緊急、flow-fix優先] 勢力規模動態arc診斷done記backlog:世界全小因『併小成大』沒運作——現跑的merge是自我回收臨時工(錯的整併),真正的join(併入)dispatch155→resolve24(85%蒸發)+accept46%=卡在resolve=同session執行完成家族。arc方向=de-patch join resolve瓶頸非build新整併。backlog、logistics後、不擋flow-fix。記known_issues。"
---

# 勢力規模動態 arc：診斷 DONE（記 backlog，別現在做）

## 診斷（QA 現成 run1 坐實，非重跑）
用戶願景「活世界有大有小」；現況塌全小（133 隊全 ~2.9 人、無大團、野心 rung≥2 僅 6 隊）。**根因坐實：**
- **現跑的 merge（322）是「母隊自我回收臨時工子隊」**（Team40 派 Team61→完工併回，pop 恢復原狀非變大）= **錯的整併**、對 cross-lineage power consolidation **零效果**。
- **真正能「併獨立小團進大隊」的機制 = join（投靠/併入）**——但 `dispatch 155 → resolve 僅 24`（**85% 半路蒸發**）+ accept 僅 46% = **量小又卡在 resolve**。
- **∴ 根 = join dispatch→resolve 瓶頸（85% 蒸發）= 同 session「dispatch 多 completion 少 / 決策 fire 卻不執行」家族**（means-end/trade/founding/convoy 同型 meta-theme）。

## arc 方向（backlog、logistics 後）
**非「build 新整併」**（機制在、是錯的那種在跑 + 對的那種卡住）——是：
1. **de-patch join resolve 瓶頸**：measure-first 查為何 155→24 的 85% 蒸發（gated？argmax 被輾？——同執行完成家族）。
2. **可能讓大團長得起來**（rung 卡在低、無團做大——待查是否同源或另議）。

## 記憶 / 分流
- **記 known_issues**：勢力規模動態——「併小成大」失效根=join resolve 瓶頸（非 merge，merge 是自我回收）；同執行完成家族。
- **backlog、非緊急、flow-fix 優先**。**別現在做、別 fork flow-fix determinism 驗。** logistics 收官後再撿。

## 溯源
`2026-08-01-qa-to-blueprint-why-consolidation-fails-verdict`（已 consumed，join 瓶頸坐實）；game-design 規模分布校正（`495bfdee`）；同 session 執行完成家族。
