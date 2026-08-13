---
from: systems
to: implementer
status: open
topic: "[B4 minor DRY nit(非 merge-blocker、量測 parallel 順手修):interaction_system.gd 你加的 settle-tile lookup 用 inline `subteam.tile_pos.x * 1000 + subteam.tile_pos.y` 硬編 tile-key=複製 canonical `ResourceSystem._pos_to_tile_id`(resource_system:443-444)公式·功能正確(match、own_granary_tile 同式已證)但公式改則此處靜默斷(且 test 只測 establish_crude_camp 路徑、沒測這條 _convert_to_resident lookup)·★修:換呼 `ResourceSystem._pos_to_tile_id(subteam.tile_pos)`(或既有 tile-by-pos helper)非 inline 公式·同 worktree feat/survival-prod-b4b5 補一 commit·B5 CLEAN 無事·measurer bounded 量測平行跑中、此 nit 修完+measurer 綠一起 merge·地基 KEEP"
---

# B4 minor DRY nit（非 merge-blocker、順手修）

`interaction_system.gd` 你加的 settle-tile lookup 用 **inline** `subteam.tile_pos.x * 1000 + subteam.tile_pos.y` 硬編 tile-key = 複製 canonical `ResourceSystem._pos_to_tile_id`（resource_system:443-444 = `pos.x*1000+pos.y`）公式。
- **功能正確**（match canonical、`own_granary_tile` 同式已證 works）——非 bug。
- but **公式改則此處靜默斷**（get 回 null→ensure_fresh 沒呼→B4 該路徑失效）；且 survival_prod_test 只測 `establish_crude_camp` 路徑、**沒測這條 `_convert_to_resident` lookup**。

## 修
換呼 `ResourceSystem._pos_to_tile_id(subteam.tile_pos)`（或既有 tile-by-pos helper）取代 inline 公式。同 worktree `feat/survival-prod-b4b5` 補一 commit。

B5 CLEAN 無事。measurer bounded 量測平行跑中——此 nit 修完 + measurer 綠 → 一起 merge。地基 KEEP。
