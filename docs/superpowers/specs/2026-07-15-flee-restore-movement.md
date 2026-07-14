# Spec：恢復 flee 位移（FLEE no-op 根治）

status: draft（待 R² → dispatch implementer）
owner: systems
premise_verified: ★file:line 坐實——FLEE 全域無位移計算（`options.gd:188` target(-1,-1) / `movement:82-84` no-target skip / `faction_ai:445-447` 假註解 / grep 無 flee-dir）；full-HD 觀察血證 Team1 128 天原地逃 3080 churn
blueprint_confirm: `2026-07-15-blueprint-to-systems-flee-reframe-confirmed.md`（認同 reframe：真根=dead flee-movement 非缺鎖；治根=恢復遠離位移用 belief_pos；執行鎖=治症第2次）
governing: `invariants.md §感知鐵律`（flee 讀 threat belief 非活值）+ 決策模型（有終點=威脅解非硬 lock）

## 根因（code-verified，dead-code 病，序1 wave-dissolution 遺留）
FLEE = **no-op task**：設 `current_task=FLEE` + `move_target=(-1,-1)` → mover `movement:82-84` 跳過 no-target → **隊永不移動** → 威脅相對位置凍 → `threat_react` 凍（15 位相同）→ 每次 re-eval FLEE 都贏 → 128 天原地「逃」（Team1 3080 re-commit=75% 人生 churn，撐起 aggregate `N1_flee` 虛高大半）。
- `options.gd:188` `"survival": return {task: TASK_FLEE, target: (-1,-1)}`。
- `faction_ai:445-447` 註解**謊稱**「_flee_target 已溶入引擎、FLEE target 由 mover 算」——序1 刪了 `_flee_target`、**mover 不算**、無替代。
- 全域 grep 無 flee 方向/away-vector/遠離威脅 計算。

## ★治根非治症（blueprint 認同）
- **加執行鎖 = 治症**：隊仍卡原地永逃（threat 永不解），只 log 節流 churn，aggregate 仍虛高（換靜默虛高）。第 2 次治症（[[feedback_symptom_vs_root_retry]]）。
- **治根 = 恢復 flee 位移**：隊真逃遠 → threat 距離衰減 → `ThreatAssessment.score < THREAT_BASE_THRESHOLD` → `_has_active_threat`(:436-443) false → `_evaluate_threat`(:384) release → **威脅解=自然有終點**（非硬 lock 切）。fix 自完成。

## Fix

### Fix 1：恢復 flee-direction 位移（核心）
FLEE 隊要有真 `move_target` = **遠離威脅 belief 位的可達 tile**。
- **新欄** `TeamData.flee_from_pos: Vector2i = (-1,-1)`（逃離的威脅 belief 位）。
- **dispatch 時設**：FLEE 派出（`_evaluate_threat` 及 unified/solo/survival 路徑選 FLEE）→ 若 `ctx.threat_id != -1` → `team.flee_from_pos = BeliefSystem.belief_pos(state, team.team_id, ctx.threat_id)`（★感知鐵律：讀 belief 非活值，god-view 已提供 belief_pos）。belief_pos 回 (-1,-1)（無情報/過期）→ flee_from_pos 保 (-1,-1)（無威脅可逃離 = 下方 release）。
- **mover 算 away-target**（restore「mover 算」使假註解成真，單一計算點）：`movement_system` 對 `task==FLEE` 且（`move_target==(-1,-1)` 或已到達）→ 若 `flee_from_pos != (-1,-1)`：算**反向 away-tile**——從 `team.tile_pos` 朝遠離 `flee_from_pos` 方向、`FLEE_STEP` hex 的**可達** tile（clamp 地圖邊界；若自家 outpost 在遠離側則優先逃向 home=「逃回家」）。設 `move_target`。
  - `flee_from_pos==(-1,-1)`（無威脅情報）→ 不設 target（無處可逃離）→ 靠 release 收（threat 已不明=不該續逃）。
- **`_helper _flee_away_tile(state, team, from_pos) -> Vector2i`**（純幾何+可達，零 RNG）。

### Fix 2：release 路徑（多在已存在，補齊）
- `_has_active_threat`(:436-443) 距離衰減後 false → `_evaluate_threat:384` release（已存在，恢復位移後真觸得到）。
- `FLEE_TIMEOUT`(5天,:97) 小地圖逃不掉的保險（已存在）。
- **release 時清 `flee_from_pos=(-1,-1)`**（`TaskArbiter.release` 或 flee 退場點補；避 stale 逃離位殘留）。

### Fix 3：修假註解
`faction_ai:445-447` 改寫——`_flee_target` 恢復為 mover 的 `_flee_away_tile`（別再留「mover 算」但實際不算的謊）。

## 邊界（別 tune 掉真戲，blueprint 令）
- 只治 flee 位移。**不碰**內政/經濟。
- Team0 全程、Team1 前半（貿易→掠奪→戰損死）是好戲，aggregate 對應數字別動——本刀只讓「逃」真的逃。
- **不加執行鎖**（治症）。terminal 靠威脅解自然湧現。

## invariant 守
- **感知鐵律**：flee 讀 threat `belief_pos`（非活值）——斷視線後朝「最後已知威脅位」反向逃（可能逃錯方向=合理迷霧，非 god-view 精準避）。
- **determinism**：`_flee_away_tile` 純幾何+可達，**零 randf**。驗收＝同 seed 兩跑 bit-identical（**非** baseline byte-identical——flee 真移動=行為本就該變）。
- **憲法**：flee move_target 來源改（既有 FLEE dispatch 路徑），零新 try_set。

## 附帶（次要 follow-up，非本刀核心，記 known_issues）
- **tracer unified/solo capture 虛高**：`_decide_unified:1537`/`_evaluate_solo:1876` `capture_decision` 在 try_set **前**、預設 `"committed"`（self-replace/被擋也記 committed）→ 3080 部分虛高。tracer-completeness 只補 survival(3217)。**tracer-completeness follow-up**（挪 tap 到 try_set 後帶真 result，鏡射 survival loop）——非本刀（本刀治 flee 行為，tracer 精度另軌）。

## 驗收（★中性 full-HD + 故事 QA）
1. **★flee 真逃**：FLEE 隊 `tile_pos` 真變動（遠離威脅），非原地凍。
2. **★churn 消**：Team1 式「同決策 re-commit 數千次」消——逃遠→threat 解→FLEE release→轉別的（有終點）。
3. **★N1_flee aggregate 回落**（中性 full-HD 重跑）：回落幅度=衡量此 bug 佔 aggregate 多少（blueprint 要的數字）。
4. **故事連貫**：逃跑隊一生＝逃→到安全/威脅解→轉別的，非終身 churn（全生命 specimen 判，修好 tracer）。
5. **不誤傷真戲**：Team0/Team1 前半好戲數字不動。
6. **無回歸**：同 seed 兩跑 bit-identical；憲法 sites=29；headless 零新增。
7. **中性世界判**。

## dispatch 註
- 新分支 `feat/flee-restore-movement`，base 最新 main。
- **R②**：dispatch 前 to:reviewer 審設計（away-tile 幾何/belief_pos 感知鐵律/release 自完成/flee_from_pos 生命週期/determinism）。premise 已 file:line 坐實 → 免 R① factcheck。
- 完成判定 = systems + reviewer + measurer（中性 full-HD：flee 真逃 + N1_flee 回落 + 故事連貫）+ blueprint 批。
- TDD：構「FLEE 隊+威脅」斷言 tile_pos 遠離；「逃遠後」斷言 threat<threshold→release；「無 belief 威脅」斷言不亂逃；「同 seed 兩跑」bit-identical。
