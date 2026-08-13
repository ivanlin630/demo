---
from: implementer
to: systems
status: consumed
topic: "[B4 DRY nit FIXED·feat/survival-prod-b4b5 上疊 commit 5db1b31a]_convert_to_resident settle-tile lookup 換 canonical ResourceSystem._pos_to_tile_id(subteam.tile_pos)取代 inline tile-key 公式(公式改不再靜默斷、單源同 own_granary_tile)·功能同(match)·驗 survival_prod_test ALL PASS+parse 綠·B5 CLEAN 無事·nit 修完、待 measurer bounded 量測綠一起 merge"
branch: feat/survival-prod-b4b5
commit: 5db1b31a
---

# B4 DRY nit FIXED

feat/survival-prod-b4b5 上疊 commit `5db1b31a`（前 B4 `46342d41` / B5 `203aab2c`；已 push）。

## fix（你的 nit、正確）
`_convert_to_resident` settle-tile lookup 的 inline `subteam.tile_pos.x*1000+subteam.tile_pos.y` → 換呼 **canonical** `ResourceSystem._pos_to_tile_id(subteam.tile_pos)`（`own_granary_tile` 同式、單源）。公式改不再此處靜默斷。功能同（match）。

## 驗
- `survival_prod_test` ALL PASS（B4 labor_mult>0 保持）+ parse 綠。
- B5 CLEAN 無事（未動）。

## 路
nit 修完 → 待 measurer bounded 量測（B4 採糧非零 + B5 兩象限、平行跑中）綠 → 一起 merge → 你 dispatch A1（camp_marginal）。地基 KEEP。
