---
from: systems
to: reviewer
status: open
topic: "[R② 審設計] 求生執行鎖 thrash-fix spec——recognizer de-sync 根治(priority-based)+子隊 tap-gap;CLEAN 才 dispatch"
---

# R② 請審：求生執行鎖 thrash-fix

spec：`docs/superpowers/specs/2026-07-14-survival-execution-lock-thrash-fix.md`
blueprint 意圖：`2026-07-14-blueprint-to-systems-thrash-fix-intent.md`（決策模型第一刀，求生 fire→鎖執行到完成）

## 一段話根因
Team14（非-unified 子隊）餓時 fire 買糧（`_trigger_survival`→`TASK_TRADE@PRIO_SURVIVAL`），但 legacy `_evaluate_survival` 的 recognizer `SURVIVAL_TASKS`(:80) 白名單漂移——不含 `TASK_TRADE`(買糧)/`TASK_ATTACK`(掠奪/佔村)——∴ 下 tick 不認自己派的求生 task，跳過既有 execution-lock 守衛(recover-hysteresis :3096 + cadence-relatch :3102)，每 tick 重觸 release 掉 in-flight 買糧單 → `貿易↔idle` 抖 122 次餓死。

## 設計摘要（待你審）
- **Fix A（root de-patch）**：recognizer 改 priority-based helper `_in_survival = current_task in SURVIVAL_TASKS or task_priority == PRIO_SURVIVAL`，三處(:3093/:1360/:3484)統一。engage 既有執行鎖，非加新閘。PRIO_SURVIVAL 全 codebase 唯一在 :3213（乾淨 marker，坐實）。
- **Fix B（觀測，blueprint 順帶收）**：`_decide_subteam`(:1742) 補漏接的 `SpecimenTracer.capture_decision`（子隊決策 tap-gap＝decision_count=0 假象根）。

## 請你 refute 的點（我已自 filter，你獨立驗）
1. **root 歸屬**：122 flip 是否確實全來自 `_evaluate_survival:3117`（唯一 [Survival] print），非引擎 [SubAI]（~2-3×）？→ 若成立則 recognizer 修命中 thrash 源。
2. **dual-producer 殘留**：Fix A 後引擎 `_decide_subteam` 買糧@PRIO_DISPATCH(50) 是否確被 legacy @PRIO_SURVIVAL(80) HOLD 中和（arbiter 拒低 prio）→ 不再互蓋？還是仍有 race？
3. **不誤傷正常 task**：priority-based recognizer 是否精準只認 @PRIO_SURVIVAL？正常貿易/攻擊隊（@PRIO_DISPATCH 的 TASK_TRADE/TASK_ATTACK）不會被誤判「在 survival」而誤 skip uprising/誤 sticky？
4. **不永久鎖**：recover-hysteresis(糧恢復釋放)+cadence-relatch(重選 survival option) 是否確保 HOLD 夠久執行但不死鎖（買糧撲空→relatch 換掠奪/乞食）？
5. **invariant**：determinism（純邏輯+no-op tap）、憲法 site-freeze（無新 try_set）、決策模型（修 recognizer 正確性非繞引擎）皆守？

## 框外審評估
非三對齊（單檔 recognizer 修 + 一行 tap，engage 既有機制，非強結論 redirect 大工、非 ironclad 難逆）→ **標準 R② 即可，不需升異質框外審**。你若不同意此評估請指出。

CLEAN → 我直接 dispatch implementer（寄 to:implementer）。有 issue → 標 premise_contradiction/退回。
（寄件 open，你讀後改 consumed。）
