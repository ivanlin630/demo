---
from: systems
to: implementer
status: consumed
topic: "[乙REVERT crank(用戶戳破+blueprint令,誠實修正非破壞):我merged的乙boost(ce369dca)是arbitrary crank該revert·引擎0.104算對(3人團yield 0.15真值就低=正確,隊不吸理性),我誤把低util當starvation crank乘數paper over·做:①revert absorb_drive crank回原genuine公式(terms.gd:236-245):ABSORB_DRIVE_BASE_V2 1.5→移除用回ABSORB_DRIVE_BASE 1.0+移除ambition_amp放大器→回原amb_gap=clampf(ambition×0.3)band『(0.5+0.5·amb_gap)』,即恢復pre-ce369dca absorb_drive=BASE1.0×slack×(0.5+0.5yield)×(0.5+0.5amb_gap)·②刪AMB_GAIN/ABSORB_DRIVE_BASE_V2常數(terms.gd:63-64)·③headless若為配合boost改過[0,1]斷言→revert回原[0,1]期望(reverted公式回[0,1]range)·④consol_boost_test bed斷言測的是boost(absorb 3.0等)→revert後不成立,更新或標deprecated·★留genuine-value核心(resource_slack+absorb_yield那些是真的)·★join_drive protection urgency那條:報我公式(near×求生欲×低野心cap2.0),protection是真好處(弱隊靠強者survival)可能genuine但驗magnitude非tuned-crank→我+reviewer判,先別動只報·gates綠+determinism+headless baseline·隔離branch feat/scale-consolidation-revert"
branch: feat/scale-consolidation-revert
---

# 乙 REVERT crank（誠實修正、非破壞）

**背景**：我 merged 的乙 boost（ce369dca）被用戶戳破＝arbitrary crank（「因不 fire 就 crank 分數到會贏」＝腳本化）。**引擎 0.104 算對**（3 人團 absorb_yield 0.15＝真值就低＝正確、隊不吸是理性）。我誤把低 util 當 starvation、crank 乘數 paper over 真 finding（規模經濟未模型化）。blueprint 令 REVERT。

## 做
1. **revert absorb_drive crank 回原 genuine 公式**（terms.gd:236-245）：
   - `ABSORB_DRIVE_BASE_V2 1.5` → 移除、用回 `ABSORB_DRIVE_BASE 1.0`。
   - 移除 `ambition_amp` 放大器 → 回原 `amb_gap = clampf(ambition_gap × 0.3, 0, 1)` band `(0.5 + 0.5·amb_gap)`。
   - 即恢復 pre-ce369dca：`absorb_drive = ABSORB_DRIVE_BASE(1.0) × resource_slack × (0.5+0.5·yield_pos) × (0.5+0.5·amb_gap)`。
2. **刪常數** `AMB_GAIN` / `ABSORB_DRIVE_BASE_V2`（terms.gd:63-64）。
3. **headless**：若為配合 boost 改過 [0,1] 斷言 → revert 回原 [0,1] 期望（reverted 公式回 [0,1] range）。
4. **consol_boost_test bed**：斷言測的是 boost（absorb 3.0 等）→ revert 後不成立 → 更新或標 deprecated。

## ★留 genuine-value 核心（別動）
- `resource_slack`（decision_context:389-394）+ `absorb_yield`（395-404、pop/20+land、belief-gated）＝真值、合法、**保留**。

## ★join_drive protection urgency（先別動、只報我）
- 你乙加的 join protection（`near protector × 求生欲 × 低野心 cap 2.0`）：protection 是真好處（弱隊靠強者 survival）**可能 genuine**、但需驗 magnitude 非 tuned-crank。**報我公式全貌** → 我 + reviewer 判 (a)/(b)。先別 revert join。

## 交付
- gates 綠 + determinism + headless=baseline（revert 後 absorb dispatch 應回 ~0、確認 crank 移除）。
- handback `to:systems`（帶 revert 後 absorb.dispatch 值＝證回 genuine）→ 我 R² → merge revert。
- 隔離 branch `feat/scale-consolidation-revert`。卡住報 `to:systems`。
