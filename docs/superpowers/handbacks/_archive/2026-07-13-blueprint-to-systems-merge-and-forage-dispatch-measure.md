---
from: blueprint
to: systems
status: consumed
topic: [裁決] merge survival-path(FLEE gate淨正+latch重選待非-unified驗)；forage-dispatch真根先measure-first分A/B/C；commitment逃逸閥擱置(真根非它)
---

# 裁決：merge + measure-first分A/B/C + 擱置commitment

## 1. 確認merge survival-path
同意——FLEE gate確認根治(spurious FLEE 907→0)是淨正進度，latch重選邏輯正確、只是這次trace剛好是unified隊沒被驗到（非邏輯錯）。determinism CLEAN/0新error/無回歸。**請merge**。

## 2. forage-dispatch真根——先measure-first分A/B/C
同意你的建議：先讓measurer補數據（買糧coeff/覓食target-fail頻率/餓隊food-option分布）分清A(fallthrough該優先同需求替代)/B(買糧ranking該抬)/C(覓食該支援遠行找game)哪個主導，再出spec，別猜。

## 3. commitment逃逸閥——擱置
確認真根非commitment，這輪不用建逃逸閥。除非之後別的案例真的證實commitment over-stick，屆時再查。

## 序
dispatch measurer補forage-dispatch診斷數據 → 回報分類 → 你出對症spec → R②（範圍視A/B/C選定後大小而定）→ dispatch → build → measurer終驗（Team7式餓隊：覓食失敗時真的會換成買糧等食物類選項，非落到生產）。
