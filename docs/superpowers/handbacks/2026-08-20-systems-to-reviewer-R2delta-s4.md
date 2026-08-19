---
from: systems
to: reviewer
status: open
topic: "[R² delta 審(blueprint 明示 delta 非全審)·settlement §4 戰略蓋點 engine 化 + de-scaffold HOW·spec=2026-08-20-settlement-S4-strategic-siting-HOW.md·R①免(前提=結構事實:constitution baseline_v2:77-78 兩站/_evaluate_l0_settle:4777 唯一 caller:838/options.gd REGISTRY 面/population_system.check_overflow_for_team/既有 write_memory 機制、皆 file:line 可查、無未驗因果斷言;★本 spec 刻意不鎖在 pending-QA 那兩條長跑因果[labor-v2 accepted cost/churn attribution])·★審點:①★de-scaffold 正確性:刪 _evaluate_l0_settle+caller、功能全落新『紮根』engine option→2 constitution 站(taskarbiter/threshold)是否真自然消失(dispatch 走引擎單源 TaskArbiter、threshold 收進 util)、還是會在別處復現新站?②★hard gate→util 的 de-patch 是否過頭:viability(食夠不夠撐工期)從 applicable hard gate 改成 util term(ETA vs food_runway)——瀕餓團真的會被 util 過濾掉嗎?還是可能開工後餓死變常態(=從『不開工』變『開工餓死』的行為劣化)?你判該不該保留一個最小 applicable 物理下限③零新旋鈕檢查:擴張邊際帳宣稱只讀既有(MarginalEconomy._inflow_est/ctx.idle_labor/farming/倉)、可行性帳只讀既有(food_runway/ETA 同 persist_strength._safe_factor 量)——真有既有量可用嗎?哪裡會被迫發明常數?④★overflow 決策化的保底設計:機械 split 降 last-resort(延遲/margin)而非刪——我留給你議具體形式;風險=決策沒動作時 pop 卡 cap 無出口 vs 保底太早 fire 決策化失效⑤反饋迴路:self-knowledge/零新管道/禁永久黑名單(weight 衰減或有效期)是否足夠、會不會變成隱性全域黑名單⑥替代同秤:『1 人碎片蓋不如投』真能從可行性帳湧現、還是需要額外項(=WHAT 補定③說純可行性帳算出、我照做、你驗合不合理)·slice 序:§4a(硬 gate de-scaffold 本 slice 完成)→§4b(三動機+overflow 決策化 fp 大)→§4c(反饋)·CLEAN→我 dispatch §4a·地基KEEP"
---

# R² delta 審：settlement §4 戰略蓋點 engine 化 + de-scaffold

spec=`docs/superpowers/specs/2026-08-20-settlement-S4-strategic-siting-HOW.md`。**delta 審非全審**（blueprint 明示）。**R① 免**（前提=結構事實、file:line 可查、無未驗因果斷言；★本 spec **刻意不鎖在 pending-QA 那兩條長跑因果**）。

## ★審點
1. **★de-scaffold 正確性**：刪 `_evaluate_l0_settle`(4777)+caller(838)、功能全落新「紮根」engine option → **2 constitution 站（taskarbiter/threshold）是否真自然消失**（dispatch 走引擎單源 TaskArbiter、threshold 收進 util），**還是會在別處復現新站**？
2. **★hard gate→util 的 de-patch 是否過頭**：viability（食夠不夠撐工期）從 applicable **hard gate** 改 **util term**（ETA vs food_runway）——**瀕餓團真的會被 util 過濾掉嗎**？還是可能**開工後餓死變常態**（=從「不開工」劣化成「開工餓死」）？**你判該不該保留一個最小 applicable 物理下限**。
3. **零新旋鈕檢查**：擴張邊際帳宣稱只讀既有（`MarginalEconomy._inflow_est`/`ctx.idle_labor`/farming/倉）、可行性帳只讀既有（`food_runway`/ETA 同 `persist_strength._safe_factor` 量）——**真有既有量可用嗎？哪裡會被迫發明常數**？
4. **★overflow 決策化的保底設計**：機械 split 降 **last-resort**（延遲/margin）而非刪——**具體形式留你議**；風險兩端=決策沒動作時 **pop 卡 cap 無出口** vs 保底**太早 fire→決策化失效**。
5. **反饋迴路**：self-knowledge / 零新管道 / **禁永久黑名單**（weight 衰減或有效期）是否足夠、**會不會變成隱性全域黑名單**？
6. **替代同秤**：「1 人碎片蓋不如投」**真能從可行性帳湧現**、還是需要額外項？（WHAT 補定③說「純可行性帳算出」、我照做、你驗合不合理。）

slice 序：**§4a**（★硬 gate de-scaffold 本 slice 完成）→ **§4b**（三動機+overflow 決策化、fp 大）→ **§4c**（反饋）。CLEAN → 我 dispatch §4a。地基 KEEP。
