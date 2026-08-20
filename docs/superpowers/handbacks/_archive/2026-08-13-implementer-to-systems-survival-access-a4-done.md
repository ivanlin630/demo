---
from: implementer
to: systems
status: consumed
topic: "[slice A4 DONE·feat/survival-access-a4 commit 86ba9bec]forage de-patch+solo-convert+9筆(佔據率真 lever、行為變 slice)·【A4】terms survival_pressure eval 1.0 死值→clampf((2×SLACK_COMFORT_DAYS7−food_days)/7,0,1)衰減(<7 floor 1.0/7-14 線性/≥14→0);外科手術只動覓食【solo-convert】新 _tick_solo_settle(loop3、非子隊 TASK_SETTLE 抵達鏡射 _settle_relocated_village 三分支、own-faction outpost→convert+convert_via_settle tap/空地 crude_camp/else release);invite accept 已 set_team_faction→own-faction 分支成立【9筆】ENGINE_SOURCES 加 invite_settle 同層 self-replace·★驗:survival_a4_test ALL PASS(A4 bounded 瀕餓≤7→1.0/10→0.571/≥14→0 單調+solo-convert 抵→convert PRODUCE+convert_via_settle=1 非等 pair+9筆 self-replace)+headless 0-new+constitution 75+determinism 3-run byte-identical(warring 728d62ef)·★fp intended-change LIVE(warring 678b3ee3→728d62ef、A4 forage decay 真行為變)·感知鐵律(自家 food_days/到站真位)、零新 RNG·★measurer 佔據率終測請求(綠才 merge):A2 invite-widen+solo-convert+A4 合力真 causal(convert_via_settle>0、佔據率 baseline 6.4%顯著升)+bounded 四項+不 over-invite·請 merge-gate 硬讀→measurer 佔據率終測→綠 merge→arc 佔據率驗收"
branch: feat/survival-access-a4
commit: 86ba9bec
---

# slice A4 DONE — forage de-patch + solo-convert + 9筆（佔據率真 lever）

feat/survival-access-a4 commit `86ba9bec`（off main HEAD d9a05cff；已 push）。de-patch 照妖鏡家族、三塊。

## 【A4 forage de-patch】
`terms.gd survival_pressure` eval 硬編 `return 1.0`（T1 剝 urgency 死值、同 camp_drive 家族）→ `clampf((2×SLACK_COMFORT_DAYS − food_days)/SLACK_COMFORT_DAYS, 0, 1)`。<7 天(絕境)→1.0 floor 不動、7→14 線性衰減、≥14→0 讓位。`SLACK_COMFORT_DAYS=7` 既有錨（=`SURVIVAL_RECOVER_DAYS` 同值、禁新常數）。★**外科手術只動覓食**（5 消費者只覓食吃完整衰減；自救建田/threat/買糧 用 survival_pressure 當 weight[另一函式]不碰；遷移找糧 applicable 已 food_days<門檻永在 floor 區）。

## 【solo-convert】
interaction TASK_SETTLE convert 包在 pairwise a/b handler（solo 無 pair 不 convert）→ 新 `_tick_solo_settle`（loop3、非子隊 TASK_SETTLE 抵達即安頓、**鏡射 `_settle_relocated_village` 三分支**）：own-faction outpost→`_convert_to_resident`+`convert_via_settle` tap / 空地→`establish_crude_camp` / 皆不成→`release`。被邀者 diplomatic `invite_settle` accept 已 `set_team_faction` 入 lord faction → own-faction 分支成立。

## 【9筆】
`task_arbiter ENGINE_SOURCES` 加 `"invite_settle"` → 同層 50=50 self-replace（非 priority-crank、被邀 settle 令不被同層 stomp）。

## 命門守
感知鐵律（A4 讀自家 food_days、solo-convert 到站用真位=已在 tile）、零新 RNG、fp intended-change。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `survival_a4_test` | **ALL PASS**：①A4 bounded（瀕餓 food_days≤7→**1.0 floor**、food_days=10→**0.571** 連續、≥14→**0** 讓位、單調）②solo-convert（抵 own-faction outpost→convert PRODUCE + `convert_via_settle=1` **非等 pair**、還在路上不 convert）③9筆 invite_settle 同層 self-replace 過 |
| headless | **0-new** |
| constitution_gate | **PASS sites=75** |
| determinism | **3-run byte-identical**（warring seed1337 1000t FP `728d62ef`；純算術無新 randf） |

★**fp intended-change LIVE**（warring FP `678b3ee3`→`728d62ef`；A4 forage decay 令吃飽隊少覓食=真行為變）。

## ★measurer 佔據率終測請求（bounded、綠才 merge）
- ★**佔據率終測 = A2 invite-widen + solo-convert + A4 合力真 causal**：`convert_via_settle`>0、佔據率 baseline **6.4% 顯著升**。
- bounded 四項（A4 四食況 + solo-convert + 9筆）+ 不 over-invite churn + determinism。realistic vagrant-rich 床。

## 路
1. **你 merge-gate 硬讀**（A4 外科手術只動覓食 term + solo-convert 鏡射既有三分支非發明 + 9筆 self-replace 非 crank + 感知鐵律）。
2. → measurer 佔據率終測 → 綠 merge → arc 佔據率驗收。地基 KEEP。

（perf/F2 disk flag 續。）
