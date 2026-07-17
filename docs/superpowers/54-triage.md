# 54 待標閘 triage（framework 做好 stream① 殲滅殘留閘）

> **★2026-07-17 進度**：**91→89→72**（gate PASS removed=0，pushed ad294112）：
>   - S1 registry merged（5cfc2483）:`applicable::threshold`+`to_task::early_return` relocate 移除（byte-identical）→ 89。
>   - **bucketB-legit inline gate-ok merged**（comment-only，17 標）→ 72。re-freeze 72（ad294112 pushed）。
>   - **seam#2 S1 `_facility_deficit` registry merged**（f5fda115，byte-identical 5/5，加設施=1 entry；gate 72 不變無 fingerprint 變）。B-facility gate 本身待未來 gate-ok 批標。
> baseline `scripts/debug/constitution_baseline_v2.txt`：現 **72 閘**。剩=taskarbiter scaffolding(28,已 gate-ok) + Bucket A route/dispatch(legit-until-convergence) + B2 照妖鏡(序5) + B-facility guards(NeedOracle 單源,待批標) + threat(threat-oracle) + rng(C legit 待標)。綠=待→0。
> ★de-patch 前逐 code 驗真行為閘（血證:閘4 randi=ID-gen/閘6 已軟 util 曾 over-reach，[[feedback_fileline_vs_interpretation]]）。detector-hit ≠ 確認違規。
>
> **★剩 72 之 35 待閘分類（investigator 逐 code 2026-07-17）**：
>   - **24 CONVERGENCE-TRACKER（STAY，真統一 tracker）**：route/dispatch_entry + `_evaluate_survival/threat/uprising/subteam/all_body/solo` + `rank_survival/rank_scored_ctx` 的 threshold/early_return + `_trigger_survival::route`。=filtered-subset dispatch scaffolding，收斂 arc（threat-oracle/survival-churn/ambient）移除，**不標**（gate 追蹤真統一剩餘）。
>   - **9 TERMINAL-LEGIT → mark batch2**（7 乾淨 + 排除 collision）：`_send_diplomacy_message::rng`(:174 event-ID)、`try_proactive_diplomacy::rng`(:130 慎重³案③)、`_facility_deficit::early_return/threshold`、`_facility_terrain_fit::threshold`、`_pick_facility::early_return/threshold`。**★排除 `_evaluate_new_outpost_location::threshold`**（investigator 標 :2727 guard 但同 fingerprint 藏 MIN_BUILD/MINING_GREED，bucketB reviewer 已判 STAY=collision）。
>   - **2 DEATH-CONSTANT（STAY，序5 de-patch）**：`_consider_extraction::threshold`(:2242 extract_score>0.4)、`_evaluate_independent_strategy::threshold`(:1217 AMBITION_FOUND_MIN)。

## Bucket A — seam#1 收斂（★2026-07-17 逐 code 全驗：3 subset 收斂全 unsound；唯一真消閘=S1 移除 2 個 91→89，其餘 route/dispatch 全 legit-until-convergence-design 保留非移除。下方 A1/A2 舊分類 superseded——survival/ambient 收斂逐 code 驗同 threat 也 unsound:ambient 排 FLEE 防 churn 序3 血證/survival previous_task 防抖基準）
> ★2026-07-17 R② 異質審裁定 threat 收斂 UNSOUND（見 spec §R②）。Bucket A 拆：
>
> **A1 安全收斂**（S1 registry byte-identical + survival/ambient/solo/subteam 逐路驗）：R② CLEAN→impl→退役後 baseline 消。含 `options.applicable::route`、`rank_survival::early_return`、`rank_scored_ctx::early_return/threshold`、`_evaluate_survival/solo/subteam/all_body/uprising/independent_strategy::route`、`_decide_subteam::route`、`_trigger_survival::route`。**逐路驗行為保才退役**（survival latch/ambient FLEE 排除 藏語意）。
>
> **A2 threat 閘 = legit-until-threat-oracle**（剝離，非移除）：`_evaluate_threat::dispatch_entry/route`、`rank_threat`（+preempt `faction_ai_system.gd:396`/probe `:405`）。編碼真選擇語意（量級壓小×gate選×PRIO70×preempt×自有FLEE公式）。**標 gate-ok(legit-until-threat-oracle)**，收斂延路線圖序3-4。

- `decision_engine.gd::rank_scored_ctx::early_return`（統一路內部早退，seam 後留 or 標 gate-ok 待定）
- `decision_engine.gd::rank_scored_ctx::threshold`（同上）
- `decision_engine.gd::rank_survival::early_return`（rank_survival 退役隨 seam）
- `options.gd::applicable::route`（registry 化後 route 消，S1）
- `faction_ai_system.gd::_decide_subteam::route`
- `_evaluate_all_body::route`
- `_evaluate_independent_strategy::route`
- `_evaluate_solo::route`
- `_evaluate_subteam::route`
- `_evaluate_survival::dispatch_entry` / `::route`
- `_evaluate_threat::dispatch_entry` / `::route`
- `_evaluate_uprising::route`
- `_trigger_survival::route`
- （+ 各 `_evaluate_*::early_return`/`::threshold` 屬同函式者若隨函式退役則一併，S2/S3 impl 明確）

## Bucket B — ✅逐 code adjudicated（investigator 抓 56 rows/18 func → systems 判，2026-07-17）
> raw 條件表見 handback thread（investigator）。判準:GUARD/world-mechanic=gate-ok legit;facility cluster=route seam#2;const 擋人格決策=照妖鏡 defer 序5。**只判不 de-patch（防 over-reach 血證）**。

**B-legit → 標 gate-ok（GUARD + world-mechanic）** ← R② CLEAN（2026-07-17，含 1 scoping 限制）。★標機制=**inline 源碼 `# gate-ok`**（非改 baseline txt=裝飾，[[reference_constitution_gate_marking]]）→ 是源碼編輯=dispatch implementer。**★限制**：`_evaluate_independent_strategy::threshold` fingerprint 混 AMBITION_FOUND_MIN(B2 序5 defer)→**只准 inline 標 `:1158` envoy-timeout 那行**，`:1212/1217/1219` 留無標（fingerprint 續被追蹤=正確）。`to_task`(options.gd) 標**待 S1 merged 後**（S1 registry 化同檔，避 conflict）。其餘 17 項各為函式內唯一命中無 collision，安全 inline 標。
- **GUARD（純資料守衛/cadence/in-flight，非決策）**：`_calc_diplomacy_score`(null)、`_consider_extraction`(treasury≤0/player/null)、`_evaluate_infrastructure`(null/combat/player/empty)、`_evaluate_independent_infrastructure`(combat/player/null/no-outpost/empty)、`_evaluate_new_outpost_location`(candidates empty)、`_evaluate_outpost_residency`(cadence throttle+null)、`_evaluate_owner_contact`(非resident/無owner/last_tick=-1)、`_evaluate_storage_visit`(非自家outpost/public empty)、`_trigger_defection_evaluation`(null)、`_trigger_survival`(null+means-end自救豁免)、`_evaluate_independent_strategy`(player/parent≠-1/combat/null/envoy-in-flight/subjugate-in-flight)、`to_task`(全 IDLE fallback=資料缺守衛)。
- **world-mechanic 閾（世界規則非行為 gate）**：`_evaluate_infrastructure` outpost_level>=3=**level cap**、`_evaluate_outpost_takeover` OUTPOST_TAKEOVER_DAYS=**占領 timer**、`_evaluate_owner_contact` CONTACT_TIMEOUT_DAYS=**cadence**、`_evaluate_independent_strategy` envoy timeout 2day=**latch-timeout（守 invariant①in-flight latch必timeout）**、`_pick_outpost_type` tools>=3.0=**材料需求**、`_decide_unified` DISPATCH_DIST_THRESHOLD=**probe bookkeeping 非 option 選擇**（investigator 挖，非決策）、`_evaluate_storage_visit` needed*2.0=**庫存 housekeeping**(mild)。

**B-facility → ★前提先驗重判（2026-07-17，S6 已 merged 單一源解）**：
> `_facility_deficit`(`faction_ai_system.gd:3061-3116`)**已讀 NeedOracle**（workshop/apothecary/armorsmith/smeltery/stable = `NeedOracle.need_keep(+demand)`，`:3064` S6 註「遷 NeedOracle 消 TARGET_PER_POP 殘留與生產/商業共讀同源」）→ **單一源違規早解**。seam#2 原 premise「facility 走 TARGET_PER_POP 各算」**stale**。重判：
- **已 legit gate-ok**（單源/world-mechanic/軌2 de-patched）：`_facility_deficit` 各 res 分支的 `if tgt<=0.001: return 0`=GUARD、workshop/apothecary/armorsmith/smeltery/stable=NeedOracle 單源、weaponsmith `0.6-armed_ratio × _militancy`=軌2 閘1 de-patched(人格 militancy 秤)、mint `ore>10.0`=tile-bound world-mechanic、granary=local food(S2 granary seam)、`_facility_terrain_fit`=resource-presence geography。→ 併入 B-legit gate-ok 批標。
- **seam#2 剩餘=擴充 only**：`_facility_deficit` 仍是 per-facility `match`（+`_facility_score`/`_pick_facility` 0.05/DEMOLISH_MARGIN、`_pick_outpost_type`、`_evaluate_new_outpost_location` MIN_BUILD_SCORE/MINING_GREED）=加設施=加 branch → **match→registry 資料驅動**（同 seam#1 S1 pattern，byte-identical 擴充 refactor）。**單一源不必再做（S6 done）**。
- `_evaluate_infrastructure::dispatch_entry`=infrastructure 評估入口，待查 engine-routed vs scaffolding（低優先，不擋）。

**B2 照妖鏡候選 → 序5 死常數人格化 defer（framework-first，不現修）**：
- `_consider_extraction:2242` `extract_score > 0.4` = 徵收決策硬閾（0.4 const）→ 候選（該人格化?）。
- `_evaluate_independent_strategy:1217` `ambition >= AMBITION_FOUND_MIN` = 建國 ambition 硬 cutoff → 候選（EXPAND_MIN_POP/food-surplus=capability precondition legit，唯 AMBITION_FOUND_MIN 是人格硬切）。
- `_evaluate_new_outpost_location:2722` MINING_GREED_THRESHOLD(greed+ambition 硬 cutoff)=人格 grounded 但硬切，低優先（也 facility cluster）。

## Bucket C — rng 決策骰（RNG 3-案判準）= 2
> 判準：純骰 de-patch / 世界 outcome legit / 人格加權機率 legit-IF-陡。
- `_send_diplomacy_message::rng` — ✅ **驗畢=gate-ok**（`diplomatic_ai_system.gd:174` `state.player_forced_event_id = str(randi())` = event-ID 生成，非決策骰；同 `_maybe_request_join_player::rng` baseline:66 false-positive 族。逐 code 擋住 over-reach:detector hit randi 但 ID-gen）。→ 下批標 legit list。
- `try_proactive_diplomacy::rng` — ✅ **驗畢=gate-ok**（`diplomatic_ai_system.gd:130` `if randf() < 慎重³ return` = 人格加權機率，unit-proven 陡 = RNG 案③ legit-IF-陡）。★fast-follow measure 回（2026-07-17）：**行為級分化撤回**——高端「0%」是 127-樣本 noise（569 樣本 0.70% 不重現），低慎重<0.35 **generator 架構不可達**（`person_generator.gd:17` NORMAL_LO=0.35，無 archetype 列慎重 lo_v）。**公式陡（源硬 legit）成立，但行為分化被 opportunity 稀缺+floor 遮蔽**。gate-ok 立於**公式**非行為。殘：generator-diversity（低慎重原型）+ 藍圖陳述更正 = 軟債/vision backlog（不現修，framework-first）。

## 流程
1. Bucket A：seam#1 R² CLEAN → impl → S3 batch removed（26 閘）。
2. Bucket C try_proactive：measure 回 → 判。_send_diplomacy_message：逐 code。
3. Bucket B：逐 code 驗 → B1 標 gate-ok（constitution_gate legit list）/ B2 de-patch。
4. 每批走紀律鏈（逐 code 驗真行為 → 標/de-patch → constitution_gate 綠證）。
