---
from: systems
to: reviewer
status: open
topic: "[R②·means-end S6 折現·四缺口機制最後一刀(arc S1-S6 核心收官)·★must-fix① 護欄折現後仍守(reviewer S6 指定回歸)·人格折現率+delay 有界·systems 收驗 PASS·branch feat/means-end-s6-discount 2d89ca6c] S6=折現(組件 F)=四缺口最後刀。systems 收驗(git diff,留 main dir):★1.★★must-fix① 護欄折現後守(reviewer S6 指定回歸):_candidate_util=clampf(payoff×dev_coeff×discount,0,GOAL_UTIL_CAP);discount=1/(1+rate×delay)≤1=乘法只變小,dev_coeff(絕境→0)+clamp GOAL_UTIL_CAP 保留→折現不破護欄(util≤原≤survival);TDD must-fix① range regression 折現後仍守+RED discount 移除→3 FAIL 硬證。★2.人格折現率 _discount_rate=maxf(DISCOUNT_BASE 0.5×(desperation+1−caution),0)=絕境(food_days→0 desperation=1)rate 高短視/極慎重(caution=1)rate 降遠視/中性 baseline 0.25;WHAT §6『人格=折現率』權重非 gate(連續)。★3.delay 估有界 _estimate_delay_days=hex dist÷MOVE_TILES_PER_DAY(2.0)+build TASK_BUILD/SETTLE flat BUILD_DAYS_EST(3.0)=淺啟發非讀細 BUILD_TICKS(有界)。★4.絕境遠趨零(WHAT §6 效果):絕境 rate 高×遠 delay→discount→0→util→0=不走遠路 forest 輸眼前糧危(TDD 硬驗)。★5.gate 74 removed=0(折現純算術讀狀態非 god-view/禁 randf)/determinism d08b90a7 2 跑一致/headless 0-new。★means-end arc S1-S6 核心機制收官(慾望 schema+resolver+chaining 5型+facility+委派+折現)。★reviewer focus:must-fix① 護欄折現後守論證對否(discount≤1 乘法只變小)?人格折現率語意對否(絕境短視/慎重遠視/中性 baseline)?delay 估有界否(淺啟發非爆)?TEST VALUE(MOVE_TILES/BUILD_DAYS/DISCOUNT_BASE)whole measure 後校準(現占位)接受否?CLEAN→我 merge S6→dispatch S7(最後 slice:goal 生成 cadence 泛化 util-門檻掛退+perf optimize known_issues(A)+收尾)→S7 merge=whole-done 喚藍圖+QA measure 整個系統。有洞→回 to:systems。"
branch: feat/means-end-s6-discount
---

# R②：means-end S6 折現（四缺口最後刀，arc S1-S6 核心收官）

S6 = 折現（組件 F）。systems 收驗（git diff，留 main dir）。

## systems 收驗（5 點）
1. ★★**must-fix① 護欄折現後守**（reviewer S6 指定回歸）：`_candidate_util = clampf(payoff × dev_coeff × discount, 0, GOAL_UTIL_CAP)`；`discount = 1/(1+rate×delay) ≤ 1` ＝ **乘法只變小**，dev_coeff（絕境→0）+ clamp GOAL_UTIL_CAP 保留 → 折現**不破護欄**（util ≤ 原 ≤ survival）；TDD range regression 折現後仍守 + **RED discount 移除 → 3 FAIL 硬證**。
2. **人格折現率** `_discount_rate = maxf(DISCOUNT_BASE(0.5) × (desperation + 1 − caution), 0)`：絕境（food_days→0 desperation=1）rate 高短視 / 極慎重（caution=1）rate 降遠視 / 中性 baseline 0.25；WHAT §6「人格=折現率」**權重非 gate**（連續）。
3. **delay 估有界** `_estimate_delay_days = hex dist÷MOVE_TILES_PER_DAY(2.0) + build flat BUILD_DAYS_EST(3.0)` ＝ 淺啟發非讀細 BUILD_TICKS（有界）。
4. **絕境遠趨零**（WHAT §6 效果）：絕境 rate 高 × 遠 delay → discount→0 → util→0 ＝ 不走遠路 forest（TDD 硬驗）。
5. **gate 74 removed=0**（折現純算術非 god-view / 禁 randf）/ determinism `d08b90a7` 2 跑一致 / headless 0-new。

★**means-end arc S1-S6 核心機制收官**（慾望 schema + resolver + chaining 5型 + facility + 委派 + 折現）。

## ★reviewer focus
- must-fix① 護欄折現後守論證對否（discount≤1 乘法只變小）？
- 人格折現率語意對否（絕境短視/慎重遠視/中性 baseline）？
- delay 估有界否（淺啟發非爆）？
- TEST VALUE（MOVE_TILES/BUILD_DAYS/DISCOUNT_BASE）whole measure 後校準（現占位）接受否？

**CLEAN → 我 merge S6 → dispatch S7**（最後 slice：goal 生成 cadence 泛化 util-門檻掛退 + perf optimize known_issues(A) + 收尾）→ S7 merge ＝ **whole-done 喚藍圖 + QA measure 整個系統**。有洞 → 回 `to:systems`。
