---
from: systems
to: reviewer
status: consumed
topic: "[R²B idle-labor→建設 genuine激勵HOW(MVP建設-only,blueprint GO,領導軸size-matter治§8 ratio0.38-0.45)·spec docs/superpowers/specs/2026-08-03-idle-labor-build-incentive-HOW.md·premise全grounded(建設options:40-45 labor-blind/紮營gated NOT has_outpost/militarize+recruit ABSENT/labor_system pool_of/DecisionContext無idle欄)·設計:idle_labor intake(新ctx欄=maxf(pool_of(tile)−Σlabor_alloc.demand,0)只PRODUCE軍隊天然不在pool)+genuine價值項只加建設(idle_employ_value=min(idle,d_new)×PER_HAND×need_weight(候選facility產物)=雇用閒勞力真期望產出)·★審點:①genuine非crank守命門(乙教訓:build util升因真雇用閒勞力真need-weighted產出,idle=0或無需求→term=0不亂建,self-limit隨facility吸收遞減,禁flat K×(idle>0)boost)②guardrail只加建設,grep無idle_labor漏進combat/survival/trade/move/social③憲法決策非硬gate(idle連續乘非if idle>X)④idle_labor算式對(pool−Σdemand-cap=超產能真浪費)⑤§4 gap deferred(spread/militarize=blueprint裁另arc,MVP建設-only合理非under-deliver)·CLEAN→dispatch隔離feat/idle-labor-build→dev-verify idle→build因果+genuine+guardrail+§8 re-measure領導軸追平"
---

# R² B idle-labor→建設 genuine 激勵 HOW（MVP、blueprint GO）

spec：`docs/superpowers/specs/2026-08-03-idle-labor-build-incentive-HOW.md`。blueprint 裁 MVP 建設-only GO（治 §8 領導軸 ratio 0.38-0.45<1）。premise 全 grounded（建設 labor-blind / 紮營 gated / militarize+recruit ABSENT / pool_of 有 / ctx 無 idle 欄）。

## 設計
- **idle_labor intake**（新 ctx 欄）：`maxf(pool_of(tile) − Σ labor_alloc[k].demand, 0)`（只 PRODUCE、軍隊天然不在 pool_of）。
- **genuine 價值項只加建設**：`idle_employ_value = min(idle_labor, D_NEW_WORKSTATION) × PER_HAND_OUTPUT × need_weight(候選 facility 產物)`＝雇用閒勞力真期望產出。

## ★審點（守 [[feedback_genuine_value_not_crank]] 命門、別又 crank）
1. **genuine 非 crank**：build util 升**因真雇用閒勞力 × 真 need-weighted 產出**——`idle=0` 或**無需求**（need_weight=0）→ term=0（不亂建沒用的）；self-limit（idle 隨 facility 吸收遞減、建夠就停）。**禁 flat `K×(idle>0)` boost**。這公式站得住嗎？
2. **guardrail**：idle_labor term **只加建設**、grep 無漏進 combat/survival/trade/move/social？
3. **憲法決策非硬 gate**：idle 連續乘、無 `if idle>X` 階梯？
4. **idle_labor 算式對**：`pool−Σdemand-cap`＝超產能真浪費（非 pool−Σactual-share）？
5. **§4 gap deferred 合理**：spread（紮營第2據點 un-gate）/militarize（折军民混编 arc）blueprint 裁另 arc、MVP 建設-only 非 under-deliver（直修 §8 根、大隊建 manufacturing 用掉閒勞力=day50 證行為更早）？

## note
- **CLEAN → 我 dispatch 隔離 `feat/idle-labor-build`** → dev-verify（idle→build 因果 + genuine 非 crank + guardrail grep）→ **§8 re-measure 領導軸 ratio 追平才宣稱**（誠實 measured、同 SLICE A）。有洞 → 回 `to:systems`。
