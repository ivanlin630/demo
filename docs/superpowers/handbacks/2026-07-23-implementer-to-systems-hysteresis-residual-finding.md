---
from: implementer
to: systems
status: consumed
topic: "[finding·hysteresis 正確部分(seed1337 -53%/-45%)但非 robust(seed42 持平)·③非 hysteresis 範疇=movement 層·④settled 薄利] hysteresis 機制對(seed1337 GATE-A 19→9/total 31→17)但 seed42 幾乎無效(殘留由 ③④主導非 hysteresis 治得了)。我 scout ③(dragged-away):FLEE-away task-gated(current_task==FLEE,不劫持 return_home)、combat_target=freeze(continue 非 drift)→③「task=return_home 卻越漂越遠」=movement 層(strategic_move override 或 move_target 沒同步到家 stale drift),★非 hysteresis/decision 層。④arrived-but-starving=settled 薄利 harvest(systems 已知)。建議:hysteresis merge-partial(seed1337 真勝+無迴歸)+③(movement task-execution)+④(薄利)各別刀。呈裁+seed robustness。"
branch: feat/gateA-return-hysteresis
commit: 8c7fbd83
---

# finding：hysteresis 正確部分但非 robust；殘留 ③④ 非 hysteresis 範疇

measurer hysteresis 量測（cc consumed）+ 我 code-scout。**hysteresis 機制對，但 seed 分歧=殘留由其他根主導**。
[[project_hand_obeys_brain_arc]] → 呈裁序，**不逕改**。

## ✓ hysteresis 機制正確（seed1337 大勝）
- seed1337：GATE-A bucket 19→9（**-53%**）、total 絕境 31→17（**-45%**）。band[3,5] 撐返家破 oscillation 有效。
- 12 隊 trace：① clean-success 3（設計樣子）② long-delay-success 2（50+天終究成功，非壞）。
- 無新餓死、doom 不惡化、無迴歸、determinism 25655ec0 採信。

## ✗ 非 robust：seed42 幾乎無效（11→9/total 持平）
- seed42 殘留由 ③④主導 → hysteresis 治不了（**機制對但非該 seed 主要困因**，非 hysteresis 有 bug）。

## 殘留 ③④（我 scout：皆非 hysteresis 範疇）
### ③ chronic-fail-dragged-away（2 隊）= movement 層 committed-not-executed（★非 hysteresis/decision）
- measurer：task=return_home 全程卻**位置越漂越遠**（反向非慢）。
- **我 scout 排除**：(a) FLEE-away override（`movement_system:82-84`）**task-gated** `current_task==TASK_FLEE`→**不劫持 return_home**；
  (b) `combat_target!=-1`（`movement:77`）= `continue` **freeze**（卡住不動，非 drift 反向）。
- **∴剩候選（movement 層 task-execution）**：`set_strategic_move`（arbiter A2c-2，`movement:91-92` movement 前設 move_target）override
  return_home 的 move_target → 走向 strategic 目標（可能反向）；**或** RETURN_HOME `to_task` 的 home target 沒同步到
  `team.move_target`（stale 舊 target drift）。需 **trajectory trace** 定哪支（move_target 逐 tick vs strategic_assignments）。
- = **committed-not-executed 更深一層（movement/task-priority 層，非 decision applicable 層）** [[project_hand_obeys_brain_arc]]。

### ④ arrived-but-still-starving（1 隊）= settled 薄利 harvest（systems 已知，非 GATE-A）
- 到家卻 food_days 卡 0 逾 20 天=home 真無糧可收 → with-outpost collect 5.58-6.55≈burn（薄利 caveat#6）。獨立刀。

## 呈裁（HOW owner）
1. **hysteresis merge-partial**：seed1337 -53%/-45% + 機制對 + 無迴歸 = 銀行（決策層真 gain；seed42 平非迴歸=其他根未觸）。
2. **③ movement task-execution**（return_home 越漂越遠）：建議 **trajectory trace 定 strategic-override vs move_target-stale** 再 spec。=committed-not-executed 更深（movement 層）。
3. **④ settled 薄利 harvest**（carrying-capacity valves，systems 已知）= 另刀。
4. **seed robustness**：seed1337 大勝+無迴歸 justify merge-partial；robust 定案需更多 seed（measurer 建議）。
- **v2b(coin)續 DEFER**。等裁 merge-partial + ③④序。
