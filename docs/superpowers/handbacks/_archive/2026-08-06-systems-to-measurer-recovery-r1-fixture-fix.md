---
from: systems
to: measurer
status: consumed
topic: "[recovery-r1 阻塞診斷完=非 code bug、是量測 harness LOD 設置·你診斷方向對(no-player LOD partitioning)·真根鏈:①migrant belief 源接對了——_village_est 讀 BeliefSystem.best_estimate(...population_est)=全 sim 同一路(threat/diplomatic/absorb 全走此)、且 vision_system.gd:112 _write_tier01 真寫 population_est belief(親見 record_claim)=機制存在②但 no-player fixture 傳 player_pos=(-1,-1)→sim_runner LOD partition(_get_near_teams dist≤LOD_NEAR_RADIUS=3 of player_pos / _get_far_teams 其餘)→真隊全落 far bucket→vision(LOD_BOTH)只每 FAR_ZONE_INTERVAL=100tick 跑一次(慢)→短/靜態 fixture 窗內領主 vision 沒跑→無 population_est belief→_village_est null→migrant inert·★修=量測 harness 非改 code:傳 player_pos=lord/cluster tile 給 advance_tick(lord dist0+村 dist3≤3 全落 near→hourly vision 10tick→belief 快 populate);或 SimRunner.force_full_hd=true(全-near、但改世界節奏 tempo、qualitative 三態檢 OK 但數值床慎用)·你 formula 手算三態(plains+0.54/forest−1.30/mountain−2.22)已證 sign 正確、只差 belief 供給·重跑:player_pos=cluster 後應見 plains 欠人村 migrant.dispatched fire、forest/mountain 不派·★broader:no-player headless 床預設 far-cadence vision(已知 LOD 非 bug)、需 belief acquisition 的床都要 player_pos=cluster 或 force_full_hd——我記入 measurement 協議 memory 供他床·地基 KEEP"
---

# recovery-r1 阻塞診斷 = 非 code bug、量測 harness LOD 設置

你診斷方向對（no-player LOD partitioning）。逐行追完真根：

## 真根鏈
1. **migrant belief 源接對了**：`_village_est` 讀 `BeliefSystem.best_estimate(...population_est)` = 全 sim 同一路（threat/diplomatic/absorb 全走此）；且 **`vision_system.gd:112` `_write_tier01` 真寫 `population_est` belief**（親見 `record_claim`）= 機制存在、非漏接。
2. **但 no-player fixture 傳 `player_pos=(-1,-1)`** → `sim_runner` LOD partition（`_get_near_teams` dist≤`LOD_NEAR_RADIUS=3` of player_pos / `_get_far_teams` 其餘）→ **真隊全落 far bucket** → vision（LOD_BOTH）**只每 `FAR_ZONE_INTERVAL=100 tick` 跑一次**（慢）→ 短/靜態 fixture 窗內領主 vision 沒跑 → 無 population_est belief → `_village_est` null → migrant inert。

## ★修（量測 harness、非改 code）
- **主**：`advance_tick(state, player_pos)` 傳 **`player_pos = lord/cluster tile`**（lord dist0 + 村 dist3≤3 全落 near → hourly vision `NEAR_CADENCE=10 tick` → belief 快 populate）。無真 player 也可傳、player_pos 只是 LOD 焦點。
- **替**：`SimRunner.force_full_hd=true`（全-near、無 player_pos 依賴；**但改世界節奏 tempo**、qualitative 三態檢 OK、數值床慎用）。

## 序
你 formula 手算三態（plains +0.54 / forest −1.30 / mountain −2.22）已證 sign 正確、只差 belief 供給。重跑（player_pos=cluster）應見：plains 欠人村 `migrant.dispatched` fire、forest/mountain 不派。→ 回 systems → QA → merge。

## ★broader（你顧慮的其他床）
no-player headless 床**預設 far-cadence vision**（已知 LOD 設計、非 bug）——需 belief acquisition 的床都要 `player_pos=cluster` 或 `force_full_hd`。我記入 measurement 協議 memory 供他床。地基 KEEP。
