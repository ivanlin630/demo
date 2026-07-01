# 後期 scaling / 卡死評估（沙盒 bar 長跑要求）

> 系統評估報告（藍圖 `granary-fix-plus-observability-perf` #4）。碼審雙 investigator（compute O(N²) + memory 無界增長）綜合。
> 問題：世界長跑越大 → per-tick 成本超線性 → late-game tick-time 爆 → **等的 emergent 大戲永遠跑不到**。
> N=活隊數、F=派系、T=tile、P=person、D=每隊 discovered 集(隨 N 長)。

## 一句話結論
**LOD infra 存在且正確**（movement/economy 吃 NEAR/FAR subset），**但最重的認知系統 defeat LOD**——faction AI 直接忽略傳入的 subset、對全世界跑 O(N²)/小時。late-game 會爆，但**非需重寫**：修 = 讓重系統 honor 已有 LOD + 加 tile→teams 空間索引 + erase-prune。

## A. Compute — 超線性熱點（排序）

| # | 位置 | 成本 | cadence | 病灶 |
|---|---|---|---|---|
| **1** | `faction_ai_system.gd:513 evaluate_all` → `_has_hostile_within:1455` | **O(N²)** | **每小時** | ★`evaluate_all(_team_ids)` 的 LOD 參數被 `_` 忽略 → 對全 `state.teams` 跑;每隊 `_has_hostile_within` 掃全隊、無空間索引 = 主 O(N²)/hr |
| **2** | `faction_ai_system.gd:419 _evaluate_outpost_residency` | **O(N·T)→O(N²)** | 每小時 | 每隊掃全 tile;`_has_resident_team_on_tile:399`/`_has_inflight_settler:407` 每 owned tile 再掃全隊 |
| **3** | `vision_system.gd:22 tick_discovery` | O(\|obs\|·N)→**O(N²)** | FAR 100t | inner `for other_id in state.teams` 全 N,NEAR observer 仍測每 FAR 隊(內圈未 LOD-gate) |
| **4** | `interaction_system.gd:74 process_on_move` | **O(N²)** 群聚時 | 每小時 | co-location 靠全隊掃找同格,無 tile→teams 索引(**修 pattern 已存**:`sim_runner.gd:247` pos_map) |
| **5** | `world_state.gd:123 erase_team` | O(N)/erase → **O(K·N)≈O(N²)** | 每 tick × cleanup | 3× 全隊/registry ref-sweep;**die-off cascade(K erase/tick)= late-game 崩塌直接放大器 = 最可能卡死觸發** |
| 6 | `outpost_system.gd:168 tick_all` | O(T+outposts·N) | 每小時 | 全 tile + 每產出 tile residency 掃全隊 |
| 7 | `strategic_ai_system.gd:242 _find_trade_partner` O(D·T·N) / `faction_ai:2254 _evaluate_infrastructure` O(F·T·N) | 最高次冪 | 100t/500t | cadence 擋著,raw 成本高 |
| 8 | `belief_system.gd:188 _cap_observer` + N·D 掃 pattern | O(N·D) 聚合 | 決策掃 | 每對有 cap,但 D 隨 N 長 → 聚合超線性 |

**核心病**:NEAR/FAR LOD 正確擋 movement/economy,但 faction AI(`evaluate_all` 忽略 LOD 參)/vision/interaction/outpost residency/extinction cleanup 全**做全世界 O(N)-inner 掃、多數每小時** → O(N²)、O(N·T)/hr 隨 N/T 無界。die-off 經 `erase_team` O(N) sweep 複合 = late-game tick-time 爆的最可能觸發。

## B. Memory — 無界增長（排序）

| # | 結構 | 成長 | 既有界? | 病灶 |
|---|---|---|---|---|
| **1** | `world_state.gd:17 team_intel[obs][tgt]` | **O(世界年齡無界)** | per-obs 200 claim cap ✓ / **observer row ✗** | ★`erase_team`(123-162)**從不 prune team_intel** → 每個曾存在的隊留永久 observer dict + 死 target claim rows。高 churn 長跑主 leak |
| 2 | `world_state.gd:53 player_alerts` | 無界(headless) | UI poll drain ✓ / 無 poll ✗ | diplomatic alert 未 dedup;真 UI 排掉、AI-only sim leak |
| 3 | `person_data.gd:54 memory` | 隨年齡/person | `MEMORY_MAX=20` 但只 `write_memory` 路徑 | `reaction:369`/diplomacy/trade/command append **繞過 `_trim_memory`** → 可超 20 |
| 4 | `person_data.gd:62 relation_edges` | 半無界/長命 leader | per-target dedup ✓ / 死 target 不 prune | 只 person 死才釋放。低險 |
| — | 其餘（known_reputations/team_discovered/messages/captive/faction dicts/anon_cohorts/encounter_log）| — | **全有 cap/TTL/erase-prune ✓** | 界住,低險 |

**correctness nit**:`world_state.gd:157-158 team_known[obs].erase(tid)` 是 no-op(array 存 MessageData 非 int)→ 意圖的跨 registry cleanup 沒真跑;無害(TTL 覆蓋)但該修對。

## C. late-game 投影
- **食物太鬆(granary cadence bug)→ 世界長更大 → N↑ → O(N²) 打更重**。granary 修(食物收緊)會壓 N → 間接緩 scaling。兩問題耦合。
- **die-off cascade 最危**:大滅團潮(飢荒/征服)同 tick 多 erase → `erase_team` O(K·N) → tick-time spike → 可能表現為「卡死」。這也是沙盒最想看的大戲時刻 → 偏偏最會爆。
- team_intel leak:長跑高 churn → observer rows 單調累積 → 每次決策掃 observer 都付死 row 成本 + 記憶體漲。

## D. 加固建議（非重寫,targeted）
**P0（最大 bang、單點/複用既有）**：
1. **faction AI honor LOD**:`evaluate_all` 停止忽略 subset(或 `_has_hostile_within` 改吃 tile→teams 索引)→ 殺主 O(N²)/hr。
2. **tile→teams 空間索引**(複用 `sim_runner.gd:247` pos_map pattern，做成共用):interaction co-location(#A4)/`_has_hostile_within`(#A1)/residency(#A2)一次收多個 O(N²)→O(N)。
3. **team_intel prune 進 erase_team**(#B1 top leak,同我剛修 create_faction 的 chokepoint):erase 時 `team_intel.erase(tid)` + 掃 observer 清死 target row。

**P1**：vision inner loop LOD-gate(#A3);die-off `erase_team` batch/索引化(#A5,靠 P0.2 空間索引大緩)。

**P2（低險、小修）**：player_alerts headless drain(#B2)、memory trim 路徑統一走 `_trim_memory`(#B3)、team_known no-op cleanup 修(nit)。

## E. 驗證手段（配 #2/#3 探針）
- **每-tick 計時**(#3):tick-time log 帶 tick 數 → 看 tick-time vs N 曲線(該 flat/線性,超線性=紅旗)。
- **scaling bed**:大 N seed(200+ 隊)+ die-off 場景,量 tick-time 隨 N;加固前後對照。
- process 探針(#2):die-off tick 的 erase 數 + tick-time spike 關聯。

## 待藍圖
scaling **會爆**(O(N²)/hr faction AI + O(N²) die-off cleanup + team_intel leak),沙盒長跑前**須加固**(否則大戲跑不到)。但非重寫——P0 三項 targeted(honor-LOD + 空間索引 + erase-prune)收大部分。**排序建議**:granary(定世界規模)→ 加固 P0(配 #2/#3 探針/計時一起,scaling bed 驗)→ 長跑觀 emergence。要開加固 slice 否 + 序在 granary 前後?
