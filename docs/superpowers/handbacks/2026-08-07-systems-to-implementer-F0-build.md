---
from: systems
to: implementer
status: consumed
topic: "[dispatch build F0 state-fingerprint 安全網(R² CLEAN+2 觀察納入 spec)·spec docs/superpowers/specs/2026-08-07-framework-F0-state-fingerprint-HOW.md·框架收尾 program prerequisite(§2.2 硬規:無 F0 綠不動任何結構 slice)·F0=量測儀器非重構·新 slice feat/framework-F0 off 更新後 main·範圍:①StateFingerprint static helper=全 world-state 結構化 hash(full canonical sorted-by-id+dict 顯式 sort[非信 GDScript4 插入序、fingerprint 需跨 code 版本序穩定]+float 量化 round 1e-4);涵蓋 teams(id/pop/minor/task/priority/reason/tile_pos/move_target/faction_id/parent/resources/tags/combat_target)/persons(id/team/values/loyalty/skills/memory type+key+tick canonical)/factions(id/leader/members/goals/rep)/belief(team_intel/discovered/known_rep per-observer sorted canonical)/tiles(outpost_owner/level/farming/construction/關鍵 resource_cap)/world(tick/in_transit_letters/計數);★排除 ephemeral 快取(food_runway/persist_strength recompute)/RNG state/probe-observer-tracer/phase-timing·②state_fingerprint_bed harness=3床(warring WarringHarness seeded/peaceful-economy/recovery-cohesion)×3seed(含硬 seed 1337)×3tick(240/1000/2400)=27 fingerprint→落 docs/measurements/fingerprint-baseline-<hash>.json·③★★F0 自身驗收(儀器不擾世界禁耗 global RNG=第三度警戒、feedback_observer_no_global_rng LOD→RNG 犯過2次):★R² 觀察①=compute() 前後直接讀 RNG call-count/state 斷言不變(主、更快失敗好 debug)+determinism 3-run byte-identical(輔)+coin_eq 純讀不寫·★R² 觀察②=逐域確認真 exercise(尤 envoy 建國提案/信使外交、檢查該域 fingerprint 欄位在 27 筆真有變化非死值、假覆蓋=安全網盲點→補床/seed 或明標未覆蓋)·守:純讀 state 零寫/零 RNG/determinism/constitution 過閘(純讀 observer 合法同 ObserverQueryApi read-only)/headless 0-new(F0 harness 獨立 bed 不入正式 tick)·完成 handback to:systems R²(merge-gate 核 StateFingerprint 零 RNG 消耗+涵蓋足+27 fingerprint 落地+假覆蓋檢)→F0 綠=安全網就位→F1(threshold 死常數審)·此 slice 是儀器非重構、無行為變·地基 KEEP"
---

# dispatch build F0 state-fingerprint 安全網（R² CLEAN + 2 觀察納入）

spec：`docs/superpowers/specs/2026-08-07-framework-F0-state-fingerprint-HOW.md`。框架收尾 **prerequisite**（§2.2：無 F0 綠不動任何結構 slice）。F0=量測儀器非重構、**無行為變**。新 slice `feat/framework-F0` off 更新後 main。

## 範圍
1. **`StateFingerprint` static helper** = 全 world-state 結構化 hash（**full canonical** sorted-by-id + **dict 顯式 sort**[非信 GDScript4 插入序、fingerprint 需跨 code 版本序穩定]+ float 量化 round 1e-4）。
   - 涵蓋：teams(id/pop/minor/task/priority/reason/tile_pos/move_target/faction_id/parent/resources/tags/combat_target) / persons(id/team/values/loyalty/skills/memory type+key+tick canonical) / factions(id/leader/members/goals/rep) / belief(team_intel/discovered/known_rep per-observer sorted canonical) / tiles(outpost_owner/level/farming/construction/關鍵 resource_cap) / world(tick/in_transit_letters/計數)。
   - ★排除：ephemeral 快取(food_runway/persist_strength recompute) / RNG state / probe-observer-tracer / phase-timing。
2. **`state_fingerprint_bed` harness** = 3 床（warring WarringHarness seeded / peaceful-economy / recovery-cohesion）× 3seed（含硬 seed 1337）× 3tick（240/1000/2400）= **27 fingerprint** → 落 `docs/measurements/fingerprint-baseline-<hash>.json`。
3. ★★**F0 自身驗收**（儀器不擾世界=禁耗 global RNG、第三度警戒 `feedback_observer_no_global_rng` LOD→RNG 犯過 2 次）：
   - ★**R² 觀察① 納入**：`compute()` 前後**直接讀 RNG call-count/state 斷言不變**（主、更快失敗好 debug）+ determinism 3-run byte-identical（輔）+ coin_eq 純讀不寫。
   - ★**R² 觀察② 納入**：**逐域確認真 exercise**（尤 envoy 建國提案/信使外交、檢查該域 fingerprint 欄位在 27 筆**真有變化非死值**、假覆蓋=安全網盲點 → 補床/seed 或明標未覆蓋）。

## 守 / 序
純讀 state 零寫 / 零 RNG / determinism / constitution 過閘（純讀 observer 合法、同 ObserverQueryApi read-only）/ headless 0-new（F0 harness 獨立 bed 不入正式 tick）。
完成 → handback `to:systems`（R²、merge-gate 核 StateFingerprint **零 RNG 消耗** + 涵蓋足 + 27 fingerprint 落地 + 假覆蓋檢）→ **F0 綠=安全網就位** → F1（threshold 死常數審）。地基 KEEP。
