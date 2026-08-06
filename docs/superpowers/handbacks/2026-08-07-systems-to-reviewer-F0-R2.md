---
from: systems
to: reviewer
status: consumed
topic: "[R² 審設計:F0 state-fingerprint 安全網 HOW(spec docs/superpowers/specs/2026-08-07-framework-F0-state-fingerprint-HOW.md)·框架收尾 program prerequisite slice(§2.2 硬規:無 F0 不動任何結構 slice)·F0=量測儀器非重構(建真重構安全網)·★R² 重點審:①涵蓋度足否=判準『足以攔結構 slice 引入的行為漂移類型』:StateFingerprint 涵蓋 teams(task/pos/resource/tags/faction)/persons(values/loyalty/skills/memory)/factions(goals/members/rep)/belief(team_intel/discovered)/tiles(outpost/farming/construction)/world——結構 slice 誤改任一 decision/lifecycle 結果是否必現 fingerprint diff?有無漏涵蓋的行為結果 state?②排除項正確否(ephemeral 快取 food_runway/persist_strength recompute/RNG state/probe—排除防噪、byte-identical run 內穩定但無資訊)③hash deterministic/order-stable(sorted-by-id+dict 顯式 sort+float 量化)——GDScript4 插入序陷阱防了否④scope 界定(3床 warring/peaceful/recovery-cohesion×3seed×3tick=27)是否 exercise 全 ~8 faction_ai 行為域(判準非數字大小、是覆蓋 threat/survival/faction-goals/side-dispatch/construction/outpost/relocate/envoy 全域+硬 seed+早中長 tick 漂移 onset)⑤★F0 不擾世界(禁耗 global RNG=觀測儀器不變量、同 HOB/tracer/coin_eq 前例):純讀 state、determinism 3-run+coin_eq 自驗——設計層有無 RNG 消耗/寫 state 風險?·序:CLEAN→build(StateFingerprint helper+state_fingerprint_bed harness+baseline 27 fingerprint)→F0 綠=安全網就位→F1 threshold 死常數審·地基 KEEP"
---

# R² 審設計：F0 state-fingerprint 安全網 HOW

spec：`docs/superpowers/specs/2026-08-07-framework-F0-state-fingerprint-HOW.md`。框架收尾 program **prerequisite slice**（§2.2 硬規：無 F0 不動任何結構 slice）。F0=量測儀器（建真重構安全網、非重構）。

## ★R² 審查重點
1. **涵蓋度足否**（判準=「足以攔結構 slice 引入的行為漂移類型」）：StateFingerprint 涵蓋 teams(task/pos/resource/tags/faction) / persons(values/loyalty/skills/memory) / factions(goals/members/rep) / belief(team_intel/discovered) / tiles(outpost/farming/construction) / world。結構 slice 誤改任一 decision/lifecycle 結果 → **必現 fingerprint diff**？**有無漏涵蓋的行為結果 state**？
2. **排除項正確否**（ephemeral 快取 food_runway/persist_strength recompute / RNG state / probe—排除防噪、byte-identical run 內穩定但無資訊）？
3. **hash deterministic/order-stable**（sorted-by-id + dict 顯式 sort + float 量化）——GDScript4 插入序陷阱防了否？
4. **scope 界定**（3 床 warring/peaceful/recovery-cohesion × 3seed × 3tick=27）是否 exercise 全 ~8 faction_ai 行為域（判準非數字大小、是覆蓋 threat/survival/faction-goals/side-dispatch/construction/outpost/relocate/envoy 全域 + 硬 seed + 早中長 tick 漂移 onset）？
5. ★**F0 不擾世界**（禁耗 global RNG=觀測儀器不變量、同 HOB/tracer/coin_eq 前例）：純讀 state、determinism 3-run + coin_eq 自驗——設計層有無 RNG 消耗/寫 state 風險？

## 序
CLEAN → build（StateFingerprint helper + state_fingerprint_bed harness + baseline 27 fingerprint）→ **F0 綠=安全網就位** → F1（threshold 死常數審）。地基 KEEP。
