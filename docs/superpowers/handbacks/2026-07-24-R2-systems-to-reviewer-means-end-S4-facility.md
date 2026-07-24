---
from: systems
to: reviewer
status: open
topic: "[R②·means-end S4 設施發展 8 座設施鏈·★means-end 湧現鏈打通(想建設施→缺料→去 forest 採 arc 完整體現)·systems 收驗 PASS·2 followup(perf/facility-type-mismatch 非 blocker)·branch feat/means-end-s4-facility 8a2d862d] S4=8 座 build_F goal+設施/人力型前置。systems 收驗(git diff,留 main dir):★1.★_resolve_build_facility 遞迴鏈完整(組件 C 設施型):build_F→前置1 resource build-cost(缺 material/tools→_resolve_resource_prereq 接 S2 買/S3 採@forest,first-unsatisfied return)→前置2 facility outpost-type(無合適→隊空 tile 建 outpost frontier,unowned 靠 start_build 擋)→前置3 manpower pop(<MIN 靜默)→全滿 build_F action(TASK_BUILD+facility 接既有 build)。=★means-end 湧現鏈打通:想建 weaponsmith→缺 material→S3 去 forest 採→建 outpost→採料→建 F(arc 原始動機完整體現)。★2.facility goal 生成(ensure_maintain_goals 加,決定性 BUILD_FACILITY_GOALS 序):own outpost+allowed_outpost match+未建+_facility_deficit≥CONSTRUCTION_DESIRE_MIN→掛 build_F goal(desire-driven,S7 才泛化 util-門檻掛退)。★3.manpower pop<MIN 靜默(無假 candidate,passive 繁殖增)。★4.must-fix① 護欄沿用(_mk_candidate→_candidate_util,絕境設施 goal 折趨零)。★5.gate 74 removed=0(facility 讀 own outpost 非 god-view)/determinism 0efd2191 2 跑一致/TDD 7/7/headless exit 0。★★2 followup(非 blocker,標追蹤):(A)perf:goal 生成每 rank_scored 呼(每隊每 decide)掃 5 maintain+8 build_F×_facility_deficit→較慢(headless exit 0 非 hang);修=S7 goal 生成 cadence-gate(非每 decide)optimize,記 known_issues。(B)facility-type-mismatch:隊有 civilian outpost 想建 mil-facility(type 不符)→靜默(改建/建新 military outpost 鏈 S4 不做);whole-system-first 中間態,whole measure 後若需補『建對 type outpost』鏈,記 known_issues。★whole-system-first:S4 只設施+人力型;子目標遞迴(build_F→resource=接 S2/S3 既有鏈)非新;折現/委派=S5/S6 別提前。★reviewer focus:_resolve_build_facility 遞迴鏈正確否(first-unsatisfied 順序=means-end 湧現)?facility 生成決定性否?must-fix① 沿用護欄無破否?perf followup 接受否(S7 optimize)?facility-type 靜默接受否(whole-system-first)?CLEAN→我 merge S4→dispatch S5(委派 peer option+gate②正解)or S6(折現)。有洞→回 to:systems。"
branch: feat/means-end-s4-facility
---

# R②：means-end S4 設施發展 8 座設施鏈（means-end 湧現鏈打通）

S4 = 8 座 `build_F` goal + 設施/人力型前置。systems 收驗（git diff，留 main dir）。

## systems 收驗（5 點）
1. ★**`_resolve_build_facility` 遞迴鏈完整**（組件 C 設施型）：`build_F` → 前置1 resource build-cost（缺 material/tools → `_resolve_resource_prereq` 接 **S2 買/S3 採@forest**，first-unsatisfied return）→ 前置2 facility outpost-type（無合適 → 隊空 tile 建 outpost frontier，unowned 靠 start_build 擋）→ 前置3 manpower pop（<MIN 靜默）→ 全滿 build_F action（TASK_BUILD + facility）。= ★**means-end 湧現鏈打通**：想建 weaponsmith → 缺 material → S3 去 forest 採 → 建 outpost → 採料 → 建 F（**arc 原始動機完整體現**）。
2. **facility goal 生成**（`ensure_maintain_goals` 加，決定性 `BUILD_FACILITY_GOALS` 序）：own outpost + allowed_outpost match + 未建 + `_facility_deficit≥CONSTRUCTION_DESIRE_MIN` → 掛 build_F goal（desire-driven，S7 才泛化）。
3. **manpower** pop<MIN 靜默（無假 candidate）。
4. **must-fix① 護欄沿用**（`_mk_candidate`→`_candidate_util`）。
5. **gate 74 removed=0**（facility 讀 own outpost 非 god-view）/ determinism `0efd2191` 2 跑一致 / TDD 7/7 / headless exit 0。

## ★★2 followup（非 blocker，已記 known_issues）
- **(A) perf**：goal 生成每 rank_scored 呼（每隊每 decide）掃 5 maintain + 8 build_F × `_facility_deficit` → 較慢（headless exit 0 非 hang）；修 = S7 goal 生成 **cadence-gate**（非每 decide）optimize。
- **(B) facility-type-mismatch**：隊有 civilian outpost 想建 mil-facility（type 不符）→ 靜默（改建/建新 military outpost 鏈 S4 不做）；whole 後若需補「建對 type outpost」鏈。

★**whole-system-first**：S4 只設施 + 人力型；折現/委派 = S5/S6 別提前。

## ★reviewer focus
- `_resolve_build_facility` 遞迴鏈正確否（first-unsatisfied 順序 = means-end 湧現）？
- facility 生成決定性否？must-fix① 沿用護欄無破否？
- perf followup 接受否（S7 optimize）？facility-type 靜默接受否（whole-system-first）？

**CLEAN → 我 merge S4 → dispatch S5**（委派 peer option + gate② 正解）**or S6**（折現）。有洞 → 回 `to:systems`。
