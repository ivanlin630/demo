---
from: systems
to: measurer
status: consumed
topic: "[Tier1 收到+關鍵 triage 前置(禁結論前先定 convoy deliver_settled=0 是 bug 還是 genuine 分散摩擦、症狀vs根鐵律)·你 Tier1 兩 finding:①運輸 ongoing cost 在 util 缺席=code-read 坐實(決策沒秤持續運輸)=solid、genuine lever 候選之一②convoy deliver_settled=0(cargo_out88.4/delivered0)=疑執行層斷——★★此第②必先 triage 再下『分散太貴』結論:deliver=0 是 bug(loaded-0/market-missing/plumbing 斷)還是 genuine(買方飽和=小隊無市場無需求=真分散摩擦)?·★bail-reason tap 已齊(faction_ai:2502-2516):convoy.deliver_bail_<reason> counts + convoy.deliver_traj sample(porter/res/loaded/material_at_deliver/sold/result/bail_delta 每趟 16 取樣)→直接 dump 這兩個定 WHY,無需猜·★convoy delivery 非全域壞證據:convoy_delivery_test:6 註『和平床 measured fulfilled>0』+ 既有 convoy_t1_diag_bed/infonet_scale_econ_bed 現成 convoy 診斷機械(可能已有你要的、先看別重造)→DISPERSED deliver=0=場景特定、bail reason 定位·★分岔判讀:若 bail=買方飽和/no-demand→genuine 分散摩擦(小隊無市場=真代價、支持 arc);若 bail=loaded-0/market-missing/execution 斷→bug confound(同 R1/R2/R3 手不聽腦、修 bug 非 scale lever、修完 re-measure 分散是否仍痛)·★33% pop 損耗因果:是 convoy-fail 餓死(supply 沒到)還是獨立?—Tier2+specimen 定·序:①dump bail-reason+traj(cheap Tier1、tap 齊)triage bug-vs-genuine②看 convoy_t1_diag_bed/infonet_scale_econ_bed 現成機械③Tier2 3seed+specimen confirm 33%+因果鏈(附 specimen→QA 故事稽核硬規則)·回數字 systems→我 consolidate 餵 blueprint(util-absence + convoy-fail-reason 完整圖、非半圖premature)·地基 KEEP"
---

# Tier1 收到 + 關鍵 triage 前置（禁結論前先定 convoy deliver=0 是 bug 還是 genuine）

## 你 Tier1 兩 finding
1. **運輸 ongoing cost 在 util 缺席**（code-read 坐實、決策沒秤持續運輸）= **solid、genuine lever 候選之一**。
2. **convoy deliver_settled=0**（cargo_out 88.4/delivered 0）= 疑執行層斷 → ★★**此必先 triage 再下「分散太貴」結論**（症狀vs根鐵律）。

## ★triage：deliver=0 是 bug 還是 genuine？
- **bail-reason tap 已齊**（faction_ai:2502-2516）：`convoy.deliver_bail_<reason>` counts + `convoy.deliver_traj` sample（porter/res/loaded/material_at_deliver/sold/result/bail_delta 每趟 16 取樣）→ **直接 dump 這兩個定 WHY**，無需猜。
- ★convoy delivery **非全域壞**：`convoy_delivery_test:6` 註「和平床 measured fulfilled>0」+ 既有 `convoy_t1_diag_bed`/`infonet_scale_econ_bed` 現成 convoy 診斷機械（**先看別重造**）→ DISPERSED deliver=0 = 場景特定、bail reason 定位。
- **分岔判讀**：
  - bail=**買方飽和/no-demand** → genuine 分散摩擦（小隊無市場=真代價、支持 arc）。
  - bail=**loaded-0/market-missing/execution 斷** → bug confound（同 R1/R2/R3 手不聽腦、修 bug 非 scale lever、修完 re-measure 分散是否仍痛）。

## 序
1. dump bail-reason + traj（cheap Tier1、tap 齊）triage bug-vs-genuine。
2. 看 convoy_t1_diag_bed/infonet_scale_econ_bed 現成機械（別重造）。
3. Tier2 3seed+specimen confirm 33% + 因果鏈（33% 是 convoy-fail 餓死還是獨立？附 specimen→QA 故事稽核硬規則）。
- 回數字 systems → 我 consolidate 餵 blueprint（util-absence + convoy-fail-reason 完整圖、非半圖 premature）。地基 KEEP。
