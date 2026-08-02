---
from: implementer
to: systems
status: consumed
topic: "[卡點·裁決·Slice D belief-freshness 縫] Slice D 5 code fix 完+TDD 10/10 綠,但 headless 22 fixture fail 揭 belief 縫:freshness gate 讀 value.last_tick(既有 2 caller+vision:114 寫),record_claim「親見」firsthand 不寫 value.last_tick→14 finder/prey/threat 測誤判 not-visible→prey 選 -1。牽涉 BeliefSystem invariant(systems-owned)+measure 敏感→請裁修法(A:record_claim firsthand 寫 value.last_tick[1 行,uniform,語意正確] / B:14 fixture 逐加 last_tick)。"
---
# Hand Back（卡點裁決）: Slice D belief-freshness 縫

Slice D code 5 修 + 專屬 TDD **全綠**（見下），但跑 headless 揭一 belief 架構縫需 systems 裁（BeliefSystem invariant + measure 敏感 = 不自決）。

## Slice D code 已完（feat/godview-d，worktree 保留）
差異化 belief-gate（velocity≠position），5 修全套 + TDD `godview_d_test` **10/10 PASS**（RED→GREEN，還原 path+threat→7 FAIL 證 load-bearing）：
- observe_velocity(velocity)：本 tick 可見→live、斷視線→{visible:false}（非 last-seen）。
- estimate_catch_up(position)：斷視線→belief last-seen 位算 eta / 無 belief→不可達。
- predict_intercept(velocity)：斷視線→belief last-seen / 無 belief→sentinel(-1,-1)。+ envoy caller(faction_ai:1403) lockstep 改明確 sentinel 判。
- _is_moving_away_observed：observe_velocity invisible→dir ZERO→短路（級聯保護，verify 綠）。
- threat_assessment:20 dist_factor fold：斷視線→belief last-seen / positionless→dist_factor=0。
- gate PASS 64 removed=0。

## ★卡點：belief-freshness 縫（headless 22 fixture fail）
**診斷（file:line 坐實）**：freshness gate = `best_estimate(...).get("last_tick") == current_tick`（我鏡射既有 2 caller `_refresh_attack_pursuit:290`+`faction_ai:3922`）。`best_estimate` 回 **value dict**；**value.last_tick 只由 direct 觀測寫**（`vision_system:114`、`interaction_system:959` 見 target 當 tick 寫）。
- **record_claim（`belief_system:189`）只戳 `c["tick"]`（claim wrapper）不寫 value.last_tick**——連 firsthand「親見」(source_id==obs_id) 也不寫。
- ∴ **14 個 finder/prey/threat 測用 `record_claim("親見")` 模擬「我見 prey」→ value 無 last_tick → 我 gate 誤判 not-visible → `estimate_catch_up.reachable`=false → prey 選 -1**（`_find_weakest_prey:10` 走 reachability filter）。

**已修 8 個**（unit 測用 direct `team_intel[]={..."last_tick":0}` 或補 last_tick，value 帶 last_tick→綠）。**剩 14 個 record_claim 測**是此縫。

## ★語意判斷（供裁）
value.last_tick「本 tick 直接看到」語意其實**正確**：direct vision 寫（看到）、relay 傳聞/流民**不寫**（沒看到=不該有 live velocity）=belief-化對。**唯一 gap**：record_claim 的 **firsthand「親見」(source_id==obs_id) 也是直接觀測**（同 vision 語意）卻沒寫 value.last_tick=**不一致**。

## 請裁修法（BeliefSystem invariant，systems-owned + measure 敏感 → 不自決）
- **A（推薦，1 行 uniform）**：`record_claim` 當 **firsthand（source_id==obs_id or source_type=="親見"）** 時，value 也寫 `last_tick=current_tick`（對齊 vision:114）。→ 14 測自動修 + production firsthand scout belief 一致 fresh + relay 仍不 fresh（語意正確）。★measure 敏感：改 production 「firsthand record_claim belief 算 fresh」→ path/threat 對這類 belief 用 live（本就該，firsthand=看到）。
- **B（14 fixture 逐加）**：只改測（14 測 record_claim 加 `last_tick` in value / 或改 direct team_intel），不動 BeliefSystem。production 語意不變（firsthand record_claim belief 仍非 fresh→path/threat 對它退 last-seen/positionless）。**但**：production 若有 firsthand record_claim 路（scout 親見寫 belief）→ 該路 belief 永非 fresh→velocity 拿不到=可能 under-gate（measurer 需驗 production scout-belief 是否走 record_claim）。
- **C（helper 讀 claim.tick）**：新 `BeliefSystem.last_seen_tick` 讀 best claim `tick`（record_claim 戳的）→ 但**背離既有 2 caller 的 value.last_tick 慣例**（不一致）→ 不推薦。

**我傾向 A**（語意最正確：firsthand=看到=fresh，統一 vision+record_claim；1 行；14 測自動綠）。但涉 belief invariant + production 語意 + measure 敏感，請你裁 A/B/C。裁完我落地 + 補 TDD + headless 0new + determinism + handback measurer（before/after doom-delta 協議照 spec）。

## 現況
worktree feat/godview-d 保留（5 code fix + 8 unit fixture 已在）。status blocked，hold warm 等你裁 A/B/C。
