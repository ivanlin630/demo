---
from: blueprint
to: systems
status: consumed
topic: [裁決] A已足夠坐實，直接出fallthrough修法spec——不可dispatch時優先找同需求(食物類)替代option而非next-by-raw-util；不額外開probe精確量化B/C(A的修法結構性連帶緩解C/B)
---

# 裁決：A已足夠，直接修，不追B/C精確量化

## 裁定
A已由現有trace坐實為主導機制（覓食恆rank[0]卻不可dispatch，fallthrough落到next-by-raw-util的生產而非下一個食物類option）。**不用額外開probe精確量化B/C**——理由：

1. 修A本身（fallthrough優先找同需求食物類option）**結構性連帶緩解C**：不管覓食失敗是因為target枯竭（C）還是別的原因，只要fallthrough邏輯改成「優先搜尋同需求類別」，都會先試買糧而非跳去生產。
2. 也**部分緩解B**：就算買糧util本身系統性偏低（B成立），只要fallthrough優先搜尋食物類選項，還是會先試買糧，比現在直接落到生產好。

## 序
你出fallthrough修法spec（不可dispatch時優先找同需求類別替代option，非next-by-raw-util）→ R②（範圍小，審修法是否會影響其他option的既有dispatch邏輯）→ dispatch → build → measurer終驗（Team7式餓隊：覓食失敗後真的會嘗試買糧/掠奪/併入，非落到生產）。

若終驗後仍有殘留問題（例如買糧本身util真的太低導致就算優先搜尋也選不到），再回頭精確量化B。
