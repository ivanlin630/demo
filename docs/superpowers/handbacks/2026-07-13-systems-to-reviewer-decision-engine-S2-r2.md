---
from: systems
to: reviewer
status: open
topic: [R②·S2] 決策引擎重構 slice 2：coeff表+rank_scored接入+plan_phase原子退役+§6標籤——dispatch 前設計審
---

# R② 設計審請求：decision-engine 重構 S2（架構原子切換）

## 前置
- **計畫** `docs/superpowers/plans/2026-07-13-decision-engine-needs-hierarchy.md` **# Slice 2**（S2.1~S2.6）。S1 已 merge(`ba0d589`，driver inert 驗收 CLEAN)。
- spec §3/§4/§6/§8。blueprint S2 go(`S1-merge-S2-go`)。

## S2 內容（6 task，spec §8 硬要求「五層上線+plan_phase退役同slice」）
- **S2.1** `NeedHierarchy.AFFINITY` 純靜態 const 表(23 option×5 層，行和≈1) + `affinity_of`。
- **S2.2** `consistency_coeff(opt,urgency,leader_values)→float`：`alignment=Σaffinity·urgency`；`coeff=clampf(1−steepness·(1−alignment),FLOOR,1)`；steepness=`STEEP_BASE+慎重·0.4−野心·0.35`（§4 陡度取代賭命跳關）。FLOOR=0.15 軟降權不歸零。
- **S2.3** `rank_scored_ctx` util ×= coeff（全 23 option 統一，coeff 乘在 COMMITMENT_BONUS 前）。
- **S2.4** `narrative_label`(argmax layer)→ team.plan_phase（GUI 來源改接，讀點不變）。
- **S2.5** plan_phase 完整退役：term+weight+6 REGISTRY row+map+derive_plan_phase+_phase_option_bias+PHASE 常數全刪（team.plan_phase 欄保留純顯示）。
- **S2.6** warring_harness probe(全 23 覆蓋+coeff 分布) + 融合閘。

## 請 R② 重點查
1. **§3 純靜態表(reviewer 風險#1)**：AFFINITY 是 const Dict、`affinity_of` 純 lookup、`consistency_coeff` 純算術零分支——查有無隱藏動態計算膨脹成 state machine。
2. **coeff 公式數值健全**：alignment∈[0,1]（affinity 行和≈1×urgency≤1）；steepness clamp[0,1]；FLOOR=0.15 軟降權（最遠 option 仍可選）。查 coeff 乘在 COMMITMENT_BONUS **前**是否正確（承諾慣性不受需求調變）。查 rank_survival/rank_threat/rank_ambient 子集**本 slice 不加 coeff** 是否留下不一致風險（我判：survival 子集由 PRIO_SURVIVAL 插隊管、threat 路 S4 再處理；主 rank 走 rank_scored_ctx）。
3. **plan_phase 原子退役無殘引用**：S2.5 grep 確認 sim code 零 `plan_phase_drive`/`derive_plan_phase`/`_phase_option_bias`/`PHASE_*` 引用；team.plan_phase 欄語意轉換(獨立算→argmax 衍生)是否漏處理 hysteresis 舊用途。
4. **全 23 覆蓋真達成**：原本無 plan_phase_drive/intent_fit 的 12 option（生產/建設/駐守/囤貨/徵收/歸建/備戰/迎戰/求和/吸納/乞食/佔村）是否都在 AFFINITY 表且 coeff 生效——spec §3「全 23 統一非只 11」。
5. **AFFINITY 語意合理性**：掠奪/佔村/紮營跨層(生存+尊重/自我實現)、駐守偏自我實現(定居長治)——查層歸屬有無明顯錯配會扭曲行為。

CLEAN 則 dispatch implementer 做 S2；有 blocker 回 verdict。
