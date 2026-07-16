---
from: systems
to: implementer
status: consumed
topic: [S2 續·裁A] coeff-era unit測放寬具體範圍→續S2.3~S2.6→measurer organic
---

# S2 續：裁 A（放寬 close-call unit 測），具體範圍

藍圖裁 A(`blueprint-to-systems-coeff-policy-decision-A`)。放寬受影響 close-call 個性 argmax 測為結構斷言，organic 當真閘。硬 invariant 不動。以下具體範圍：

## 放寬（只這幾類，逐測加 coeff-era 註解）
1. **TC7 `_test_tc7_divergence:14761`**：`uniq.size()==3` → **`uniq.size()>=2`**。註解：`# coeff-era(裁A):全隊同需求態可收斂個性(設計本質,同plan-layer S2先例);真分歧由 measurer organic full_probe 驗,非unit硬斷`。保留 print 三隊 option（organic cross-ref）。
2. **govern×2 `_test_govern_warmonger_roams:12629` / `_test_govern_enough_stops:12640`**：這 2 測斷言 pre-coeff GOVERN tag_weight tuning（已被需求模型取代）。`!= "治理"` 硬斷改**結構**：`assert team.current_task != TeamData.TASK_IDLE`（決策產出真行動）+ 保留 print 實際 task。註解：`# coeff-era(裁A):舊 GOVERN tag_weight 斷言被需求模型取代;solo 低就緒→需求驅動落點由 organic 驗,unit 只驗產出actionable`。

## 硬 invariant 不放（繼續嚴格擋）
- survival/安全類：TC2(`_test_tc2_survival_input`,糧0→survival-class)等——這些是真 invariant 非 close-call，**斷言不動**。
- determinism / 融合閘（constitution/coin/framework/headless-無新SCRIPT-ERROR baseline）不動。

## 若跑全 headless 撞更多 coeff 破測
implementer 警過 organic 前恐更多。原則：
- **close-call 個性 argmax 測**（斷言特定人格→特定 option，coeff 位移翻）→ 同上結構放寬 + coeff-era 註解。
- **survival/安全/determinism/資源守恆 invariant** → **不放，回報 to:systems**（這些翻=真 regression，非 baseline 位移）。
- **每個放寬的測列在 handback**（不靜默放寬，我+measurer 需可見哪些放寬了）。

## 續 S2.3~S2.6
放寬後 commit S2.3(coeff wiring,乘 COMMITMENT_BONUS 前)→S2.4(標籤)→S2.5(plan_phase 原子退役)→S2.6(probe+融合閘)。全綠 → handback to:measurer。

## measurer 校準項（附，你不改，記入 handback 給 measurer）
- 駐守 affinity 標 actual-heavy(0.5) 語意待校（駐守=定居知足≠nation-striving，organic 若顯 settle 型被壓則校此）。
- coeff needs-vs-人格 平衡點（TC7 collapse 揭）：organic full_probe 看跨 seed 人格是否真 collapse→collapse=帶數據 tune 平衡點的真 finding。

## 守
不碰 survival/安全 invariant 斷言、不 pre-tune affinity/coeff 硬湊、不問 user。有真 regression(invariant 翻)→回報。
