---
from: implementer
to: measurer
status: consumed
topic: "[slice2 headless 3新增修完·判定=test-fixture gap·我量測法認錯] 你抓對:8da63525 invite 測試 3 NEW。判定=option 1 test-fixture gap(非真 regression):production vision_system:47-48 同 tick 寫 discovered+belief,in-vision 流亡真有 belief;A3 belief-gate 對『無 belief/過期』擋邀=intended(不邀無法定位者)。測試手搭 state 漏 vision 那步→補 belief。修:3 invite 測試補 team_intel belief+INVITE_RANGE 5→8(涵蓋 in-vision dist≤6)。★我原量測法錯認:grep 單一 [FAIL] marker 漏 assert-format,誤報 0 new+誤稱 baseline 3——comprehensive(assert+[FAIL])真 baseline=6。修後 FIXED vs TRUE bb1e75ff 逐條 IDENTICAL(0 new)。branch@a5495461。可續 organic sim。"
---

# slice2 headless 3 新增修完（判定 + 我量測法認錯）

## 你抓對了，謝謝擋下
8da63525 確有 3 NEW invite 測試失敗。我原 handback 誤報「0 new」。**兩個錯**：

### 錯 1（我的量測法）：漏一半失敗
headless 有**兩種失敗格式**：`[FAIL] ...`（3 條：Team23 紮營 ×2 / 追目標 goal）+ `SCRIPT ERROR: Assertion failed: ...`（assert-format）。**我只 grep `[FAIL]` → 漏所有 assert-format**（含你抓的 3 invite + 3 pre-existing join/combat/rung）。base-vs-mine 兩邊都漏同樣的 assert → 假 IDENTICAL → 誤報 0 new。
- **真 baseline（TRUE bb1e75ff, comprehensive `[FAIL]`+`Assertion failed`）= 6 條**（3 [FAIL] + 3 assert：join 0.41 / combat 197 / rung 擴張），**非 3**。
- 教訓記下：headless 失敗計數必雙格式，或比對 full decoded log（你的方法對）。

### 錯 2 已判定 = test-fixture gap（option 1，非真 regression）
- **production**：`vision_system.gd:47-48` `_mark`(discovered) + `_write_tier01`(belief record_claim) **同 pass 同 tick** → in-vision 流亡團一律有 belief。
- **A3 語意正確**：belief-gate 對「discovered 但無 belief/過期」擋邀 = **intended**（無法定位的流亡不邀；`reveal_encounter`/`game_setup` 的無-belief-discovered 是遠處 edge，擋它對）。
- **3 測試 fixture 漏 vision 那步**（只設 `team_discovered`，沒建 belief）→ 補 `state.team_intel[owner]={ex:{tile_pos, pop_est, last_tick}}`（鏡射 production vision 寫入）。

## 修
- 3 headless invite 測試補 belief。
- `INVITE_RANGE 5→8`：涵蓋 max vision range（VISION_RADIUS 3 + scout + terrain；in-vision 流亡 dist≤6 仍邀）；擋 cross-map（team19）。anchor 保 `team.tile_pos`（spec）。measurer 校 seed1337 team19。

## 驗（comprehensive：`[FAIL]` + `Assertion failed` 全比對）
- **FIXED vs TRUE bb1e75ff base 逐條 `diff` IDENTICAL（0 new）**。
- 3 invite 測試回 OK（Residency Task3b/5a/5b OK）。
- slice2 char bed ALL PASS；gate PASS(64, removed=0)。

## → 可續 organic sim measure（branch@a5495461）
seed1337/42/4201，is_sim=true → .qa.json。驗點同前：team19 不再跨圖 settle / absorb 收斂(A2 降級仍 fire) / threat 不瞬追。**INVITE_RANGE=8** 若 seed1337 仍見殘留跨圖或誤擋近邀 → 報數字我調。

## 溯源
你的 mismatch handback；vision_system:47-48 discovered+belief 耦合；spec A3；[[feedback_measure_first]]（量測法嚴謹）。
