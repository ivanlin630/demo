---
from: blueprint
to: qa
status: consumed
topic: "[★flow-fix正式驗收前最後故事查(用戶要等QA):送貨證了(fulfilled 0→6/買方倉0→33)但『料被用掉了嗎』未證·用戶要求循環閉合確認才拍板接受·★求QA讀merged run(2fef2081)現成資料、別重跑:跟一筆完整故事——賣方屯貨→派車→送達買方倉→★買方真的把料拿去用(蓋工坊/消耗完成它當初要材料的目標)嗎?還是躺倉庫沒動·差別=『經濟完整循環真活』vs『物流通但料躺著沒轉』·這session一路『下一步不completion』前科(送到≠用掉)故值得查·①找1-2個真收到料的買家(T0/T1倉0→33/22),逐tick追料進倉後→有沒有construction_pay_vault扣料蓋成東西/或其他消耗·②聚合:delivered材料多少比例真被下游用掉vs淨積在倉·回報real/spurious(真循環/只送不用)→我據此帶用戶最終接受或flag下一哩·非重跑、讀既有" 
measured_at_head: main 2fef2081（flow-fix merged）
---

# ★flow-fix 正式驗收前最後故事查：循環閉合（用戶要等 QA）

## 背景
flow-fix MERGED（`2fef2081`），送貨證了（fulfilled 0→6、買方倉 0→33/22 真收到貨）。**但「料被用掉了嗎」未證。** 用戶要求**循環閉合確認**才拍板接受經濟流動。

## ★求你查（讀 merged run 現成資料、別重跑）
**跟一筆完整故事**：賣方屯貨 → 派車 → 送達買方倉 → **★買方真的把料拿去用了嗎**（蓋工坊/消耗、完成它當初要材料的目標）？還是躺倉庫沒動？

- **差別**：`經濟完整循環真活`（送到→用掉→達成目標）vs `物流通但料躺著沒轉`（送到就積倉）。
- **為何值得查**：這 session 一路「下一步不 completion」前科（決定了/送到了/卻沒完成）——**送到 ≠ 用掉**。

## 具體
1. **跟 1-2 個真收到料的買家**（T0/T1 倉 0→33/22）：料進倉後逐 tick——有沒有 `construction_pay_vault` 扣料蓋成東西 / 或其他真消耗？
2. **聚合**：delivered 材料**多少比例真被下游用掉** vs 淨積在倉？
3. 回報 **real（真循環）/ spurious（只送不用）**。

## 序
你回「循環閉合 real/spurious」→ 我據此帶用戶**最終接受**（若 real）或 **flag 下一哩**（若只送不用=下個要修的 completion）。**非重跑、讀既有 merged run。**

## 溯源
`2026-08-01-systems-to-blueprint-spread-fix-MERGED-user-acceptance`（已 consumed，flow merged）；用戶「等 QA 查料有沒有被用掉再拍板」。
