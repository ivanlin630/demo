---
from: systems
to: reviewer
status: consumed
topic: "[R²·★★make-or-break·economy-decision headroom meta-fix(一根解全家trade/founding/convoy/construction)·spec=2026-07-31-economy-decision-headroom-metafix-HOW.md·blueprint裁(b)系統性de-patch·★親驗refined機制(別在錯前提設計):survival boost已food-scaled(decision_engine:75-76 fed無boost絕境才2.5)=survival-conditional大體已做,真binding=GOAL_UTIL_CAP=1.5(goal_resolver:16)無條件封頂economy goals(static option不受1.5cap可>1.5即使fed也贏不過)+distance倒扣+無可靠性·meta-fix真lever=①食物scaled goal-cap headroom(runway modulator:fed→cap升能競爭/starving→cap≤survival保must-fix①,survival boost也scaled雙保絕境)②distance discount不對own-supply倒扣③guaranteed-own-supply可靠性通用維度·heavy驗:隊仍survive不因economy餓死+不凍+全家fed真fire·make-or-break從嚴複驗①food-scaled cap真讓fed贏且絕境survival仍贏(must-fix①不破)] economy headroom meta-fix。親驗survival已food-scaled,真lever=food-scaled goal cap非再scale survival。從嚴審must-fix①不破+全家真fire+不凍。"
---

# R²（★★make-or-break）：economy-decision headroom meta-fix — 一根解全家

## spec
`docs/superpowers/specs/2026-07-31-economy-decision-headroom-metafix-HOW.md`。blueprint 裁 (b) 系統性 de-patch。

## ★親驗 refined 機制（別在錯前提設計，回應你上輪 make-or-break catch）
你上輪親驗 pull-convoy 結構輸 argmax——我進一步親驗**全貌**，refine：
- **survival boost 已 food-scaled**（`decision_engine:75-76`：`food_days<2.0` 才 boost、`∝(2.0−food_days)`、fed 無 boost）＝**survival-conditional 大體已做**（blueprint「無條件」前提 partly 已由此條件化）。
- **★真 binding = `GOAL_UTIL_CAP=1.5`（goal_resolver:16）無條件封頂 economy goals**：static option（覓食/govern，decision_engine:64-66 terms×coeff）**不受 1.5 cap**→可 >1.5→**即使 fed 隊 economy goal(≤1.5)也贏不過強 static option**。+ distance 倒扣 + 無可靠性。
- ∴ meta-fix 真 lever＝**食物 scaled goal-cap headroom + distance-fix + reliability**（非再 scale survival，已 scaled）。

## Fix（3 部分系統性、全家共用）
- **1a 食物 scaled goal-cap headroom**（核心）：`goal_cap = BASE + safety_factor(food/runway) × HEADROOM`。fed→cap 升（economy 競爭甚至贏 static）/ starving→cap≤survival（保 must-fix①，+ survival boost 也 scaled=雙保絕境）。runway sense=modulator。
- **1b** distance discount 不對 own-supply logistics 倒扣（遠 surplus 是價值非純成本、有界遞減不殺死）。
- **1c** guaranteed-own-supply 可靠性通用維度（own-supply≈1/uncertain<1，三案共用）。

## ★★reviewer focus（make-or-break 從嚴）
1. **★★食物 scaled goal-cap 真讓 fed economy 贏否**：fed 隊(food_days>2.0)goal_cap 升到 3.0 後，economy goal 真能贏強 static option（覓食 fed 無 boost）？**這條是本 fix 成敗**——別又是斷言，要能親算/驗 fed 隊 goal 真 > static。
2. **★★must-fix① 不破**：starving 隊 goal_cap 降回 <survival(2.5) + survival boost 滿 2.5 → 絕境 survival 仍 100% 奪 argmax（雙保）？headroom 會不會在中度飢餓(food_days 1-2)讓 goal 意外贏過 survival？親算中度飢餓區。
3. **1b distance-fix 邊界**：own-supply discount 降但仍有界（非取消）、不誤惠非-own-supply candidate？
4. **1c reliability 維度非 scripted**（連續 util-weigh、非硬類別閘）？own-supply=1/market/forage<1 的判定接得到真確定性訊號否？
5. **heavy 驗設計足否**（survive 不因 economy 餓死 + 不凍 + 全家 fed 真 fire execution-verified）？

## 判
CLEAN → implementer（food-scaled cap + distance-fix + reliability + heavy TDD）→ measurer（全家 fed 真 fire + starving 不餓死 + 不凍）→ QA。有洞（尤其 1 fed 真贏 / 2 must-fix① 破）→ 回 `to:systems`。**★這是 session 最高槓桿 fix、觸核心決策公式、唯一真 regression 風險等級=founding floor + must-fix① 護欄雙觸，R² 最嚴。** meta-fix 過 → convoy ②③④ plumbing 建其上（我並行備）。
