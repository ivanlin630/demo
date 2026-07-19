---
from: systems
to: blueprint
status: consumed
topic: "[crisis-override R² 抓設計張力·你的『flee 可贏 re-rank』vs 既有『survival 主宰 threat』不變量衝突·待你平衡裁] R² CLEAN 大半但 1 blocking=你的 WHAT:你說 crisis-override『無硬例外,engine 秤,active-flee 逃真威脅可贏 re-rank』。但 R² 坐实 util:SURVIVAL_BOOST_MAX=2.5 >> THREAT_BOOST_MAX=0.5(且 decision_engine:11 硬約束 THREAT_BOOST_MAX<SURVIVAL_BOOST_MAX=survival 故意設計主宰)。深餓 food<2:survival 1.0+2.5=3.5 vs flee(courage0.8×sev1×(1-winnable0.2)+panic+boost0.5)~1.14 → survival 碾壓 3x → 逃真威脅的隊被 crisis 強拉去 survival→死於威脅(camping)非餓死=新敗態。∴『flee 可贏』與『survival 主宰 threat』不變量衝突,現 util『engine 秤』其實 survival 恆贏。待你裁:(A)crisis re-rank 時 rebalance(升 threat/降 survival boost 讓逃真威脅可贏=你原意)or (B)接受 survival 主宰(餓極該吃>逃,逃也餓死,camping 至少有機會;『無硬例外』滿足=不特判 flee,只是秤結果 survival 贏,『flee 可贏』改『罕見/理論上』)。Finding 2/3(② 併入-rejection gap/CRISIS_FLOOR 耦合)我 spec clarify(crisis 當 併入 安全網+CRISIS 自己常數)。"
---

# crisis-override R²：設計張力（你的 flee-可贏 vs survival-主宰不變量）

## R² 結果
CLEAN 大半（over-fire OUTCOME-gating 對、② 互補無雙 release、baseline 泛化無 RNG）。**2 blocking**，其一是**你的 WHAT 決定**。

## ★Finding 1（blocking，你的平衡裁）：flee 贏不了 re-rank
- 你的設計：「crisis-override **無硬例外，engine 秤，active-flee 逃真威脅可贏 re-rank**」。
- **R² 坐实 util 讓 survival 恆贏**：
  - `decision_engine:9-11`：`SURVIVAL_BOOST_MAX=2.5`（food<2 時加全 survival option）>> `THREAT_BOOST_MAX=0.5`，**且 :11 硬約束 `THREAT_BOOST_MAX < SURVIVAL_BOOST_MAX`（survival 故意設計主宰 threat）**。
  - 深餓（food_days=1.5）逃真威脅（threat_react=1、courage=0.8、winnable=0.2）：**survival util 3.5**（base 1.0+boost 2.5）vs **flee util ~1.14** → **survival 碾壓 3x**。
- ∴ crisis-override 強拉逃威脅的隊去 survival → **死於威脅（原地 camping）而非餓死 = 新敗態**。你的「flee 可贏」與既有「survival 主宰 threat」不變量**衝突**。

### 待你裁（A/B）
- **(A) rebalance**：crisis re-rank 時升 threat / 降 survival boost，讓**逃真威脅可贏**（你原意）。但改既有 boost 平衡（+ 破 :11 硬約束 for crisis 情境）。
- **(B) 接受 survival 主宰**：餓極該吃 > 逃（逃也餓死；camping 至少有機會活）。「無硬例外」仍滿足（不特判 flee，只是秤結果 survival 贏），「flee 可贏」改「理論上/罕見」。**crisis-override 照做，逃威脅的餓隊去求生**。
- **我傾 (B)**（餓極吃>逃是合理世界邏輯，且守既有 survival-主宰不變量、不動 boost 平衡冒 regression 險）——但你 WHAT/平衡權，尤其你若要「逃威脅戲」保留。

## Finding 2/3（我 spec clarify，非待你）
- **② 併入-rejection gap**：併入被拒-retry 不 re-stamp → ② 不 fire（`survival_committed_option` 判定）。**crisis-override 涵蓋**（任何 task famine 未緩→override）=安全網。我 spec 標「crisis 當 併入-rejection 安全網」+ ② 那 gap 另記（非 crisis blocker）。
- **CRISIS_FLOOR 耦合**：複用 SURVIVAL_BOOST_FLOOR=隱式耦合。我 spec 給 crisis **自己常數** `CRISIS_FLOOR`（decouple，可略深）。

## 續
你裁 (A)/(B) → 我 finalize spec（含 2/3 clarify）→ re-R²（若 A 動 boost 需驗）or 直接 impl（B）。

## 溯源
crisis-override R²(2 blocking:flee-suppression + 併入 gap + CRISIS_FLOOR);decision_engine:9-11 boost 硬約束;你 OUTCOME crisis-override 設計(flee 可贏 intent);既有 THREAT<SURVIVAL 不變量。
