# Spec：seam#3 sim_runner 系統 registry（near+far 雙分支→統一 loop，byte-identical 擴充）

> framework 做好 stream② seam#3（stream② 最後一 seam；#1 option registry / #2 facility registry 皆 merged）。北極星:加一個 per-team 系統=1 SYSTEMS entry（非改 near+far 兩分支）。
> **★前提先驗（2026-07-17 systems 逐 code，`sim_runner.gd:123-266`）坐實（非 stale）**：`_advance_tick_body` near 分支（`:183-228`）與 far 分支（`:238-261`）**兩近乎相同 step 序列**——far 複製 near ~18 共同步（vision/equip/strategic_move/move/messages/intel/market/interactions/faction_snapshot/ambush/resources/manufacture/consumption/salary/fatigue/faction_ai/training/strategic_ai/events/emit），差:team set（near_teams/far_teams）+ cadence（NEAR_CADENCE/FAR_ZONE_INTERVAL）+ far 跳項 + far 專屬。加 per-team 系統=改兩分支=擴充債。

## 根（結構已讀）
`_advance_tick_body`（`:123-266`）：
- **near 分支**（每 near-cadence，`:183-228`）：~20 `_stepN_*(state, near_teams[, NEAR_CADENCE])` + 交錯 `if phase_timing: _t=_pht("near.X",_t)` 分組 timing。
- **far 分支**（每 FAR_ZONE_INTERVAL，`:236-261`）：~18 `_stepN_*(state, far_teams[, FAR_ZONE_INTERVAL])`，尾單一 `_pht("far.total")`。
- **★near/far 異質（seam#1/#2 教訓:policy 捕特殊，勿硬併）**：
  - **far 跳（near-only，★R② 補全）**：`_step7_person_reactions`/`_step7b_npc_goal_cleanup`、`_step5a_regenerate_tiles`（near 全域每小時覆蓋 far tile，far 不重複=原 24× 雙記元凶）、`_step1a_forced_event`/`RecruitTutorial`、**`_step4b_outpost_tick(state)`（`:203`，R② 抓漏盤點——near interactions 後/faction_snapshot 前，far 無此呼叫=near-only；args_shape `(state)`）**。
  - **★R② premise 修正：`rebuild_team_tile_index()` = BOTH 非 far 專屬**：near `:191`（move 後，下游 co-location/hostile 查 post-move 位置）+ far `:242`（far move 後刷新）**兩分支各呼叫一次**（同型 post-move 步，非「far 才需」）。歸類 **BOTH-lod、registry 外顯式插在 move entry 後（near/far loop 各插一次）**。**★若漏 near :191=真行為回歸（下游讀 stale tile-index）**。
  - **cadence 參**：`_step2_move`/`_step5_collect`/`_step6_consume`/`_step6d_fatigue` 收 NEAR_CADENCE vs FAR_ZONE_INTERVAL。
  - **phase_timing 粒度**：near 分組 per-`_pht("near.X")`、far 僅 aggregate。
  - **tick 級單次**（非 per-team，registry 外保留）：`_step1_advance_time`、harvest（每 6h）、`_step_captives`/`_step_cleanup_extinct`（tick 末）、`_step1d_overflow`。

## 目標：SYSTEMS registry + 統一 lod loop
- **SYSTEMS registry**（ordered）：`SYSTEMS = [{name, fn, lod, cadence_ref, timing_label, args_shape}, ...]`：
  - `lod: NEAR|BOTH`——`BOTH`=near+far 都跑（~18 共同步）、`NEAR`=僅 near（reactions/cleanup/tile-regen/forced_event/tutorial/**outpost_tick**）。（無純 FAR-only per-team 步。）
  - `cadence_ref`：跑 near 時傳 NEAR_CADENCE、far 時傳 FAR_ZONE_INTERVAL（收 cadence 的步標記）。
  - `timing_label`：near 分組 `_pht` label（保觀測 byte-identical）。
- **統一 loop**：near 塊 `for sys in SYSTEMS where sys.lod in [NEAR,BOTH]: sys.fn(state, near_teams, near_cadence)` + 分組 timing；far 塊（cadence gate 內）`for sys where lod==BOTH: sys.fn(state, far_teams, far_cadence)`。**同序、同 team set、同 cadence 參、同 phase_timing**。
- **registry 外保留**（tick 級單次 + **BOTH rebuild_index 顯式插 move 後**）：明確 code 非 registry（seam#1/#2 教訓:特殊不硬塞泛型）。
- **★統一 loop 非平坦 for（R②②）**：因 rebuild_index 顯式夾在 move 群組中間 + near `_pht` 是**多步聚合組邊界**才 fire，loop 不能純 `for sys: sys.fn()`——需在 **move entry 後插顯式 checkpoint（rebuild + 條件 bookkeeping）+ 在各 timing group 最後 entry 後 fire `_pht`**。=registry 迭代 + 顯式群組 checkpoint 混合（非全平坦）。

## ★關鍵設計（byte-identical 風險，seam#2 schema 教訓）
- **step 順序精確**：near/far 各自的 `_stepN` 呼叫順序**逐一對照原碼**（registry entry 順序=原 near 順序；far 只跑 BOTH 子集，順序須與原 far 分支一致——確認 near/far 共同步順序本就相同，否則 registry 單一順序無法同時 byte-identical 兩分支=關鍵驗證點）。
- **★rebuild_team_tile_index = BOTH（R② 修正）**：near `:191` + far `:242` 各 move 後呼叫一次，registry 外顯式插 move entry 後（**兩 loop 各插**，非 far-only）。漏 near :191=真回歸。
- **phase_timing group 邊界**：near 的 `_pht` 是**多步聚合組**才 fire（`near.move`=strategic_move+move+rebuild+bookkeeping 共 4 段、`near.messages`=3 子步、`near.outpost_ambush`=outpost_tick+snapshot+ambush 3 步、economy/consume/strategic_ai/reactions/events_emit 同理各多步）→ `timing_label` 掛**該組最後 entry，跑完才 fire**；因 rebuild 顯式夾中間，需顯式 checkpoint（見上）。撞 [[feedback_full_transient_observability]]。
- **args_shape 異質（★R② 補第 4 型）**：`(state,teams,cadence)`/`(state,teams)`/`(state)`（`_step4b_outpost_tick`/`_step6e_strategic_ai`/`_step9_emit_messages`）+ **`(state,teams,time_mult)`**——vision（`:184/:238` 帶 `time_vision_mult`）、move（帶 `time_speed_mult`+cadence）多一個非 team/非 cadence 時間乘數參。registry `args_shape` 枚舉須含此型（或 time_mult 併入 args_shape 維度），near/far 皆傳同一全域 `time_*_mult`。

## 交付切片（TDD，byte-identical）
- **S1 SYSTEMS registry + 統一 near/far loop**：抽 ~18 BOTH 步 + near-only 步進 SYSTEMS，near/far 塊改 registry-driven loop。tick 級單次/far-rebuild 保 explicit。**byte-identical**（seeded 對照 near+far 全步輸出 + phase_timing label + Probe）。加 dummy BOTH 系統=1 entry 驗擴充。

## 非回歸
- **near/far step 順序 + team set + cadence 參 byte-identical**（seeded warring + game_sim 對照）。
- **far 跳項保**（reactions/tile-regen/tutorial 不在 far）。
- **觀測 byte-identical**（phase_timing label + Probe 計數，同 seam#1/#2）。
- **LOD 語意不變**（far 降頻批次、near 全速；本 slice 純重構 dispatch 結構非改 LOD 政策）。

## 閘
- **R② 必過**（tick loop 核心結構重構；標準同框 R²——無決策語意/收斂風險，純 dispatch 結構）。**重點審**：near/far 共同步順序是否真一致（單 registry 順序能否同時 byte-identical 兩分支）？phase_timing group 邊界是否 registry 可精確重現？far-rebuild-index 順序位置？
- premise 坐實（逐 code 讀 near/far 雙分支）→ R① 免。
- **measurer**：near+far byte-identical（seeded 對照 + phase_timing + Probe）+ 擴充 proof。同 seam#1/#2 中性複核法。

## 溯源
seam#1 S1（options registry，merged 5cfc2483）/ seam#2 S1（facility registry，merged f5fda115）pattern；`sim_runner.gd:123-266` near/far 雙分支；[[project_unification_matrix]] stream② seam#3；[[project_time_scale_wave]]（LOD/時間尺度）；seam#2 schema 教訓（異質用 policy 欄捕，勿硬併）。
