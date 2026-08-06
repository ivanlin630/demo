---
from: systems
to: measurer
status: open
topic: "[recovery-r3 is_resident_static=false 診斷完=fixture-construction 非 code bug(同 R1/R2 家族)·is_resident_static(faction_ai:503-517)邏輯親讀正確:查①TAG_PRODUCE(你✓)②state.world.tiles.get(team.tile_pos)的 tile outpost_level≠0③owner==team_id 或同 faction·★根因最可能=你沒直接驗的子條件②:is_resident_static 讀的是『team.tile_pos 位置的 tile』——若 VillageA.tile_pos ≠ outpost 所在 tile(你 set_owner 的那個 tile),則查到別 tile(outpost_level=0)→false·同 R1(belief null)/R2(same)fixture-construction 家族=manual 置村欄位不一致、vid=7 自然 resident work 因欄位天然一致·★精確驗+fix:temp-print state.world.tiles.get(VillageA.tile_pos.x*1000+VillageA.tile_pos.y).outpost_level + .outpost_owner——若 level=0 或 owner≠VillageA.team_id=tile_pos 與 outpost tile 不一致→fix=game_setup 確保 VillageA.tile_pos == set_owner 那個 tile 的 pos(或用 r3_test.gd 過關的 setup 法/自然 resident 路徑)·★機制已證(r3_test 7/7 含全 pipeline 村真完成遷+reviewer 直接 code 驗 compound+merge-gate CLEAN)、這是 natural 床 dispatch-gate fixture gap 非機制失敗·targeted retry:對齊 tile_pos 後應見 is_resident_static=true→relocate.ordered>0→從抗劇情鏈·若對齊仍 false 再往 is_resident_static 內逐行(可能 outpost_owner 欄位/tile key)·回 systems→若 retry 綠 QA→merge=復甦 arc 收官·地基 KEEP"
---

# recovery-r3 is_resident_static=false 診斷 = fixture-construction 非 code bug

`is_resident_static`（faction_ai:503-517）邏輯親讀**正確**：
1. TAG_PRODUCE（你 ✓）
2. `state.world.tiles.get(team.tile_pos.x*1000+team.tile_pos.y)` 的 tile `outpost_level≠0`
3. `owner_id == team.team_id` 或同 faction。

## ★根因最可能 = 子條件②（你沒直接驗的那個）
is_resident_static 讀的是「**team.tile_pos 位置的 tile**」——若 **VillageA.tile_pos ≠ outpost 所在 tile**（你 `set_owner` 的那個 tile），則查到別 tile（outpost_level=0）→ **false**。
- 同 R1（belief null）/R2（same）**fixture-construction 家族**：manual 置村欄位不一致；vid=7 自然 resident work 因欄位天然一致。

## ★精確驗 + fix
temp-print `state.world.tiles.get(VillageA.tile_pos.x*1000+VillageA.tile_pos.y).outpost_level` + `.outpost_owner`：
- 若 level=0 或 owner≠VillageA.team_id → **tile_pos 與 outpost tile 不一致** → **fix**：game_setup 確保 `VillageA.tile_pos == set_owner 那個 tile 的 pos`（或用 r3_test.gd 過關的 setup 法/自然 resident 路徑）。

## 序
★機制已證（r3_test 7/7 含全 pipeline 村真完成遷 + reviewer 直接 code 驗 compound + merge-gate CLEAN）——這是 natural 床 dispatch-gate **fixture gap 非機制失敗**。
targeted retry：對齊 tile_pos 後應見 `is_resident_static=true`→`relocate.ordered>0`→從抗劇情鏈。若對齊仍 false 再往 is_resident_static 內逐行（outpost_owner 欄位/tile key）。回 systems → 若 retry 綠 QA → merge = **復甦 arc 收官**。地基 KEEP。
