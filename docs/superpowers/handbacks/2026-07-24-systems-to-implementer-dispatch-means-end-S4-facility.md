---
from: systems
to: implementer
status: consumed
topic: "[dispatch·means-end S4 設施發展 goal-set+設施/人力型前置(8 座設施鏈)·spec HOW §10 S4+組件 C 設施/人力 handler+B registry 8 設施+E NeedOracle CONSTRUCTION_COST_RES 泛化(此 slice 才真需)·★順帶撿 unowned track(build_F 目標 outpost owned/unowned 前置自然處理)·★base=LOCAL main HEAD 73f4e322(含 S3)非 origin·新 branch feat/means-end-s4-facility off local HEAD] S1 骨架/S2 資源型/S3 定位型(含閉環)已 merged。S4=設施發展:8 座設施 goal(build_farming/workshop/apothecary/mint/stable/smeltery/weaponsmith/armorsmith)→設施/人力型前置。修:①GoalRegistry(組件 B)填 8 座 build_F goal 前置(照既有 OutpostSystem.FACILITY_DEF/OUTPOST_COST):resource 前置=F build-cost(material/tools,讀 FACILITY_DEF cost)+facility/location 前置=F 需 allowed_outpost type(mil-facility 需 military outpost→需有該 type outpost=facility 前置遞迴 or location outpost-type)+manpower 前置=build pop 門檻(既有 _dispatch_facility_builder pop<6/_check)②設施型前置 handler(組件 C):{kind:facility,facility:F}→隊自有 outpost 有 F?無→生『建 F』frontier(遞迴 build_F 或直接建 candidate),to_task 接既有 _dispatch_facility_builder/facility build 機械③人力型前置 handler(組件 C):{kind:manpower,pop:N}→pop<N→★S4 最小:pop 靠 passive 繁殖增長無主動 task→該 goal thread 這輪靜默無 frontier(等 passive)or 接既有 recruit option 若存在;別造假 candidate(whole-system-first,人力主動增=後續精修)④★build_F action(前置全滿)→建 F candidate:to_task 接既有建 facility 機械(_dispatch_facility_builder/start facility build)⑤facility goal 生成(組件 A,S4 最小):隊對 F 有 desire(既有 _facility_deficit 信號>threshold)→掛 build_F goal;S7 才做 util-門檻掛退泛化⑥★NeedOracle CONSTRUCTION_COST_RES 泛化(組件 E,此 slice 才真需):facility build-cost 前置 need 傳播——但既有 _construction_facility_need 已處理 material/tools build-cost,S4 build_F resource 前置可直接讀 FACILITY_DEF cost as qty(不一定動 CONSTRUCTION_COST_RES;若 build_F 遞迴需泛化則做,你判+我 R² 收)⑦must-fix① util 護欄沿用 S2 _candidate_util(GOAL_UTIL_CAP+dev_coeff,絕境設施 goal 折趨零)⑧★順帶撿 unowned track(reviewer R²):build_F 若目標 outpost 需 unowned/owned 判定→自然在此 facility 前置處理(隊自有 outpost 才建 facility;S3 material build outpost 的 unowned 靠既有 start_build 擋不變)。TDD:①8 座 build_F goal registry 前置正確(對 FACILITY_DEF)②設施型前置 handler 生建 F candidate(缺設施+資源夠+pop 夠→建 F)③人力前置 pop<N handler(靜默 or recruit,無假 candidate)④build_F 前置未滿遞迴(缺 material→接 S2/S3 資源鏈)⑤must-fix① range 斷言 regression(絕境設施 goal<survival)⑥determinism 2 跑 byte-identical(禁 randf)。閘:constitution_gate 74 removed=0(讀 belief 禁 RNG,facility 讀自有 outpost 非 god-view)+headless 0-new+determinism。★whole-system-first:S4 只設施+人力型;子目標遞迴/折現/委派=S6/S5 別提前(build_F 遞迴到資源=接 S2/S3 既有鏈 OK,非新)。完成=systems+reviewer R²(非自判)→to:systems 收驗+S4 R²。task=systems+reviewer。"
branch: feat/means-end-s4-facility
---

# dispatch：means-end S4 設施發展 goal-set + 設施/人力型前置（8 座設施鏈）

S1/S2/S3（含閉環）已 merged。**S4 = 設施發展**：8 座設施 goal + 設施/人力型前置。

## ★★base 鐵律
- off **LOCAL main HEAD `73f4e322`**（含 S3）非 origin。

## 修（spec 組件 A/B/C/E + F 護欄）
1. **GoalRegistry**（組件 B）填 8 座 `build_F` goal 前置（照既有 `OutpostSystem.FACILITY_DEF`/`OUTPOST_COST`）：
   - resource 前置 ＝ F build-cost（material/tools，讀 FACILITY_DEF cost）。
   - facility/location 前置 ＝ F 需 allowed_outpost type（mil-facility 需 military outpost → 需有該 type outpost）。
   - manpower 前置 ＝ build pop 門檻（既有 `_dispatch_facility_builder` pop 檢查）。
2. **設施型前置 handler**（組件 C）：`{kind:"facility", facility:F}` → 隊自有 outpost 有 F？無 → 生「建 F」frontier（遞迴 build_F 或直接建 candidate），to_task 接既有 `_dispatch_facility_builder`/facility build。
3. **人力型前置 handler**（組件 C）：`{kind:"manpower", pop:N}` → pop<N → ★**S4 最小**：pop 靠 passive 繁殖增長無主動 task → 該 goal thread 這輪**靜默無 frontier**（等 passive）or 接既有 recruit option 若存在；**別造假 candidate**（whole-system-first，人力主動增 = 後續精修）。
4. **★build_F action**（前置全滿）→ 建 F candidate：to_task 接既有建 facility 機械。
5. **facility goal 生成**（組件 A，S4 最小）：隊對 F 有 desire（既有 `_facility_deficit` 信號 > threshold）→ 掛 build_F goal；S7 才做 util-門檻掛退泛化。
6. **★NeedOracle `CONSTRUCTION_COST_RES` 泛化**（組件 E，此 slice 才真需）：既有 `_construction_facility_need` 已處理 material/tools build-cost，S4 `build_F` resource 前置可直接讀 FACILITY_DEF cost as qty（不一定動 `CONSTRUCTION_COST_RES`；若 build_F 遞迴需泛化則做，你判 + 我 R² 收）。
7. **must-fix① util 護欄沿用** S2 `_candidate_util`（絕境設施 goal 折趨零）。
8. **★順帶撿 unowned track**（reviewer R²）：build_F 若目標 outpost owned/unowned 判定 → 自然在此 facility 前置處理（隊自有 outpost 才建 facility；S3 material build outpost 的 unowned 靠既有 start_build 擋不變）。

## TDD
1. 8 座 build_F goal registry 前置正確（對 FACILITY_DEF）。
2. 設施型前置 handler 生建 F candidate（缺設施 + 資源夠 + pop 夠 → 建 F）。
3. 人力前置 pop<N handler（靜默 or recruit，無假 candidate）。
4. build_F 前置未滿遞迴（缺 material → 接 S2/S3 資源鏈）。
5. must-fix① range 斷言 regression（絕境設施 goal < survival）。
6. determinism 2 跑 byte-identical（禁 randf）。

## 閘 + 紀律
- `constitution_gate` 74 removed=0（讀 belief 禁 RNG，facility 讀自有 outpost 非 god-view）+ headless 0-new + determinism。
- ★**whole-system-first**：S4 只設施 + 人力型；子目標遞迴/折現/委派 = S6/S5 別提前（build_F 遞迴到資源 = 接 S2/S3 既有鏈 OK，非新）。
- 完成 = **systems + reviewer R²**（非自判）→ `to:systems` 收驗 + S4 R²。
