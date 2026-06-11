# Hand Back: Task Arbiter

> 日期：2026-06-11
> Branch：`feat/task-arbiter`
> Spec：`docs/superpowers/specs/2026-06-11-task-arbiter-design.md`
> Plan：`docs/superpowers/plans/2026-06-11-task-arbiter.md`

## 實作摘要

| 檔案 | 變更 |
|---|---|
| `scripts/simulation/task_arbiter.gd` | **新檔**：PRIO_* 常數 + try_set / release / transition / _defiance_check（照 spec 全文）|
| `scripts/data/team_data.gd` | 加 `task_priority: int = 0` |
| `scripts/simulation/faction_ai_system.gd` | 33 處 migration（survival→80 / threat→70 / dispatch→50 / faction goal→30 / 完成→release）+ 護衛 escort target 消失→release |
| `scripts/simulation/interaction_system.gd` | 10 處（trade/tribute/diplomacy/merge 完成→release；安頓→transition(生產, AMBIENT)；herald order→try_set 60/50；aid 恢復 previous_task→transition(50)）|
| `scripts/simulation/outpost_system.gd` | 9 處（start_* 施工→transition(建設, 50)；完工→release）|
| `scripts/simulation/player_command_system.gd` | 3 處（order_subteam→try_set 60、被擋回 ok:false；取消施工→release；aid 恢復→transition/release）|
| `scripts/simulation/reaction_system.gd` | 2 處（bridge 恐慌逃跑→try_set 70；新流亡 team→豁免賦值 + priority 0）|
| `scripts/simulation/strategic_ai_system.gd` | 1 處（trade dispatch→try_set 50，false 不設 trade_task_start_tick）|
| `scripts/simulation/subteam_system.gd` | 2 處（dispatch 新 team→豁免賦值 + PRIO_DISPATCH；merge 部分合併→release）|
| `scripts/simulation/population_system.gd` | 1 處（overflow 流亡→豁免賦值 + priority 0）|
| `scripts/simulation/sim_runner.gd` | 1 處（aid 超時恢復 previous_task→transition/release）|
| `scripts/simulation/movement_system.gd` | **plan 外**：1 處（護衛目標消失→release；plan 的 grep pattern 漏掉多空格賦值）|
| `scripts/debug/headless_test.gd` | +9 測試（Task1a–f 單元、Task2a/2b 整合、Task4 bridge）|
| `docs/team.md` | task_priority 欄位 + TaskArbiter 優先表/不變量章節 |

### 與 spec/plan 的差異

1. **plan grep pattern 漏網**：plan 用 `current_task = `（單空格）grep，漏掉 5 處多空格對齊賦值（movement_system:40、faction_ai:792、interaction:384/469/478）。已全部補 migrate。實際 migration 數 = 65（plan 估 60）。
2. **守城（Uprising Path A）= PRIO_THREAT (70)**：spec 只明定起義=70；守城是同一事件的另一路徑，採同層。
3. **「等待新領主」（defection path A）= transition(PRIO_AMBIENT)**：spec 未覆蓋。語意為待命、任何任務可打斷 → AMBIENT。
4. **herald order（_deliver_order）**：玩家信使 → 60，NPC 對 NPC 下令 → 50（照 spec 玩家命令定義）。被高層擋下時 `player_commanded_task` 意圖仍保留，faction_ai 後續經 loyalty 門檻重試。
5. **order_subteam 玩家下令被擋（vs 70/80/100）改回 `ok:false` + msg**：原行為無條件蓋寫。UI 呼叫端若依賴必成功需注意。
6. **_evaluate_solo 攻擊/掠奪/外交 找無目標時不再設 task**：原行為設 task 但無 move_target（殘缺狀態），現改 return。
7. **stuck 重評**（prosperity / solo）：同層搶不動 → 先 `release` 再 `try_set`，保留原 stuck-重評語意。

## 行為變化（實測）

- **逃跑↔乞食 ping-pong：30,478 → 14**（multi 4 config × 90 天；驗收 < 1,000 ✅）
- `[ReactionBridge]` 觸發 multi 全程僅 1 次（原本佔 log 65%）
- 世界仍活著：multi 中 [Survival]=46、[ThreatResponse]=20、[SoloAI]=15、[ProsperityAttack]=5、乞食=36、return_home=10
- `[抗命]` / 壓抑：單元測試出現並斷言通過（Task1d 抗命、Task1e 壓抑 stress/unrest 上升、Task1f 壓抑累積爆發）。**multi 無玩家命令場景 → 50-挑戰-60 窗口未觸發（=0），屬場景限制非 bug**
- TASK_TRADE 不再被 faction goal (30) 蓋（known_issues trade 殘餘第 1 項同時解）

## 驗證

- headless_test：`=== DONE ===`，0 SCRIPT ERROR（含 9 個新 arbiter 測試全 OK）
- game_sim_test：`ALL INVARIANTS PASSED (violations=0)`
- game_sim_multi：4 config × 21,600 ticks 完跑，0 SCRIPT ERROR，4 config 人口存活
- grep 驗證：`current_task\s*=[^=]` 殘留僅 task_arbiter.gd（4）+ 新 team 豁免 3 點（reaction_system:302 / population_system:47 / subteam_system:29，皆同時設 priority）
- 既有 `[FEATURE FAIL] Trade — trade_success=0` 為 main 既有問題（6/9 log 同樣），非本次造成

## 連動風險

- **守城/起義 (70) 無既有 release 點**：spec 釋放條件表中 THREAT 層靠 `_evaluate_threat` 重評，但該函式只處理 [迎戰/備戰/逃跑]，不含守城/起義。原「最後寫的贏」時代會被任意蓋掉；現在 70 層只有 survival (80) / combat (100) 能搶 → 起義/守城 team 可能長期滯留高層。multi 中未觸發起義（=0）所以未實證。**建議主 session 補：_evaluate_threat 重評清單加守城/起義，或事件結算點接 release**
- **UI / agent_repl**：order_subteam 改可能回 `ok:false`（見差異 5），呼叫端如有「下令必成功」假設需檢查
- **previous_task 恢復一律給 PRIO_DISPATCH**：原 task 若本為 60（玩家命令）會降為 50，下次 AI 派遣可同層競爭。記錄原 priority 需加欄位，暫未做

## 待主 session 確認

- 優先表數值 / 抗命閾值 0.3 tune（測試值）
- 守城/起義 release 缺口（上）是否開 task 補
- 殘留豁免 3 點是否合規
- task 滯留 >30 天無 instrumentation，僅以事件分布抽查；要精確警報需加偵測 print
