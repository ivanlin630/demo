# world_sim 長期世界量測台 — 設計 spec

> 系統(HOW)spec。純 NPC 世界長跑量測 harness，量因果脊椎 emergent（立國/vendetta/誘殺/scout…）。承 `2026-06-20-spine-probes`（探針）+ 量測回報缺口。

## 1. 問題

`game_sim_test`（玩家中心）量不到長期世界 emergence：玩家團滅 → `event_system` 觸發「玩家絕後」`game_over=true` → 世界系統 gate off（`encounter:1378 if game_over: return` 等）→ **世界凍結空轉** → 立國/vendetta/誘殺/scout 等慢 emergent 量到 0（首輪 90 天 + 嘗試 2 年皆被玩家死腰斬）。

## 2. 解法（option A：無玩家世界）

`GameSetup._setup_player` line 504 `if pcfg.is_empty(): return` → **config 無 `player` 區塊 = 不建玩家、`player_id=-1`、不觸發絕後 game_over**（`player_id==-1` 哨兵全系統已 guard）。→ 世界永不凍 → 跑滿 max_ticks。

= 新 harness `world_sim.gd` + 新 config `world_sim.json`（explicit NPC 隊、無 player 區塊、長 max_ticks）。**零遊戲 code 改**（純 debug infra + config）。

## 3. 範圍

- **純量測**：跑純 NPC 世界 N 年，Probe 彙總 + SpineTrace 取樣。不改遊戲行為。
- **config**：explicit 模式、NPC 隊（含 archetype：軍閥/商隊/生產村/流亡/居民，≥5 隊 2 faction 給衝突素材）、**無 `player` 區塊**、`max_ticks` 預設 2 年(172800)、seed 固定（可重現）。
- **harness**：複用 `game_sim_test` 跑迴圈精神，去玩家專屬（無 command_schedule 注入、無 player encounter 驅動、`player_pos` 取 `Vector2i(-1,-1)`）。Probe.enabled + SpineTrace 取樣（長跑 → 取樣 cadence 放寬，月取樣免 log 爆）。結尾 Probe.summary。
- **OUT**：改遊戲行為、新平衡值（量測只揭 feel）、UI、玩家路徑（本台無玩家）。

## 4. 風險 / 注意

- **player_id=-1 下 LOD/vision**：world LOD 可能以玩家為中心；無玩家 → 全域 LOD 或 NPC 各自 LOD。需確認 `runner.advance_tick(state, Vector2i(-1,-1))` 跑通（NPC 世界不依賴玩家焦點）。若 LOD 退化致行為異常 → 記 known_issues（量測台限制），非遊戲 bug。
- **長跑 perf**：172800 tick 純 NPC + 月取樣。應分鐘級。可 background。
- **世界自然死光**：NPC 全滅則世界空（無 game_over 機制停 → 跑到 max_ticks 空轉）。summary 仍出；可加「存活隊數歸 0 → 提早收尾」軟停（optional）。
- **可重現**：seed 固定 → 數字可比較（調 TEST VALUE 前後對照）。

## 5. 驗收

- `world_sim` 跑滿 max_ticks（無玩家 game_over 凍結）、無 SCRIPT ERROR、不變量/coin_eq 維持。
- `[ProbeSummary]` 印；**長期 emergent 非零**：立國/vendetta/feud/scout/誘殺 至少數項 >0（90 天測不到的，2 年世界長出來）→ 證實「沒跑夠久」假設 vs「真沒條件」。
- 既有 `game_sim_test`/`headless_test` 不受影響（新檔/新 config，Probe flag 各自管）。

## 6. 給實作（plan 拆）

- Task1 `config/world_sim.json`（explicit NPC 隊 archetype + 無 player + max_ticks 2 年 + seed）。
- Task2 `scripts/debug/world_sim.gd`（複用 game_sim_test 迴圈去玩家、Probe + SpineTrace 月取樣 + summary；player_pos=-1）。
- Task3 跑通驗收（跑滿、emergent 非零、不變量維持）+ 數字回報 handback。
