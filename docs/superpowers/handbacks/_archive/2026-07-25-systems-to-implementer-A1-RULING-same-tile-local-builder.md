---
from: systems
to: implementer
status: consumed
topic: "[裁·A1 BLOCKED 解除·認我 spec 錯(same-tile 派子隊零距離無 arrival)·你正解對(就地 builder)·裁:same-tile 就地/remote 派子隊分流+:171 移除回 followup+TDD 驅真 movement·spec §2b/§5 已訂正·續做] 認我 spec 又錯(第 2 次 A1 相關):same-tile 建派同格子隊→零距離無 movement→begin_subteam_construction 只 arrival 觸發→永不 start→mint_lv=0 regression。你 code 坐實+正解(infra 已有就地 builder)對。★裁(spec §2b 已訂正):①S4 :178 build_F facility(same-tile own outpost)→**就地/派子隊分流**(複用既有 infra 邏輯:owner 在場 team.tile_pos==own_outpost tile→OutpostSystem._subteam_upgrade_facility(state,team,tile,facility) 就地開工;不在場→_dispatch_facility_builder 派子隊)。★非一律派子隊。②S4 :171(隊站空 tile 建 new outpost=same-tile founding)→**移除該 candidate**(回 S4 facility-type-mismatch known_issues followup=non-A1-core;same-tile outpost 無母隊就地 outpost-build 路+屬 facility-type-mismatch 補非 A1)。build_F facility-outpost-type 前置未滿→靜默(followup 不變)。③S3 forest remote founding(異格)→delegate _dispatch_builder **不變**(remote 子隊真移動→抵達→建,你 s3 綠)。∴A1 scope=S3 remote forest(delegate)+S4:178 facility(就地/派子隊分流);:171 移除。_dispatch_goal_delegate facility 分支=就地/派子隊分流(非一律 _dispatch_facility_builder)。④★★TDD execution-end **驅真 movement/arrival 非 teleport**(你首版 teleport 遮 same-tile bug;spec §5.2 訂正:remote founding 真移動抵達觸發 begin_subteam_construction;same-tile facility 就地驗真建成)=feedback_verify_execution_end 精化。★續做(halt 解除):照訂正 spec §2b/§5。goal-chain 建 facility 複用 infra owner-在場分流=所有權縫收斂(means-end 想建→接 infra path,非另立子隊路)。完成=systems+reviewer R²(★我收驗查真建成 mint/outpost level>0+whole-headless 無 regression+驅真 movement TDD)→to:systems。謝你 whole-headless 抓 regression+揭就地 builder+teleport 遮 bug=execution-end 教訓精化。"
branch: feat/means-end-A1-fix
---

# 裁：A1 BLOCKED 解除（same-tile 就地 builder / remote 派子隊分流）

認我 spec **又錯**（第 2 次 A1 相關）：same-tile 建派同格子隊 → 零距離無 movement → `begin_subteam_construction` 只 arrival 觸發 → 永不 start → mint_lv=0 regression。你 code 坐實 + 正解（infra 已有就地 builder）**對**。

## ★裁（spec §2b/§5 已訂正）
1. **S4 `:178` build_F facility（same-tile own outpost）** → **就地/派子隊分流**（複用既有 infra 邏輯）：owner 在場（`team.tile_pos == own_outpost tile`）→ `OutpostSystem._subteam_upgrade_facility(state, team, tile, facility)`（就地開工）；不在場 → `_dispatch_facility_builder`（派子隊）。**非一律派子隊**。
2. **S4 `:171`（隊站空 tile 建 new outpost＝same-tile founding）** → **移除該 candidate**（回 S4 facility-type-mismatch known_issues followup＝non-A1-core）。build_F facility-outpost-type 前置未滿 → 靜默（followup 不變）。
3. **S3 forest remote founding（異格）** → delegate `_dispatch_builder` **不變**（remote 子隊真移動→抵達→建，你 s3 綠）。
4. ★★**TDD execution-end 驅真 movement/arrival 非 teleport**（你首版 teleport 遮 same-tile bug；spec §5.2 訂正）。

∴ A1 scope = S3 remote forest（delegate）+ S4:178 facility（就地/派子隊分流）；:171 移除。`_dispatch_goal_delegate` facility 分支 = 就地/派子隊分流。goal-chain 建 facility **複用 infra owner-在場分流 = 所有權縫收斂**（means-end 想建 → 接 infra path，非另立子隊路）。

## 續做（halt 解除）
照訂正 spec §2b/§5。完成 = systems + reviewer R²（★我收驗查真建成 mint/outpost level>0 + whole-headless 無 regression + 驅真 movement TDD）→ `to:systems`。謝你 whole-headless 抓 regression + 揭就地 builder + teleport 遮 bug ＝ execution-end 教訓精化。
