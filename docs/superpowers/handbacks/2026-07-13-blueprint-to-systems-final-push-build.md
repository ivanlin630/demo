---
from: blueprint
to: systems
status: open
topic: [★直接動工,不再量測到完成] 決策生命週期統一最後兩塊——②分流收斂(尤其faction成員無個人決策路)+⑦釋放統一(4套獨立重評判斷收成一套)。做完再一次量測，中途不要再送量測報告
---

# 最後兩塊，直接做完，不要中途量測

## 用戶明確指示
模型還沒好之前，量測都是浪費時間。**不要再送中途驗收報告給我，做完兩塊再一次量測**。

## 要做的（守門員全圖已盤點清楚，直接出spec+build，不用再等我逐項裁決）
1. **②分流收斂**：unified(_decide_unified)/solo(_evaluate_solo)/subteam(_evaluate_subteam)/faction成員 四條各自獨立的「選行動」路徑，收斂到單一決策路。**優先處理faction成員完全沒有個人日常決策路**這個缺口（`faction_id!=-1`成員目前只有`_evaluate_independent_strategy`戰略層，日常行動完全沒有決策，這是最大的洞）。
2. **⑦釋放統一**：survival release(food-recovery hysteresis)/threat release(no-threat+FLEE_TIMEOUT)/stuck release(_is_stuck)/timeout latch 四套獨立的「何時該重新想」判斷，收斂到「重評cadence+crisis-bypass」統一框架（cadence rework已起頭，這次要把threat/stuck/timeout也收進來）。

## 不用再問我的部分
守門員全圖裡的分類我已經同意你的建議（⑤TaskArbiter priority tiers保留刻意例外、①LOD/cadence節流保留、null/leader guard保留）。灰區（③urgency重疊gate/⑨commitment逃逸閥/⑩豁免）**這次不用處理，維持現狀**，先把②⑦這兩塊真正的N-瞎子核心做完。

## 序
你直接走完整流程（出spec→R①→R②→implementer build→定案）**不要中途回報進度給我**，除非遇到需要WHAT層裁決的真正岔路（例如發現premise矛盾、或範圍評估後發現遠超預期需要重新確認scope）才回報。做完兩塊、determinism驗完、無回歸後，**一次性**給我：①代表隊完整trace（沿用Team7手法）②established是否終於>0 ③這次改動的完整清單。
