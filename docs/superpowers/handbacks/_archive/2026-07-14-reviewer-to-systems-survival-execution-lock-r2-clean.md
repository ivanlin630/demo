---
from: reviewer
to: systems
status: consumed
topic: "[R②判決·CLEAN] 求生執行鎖 thrash-fix——5點refute全過,可dispatch implementer"
---

# R② 判決：求生執行鎖 thrash-fix

verdict: **clean**
premise_contradiction: false

## 逐點驗（file:line 全查證，非採信 spec 轉述）

1. **root 歸屬**：`grep -c "\[Survival\] Team14"` = 122（與 spec 數字精確吻合），`grep -c "\[SubAI\] Team14"` = 6。thrash 絕大多數（122 vs 6）確屬 `_evaluate_survival:3117` 印出的 legacy recognizer 路徑，非引擎 `_decide_subteam`。命中 thrash 源。
2. **dual-producer 殘留**：讀 `task_arbiter.gd:38-86` `try_set` 全文——引擎 @PRIO_DISPATCH(50) 想搶 legacy @PRIO_SURVIVAL(80) HOLD 的隊：`priority > team.task_priority`(50>80)false；A1a 同層 self-replace 僅認 `ENGINE_SOURCES=["unified","solo"]`(`:20`)，`"subteam"` 不在列；PLAYER 抗命分支門檻不合（task_priority≠60）→ 三路皆不放行 → `return false`。無 race，HOLD 正確擋下。
3. **不誤傷正常 task**：`_in_survival` 兩條件（`current_task in SURVIVAL_TASKS` / `task_priority==PRIO_SURVIVAL`）對 @PRIO_DISPATCH(50) 的正常貿易/攻擊隊皆 false，行為不變。另查 `:1167`（founding busy-gate）用 `task_priority > PRIO_DISPATCH` 本已涵蓋 PRIO_SURVIVAL(80>50)，不需改動，spec 未動此處正確；`:1453` 該條件後接 `pass`（死碼，無功能影響），不改動亦正確。
4. **不永久鎖**：`:3096` recover-hysteresis（`days_left >= SURVIVAL_RECOVER_DAYS` 才 release）+ `:3102` cadence-relatch（`decision_eval_next_tick` 到期或 crisis 才重評換選項）讀過，非死鎖，確為既有執行鎖機制。
5. **invariant**：`_in_survival` 為純讀 helper（讀既有 `task_priority` 欄），三處呼點皆條件判斷改寫、無新 `try_set`/mutation site → determinism/憲法 site-freeze 不動。

Fix B（SpecimenTracer tap）：`specimen_tracer.gd:51` 簽名 `capture_decision(state, team, winner_opt, task, target)` 核對，spec 提案呼叫 `(state, sub, opt, td["task"], tgt)` 參數順序對；`grep` 確認既有 4 處 tap（`:1480/1523/1876/3217`）、`_decide_subteam`(`:1742`) 確漏。`is_specimen` gate 內建 no-op-unless-specimen，claim 屬實。

## 框外審評估
同意 systems 評估——非三對齊（單檔 recognizer 修+一行 tap，engage 既有機制，非強結論 redirect 大工/非 ironclad 難逆）。標準 R② 審已足，未升異質框外審。

## 附註（非 issue，供留意）
spec refute 點1原句「非引擎[SubAI]（~2-3×）」實測比值為 122:6（~20x），非 2-3x——數字方向正確（legacy 主導）但比例描述偏差，不影響 CLEAN 判決。

## 結論
5 點 refute 皆過、Fix A/B 前提與設計皆 file:line 坐實，無 premise_contradiction、無 issue。**CLEAN → 可直接 dispatch implementer。**
