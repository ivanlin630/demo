---
from: blueprint
to: systems
status: open
topic: 統一框架 arc 的完整「吵架塊」scope map（子 session 徹查）+ 一個可即修 defect bug
---

# 狀態吵架全掃描 — 統一決策框架 arc 的 scope

承 `unified-decision-framework`。藍圖開子 session 把整個 `scripts/simulation/**` + `scripts/data/*` 翻過，找出所有「多系統搶同一塊 state、無單一 owner/協調」。給框架 arc 定範圍——別只修 current_task 漏掉其餘。

## Pattern A — 決策吵架（意圖/目標/動作槽）

**核心 = 6 個平行意圖槽 / 3 個生產者 / 5 個 cadence 時鐘 / IDLE-only 重評。**

| 槽 | 問題 | 嚴重 |
|---|---|---|
| `current_task`+`task_priority` | TaskArbiter 是 latch 非 weigh；多意圖共用 PRIO_DISPATCH=50（tribute/prosperity/scout/trade_net/settle）first-writer-wins；ambition=PRIO_AMBIENT=10 且只 IDLE 設（核心方向最弱）；只 IDLE 重評 | HIGH |
| `move_target` | **無 arbiter**，22 寫點 last-writer-wins；movement strategic_assignments(59-66) / faction_ai pursuit(230) / escort(43) 每 tick race；順序決定目的地（非確定） | HIGH |
| `strategic_assignments` | **第二套決策槽**（strategic_ai 擁有），繞過 arbiter 直餵 movement；strategic_ai 內 3 函數（clear@130 / erase@90-92 / breakout@149-172）同 tick 互 race | HIGH |
| `combat_target` | **全域 mutex**：!=-1 在 arbiter:22 / movement:56 / 各 cadence 評估器是絕對 veto；6 檔設、6 檔清 → **一個沒清 = 整隊跨所有系統凍結**（aid/beggar special-case 即補漏證據） | MED-HIGH |
| `prosperity_target_id` / `order_target_id`+`order_task` | order 槽**一槽三義**（escort/tribute/merge），last-writer-wins，靠 current_task 區分 | MED |
| cadence gates | prosperity/threat/residency/ambition/order 各自時鐘自閘 + `_evaluate_threat:253` 「current_task!=IDLE→return」→ **重評結構性餓死**，stuck 主因 | MED-HIGH |

**生產者順序耦合**：`sim_runner:148`(faction_ai) → `:150`(strategic_ai) 每 tick 接力，無共享模型。

**雙重意圖表徵（4×）**：faction `goals`(字串 徵收/立國/外交/攻擊/掠奪) / `strategy`(字串) / `strategic_goals`(typed dict expand/defend/trade_net) / `player_goal_override` —— 同一概念四套並行，各擁不同系統。

→ **框架要收的決策槽**：current_task + task_priority + move_target + strategic_assignments + combat_target + prosperity_target_id + order_target_id/order_task，**併成一個生產者、一套意圖表徵、一個 weigh（非 latch）、去 IDLE-only**。

## Pattern B — 所有權吵架（一值多寫、delta vs 絕對 set 互洗，無銀行）

| 值 | 寫者 | 問題 | 嚴重 |
|---|---|---|---|
| `loyalty` | ~26 寫/11 檔 | delta(薪資/義氣/aid/fatigue) vs **絕對 set**(unrest_split 0.25-0.9 / defect=0 / recruit=0.5) → 絕對洗掉累積 delta | HIGH |
| `resources[*]` | ~110 寫/20 檔 | 多 per-key RMW + 整 dict reset/clear；面積最廣（trade-reserve 單源已修一部分，仍只部分 owned） | HIGH（面積） |
| `anon_treasury` | 24 寫/8 檔 | delta + 數處 `=0.0` 歸零，無銀行 → **貨幣守恆風險**（同 loyalty 形但是錢） | MED-HIGH |
| `unrest_turns` | 14 寫 | delta 累積 + `=0` 絕對歸零 → **歸零洗掉別系統民怨，壓掉該爆的叛亂** | MED |
| `outpost_owner`(tile) | 16 寫/5 檔 | 戰鬥佔領/AI 接管/起義/結盟/棄守 last-writer-wins，同 tick race；`pending_owner_change_tick` 是繞它的 buffer hack | MED-HIGH |
| `stress`/`fear` | 4+ 檔 | 純 delta（無絕對洗），但 4 系統共塑一個決策輸入；無單 owner | LOW-MED |
| `readiness` | 2 檔 | 恢復 vs 戰耗，delta 收斂；輕 | LOW |
| `leader_id`/`named_members` | 6+/~12 檔 | 多為 lifecycle，但 succession(event_system:45-68) 可 race death-clear / player-inherit | LOW-MED |

→ **所有權清理**：每池一個 owner / 協調更新（loyalty、anon_treasury、unrest、resources、outpost_owner 各設「banker」收所有 delta，禁外部絕對 set）。= `project_framework_seams` 的所有權圖縫。

## 好消息：現成「乾淨單一 owner」當藍本
框架照這些做，有證明可行的模式，非從零：
- `ambition_archetype/cap/rung` → 只 `ambition_ladder.update`
- `anon_cohorts` → 只 `AnonCohort` helper；`relation_edges` → 只 `RelationGraph.add_edge`
- `faction_id`/`parent_team_id`/`subteam_ids` → world_state bidir helper
- `guard_ratio`/`work_morale`/`equip_order`/`armor_config` → 各只一個 update 函數

## 可即修 defect（孤立，與框架 arc 無關，你排）
**`event_faction_defect.gd:21`**：活隊離派系直接 `team.faction_id = -1`，**沒走 `set_team_faction`/bidir helper** → `factions[fid].member_team_ids` 留懸空單向鏈（invariant audit 報）。其餘 5 處 `faction_id=-1` 是新生隊（良性）。

## key files
`task_arbiter.gd`、`faction_ai_system.gd`(153-340/488-603/632-760)、`strategic_ai_system.gd`(43-172)、`movement_system.gd`(29-80)、`sim_runner.gd`(148-150)、`event_unrest_split.gd`(122-127)、`event_faction_defect.gd:21`。

## 給框架 arc 的一句話
統一決策框架 = 收 Pattern A（6 槽→1 連貫 weigh 決策、1 意圖表徵、去 cadence-IDLE 餓死）。所有權清理 = 收 Pattern B（6 池→各設 banker）。兩條都對上既有框架債（pipeline 縫 + 所有權圖縫）。believability bar 見 `unified-decision-framework.md`（連貫≠同質，人格分歧不可洗平）。
