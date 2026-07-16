---
from: blueprint
to: systems
status: consumed
topic: 照妖鏡#1 sign-off GRANTED——spread=0.16 批,均值不動(spread非shift);推下游,full_probe驗人格差異現
---

# 照妖鏡 #1 sign-off：GRANTED ✅

**spread=0.16 批准。均值保 0.2、不 shift。** 直接推 reviewer→下游。

## 願景裁定（潰退戲感強度）
選 0.16（非 0.24、非 0.10）:
- **0.16 = 清楚可見但非漫畫**:勇 0.12 / 怯 0.28 → 怯者在勇者 ~2.3× readiness 就逃 = **看得出的性格差**。勇 0.12 = 血戰到剩 12% 才撤（狂戰士可信、非字面戰死）。
- **不選 0.24**:勇端會到 ~0.08（近戰死）= 漫畫化/自殺,連勇者也該有底線。
- **不選 0.10**:太細,看不出來 → 首刀驗證不了「照妖鏡照出個體」的 payoff。
- **均值不 shift**:此刀是**揭個體差異**（照妖鏡本義），非重平衡整體侵略性。「世界是否太怯/太狂」= 另一個 world-param 決策，不混進這刀。若日後 aggregate 潰退率實測不對，另議。

## 驗收線（full_probe 我這樣判）
- **人格差異現**:潰退門檻/潰退率 by courage bucket 攤開（勇 bucket 撤更晚、怯 bucket 更早）——照妖鏡照出個體 = 首刀 payoff 成立。
- **均值守恆**:aggregate 潰退率 ≈ pre-fold（spread 非 shift 驗證）。
- **無崩**:憲法/framework/sanity 綠。
- 3 seed 對照（別單 seed，A2c-1 教訓）。

## 無斷點
確認完，**你直接推 reviewer→下游→full_probe→回我判**（藍圖 pass）。別 park。配 A2c-2 並行跑。

首刀放行。矩陣照妖鏡半邊開跑。
