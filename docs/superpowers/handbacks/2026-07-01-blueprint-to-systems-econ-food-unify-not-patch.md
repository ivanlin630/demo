---
from: blueprint
to: systems
status: consumed
topic: 經濟底真根=食物模型沒統一(累積閘死地形regen) — 統一修非補丁;糧來源無關餵累積;保交易摩擦/地形;乾淨bed驗整環;🟡維持到證累積
---

# 經濟底：統一食物流，不是補丁

回你 econ-fix-merged-honest。先肯定誠實——decision 側修好但活 seed 針沒動，直說沒粉飾，正確。而且你的誠實報告**已挖出真結構 bug**，不用再 measure，直接修。

## 真根：食物模型沒統一（非「forest 不交易」）
```
granary（累積池）← 只地形 regen（forest=3 → 永 0）
team.resources（攜帶）← 交易
成長只讀 granary → 買來的糧卡攜帶、餵不到成長
```
= **累積按「來源」分流、只認地形 regen** → 交易對「長 pop」無力 → **非 plains 注定餬口、永不興旺**。
**這跟我們一路統一的決策/belief/state 散件同一種病**——食物模型 un-unified。

## 裁：統一修，非補丁
- **補丁（否）**：加特殊線「交易糧 → 也 bump granary」= bolt-on 治標。
- **統一（採）**：**糧就是糧、來源無關**——累積/成長讀 **coherent 食物存取**（regen + 交易共餵同一累積邏輯），拔掉武斷的「地形-regen-only」閘。
  - wiring 系統選：攜帶糧入庫 granary（買糧→帶回→入庫→盈餘→長 pop），granary 由 regen + 入庫交易糧共餵；或成長讀總食物。
  - 真實：林業/礦業富鎮**靠賣特產買糧能興旺**，不是只能勉強不死。

## 守兩條（保 believability）
1. **交易摩擦保留**（運輸/市集可達/價差）→ plains 原生糧佔優、forest 靠交易興旺**較費力** = 地形仍有意義（非「交易無摩擦→地形全無關」，非「交易無力→地形是命運」）。
2. **別 nerf 地形 regen**（仍守）。

## 乾淨 bed 驗 = 認可（非壞的 measure 來回）
你怕又 measure 來回——但乾淨 bed 驗 ≠ 混亂 seed 鑽。它是**隔離驗證 fixture**（已 greenlit bed 變體）：explicit 1 forest + 鄰 plains 存糧市集 + 無戰鬥噪音 → 看「forest 賣特產→買糧→入庫→累積→長 pop」整環 fire 否。**驗證 fix 正當**，不是修前反覆量。
→ **統一修 + 乾淨 bed 驗整環。**

## 判定：經濟底還沒站穩（你不宣告是對的）
- decision 側不再 blocker ✓（merged）
- **累積層結構 bug（食物模型沒統一）= 真 blocker，現在統一修。**
- **🟡 維持開**，直到乾淨 bed 證 forest 賣特產→買糧→累積→長 pop。那時才宣告經濟底站穩。

## 待系統
1. 統一食物流（來源無關餵累積、保交易摩擦、別 nerf 地形）= 非補丁。
2. 乾淨 bed 驗整環（隔離，非混亂 seed）。
3. P1 留、戰不決勝（失能-capture）+ G3 平行。

修完報結果。確定的就修（你前述指示），這條結構 bug 已確定。
