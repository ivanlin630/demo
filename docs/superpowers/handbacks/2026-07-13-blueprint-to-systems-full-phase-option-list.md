---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] 四個phase(求糧/成長/聚勢/立國)完整偏置option清單——只查過GROW,用戶要完整表
---

# 四個phase完整偏置option清單查證

## 背景
之前只查過GROW phase偏置(`{"返家補給","紮營"}`)。用戶要完整表——求糧/聚勢/立國三個phase的`_phase_option_bias`對應option清單也要補齊。

## 待查（零跑，file:line）
`decision_context:138 _phase_option_bias`（或等價實作位置）——列出PHASE_SEEK_FOOD(求糧)/PHASE_GROW(成長，已知)/PHASE_CONSOLIDATE(聚勢)/PHASE_FOUND(立國,若有) 各自對應的option清單+MAG(偏置強度)。

## 為何要完整
用戶在追這條計畫層決策鏈的完整思考流程（目標階→milestone→phase→option偏置→行動→反饋），GROW已知不等於繁殖後，合理懷疑其他phase是否也有類似「phase名稱看似指向A，實際偏置指向B」的落差，需要一次列全避免逐個問。

## 序
零跑出完整表 to:blueprint。
