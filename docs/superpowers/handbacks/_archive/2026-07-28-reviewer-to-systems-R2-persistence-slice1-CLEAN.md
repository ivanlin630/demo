---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN + scope 裁] 持守統一 Slice 1 決策層——世界不凍回歸親算確認，SOLO skip/survival_stall 排除兩項裁准，merge放行"
---

# R② 判決：持守統一 Slice 1 決策層 bonus-collapse — CLEAN

## 核心機制核實
`PersistStrength._value`：`progress=clampf(elapsed/horizon,0,1)`（`elapsed=current_tick-task_start_tick`——親核 `task_start_tick` 是 `try_set`/`transition` 既有維護欄位，非新造，沉沒成本 proxy 有真實依據）× `lean=clampf(0.5+(stick-flex),0.2,1.0)`（`慎重`+`義氣`→stick / `貪婪`+`野心`→flex，WHAT spec 原留給 plan 定的 mapping 細節，implementer 選的替代確實對應 WHAT 自己舉的例子「慎重/固執→沉沒、貪婪/機會→前瞻」，屬授權範圍內判斷非過界）× clamp `PERSIST_CAP(0.3)`。TDD `_test_clamp_below_crisis` 親驗 `0.3<SURVIVAL_BOOST_MAX(2.5)`——持守偏置量級遠低於危機層，危機永遠打得斷，latch 反例守住。

## ★世界不凍回歸——親算數字合理
`teams 49→64`（成長非停滯）、`attrition 1.13% vs baseline 1.80%`（兩者皆非 0，皆活）——跟 latch 那次「凍結」的訊號完全不同型態（那次是全世界churn歸零）。這正是吸取 latch 教訓後該做的回歸檢查，做對了。

## progressive-only gate
`NON_PROGRESSIVE=[TASK_IDLE,TASK_FLEE]`——FLEE 排除吻合我 R①「FLEE 無 progress 概念」的發現，一致。

## ★scope 裁定（你請裁的兩項）
1. **`SOLO_COMMITMENT_BONUS`＝skip**：親 grep 全庫，**唯一命中是它自己的宣告行**——零消費者，貨真價實死碼。裁准：skip 正確，這次不用管（要不要順手刪死碼是另一個決定，非本 slice 責任）。
2. **`survival_committed_stall`＝排除本 slice**：`stall_patience_factor`（我在更早的 latch/S5 審查輪已親讀過此函式）＝`clampf(caution+(1.0-survival),MIN,MAX)`——**本來就已經人格加權，非 flat**。裁准：**排除正確，且不該勉強塞進這個新公式**——它已經是個成熟、獨立的機制，硬套統一公式只是製造第二套解同一問題的邏輯（跟我這 session 一貫在盯的「冗餘求解器」同款毛病），非真收斂。留它獨立運作，若未來 whole-measure 真的發現它跟新公式打架或有縫，再議；現在不是必須合併的理由。

## TDD/gate
5 個測函式、10 條斷言，逐條讀過對得上（progressive-gate 3+sunk-cost 2+人格分化 2+clamp 2+寫欄 1）；`_argmax_intent` 新增 `persist_bonus` 參數帶 `COMMANDER_COMMITMENT_BONUS` 預設值——保純函式/測試呼叫端不必改，只有真正被替換的 3 個 live call site（`select_strategic_intent`/`_evaluate_independent_strategy`/`decision_engine.gd` 兩處）改傳新值，符合 HOW spec §7「call site 不必逐個改」的精神。

## 判決
**CLEAN → merge。** Slice 1（決策層自算自用）完整、乾淨、世界不凍驗證到位。SOLO skip + survival_stall 排除兩項裁准，記入 spec 或 known_issues 供後續 slice/whole-measure 參考。→ dispatch Slice 2（進度事件新鮮度，construction-tick 真接線）。
