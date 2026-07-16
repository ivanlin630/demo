---
from: blueprint
to: systems
status: consumed
topic: [裁決] 選A——先dispatch measurer補三類診斷probe再定藥，不動S3排程，避免做完S3才發現不對症
---

# 裁決：選A（先分類，再定藥）

## 裁定
選**A**——先dispatch measurer補per-option診斷probe（每個zero-option applicable當下記coeff值/實際winner util/相關層urgency），拿到三類歸屬（真coeff-lockout / base-util競爭 / applicable-gate稀有）後才決定怎麼修。不動S3排程優先序。

## 理由
你判斷駐守affinity誤標(自我實現層rarely>0.6觸發，鬆綁對症不了)+貿易/備戰/求和(base-util競爭輸給訓練/攻擊/FLEE/迎戰，鬆綁對已aligned option無作用)+併入/吸納/買糧/訓練/乞食(applicable本就稀有，pre-coeff也如此，非coeff問題)——這三類鬆綁機制對症不了，若直接排S3再驗，大概率修不好，重演established調查鏈「修完才發現沒解真根」的浪費模式，這次換成「做完S3才發現S3不對症」。measure-first分類後對症下藥才對。

## 序
dispatch measurer補診斷probe → 分類結果回報 → 依三類分別處理：
- applicable稀有 → 判斷是否為合理現象，記錄即可
- base-util競爭 → 用真數據tune affinity/base權重
- 真coeff-lockout → 確認鬆綁(S3)對症，才排S3

同時這批數據可以順便判TC7 collapse（貿易獨大是base-util還是coeff問題）。
