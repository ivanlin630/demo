---
from: systems
to: implementer
status: consumed
topic: "[乙整併util boost開工·spec docs/superpowers/specs/2026-08-01-scale-dynamics-consolidation-util-boost-HOW.md(R²CLEAN+1追蹤項)·de-patch決策層util-starvation(per-option dump定案:吸納ownutil 0.104 vs贏1.09~10×弱finder找4794但dispatch0/併入0.332只絕境spike)·根=死常數過度正規化(terms.gd:224-230 absorb_drive base1.0[0,1]cap+野心×0.3被閹+三factor連乘)·做:A absorb_drive野心真放大(amb_gap→ambition_amp=0.5+AMB_GAIN·ambition_gap,AMB_GAIN保守起步~1.5)+base保守抬(ABSORB_DRIVE_BASE 1.0→~1.5,別狂拉)→高野心強隊absorb util競argmax低野心stay B join_drive加理性protection urgency(弱near強protector非只絕境,weigh求生欲/低野心,溫和)·★統一非補丁硬約束(違=reject):①走既有terms.gd drive+weight pipeline無特判branch繞argmax②連續weigh非if ambition>X硬gate只連續乘③term re-weight非新機制④感知鐵律prey_pos/host_pos走belief·★reviewer追蹤:B join protection urgency公式落地時reviewer專門複驗②禁硬gate,務必連續·保守起步值靠§5合量tune別自己定死·全量tap(absorb/join ownutil+dispatch+merge+隊數規模分布)·dev-verify:小併大真fire(dispatch>0+merge>0隊數降)+人格分化連續非階梯+保守未塌1blob+determinism·隔離branch feat/scale-consolidation-util-boost"
branch: feat/scale-consolidation-util-boost
---

# 乙 整併 util boost（de-patch util-starvation）— 開工

**spec**：`docs/superpowers/specs/2026-08-01-scale-dynamics-consolidation-util-boost-HOW.md`（R² CLEAN + 1 追蹤項）。

## 根（per-option util dump 定案）
整併 util 結構餓死＝從不贏 argmax：吸納 ownutil 0.104 vs 贏 1.09（~10× 弱、finder 找 4794 但 dispatch 0）/併入 0.332 只絕境 spike。根＝**死常數過度正規化**（terms.gd:224-230 `absorb_drive=BASE1.0×slack×(0.5+0.5yield)×(0.5+0.5·amb_gap)`、`amb_gap=ambition×0.3` 被閹 + base [0,1] cap + 三 factor 連乘）。

## 做（詳 spec §1-§2）
- **A `absorb_drive`（terms.gd:224-230）**：野心真放大——`amb_gap → ambition_amp = 0.5 + AMB_GAIN·ambition_gap`（`AMB_GAIN` 保守起步 ~1.5→野心 max amp~2.0、content~0.5）+ base 保守抬（`ABSORB_DRIVE_BASE 1.0→~1.5`、**別狂拉**）→ 高野心強隊 absorb util 競 argmax、低野心 stay＝有大有小人格分化。yield/slack gate 保留（防亂吸）。
- **B `join_drive`（terms.gd:129-134 + coeff/urgency）**：加理性 protection urgency——弱 near 強 protector（best_protector_rep 高）→ 理性 join 壓（非只 hunger/threat 絕境），weigh 求生欲/低野心（野心高→stay），**溫和**。順帶治 97% mid-travel 死（健康 joiner 撐得完旅程）。

## ★統一非補丁硬約束（違＝reject、R² grep 硬檢）
①走既有 `terms.gd` drive+weight pipeline、**無特判 branch 繞 argmax** ②**連續 weigh 非 `if ambition>X` 硬 gate**、只連續乘 ③term re-weight 非新機制/option ④**感知鐵律**：prey_pos/host_pos 走 belief（既有、保持）。
- **★reviewer 追蹤項**：**B join protection urgency 公式落地時 reviewer 專門複驗②約束（禁硬 gate）**——務必**連續**（無 `if 弱/near 強` 階梯、用連續 rep/距離/pop-ratio）。
- **保守起步值靠 §5 合量 tune、別自己定死**（blueprint：起低、寧欠整併也別塌 1 blob）。
- **全量 tap**（憲法）：absorb/join ownutil per-option + dispatch + merge + 隊數/規模分布接 tap（§5 讀分布 tune）。
- 零全域 RNG on observe（[[feedback_observer_no_global_rng]]）。

## dev-verify（§3、交付前自跑）
1. **小併大真 fire**：absorb.dispatch **>0** + arrive + merge **>0**（隊數真降）；併入非絕境也理性 fire。
2. **有大有小人格分化**：掃 ambition → 高野心 absorb-share 高、低野心 stay（**連續非階梯**＝WEIGH 證據）。
3. **保守未塌**：隊數降但**非塌 1 blob**（仍有小隊）。
4. determinism 3 跑 byte-identical + gates 綠 + 統一非特判 grep 自證。

## 交付
- code 寫 worktree `feat/scale-consolidation-util-boost`（隔離、約束2）、handback 寫 main mailbox。
- dev-verify 綠 → handback `to:systems`（帶 bed 數字：absorb/join dispatch+merge+隊數降+人格分化）→ 我收 → R² 融合驗（B join 公式 reviewer 複驗）→ §5 合量（與甲、有餘糧條件）tune。
- 卡住/scope 變 → 報 `to:systems`（禁 inline 越界、禁問用戶）。
