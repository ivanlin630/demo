# Hand Back: far-zone elapsed 移動積分（time-scale wave slice B）

branch: `feat/far-elapsed-movement`（base `origin/main`=525bae6）；commit `7b78123`。

## 實作摘要
- **`scripts/simulation/movement_system.gd`**：
  - `process` 簽名收 `elapsed_ticks: int`（default `TICKS_PER_HOUR`=舊行為，向後相容）。
  - `move_tick_acc += elapsed_ticks`（取代硬編 `+TICKS_PER_HOUR`）。
  - 單步→**多格迴圈**：`acc>=cost` 逐格步進、每步 `acc-=cost`（**保餘數**，非 `acc=0`）；每格重算 `cost`（地形變）、到點/stuck 即停（`_step_team` 清 `move_target`）。
  - cost 上限保護：`max_steps = maxi(1, elapsed/MIN_MOVE_TICKS)`（cost 恒 clamp≥MIN → 防病態無限迴圈）；迴圈後 `acc = mini(acc, MAX_MOVE_TICKS)`（節流下丟不可能兌現的超額，留合法零頭）。
- **`scripts/simulation/sim_runner.gd`**：`_step2_move_teams` 收 `elapsed_ticks` 轉傳；near 呼叫傳 `NEAR_CADENCE`(10)、far 呼叫傳 `FAR_ZONE_INTERVAL`(100)。→ far 每呼叫補回 100 tick 移動預算 = 與 near 同速（修 10× 稀釋）。

**與 spec 無差異**。scope 內兩檔如 spec；`headless_test.gd` 未動（既有 movement 測用 2-arg `process`，走 default elapsed=TICKS_PER_HOUR + near max_steps=1 → 舊單步語意保留，無需改）。

## 驗收證據（before=origin/main，after=commit）
| 閘 | 結果 |
|---|---|
| headless | `=== DONE ===`，0 SCRIPT ERROR |
| framework_validation | PASS=7 DORMANT=0 |
| coin_eq | delta=0.00（守恆不受移動影響）|
| 確定性 | seeded warring reproducible OK（**final 值變 teams 47→46=B預期**，pop 380 量級不崩）|

**一修多解（B 前後對照）**：
- **V1 trade**（trade_funnel_bed default/1337/6mo）：到場 arrive 3→21（4.3%→40.4%）、成交 deal 16→42、timeout 夭折 38→21、矛盾率 0.758→0.605。（`deal_merchant=0` 兩側皆然 = 本 run 商隊tag=0 無 carrier 存在，**正交於移速**，殘因見下）
- **V4 envoy**（seeded_warring_bed）：seed1337 delivered 1→3、timeout 14→3；seed42 dispatched 5→40、delivered 4→32。
- **V3 帶禮結盟**：seed1337 gift_delivered 1→3、**accept 0→1**；seed42 gift_delivered 4→32、indep.found_ally 4→35。
- **不塌房**：teams/pop/factions 同量級、無全滅（seed1337 pop 189→226 反升、seed42 269→221、seed7 398→406）。

**perf（附帶，lod_perf_bed warring/1337/2mo）**：LOD-active mean 8547→10969us（**+28% = far 隊現真做 pathfinding**，先前 10× 欠移=少做 9/10 path work）。**max hitch 731261→731414us（實質不變 = 既有 die-off O(N) spike，非本改）→ 無新 spike**。多格迴圈 cap（far≤6，常態 1-2）→ per-tick 仍有界（perf 域不變量守）。

## 連動風險（主 session 決定是否補修）
- **`gen`/FOOD 校準**：far 隊現以正確 ×5 速跑（A1）→ 跨格旅途糧耗、AI_ETA_LIMIT/founding·trade timeout 皆按舊 near 速校準，現可能寬鬆化（多為好事）。spec 註 4 標「A2 後段複驗」，本 slice 不動值。**risk = 中**（節奏變但正向；seeded pop 量級穩，未見塌房）。
- **A2 相容**：本改修 far/near **比例**（正交於絕對速度）→ A1(×5,cost48)/A2(×1,cost240) 皆相容，不等 A2。
- **RNG 流**：多格迴圈改 `_step_team`/PathSystem randf 消耗序 = **預期行為變**（B 核心）。**merge 後須重立所有 seeded baseline**（seeded_warring_bed WARRING_OUT / headless reproducible 期望值 / longwindow / dieoff 等）。確定性本身守（同 seed 同結果）。
- **perf 優化受限**：far-movement pathfinding 現為 LOD regime 新顯著項。**禁用 path memoize/cache 省 A* 呼叫**（會重排 randf 消耗序 → 破確定性/違 RNG-sacred）。若 50-隊目標下需降 far path 成本 → 須無 RNG-side-effect 手段（如 far 專用粗粒度移動），歸後段裁。

## 待主 session 確認
- **baseline 重立**：本 commit 使所有 seeded final 值變（B預期）。merge 後請重跑並更新各 bed baseline JSON（seeded_warring_bed / headless reproducible 期望）。
- **deal_merchant 殘因非本 slice**：trade V1 到場/成交大漲，但 `deal_merchant`（商隊跑單成交）仍 0 = **carrier 存在性**（default run 商隊tag=0，無 merchant-carrier spawn）→ 正交於移速，屬另軌（carrier spawn/gen）。
- **envoy accept 低（seed42 全 reject=32）**：delivered 大漲但 accept=0 = **決策端拒絕**（送達成功，是否接受屬外交決策 gate），非送達問題。可能後續調外交 accept 傾向，非本 slice。
