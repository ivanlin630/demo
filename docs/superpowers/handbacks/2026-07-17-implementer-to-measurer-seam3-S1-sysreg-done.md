---
from: implementer
to: measurer
status: consumed
topic: "[seam#3 S1 交付] sim_runner near+far 雙分支 → SYSTEMS registry 統一 loop(byte-identical,stream② 最後 seam)。R② 4 陷阱全落實(rebuild=BOTH/outpost_tick=NEAR/args_shape 4 型/loop 非平坦)。branch feat/seam3-sysreg HEAD 1d370635 off origin/main f5fda115。四閘自驗綠(char 17-label 序同+擴充/warring total_diffs=0/game_sim 0 semantic diff/gate 72 removed=0),請中性全量複核。★perf flag:call() 動態派發熱路徑。"
---
# Hand Back：seam#3 S1 sim_runner SYSTEMS registry（byte-identical 純重構）

**branch** `feat/seam3-sysreg`（已 push）**HEAD `1d370635`**，off origin/main `f5fda115`（含 seam#1/#2 registry）。**stream② 最後一 seam**。

## 實作摘要
- `scripts/simulation/sim_runner.gd`：`_advance_tick_body` near 分支 + far 分支 → `SYSTEMS` static-var registry（ordered `{name, fn, lod, shape, tl}` ×24 entry）+ 統一 `_run_systems(state, teams, cadence, vmult, smult, is_near, t_in)` loop。加 per-team 系統=加 1 entry。
  - **lod**：`LOD_BOTH`(near+far 都跑,~20 共同步) / `LOD_NEAR`(僅 near:outpost_tick/regen/reactions/cleanup)。
  - **★near/far 共同步序本就相同**（逐 code 核，關鍵驗證點）→ 單 registry 順序同時 byte-identical 兩分支：near 跑 NEAR+BOTH、far 跑 BOTH（跳 NEAR entry），共同步相對序一致。
  - **tick 級單次**（advance_time/day_boundary/harvest/overflow/captives/cleanup_extinct）+ **forced_event near-prelude** 保 explicit（非 registry）。
- `scripts/debug/seam3_sysreg_test.gd`（新 char bed）：phase_timing label 序 + 擴充 proof。
- `_seam3_dummy_step`（test-support no-op `Probe.bump`，僅擴充測試 append entry 時觸發）。

## ★R② 4 陷阱逐一落實（byte-identical 硬要求）
1. **`rebuild_team_tile_index()` = BOTH**：move entry 後的 **checkpoint 對 near+far 都跑 rebuild**（原 near :191 + far :242 各一次）。漏 near=真回歸→已在 `_run_systems` move-shape 內顯式插（非 far-only）。
2. **`_step4b_outpost_tick` = NEAR-only**：`lod:LOD_NEAR`（far 跳過）；序上緊接 interactions 後（registry entry 位置）。far 隊據點不被每 far-cadence 誤 tick。
3. **args_shape 4 型**（含 R② 第4型 time_mult）：`vision(state,teams,vmult)`/`teams`/`teams_cadence`/`moved(state,moved,teams)`/`arrived(state,arrived)`/`state`/`regen(state,cadence)`/`move(state,teams,smult,cadence→Dict)`。near/far 皆傳同一全域 `time_*_mult`。
4. **loop 非平坦**：move entry 後顯式 checkpoint（rebuild + moved/arrived 抽取 + near-only player-clear）；phase_timing `_pht` 掛群組最後 entry、**僅 is_near fire**（far 無分組 _pht，尾單一 far.total explicit）；near-only glue（strategic_move 前 player_old capture / ambush 後 encounter-return / emit 後 RecruitTutorial）以 is_near+entry-name hook。

## byte-identical 四閘自驗（★皆 0 diff）
1. **char bed**：phase_timing **17-label 序完全相同**（day_boundary + near.forced_event…near.events_emit 12 + harvest/far.total/captives_cleanup），refactor 前後 identical（結構性、RNG-無關=觀測 byte-identical 主證）。擴充 proof：dummy BOTH 系統 near+far 皆執行（calls≥2）。
2. **seeded_warring_bed seed=1337 / 3 月**：pointwise metric diff = **`total_diffs=0`（逐點相同，零行為變）**（tick loop=全 sim，67 teams/全 probe identical）。
3. **game_sim_multi**：baseline vs refactor 逐行 diff = **12092 行相等，0 semantic diff**（唯一差異=`[TickPerf]` 牆鐘 µs）。
4. **constitution_gate**：**PASS sites=72 removed=0**（sim_runner 非 decision-file→無 threshold/early_return fingerprint；TaskArbiter 用法未動→taskarbiter fingerprint 不變）。
5. **full headless_test**：`=== DONE ===`；殘 3 assertion=pre-existing baseline（同名同行 15529/7075/13979，無新增無減少）。

## ★連動風險 / flag
- **★perf（給 measurer 特別驗）**：`_run_systems` 用 `call(fn, ...)` **動態字串派發** ×24 步 ×每 near/far tick——比原直接呼叫有 variant-call overhead。**tick loop=最熱路徑**，可能 per-tick µs 上升。game_sim TickPerf µs 範圍看似相近（未見明顯回歸）但 **wall-clock 非精確**——請 measurer HOB per-tick perf 對照（GODOT_TIMEOUT=600 雙 checkout 比，非撞絕對門檻，[[reference_hob_perf_protocol]]）確認可接受。若 regression 顯著→systems 裁（string→StringName cache / 直呼 fallback / 接受）。
- **test-support**：`_seam3_dummy_step`（no-op Probe.bump）留 production——擴充 proof 用，一般 sim 無此 entry 零觸發。
- **caller 零破**：`advance_tick`/`_advance_tick_body` 簽名不變。

## 下一站
- measurer：near+far byte-identical 中性複核（seeded 對照 + phase_timing label + Probe + 擴充 proof，同 #1/#2 法）+ **★perf 對照**。上述閘可直接複跑。
- 綠 → to:systems 判 merge（stream② seam 全收官）。我 hold warm 等裁決。

## 溯源
spec `docs/superpowers/specs/2026-07-17-seam3-sim-runner-systems-registry.md`（R② 補完 3 findings CLEAN）；dispatch `…seam3-S1-sim-runner-registry.md`；seam#1/#2 pattern（merged 5cfc2483/f5fda115）；`sim_runner.gd:123-266`；[[feedback_full_transient_observability]]；[[project_time_scale_wave]]（LOD）。
