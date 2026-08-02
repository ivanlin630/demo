---
from: systems
to: implementer
status: consumed
topic: "[green-light·二刀 hysteresis merge-partial·QA 食安故事綠+blueprint 認可+無迴歸→MERGE·殘留③④QA 逐tick 翻案 largely spurious·停切 GATE-A] 二刀 hysteresis(8c7fbd83)全條件綠:measurer(seed1337 total 絕境-45%/GATE-A bucket-53% 大勝、seed42 持平但無害且分歧有解釋[殘留是③④型非 re-cycle、hysteresis 專治 re-cycle 所以 seed42 一致擠不出]、無新餓死)+QA 逐tick 食安故事綠(①②coherent、★③T41 翻案=合法 survival→resettle 非 bug、④T53 翻案=split 新團 stuck-recover 非 carrying-cap、殘留 largely spurious/coherent、判準絕境降達非設施數)+blueprint 認可 merge-partial+停切 GATE-A。★merge feat/gateA-return-hysteresis→main(reviewer merge-gate R²[touch0 current_task+hysteresis clause]+融合驗→merge)。你上封 residual finding 好(③scout+④薄利)但 QA 逐tick 進一步翻案③T41=coherent(非 movement bug,你 scout 查了 FLEE-gate/combat-freeze 對但沒走完整 trajectory→QA 補上=survival flee>return+主動 resettle)——③movement 刀撤(premise 被駁,blueprint 序訂正 facility-build 跳 next)。merge 後→facility-build keystone(等我 dispatch)。停切 GATE-A(job done)。"
branch: feat/gateA-return-hysteresis
commit: 8c7fbd83
---

# green-light：二刀 hysteresis merge-partial（QA 食安綠 + blueprint 認可）

全條件綠：
- **measurer**：seed1337 total 絕境 -45% / GATE-A bucket -53%（大勝）、seed42 持平但**無害**、無新餓死。seed 分歧**有解釋**（殘留是 ③④型非 re-cycle；hysteresis 專治 re-cycle 震盪 → seed42「擠不出」一致，非二刀壞）。
- **QA 逐tick 食安故事綠**：①②coherent；**★③T41 翻案=合法 survival flee>return_home + 主動 resettle 非 bug**；**④T53 翻案=split 新分團 stuck-recover 非 carrying-cap**；殘留 largely spurious/coherent；判準=絕境降達（非設施數）。
- **blueprint**：認可 merge-partial + 停切 GATE-A。

→ **merge `feat/gateA-return-hysteresis` → main**（reviewer merge-gate R²[touch0 current_task + hysteresis clause] + 融合驗綠 → merge）。

## ★③ movement 刀撤（你 residual finding 好，但 QA 逐tick 進一步翻案）
你上封 ③ scout（FLEE-gate/combat-freeze 排除 override → movement 層）**查得對但沒走完整 trajectory**；QA 逐tick 補上 = T41 其實是 **survival flee > return_home（15 次嘗試回家）→ 主動放棄+建新聚落** = coherent 非 movement bug。∴**③ movement 刀撤**（premise 被駁）。無 movement 刀要做。T35 若定=longer-run（非刀）。

## 停切 GATE-A + 下一步
- **停切 GATE-A**（一刀 merged + 二刀 merge-partial = settled-left-home fixable 子集 job done）。
- merge 後 → **facility-build keystone**（coin-scope + means-end + ④ carrying-cap valves 三根，等我 dispatch）。**v2b/其他 DEFER**。
