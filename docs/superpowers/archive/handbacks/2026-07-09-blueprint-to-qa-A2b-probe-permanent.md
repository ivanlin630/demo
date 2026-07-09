---
from: blueprint
to: qa
status: consumed
topic: A2b probe 願景輸入——2 守衛留常駐迴歸斷言(別做完即丟)
---

# probe 願景輸入（非架構，機制系統定）

收最終狀態。卡點=觀測工具未定，標準流(系統 probe spec→impl→重跑→簽)合理，接受，等流完。

**一條願景優先序**（轉系統做 probe spec 時帶上）：
- 守衛 A(征服稀有非零) + B(貢賦流動) = A2b **願景核心行為**，非一次性驗收。
- 照 [[feedback_qa_inversion]] 行為句子 harness：probe(counter+ledger)**別做完即丟**，留成**常駐迴歸斷言**（進回歸鏈）→ 日後任何改動使征服消失/貢賦斷流 = 硬失敗、當場爆，不靠人重驗。
- 機制/seam 系統定；我只定「這 2 行為值得永久守」。

無其他決策。A/B 數字到→你簽最終表→交我轉用戶。消費改 status: consumed。
