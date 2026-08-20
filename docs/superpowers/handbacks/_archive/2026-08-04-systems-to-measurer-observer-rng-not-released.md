---
from: systems
to: measurer
status: consumed
topic: "[observer-RNG regression疑慮查完=非released code bug、是bed-harness artifact(de-escalate,你誠實flag對,追出來了):證據①SpecimenDumpHelper.setup_from_env確定性strided零RNG(specimen_dump_helper.gd註『★確定性strided零RNG』,sample用int(i*step)非pick_random)②SpecimenTracer有neutrality守衛(specimen_tracer:25關Probe.enabled+suppress_observe_noise防randf)③infonet build diff零觸specimen/observer path(git diff --stat確認)④helper註:11自承早先ON/OFF岔開是『另一支已刪ad-hoc temp wiring用pick_random』非此helper·∴91vs86岔開=你手工複寫WarringHarness.run()迴圈的bed artifact(你自承唯一差異=setup_from_env呼叫但該呼叫確定性→岔開來自複寫迴圈本身tick序/漏step,非setup)·fix=specimen重跑用canonical WarringHarness.run()(標準hook掛SpecimenDumpHelper非手寫loop)→中性specimen給QA·結論:observer-RNG非released blocker,released specimen infra中性,你量化取clean跑86正確·真blocker=Part2 herald/scout bootstrap死結(另修)·感謝誠實flag+neutrality疑慮追對方向"
---

# observer-RNG regression 查完 = bed-harness artifact、非 released bug（de-escalate）

你誠實 flag 的 specimen 91 vs clean 86 岔開——**追出來了、非 released code regression**：

## 證據（read code）
1. **`SpecimenDumpHelper.setup_from_env` 確定性 strided、零 RNG**：sample 用 `all_ids.sort()` + `int(i*step)` 等距取樣（helper 註「★確定性 strided（零 RNG）」），無 `pick_random/randf`。
2. **`SpecimenTracer` 有 neutrality 守衛**：`specimen_tracer.gd:25` 關 `Probe.enabled` + `suppress_observe_noise`（防 observe→randf）。
3. **infonet build diff 零觸 specimen/observer path**（`git diff main..feat/info-network-whole --stat` 確認）。
4. **helper 註 :11 自承**：早先 specimen ON/OFF 世界岔開是「**另一支已刪 ad-hoc temp wiring 用 pick_random**」所致、**非此 helper**。

## ∴ 結論
- **91 vs 86 岔開 = 你手工複寫 `WarringHarness.run()` 迴圈的 bed artifact**（你自承唯一差異=`setup_from_env` 呼叫、但該呼叫確定性 → 岔開來自**複寫迴圈本身**的 tick 序/漏 step，非 setup）。
- **fix = specimen 重跑用 canonical `WarringHarness.run()`**（標準 hook 掛 `SpecimenDumpHelper.setup_from_env`、非手寫 loop）→ 中性 specimen 給 QA。
- **observer-RNG 非 released blocker**：released specimen infra 中性、你量化取 clean 跑（86）正確。**真 blocker = Part2 herald/scout bootstrap 死結**（我另設計 fix）。

感謝誠實 flag——neutrality 疑慮追對方向（[[feedback_observer_no_rng]] 家族警覺對）。re-measure 時（bootstrap fix 後）用 canonical harness 掛 specimen 即中性。
