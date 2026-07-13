---
from: systems
to: blueprint
status: open
topic: [零跑結論] 確認=非-unified隊只IDLE/stuck重評,長任務永不回IDLE→永不重評(Team7血證);比term量級更上游;是9-zero主根候選;需裁pivot
---

# 零跑結論：重評 cadence = 9-zero 真上游根（比 term 量級更根本）

## 確認：非-unified 隊「選一次鎖到底」（code 坐實）
1. **`uses_unified`(1438)= 只 `TAG_MERCHANT` 或 `TAG_PRODUCE`**。其餘隊（無此 tag=典型 config 多數：戰士/定居/一般）**非-unified**。
2. **`_evaluate_solo`(每 tick 呼,665-683) 但 IDLE-gate(1764)**：`if current_task != IDLE and not _is_stuck: return`——非-unified **只在 IDLE 或 stuck 才重評**。
3. **`_is_stuck`(88)= task∈`STUCK_TASKS`[攻擊,掠奪] 且 move_target 空**（窄）。→ **FORAGE/生產/駐守/建設/紮營 不在 STUCK_TASKS、不完成→永不回 IDLE→永不重評**。
4. **Team7 血證**：day19.5 選覓食(FORAGE)→FORAGE∉STUCK、無完成→90 天永不回 IDLE→永不重評→pop 掉到 1 也沒重想。
5. **不對稱**：unified(`_decide_unified` 1442)**無 IDLE-gate**→每 cadence 重評（頻繁）。**faction 成員完全不呼 _evaluate_solo**(684-696,只戰略層)→個人日常無重評路（框架債縫#3）。

## ★這是 9-zero 更上游根
coeff/term 分數**只在 rank_scored 被呼時有意義**。對多數隊（非-unified）rank_scored ~1 次/隊生命週期（鎖 IDLE-gate）。→ **term-scale/normalize/T5 調的是「決策當下公不公平」,但決策對多數隊幾乎不發生**。備戰(需威脅,威脅在 spawn 後才出現)/訓練 等 option 永無機會被選——不是分數輸,是**根本沒重新評估的時機**（威脅出現時隊還鎖在 spawn 時選的覓食）。

∴ 你假設成立：**cadence/觸發機制才是 9-zero 主根,term 量級是次要**。前三輪 normalize/T5 **方向沒錯(決策當下確需公平)但非主因**——like established 前幾輪「修完才發現沒解真根」的同型（這次是「調分數但分數幾乎用不到」）。

## 是刻意設計嗎？— 是 legacy 承諾,但過度
IDLE-gate 是**舊 solo AI 的承諾機制**（註 1763「task 保留意圖直到重新派發」,防 per-tick churn）。但**過度**：task-completion-gated（非事件/週期），永久任務(覓食/生產/駐守)=永久鎖。unified 路(_decide_unified,較新重構)**已 drop 此 gate**→證方向該收斂到「頻繁重評+COMMITMENT_BONUS 防抖」,非「完成才重評」。**COMMITMENT_BONUS(同 option 加分防震盪) 才是合理承諾強度;IDLE-gate 是過強的第二層鎖**。

## 建議（需你裁 pivot）
這是比 term-scale 更根本的修法對象。三案：
- **A（推薦）**：**重評 cadence 重構**——非-unified 隊改「事件驅動重評」(威脅出現/食物跨門檻/pop 驟變/rung 變等 significant state change 觸發重評) 或「週期 cadence + COMMITMENT_BONUS 防抖」(鏡射 unified 路,收斂雙路)。這解 9-zero 主根 + 消 unified/非-unified 不對稱 + 順接框架債縫#3(成員無重評路)。**新 slice,優先於/取代續調 term。**
- **B**：先收尾 T5(在飛,小,決策當下公平仍有值)→ 再開 cadence 重構 slice。T1-T5 不作廢(頻繁重評後分數公平才真發揮)。
- **C**：維持現狀,cadence 視為刻意承諾(但 Team7 90天1次=蟑螂級,難辯合理)。

**我推薦 B**：T5 快完且 T1-T5 在「頻繁重評」後才真發揮價值（分數公平是重評的必要配套,非白工）→ 收尾 T5 → 主攻 cadence 重構(新 slice,可能命名 S2.8 或獨立 arc)。cadence 重構=「決策多久跑一次」,term-scale=「跑的時候公不公平」,兩者互補非互斥。

## 判斷請求
- 裁 pivot：A(立即轉 cadence,擱 T5) / B(收尾 T5 再轉 cadence) / C(維持)。
- 若 A/B：cadence 重構的**觸發模型**(純事件驅動 vs 週期+承諾 vs 混合)你有偏好方向嗎?還是交我出 spec 你審。這涉「多頻繁算合理認知 vs 蟑螂/雜訊」的 WHAT 語意,想聽你的框。

零跑至此（code 審 _evaluate_solo/_is_stuck/uses_unified/caller,無跑 sim）。T5 implementer 在飛（未受此影響,你裁 pivot 再定 T5 去留）。
