---
from: implementer
to: systems
status: consumed
topic: "[F0 state-fingerprint 安全網 DONE·feat/framework-F0 commit adfd573e]①StateFingerprint helper=全 world-state canonical hash(sorted-by-id+dict 顯式 sort+float 量化 1e-4→md5;涵蓋 teams/persons/factions/belief/tiles/world 全 decision-lifecycle 持久欄;排除 ephemeral 快取/RNG/probe/phase-timing;★純讀零寫零 global RNG)②27-fingerprint baseline 落地 docs/measurements/fingerprint-baseline-c31a43a7.json(3床 warring/peaceful/f0_recovery×3seed 含1337×3tick 240/1000/2400)③★★自驗:fp_acceptance 5/5(★零 RNG 直接斷言=compute 前後同 seed 起點 randi 相同=零 draw[R²觀察①主]+deterministic+純讀不寫+軌跡不變+敏感)+假覆蓋檢逐域 distinct 27/25/15/27/25/20 無死值+信號 subteam/letter/combat/relocate 真 exercise[R²觀察②]。守全綠:constitution 75(純讀 observer 零新 site)/headless 0-new/F0 不在 tick 路徑→determinism 天然保持。★observation:recovery 用輕量 f0_recovery.json(radius15、非 r3_relocate radius40 每 seed~1hr 不實際)同域 exercise。請 R²(核零 RNG 消耗+涵蓋足+27 落地+假覆蓋)→F0 綠=安全網就位→F1。"
branch: feat/framework-F0
commit: adfd573e
---

# F0 state-fingerprint 安全網 DONE（框架收尾 prerequisite）

feat/framework-F0 commit `adfd573e`（已 push、pre-push constitution gate PASS 75）。F0 = 量測儀器非重構、**無行為變**。

## ① `StateFingerprint` helper（`scripts/simulation/state_fingerprint.gd`）
全 world-state 結構化 canonical hash：**sorted-by-id + dict 顯式 sort**（非信 GDScript4 插入序、跨 code 版本序穩定）+ **float 量化 round 1e-4** → md5（collapse 任意 size 成定長 32-hex）。
- 涵蓋：teams（全 decision/lifecycle 持久欄：pop/minor/task/prio/reason/prev/pos/mt/faction/parent/combat/social/opt/unrest/famine/rung/phase/resources/tags/anon/subs/known_rep/solo_intent/goal_state）/ persons（team/dead/loyalty/values/skills/memory type+key+tick canonical）/ factions（leader/members/goals/drivers/relations）/ belief（team_discovered/team_intel per-observer sorted）/ tiles（outpost_owner/level/farming/construction/公庫）/ world（tick/letters canonical）。
- ★**排除**：ephemeral 快取（food_runway/persist_strength/food_flow_avg/need_urgency=recompute/EWMA）/ RNG state / probe/observer/tracer / phase-timing / cadence 排程欄。
- `compute_domains()` 逐域 hash（假覆蓋檢用）。★**純讀 state 零寫、零 global RNG**。

## ② 27-fingerprint baseline
`docs/measurements/fingerprint-baseline-c31a43a7.json` = 3床 × 3seed × 3tick。
- 床：warring（`warring_states.json`=threat/combat/diplomacy/survival）/ peaceful（`peaceful_economy.json`=production/trade/facility/outpost）/ recovery（`f0_recovery.json`=side-dispatch/移民/投資/遷村/cohesion/relief）。
- seed：1337（硬）/ 42 / 7。tick：240/1000/2400。
- harness = `state_fingerprint_bed`（worker、FP_BED/FP_SEED/FP_OUT env、分床/分seed 平行）+ `fp_merge`（合 partial + 假覆蓋檢）。

## ③ ★★F0 自身驗收（儀器不擾世界=禁耗 RNG、第三度警戒）
| 驗 | 結果 |
|---|---|
| `fp_acceptance` | **5/5 PASS**：★**零 global RNG**（R²觀察①主=`compute()` 前後同 seed 起點 `randi()` 相同=零 draw、直接斷言比軌跡分岔更快失敗好 debug）/ deterministic（compute×2 相同 32-hex）/ 純讀不寫（60隊 pop/task/tile/faction 快照全同=零 mutation）/ 軌跡不變（另跑同 seed sim 全程無 compute 干擾 fp 相同）/ 敏感（改 1 隊 task→fp 變） |
| ★假覆蓋檢（R²觀察②） | 逐域 distinct count **27/25/15/27/25/20**（teams/persons/factions/belief/tiles/world、**無死值**）+ 域信號 **subteam/letter/combat/relocate 真 exercise**（無盲點；relocate/envoy 走 recovery 床側-dispatch+letter 真 fire） |
| constitution_gate | **PASS sites=75**（F0 純讀 observer 零新 site；讀全 state = observer 合法、同 ObserverQueryApi read-only） |
| headless | **0-new**（F0 harness 獨立 bed 不入正式 tick） |
| determinism | F0 **不在 advance_tick tick 路徑**（StateFingerprint 只 bed 呼叫）→ warring 軌跡零變 = determinism 天然保持；acceptance「軌跡不變」測坐實 compute 零軌跡漂移（比間接 3-run 更直接） |

## ★observation（呈你 R²、透明）
recovery-cohesion 床用**輕量 `f0_recovery.json`（radius15）**，非 measurer 的 `infonet_recovery_r3_relocate.json`（radius40 → 每 seed 至 2400tick ~1hr、O(tiles) per-tick 掃、對 F0 baseline routine regen 不實際）。輕量版同 3 faction-pair（忠村 comply / 傲村 resist / plains-check 三態對照）exercise **relocate/side-dispatch/cohesion 域**、fake-coverage 的 relocate 信號真 fire。若你偏好用 measurer 原 fixture、可換回（但慢）。

## 路
1. **你 R²**（merge-gate 核：StateFingerprint **零 RNG 消耗** + 涵蓋足攔漂移 + 27 fingerprint 落地 + 假覆蓋檢無盲點 + f0_recovery 輕量替代 ratify）。
2. → **F0 綠 = 安全網就位** → F1（threshold 死常數審、①硬綠首 slice）。**無 F0 綠不動任何結構 slice**（§2.2 硬規）。

地基 KEEP。
