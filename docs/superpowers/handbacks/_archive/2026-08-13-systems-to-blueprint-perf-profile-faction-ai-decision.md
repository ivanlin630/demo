---
from: systems
to: blueprint
status: consumed
topic: "[perf profile 實測完(短窗跑法成功、答用戶『運算卡哪』)·★兇手=faction_ai 93.7% 非嫌疑清單任一(尋路/print/belief 全排除)·評測床 perf_phase_bed.gd(force_full_hd 全隊 near+phase_timing+短窗 DAYS+累積相位表、純 debug 零 production 侵入)·跑 seed1337 warring 1天240tick wall28.3s·★相位表:near.faction_ai=93.7%(26.5s/28.3s)、near.move[含尋路 estimate_catch_up]=1.3%、near.reactions=1.1%、near.vision[belief 掃]=1.0%、餘全<0.8%·★三嫌疑全 DISPROVEN:①尋路=near.move 1.3% 排除②belief 掃=near.vision 1.0% 排除③print=phase_sum 100% of wall→print/glue≈0% 排除(答 Q2 print 佔比≈0)·★熱點 pin(faction_ai 內層 [FaiPhase] 每 tick 一致):loop1.assign_tasks+unified.rank+assign.leader_unified 主宰→code 位 _assign_tasks(faction_ai:2308)→_decide_unified(:2399)→DecisionEngine.rank_scored(:2410=unified.rank)·★perf 根 CONFIRM=統一決策框架 per-team option 排序:每 faction 的每 member team(:2348 loop)每 DECISION_CADENCE 呼一次 rank_scored(所有 option×term×weight)→隨 team 數×option 數擴張=die-off/大世界天花板真因·★caveat 誠實:force_full_hd=worst-case(全隊 near 每 tick 跑 faction_ai、無 far 批次降頻)→絕對 tick-time 誇大;real LOD far 隊 FAR_ZONE_INTERVAL 批次→實際低;但相對宰制(faction_ai>>其餘)+team-count 擴張=perf 根成立、corroborate 決策成本 O(teams×options)·★hook QA 豁免:純 perf 聚合 metric 不下 behavior 因果(哪 phase 吃 CPU 非隊為何做X)·evidence-only 禁 fix·序:你帶用戶看『卡在決策引擎排序非尋路』→若要修 perf(cache ranking/降 cadence/early-prune option/memoize term)=另 arc 待用戶裁、我不提 fix·與饑荒 ledger 平行(measurer 跑)"
---

# perf profile 實測完 — 答用戶「運算卡哪」

短窗跑法成功（避 GODOT_TIMEOUT 砍）。evidence-only、禁 fix。

## 評測床
`scripts/debug/perf_phase_bed.gd`（新、純 debug/infra 零 production 侵入，同 lod_perf_bed 族）：
- `force_full_hd=true`（全隊 near → 分組 `_pht` 相位計時 fire）+ `phase_timing=true`。
- 每 tick advance 後讀 `runner._ph` 累積 → 全窗相位表。**免動 sim_runner**。
- env `PERF_DAYS`（default 5）短窗、`PERF_SEED`/`PERF_CONFIG`。
- 跑：seed 1337 warring_states 1 天 = 240 tick、wall 28.3s。

## ★相位表（答「運算卡哪」）
| phase | %phase | us/tick | 判定 |
|---|---|---|---|
| **near.faction_ai** | **93.7%** | 110468 | ★兇手 |
| near.move（含尋路 estimate_catch_up） | 1.3% | 1505 | 嫌疑**排除** |
| near.reactions | 1.1% | 1354 | |
| near.vision（belief 掃） | 1.0% | 1123 | 嫌疑**排除** |
| 其餘 13 相 | 各 <0.8% | | |

- **phase_sum = 100% of wall** → print/glue ≈ 0% = **print 嫌疑排除**（答 Q2）。

## ★三嫌疑全 DISPROVEN
1. **尋路** = `near.move` 1.3% → 排除。
2. **belief 掃** = `near.vision` 1.0% → 排除。
3. **print 阻塞** = phase 總計時 = 100% of wall（print/glue 佔比 ≈ 0）→ 排除。

## ★熱點 pin（faction_ai 內層 `[FaiPhase]` 每 tick 一致）
`loop1.assign_tasks` + `unified.rank` + `assign.leader_unified` 主宰。code 位：
- `_assign_tasks`（faction_ai:2308）→ `_decide_unified`（:2399）→ **`DecisionEngine.rank_scored`（:2410 = `unified.rank`）**。
- 每 faction 的每 member team（:2348 loop）每 `DECISION_CADENCE` 呼一次 `rank_scored`（評所有 option × term × weight）。

## ★perf 根 CONFIRM
**統一決策框架 per-team option 排序** = CPU 宰制。隨 **team 數 × option 數** 擴張 = die-off / 大世界 perf 天花板真因（corroborate 先前 dieoff 1 月窗 >10min 被砍 + measurer 撞執行天花板）。

## ★誠實 caveat
`force_full_hd` = **worst-case**（全隊 near 每 tick 跑 faction_ai、無 far 批次降頻）→ 絕對 tick-time 誇大。real LOD far 隊走 `FAR_ZONE_INTERVAL` 批次 → 實際低。但**相對宰制**（faction_ai >> 其餘）+ team-count 擴張 = perf 根成立。

## hook QA 豁免
純 perf 聚合 metric、**不下 behavior 因果**（「哪 phase 吃 CPU」非「隊為何做 X」）→ hook 明文豁免。

序：你帶用戶看「卡在**決策引擎排序**、非尋路/print/belief」。若要修 perf（cache ranking / 降 cadence / early-prune option / memoize term eval）= 另 perf arc 待用戶裁——我不提 fix。與饑荒 ledger 平行（measurer 跑中）。
