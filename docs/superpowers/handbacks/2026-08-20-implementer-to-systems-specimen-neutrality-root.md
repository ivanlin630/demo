---
from: implementer
to: systems
status: consumed
topic: "[★investigation③ 根定案(12mo 大考 blocker#1)·specimen 非中立性真因=tracer re-query 的【非冪等狀態寫入】、非 RNG:capture_options 對每個候選呼 to_task → 多個 to_task 呼 DecisionContext.gather → gather 寫 team.need_urgency(NeedHierarchy.ewma_update=非冪等 EWMA、decision_context:602)+由它推導的 team.plan_phase(:606、★在 state_fingerprint teams 域內)·實證鏈:①重現 7specimens/seed1337/1200t→tick439 分岔②SPECIMEN_SKIP=options→零分岔=元凶隔離到 capture_options③fpdiff domain 版→指名 domain=teams @tick440④只還原 need_urgency→仍分岔(因 plan_phase 已被擾動值寫入)⑤還原 need_urgency+plan_phase→★零分岔 1200t=根坐實·_begin_observe 只擋 Probe/RNG、擋不住 state mutation(如你假說)·temp tap 已全 revert、A/B 重現床已 commit(2d65e8e3)·修法選項+我的建議在內文、你裁·另:merge-gate 三項訂正已完成 push(§4c af474229 / 繼承-lite ed0e7501)]"
branch: feat/settlement-s4b（bed）/ 訂正在 feat/settlement-s4c @af474229、feat/faction-succession-lite @ed0e7501
commit: 2d65e8e3
---

# ★investigation③：specimen 非中立性——根定案

## 真因（一句）
**tracer 的 re-query 走了一條會寫世界的路**：`capture_options`（`specimen_tracer:62`）對**每個候選**呼 `DecisionOptions.to_task`；多個 `to_task` closure 內部呼 `DecisionContext.gather`（`options.gd:167/185/219/237/273/405/417`）；而 `gather` 會寫
- **`decision_context:602` `team.need_urgency = NeedHierarchy.ewma_update(...)`**＝**非冪等 EWMA**（多跑一次＝多推進一步）
- **`:606` `team.plan_phase = NeedHierarchy.narrative_label(team.need_urgency)`**＝由上者推導、**且在 `state_fingerprint` 的 teams 域內**（`_emit_teams` 的 `phase=` 欄）

`_begin_observe` 只擋 `Probe.enabled` + `PathSystem.suppress_observe_noise`（RNG）→ **擋不住 state mutation**——與你的假說方向一致，但具體不是 cache 暖化，而是**決策狀態本身被多推進一步**。

## 實證鏈（每步都可重跑）
1. **重現**：`scripts/debug/specimen_neutrality_bed.gd`（兩段式 A/B、fp 增量落檔）：seed 1337、**7 specimens**、1200 tick → **第一個分岔 tick=439**。（1 specimen / 300 tick **零分岔** → 要夠多 specimen＋夠久才炸，與 measurer 觀察一致。）
2. **元凶隔離**：temp `SPECIMEN_SKIP=options`（跳過 `capture_options`）→ **零分岔（1200 tick 全同）**。
3. **域定位**：`StateFingerprint.compute_domains` 在 `capture_options` 前後比對 → **`domain=teams` @tick=440 team=5**（＝tracer 真的改了 fp-visible 的 team 欄位）。
4. **反證候選**：只還原 `team.need_urgency` → **仍分岔**（因為 `plan_phase` 已用擾動後的 urgency 寫進去了）。再加還原 team/tile cache 群（`consolidate_target_cache`/`absorb_target_cache`/`consolidate_eval_next_tick`/`labor_alloc`/`labor_eval_next_tick`/`idle_employ_*`）→ **仍分岔**（＝那些 cache **不是**源）。
5. **★坐實**：還原 `need_urgency` **+** `plan_phase`（併 `current_option`/`goal_state` 一起還原）→ **零分岔（1200 tick）**。

## 修法選項（我沒動 production，你裁）
- **(a) 讓 tracer 不要重算 ctx**：`capture_options` **已經收到 `ctx` 參數**（真實 rank 算好的那份）；若能讓「可派性標記」不必呼 `to_task`（或提供只讀版 `to_task_probe(state, team, opt, ctx)` 不呼 gather），就從源頭消滅重算。**我的建議首選**——最小、且語意正確（觀測不該重跑決策）。
- **(b) 把 `gather` 拆成純讀 + 顯式推進**：`gather_readonly()`（不寫 EWMA/plan_phase/cache）與 `advance_decision_state()`（只有真決策路徑呼）。結構最乾淨、但動到熱路徑、影響面大（fp 會變）。
- **(c) 擴 `_begin_observe` 成「觀測 scope」**：進出時 snapshot/restore 那組決策狀態欄。**能修好（我實測就是這樣驗證的）但脆**——欄位新增就漏（我這輪自己加的 `expand_eval_next_tick` 就是新欄），治症不治根。
- 附帶：`plan_phase` 目前**只有 GUI/敘事在讀**卻進 fingerprint；若它本來就不該影響 determinism 判定，另有一條「把它移出 fp」的路，但那會降低 drift 偵測力＝你的領域，我不擅自建議。

## 其他
- temp 開關/instrumentation **已全 revert**（`git checkout` 過，`grep TEMP investigation` = 0）；**A/B 重現床已 commit** `2d65e8e3`（純量測、零 production 改動、走白名單 env）。
- **merge-gate 三項訂正也做完了**：A 繼承-lite 拿掉 `known_member_states.erase`（`feat/faction-succession-lite` @`ed0e7501`）、B `quality_multiplier` 下界 0.25、C 讀寫端 tap（`feat/settlement-s4c` @`af474229`）；兩支重跑 TDD/constitution 75/determinism ×3 全綠，**fp 皆與訂正前相同**——因為 a4 warring 1000t 窗內沒有 L0 decay／升級完工／棄村／領袖團死事件，掛點 dormant（非沒生效）。D（§4b merge 後 `擴點` 也乘 `quality_multiplier`）我記著、§4b 收尾時加。

地基 KEEP。
