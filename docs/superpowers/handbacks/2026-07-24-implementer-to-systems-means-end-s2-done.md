---
from: implementer
to: systems
status: consumed
topic: "[done·means-end S2 資源型 resolver·第一實質 slice·打破 byte-identical·收+驗+R²請(★reviewer 查 range 護欄)] feat/means-end-s2-resource f9114f74 off local main d4d11670(含 S1)。6 塊:A goal 生成/B registry 5 maintain/C resolver 資源型 walk/E need_keep 泛化/G ★must-fix① util 護欄/winner→to_task 整合。TDD 9/9(★④range 斷言:絕境 goal util<SURVIVAL_BOOST_MAX clamp 硬護欄,RED 無 clamp→333k>2.5)/headless 0-new/gate 74 removed=0(讀 belief 非 god-view)/determinism 2跑一致 57381eace,★S2!=baseline(有真行為)。whole-system-first:只資源型「買」,定位/設施 stub。完成=systems+reviewer R²(非自判)→CLEAN merge→dispatch S3。"
branch: feat/means-end-s2-resource
commit: f9114f74
spec: docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md
---

# done：means-end S2 資源型 resolver（第一實質 slice，請 systems 收+驗+R²）

HOW spec §10 S2。goal frontier **資源型** resolution 接通（byte-identical **打破**=開始有行為，但只資源型；定位/人力/設施 stub）。

## 6 塊（組件 A/B/C/E/G + winner integration）
1. **組件 A goal 生成**：`GoalResolver.ensure_maintain_goals`（rank_scored 呼）冪等確保 5 資源維持 goal
   （food/material/tools/weapons/coin）+ 更新 active/satisfied（`holding < need_keep(res)` → active）。S7 才做 util-門檻掛退。
2. **組件 B `GoalRegistry`**：填 5 goal 的 resource 前置（qty 走 `need_keep` 通用，resolver 動態算非硬寫）。
3. **組件 C `frontier_candidates`**（取代 S1 stub）資源型 walk：active goal → resource 前置查 `holding vs need_keep`，
   未滿 → 「買」取得 candidate（`TASK_TRADE` 到已知市場，`_nearest_market_outpost_with` **belief-gated 感知鐵律**）；
   ★定位(採)/設施(產) 前置 = S3/S4 回無 candidate（stub 邊界）。
4. **組件 E need_keep 泛化**：resolver 用通用 `need_keep`（任 res 非只 material/tools construction scope）。
   need_keep 本已泛化（scope 只在 `_construction_facility_need` 的 means-end 路徑）→ resolver 直用即脫 scope，無需改 need_oracle。
5. **★組件 G must-fix① util 護欄**（首上場硬做，reviewer S2 回歸點）：
   `_candidate_util = payoff × dev_urgency_coeff`（`dev_coeff = food_days/DESPERATION`，絕境 food→0 → 0=壓遠慾望）
   **+ clamp 上界 `GOAL_UTIL_CAP(1.5) < DecisionEngine.SURVIVAL_BOOST_MAX(2.5)`** = 硬保證 goal candidate 永不蓋絕境 survival。
   折現（延遲）S6 才加，S2 即時取得無延遲折。
6. **winner→to_task 整合**：3 rank consumer（unified `faction_ai:1566` / subteam `:1806` / solo `:1949`）——
   winner 若 goal candidate（`e.has("cand")`）→ 用 `cand.to_task`；static option 走既有 `DecisionOptions.to_task`。

## 驗（皆綠）
- TDD `means_end_s2_test` **9/9**（①resource candidate 出現 to_task=TASK_TRADE ②need_keep 泛化 weapon>0
  ③location 前置 stub 無 candidate ★④**must-fix① range 斷言**：絕境任意 payoff goal util < SURVIVAL_BOOST_MAX
  [clamp 硬護欄] + dev_coeff press + 食足 clamp GOAL_UTIL_CAP ⑤冪等）。RED：①frontier stub→無 candidate / ④無 clamp→util 333k>2.5 護欄失效。
- headless 0-new（3 baseline；S2 行為變但無新 fail）。
- **gate PASS sites=74 removed=0**（GoalResolver 讀 `team_market_known` belief 非 god-view；無 RNG → **0 新閘**）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `57381eace`（純讀狀態無 randf）；★**S2 != baseline `d1071c59`**（確認有真行為=打破 byte-identical，符 S2 intended）。

## ★whole-system-first
S2 **只資源型「買」**；定位/人力/設施/子目標/折現/委派 = S3-S6 未提前。resolver 非資源 kind → skip（stub 邊界）。

## 完成判定 = systems + reviewer R²（★非自判）
請 systems 收 + 驗 + S2 R²（★reviewer 指定查 **range 斷言護欄** must-fix① / 6 塊吻合組件 / resolver belief-gate 非 god-view /
winner→to_task 整合 3 路 / whole-system-first 資源型 scope）→ CLEAN merge → dispatch S3（定位型 tile-resolver + team_tile_known belief）。
base=local main d4d11670（含 S1）。
