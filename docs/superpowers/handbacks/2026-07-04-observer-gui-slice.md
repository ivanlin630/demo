# Hand Back: 觀測 GUI 輕 slice（ticker + inspect + 速度 + god-view 地圖 + 截圖 harness）

> spec `2026-07-04-observer-gui-slice-design.md`。三件全上、品質 bar 走完、玩家路徑零 diff、RNG/行為零擾（seeded warring 逐點 diff=0 為證）。

## 實作摘要（每檔一行）

新檔：
- `scripts/simulation/observer_query_api.gd` — god-view read-only DTO 層（team_label/faction_label/query_all_teams/query_team/query_map_*），全 static 零寫入。
- `scripts/ui/observer_bridge.gd` — observer driver：tick_step frame 預算（12ms）攤 spike、LOD 錨點同 headless bed `(-1,-1)`、encounter>800 護欄 mirror WarringHarness、consume_messages 雙 channel origin_tick 水位穩定合併。
- `scripts/ui/observer_event_text.gd` — 人話 formatter：全 emit type 逐 type 走查（含新 4 型），leader 人名/隊名/勢力名/數字帶單位；未知 type fallback description。
- `scripts/ui/observer_ticker_panel.gd` — 事件 ticker：全量增量消費、選中隊過濾、歷史 500 條。
- `scripts/ui/observer_inspect_panel.gd` — 隊伍清單（名/pop/rung/task）→ 詳情（leader/pop 四分解/糧+日流/rung+archetype/faction/task+reason/solo_intent/readiness/fatigue/傷兵/位置）。
- `scripts/ui/observer_main.gd` — 根：seeded boot（同 WarringHarness RNG 流）、速度四檔（pause/1×=240tps/4×=960tps/max=預算內盡量）、月/日/tick 顯示、三方同步接線、截圖 harness。
- `scenes/ObserverMain.tscn` — main scene 不換；跑法 `.\tools\godot.ps1 res://scenes/ObserverMain.tscn`。

改檔：
- `scripts/simulation/message_system.gd` — TTL 表 +4 key；新 `emit_ambient`（見下 RNG 隔離設計）。
- `scripts/simulation/manpower_system.gd` — `[P1Assim]`/`[P1Revolt]`/`[P1Flee]` 三處 print 後 +emit（print 不動）。
- `scripts/simulation/npc_combat_system.gd` — `[P1Absorb]`/`[Capture]` 兩處 +`captives_taken` emit。
- `scripts/data/world_state.gd` — +`observer_messages: Array`（獨立 channel，見下）。
- `scripts/ui/world_map_view.gd` — observer 分支（無迷霧、archetype 填色+faction 環、outpost 方標、click pick 同格循環、follow camera）；player 分支零行為變（`_observer` guard）。
- `scripts/debug/headless_test.gd` — +3 測（ambient 隔離/query+bridge/formatter）。

## 與 spec 的差異（3 件，全有因）

1. **emit_ambient 不進 global_messages / team_known，走新 `state.observer_messages` channel**。spec 原文「ticker 吃 global_messages」。實測（seeded warring 逐點 diff）發現兩條擾動路：
   - `order_system.gd:25` 借 `global_messages.size()` 當 order_id 空間 → 任何 append 位移 oid 流 → 訂單去重/履約行為真變（diff 抓到 2/3 seed 70 處）。
   - `team_known` 進 `_exchange_one_way` 逐訊息 `_decide_propagation_mode` randf → RNG 流擾動。
   改獨立 append-only channel 後 **total_diffs=0**。ticker consume 合併雙 channel（既有型別照吃 global_messages），觀測功能等價。副作用：新 4 型事件不進 intel 傳播（觀測用途，spec 本意即 ticker 拿得到）。
2. **速度控制自建於 observer_main，未改 `turn_controls.gd`**。復用其節流 pattern（timer+carry）非其檔——避免雙模式分支污染 dormant player GUI 檔。
3. **`observer_query_api.gd` 放 `scripts/simulation/`**（與 player_query_api 同層=DTO 層歸屬）；spec 檔案清單把它列在 ui/ 一串裡。

## 品質 bar 驗證（spec 驗收逐條）

1. 回歸：headless `=== DONE ===`＋僅 1 pre-existing FAIL（弱目標未加入攻擊 goal）＋`seeded warring reproducible OK` final 原值（teams=47/factions=8/established=1/pop=380/probe_capture=0）；framework PASS=7 DORMANT=0；seeded_warring_bed 對 baseline 逐點 `total_diffs=0`（seeds 1337/42/7）。
2. 三件：ticker 中文成句無 probe dump（截圖）；隊過濾走真同步 path（--obs-select 截圖驗）；inspect 欄位齊+地圖同步；速度四檔+月/日/tick 顯示。
3. bar 場景：seed 1337 + 2674 各 6 月 max 跑滿不崩無 SCRIPT ERROR；狼弧事件鏈 ticker 過濾下成可讀故事（`張忠隊(10) 收服陳智隊(3)→俘獲部眾1人→俘虜趁隙逃亡→向許忠隊(51)宣戰→擊潰→收服納入勢力8`，見 assets t7200 特寫；inspect 同步顯示俘虜欄）。
4. 截圖 assets：`docs/superpowers/handbacks/assets/2026-07-04-observer-gui-slice/`（6 張精選：早期地圖、狼弧過濾特寫×2、1337 月4/月7 終局、2674 終局）；全量 15 張在工作樹 `shots/`（未 commit）。

## cadence hitch 實測（Task 4 裁決）

- seed 1337 6 月 max：4323 frames、over150=5；seed 2674：4333 frames、over150=6。
- **量測 caveat**：`_process` delta 被 Godot clamp 在 150ms → hitch_max 讀值恆 150ms，真幅度不可見（spec 已知單 tick spike ~294ms 可能就是這 5-6 幀）。頻率 = **偶發（≈1 次/月）非常態** → 依 spec 裁決規則**收**，far.total top violator 不在本 slice 動（動 sim=RNG 擾動風險）。
- 另註：seed 1337 六月 wall time 超 400s（seed 2674 ~100s）——後期戰事重、單 tick 均價高；frame 預算有效攤平（無凍結），只反映 max 速吞吐。

## 連動風險

- `world_map_view.gd`：player 分支加了 `_observer` guard 分流；Main.tscn（dormant 圖形套件）行為未動，但該檔今後雙用途——動 player 繪製時注意 observer 分支。
- `observer_messages` 無 TTL prune（cap 2000 裁尾）；sim 零讀 → 無行為風險，僅記憶體上界。
- 新 emit 落點在 manpower/npc_combat 熱路徑：emit_ambient 純 append 零 RNG，但**未來有人把它改回進 team_known/global_messages 就會擾流**——檔內註解已標死因。
- 矩陣平行軌：本 slice 未碰 `interaction_system.gd`/RelationGraph/belief ✓；`manpower_system.gd`/`npc_combat_system.gd` 有 +emit（與 F-I2/F-I4/F-I5 軌無重疊預期）。

## 觀測中發現（純觀測揭露，sim 未動，供 known_issues 候選）

- **beast pseudo-team 走人類系統**：ticker 可見獸隊（id -1000000 段）張貼收購武器訂單、對人宣戰訊息帶隊名——order_system `tick_team_orders`/message 未排除 `beast_kind != ""` 隊。另 beast 隊 leader_id=-1 → 繼承安全網是否會給獸隊晉升人名 leader 值得驗（截圖見「呂海隊(-1000000)」）。UI 層已改標示「X(獸)」，sim 側未動。
- MAX 速下 ticker label 用消費時 state → 事件主已滅團顯示「隊N(已滅)」＝誠實但可讀性小傷（1×/4× 幾乎不見）。
- 同 tick 雙 channel 事件排序：穩定合併 global 先 → 「收服」顯示先於同 tick「俘獲」（code 時序相反）。同日戳，可讀性無傷；要嚴格時序需 per-tick 序號（未做）。

## 待主 session 確認

- `observer_messages` channel 設計（spec 差異 1）是否收編 invariants（「global_messages.size() = order_id 空間，禁外部 append」值得立矛盾警示）。
- beast pseudo-team 洩入訂單/訊息系統（上節）是否開 known_issues 項。
- 隊過濾互動驗證天花板：截圖 harness 用 --obs-select 走真同步 code path 驗；滑鼠點擊 pick 的 fidelity 依 [[reference_screenshot_harness]] 屬真人玩測範圍。
