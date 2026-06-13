# Hand Back: 飢餓致死鏈

Spec: `docs/superpowers/specs/2026-06-13-famine-death-design.md`
Plan: `docs/superpowers/plans/2026-06-13-famine-death.md`
Branch: `feat/famine-death`

## 實作摘要

| 檔案 | 變更 |
|---|---|
| `scripts/data/team_data.gd` | 新增 `famine_days: float`（連續斷糧累積天數，語意=天） |
| `scripts/data/person_data.gd` | 新增 `hunger: float`（個人飢餓 [0,1]，跟人走不跟團） |
| `scripts/simulation/resource_system.gd` | 飢餓常數；`resolve_consumption` 吃飽歸零 / 斷糧累積 famine_days + grace 後 `_apply_famine_attrition`（先 minor 後 anon，跨整數日結算避免 cadence 重殺）；`_update_person_needs` 加 named hunger 累積/回復（加 `day_fraction` 參數） |
| `scripts/simulation/health_system.gd` | `tick_natural_regen` 加餓傷分支（hunger≥0.7 → blood 流失取代再生）；新增 `check_starvation_deaths`（日邊界 blood≤0 named 死亡） |
| `scripts/simulation/encounter_system.gd` | `is_combat_capable` 接線 `BLOOD_COMA_THRESHOLD`（blood<30 昏迷失能，named + anon unit 同判）— 實裝原零引用死碼 |
| `scripts/simulation/sim_runner.gd` | 日邊界（DayNight print 同點）呼叫 `check_starvation_deaths` |
| `scripts/debug/headless_test.gd` | 9 個 famine 測試（Task1a–d / 2a–b / 3a–c） |
| `docs/known_issues.md` | S5 / U4 勘誤 |

死亡鏈：團級斷糧 → grace 7 天 → minor 先死（10%/日）→ anon（5%/日）；named 走個人 hunger → blood 餓傷 → blood<30 昏迷失能 → blood=0 死亡（通用死因，沿用戰死 erase+pop-1 模型，leader 死交既有繼承鏈）。

## 與 spec/plan 的差異

1. **餓傷 drain 常數對齊（重要）**：plan 寫 `HUNGER_BLOOD_DRAIN_PER_TICK = 5.0/TICKS_PER_DAY`，假設 `tick_natural_regen` 為 per-tick。實查為 per-cadence（near ~24 次/日、far ~2.4 次/日，呼叫點在 `interaction_system.process_on_move`）。若照字面值，near 實際僅 ~0.5 血/日（慢 10×）。改取與 `BLOOD_REGEN_PER_TICK` 同量級 **0.2/呼叫**（near ~5 血/日，符 spec 意圖值）。

2. **死亡不 null `team_id`**：plan Step 3 末尾 `p.team_id = -1`。實查 encounter 戰死模型（`encounter_system` ~:1107）只 `named_members.erase` + 清 leader_id，**不改 person.team_id**。若 null team_id，`_get_player_team_id` 找不到玩家團 → `_promote_successor` 不會路由到 `_handle_player_leader_death` → 玩家 leader 餓死不觸發 choose_heir（破壞驗收）。改為：不改 team_id；以「是否仍在編制（leader_id 或 named_members）」作重複結算防護。**玩家 leader 餓死走 choose_heir forced event 已測（Task3c）通過。**

3. **pop 守恆確認**：`game_setup._setup_anon_tiers` 證實 `population == anon + named + (leader?1:0) + wounded`，故 leader/named 死皆 pop-1 正確（plan 一致）。註：encounter 戰死路徑 named 死 **未** pop-1（既有不一致，非本次範圍）。

## 驗證

- `headless_test.gd`：`=== DONE ===`，無 SCRIPT ERROR；9 famine 測試全過。
- `game_sim_test.gd`（7200 tick）：`ALL INVARIANTS PASSED (violations=0)`；`[Famine]` 最早出現 famine=7 天（grace 守住）。
- `game_sim_multi.gd`（4 config × 21600 tick）：46 `[Famine]` / 51 `[Death]`；PopSample 全 config 下行（warzone 53→46→41、tyrant 34→24→22）；CoinAudit delta=-0.00（守恆）；居民村（op=1, 生產：warzone team5/6）食物正成長、無波及。
- 2 年抽查（warzone max_ticks 172800，Edit 工具改後還原）：跑完無崩潰（0 SCRIPT ERROR），coin delta -0.00，pop 54→31。

## 連動風險 / 待主 session 確認

- **death rate 參數**：minor 10% / anon 5% / hunger gain 0.05/日 / blood drain 0.2/呼叫 為測試值（CLAUDE.md 記時間常數均待正式調參）。建議正式平衡期重校。
- **far-zone lone leader 偏慢**：pop=1 流浪團無 minor/anon → 團級耗損無效，只能走 blood 鏈；far cadence drain ~0.5/日 → 餓死慢。觀察：多數殘存 pop=1 流浪團其實 income=burn（乞食/採集 2.4/日，satisfaction≈1.0）為合法生存非永生 bug；真正斷糧（income<burn）團確實餓死。若要 lone leader 餓死更快，需 far drain 不受 cadence 稀釋（待議）。
- **餓傷與戰場 bleeding 疊加**：hunger≥0.7 期間 `tick_natural_regen` 不再生血，戰場出血團恢復變慢、致死率可能上升。建議觀察 encounter 致死分布。
- **昏迷新語意**：`is_combat_capable` 現在把 blood<30 判為失能。失血未死的 named/anon 在 encounter 中會倒地，可能改變既有戰鬥平衡（原本只看 body part）。
- **ghost person 殘留**：餓死者留在 `state.persons`（team_id 不變，沿用戰死模型），`_update_person_needs`/`tick_natural_regen` 仍會迭代到，僅 cosmetic；不影響 stored pop。與既有 encounter ghost 行為一致。
- **全圖飢荒 → 掠奪塌成乞食（行為觀察，非 bug）**：`_trigger_survival`（`faction_ai_system.gd:1856`）survival 決策本有掠奪路徑（Path 1B 遠 outpost + Path 2，門檻 `殘忍>0.5 或 好戰>0.6` + 有獵物）。但 `_find_weakest_prey`（:1948）要求獵物 **食物≥20**（:1957）且更弱（pop<0.7×自己）。本次 multi run 全圖斷糧（多數團 food=0）→ 無團達 20 食物門檻 → prey 全 -1 → 掠奪/攻擊全落空，統一掉 Path 4 乞食（90 天 0 遭遇戰 / 0 loot；survival transition 41×→乞食、8×→return_home）。另 11× `[ProsperityAttack]`（貪婪層攻擊，與 survival 掠奪不同路）亦被 survival 飢餓 override 成乞食/return_home（attacker 自身將餓死）。catch-22：大家都餓時沒糧可搶。要看到掠奪/戰鬥，需 config 製造貧富不均（部分團囤糧）或放寬食物使 attacker readiness 足。屬連動觀察，本 spec 範圍不改。

## 本次發現（待主 session 評估，非本 spec 範圍）

- **`SURVIVAL_TASKS` 漏列 `掠奪`（潛在 bug）**：`SURVIVAL_TASKS = ["return_home","乞食","投靠"]`（`faction_ai_system.gd:27`）未含 `TeamData.TASK_LOOT`（"掠奪"）。但 `_trigger_survival` Path 1B/2 會把 survival 團設成 `掠奪`。後果：survival-觸發的掠奪團不被各 sticky guard（:133/:633/:696/:1841/:2041 `if current_task in SURVIVAL_TASKS`）認成「已在 survival 態」→ 下一評估 tick 可能被 prosperity/strategic AI 重評蓋掉，掠奪未抵達即被打斷。本次 run 因 0 掠奪未暴露；一旦食物放寬讓 survival 掠奪真的跑，會浮現「掠奪團半路被改任務」抖動。建議：`SURVIVAL_TASKS` 補入 `"掠奪"`（或 survival 掠奪改用獨立 sticky flag）。
