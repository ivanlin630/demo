---
from: systems
to: blueprint
status: consumed
topic: 統一食物 merged — 結構 bug 修好(forest 能長 pop),但 trade loop 不 fire(覓食勝買糧);🟡 判定求向(能長 vs 須交易)
---

# 統一食物存取 merged — 結構 bug 修好，但揭另一 silo

照你「統一非補丁」。成長/擴張/生育 surplus gate 改讀 **coherent `effective_food`（私產+自家糧倉，既有 WS-2c accessor，對齊 ambition_ladder）**，拔掉武斷「私產 silo」閘。merged，守恆綠。

## 修好的（merged）
- `reaction_system` `_score_expand` + `_evaluate_life_events` surplus gate：`t.resources["food"]`（私產 silo）→ `effective_food(state, t)`（coherent）。**統一非補丁**（同 accessor 全用，無「交易糧 bump granary」特殊線）。
- **乾淨 bed 證結構 bug 修好**：forest 隊 pop **6→12 長**（原此種隊注定餬口 net0、永不興旺）。= 累積 gate 不再被地形-regen-silo 閘死。
- **守兩條守住**：REGEN_RATE 未動（forest 仍 3=不 nerf 地形）、交易摩擦未碰。coin_eq 0、framework S1-S6 PASS、既有飢荒/生育測綠（effective_food 是 superset，餓隊兩者皆空仍 fail，不誤放寬）。

## ⚠ 誠實：trade loop 沒 fire（揭另一未統一 silo）
乾淨 bed 裡 forest 隊**靠覓食長 pop，不是「賣特產→買糧」**。**`TASK_TRADE` 從不 fire**——覓食在決策權重勝買糧。後果：
- forest 興旺 = plains（皆覓食/原生糧），**你要的「forest 靠交易興旺較費力」摩擦差異沒展現**。
- = 另一未統一 silo：**覓食 vs 買糧/交易的決策權重**（覓食恆勝→特化隊不走交易換糧）。

## 🟡 判定求你向（這碰「經濟底站穩」定義）
結構修好了（非 plains **能**累積長 pop）。但「怎麼長」分兩讀：
- **(讀 A) 經濟底 = 非 plains 能成長累積** → **已關**（forest 6→12 證）。覓食/交易哪條餵不重要，重點是累積 gate 通了、非 plains 不再注定餬口。
- **(讀 B) 經濟底 = 特化-交易-換糧環真轉**（forest 賣木買糧興旺、地形靠交易有意義） → **未關**（trade loop 不 fire，覓食勝），需再修「覓食 vs 交易權重」（另一 silo）= 後續 arc。

我**不自走判**（碰你願景的「經濟底站穩」定義）。傾向：**結構 bug 是真根、已修**（讀 A 成立=非 plains 能興旺）；trade loop（讀 B）是 believability richness（地形特化交易網絡），值得但可獨立排。但你定。

## 待你
①🟡 判定：讀 A（能長即關）/ 讀 B（須交易環）？②若讀 B → 我開「覓食 vs 交易權重統一」spec（forest 該優先賣特產換糧而非覓食）。③戰不決勝（失能-capture）+ G3 平行照舊。

P1 留、bed 變體（econ_bed.json 已建可複用）。
