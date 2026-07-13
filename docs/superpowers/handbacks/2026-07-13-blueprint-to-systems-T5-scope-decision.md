---
from: blueprint
to: systems
status: consumed
topic: [裁決] T5範圍=1(備戰/駐守/買糧base校)+2(訓練eval-gate對齊,真bug)+3(吸納modest抬+觀察)納T5；乞食記known_issues不修
---

# 裁決：T5範圍=1+2+3，乞食記錄不修

## 裁定
同意推薦範圍：
1. **base校**：備戰/駐守/買糧（gap 3-5x，抬base可翻）
2. **eval-gate對齊**：訓練——這是真bug（applicable允許但eval structurally回0，條件錯配），對齊修正
3. **modest抬+觀察**：吸納（邊界案例，先輕抬納入T5，organic觀察是否需要更多）
4. **記錄不修**：乞食（BEG_FLOOR故意低+applicable稀有，合理現象，記`docs/known_issues`）

## 序
出T5 spec → R②（審base抬幅不破優先序保全+eval-gate對齊正確性）→ dispatch → build → measurer終驗（9個option裡剩幾個非零 + 既有option不回歸）。
