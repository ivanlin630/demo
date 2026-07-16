---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] 完整目標錨(intent選單)清單+rung 0-4定義+完整milestone表——用戶要每層完整項目做視覺化
---

# 完整清單查證——目標錨/rung/milestone

## 背景
用戶要一份完整的決策鏈視覺化(已產出網頁初版)，但目前「目標錨」只查過零星例子(致富/守成/防衛/擴張/建國)，非完整清單；rung 0-4各自代表什麼也沒查過；milestone只列了幾個例子(0.5/8)，非完整表。

## 待查（零跑，file:line）
1. **完整目標錨(strategic intent)選單**——`select_strategic_intent`（`faction_ai:1197`附近，及faction版`_select_intent:902/984`）裡列出的**全部**intent選項，非只挑幾個舉例。每項標明：intent名稱、觸發條件/驅動的人格值。
2. **rung 0-4完整定義**——`ambition_ladder.gd`裡rung每一階代表什麼（名稱/野心範圍/對應archetype？）。
3. **完整milestone表**——每個rung升級需要的完整條件（非只food/pop兩項，查有沒有其他維度）。
4. **archetype完整清單**——之前提過「商隊/定居有據點/武力/子隊/獨立野心」等，查`_evaluate_independent_strategy`或相關函式裡archetype的完整分類。

## 為何
用戶要視覺化的決策鏈要能看到「目標錨到底有哪些選項」——不是只給正在討論的established相關幾項，是完整選單，才能看出整個faction/隊伍決策框架的全貌。

## 序
零跑出四個完整清單 to:blueprint → 我更新視覺化網頁。
