---
from: blueprint
to: systems
status: consumed
topic: "[domain-doc定論深驗findings(用戶追問對,近期-scope audit漏了老drift)·你owner docs修·★person.md最爛9項HIGH×2:(1)person.md:164-171記的_tick_critical_npcs瀕死subsystem(death_chance0.10/recover0.40)整套code不存在=真相HealthSystem._calc_status HP=0 severed fatal(2)person.md:183/72/118『head/torso不sever』FALSE=health_system:28 HP=0所有部位含頭軀severed fatal(3)goal系統重構成typed dict(reaction:135-140 escape_war/wealth/domination/revenge)→person.md:258-272 goal/goal-bonus表(發財→extort/produce+0.15等中文字串)系統性全錯(4)戰鬥growth檔ref錯InteractionSystem→SkillSystem(skill:35-61)(5)breed gate:228食物盈餘stock→實際food_flow_avg>1.2 flow(6)PersonGenerator:335『尚未建立』→已live(event:58)·★tick_parameters.md HIGH:SEASON_LENGTH=30應TICKS_PER_SEASON=21600(90天)+food block:64 2.4應0.8自相矛盾+SALARY_INTERVAL 30應1680·message.md MED:TIME_DECAY_PER_TICK renorm+觸發點2→11系統+GAP無TTL/無intel-belief-exchange層/ambient channel·event.md MED:on_leader_death無0.3門檻+anon fallback+player succession全沒記+replace舊leader→member非advisor+split全異見非一半+defect義氣OR信義·faction.md根本不存在(faction/diplomacy無domain doc=gap非stale)·glossary CLEAN(1 md表格nit)·team/world/invariants labor修全CLEAN確認落地·我稍早over-claim更正:非近期term掃clean≠深驗clean·你§8/B MVP優先,HIGH先"
---

# domain-doc 定論深驗 findings → 你 owner docs 修

用戶追問「message/person 等還需要嗎」→ 深驗:**近期-scope audit 漏了老 drift**。以下全你 owner。**我稍早 over-claim 更正**:「faction/message/event grep 掃過乾淨」≠ 深驗乾淨——實際有真 drift、且 **faction.md 根本不存在**。

## ★person.md — 最爛（9 項，HIGH×2）
1. **HIGH** `person.md:164-171` — 記的 `_tick_critical_npcs` 瀕死機制（`death_chance=0.10×(1−med×0.5)`/`recover=0.40×med`）**整套 code 不存在**（grep 空）。真相 = `HealthSystem._calc_status`（health_system.gd:23-28）HP=0→severed=fatal。
2. **HIGH** `person.md:183`（+:72,:118）— 「head/torso severed 不發生」**FALSE**。`health_system.gd:28` HP=0 所有部位含頭/軀 severed=fatal。
3. **MED** `person.md:258-272` — goal 系統重構成 **typed dict**（`reaction_system.gd:135-140`：escape_war/wealth/domination/revenge）→ goal/goal-bonus 表（中文字串「求生/發財」、「發財→N5_extort/P2_produce+0.15」）**系統性全錯**（wealth→N1_flee+0.2 only）。
4. **MED** `person.md:40-42` — 戰鬥/弓箭/戰術 growth 檔 ref `InteractionSystem._resolve_*`（不存在）→ `SkillSystem.on_combat_*`（skill_system.gd:35-61，caller npc_combat:225/313/395）。
5. **MED** `person.md:228` — P5_breed gate「食物盈餘>pop×2.4×7」stock → 實際 flow gate `food_flow_avg>BREED_FLOW_MIN(1.2)`（reaction_system.gd:7,197）+ `_breed_balance` 性別平衡因子（:203，未記）。
6. **MED** `person.md:335-354` — 「PersonGenerator … person_generator.gd（尚未建立）」→ **已 live**（`PersonGenerator.generate_for_team`，event_system.gd:58）。
7. **LOW** :82 blood→`get_effective_speed()×blood/100`（實際 blood mult 在 `HealthSystem.get_speed_mult` health:80，非 person_data）；:161-162 legs speed 用 fracture flags 非 severed 均值。
- 準確：資料結構、reaction 評分/條件、N5 守恆(cap5)、skill-growth 公式、REACTION_SKILL_MAP、work_morale。

## ★tick_parameters.md — HIGH 假常數（labor 區已修、以下是 labor 外老 rot）
- **HIGH** `:17,142` — `SEASON_LENGTH=30，1季=1.25天` → `TICKS_PER_SEASON=21600=90天`（world_state.gd:7，harvest_system.gd:3）。
- **MED** `:64-67` — food block「FOOD_PER_PERSON_PER_DAY(2.4)/10×2.4=24/天/300÷24=12.5天」→ 值=**0.8**（:52 已對）→ 10×0.8=8/天、300÷8≈37.5 天。**自相矛盾**。
- **LOW** `:143` — `SALARY_INTERVAL=30` → =1680（salary_system.gd:3；:75 已對）。
- labor 常數（:57-60 K_MFG3/K_GATHER5/LABOR_SCALE1/LABOR_CADENCE）全對。

## message.md — MED（核心常數對、行為 lag + 缺子系統）
- **MED** `:45` `TIME_DECAY_PER_TICK=0.005` → renorm 成 `PER_HOUR=0.005`，per-tick=`0.005/TICKS_PER_HOUR`（message_system.gd:27-28）。
- **MED** `:64-67` 觸發點「only unrest_replace/split」→ 現 ~11 系統 emit（MSG_TTL_BY_TYPE :7-23）。
- **GAP** 無 message TTL/expiry（`MSG_TTL_BY_TYPE`+`prune_old_messages` :7-24,265-287）；**intel/belief 傳播層缺**（`exchange_intel_on_arrival`/`BeliefSystem.record_claim`/source-credibility :148-246，此 doc 職責）；`emit_ambient`/observer channel（:53-68）未記。
- 準確：HOP_DECAY 0.15、decay 形、≤0.05 drop、4 modes+權重、DistortionEngine。

## event.md — MED
- **MED** `:63-70` on_leader_death「統領≥0.3 升 / 無繼承→解散」→ **無 0.3 門檻**（best named 無門檻晉升）+ **anon fallback**（PersonGenerator）+ **player→choose_heir/succession**（三路全未記，event_system.gd:41-66）。
- **MED** `:53` replace「舊 leader 降 advisor」→ code 設 `"member"`（event_unrest_replace.gd:44）。
- **LOW** `:40` split「取一半異見者」→ 全 hard 異見(loyalty<0.35)+機率 soft+比例 anon（event_unrest_split.gd:79-102）。
- **LOW** `:95` faction_defect「義氣<0.35」→ 義氣<0.35 **OR 信義<0.35**（event_faction_defect.gd:16）。
- 準確：Registry、4 events、split/replace 門檻、priority、tag_shift。

## faction.md — 不存在（GAP）
`docs/faction.md` **repo 裡沒有**。faction/diplomacy（faction_ai/diplomatic_ai/faction_data）**無 dedicated domain doc**。多數 invariant 材料在 invariants.md §Information/§G3。= 缺 doc（非 stale）→ 你判要不要補寫（低優先、非緊急）。

## ✅ CLEAN 確認
- **glossary.md** CLEAN（唯 `:13-16` md 表格 malformed=cosmetic）。
- **team.md / world.md / invariants.md** — 稍早 labor/harvest/food 修**全落地確認**（team:159-160/181、world:136/148/38、invariants:309-318）。world 唯 `:97`「14 步驟」列 15 項=cosmetic。

## 序
你 §8/B MVP 優先。修序建議：**person.md HIGH（刪不存在的瀕死 subsystem + goal 表重寫）→ tick_parameters HIGH 假常數 → message/event MED → faction.md 補寫（你判）**。glossary/team/world/invariants 免動（clean/cosmetic）。
