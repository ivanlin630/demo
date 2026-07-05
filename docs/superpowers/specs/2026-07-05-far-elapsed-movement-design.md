# far-zone elapsed 移動積分（time-scale wave slice B）— Design

> 藍圖 `timewave-five-rulings` 裁 **B = 最高優先**（measure 證一修多解）。三平行 measure 揭共根。
> **一修解三**：V1 trade 到場 / V4 envoy 送達 / V3 帶禮結盟（禮隨信使走、信使到得了才有）。+ 遠隊「疏非慢非笨」= LOD 詭異感的正解。

## 斷點（measure 定罪）
- `movement_system.gd:76` `team.move_tick_acc += WorldState.TICKS_PER_HOUR`（**硬編 10，不管實際經過多久**）。
- sim_runner 呼叫：near `sim_runner.gd:191`（near 分支,每 `NEAR_CADENCE`=10 tick 跑一次）、far `sim_runner.gd:240`（far 分支,每 `FAR_ZONE_INTERVAL`=100 tick 跑一次）。
- → near 每 10 tick +10 = **1 tick 移動/tick**；far 每 100 tick +10 = **0.1 移動/tick = 10× 稀釋**。自然世界全隊 far → 跨格物流全癱。
- 附帶：`:77-79` `if acc < cost: continue / acc = 0`——**`acc=0` 丟餘數**（連 near 都每步丟 <cost 的零頭，小不準）。

## 修（elapsed 積分：疏批次但補回真時間）
1. **`process` 收 `elapsed_ticks` 參數**（`movement_system.gd:35` 簽名）。`move_tick_acc += elapsed_ticks`（取代硬編 `TICKS_PER_HOUR`）。
2. **sim_runner 兩呼叫傳實際 elapsed**：near→`NEAR_CADENCE`(10)、far→`FAR_ZONE_INTERVAL`(100)（`sim_runner.gd:191/240`；用常數非字面）。→ far 每呼叫 +100 = 1 移動/tick effective = **與 near 同速**。
3. **多格步進（疏非慢非笨核心）**：`acc >= cost` 時**迴圈步進**多格、每步 `acc -= cost`（保餘數，非 `acc=0`）：far 隊一次呼叫 elapsed=100、cost=48 → 走 2 格、acc=4 餘。=遠隊算得疏（每 100 tick 一次）但走對距離（100 tick 的路）。
   - 迴圈守界：每格重算 cost（地形變）、到 `move_target` 即停（`_step_team` 到達清 target）、途中觸發（相遇/到點）保既有語意。
4. **cost 上限保護**：單呼叫最多步 `elapsed/MIN_MOVE_TICKS` 格（防病態格 cost=0 無限迴圈）。

## ★RNG 流神聖（cadence-spike 教訓）
- 移動/`_step_team` 若含 `randf`（path tiebreak / observe_velocity 副作用）→ **多格迴圈改 randf 呼叫序** → seeded 流位移。**這是預期行為變**（far 移對=世界不同），但：
  - **禁**在迴圈內用「先濾後算」或 memoize 改變 randf 消耗序假設（濾鏈含 randf 勿重排，[[reference_multi_sanity_unseeded]] / cadence 教訓）。
  - 驗證=**確定性保持**（同 seed 同結果，`seeded warring reproducible OK` 仍 pass，只是 final 值變）。
- **A1 相容**：B 落於 A1（×5,cost=48）→ far 以正確 ×5 速跑。A2（×5→1,cost=240）後 far 以正確 ×1 速跑。B 修 far/near **比例**（正交於絕對速度）→ A1/A2 皆相容,不等 A2。

## 驗收
1. 回歸：headless DONE+0 SCRIPT ERROR；framework PASS=7 DORMANT=0；coin_eq delta=0（守恆不受移動影響）。
2. **seeded warring reproducible OK**（確定性保持；**final 值必變**=far 移對,附前後 teams/factions/est/pop 量級不崩全滅）。
3. **一修多解證據**（default/warring measure，B 前後對照）：
   - envoy `delivered/dispatched` 由 ~0 起（V4 解）。
   - trade 商隊 `arrive/dispatch`、`deal_merchant` 由 ~0 起（V1 解——sufficiency/trade_funnel bed 對照）。
   - V3 帶禮結盟 accept >0（禮隨送達的信使到）。
   - far 隊 specimen 可追「跨格→到達」（非永漂）。
4. **不塌房**：teams/pop/faction_found 同量級、狼弧在、不 over-war。
5. **perf 附帶**：far 移動多格迴圈的 tick-time（lod_perf_bed 對照，別新增 spike）。

## 檔案 scope
改：`movement_system.gd`（process 收 elapsed + 多格迴圈 + acc 餘數）、`sim_runner.gd`（兩呼叫傳 NEAR_CADENCE/FAR_ZONE_INTERVAL）。可能 `headless_test.gd`（若既有移動測 assume 單步/固定 acc）。
**勿碰**：TimeScale/×5→1（A2）、cadence 常數值（③）、FOOD/gen（A2/④）、faction_ai 思考 cadence（②行軍降頻=另 slice,B 只管移動速度不管思考頻率）、決策邏輯。

## 註（給實作）
- ②「行軍降頻」（移動中隊思考 cadence 降）是**分開的**（餵 A 減 O(N²)），非本 slice——B 只修移動 elapsed（物流）。別混。
- `AI_ETA_LIMIT`/founding·trade timeout 按 near 速校準（measure 揭）→ far 移對後這些 budget 是否仍合理需複驗（可能寬鬆化=好事）；裸常數收編歸後段，本 slice 不動值。
