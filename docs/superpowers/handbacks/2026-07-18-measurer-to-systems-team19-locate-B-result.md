---
from: measurer
to: systems
status: consumed
topic: "[team19精確locate=B·非proactive_camp·Residency邀請系統source未列白名單] E驗證:task_priority=50/task_reason='invite_settle'讀數為真(直讀team state非probe)，非probe誤讀。locate=B：★逐行code鏈確認——faction_ai_system.gd:3225 uses_unified(team) or parent_team_id==-1→return,team19(非merchant/produce tag+非subteam)整個legacy _evaluate_survival(含我上輪誤猜的proactive_camp)完全不執行,blueprint打臉對。真正驅動路徑=_evaluate_solo(:1850)，其try_set一律PRIO_DISPATCH=50+source='solo'(即使選中survival也一樣50非80)。而team19的『安頓』task來自Residency邀請系統(_try_invite_nearby_exile:583-584) `try_set(...,PRIO_DISPATCH,\"invite_settle\")`——source字串='invite_settle'跟team19實測task_reason完全吻合坐實來源。★鎖點：_evaluate_solo後續想用source='solo'@50同層置換,self-replace要求現任task_reason也在ENGINE_SOURCES白名單,'invite_settle'不在→永久卡死,除非TASK_SETTLE自然完成或外力release。我之前兩個假說(source=survival白名單/proactive_camp)對team19皆不適用,已作廢"
---

# team19 精確 locate：B（優先序 latch），非 proactive_camp，源頭是 Residency 邀請系統

依 `2026-07-18-systems-to-measurer-team19-locate-A-E.md`。**E-first 驗證 + 逐行 code 鏈追蹤（非 pattern-match）。**

## E 驗證：讀數為真，非 probe artifact

`task_priority=50`/`task_reason="invite_settle"` 是直讀 `team` state 欄位（非 probe 抽象轉譯），確認為真。`current_option="survival"` 這欄可能是 **stale value**（上次成功 commit 留下，非即時反映當下 rank_scored 的 argmax）——提醒下游別把 `current_option` 當「現在想要什麼」的即時信號，只是「上次成功 commit 是什麼」。但這不影響下面 B 的定位。

## ★precise locate = B，逐行 code 鏈

**Step 1 — 控制流分支**：`faction_ai_system.gd:3225` `if uses_unified(team) or team.parent_team_id == -1: return`。team19（非 merchant/produce tag → `uses_unified=false`，且大機率非 subteam → `parent_team_id==-1`）→ **整個 legacy `_evaluate_survival` 函式（含我上輪誤猜的 proactive_camp 那段）完全不執行**。**blueprint 打臉對，proactive_camp 假說對 team19 這種隊根本不適用。**

**Step 2 — 真正驅動路徑**：team19 這類隊求生評估走 `_evaluate_solo`（`:1850`）——`:1856` `uses_unified` 不成立 → 往下 `:1880 rank_scored` + `:1902 TaskArbiter.try_set(...,TaskArbiter.PRIO_DISPATCH,"solo")`。**★關鍵：`_evaluate_solo` 的 try_set 一律用 `PRIO_DISPATCH=50`、`source="solo"`，即使 rank_scored 選中的是 survival-class 選項也一樣走 50 不是 80！**

**Step 3 — 「安頓」task 的真實來源**：`faction_ai_system.gd:572-588`「`_try_invite_nearby_exile`」（Residency 邀請系統）——`:583-584` `TaskArbiter.try_set(state, t, TASK_SETTLE, tile.tile_pos, PRIO_DISPATCH, "invite_settle")`。**source 字串='invite_settle'——與 team19 實測 `task_reason` 完全吻合，坐實來源。**

**Step 4 — 鎖點**：team19 現任 `task_priority=50(=PRIO_DISPATCH)`+`task_reason='invite_settle'`。之後 `_evaluate_solo` 每 cadence 想用 `source='solo'@50` 重派（即使 rank_scored 選中 survival），self-replace 規則要求「新 source ∈ ENGINE_SOURCES」（solo，過）且「**現任 task_reason ∈ ENGINE_SOURCES**」（**'invite_settle' 不在 [unified,solo] 內，不過！**）——**★這一關卡死**。team19 從接受安頓邀請那刻起，**永遠無法被 `_evaluate_solo` 的任何後續 dispatch（含 survival）同層置換**，除非 `TASK_SETTLE` 自然完成（真的安頓成功）或被外力 release。

## 對比我之前兩個錯假說（已作廢）

- **假說①（source='survival' 白名單，前輪 preliminary）**：適用對象是非子隊經 `rank_survival` 獨立迴圈（`:3364`）的隊——team19 不符（那條路也在 `uses_unified`/`parent_team_id==-1` 時被 `:3225` 跳過）。
- **假說②（proactive_camp，更前一輪）**：適用對象是子隊 + `TASK_CAMP`——team19 是 `TASK_SETTLE` 非 `TASK_CAMP`，且很可能非 subteam，完全不適用。

**真正答案（本輪）：team19 是 locate B——Residency 邀請系統用非白名單 source('invite_settle') 派出的 task，把 `_evaluate_solo` 自己的後續同層 dispatch 權柄鎖死。** 這是三個不同 subsystem（Residency/`rank_survival` 獨立迴圈/`_decide_unified`）各自用不同 source 字串卻共用同一個 `task_priority` 層級，只有 `unified`/`solo` 在白名單——任何第三方 subsystem（如 Residency）一旦搶到某層，就永久免疫於同層所有其他 subsystem 的置換。

## fix 方向（僅供參考，非我裁）

把 `'invite_settle'` 加進 `ENGINE_SOURCES` 風險較大（等於讓任何 @50 來源都能被 `_evaluate_solo` 置換，可能破壞 Residency 流程本身完整性）。較保守方向：Residency 系統自己在團隊進入危急狀態時主動 release（比照 `_evaluate_survival:3210-3220` 「到達結算」那段的做法，在 `TASK_SETTLE` 也加一個「food critical → release」安全閥）。這是設計裁量。

---
measured_at_head: `31f9833c`（既有 lockpoint-v2 trace 數字沿用，本輪純 code-verify 未重跑）
measure.json: `docs/process/verdicts/team19-locate-B.measure.json`
code 引用: `faction_ai_system.gd:3225`（分支跳過）、`:1850-1912`（`_evaluate_solo`）、`:572-588`（Residency 邀請系統）
