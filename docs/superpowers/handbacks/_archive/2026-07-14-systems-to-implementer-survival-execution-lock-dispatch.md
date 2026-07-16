---
from: systems
to: implementer
status: consumed
topic: "[DISPATCH] 求生執行鎖 thrash-fix——spec鎖+R②CLEAN;新worktree feat/survival-execution-lock;TDD"
---

# Dispatch：求生執行鎖 thrash-fix

spec（讀全文，注意事項在內）：`docs/superpowers/specs/2026-07-14-survival-execution-lock-thrash-fix.md`
R② CLEAN：`docs/superpowers/handbacks/2026-07-14-reviewer-to-systems-survival-execution-lock-r2-clean.md`（5 點 refute file:line 全查證）

## worktree
- 新 branch `feat/survival-execution-lock`，worktree `.worktrees/survival-execution-lock`，base = origin/main `0a761414`（已 push，含 spec）。
- **★base 已含最新 main**（Slice A 已 merged 於 a630f2ab），無 stale base 風險。

## 觸及檔（單檔為主）
- `scripts/simulation/faction_ai_system.gd`：
  - **Fix A**：加 helper `_in_survival(team) -> bool: return team.current_task in SURVIVAL_TASKS or team.task_priority == TaskArbiter.PRIO_SURVIVAL`（near :80）；三處 recognizer 呼點改呼 helper：`:3093`（核心執行鎖入口）、`:1360`（leader survival-sticky）、`:3484`（uprising skip）。
  - **Fix B**：`_decide_subteam` winner commit(:1742，`HandBrainProbe.capture` 旁)補 `SpecimenTracer.capture_decision(state, sub, opt, td["task"], tgt)`。
- **無新 const/option/data 欄**。

## TDD（先 red）
1. **thrash 重現 failing test**（Tier-1 控制場景床，秒級）：構餓子隊（parent_team_id!=-1，food_days<WARNING，可達食物市集）→ 跑 `_evaluate_survival` 連續二 tick → **斷言：買糧 dispatch 後 current_task 保持 TASK_TRADE@PRIO_SURVIVAL，不被 release 回 idle**（修前紅：第二 tick release；修後綠：HOLD）。
2. Fix B tap：specimen=子隊時，`_decide_subteam` 後 `SpecimenTracer.decision_count > 0`。
3. 標準 sanity：`headless_test` ≥1000 tick 無新 SCRIPT ERROR（注意 main 已知 3 assertion 失敗＝baseline，非新增）；determinism byte-identical；憲法閘 sites 不變。

## 驗收（spec §驗收法為準，measurer 產數字 + specimen trace）
thrash flip 歸零 / 買糧單下得成 / 故事性 specimen（QA 判官讀）/ tap-gap 收 / 不回歸。**本 slice 是全量暫態可觀測性 + QA 故事性判官 workflow 的首個試驗**——measurer 需產 `.specimen.jsonl`（`03b §⑤`）給 QA。

## 完成判定
= systems + reviewer/QA，**非 implementer 自判**。code commit 後寫 handback（`to:systems status:open`）→ 我收 + 推量測員/QA/藍圖鏈。
