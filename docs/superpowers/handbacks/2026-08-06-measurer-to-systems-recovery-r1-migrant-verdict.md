---
from: measurer
to: systems
status: open
topic: "recovery-r1移民三態湧現分化 — formula驗證通過但fixture遇阻塞(非code邏輯bug,已定位到VisionSystem層級,超出temp-print診斷範圍):★ex-ante formula table(migrant_marginal pop2,k=3)手算完全對齊spec預期——plains=+0.54(正)/forest=−1.30(負)/mountain=−2.22(負),三態sign正確。★fixture(1領主pop15+3村pop2各terrain,同faction,距lord=3hex在VISION_RADIUS內)holding ledger正確追蹤全部3村(holding_count=3 confirmed)。但migrant.marginal全程0 samples——temp-print定位到`_village_est`每次都返回null(需求belief population_est,B系村village_id!=lord.team_id時走BeliefSystem.best_estimate)。進一步temp-print追到根源:VisionSystem.tick_discovery從未對lord(team_id=0)執行掃描,即使直接印tid==0分支也是0命中(距離改3後仍0,排除純距離問題)。查sim_runner.gd的near/far LOD team-partitioning(phase table shape='vision'呼叫teams參數)疑跟fixture無player(no_player=(-1,-1))有關,但這已超出我用temp-print能單獨解開的範圍,誠實回報阻塞點交你們判斷(可能是fixture環境設置問題,也可能是無player headless bed run的既有vision覆蓋缺口——若後者,可能影響其他量測員床)。temp print(faction_ai_system.gd+vision_system.gd共2處)已revert確認乾淨。fixture persist commit 6c9d8978。"
---

# recovery-r1移民三態湧現分化 — formula驗證通過，fixture遇VisionSystem層阻塞

工單 `2026-08-06-systems-to-measurer-recovery-r1-measure.md` 消費。

## ★formula驗證：完全通過（ex-ante，先算後跑）

用`MarginalEconomy.migrant_marginal(est, MIGRANT_BATCH=3)`公式（`marginal_economy.gd:27-35`），手算pop=2、`outpost_level=1`/`farming_level=0`/`harvest_factor=1.0`：

| terrain | REGEN | marginal(pop2,k=3) | sign |
|---|---|---|---|
| plains | 8.0 | **+0.54** | 正（該收移民） |
| forest | 3.0 | **−1.30** | 負（不該收） |
| mountain | 0.5 | **−2.22** | 負（不該收） |

**三態sign完全對齊spec預期，公式本身正確、零if-terrain分支、REGEN主導**。此表跟我上輪recovery-economic-baseline的Model B breakeven分析交叉一致（pop2森林接近打平線,山地明顯赤字,平原明顯盈餘）。

## fixture：holding ledger正確運作

1領主(pop15,faction leader,own outpost)+3村(plains/forest/mountain各pop2,own outpost level1,同faction)，距lord=3 hex（`VISION_RADIUS`範圍內）。**holding_count=3全程確認**（temp-print `dispatch_ledger.size`逐tick遞增、holding kind的3個entry皆存在）——lord的holding-ledger監看機制正確追蹤全部3村，這部分做對了。

## ★阻塞點：`_village_est`恆null，追到VisionSystem層級

`migrant.marginal`全程40天=0 samples——`_try_migrant_side`（`faction_ai_system.gd:1703`）內對每個holding entry呼叫`_village_est`皆返回null，卡在：
```gdscript
pop_est = BeliefSystem.best_estimate(state, lord.team_id, village_id).get("population_est", -1)
if pop_est < 0: return null   # ← 每次都在這裡bail
```

**temp-print逐層定位**（已revert，落地`docs/measurements/2026-08-06-migrant-debug.txt`）：
1. 首版距離=6（超出`VISION_RADIUS=3`）→ est=null，合理懷疑是距離問題，改為距離=3重跑。
2. **距離=3（在視野範圍內）→ est依然=null，排除純距離假說**。
3. 追查population_est唯一production寫入點：`VisionSystem._write_tier01`（`vision_system.gd:100-130`），由`tick_discovery`（`vision_system.gd:24`）在`dist<=vrange`時呼叫。
4. **在`tick_discovery`最外層加`tid==0`debug print，全程0命中**（落地`docs/measurements/2026-08-06-vision-debug.txt`）——**lord(team_id=0)從未出現在`tick_discovery`的`team_ids`參數裡，跟距離無關，是掃描對象清單本身就沒收lord**。

## 我沒有繼續深挖的原因

追到`sim_runner.gd:134`的phase table（`{"name":"vision",...,"shape":"vision"}`）→ `shape`解析呼叫`call(fn, state, teams, vmult)`（`sim_runner.gd:179`）——`teams`參數由更上層的near/far LOD team-partitioning決定（`_run_systems(state, teams, cadence, vmult, smult, is_near, t_in)`，near/far似乎跟玩家距離相關的效能分層，我的fixture是`player.team_id=-1`無玩家）。**這已經是sim_runner的LOD架構層級，非temp-print能單獨解開的範圍**——我不確定是（a）我的fixture缺了某個player-less headless bed run需要的設置、（b）無player時near/far劃分本身有邊界情況讓所有team都掉出vision掃描、還是（c）別的原因。**誠實回報阻塞點，非猜HOW**。

**★若是(b)，這可能是個影響範圍更廣的發現**——本session之前所有的měasurer beds（established-fragility/moderate-distress/g3-betrayal/ledger-diversity/care-loop）也都是`player.team_id=-1`的headless bed，如果vision-based belief（population_est）在無player時普遍不會形成，那些床裡任何依賴`BeliefSystem.best_estimate(...).population_est`的機制可能都有同款潛在缺口（雖然到目前為止那些床測的機制多半走別的belief管道，如`known_member_states`/`known_reputations`/`benefactor memory`，沒撞到這個特定欄位，算是僥倖沒踩到）。

## 落地檔案（已ls/wc驗證）

- `docs/measurements/2026-08-06-infonet-recovery-r1-migrant.json`（29行聚合）
- `docs/measurements/2026-08-06-infonet-recovery-r1-migrant.specimen.jsonl`（2846行）
- `docs/measurements/2026-08-06-migrant-debug.txt`（1212行，`_try_migrant_side`診斷）
- `docs/measurements/2026-08-06-vision-debug.txt`（24行，`tick_discovery`診斷，0命中本身就是資訊）

## 清理

- temp print（`faction_ai_system.gd`的`_try_migrant_side`診斷 + `vision_system.gd`的`tick_discovery`診斷，共2處）已`git checkout --`revert確認乾淨。
- fixture（config+bed script，含per-target sample歸因基礎設施）已persist commit `6c9d8978`，供修好vision問題後直接重跑復用。

別下accept。vision/no-player LOD的阻塞點是否為既有已知限制、是否影響其他床，交你們判斷；若需要我針對某個具體player-present或別的belief管道重新設計fixture，請開新工單指定方向。
