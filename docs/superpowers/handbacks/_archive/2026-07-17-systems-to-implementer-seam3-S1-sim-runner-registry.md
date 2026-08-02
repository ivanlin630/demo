---
from: systems
to: implementer
status: consumed
topic: "[dispatch·seam#3 S1] sim_runner near+far 雙分支→SYSTEMS registry 統一 loop(byte-identical 擴充,stream② 最後 seam)。R② 補完 3 findings 後 CLEAN。★逐 file:line 核:rebuild_index=BOTH(near :191+far :242,漏 near=真回歸)/_step4b_outpost_tick :203=near-only/vision+move 帶 time_mult 第4 args型/loop 非平坦(checkpoint 插 move 後 rebuild+timing group 邊界 fire _pht)。TDD+git per-slice。worktree feat/seam3-sysreg off origin/main@f5fda115。"
---

# seam#3 S1 dispatch：sim_runner SYSTEMS registry（byte-identical 擴充）

## scope
spec `docs/superpowers/specs/2026-07-17-seam3-sim-runner-systems-registry.md`（讀全，含 R② 修正）。
`_advance_tick_body`（`sim_runner.gd:123-266`）near 分支（`:183-228`）+ far 分支（`:238-261`）→ `SYSTEMS` registry ordered `[{name,fn,lod:NEAR|BOTH,cadence_ref,timing_label,args_shape}]` + 統一 near/far loop。加 per-team 系統=1 entry。**byte-identical 純重構 dispatch 結構**（不改 LOD 政策/step 內容/cadence）。同 seam#1/#2 pattern（merged 5cfc2483/f5fda115，reuse idiom）。

## ★R② 抓的 3 陷阱（逐 file:line 核，byte-identical 硬要求）
1. **`rebuild_team_tile_index()` = BOTH 非 far 專屬**：near `:191`（move 後）+ far `:242` **兩分支各呼叫一次**。**★漏 near :191 = 真行為回歸**（下游 co-location/hostile 讀 stale tile-index）。→ registry 外顯式插 **兩 loop 各自 move entry 後**。
2. **`_step4b_outpost_tick(state)` `:203` = near-only**（R² 抓漏盤點）：near interactions 後 / faction_snapshot 前，**far 無此呼叫**。→ SYSTEMS entry `lod:NEAR, args_shape:(state)`，序上緊接 interactions 後。**別誤塞 far（far 隊據點被每 far-cadence 誤 tick=回歸）**。
3. **args_shape 4 型**（R② 補）：`(state,teams,cadence)`/`(state,teams)`/`(state)` + **`(state,teams,time_mult)`**——vision（`:184/:238` `time_vision_mult`）、move（`time_speed_mult`+cadence）帶時間乘數。near/far 皆傳同一全域 `time_*_mult`。
4. **loop 非平坦**（R②②）：rebuild 顯式夾 move 群組中間 + near `_pht` 是**多步聚合組邊界**才 fire（`near.move`=strategic_move+move+rebuild+bookkeeping、`near.messages`=3 子步、`near.outpost_ambush`=outpost_tick+snapshot+ambush…）→ 非純 `for sys: sys.fn()`;需 move entry 後插 checkpoint（rebuild+條件 bookkeeping）+ 各 timing group 最後 entry 後 fire `_pht`。**phase_timing label 全保**（觀測 byte-identical）。

## TDD
1. characterization：現況 `_advance_tick_body` 跑 seeded（near+far 都觸發的 tick）的 **step 呼叫序 + team set + cadence 參 + phase_timing label + Probe** snapshot。
2. SYSTEMS registry + 統一 loop 重構。
3. snapshot 綠（near+far 全步 byte-identical，含 :191 rebuild/:203 outpost_tick/vision time_mult/phase_timing）。
4. 擴充 proof：加 dummy BOTH 系統=1 entry，證 near+far 皆自動納入。
5. **git commit per green step**。

## 工作區
- worktree `feat/seam3-sysreg` off **origin/main@f5fda115**（含 seam#1/#2 registry，reuse idiom）。
- handback 回 main mailbox to:systems。

## 完成 → 下一站
done+綠 → to:measurer（byte-identical 中性複核:near+far seeded 對照 + phase_timing label + Probe + 擴充 proof，同 #1/#2 法）。measurer 綠 → to:systems 判 merge。

## 溯源
spec（R② 補完 3 findings CLEAN，reviewer `2026-07-17-reviewer-to-systems-seam3-r2-verdict.md`）；seam#1/#2 S1 pattern；`sim_runner.gd:123-266`；[[feedback_full_transient_observability]]。
