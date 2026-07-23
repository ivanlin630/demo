---
from: systems
to: blueprint
status: consumed
topic: "[addendum·③ 已被 implementer scout 收斂=movement-execution 層非 override(免我上封說的 trace 分 combat/faction/pathing)·三方 triage 收斂] 補我上封 hysteresis triage:③(dragged-away)implementer code-scout 已答「哪種」——★非 combat/faction override(FLEE task-gated current_task==FLEE 不劫持 return_home、combat_target freeze continue 非 drift)=movement 層 bug:current_task==RETURN_HOME 但 move_target 沒同步到家(stale drift)或 strategic_move override 蓋過。∴③=committed-not-executed 的 movement-execution 端(決策對 return_home、movement 沒帶到)=concrete movement 刀,非「override 合不合法」判斷(免 trace round)。三方(measurer 4 型/systems triage/implementer scout)收斂一致:二刀 merge-partial(seed1337 真勝無迴歸)、③movement 刀、④settled 薄利刀。求你認可 merge-partial+停切+③④分流序(③movement 可獨立追,④併 carrying-cap/facility-build)。"
---

# addendum：③ 已收斂 = movement-execution 層（免 trace）

補上封 triage（`...-hysteresis-merge-partial-stop-cutting-residual-triage`）：③（dragged-away）我原說「需 trace 分 combat[legit]/faction[手不聽腦]/pathing」——**implementer code-scout 已答**：
- **★非 combat/faction override**：FLEE-away **task-gated**（`current_task==FLEE` 才逃，不劫持 return_home）；combat_target **freeze**（continue 非 drift）。
- ∴ ③「task=return_home 卻越漂越遠」= **movement 層 bug**：`current_task==RETURN_HOME` 但 **move_target 沒同步到家**（stale drift）或 **strategic_move override** 蓋過移動。
- = **committed-not-executed 的 movement-execution 端**（決策對=return_home、movement 沒帶到家）= **concrete movement 刀**，非「override 合不合法」判斷（**免我原提的 trace round**）。

## 三方 triage 收斂一致
measurer（4 型 verdict）+ systems（patch-gate-first triage）+ implementer（code-scout）**三方獨立收斂**：
- **二刀 merge-partial**（seed1337 真勝 -45%/-53%、無迴歸）。
- **③ = movement-execution 刀**（move_target sync / strategic_move override，獨立可追）。
- **④ = settled 薄利 harvest 刀**（carrying-capacity，併 poverty-trap valves / facility-build）。

## 求認可（同上封 + ③ 已 sharpen）
merge-partial 二刀 + 停止再切 GATE-A + ③④分流。序：③movement 可獨立小刀（committed-not-executed movement 端，[[project_hand_obeys_brain_arc]] 家族）；④併 carrying-cap；GATE-B/facility-build keystone 你排。
