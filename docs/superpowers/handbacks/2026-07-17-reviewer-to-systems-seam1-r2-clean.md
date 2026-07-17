---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict] seam#1 REVISED spec：CLEAN，可 dispatch S1 implementer。3 個非阻斷 caveat 需交待 implementer/measurer。"
---

# R② 判決：seam#1 REVISED scope — CLEAN

## 逐項驗證（全部 file:line 核實無誤）

**5 findings（異質 skeptic）**：
1. terms.gd:170-171 註解「threat_react 只作小係數 modifier 非碾壓量級…threat 有無由 applicable gate 管」逐字核對無誤。terms.gd:176（備戰 clampf(慎重*0.9+好戰*0.2,0,1)）、:180（迎戰 好戰*0.7+(1-threat_react)*0.2，威脅越大確越低）、:239（economic weight 0.3+貪婪，max 1.3）核實。
   - 小瑕疵（非阻斷）：文中「野心→1.5(terms.gd:243)」——ambition weight 實際公式 `clampf(野心-0.2,0,1)*1.5`，clamp 上限 0.8×1.5=**1.2**，非字面 1.5（1.5 是乘數常數非最終權重上限）。不影響結論方向（threat 仍結構性被壓），但引用精度該修正。
2. decision_engine.gd:37 boost 條件 `opt in DecisionOptions.SURVIVAL_OPTION_SET` 核實；SURVIVAL_OPTION_SET（options.gd:52）確不含 threat/"survival"(FLEE)/備戰/迎戰/求和 → threat 確無 break-top boost。
3. task_arbiter.gd:9 PRIO_THREAT=70、:12 PRIO_DISPATCH=50、:20 ENGINE_SOURCES=["unified","solo"] 核實；`_decide_unified`(faction_ai_system.gd:1553) 以 "unified" source @PRIO_DISPATCH try_set，同層 self-replace 邏輯成立 → PRIO 塌層描述屬實。
4. faction_ai_system.gd:395 PREEMPT_MARGIN gate、:396 `rank_threat(ctx)` call site 核實。
   - 小瑕疵（非阻斷）：「唯一 call site」嚴格說是唯一**production** call site；`scripts/debug/threat_dissolution_check.gd:35/65` 另有兩處 debug harness 呼叫。不影響「剝離歸 threat-oracle」結論（S1 registry 化不改 rank_threat 簽章，harness 不受影響），僅供紀錄。
5. faction_ai_system.gd:405 `Probe.bump("threat.dispatch."+opt)` 核實，位在 :387-407 單一 for-loop 內，此 loop 同時服務 idle-非unified 門檻路（:391）與 busy-preempt 路（:395），是目前 threat.dispatch.* 的唯一 tap。確認：idle-**unified**隊在 :390 已提前 return（不進此 loop）→ 今天 unified 隊的 idle threat dispatch 本就無此 tap，只有 busy-preempt 分支有 tap。收斂後若移除本函式，唯一殘存的 tap 也隨之消失 = 盲點成立。

**S1 registry byte-identical claim**：options.gd:5-45 REGISTRY 本就是 Dictionary（GDScript 4 保插入序），`applicable()`(:57) 已 `for opt in REGISTRY` 迭代 → 序不變的前提成立。**但**：
- applicable() 現有 match 分支內嵌不少 **Probe.bump 診斷副作用**（e.g. `occupy.ctx_hastarget`/`occupy.appl_kill_pop`/`occupy.applicable` :102-108、`produce.appl_kill_nofacility` :76）。registry 化若把 guard 抽成 per-entry lambda，這些副作用必須逐條精確保留（非只保 out.append 邏輯），否則「byte-identical」在**觀測層**（非只行為層）會破——撞 `[[feedback_full_transient_observability]]` 不變量。measurer S1 驗收清單應明確含「Probe 計數 byte-identical」非只「dispatch 結果 byte-identical」。
- applicable() 頂部的 subteam 通用閘（:60-64 `if ctx.is_subteam and opt in STRATEGIC_SELFINIT_SET: continue`）是跨所有 entry 的共用前置閘，registry 化須確保此閘仍**在每 entry predicate 之前統一套用**（非要求每個新 entry predicate 自己重複判斷，否則未來加 option 忘記=靜默破 A2a 不變量）。

**threat 剝離裁定**：同意 sound。rank_threat 非 scaffolding，是真選擇語意（量級刻意壓小 + applicable-gate 曝光 + 自有 FLEE raw 公式 + PRIO70 preempt 唯一路），與 rank_survival/rank_ambient（已是主 rank_scored 語意的 filtered view / 純 idle-filler）性質不同，不可同批次無腦收斂。剝離到 threat-oracle arc（4 前置齊備才收斂）是對的技術判斷，非拖延。

**survival/ambient 逐路驗 plan**：rank_ambient 排除 FLEE/survival/threat（options.gd 對應 :156 註解，decision_engine.gd 同函式內）核實，純 idle-filler 定性成立。
- 一點須在 S2 逐路驗清單明列（非阻斷 S1，但擋 S2 CLEAN）：rank_survival 的 churn-guard 用 **previous_task**（decision_engine.gd:114-118，比對 `team.previous_task`），而 rank_scored 的 COMMITMENT_BONUS 用 **current_option**（:46 `if opt == current_option`）。這是兩套不同狀態源的黏性判斷；non-unified 隊 collapse 進 rank_scored 前，previous_task 語意（release→IDLE 後仍保底防抖）能否被 current_option 語意等價覆蓋，需獨立驗證，不能假設兩者同構。

## 判準結果
**CLEAN → dispatch S1 implementer**（byte-identical TDD，git per-slice，measurer byte-identical 驗——含上述 Probe 計數 byte-identical 要求）。
S2（survival/ambient）留待 systems 逐路驗 plan 明列上述 previous_task/current_option 差異點後再送 R②。
threat 剝離裁定不需再審，歸 threat-oracle arc 序3-4。

## 溯源
Spec `docs/superpowers/specs/2026-07-17-seam1-control-flow-convergence.md`；systems handback `2026-07-17-R2-systems-to-reviewer-seam1-control-flow.md`；file:line 逐條見上。
