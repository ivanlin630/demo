# Hand Back: P2b-1 survival 選擇統一（non-unified `_trigger_survival` 委派 engine）

branch：`feat/p2b1-survival-selection-unify`（3 commits，已 push）

## 實作摘要

| 檔案 | 改動 |
|---|---|
| `scripts/simulation/decision/options.gd` | `SURVIVAL_OPTION_SET` const；`返家補給` applicable generalize（任何有家隊絕境 food<DESPERATION 入榜，非僅商隊）；`覓食` 加 `FORAGE_VIABLE_POP` 守衛（split 自 `survival`） |
| `scripts/simulation/decision/decision_context.gd` | 加 `var population`，gather 填 `team.population`（供 `覓食` pop 守衛） |
| `scripts/simulation/decision/decision_engine.gd` | `rank_survival(state,team)`：同 `rank` 但 applicable 過濾到 `SURVIVAL_OPTION_SET`、不寫 `current_option`、承諾比對 `current_task` |
| `scripts/simulation/faction_ai_system.gd` | `_trigger_survival` 改委派 `rank_survival`→`to_task` 派 top 可派 @`PRIO_SURVIVAL`；**刪** `LOOT_GATE`/`JOIN_GATE`/`CAMP_GATE` const + `_loot_pref`/`_join_pref`/`_camp_pref` func；保 leader 檢查/previous_task/TASK_BUILD 農田不中斷/player-join guard/hunt fallback/release |
| `scripts/debug/headless_test.gd` | 新 `_test_p2b1_rank_survival` + `_test_p2b1_nonunified_survival_delegation` + homed/homeless desperate helpers；調整 4 處既有直呼點（見下） |

## 與 spec/plan 差異

- **helper pop=20（非 plan 預設）**：rank_survival 測需排除 `覓食`(survival_pressure 量級碾壓)才能斷言 `返家補給` 為 ranked[0] → homed/homeless helper 用 pop>`FORAGE_VIABLE_POP`(15)。join 測傳 pop=10（強鄰 finder 要 neighbor pop>1.5×team）。
- **delegation 測環境工程**：plan 測 stub 為草稿。實 term 數學下 `loot_drive` 平坦(1.0)、`camp`/`join`/`beg`/`forage` drive 隨絕境放大 → loot 僅在隔離(無可農地+獵物非 aid)時勝。raider→LOOT 測標 tile 有主(排紮營)+prey 低糧(排乞食)。屬「確認新人格→動作同義才調」非盲放寬。
- **delegation 測對舊 code 也 PASS**（characterization）：homed→return/raider→loot/joiner→join 三情境舊手寫 branch 同樣產此 task，故 Step3「確認 FAIL」未失敗 → 價值在 refactor 後仍綠。

## ~20 直呼點：調了哪些 + 原因（同義 vs 退化）

1. **`merchant restock`（s4）**：舊斷言「非商隊不走返家補給」→ 改斷言「非商隊**絕境**有家**應**返家補給」+ 新增 s5「非商隊**輕飢**(food≥DESPERATION)不 proactive 返家」。**契約變（spec §1 明示）**：`返家補給` generalize 給非商隊絕境 = 保 1037 熱路徑，spec 標為「行為改善」。
2. **`_test_survival_prefs`**：`_loot_pref/_join_pref/_camp_pref` 斷言 → `DecisionTerms.weight("loot"/"join"/"camp",...)` 斷言。**同義**：pref helper 公式 = weight 公式（P2a 已對齊），helper 刪後單一 owner = weight。
3. **`_test_survival_decision_tree` Path2（殘忍→掠奪）**：加「tile 標有主 + prey 低糧」隔離 loot。**同義**：仍測殘忍隊掠奪傾向；移除 drive 量級造成的 camp/beg 遮蔽（非改人格映射）。
4. **`_test_survival_b_branch_far_outpost_loot`**：LOOT → **RETURN_HOME**。**退化但 spec 已知可接受**：遠 outpost+殘忍「就近掠」的距離 nuance 隨 `restock_need`(非距離感知)移除 → 遠家絕境隊現返家。spec §行為對齊明列、loot 稀有。

## world_sim 2yr 量測（unseeded，機制非絕對閾）

| 指標 | baseline | after |
|---|---|---|
| `[Survival]` 事件 | 1032 | 969（同量級） |
| `攻擊→idle` churn | 927 | 932（幾乎相同） |
| dest=return_home | 41 | 5 |
| dest=掠奪 | 15 | 0 |
| dest=覓食 | 1 | 4 |
| 存活隊（月24） | 6 | 5 |
| InvariantViolation | 0 | 0 |

- **無 mass starvation**：存活隊 plateau 穩（6 vs 5 在 unseeded 噪內），無崩盤。
- **熱路徑「真相」**：spec measure-first 稱「`[Survival]` 多為 return_home」**不準** —— baseline 即 **idle-release 主導**（927/1032 = 攻擊隊輕飢→survival 評估→無可派 option→release→idle→再攻 churn）。此 churn **pre-existing**（927→932 幾乎不變），**非本 plan 引入**，屬獨立既有問題（attacker 輕飢 churn）。
- **return_home 41→5 / loot 15→0**：僅 5-6 distinct 隊觸 survival，unseeded RNG 組成噪。返家機制由單元測 `_test_p2b1_nonunified_survival_delegation`(a) deterministic 證（homed 絕境隊→TASK_RETURN_HOME）。
- **輕飢不亂掠奪**：loot dest=0，未 over-loot。
- framework S1-S6 PASS；game_sim_multi coin delta=0 ×4 config；headless 全綠 0 SCRIPT ERROR。

## 連動風險（主 session 決定是否補修）

- **`返家補給` generalize 對 unified produce 隊**：unified 路徑(`_decide_unified`)同讀 `applicable` → 絕境 produce 隊現也得 `返家補給` 候選（先前無）。spec §1 標為 believability 改善。已驗 `_test_p2a_*`/TC 全綠，但 **unified 隊行為微變**（絕境有家 produce 隊可能返家而非續產）→ 主 session 確認願景接受。
- **`覓食` 加 pop 守衛影響 unified**：`覓食` applicable 現需 `population≤FORAGE_VIABLE_POP(15)` → unified 大軍(pop>15)絕境不再有 `覓食` 候選。已驗既有 unified/TC 測不破（unified 隊多小）。但**大軍絕境行為改變**（無覓食候選 → 靠其他 survival option 或 FLEE）。
- **距離 nuance 丟失**：遠家殘忍隊不再就近掠 → backlog「`restock_need` 距離衰減」（系統可後補）。
- **嚴重度 gate 簡化**：`severity` 參數對選擇不再加 gate（食物量級由 drive 表達）；舊 warning「有家+不該放棄當前 task → 原地不動」nuance 移除 → 理論上輕飢有家隊更易切返家。實測 churn 未增（pre-existing attacker churn 主導，掩蓋此微變）。

## 待主 session 確認

- **P2b-2 全退 entry 起點**：本塊保 `_evaluate_survival` gate + `_trigger_survival` wrapper + `PRIO_SURVIVAL`。全退（non-unified survival 整路由 engine entry）耦合 P3/P4（軍隊 attack/threat/vendetta 不在 engine）—— 待 P3/P4 後。
- **`_evaluate_solo` survival 仍雙 owner**：`scripts/.../faction_ai_system.gd` solo camp/join scoring（spec §範圍明列不碰）仍手寫，未統一 → backlog（P2b-2 或獨立塊）。
- **attacker 輕飢 churn（pre-existing）**：927 次/2yr 攻擊隊輕飢→survival→release→idle→再攻。本 plan 揭露但未引入。是否獨立修（survival entry 對「無可派 option 之輕飢攻擊隊」早退不釋放？）由主 session 排序。
- **`返家補給` 站家上 edge**：produce 隊站自家(空)outpost 上絕境 → `返家補給` target=當前格 → return_home 原地。本塊未新增 latch（舊 Path1 同行為），但 generalize 擴大觸及面 → 留意。
