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

| `decision_engine::rank_scored_ctx` | `_persist=PersistStrength.compute`（取代 flat COMMITMENT_BONUS） | ✅**已人格化=留**（持守統一 arc） | — |
| `faction_ai::_evaluate_independent_strategy` | `pop>=EXPAND_MIN_POP`（建國最小 pop）+hysteresis persist | ✅**physical(最小 pop 建國)+已人格化(persist)=留** | — |
| `faction_ai::_evaluate_subteam` | SCOUT_TIMEOUT/CONSTRUCT_TRANSIT_TIMEOUT lifecycle timeout | ✅**physical(lifecycle 安全 timeout)=留** | — |
| `diplomatic::_calc_diplomacy_score` | `self_peace=義氣×信義`（:21） | ✅**已人格化(義氣/信義)=留** | — |
| `faction_ai::_evaluate_all_body` | `tick % INFRA_INTERVAL/FACTION_UPDATE/BETRAY_CHECK` | ✅**physical(cadence 排程)=留** | — |
| `faction_ai::_evaluate_new_outpost_location` | **`is_greedy_leader=(貪婪+野心)>=MINING_GREED_THRESHOLD(1.1)`**（:15 硬 persona-gate） | ⚠️**違憲硬 persona-gate=de-patch 靶**（憲法 A 家族） | 貪婪/野心 WEIGH（非 gate、選址 greed 傾向連續非硬類別） |

## ★★F1 audit 完成結論（9 site 全分類）
- **已人格化/physical 留（6）**：_evaluate_threat（慎重）/ rank_scored_ctx（persist）/ _evaluate_independent_strategy（physical EXPAND_MIN_POP+persist）/ _evaluate_subteam（timeout）/ _calc_diplomacy_score（義氣/信義）/ _evaluate_all_body（cadence）。
- **★genuine 靶（3）**：
  1. **_evaluate_survival** — DESPERATION-entry `food_days<3.0` raw const → 人格化（膽/懼/慎重、絕境進入該分化）。★注意 DESPERATION 亦作物理 need-anchor(買糧/relief 量)=該處留、只 decision-entry 門檻化。
  2. **_evaluate_uprising** — `is_military=martial>0.6 or ambition>0.7` 硬 persona-gate → soft weight（憲法 A 家族）。
  3. **_evaluate_new_outpost_location** — `(貪婪+野心)>=MINING_GREED_THRESHOLD` 硬 persona-gate → soft weight（憲法 A 家族）。
- ★2/3 靶=**憲法 A 家族硬 persona-gate 違憲**（[[project_unification_matrix]] line39 roadmap 序5 de-patch 權重、判準已定：硬 yes/no 卡人格類別→違憲→de-patch soft weight）。
- ★**re-verify 紀律信號**：9 site 中 6 已人格化/physical=**盲人格化會白工/破已對的**（threat 差點 over-count 第2次）。F1 genuine scope 小明確（3 靶、2 同 A 家族已定判準）。

## output → blueprint
3-靶 classification（survival DESPERATION-entry / is_military / MINING_GREED persona-gates → soft weight）→ blueprint spec 人格化 slices（★genuine 真值 modulate 非 crank 逼 outcome、乙教訓；憲法 A 家族判準已定=硬 persona-gate→soft weight 零差異化損失）→ R①→R²→build（fp 預期分化驗 intended、與②結構 slice 分不混）。
