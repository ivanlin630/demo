# Task 優先權仲裁（Task Arbiter）— Design

> 日期：2026-06-11
> 議題：`current_task` 被 9 檔 60 處直接寫入，互相蓋寫無主從。實證：reaction overhaul 後 multi 出現 **30,478 次「逃跑↔乞食」ping-pong**（bridge vs survival 互搶，佔 log 65%）。歷史上同類 bug 已三次（combat_target 卡移動 / TASK_TRADE 被 faction goal 蓋 / survival-loot 互蓋），每次 patch 白名單 → 白名單散落各處，新 task type 必再漏。

## 設計原則

- **優先權按「事件性質（緊急度）」分，不按系統分**
- 仲裁只管 task 寫入；心理計算（loyalty/stress/記憶）不受影響
- **每層必有釋放條件** — task 結束 → priority 歸 0，低層才能再寫
- 同層不互蓋（先到先得）；stuck / 完成 → release 讓位

## 優先表

| 優先 | 常數 | 來源 | 釋放條件 |
|---|---|---|---|
| 100 | PRIO_COMBAT | `combat_target != -1`（戰鬥鎖，絕對）| encounter / combat 結束清 combat_target |
| 80 | PRIO_SURVIVAL | survival（return_home / 乞食 / 投靠 / 飢餓掠奪）| 糧回 ≥ 3 天份重評 / task 互動完成 |
| 70 | PRIO_THREAT | threat response（逃跑/迎戰/備戰）+ ReactionBridge 恐慌逃跑 | `_evaluate_threat` 重評 threat 消失 → idle |
| 60 | PRIO_PLAYER | 玩家命令 | 完成 / 玩家取消 |
| 50 | PRIO_DISPATCH | 派遣任務（貿易/安頓/建設/prosperity 攻擊/偵查/信使/徵收/外交/護衛）| 完成 / timeout / stuck 重評 |
| 30 | PRIO_FACTION | faction goal 傾向（攻擊）| goal 變更 / readiness 不足 |
| 10 | PRIO_AMBIENT | 閒置填充（居民「生產」常駐等）| 隨時可被蓋 |
| 0 | — | idle | — |

**設計決定（依 invariants「玩家不是世界中心」）**：玩家命令 60 < 威脅 70 — NPC 隊收玩家命令後遇恐慌仍會自行逃跑（NPC 有自主性）。

## API

新檔 `scripts/simulation/task_arbiter.gd`：

```gdscript
class_name TaskArbiter

const PRIO_COMBAT:   int = 100
const PRIO_SURVIVAL: int = 80
const PRIO_THREAT:   int = 70
const PRIO_PLAYER:   int = 60
const PRIO_DISPATCH: int = 50
const PRIO_FACTION:  int = 30
const PRIO_AMBIENT:  int = 10

# 嘗試設 task。優先權嚴格大於現任才搶得動（同層先到先得）。
# 回 true = 已設；false = 被現任擋下。
static func try_set(team: TeamData, new_task: String, move_target: Vector2i,
		priority: int, source: String = "") -> bool:
	if team.combat_target != -1:
		return false   # 戰鬥鎖絕對（內部結束流程走 release_combat）
	if priority <= team.task_priority and team.current_task != TeamData.TASK_IDLE:
		return false
	team.current_task = new_task
	team.move_target = move_target
	team.task_priority = priority
	return true

# task 完成 / 取消 / 釋放條件達成 → 回 idle + priority 歸 0
static func release(team: TeamData) -> void:
	team.current_task = TeamData.TASK_IDLE
	team.move_target = Vector2i(-1, -1)
	team.task_priority = 0

# 不改 task 只接管欄位同步的轉換（如 安頓→生產 的就地轉換）
static func transition(team: TeamData, new_task: String, priority: int) -> void:
	team.current_task = new_task
	team.task_priority = priority
```

`team_data.gd` 加欄位：

```gdscript
var task_priority: int = 0   # 現任 task 優先權；idle 時 0
```

## 不變量

- `current_task == TASK_IDLE` ⟺ `task_priority == 0`
- 戰鬥鎖期間（combat_target != -1）任何 try_set 失敗
- 所有 task 寫入走 `try_set` / `transition`；所有結束走 `release`（migration 後直接賦值 = bug）
- 心理層計算不經仲裁（不變）

## Migration（60 處寫入點，9 檔）

| 檔 | 寫入數 | 對映 |
|---|---|---|
| `faction_ai_system.gd` | 34 | survival → 80；threat dispatch → 70；prosperity / trade timeout / residency / member tasks → 50；faction goal 攻擊 → 30；完成路徑 → release |
| `interaction_system.gd` | 8 | trade 完成 / 安頓 / 互動結算 → release 或 transition |
| `outpost_system.gd` | 9 | 建設完成 / settle → transition(生產, AMBIENT) 或 release |
| `player_command_system.gd` | 3 | 玩家命令 → 60 |
| `reaction_system.gd` | 2 | bridge 恐慌逃跑 → 70 |
| `strategic_ai_system.gd` | 1 | trade dispatch → 50 |
| `subteam_system.gd` | 1 | dispatch 初始 task → 50 |
| `population_system.gd` | 1 | overflow team 初始 idle → release 等價 |
| `sim_runner.gd` | 1 | 逐案判 |

Migration 規則：
1. 「開新任務」→ `try_set(..., 對應層級)`，**呼叫端必須處理 false**（被擋 = 不做後續副作用，如不設 combat 意圖欄位）
2. 「任務完成 / 取消」→ `release`
3. 「就地轉換」（安頓→生產）→ `transition`
4. dispatch 建新 team 時的初始 task → 直接賦值可保留（新 team 無現任）但仍設對應 priority

## 預期解掉的實證問題

| 問題 | 機制 |
|---|---|
| 逃跑↔乞食 ping-pong ×30,478 | bridge (70) 搶不動 survival (80)；survival 完成 release 後 bridge 才上 |
| TASK_TRADE 被 faction 攻擊 goal 蓋 | 貿易 (50) > faction goal (30)（known_issues trade 殘餘第 1 項同時解）|
| 未來新 task type 漏白名單 | 不再有白名單 — 只標優先層級 |

## 風險

- **Migration 漏網**：60 處有任何一處保留直接賦值 → 繞過仲裁，bug 隱蔽。計畫含 grep 驗證（migration 後 `current_task = ` 只允許出現在 task_arbiter.gd 與新 team 初始化）
- **try_set false 未處理**：呼叫端設了配套欄位（combat_target 意圖、order_target_id）但 task 被擋 → 欄位殘留。Migration 時逐案檢查副作用順序（先 try_set 成功才設配套欄位）
- **高層卡死**：釋放條件漏 → team 永久鎖高層。釋放條件表（上）是審計清單；integration 測試以「task 滯留 > 30 天」為警報
- **行為改變**：之前「最後寫的贏」變「最高層贏」→ multi 行為大幅變化，需整輪驗證
- **release 時機誤判**：survival 任務（乞食）目前完成點在 interaction 結算 — 要確認每條 task family 的完成路徑都接了 release

## 測試

1. try_set：高蓋低 ✓、低蓋高 ✗、同層 ✗、idle 任何層可寫
2. 戰鬥鎖：combat_target != -1 → 一切 try_set false
3. release：task → idle + priority 0
4. transition：安頓 → 生產，priority 改 AMBIENT
5. bridge (70) 蓋不動 survival (80) 的乞食
6. survival (80) 蓋掉貿易 (50)
7. 貿易 (50) 蓋掉 faction goal 攻擊 (30)
8. 玩家命令 (60) 蓋掉貿易 (50)、蓋不動威脅 (70)
9. try_set false 時呼叫端不殘留配套欄位（抽 2-3 個代表 case）
10. grep 驗證：migration 後 `current_task = ` 直接賦值僅存於 task_arbiter.gd + 新 team 建立點
11. multi 4 config × 90 天：「逃跑↔乞食」轉換次數對比（30,478 → 預期 < 1,000）、無 invariant violation、task 滯留 > 30 天 = 0
