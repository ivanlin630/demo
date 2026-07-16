---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] 決策生命週期完整守門員盤點——除了dispatch fallthrough/cadence gate/survival插隊/commitment,還有沒有其他獨立守門員在rank_scored外圍決定「觸發/執行/覆蓋」，全部列出再裁哪些收進統一框架、哪些保留刻意例外
---

# 決策生命週期完整守門員盤點

## 背景
用戶已定案要做「決策生命週期完整統一」（非只算分數那一步）——這是既定方向的延伸,非新決策。目前已知rank_scored外圍有這些各自獨立的守門員：
1. dispatch fallthrough（rank[0]找不到目標時怎麼retry，目前不分需求類別，spec在飛）
2. cadence gate（決定要不要呼叫rank_scored，已修）
3. survival-latch/PRIO_SURVIVAL插隊（決定要不要繞過rank_scored走別條路，已修）
4. COMMITMENT_BONUS（決定要不要覆蓋這次算出來的分數，繼續用上次選的，仍存在未動）

用戶質疑：算分數那一步統一了，但「觸發/執行/覆蓋」這條完整生命週期還是分散在好幾套獨立機制，等於N個瞎子問題換位置藏起來，沒有真的解決。

## 待查（零跑，窮盡列出）
1. **除了上述4個，還有沒有其他獨立守門員**在rank_scored呼叫前後決定「這次決策算不算數/要不要被聽/要不要被換掉」？窮盡搜尋（grep決策相關的early-return/override/bypass pattern，比照之前查rank_scored/rank_survival/rank_threat/rank_ambient呼叫關係的方法）。
2. 每個守門員的**觸發條件+效果**，file:line坐實。
3. 初步分類建議（你的專業判斷，非定案）：
   - 哪些**該收進統一框架**（例如dispatch fallthrough該吃需求急迫度，不該是獨立raw-util邏輯）
   - 哪些**該保留刻意例外**（例如威脅插隊本來就該是快速反射，不該被拖進慢速統一評分流程——這是設計上合理的分層，非需要解決的病）

## 為何窮盡列出再裁
避免像dispatch fallthrough那樣，修好一個守門員又撞到下一個沒發現的——先摸清全貌，再決定收斂範圍，比逐一撞見再救火有效率。

## 序
零跑列出完整守門員清單+初步分類建議 to:blueprint → 我裁哪些收進統一框架、哪些保留例外 → 你出正式spec → R①(premise)→R②(dispatch前)→build。
