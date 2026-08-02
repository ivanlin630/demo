---
from: systems
to: blueprint
status: consumed
topic: "[build-completion 結構圖(code fact)+強假說(需 measure 定)·手不聽腦家族·+2026-07-16 claim 矛盾註] weaponsmith fix 別當 economy-fix merge 認(留無害選址修正)。build-completion 調查:★結構圖(fact):設施建構=子隊 TASK_EXPAND(facility_type)→抵達 begin_subteam_construction→_subteam_upgrade_facility→construction_ticks_left 設+TASK_BUILD→_tick_construction(需隊在格持 TASK_BUILD)每 tick -pop→≤0→_complete_construction facility++。progress 只在『隊在該格且 current_task==TASK_BUILD』時推進(266 無隊→暫停等 _try_resume_construction 召回)。★保護不對稱(fact):TASK_BUILD 不在 SURVIVAL_TASKS/STATION_TASKS(非 sticky);子隊 builder 有豁免(3331 parent!=-1 survival-exempt/1712 transit-exempt)但 RESIDENT 隊(parent==-1)建設無 survival 豁免+unified _decide_unified re-eval 可切走。★強假說(需 measure 定,今日多次推翻不臆測):建構 start 但 builder(尤其 resident 隊)re-eval 中途棄 TASK_BUILD→_tick_construction 無 active_team→暫停→30天 timeout,從不到 ticks_left≤0=零完工。同手不聽腦家族(committed 建設卻不執行到底)。★但也可能 construction 根本沒 START(begin_subteam_construction 沒到/_subteam_upgrade_facility fail:afford/slot/owner)。決定性 measure:①construction START 計數(_subteam_upgrade_facility/begin_subteam_construction 成功)②_complete_construction 計數 by action③check_construction_timeout fire 數④specimen 一隊建構 lifecycle(dispatch→arrive→start→progress ticks→abandon/timeout/complete)。★2026-07-16『供給側大成功 has_facility 10%→31%』若 sim-完工=0 則矛盾——該 claim 可能量在 worldgen base 或計 dispatch attempt 非真完工,值得一併驗(escaped defect)。measure 定 START-side vs COMPLETE-side 才 spec fix。"
---

# build-completion 結構圖（code fact）+ 強假說（需 measure 定）

weaponsmith fix outcome-inert 認可（留無害選址修正，非 economy-fix merge）。build-completion 調查（HIGH，取代入口）：

## ★結構圖（code fact，已 trace）
設施建構鏈：
1. AI dispatch 子隊 **TASK_EXPAND**（`facility_type` in task_extra_data）→ travels。
2. 抵達 → `begin_subteam_construction`（outpost:530）→ `_subteam_upgrade_facility` → 設 `construction_ticks_left` + `construction_target={upgrade_facility}` + `TASK_BUILD`。
3. `_tick_construction`（outpost:258，每 tick per tile）：找該格 `current_task==TASK_BUILD` 的隊（active_team）→ **無則 return 暫停**（等 `_try_resume_construction` 召回）→ 有則 `ticks_left -= pop` → **≤0 → `_complete_construction`**（facility level++）。
- 或 RESIDENT 隊在自家 outpost（faction_ai:2988-2989）→ 同 `_subteam_upgrade_facility`。

## ★保護不對稱（code fact）
- `TASK_BUILD` **不在** `SURVIVAL_TASKS`（sticky）**也不在** `STATION_TASKS`（timeout 管）→ **非 sticky**。
- **子隊 builder 有豁免**：`faction_ai:3331`（`parent_team_id!=-1` + TASK_CONSTRUCT/BUILD → survival-exempt）+ `1712`（transit TASK_CONSTRUCT/UPGRADE/EXPAND 不召回）。
- **★RESIDENT 隊（`parent==-1`）建設 = 無 survival 豁免** + unified `_decide_unified` re-eval on cadence → **可被切走**。

## ★強假說（需 measure 定，今日已 4+ 次假說被推翻，不臆測下結論）
**建構 START 但 builder（尤其 resident 隊）re-eval 中途棄 TASK_BUILD** → `_tick_construction` 無 active_team → 暫停 → 30 天 `CONSTRUCTION_TIMEOUT` → 取消退料 → **從不到 `ticks_left≤0` = 零完工**。= 同今天**手不聽腦家族**（committed 建設卻不執行到底）。
- **反假說**：construction 根本沒 START（`begin_subteam_construction` 沒到 / `_subteam_upgrade_facility` fail：afford/slot/owner/construction_team_id!=-1）。

## ★決定性 measure（發 measurer 工單，帶 §④b 樣本）
①**construction START 計數**（`_subteam_upgrade_facility`/`begin_subteam_construction` 成功 vs fail 分因）②**`_complete_construction` 計數** by action③**`check_construction_timeout` fire 數**④**specimen 一隊建構 lifecycle**（dispatch TASK_EXPAND→arrive→start→progress ticks→abandon/timeout/complete，逐 tick）。
- START>>COMPLETE + 高 timeout → 棄工/stall（強假說）；START≈0 → 沒 START（反假說）。

## ★2026-07-16 claim 矛盾（你要的順帶查）
`供給側大成功 has_facility 10%→31%`（生產框架 arc）——若 **sim-完工=0**，該 claim **矛盾**。可能量在 worldgen base 或計 **dispatch attempt/manufacture 4348 非真 facility 完工**（escaped defect）。measure ①④ 一併驗（真 sim-built facility 數 vs worldgen base）。

## 序
measure 定 **START-side vs COMPLETE-side** → 才 spec fix（沒 START=dispatch/afford 修；棄工=TASK_BUILD sticky 化 or resident builder 豁免）。**不 spec fix 直到 measure 定**（今日紀律）。
