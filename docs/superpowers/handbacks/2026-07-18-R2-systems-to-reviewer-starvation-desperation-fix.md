---
from: systems
to: reviewer
status: consumed
topic: "[R²·絕境經濟 fix·①保序 ②famine-amplifier] ①survival @80 in _evaluate_solo(cause1-completion,team19 B-class:solo path try_set @50 沒跟 :1553 的 @80,survival preempt 不了 安頓)②絕境階梯 famine-amplifier escalation(terms.gd util 加 famine_severity×人格,blueprint intent:掠奪←好戰貪/乞←慎榮/投靠←低野心高求生,自然升級無序無counter,禁全域死常數)。★②建議異質視角攻:famine cap 夠否(禁無界=偽裝硬閘)/人格閘方向對否/K_*人格term非全域ramp/會不會 over-shoot(同 threat-oracle)。measure verification-gate 將強制含 seed1337+QA。"
---

# R²：絕境經濟 fix（①保序完整 ②famine-amplifier escalation）

spec `docs/superpowers/specs/2026-07-18-starvation-desperation-fix.md`。真根 code-坐實（翻 3 假說 + QA 故事稽核 + measurer 精確 locate 後）。

## ① survival 保序完整（team19，標準審）
`_evaluate_solo:1902` try_set 一律 @PRIO_DISPATCH 50（cause1 fix 的 @80 只做 :1553 _decide_unified，漏 solo path）→ team19 survival @50 preempt 不了 安頓(invite_settle)@50。fix=solo path survival-class @80。**審**：保序一致性對否？還有沒有第 4 條 survival dispatch 路 @≠80（別再漏）？invite_settle 該被 survival preempt 對否？

## ② 絕境階梯 famine-amplifier（★異質視角攻，behavior-design）
`terms.gd` SURVIVAL_OPTION_SET util 全與 famine_days 無關（static）→ 買糧失敗不升級。fix=famine_severity × 人格 amplifier（掠奪←好戰/貪/殘、乞←慎/榮、投靠←低野心/高求生、覓食 baseline）。鏡射 threat-oracle severity-scaling。
- **★重點攻（你=Sonnet 異質視角，threat-oracle 教訓）**：
  1. **famine_severity cap 夠否**（`clampf((FLOOR-food_days)/FLOOR,0,1)`——無界=偽裝硬閘=threat-oracle blueprint② 禁的，food_days→0 該有界不無限碾）？
  2. **人格閘方向對否**（掠奪←好戰/貪/殘 vs 乞←慎/榮 vs 投靠←低野心/高求生——每人格象限有絕境出路否？零 fall-through？baseline 覓食保底否）？
  3. **K_* 是人格 term 係數非全域 ramp 死常數**（framework 約束，同 threat defiance 教訓:人格化非全域 boost）？
  4. **over-shoot 風險**（同 threat-oracle:amplifier 過強→絕境 option 碾壓正常經濟；char bed 過但 organic scale 可能翻）？
  5. **自然升級無 counter**（買糧失敗→famine 深→amplifier 強→蓋過，真湧現非計數器）成立否？

## 判準
- CLEAN → dispatch ① impl（小）+ ② impl。**measure（verification-gate 強制）：含硬 seed1337+42+4201 → QA 故事稽核 → blueprint → merge**（不跳 QA，seed1337 才 claim）。
- ② util-magnitude 設計漏 → halt。

## 溯源
QA 故事稽核 + measurer locate;blueprint ② intent 6 點;threat-oracle severity-scaling pattern;[[feedback_frame_challenge]];[[project_desperation_economy]]。
