---
from: implementer
to: systems
status: consumed
topic: "[done·means-end S7 收尾·cadence-gate perf+goal 掛退 lifecycle·★S7=means-end whole-done·收+驗+S7 R²請] feat/means-end-s7-cadence 737ee409 off local main 0d10df05(含 S6)。修:①perf cadence-gate(goal 生成每 3天非每 decide)②goal 掛退 lifecycle(build_F 建成/desire 掉→退,maintain 冪等留)。TDD 7/7(RED cadence-gate load-bearing)/headless 0-new+perf 改善(4m25s<超時)/gate 74 removed=0/determinism da33122a。★means-end S1-S7 WHOLE-DONE。完成→收+驗+S7 R²→CLEAN merge=whole-done→喚藍圖+QA measure 整系統。"
branch: feat/means-end-s7-cadence
commit: 737ee409
spec: docs/superpowers/specs/2026-07-24-long-range-planning-means-end-HOW.md
---

# done：means-end S7 收尾（★means-end whole-done，請 systems 收+驗+R²）

HOW spec §10 S7。最後 slice 收尾：perf optimize + goal lifecycle，不新增機制。

## 修（收尾）
1. **★perf cadence-gate**（known_issues A）：`ensure_maintain_goals` 加 `team.goal_eval_next_tick`（鏡射 `residency_eval_next_tick`）→ 每 `GOAL_EVAL_CADENCE`（3 天）呼一次，非每 `rank_scored`（每隊每 decide）。goal_state 持久跨 tick；frontier 每 decide 重驗 holding → stale status 不生假 candidate（安全）。解 S4 goal 生成 `facility_deficit×每 decide` 慢。
2. **★goal 掛退 lifecycle**（組件 A S2/S4 最小 → 完整）：掛 = desire≥threshold（既有）+ **★退** = build_F 建成 or desire 掉 below threshold → 移除（免 goal_state 無限累積 satisfied build_F = memory+perf leak）；maintain goal 冪等持久留。
3. **must-fix① 護欄不動**（沿用）。

## 驗（皆綠）
- TDD `means_end_s7_test` **7/7**（①cadence-gate:二次呼不重生+過 cadence 重生 ②build_F 建成→退 ③maintain 冪等持久不誤退 ④must-fix① range regression）。RED：cadence-gate 移除→二次呼重生 FAIL（load-bearing）。
- headless **0-new** + **★perf 改善**（4m25s < S4/S5 超時 5min → cadence-gate 真生效，goal gen 每 3 天非每 decide）。
- **gate PASS sites=74 removed=0**（cadence/掛退純狀態+tick，無 god-view/RNG）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `da33122a`（禁 randf，tie-break；S7≠S6=gen 頻率+掛退真改，但 S7 自 2 跑一致）。

## ★★means-end 長程規劃 arc WHOLE-DONE
| slice | commit | 內容 |
|---|---|---|
| S1 骨架 | e339ac4c | goal_state/GoalRegistry/GoalResolver 接線 no-op proof |
| S2 資源型 | f9114f74 | resource frontier 買取得 + must-fix① 護欄 |
| S3 定位型+閉環 | 660a9506 | tile-resolver 拆兩類(must-fix②) + material 缺口鏈 build-closure |
| S4 設施發展 | 8a2d862d | 8 座 build_F goal + 設施/人力型前置 |
| S5 委派 | 3f765ad8 | delegate peer option + gate② viability |
| S6 折現 | 2d89ca6c | 投資型延遲折現 + 人格折現率 |
| **S7 收尾** | **737ee409** | cadence-gate perf + goal 掛退 lifecycle |

統一決策框架：goal frontier（想要什麼→walk GoalRegistry 拆前置鏈→當下可動 frontier）與 static option 同 rank 池 argmax；
must-fix① 護欄保 survival 恆贏；感知鐵律 belief-gate（team_market_known/team_tile_known）；determinism 全程守。
全鏈湧現：想要 F → 缺料 → 買/採@forest（絕境不走遠路=折現）→ 建 outpost → 採 → 湊料 → 建 F（夠 pop 委派子隊並行）。

## ★followup backlog（whole measure 的 watch，非機制 blocker）
- S3 unowned 優選精修 / S4 facility-type 改建 / S5 `_try_dispatch_or_invite` residency 8-12 浪費帶 de-patch。

## 完成判定 = systems + reviewer R²（★非自判）
請 systems 收 + 驗 + S7 R²（cadence-gate 節流正確 + stale status 不生假 candidate + goal 退不誤退 maintain + must-fix① 續守 + determinism）
→ CLEAN merge = **★means-end whole-done** → systems 喚藍圖 + QA measure 整個系統（用戶原則②）。
base=local main 0d10df05（含 S6）。
