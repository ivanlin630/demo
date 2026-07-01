# 後期 scaling 加固 P0 + tick 計時 + scaling bed — 設計 spec

> 系統 HOW spec。承藍圖 `anchor-probe-and-hardening` ③（平行 P0 加固，獨立經濟設計）。
> 依據評估 `specs/2026-07-01-late-game-scaling-assessment`。目標：長跑大 N 不爆、滅團潮 spike 收，為「終於看 emergence」鋪 perf 地基。
> **方法論 = measure-first 加固**：先做零行為變的安全大贏 + tick 計時 instrument → 量 tick-time vs N 曲線 → **再**決定要不要行為變的優化（別猜哪個主導）。

## 原則：安全優化優先、行為變優化 measure-gated
評估列 O(N²) 熱點多是「全世界掃、無空間索引」。**大部分可純優化收（零行為變）**：換 O(N) 線性掃為 O(1) 索引查。只有 faction AI honor-LOD 是行為變（far 決策頻率變）→ **留到 instrument 量到它仍主導才動**。

## A. tile→teams 共用空間索引（零行為變，最大安全贏）
評估 #A1/#A2/#A4/#A6 全是「掃全隊找某格上的隊」。**建一個共用 `tile_id → Array[team_id]` 索引**（複用既有 `sim_runner.gd:247 _step4e_faction_snapshot` 的 pos_map pattern，但提為 WorldState 級每-tick 維護的索引）。
- **落點**：`WorldState` 加 `teams_by_tile: Dictionary`（`tile_id → Array[int]`），在移動落地/erase 時單源維護（team 移動改格 = 從舊格 array 移除、入新格；erase = 移除）。或每 tick 開頭 rebuild（O(N) 一次 << 多次 O(N²) 掃）。**傾向每-tick rebuild**（簡單、單點、無雙向維護風險；O(N)/tick 遠低於現多個 O(N²)）。
- **改用點**（掃全隊 → 查索引）：
  - `faction_ai_system.gd:1455 _has_hostile_within`（#A1 主 O(N²)/hr）：查鄰格 teams 而非掃全隊。
  - `interaction_system.gd:49/74 process_on_arrival/move`（#A4 co-location）：查同格 teams。
  - `faction_ai_system.gd:399 _has_resident_team_on_tile` / `:407 _has_inflight_settler`（#A2）：查該 tile teams。
- **DoD**：三處改查索引、行為不變（同結果）、headless 回歸綠；索引每 tick 一致（加測：索引 vs 全掃結果相等）。

## B. team_intel prune 進 erase_team（零行為變，top memory leak 修）
評估 #B1：`erase_team`（`world_state.gd:123-162`）從不 prune `team_intel` → observer row + 死 target claims 永久累積。
- **改 `erase_team`**：加 `team_intel.erase(tid)`（清死 observer 整 row）+ 掃 `for obs in team_intel: team_intel[obs].erase(tid)`（清各 observer 對死 target 的 claims）。同既有 `team_discovered`/`known_reputations` 清理 pattern（同 chokepoint，緊鄰 `world_state.gd:154-157`）。
- **順修 nit**：`world_state.gd:157-158 team_known[obs].erase(tid)` no-op（array 存 MessageData 非 int）→ 移除死碼或改對（TTL 已覆蓋，低優先，plan 定）。
- **DoD**：erase 後 team_intel 無死 tid（加測：erase 隊後 `team_intel.has(tid)`=false + 無 observer 留其 claims）；決策讀 belief 不回歸；coin_eq/pop 守恆。

## C. #3 每-tick 計時 instrument（觀測地基）
- **落點**：`sim_runner.gd advance_tick`（64-188）包一層計時：記本 tick wall-time（`Time.get_ticks_usec()` 差）。
- **輸出**：per-tick 或聚合（每 N tick 印 avg/max tick-time + 當前 N/F/P）。避免每 tick print spam → 累積、週期 flush（如每日印「tick-time avg/max、teams、factions」）。
- **可選細分**：各大 step（faction AI / vision / interaction / consumption…）分段計時，找吃時間的 step（wrap `_step*` 呼叫）。**傾向先總 tick-time + 週期印**，分段 optional（plan 定，別過度）。
- **DoD**：長跑印得出 tick-time 曲線帶 tick/N；無 print spam（週期聚合）。

## D. scaling bed（大 N seed，驗 tick-time vs N）
- **新 `scripts/debug/scaling_bed.gd`**（或 warring_states 變體）：seed 大 N（如 100/200/400 隊階梯）+ **滅團潮場景**（飢荒/大征服觸發同 tick 多 erase → 驗 #A5 die-off spike）。
- **量**：tick-time vs N 曲線（該近線性；超線性=紅旗）；加固前後對照（同 seed）。
- **DoD**：跑得出 tick-time vs N（加固前 baseline + 加固後）；die-off tick 的 spike 有無收斂可見。

## E. （measure-gated，本 spec 不預先做）faction AI honor-LOD
- 評估 #A1 主 O(N²)/hr = `evaluate_all` 忽略傳入 subset、對全世界跑。**但 A 的空間索引先收掉 `_has_hostile_within` 的 O(N²) inner** → 可能已足。
- **instrument（C/D）量到 faction AI 仍主導 tick-time** 才動（honor subset / cadence-gate per-team 決策迴圈）。**行為變**（far 隊決策頻率降）→ 需驗世界行為不退化（意圖分布/建國率/戰爭不變）。**本 spec 標為條件 follow-up，別猜先做**。

## believability / 守恆 guard
- A/B/C/D 全**零行為變**（純優化 + 觀測 + 測床）→ 世界模擬結果不變、守恆不動。加固 = 同結果更快。
- 驗收硬閘：headless 全綠（PASS 數不降）、coin_eq delta=0、pop 守恆、InvariantAudit 0、warring seed 行為不變（意圖分布/probe 數同量級）。

## 檔案
- `scripts/data/world_state.gd`：`teams_by_tile` 索引（rebuild helper）+ `erase_team` 加 team_intel prune。
- `scripts/simulation/faction_ai_system.gd`：`_has_hostile_within`/`_has_resident_team_on_tile`/`_has_inflight_settler` 改查索引。
- `scripts/simulation/interaction_system.gd`：co-location 改查索引。
- `scripts/simulation/sim_runner.gd`：tick 計時 wrap + 週期聚合印;索引 rebuild 呼叫點。
- `scripts/debug/scaling_bed.gd`：新大 N + die-off bed。
- `scripts/debug/headless_test.gd`：索引一致性測 + erase team_intel prune 測。

## 風險 + 緩解
- **索引 rebuild 成本**（每 tick O(N)）：遠低於現多個 O(N²)；若 rebuild 本身顯著 → 改增量單源維護（移動/erase 時更新，plan 定；傾向先 rebuild 驗夠快）。
- **索引 vs 全掃結果不符**（漏維護）：加一致性測（索引查 == 全掃）擋回歸。
- **team_intel prune 誤刪活資料**：只刪死 tid（erase 時該隊真的沒了）→ 安全；測證決策 belief 不回歸。
- **分段計時過度**：先總 tick-time，分段 optional。
- **scope**：純 perf + 觀測 + 測床，**零碰經濟/決策/戰鬥邏輯**（honor-LOD 行為變留 E 條件 follow-up）。

## 開放細節（plan 定）
- 索引 rebuild vs 增量維護（傾向 rebuild 先，量夠快則留）。
- tick 計時輸出粒度（總 vs 分段;週期）。
- scaling bed N 階梯 + die-off 觸發法（複用 warring 飢荒/征服 or 專設）。
- team_known no-op nit 順修否。
