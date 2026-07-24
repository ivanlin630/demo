---
from: systems
to: implementer
status: open
topic: "[dispatch·means-end S5 委派 peer option(組件 D)+gate②正解+餘力 gate 多線·spec HOW §10 S5+§5·委派變體進 rank 池競 util(跟自己做並列)+委派 viability 真 guard 正解 gate②·★base=LOCAL main HEAD 2d953ff4(含 S4)非 origin·新 branch feat/means-end-s5-delegate off local HEAD] S1-S4 已 merged(means-end 湧現鏈打通)。S5=委派 peer option:build/settle 型 action『派子隊做』變體進 rank 池,跟『自己做』並列按 util 挑(WHAT §4 多線平行)。修(spec 組件 D):①委派變體(resolver 對 build/settle 型 candidate=TASK_BUILD[build_F/build outpost]/TASK_SETTLE 產兩變體:{delegate:false 自己做=既有}+{delegate:true 派子隊做});委派變體 to_task 接既有 SubteamSystem.dispatch 派子隊執行 action②★gate②正解(組件 D+known_issues DEFER 項):委派變體 applicable=**真 viability**(pop − settler_count[clampi(pop/4,2,5)] ≥ MIN_PARENT_POP_AFTER_DISPATCH=10),★attempt-gate 與 dispatch guard 同源→無 pop 8-12 浪費帶(舊 _try_dispatch_or_invite:567 attempt≥8 vs effective≥13 矛盾此處根治);pop 不夠→無委派變體(只自己做)③委派 util(組件 D):自己做 util 基礎+多線紅利(母隊留守本業+子隊並行=不離 food base)−餘力成本;TEST VALUE(S6 折現+校準)④餘力 gate 配額:能跑幾線=pop-guard(夠 pop 才有委派變體),窮隊少線/強權多線=寫實⑤must-fix① 護欄沿用(_candidate_util,委派變體 util 同 clamp<survival)。★_try_dispatch_or_invite(residency repopulate owned outpost 手評 heuristic)退役=若你委派 option 自然涵蓋 residency(派子隊 repopulate)則順帶 de-patch(constitution_gate removed=進度);若不涵蓋(residency 語意不同)則**標 followup 別強退**(需驗融合 residency 不退化),你判+我 R² 收。TDD:①委派變體出現(build/settle+夠 pop→delegate candidate 跟自己做並列 rank 池)②★gate②正解(pop 8-12 委派變體 not applicable[viability 不足]/pop≥13 applicable=attempt=dispatch 同源無浪費)③餘力 gate(pop 不夠→無委派變體)④委派 to_task 派子隊(SubteamSystem.dispatch)⑤must-fix① range 斷言 regression⑥determinism 2 跑 byte-identical(委派讀狀態禁 randf,tie-break)。閘:constitution_gate(委派讀 belief 禁 RNG;若退役 _try_dispatch_or_invite→removed 印進度)+headless 0-new+determinism。★whole-system-first:S5 只委派+gate②+餘力;折現完整=S6/goal 生成 cadence 泛化+perf=S7 別提前。完成=systems+reviewer R²(★reviewer 查 gate②正解+委派 viability+multi-line 無委派恆贏[applicable pop-guard 擋])→to:systems 收驗+S5 R²。task=systems+reviewer。"
branch: feat/means-end-s5-delegate
---

# dispatch：means-end S5 委派 peer option + gate② 正解 + 餘力 gate

S1-S4 已 merged（means-end 湧現鏈打通）。**S5 = 委派 peer option**：build/settle 型 action「派子隊做」變體進 rank 池，跟「自己做」並列按 util 挑（WHAT §4 多線平行）。

## ★★base 鐵律
- off **LOCAL main HEAD `2d953ff4`**（含 S4）非 origin。

## 修（spec 組件 D）
1. **委派變體**：resolver 對 build/settle 型 candidate（TASK_BUILD[build_F/build outpost]/TASK_SETTLE）產兩變體：`{delegate:false 自己做=既有}` + `{delegate:true 派子隊做}`；委派變體 to_task 接既有 `SubteamSystem.dispatch` 派子隊執行 action。
2. **★gate② 正解**（組件 D + known_issues DEFER 項）：委派變體 applicable = **真 viability**（`pop − settler_count[clampi(pop/4,2,5)] ≥ MIN_PARENT_POP_AFTER_DISPATCH=10`），★attempt-gate 與 dispatch guard **同源** → 無 pop 8-12 浪費帶（舊 `_try_dispatch_or_invite:567` attempt≥8 vs effective≥13 矛盾此處根治）；pop 不夠 → 無委派變體（只自己做）。
3. **委派 util**（組件 D）：自己做 util 基礎 + 多線紅利（母隊留守本業 + 子隊並行 = 不離 food base）− 餘力成本；TEST VALUE（S6 折現+校準）。
4. **餘力 gate 配額**：能跑幾線 = pop-guard（夠 pop 才有委派變體），窮隊少線/強權多線 = 寫實。
5. **must-fix① 護欄沿用**（`_candidate_util`，委派變體 util 同 clamp < survival）。

## _try_dispatch_or_invite 退役（你判）
- 若你委派 option **自然涵蓋 residency**（派子隊 repopulate owned outpost）→ 順帶 de-patch（constitution_gate removed = 進度）。
- 若不涵蓋（residency 語意不同）→ **標 followup 別強退**（需驗融合 residency 不退化）。我 R² 收。

## TDD
1. 委派變體出現（build/settle + 夠 pop → delegate candidate 跟自己做並列 rank 池）。
2. ★**gate② 正解**（pop 8-12 委派變體 not applicable[viability 不足] / pop≥13 applicable ＝ attempt=dispatch 同源無浪費）。
3. 餘力 gate（pop 不夠 → 無委派變體）。
4. 委派 to_task 派子隊（`SubteamSystem.dispatch`）。
5. must-fix① range 斷言 regression。
6. determinism 2 跑 byte-identical（委派讀狀態禁 randf，tie-break）。

## 閘 + 紀律
- `constitution_gate`（委派讀 belief 禁 RNG；若退役 `_try_dispatch_or_invite` → removed 印進度）+ headless 0-new + determinism。
- ★**whole-system-first**：S5 只委派 + gate② + 餘力；折現完整 = S6 / goal 生成 cadence 泛化+perf = S7 別提前。
- 完成 = **systems + reviewer R²**（★reviewer 查 gate② 正解 + 委派 viability + multi-line 無委派恆贏[applicable pop-guard 擋]）→ `to:systems` 收驗 + S5 R²。
