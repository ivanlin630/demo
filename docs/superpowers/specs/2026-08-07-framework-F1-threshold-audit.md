# F1 threshold 死常數審 classification（systems audit → blueprint spec 人格化）

status: IN-PROGRESS（9 threshold sites、batch1 3 site careful-verified）
owner: systems（HOW audit）→ blueprint spec 人格化 slices
date: 2026-08-07
判準（blueprint 定）：threshold=世界物理真實（大群不能覓食類、與人格無關）→**留**；=該由人格秤的行為決策（絕境/威脅/起義門檻該傲膽勇怯不同）→**death-constant 人格化靶**。★每 site 標：閾值+現讀啥+physical/death+若 death 讀哪組人格（與主引擎同組、穿人格非硬寫）。★measure-first re-verify：**先查是否已人格化再判**（threat 已人格化=差點 over-count、同 grounding D 教訓）。

## classification 表
| site | 閾值/現讀 | 判定 | 人格化讀哪組（若 death） |
|---|---|---|---|
| `faction_ai::_evaluate_threat` | `threat_react < threat_threshold`（:415）；**`threat_threshold = THREAT_BASE(0.3) + 慎重×0.3`**（decision_context:245）+ contact_vigilant 降 | ✅**已人格化=留**（慎重 modulate、threat-oracle arc done）。★我一度誤列 death-constant、re-verify 訂正=第2次差點 over-count | — |
| `faction_ai::_evaluate_survival` | `food_days < DESPERATION_DAYS(3.0 raw const)`（:3215 survival-entry）；WARNING/URGENCY/RECOVER_DAYS | ⚠️**death-constant 候選**：survival-ENTRY 門檻用 raw const、未見人格 modulate（vs threat 有）。★需終驗無他處 modulate。絕境進入該人格化（膽大者 food_days 低才慌/慎重者早慌） | 膽/懼/慎重（求生欲 lv["慎重"]/["好戰"]反）。★注意 DESPERATION_DAYS 亦作物理 need-anchor(買糧/relief 量)=該處 physical 留、只 decision-entry 門檻人格化 |
| `faction_ai::_evaluate_uprising` | `is_military = martial>0.6 or ambition>0.7`（:4544 硬 persona-gate）+ uprising unrest 門檻 | ⚠️**違憲硬 persona-gate=de-patch 靶**（憲法：硬 persona-gate on/off 違憲→soft weight）。uprising 門檻本身該人格化（膽/野心高易反） | martial/ambition WEIGH（非 gate）+ uprising 讀 膽/unrest |

### 續 verify（TBD、batch2）
- `decision_engine::rank_scored_ctx`（主 rank 門檻、可能 commitment/persist 已人格化=留候選）
- `diplomatic::_calc_diplomacy_score`（外交門檻）
- `faction_ai::_evaluate_all_body`（主迴圈 cadence/gate）
- `faction_ai::_evaluate_independent_strategy`（建國 intent 門檻、accum/野心=可能已人格化）
- `faction_ai::_evaluate_new_outpost_location`（選址評分閾）
- `faction_ai::_evaluate_subteam`（子隊 lifecycle 門檻、多 timeout=physical 候選）

## ★batch1 信號
- **re-verify 紀律再證**：threat_threshold 已人格化（差點 over-count 第2次）→ 每 site **先查已人格化否**再判 death-constant。
- 疑真 death-constant/違憲：_evaluate_survival（DESPERATION-entry）+ _evaluate_uprising（is_military persona-gate）。
- 疑 physical/已人格化留：_evaluate_threat（已慎重 modulate）+ _evaluate_subteam（timeout 多 physical）。

## output → blueprint
9-site classification 清單（death-constant 靶+人格組 / physical 留 / 已人格化留）→ blueprint spec 人格化 slices（★genuine 真值 modulate 非 crank 逼 outcome、乙教訓）→ R①→R²→build（fp 預期分化驗 intended）。
