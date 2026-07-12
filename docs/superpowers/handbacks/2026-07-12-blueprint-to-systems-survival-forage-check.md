---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] 查現有「求生覓食」邏輯——是否已有絕境優先權/不被其他task搶，或跟一般覓食同樣task-gated競爭；判斷苟活地板是否重複建設
---

# 現有「求生覓食」機制查證（被動苟活地板前置確認）

## 背景
急性崩真根已查（`2026-07-12-systems-to-blueprint-acute-crash-root.md`）：食物income需「主動生產/覓食task站在食物tile」才拿到，且此task須贏過移動/戰鬥/蓋東西等選項的argmax競爭，沒被選中=收入0。建議修法=「被動苟活地板」（站在可食tile自動拿保底口糧，不需贏task競爭）。

## 用戶問：這跟「求生覓食」有什麼不同？
用戶懷疑：系統是否**已經有**「餓到臨界時，自動優先去覓食/不會被其他task搶掉」這種絕境優先權機制？若有，苟活地板的效果可能已經部分存在，是重複建設；若沒有，才是真的缺口。

## 待查（零跑，file:line）
1. `_evaluate_survival:2974`（crude camp觸發點附近）——這條「survival」路徑具體在評估什麼？是否包含「優先覓食」的邏輯，還是只處理TASK_CAMP紮營判斷？
2. `_evaluate_solo` 提到的「覓食/貿易/紮營」（獨立隊策略選項）——覓食在這裡的argmax權重是否有隨飢餓程度動態提升（例如快餓死時覓食分數會不會被特別加權，讓它更容易贏過其他task）？還是固定權重、跟其他task平等競爭？
3. 有沒有任何「飢餓臨界」的hard override/priority interrupt（不管當下在做什麼，一旦資源低於某門檻就強制切去覓食）？grep關鍵字如 hunger/starv/critical/emergency 附近的task切換邏輯。

## 判讀請求
- 若已有動態加權/priority override機制，但月1-3仍86-96%負flow——代表**現有機制存在但不夠力**（加權不夠高，或override門檻設太低太晚），修法方向= 調現有機制的力度/觸發點，非新增苟活地板。
- 若完全沒有此類機制（覓食純粹跟其他task平等competing，無論多餓都不會被優先選中）——才是真缺口，苟活地板/或至少「飢餓時覓食加權」是必要新增。

## 序
零跑出結論 to:blueprint → 我判是否需要苟活地板 vs 調現有機制 → 待用戶最終裁決食物income語意。
