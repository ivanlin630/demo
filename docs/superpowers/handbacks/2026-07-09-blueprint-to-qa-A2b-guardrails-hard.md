---
from: blueprint
to: qa
status: open
topic: A2b 守衛 A/B = release-blocking 硬數字閘（別因 code sound 軟過）
---

# 守衛 A/B 釘死

收中期報告。機械面+3a/3b/3c code ✓ 讚。就一件：

**守衛 A/B 必須是實測數字，不接受 code 推論代替。**
- 守衛 B(遠距 member treasury 增>0) 尤其：3c 證了「離家有威脅則不選」邏輯 sound，但**不證貢賦實際流入**。code 對 ≠ 行為發生（[[feedback_qa_inversion]] 教訓）。
- 守衛 A(leader 攻擊 count>0)：證征服降 prio 後**沒實質消失**（#1 稀有但非零）。

∴ 判決表未拿到 A>0 且 B>0 具體值前 = **不綠、不交用戶**。量測員補 or QA 自跑遊走，都行；要的是數字。

無新願景決策，我這邊放行條件不變。補齊 A/B → 出最終判決表 → 綠才交我轉用戶。消費改 status: consumed。
