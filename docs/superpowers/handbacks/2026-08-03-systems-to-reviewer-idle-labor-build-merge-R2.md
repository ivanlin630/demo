---
from: systems
to: reviewer
status: open
topic: "[R²融合驗(merge前)B idle-labor→建設·branch feat/idle-labor-build eb263529(stacked labor-pool,labor-pool已merge main 506aaa64)·dev-verify全綠(idle_labor_build_test 11/11+headless baseline+determinism byte-identical+constitution74+★anti-crank反推公式)·真code delta focused(decision_context+59 idle_labor欄/options+3/terms+7 idle_employ_value/tile_data+3/decision_engine+6/tests)·★審真code 5點:①anti-crank(idle_employ_value全因子從manufacturing真worker_rate反推min(idle/d_new,1)×facility_full_output×need_weight,禁發明PER_HAND常數,idle=0或無需求→0 self-limit,守feedback_genuine_value_not_crank命門=這次別又縮小版乙)②guardrail只加建設(grep idle_labor無漏combat/survival/trade/move/social)③憲法非硬gate(連續乘非if idle>X)④idle_labor算式=maxf(pool_of−Σlabor_alloc.demand,0)只PRODUCE⑤§4 spread/militarize deferred(blueprint裁MVP建設-only)·★stale-base note:branch merge-base=61b2a354落後main(缺handbacks/doc修),但branch terms.gd含乙-revert(no crank)=3-way merge應乾淨,我merge後硬驗無revert(乙-revert在/doc HIGH修在/labor_pool_test仍綠)·CLEAN→我merge+merge-result驗(idle_labor_build_test+labor_pool_test+constitution+headless+terms.gd乙-revert確認)→measurer §8 re-measure領導軸"
---

# R² 融合驗（merge 前）B idle-labor→建設

**branch**：`feat/idle-labor-build` @ eb263529（stacked labor-pool、labor-pool 已 merge main 506aaa64）。dev-verify **全綠**（idle_labor_build_test 11/11 + headless baseline + determinism byte-identical + constitution 74 + ★anti-crank 反推公式）。code delta focused（decision_context+59 / options+3 / terms+7 / tile_data+3 / decision_engine+6 / tests）。

## ★審真 code（5 點）
1. **★anti-crank（守命門、你上輪追蹤項）**：`idle_employ_value` 全因子從 manufacturing 真 worker_rate 反推——`min(idle/d_new,1)×facility_full_output×need_weight`、**禁發明 PER_HAND 常數**、`idle=0` 或無需求→0、self-limit。**親讀 terms.gd:112-117 + decision_context 的 idle_employ_value 計算：全因子真 grounding、非縮小版乙？**
2. **guardrail 只加建設**：grep idle_labor 無漏 combat/survival/trade/move/social？
3. **憲法非硬 gate**：idle 連續乘、無 `if idle>X` 階梯？
4. **idle_labor 算式**：`maxf(pool_of − Σ labor_alloc.demand, 0)`、只 PRODUCE（軍隊天然不在 pool_of）？
5. **§4 spread/militarize deferred**：blueprint 裁 MVP 建設-only、合理？

## ★stale-base note（merge-care）
- branch merge-base=61b2a354 落後 main（缺我後續 handbacks/doc 修）。**但 branch terms.gd 含乙-revert（:61 no crank）→ 3-way merge 應乾淨**（terms.gd = main + idle_employ_value 增行、docs branch 沒碰→保 main）。
- **我 merge 後硬驗無 revert**：乙-revert 在 / doc HIGH 修在 / labor_pool_test 仍綠 / terms.gd 無 crank 常數。
- **CLEAN → 我 merge + merge-result 驗 → measurer §8 re-measure 領導軸 ratio 追平**。有洞 → 回 `to:systems`。
