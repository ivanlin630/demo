# HOW spec：LOD 紅線修（個體反應層不再綁玩家位置）

date: 2026-08-20 ／ owner: systems ／ 溯源：measurer breed 分解意外發現 → systems 親驗 → blueprint 裁「LOD＝解析度非存在」
狀態：待 ①blueprint 一行裁（§6 的 (甲)）＋ ②R² → dispatch。**大考 HALT 至本修 merge**。

## §1 前提（file:line、範圍已自糾）
- `sim_runner` SYSTEMS：`reactions`(`:156`)／`cleanup`(`:157`) ＝ `lod=LOD_NEAR` **且 `shape="teams"`**。
- near 判定 `_get_near_teams:508`＝`_hex_distance(team.tile_pos, player_pos) <= LOD_NEAR_RADIUS(3)`；headless 傳 `(-1,-1)` → 全隊 far。
- `_run_systems:171`：`LOD_NEAR and not is_near → continue`。
- ∴ **無玩家＝全世界零個體反應；有玩家＝遠隊零個體反應**（生育 `P5_breed`／逃／暴動／叛／怠工／士氣／`goal_alignment`／npc goal cleanup）。
- **實證**：measurer peaceful seed1337 25 天 `breedgate.calls=0`、11/11 隊 `minor=0`、零 `[PopMgmt]`。
- ★**範圍限定（同日自糾）**：`outpost_tick`(shape=state：建設/鑄幣/馬廄)、`regen`(shape=regen：tile 再生) **不碰 teams 陣列、照常執行** → **不在本 slice 範圍**。

## §2 T1（核心）：`reactions` / `cleanup` 改 `LOD_BOTH`
遠隊在 far pass（每 `FAR_ZONE_INTERVAL=100` tick）也跑個體反應 ＝ **降解析度、不降真實**（紅線相容）。

## §3 T2（★決定成敗）：機率按 cadence 換算，否則「降解析度」變成「降真實」
far pass 頻率是 near 的 **1/10**（`FAR_ZONE_INTERVAL=100` vs `NEAR_CADENCE=10`）。若原樣搬過去，遠隊的生育/暴動/逃亡**期望率直接掉到 1/10** ＝ 違反紅線（那正是「凍結的緩速版」）。
- **換算式**：`p_eff = 1.0 - pow(1.0 - p, ratio)`，`ratio = cadence / NEAR_CADENCE`（本例 far=10）。**數學上等價於「該窗內 ratio 次獨立試驗至少發生一次」**，且**只抽一次 randf**（determinism 友善、不增 RNG 消耗筆數）。
- 施用點：`ReactionSystem.evaluate_all(state, teams, skill_sys, cadence)` 新增 cadence 參數 → `_evaluate_life_events` 的 breed chance、`_evaluate_person` 內各機率型反應。**非機率型（門檻/狀態判定）不換算**（它們是狀態讀取、不是每 tick 抽獎）。
- ★**要 implementer 逐一分類**並在 handback 列表：哪些是「每次呼叫抽獎」（要換算）、哪些是「狀態門檻」（不換算）。分類錯＝遠隊行為率錯。
- ★**`GOAL_CHECK_INTERVAL` 對齊＝systems 已親驗、無需處理**：`reaction_system:3` `GOAL_CHECK_INTERVAL = 10 × TICKS_PER_HOUR = 100` **恰等於** `FAR_ZONE_INTERVAL=100` → far pass（`tick%100==0`）**每次都落在 goal-check tick 上**；且 near 隊雖每 10 tick 跑一次 reactions，goal check 也只在 `tick%100==0` fire → **兩者 goal-check 頻率本來就相同**，不需換算、不需改判準。（記錄此驗證是因為若哪天有人動 `NEAR_CADENCE`/`FAR_ZONE_INTERVAL`/`GOAL_CHECK_INTERVAL` 任一，這個巧合對齊會無聲失效。）

## §4 determinism / fp
遠隊現在會跑反應 → **RNG 消耗筆數與順序改變** → **fp intended-change**（世界真的不同了：這正是修的目的）。det 三跑 byte-identical 仍必須成立。

## §5 gate
1. ★**rate-equivalence（本 slice 的靈魂）**：同條件下，**far 隊長窗（≥30 天）累積的 breed／反應次數 ≈ near 隊**（±tolerance，取樣夠大）。**這條綠才叫「降解析度不降真實」**；只證「有 fire」不夠。
2. headless（無玩家）`reaction.breed` / `breedgate.calls` **> 0**、`[PopMgmt]` 出現、`minor_population` 不再全 0。
3. det 三跑 byte-identical；constitution ≤75；headless 0-new；fp intended-change。
4. ★**perf 實測必附**：全隊都跑反應 ＝ 新增成本。量 per-tick 前後差（`[TickPerf]` 即可），**照實報**——若成本大，那是 blueprint 已接受的紅線代價，但**數字要在檯面上**（近期 perf 五路的教訓：不准把成本藏在「反正修對了」底下）。

## §6 ★待 blueprint 一行裁：(甲)「無玩家→全隊視為 near」要不要做
blueprint ① 裁了 (甲)。**但我實作前發現一個 WHAT 級後果，他當時看不到**：
- 今天的 headless 世界＝**全隊走 far pass**（每 100 tick 一輪決策/移動）。
- 若改「無玩家→全隊 near」，變成每 **10** tick 一輪 → **世界思考/行動頻率 ×10**、`sim_runner:109` 自警的「改世界節奏、需配 gen 重校」正是此事 → **既有全部 headless 基線（含 accepted cost、所有 organic 量測）一次全部失效**，且大考的 scaling 量測基準也跟著變。
- ★**而 §2+§3 本身已經解決紅線違憲**（世界的存在不再綁玩家；無玩家時全隊走 far pass，個體反應照跑、率等價）。
- ∴ **我建議 (甲) 不做**（至少不在本 slice）：它不是紅線的必要條件，卻要付「全部基線重來 + 世界節奏改變」的代價。若你要的是「無玩家時世界該以最高解析度跑」這個**願景主張**，那是另一個獨立決定，值得單獨排期與重校。
- **需要你一行裁**：(甲) 照做／(甲) 不做，只做 §2+§3／(甲) 另案。
