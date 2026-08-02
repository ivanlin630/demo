---
from: systems
to: reviewer
status: consumed
topic: "[R②·標準同框] seam#3 sim_runner near+far 雙分支→SYSTEMS registry 統一 loop(byte-identical 擴充,stream② 最後 seam)。premise 逐 code 坐實(near/far ~18 共同步重複)。重點審 byte-identical 風險:near/far 共同步順序真一致否(單 registry 順序能否同時 byte-identical 兩分支)/phase_timing group 邊界 registry 可重現否/far-rebuild-index 順序位置。CLEAN→dispatch S1。"
---

# R²：seam#3 sim_runner 系統 registry（byte-identical 擴充）

## 審什麼
spec `docs/superpowers/specs/2026-07-17-seam3-sim-runner-systems-registry.md`。
`_advance_tick_body`（`sim_runner.gd:123-266`）near 分支（`:183-228`）+ far 分支（`:238-261`）兩近乎相同 step 序列 → `SYSTEMS` registry（`{name,fn,lod:NEAR|BOTH,cadence_ref,timing_label,args_shape}`）+ 統一 near/far loop。加 per-team 系統=1 entry。**byte-identical 純重構 dispatch 結構**。同 seam#1/#2 pattern（merged 5cfc2483/f5fda115）。

## ★重點審（byte-identical 風險，seam#2 schema 教訓——A/C 拆分曾漏 apothecary×0.5/聚合異質）
1. **near/far 共同步順序真一致否**：spec 假設「registry entry 順序=near 順序，far 只跑 BOTH 子集且順序與原 far 一致」。**請逐一對照 `:183-228` vs `:238-261` 的 `_stepN` 呼叫順序**——若 near 與 far 的共同步順序有任何差異，單一 registry 順序**無法同時 byte-identical 兩分支**（=關鍵翻車點，同 seam#2 workshop/armorsmith 聚合異質）。
2. **phase_timing group 邊界**：near `_pht("near.X")` 在特定 step 群後 fire（非每步），far 僅 `_pht("far.total")`。registry 的 timing_label 能否精確重現 near 的分組邊界？漏一個 `_pht` = 觀測非 byte-identical（撞不變量）。
3. **far 專屬 `rebuild_team_tile_index()`**（`:242` move 後）：registry 外手插，順序位置對否？
4. **args_shape 異質**：step 收 `(state,teams,cadence)`/`(state,teams)`/`(state)` 三型——registry 依 args_shape 傳參，有無漏型？
5. **near-only 步**（reactions/tile-regen/tutorial/forced_event）標 lod:NEAR——確認這些真不該進 far（far 跳 reactions 是 LOD 政策非 bug）。

## 判準
- CLEAN → dispatch S1 implementer（byte-identical TDD，git per-slice，measurer 中性複核 near+far seeded 對照 + phase_timing + Probe + 擴充 proof，同 #1/#2 法）。
- 順序不一致 / timing 邊界無法重現 → halt 回 systems（file:line），或 spec 補 policy 欄（同 seam#2 schema 補完後直 dispatch）。

## 溯源
seam#1/#2 S1 registry merged；`sim_runner.gd:123-266`；[[project_unification_matrix]] stream② seam#3；[[project_time_scale_wave]]。
