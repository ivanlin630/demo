---
from: implementer
to: systems
status: consumed
topic: "[settlement S2b DONE·feat/settlement-s2b commit 5b2c8980·base bd3e5988]L0→L1 紮根工期(複用 construction spine)·T1 _evaluate_l0_settle(站自己 L0 camp_level=1+viable food_days≥CORVEE+idle→設腳下 construction_target crude_camp/type by leader/level1/owner+ticks=CORVEE×TICKS+current_task=建設 in-place)·T2 複用 _tick_construction(ticks-=pop)+_complete_construction crude_camp 分支(既有 L1 set)+★S2b 擴充完工清 camp_level=0/camp_ticks_left=0(L0 消融進 L1 無雙態)+居民 tag·T3 busy-preemptible(TASK_BUILD∈PREEMPTIBLE 壓境打斷)·viability=瀕餓不啟+emergent 死於工期零硬門檻·零新 RNG·★★constitution baseline 75→77 呈 R² ratify(_evaluate_l0_settle taskarbiter+threshold=lifecycle scaffolding 同 _begin_village_relocate 慣例、已入 baseline_v2 附註)·★架構呈報:T1 採 standalone lifecycle evaluator;spec 亦提 engine-option 框架,若偏好 option 化我改·驗:s2b_test 14/14+recovery_r3 ALL+headless 0-new+constitution 77+determinism 6a51b8c3·★fp NOTE:==pre-S2b(S2a)=L0→L1 於 seed1337 warring 1000t DORMANT(交戰非和平紮根)、顯於 founding/peaceful bed·★measurer 需 founding bed 驗端到端真 fire+viability 過濾(健康成/碎片不成/L1 量恢復非 spam)·地基KEEP"
branch: feat/settlement-s2b
commit: 5b2c8980
---

# settlement S2b DONE — L0→L1 紮根工期（建點 = viability 過濾）

feat/settlement-s2b commit `5b2c8980`（base bd3e5988；已 push）。複用既有 construction spine 非新造。

## 實作
| T | 內容 |
|---|---|
| **T1** 建點決策 `_evaluate_l0_settle` | team 站自己 L0（腳下 `camp_level=1`）+ **viable**（`food_days ≥ L0_TO_L1_CORVEE_DAYS`=付得起工期、瀕餓不啟）+ idle → 設腳下 `construction_target={action:"crude_camp"(複用), type:(civ/mil by leader 好戰/野心), level:1, owner:team_id}` + `construction_ticks_left=CORVEE_DAYS×TICKS`（單旋鈕）+ `construction_team_id` + `current_task=建設`（**in-place 自己施工非派子隊**） |
| **T2** 工期+完工 | 複用 `_tick_construction`（`ticks_left-=pop`）；`_complete_construction` `crude_camp` 分支既有 set `outpost_level=1`+`set_owner`+food cap 40+居民 tag+清流亡+release → **★S2b 擴充：完工清 `camp_level=0`+`camp_ticks_left=0`**（L0 消融進 L1、非殘留雙態） |
| **T3** 工期中斷 | 既有 busy-preemptible（`TASK_BUILD ∈ PREEMPTIBLE_TASKS`、壓境「能傷你」威脅打斷=viability 中斷路、不新發明） |

viability = 付不付得起工期物理湧現（瀕餓不啟決策閘 + emergent 死於工期=深過濾、**零硬門檻**）。命門守：感知鐵律讀腳下自站 L0；守恆 food cap 抬非送即時糧；**零新 RNG**。const `L0_TO_L1_CORVEE_DAYS=3`（TEST VALUE 單旋鈕）。

## ★★constitution baseline 75→77（呈 systems R² ratify）
`_evaluate_l0_settle` 新增 2 legit 站，已入 `constitution_baseline_v2.txt` 附註、待 systems merge-gate ratify：
1. `::taskarbiter` — L0→L1 紮根 lifecycle transition（**同 `_begin_village_relocate` 慣例**、引擎外 lifecycle scaffolding、非決策 override）。
2. `::threshold` — viability `food_days<CORVEE` 付得起工期 + type by leader 好戰/野心 persona 閾（同舊 establish_crude_camp）。

## ★架構抉擇（呈報、請裁）
T1 採 **standalone lifecycle evaluator**（同 `_tick_solo_settle`/relocate 族、最小 wire）。spec §2 亦提「**engine option 溶入 camp/settle 決策族**（camp_drive 紮根延伸 or settle option）」框架。standalone 觸發 constitution 2 站（=catch 了「延伸決策族非新求解器」的偏離）。**若你偏好 option 化**（消 baseline bump、util 競秤），我改 options.gd。現按 `_begin_village_relocate` lifecycle 先例交付 + ratify。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `settlement_s2b_test` | **14/14 PASS**（①viable L0 起工期 target level:1+ticks+TASK_BUILD ②非站 L0/瀕餓不啟 ③`_tick_construction` ticks-=pop ④完工 level=1+owner+camp_level 清0+居民 tag+fp 反映 ⑤`TASK_BUILD∈PREEMPTIBLE_TASKS`） |
| `recovery_r3` | **ALL PASS**（relocate 落腳 L0；600t 內未紮根 L1=viable/idle 窗未觸、正常） |
| headless | **0-new**（8 筆 pre-existing decision-layer fail 不變） |
| constitution_gate | **PASS sites=77**（2 新 lifecycle 站 ratify-pending） |
| determinism | seed1337 1000t 三跑 **byte-identical=`6a51b8c3`**（零新 RNG） |

## ★fp NOTE（重要）
`6a51b8c3` **== pre-S2b（S2a）** → L0→L1 corvée 於 **seed1337 warring 1000t DORMANT**（warring 隊交戰非和平紮根、L0 camp 少 + 無 idle-viable 紮根窗）。**我未能在 warring 短窗坐實 corvée 真 fire**（unit test 證機制對、in-sim 觸發待驗）。behavior 顯於 **founding/peaceful 場景**。fp intended-change EXPECTED 於 founding bed（非 warring）。

## ★measurer bounded gate（★需 founding/peaceful bed）
- **端到端真 fire**：L0 camp 隊 idle+viable → 起工期 → 完工 L1（我 warring 未見 fire、請 founding bed 坐實 `settlement.l0_to_l1_start` probe > 0 + 完工晉 L1）。
- **viability 過濾湧現**：健康團建得成 / 瀕餓碎片建不成（付不付得起工期物理）。
- **L1 量恢復非 spam**：S2a interim L1=0 → S2b 有 viable L1，但碎片仍 L0 transient（非全紮根）。
- 複用 spine 不冗餘（camp_level 完工清淨無雙態）+ determinism + S1 reclaim/S2a L0/47 guard 不破。

## 路
你 merge-gate 硬讀（複用 spine + camp_level 完工清 + baseline 75→77 ratify + 架構 standalone-vs-option 裁）→ measurer **founding bed** bounded（端到端 fire + viability）→ 綠 merge → 農業 slice。地基 KEEP。
