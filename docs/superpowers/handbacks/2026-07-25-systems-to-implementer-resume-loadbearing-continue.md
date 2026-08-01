---
from: systems
to: implementer
status: consumed
topic: "[實作·2nd-layer resume 治本·R²v3 CLEAN·續 feat/construction-commitment-latch(8ffb8ab8)·你傾向(A)我認可·spec=2026-07-25-construction-commitment-latch-A1-fix.md §修③] latch WIP 保留,加 resume 治本閉環。你 execution-verified 坐實 resume load-bearing=好流程,認可(A)。修:_try_resume_construction 2746 後優先召回 construction_team_id 原隊(orig!=null+非戰鬥+在格+非已 TASK_BUILD+糧≥3天)→release-first+transition TASK_BUILD 續建,繞 owner/resident gate;orig 死/離格/餓→落回現有 candidates。★execution-verified(outpost_built>0)才收。TDD 補 directive-leak resume 救回測(驅真 tick 完工)。(B)directive 例外先不做=measure 定 thrash 需否。閘:headless 0-new+gate 74 removed=0+determinism 3跑 byte-identical。→measurer execution-verified 重量。"
branch: feat/construction-commitment-latch (續 8ffb8ab8)
---

# 實作：2nd-layer resume 治本（load-bearing 閉環）

R²v3 CLEAN（reviewer 確認 orig 召回設計嚴謹）。**續 latch branch**（8ffb8ab8 保留，加 resume 治本）。你 execution-verified 坐實 resume load-bearing = 好流程判斷，認可 **(A)**。

## spec
`docs/superpowers/specs/2026-07-25-construction-commitment-latch-A1-fix.md` **§修③ resume 治本**（讀它，含完整 code + 理由）。

## 修（A）：`_try_resume_construction` 優先召回原施工隊
`_try_resume_construction`（faction_ai:2742）「已有人施工 return」(:2746) 後、現有 candidates 掃描前插入：
```gdscript
# ★2nd-layer load-bearing：優先召回原施工隊(construction_team_id)。它專程來建、
# 常還在工地格只是被 directive/crisis/force leak 拉去外交(stall samples ct_pos==tile)。
var orig: TeamData = state.teams.get(tile.construction_team_id)
if orig != null and orig.combat_target == -1 \
        and orig.tile_pos == tile.tile_pos \
        and orig.current_task != TeamData.TASK_BUILD:
    var od: float = ResourceSystem.effective_food(state, orig) \
        / maxf(float(orig.population) * ResourceSystem.FOOD_PER_PERSON_PER_DAY, 0.001)
    if od >= 3.0:
        TaskArbiter.release(orig)                                       # release-first 過 guard
        TaskArbiter.transition(state, orig, TeamData.TASK_BUILD, TaskArbiter.PRIO_DISPATCH)
        if Probe.enabled: Probe.bump("resume.orig_recall")
        return
# orig 死/離格/戰鬥/餓 → 落回現有 candidates(別隊接手)
```
- **繞 owner/resident gate**（orig 是 construction_team_id 記錄的原施工隊本人、非找別隊接手）。糧 gate 保留（餓不搬磚）。
- orig 死/晉升/detach（`get` null）/離格/戰鬥/餓 → 落回現有 candidates（不退化）。

## ★TDD（execution-end，禁 teleport）
- **directive-leak resume 救回測**：施工中隊被 directive leak 拉去外交（仍在格）→ `_try_resume_construction` 召回原隊 → **驅真 tick 迴圈跑到 outpost_level>0 真完工**。對照無 resume（單 latch）baseline：leak 後永久棄不完工。
- 既有 latch TDD 6/6 保留。

## ★★execution-verified 硬標準（本刀真通過）
- fix 驗收 = **跑起來 outpost_built>0 + complete>0 + stall 消退**（非只 headless 綠/TDD 綠）。上輪教訓：latch 單層 TDD 6/6 綠但 execution complete=1 → 你正確擋住。這輪 resume 後要 execution 真達標。
- ★報 TDD 數字前跑讀 `=== DONE ===`。

## 閘 + 交付
- headless 0-new + gate 74 removed=0 + determinism 3跑 byte-identical。
- handback `to:measurer`：重跑 A1 focused（seed1337/42，6mo）→ **outpost_built>0** + complete 上升 + stall 消退 + resume.orig_recall fire。→ 數字 to:blueprint（release-pass）+ specimen to:QA。

## 不做（followup）
(B) directive 對 building 例外——先 (A) 治本，measure 定 directive-thrash 需否（resume.orig_recall 巨量 = thrash 訊號）。material 續 PARK。
