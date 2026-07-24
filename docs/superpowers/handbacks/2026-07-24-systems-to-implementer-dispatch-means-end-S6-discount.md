---
from: systems
to: implementer
status: open
topic: "[dispatch·means-end S6 折現(組件 F)+人格折現率·投資型 util=payoff×折現(延遲,人格)·絕境不走遠路 forest·★must-fix① 護欄 range 斷言 S6 回歸點(reviewer 指定,折現改 _candidate_util 必驗護欄仍守)·★base=LOCAL main HEAD b381b5f7(含 S5)非 origin·新 branch feat/means-end-s6-discount off local HEAD] S1-S5 已 merged(means-end 湧現鏈+委派齊)。S6=折現:遠慾望『看得遠』——投資型(延遲回本)candidate util 按延遲×人格折現率折,絕境隊折趨零不走遠路(WHAT §6)。修(spec 組件 F):①_candidate_util 加 delay-based discount(連續非投資/即時硬分,符憲法 utility 連續):util=payoff×dev_coeff×discount(delay,rate) clamp GOAL_UTIL_CAP;delay=0→discount≈1(近/即時幾乎不折)/delay 大→折重②delay 估(淺啟發有界):to_task target hex dist(移動天數,_hex_dist÷移速估)+build ticks(TASK_BUILD/SETTLE 讀既有 BUILD_TICKS)→delay_days③discount 函數:1/(1+rate×delay_days)(delay=0→1,遞減有界)④★人格折現率 rate(WHAT §6『人格=折現率』,權重非 gate):rate=DISCOUNT_BASE×(絕境因子−慎重/耐心因子);絕境 food_days→0→rate 高(短視,遠 candidate 折趨零→不走遠路 forest 輸眼前糧危)/慎重耐心高→rate 低(遠視肯投遠利)⑤★護欄:dev_coeff(絕境→0 must-fix①)+clamp GOAL_UTIL_CAP 保留,折現在其中乘(折現只會讓 util 更小非更大→護欄不破);投資型 discount 是額外壓遠端,survival boost 破頂仍優先。TDD:①投資型遠 forest candidate 折現(delay 大→util 低於近 candidate)②即時/近 candidate 幾乎不折(delay 小→discount≈1)③人格折現率(慎重 vs 衝動同 delay 不同 discount=遠視 vs 短視)④★絕境(food_days 低)→rate 高→遠 candidate 趨零(不走遠路,WHAT §6 效果硬驗)⑤★★must-fix① range 斷言 regression(reviewer S6 指定回歸:折現後絕境 goal candidate util 仍<survival-boosted static,clamp 不破)⑥determinism 2 跑 byte-identical(折現純算術讀狀態,禁 randf)。閘:constitution_gate 74 removed=0+headless 0-new+determinism。★whole-system-first:S6 只折現;goal 生成 cadence 泛化+perf optimize+(A)perf(B)facility-type followup=S7 別提前。完成=systems+reviewer R²(★reviewer 查 must-fix① range 護欄折現後仍守+人格折現率語意+delay 估有界)→to:systems 收驗+S6 R²。task=systems+reviewer。"
branch: feat/means-end-s6-discount
---

# dispatch：means-end S6 折現（組件 F）+ 人格折現率

S1-S5 已 merged（means-end 湧現鏈 + 委派齊）。**S6 = 折現**：遠慾望「看得遠」——投資型（延遲回本）candidate util 按延遲 × 人格折現率折，**絕境隊折趨零不走遠路 forest**（WHAT §6）。

## ★★base 鐵律
- off **LOCAL main HEAD `b381b5f7`**（含 S5）非 origin。

## 修（spec 組件 F）
1. **`_candidate_util` 加 delay-based discount**（連續，非投資/即時硬分 ＝ 符憲法 utility 連續）：`util = payoff × dev_coeff × discount(delay, rate)` clamp `GOAL_UTIL_CAP`；delay=0 → discount≈1（近/即時幾乎不折）/ delay 大 → 折重。
2. **delay 估**（淺啟發有界）：to_task target `_hex_dist`（移動天數÷移速估）+ build ticks（TASK_BUILD/SETTLE 讀既有 `BUILD_TICKS`）→ delay_days。
3. **discount 函數**：`1/(1+rate×delay_days)`（delay=0→1，遞減有界）。
4. **★人格折現率 rate**（WHAT §6「人格=折現率」，權重非 gate）：`rate = DISCOUNT_BASE × (絕境因子 − 慎重/耐心因子)`；絕境 `food_days→0` → rate 高（短視，遠 candidate 折趨零 → **不走遠路 forest 輸眼前糧危**）/ 慎重耐心高 → rate 低（遠視肯投遠利）。
5. **★護欄**：`dev_coeff`（絕境→0，must-fix①）+ clamp `GOAL_UTIL_CAP` 保留；折現在其中**乘**（折現只會讓 util 更小非更大 → 護欄不破）；survival boost 破頂仍優先。

## TDD
1. 投資型遠 forest candidate 折現（delay 大 → util 低於近 candidate）。
2. 即時/近 candidate 幾乎不折（delay 小 → discount≈1）。
3. 人格折現率（慎重 vs 衝動同 delay 不同 discount ＝ 遠視 vs 短視）。
4. ★**絕境**（food_days 低）→ rate 高 → 遠 candidate 趨零（不走遠路，WHAT §6 效果硬驗）。
5. ★★**must-fix① range 斷言 regression**（reviewer S6 指定回歸：折現後絕境 goal candidate util 仍 < survival-boosted static，clamp 不破）。
6. **determinism 2 跑 byte-identical**（折現純算術讀狀態，禁 randf）。

## 閘 + 紀律
- `constitution_gate` 74 removed=0 + headless 0-new + determinism。
- ★**whole-system-first**：S6 只折現；goal 生成 cadence 泛化 + perf optimize + (A)perf/(B)facility-type followup = S7 別提前。
- 完成 = **systems + reviewer R²**（★reviewer 查 must-fix① range 護欄折現後仍守 + 人格折現率語意 + delay 估有界）→ `to:systems` 收驗 + S6 R²。
