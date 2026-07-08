---
from: implementer
to: measurer
status: open
topic: A2a 子隊決策納統一框架 — 實作完成，交量測/QA 驗收(bed + 效能 + 非退化)
slice: A2a
spec: docs/superpowers/specs/2026-07-08-A2a-subteam-decision-routing.md
scope: docs/process/verdicts/A2a.scope.json
branch: feat/machine-A2a
---

# Hand Back: A2a 子隊決策納統一框架（母團 directive + faction_duty）

## 實作摘要（6 檔 + 1 焦點測試）

逐 spec D1-D7 全實作。子隊(`parent_team_id != -1`) idle 決策從手寫 argmax+randf 繞引擎
搬進 `DecisionEngine.rank_scored` 全框架。歸建(faction_duty)↔掠奪(greed) loyalty-gated
競秤湧現，零子隊專屬 term/分支。

| 檔 | 改點 |
|---|---|
| `scripts/data/team_data.gd` | +`subteam_eval_next_tick` 欄（鏡射 `threat_eval_next_tick`，D5 cadence） |
| `scripts/simulation/decision/decision_context.gd` | +`is_subteam` 欄（一旗兩用）+ gather 填 `= parent_team_id != -1`（D1） |
| `scripts/simulation/decision/options.gd` | +`歸建` REGISTRY row(`faction_duty`) + applicable(`is_subteam`) + to_task fallback(→IDLE)；+`STRATEGIC_SELFINIT_SET` const + applicable loop 頭通用戰略-gate guard（D2/D3） |
| `scripts/simulation/decision/terms.gd` | `faction_duty` eval +`歸建` case(`FACTION_DUTY_DRIVE if is_subteam`)（D2） |
| `scripts/simulation/faction_ai_system.gd` | +`_decide_subteam`(cadence-gated 引擎 dispatch)+`SUBTEAM_CADENCE`；+`_try_join_target` helper；改 `_evaluate_subteam` tail(active-transit sticky)；刪 `_check_deviation`/`_evaluate_idle_subteam`/`DEVIATION_RATE`；改註解 1332（D4/D4b/D5/D6） |
| `scripts/debug/constitution_baseline.txt` | -`_check_deviation`/-`_evaluate_idle_subteam` +`_decide_subteam` +`_try_join_target`（D7，見下方偏差1） |
| `scripts/debug/a2a_join_guard_test.gd` | ★新增焦點測試（§9/§9b，非 spec 要求，自加降風險） |

### 量測特判（工單鐵律，by construction）
- `歸建` winner → `_decide_subteam` set move_target + merge_queue + **`return` 在 capture 前** → 永不進統計。
- 投靠玩家 forced_event 分支 → `_try_join_target` 只寫 forced_event 不 try_set → `current_task` 仍 IDLE →
  `if sub.current_task == TeamData.TASK_JOIN` 守 capture → **玩家請求不 capture、直接 return**（round-5 修點）。
- 唯 NPC 投靠真 try_set(JOIN) 成功 + 一般 task-dispatch(掠奪/攻擊/迎戰/備戰/求和/survival) 才 `capture(src="subteam")`。
- 所有 lifecycle 出口(parent null / 無 leader / 全不可派) 皆不呼 capture。

## 驗了啥（實作端；QA/量測跑完整驗收）

1. ✅ **godot import 綠**（`.\tools\godot.ps1 --headless --import` 無錯）。
2. ✅ **headless_test `=== DONE ===` 無 SCRIPT ERROR**；`[SubAI] Team%d 引擎→%s (%s)` 引擎 dispatch print 出現
   （子隊真走引擎，非手 argmax）。
3. ✅ **constitution_gate PASS**（sites=30, removed=0）。
4. ✅ **game_sim_multi ~21600 tick（day 90）無崩**（此 config factions=0 未生子隊，僅 sanity 無崩）。
5. ✅ **焦點測試 `a2a_join_guard_test.gd` 13 斷言全 PASS**（§9 forced_event 非自動併/不 fallthrough + §9b 不 capture + NPC 路 + 未知 target）。

## ★待量測/QA 跑的正式驗收（我這節點跑不到/非我職責）

驗收法 §4/§6/§7/§8 需 bed + 效能對照 + seeded 漂移判定，交你：
- **§4 單點 bed**（`hand_obeys_brain_bed.gd`, seed 1337, 1 月）對 A2a 前 baseline：`subteam_bypass` → ~0；
  `subteam` src decisions>0 且 obey 高/背離低；determinism PASS。**注意**：此 bed 現以 `player=-1` 跑
  （`no_player`），故不會觸發投靠玩家 forced_event 分支——§9b「玩家請求不灌 violation」在無玩家 bed 中
  by construction 成立；若要主動驗玩家路，用我加的 `a2a_join_guard_test.gd`（已綠）。
- **§5 抖動檢**：子隊 task 走引擎後穩定（`current_option`+COMMITMENT_BONUS + SUBTEAM_CADENCE 三重防震）。
- **§6 效能回歸（藍圖 review #2）**：before/after per-tick tick-time ≤5% 退化。cadence gate 攤平 gather。
  手段：`SimRunner.phase_timing` 比 `loop1.factions`/`gather.*` bucket，或 headless N-tick wall-time 同 seed。
- **§7 非退化**：member/solo/leader 背離不暴增；`arbiter_latch` 維持 A1a 後低檔；seeded final 漂移合理判定。
- **§8 效果發生**：subteam 背離真降 + bypass→0（非只改 code）。

## 連動風險 / 殘留疑點

- **`hand_brain_probe.gd::SUBTEAM_BYPASS_REASONS = ["subteam_idle", "deviation"]` 變不可達**（兩 note_bypass
  call site 隨 `_check_deviation`/`_evaluate_idle_subteam` 刪除消失）。spec no_touch 明示「不可達但無害留」→ 未動。
  bed 量 bypass["subteam"] 應恆 0（無 call site）＝ §4「bypass→0」自動成立。
- **`headless_test.gd:2467` 註解 stale**：`# 低忠誠 → deviation_chance 更高` 指已刪的 `_check_deviation`。
  該 scenario 現改由引擎路承接（低忠高貪 → 掠奪壓過歸建，同語意）。純註解、非斷言，test 仍 === DONE ===。
  非 touch_files、屬 no_touch 測試檔 → 未改，僅記此。
- **子隊路 `_evaluate_subteam` 呼 `_decide_subteam` 前無 parent==null 檢查**：`_decide_subteam` 頭自守
  (parent==null→return)；lifecycle guard(discipline/settle/construct/escort/envoy) 仍逐 tick 早退（未 cadence-gate，責任性）。

## ★偏差（spec 未覆蓋，我做的判斷 — 呈報確認）

1. **`_try_join_target` 也入 constitution baseline**（spec D7 只列 `_decide_subteam`）：
   helper 內含 `try_set(TASK_JOIN)` → constitution_gate 以「enclosing func」為指紋單位 → 偵測為新
   引擎外 dispatch site → **gate FAIL**。修：加 `_try_join_target` 進 baseline。
   **正當性**：helper 唯一 caller = `_decide_subteam`（引擎 rank 選中 `投靠` 才 try_set），非手 argmax
   繞引擎；玩家 target 走 forced_event 不 try_set。屬引擎落點，同 `_decide_subteam` 正當。gate 自身
   remedy 明載「呈報系統更新 baseline」→ 在系統/實作權限內。**若藍圖/系統認為 helper 應 inline 進
   `_decide_subteam` 以免額外 baseline 指紋，可退（但 spec D4b 明要 helper 當 consolidation 錨）。**

2. **新增 `a2a_join_guard_test.gd`**（非 spec 要求）：spec 驗收 §9/§9b 描述構造玩家投靠場景斷言，但正式
   bed(`hand_obeys_brain_bed`) 跑 `player=-1` 觸不到該路。加此最小 state 焦點測試直測 helper 兩路，
   降 round-5 量測特判風險。若你已有覆蓋此路的 bed 場景，此檔可視為冗餘（保留無害，純 debug 腳本）。

## Future-work（spec 立案，非 A2a 職責，未動）
- **join-consent-consolidation**（既有 P2a join 債）：全 join-player 派工路遷 `_try_join_target` + 修
  `_evaluate_solo:1767` 無 guard + 修 2 處 `_maybe_request_join_player` 回 false fallthrough。scope B，另 slice。
- **抗命**（mid-mission 動態違令）：round-2 D6 deferred，另 slice。
- **母團經引擎下戰略令**：現 STRATEGIC_SELFINIT_SET guard 對子隊無條件擋；日後於 guard 加 per-opt directive 檢查（hook 預留）。
