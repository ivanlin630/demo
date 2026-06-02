# Player API 完整度評估

> 評估日期：2026-06-02

---

## 現有 API 層

### Command 端（player_command_api → player_command_system）

| 類別 | 指令 |
|---|---|
| 移動 | `move_to`, `cancel_move` |
| 執行行動 | `execute_action`（14 action_ids，見下表） |
| 強制回應 | `respond_to_forced`（diplomacy / extort） |
| 裝備/物品 | `equip_item`, `unequip_item`, `deposit_item`, `take_team_item` |
| 成員目標 | `execute_action_with_target`（目前只 recruit_named） |

**execute_action action_ids：**
`trade`, `confirm_trade`, `cancel_trade`, `propose_alliance`, `demand_tribute`, `attack`, `extort`, `recruit`, `recruit_anon`, `take_loot`, `leave_loot`, `establish_faction`, `refresh_targets`, `ignore`

### Query 端（player_query_api → sim_bridge）

| 方法 | 用途 |
|---|---|
| `query_player()` | 完整 snapshot（summary / controlled_team / inventory / available_actions / forced_interaction / visible_teams / location_context / members_detail / team_stats） |
| `query_trade_preview(team_id)` | 貿易預覽 DTO |

---

## 完整度評估

| 面向 | 狀態 | 說明 |
|---|---|---|
| 基本互動（攻擊/貿易/外交/勒索/索貢） | ✅ 完整 | — |
| 招募（匿名/記名） | ✅ 完整 | — |
| 遭遇戰（觸發→結算→戰利品） | ✅ 完整 | — |
| 勢力建立/結盟 | ✅ 完整 | — |
| 強制事件輪詢 | ✅ 完整 | diplomacy / extort 兩類型 |
| **據點/建設指令** | ❌ 缺 | 玩家無法透過 API 下令建/拆據點；NPC 走 outpost_system 直接呼叫 |
| **子隊管理** | ❌ 缺 | 無 dispatch_subteam / recall_subteam 指令；NPC 走 subteam_system 直接呼叫 |
| **勢力策略下令** | ❌ 缺 | 玩家無法改 faction goals/strategy；NPC 走 faction_ai/strategic_ai 直接處理 |
| **通知機制** | 🔶 單薄 | 只有 forced_interaction 輪詢；攻擊警告、資源不足等無 push 機制；NPC 不需要通知（每 tick 直讀 WorldState） |
| **架構可擴充性** | 🔶 注意 | `execute_action` switch 隨功能增加；新行動需手動加3處：player_command_system + player_query_api + player_api_mapper |

---

## 缺口是否影響 NPC-NPC 模擬？

**全部5個缺口均為純玩家API層問題，NPC端無對應缺口。**

| 缺口 | NPC 現況 |
|---|---|
| 據點/建設 | `outpost_system.gd` 由 sim_runner 直接呼叫 |
| 子隊管理 | `subteam_system.gd` + `population_system.gd` 直接呼叫 |
| 勢力策略 | `faction_ai_system.gd` + `strategic_ai_system.gd` 每 tick 直接更新 |
| 通知機制 | NPC 不適用 |
| 架構擴充 | NPC 系統不走 player_command_api |

---

## 下一步開發注意

補缺口時需要加的地方：

- **據點/建設**：`player_command_api.dispatch` 白名單 + `execute_action` switch + `_build_available_actions` Layer
- **子隊管理**：同上，另需 query 端輸出子隊狀態
- **勢力策略**：`execute_action` 加 `set_faction_goal` 等 action_id；mapper 輸出 faction 詳情
- **通知機制**：可考慮 snapshot 加 `pending_alerts: Array` 欄位，sim_runner 寫入，UI 輪詢
- **架構擴充**：超過 ~20 個 action_id 時考慮 action registry 模式（Dict of Callables）
