# F0 state-fingerprint 安全網 HOW（systems、框架收尾 prerequisite slice）

status: DRAFT（spec 自檢 → R²）
owner: systems（HOW）← program LOCKED `2026-08-07-framework-completion-two-hard-green-design.md` §2.2/F0
date: 2026-08-07
溯源：兩硬綠 program §2.2 硬規「純結構重構=行為保持、安全網=真 state-fingerprint、無 F0 不動任何結構 slice」。F0=量測儀器（非重構）。

## §1 目標
建**真 state-fingerprint 安全網**：純結構 slice（抽 decision chunk / 切模組）前後 fingerprint **三跑一致 + 多 seed×多床 regression 不變 = 真證「只搬位置」**（行為零漂移）。行為變更（①threshold 人格化）與結構搬移（②）分 slice 不混——F0 是②的驗收儀器。

## §2 StateFingerprint 儀器（結構化 hash、全 world-state、禁耗 RNG）
新 static helper `StateFingerprint`（純讀 state、deterministic hash、★零 global RNG=觀測儀器禁耗 RNG 不變量、同 HOB/tracer/coin_eq 前例）。

### §2.1 涵蓋範圍（★判準=足以攔結構 slice 引入的行為漂移類型、非只 coin）
結構 slice 若誤改任何 decision/lifecycle 結果 → 下列 state 某處變 → fingerprint diff。涵蓋 = **decision-and-lifecycle-affected state**：
| 域 | 欄位（canonical、sorted by id） |
|---|---|
| teams | id / population / minor_population / current_task / task_priority / task_reason / tile_pos / move_target / faction_id / parent_team_id / resources(sorted) / tags(sorted) / combat_target / outpost 關聯 |
| persons（decision 相關） | id / team_id / values(sorted) / loyalty / skills(sorted) / memory 條數+type-summary（非全 dump、防噪） |
| factions | id / leader_team_id / member_team_ids(sorted) / goals(sorted) / known-reputations 摘要 |
| belief | team_intel/team_discovered/known_reputations 結構摘要（per-observer sorted、涵蓋 provenance 關鍵欄非全 raw） |
| tiles（outpost/資源狀態） | outpost_owner / outpost_level / farming_level / construction 狀態 / 關鍵 resource_cap（decisions 讀的） |
| world | current_tick / in_transit_letters 摘要 / 關鍵計數 |
**★full canonical 優先於摘要（spec 自檢精化）**：hash 本身 collapse 任意 size 成定長 → 無需「摘要」省 size、full canonical dump（sorted/quantized）最大化 drift 偵測（純結構 slice 應 byte-identical→full 必同、摘要反漏 subtle drift）。persons memory/belief claims 亦 full canonical（type+key+tick+value sorted）。
**排除**（防噪、非行為結果、且 byte-identical run 內確定性穩定不影響但無資訊）：ephemeral 快取（food_runway/persist_strength=recompute）/ probe/observer/tracer state / phase-timing / RNG state 本身 / decision_eval_next_tick 類 cadence 排程欄（若純結構 slice 不動排程則穩定、含之無害但列明）。
★**涵蓋度判準**：exercise 全 ~8 faction_ai 行為域（threat/survival/faction-goals/side-dispatch/construction/outpost/relocate/envoy）——任一結構 slice 動任一域、行為漂移即現 fingerprint diff。

### §2.2 hash 法（deterministic、order-stable）
sorted-by-id 迭代 → canonical 欄位序列化 append buffer → stable hash（複用既有 determinism hash 機制/MD5-of-canonical-string）。dict 欄位 sort key 序（GDScript4 插入序不可靠→顯式 sort）。float 量化（避浮點噪，如 round to 1e-4）。→ byte-identical run 同 fingerprint、行為變即變。

## §3 regression 快照 harness（多 seed × 多床、scope 界定）
`state_fingerprint_bed`（headless）：跑 N seed × M 床 → 固定 tick checkpoint dump fingerprint → 落 `docs/measurements/fingerprint-baseline-<hash>.json`。
### §3.1 scope（★systems 界定、判準=覆蓋度足攔漂移類型、非任意數字）
- **床（M=3、覆蓋 ~8 域）**：①warring（WarringHarness seeded=threat/combat/diplomacy/survival 域）②peaceful-economy（production/trade/facility/outpost/公庫 域）③recovery/cohesion（side-dispatch/移民/投資/遷村/cohesion/relief 域）。三床合 exercise 全 faction_ai 行為域。
- **seed（N=3/床）**：behavior variety（含已知硬 seed 如 1337、[[reference_multi_sanity_unseeded]] warring 已 seed 化）。
- **tick checkpoint（3）**：240（day1、早期分岔）/1000（accumulation）/2400（長程漂移）。
- **合計 3床×3seed×3tick=27 fingerprint** = regression 快照集。★判準非數字大小、是「三床 exercise 全域 + 硬 seed + 早/中/長 tick」覆蓋漂移 onset/accumulation。
- ★**假覆蓋防（R² 觀察② 納入）**：build 時**逐域確認真被 exercise**（尤 envoy 建國提案/信使外交——warring diplomacy 或 recovery-cohesion side-dispatch 沾到但需明確）：檢查該域 fingerprint 欄位在 27 筆中**真有變化非死值**。某域從沒被真 exercise → 該域漂移偵測=假覆蓋（安全網盲點）→ 補床/seed/tick 或明確標該域未覆蓋。
### §3.2 regression 驗
結構 slice 後重跑 → 27 fingerprint 逐一對 baseline：全同=行為零漂移(只搬位置✓)、任一異=漂移(結構 slice 誤改行為、擋)。異需 explained（若①人格化 slice 則預期變、但①②分 slice 不混=②結構 slice 恆應全同）。

## §4 F0 自身驗收（儀器不擾世界=禁耗 RNG）
F0 是量測儀器非重構→用既有機制自驗**儀器不擾世界**：
- **determinism**：F0 fingerprint 計算開啟 → 3-run byte-identical（世界軌跡不變、fingerprint 計算零 RNG 消耗）。
- ★**直接 RNG 斷言（R² 觀察① 納入）**：`StateFingerprint.compute()` 前後直接讀 RNG call-count/state 斷言不變（比等軌跡分岔的間接症狀**更快失敗、好 debug**）。第三度 RNG 警戒（[[feedback_observer_no_global_rng]] LOD→RNG 犯過 2 次）→直接斷言為主、3-run 為輔。
- **coin_eq**：既有 coin 守恆回歸不變（F0 純讀不寫 state）。
- **headless 0-new**：F0 harness 不入正式 tick 路徑（獨立 bed）、headless 無新錯。
- constitution 過閘（F0 純讀、無新閘/無 god-view 寫—讀全 state 是 observer 合法、同 ObserverQueryApi god-view read-only 合法）。

## §5 序
F0 spec 自檢（本檔）→ R² → build（StateFingerprint helper + state_fingerprint_bed harness + baseline 27 fingerprint 落地）→ **F0 綠=安全網就位** → F1（threshold 死常數審、①硬綠首 slice）。**無 F0 綠不動任何結構 slice**（§2.2 硬規）。地基 KEEP。
