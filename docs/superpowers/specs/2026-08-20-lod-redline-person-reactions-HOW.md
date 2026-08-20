# HOW spec：LOD 紅線修（個體反應層不再綁玩家位置）

date: 2026-08-20 ／ owner: systems ／ 溯源：measurer breed 分解意外發現 → systems 親驗 → blueprint 裁「LOD＝解析度非存在」
狀態：待 ①blueprint 一行裁（§6 的 (甲)）＋ ②R² → dispatch。**大考 HALT 至本修 merge**。
★SUPERSEDED(2026-08-21):near/far 分班+率補償機制已由「事件比例計算」新法取代(見 2026-08-20-event-proportional-compute-HOW);本檔=歷史紀錄勿依此操作。

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
- **`ratio = 10`（R②delta 已對抗驗證、維持原值）**：`FAR_ZONE_INTERVAL=100` ÷ `NEAR_CADENCE=10`。R② 主張 near pass 逐 tick 跑、ratio 應為 100 → **經逐字驗證為誤**：`_run_systems(near…)` 在 `sim_runner:274`、**縮排兩個 tab**＝落在 `:239` `if current_tick % NEAR_CADENCE == 0`（一個 tab）**之內**；`_step7_person_reactions` 全站**單一 call site**（registry `:156`）。`shape="teams"` 只決定「函式收不收 cadence 參數」，**不決定 pass 多久跑一次**——兩件事不同。
- ★**換算改「真·多次試驗」（採納 R② 第二必查項）**：**不用** `p_eff = 1-pow(1-p, ratio)` 單抽。理由：單抽在一個 far 窗內**結構性封頂為最多 1 次事件**，而 near 端同窗可產生最多 `ratio` 次（p=0.15、ratio=10 → near 每人每窗期望 1.5 次）→ 單抽 = 系統性低估，**即使 ratio 正確**。
  改為：**far pass 對該項跑 `ratio` 次獨立試驗**（`for i in range(ratio): if randf() < p: <照 near 端同一套後續處理，含團級 cap 檢查>`）。
  ★**「單抽」與 determinism 無關**（R② 指正、我接受）：多抽同樣 deterministic（同 seed 同序列可重現）；我先前把「省 RNG 筆數」這個**額外優化目標**寫成 determinism 要求，是錯的框。
  ★**團級 cap 必須在迴圈內逐次檢查**（`minor_population < cap`），否則多次試驗會突破 near 端本來會撞到的上限。
- **施用範圍＝只有 breed 一項（R② 親驗、spec 直接寫死、零判斷空間交下游）**：`ReactionSystem` 全檔 `randf()` **只有一處**（`:204` breed chance）；flee/riot/defect/shirk/extort/produce/expand 全走 `_score_*` **決定性算分 + argmax、零 RNG** → **不是機率、不需換算、也沒有誤判空間**。`cleanup_goals`（`npc_ai_system:181-196`）純狀態改寫、零 RNG。
- 施用點：`ReactionSystem.evaluate_all(state, teams, skill_sys, trials: int = 1)`，`trials = cadence / NEAR_CADENCE`（near 傳 1、far 傳 10）→ 只在 `_evaluate_life_events` 的 breed 試驗迴圈使用。
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
- **★blueprint 裁定（2026-08-20）＝(甲) 不做、只做 §2+§3**。理由（他的原話重點）：紅線原文＝「只准降解析度、不降真實」→ **遠頻跑但反應率等價＝憲法明文允許的低解析模式**，violation 已被 §2+§3 清乾淨；(甲)＝×10 節奏 + 全基線報廢 + 大考前重校 ＝ **為零憲法增益付巨價**。「headless 該最高解析度」若未來成為主張 ＝ 另案單獨排（現無需求：探針/統計已捕捉所需觀測）。
- ∴ **本 slice 範圍鎖定 §2+§3**，`_get_near_teams` **不動**。
