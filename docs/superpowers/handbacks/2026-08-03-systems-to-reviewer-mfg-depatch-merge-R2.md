---
from: systems
to: reviewer
status: consumed
topic: "[R²融合驗(merge前)mfg de-patch·branch feat/mfg-labor-depatch 0c9a5c6a(labor-pool sibling,merge-base 61b2a354已含乙-revert)·dev-verify全綠(mfg_labor_depatch_test 5/5 de-patch生效+4保留gate+headless baseline+determinism byte-identical=labor-pool baseline+constitution74)·真code delta focused(manufacturing_system.gd:67移補丁閘一行+comment+tap/mfg_labor_depatch_test+101)·★審真code:①補丁閘真移除(current_task!=TASK_MANUFACTURE gate沒了,PRODUCE隊在outpost就跑)②保留gate全在(need-gated worker_rate仍含labor_mult fill/materials _can_consume/dedup labor_share/position outpost/PRODUCE resident)③無新gate/無新RNG·★stale-base note:branch=labor-pool sibling缺main的B+doc(raw diff B檔顯刪=artifact),但branch terms.gd:61含乙-revert(無crank const)+mfg-depatch只碰manufacturing_system.gd(main自ancestor未碰)=3-way merge保main的B+套de-patch,我merge後硬驗(B idle_employ_value在/乙-revert crank不在/labor_pool_test+idle_labor_build_test仍綠/mfg de-patch生效)·economy before/after+§8領導軸=交measurer(warring無settled producer)·CLEAN→我merge+merge-result驗→measurer §8三驗"
---

# R² 融合驗（merge 前）mfg de-patch

**branch**：`feat/mfg-labor-depatch` @ 0c9a5c6a（labor-pool sibling、merge-base 61b2a354 已含乙-revert）。dev-verify **全綠**（mfg_labor_depatch_test 5/5：de-patch 生效+4 保留 gate + headless baseline + determinism byte-identical=labor-pool baseline + constitution 74）。code delta focused（`manufacturing_system.gd:67 移補丁閘一行`+comment+tap / `mfg_labor_depatch_test+101`）。

## ★審真 code
1. **補丁閘真移除**：`current_task != TASK_MANUFACTURE` gate 沒了、PRODUCE 隊在 outpost 就跑（如 gather）？
2. **保留 gate 全在**：worker_rate 仍含 `labor_mult(fill)`（need-gated）/ `_can_consume`（materials）/ `labor_share`（dedup）/ outpost（position）/ PRODUCE resident？
3. **無新 gate/無新 RNG**？

## ★stale-base note（merge-care）
- branch = labor-pool sibling、缺 main 的 **B（idle-labor）+ doc 修**（raw diff B 檔顯「刪」＝artifact）。
- **但**：branch terms.gd:61 含**乙-revert**（無 crank const）+ mfg-depatch **只碰 manufacturing_system.gd**（main 自 ancestor 61b2a354 未碰）→ **3-way merge 保 main 的 B + 套 de-patch**。
- **我 merge 後硬驗**：B `idle_employ_value` 在 / 乙-revert crank 不在 / `labor_pool_test`+`idle_labor_build_test` 仍綠 / mfg de-patch 生效。
- **CLEAN → 我 merge + merge-result 驗 → measurer §8 三驗**（economy before/after + 領導軸、warring 無 settled producer 故交 measurer）。有洞 → 回 `to:systems`。
