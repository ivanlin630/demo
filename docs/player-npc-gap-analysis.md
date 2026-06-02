# 玩家 vs NPC 互動機制缺口分析

> 建立：2026-06-03 | 持續更新中

---

## 已對齊（玩家 = NPC）**不一定真的對齊日後討論 **

| 互動 | 狀態 |
|---|---|
| 攻擊 | ✅ |
| 貿易 | ✅ |
| 提議同盟 | ✅ |
| 要求納貢 | ✅ |
| 勒索 | ✅ |
| 招募 | ✅ |
| 建立勢力 | ✅ |

---

## 缺口清單

### 🔴 高優先（影響正確性）

#### G-01. NPC 主動外交繞過玩家 UI
- **現況**：`diplomatic_ai_system.try_proactive_diplomacy` 對玩家 team 直接呼叫 `handle_diplomacy_message`，系統用 NPC 公式自動替玩家回答
- **影響**：NPC 主動要求結盟、要求納貢、提議貿易時玩家無選擇
- **修法**：偵測 `target_id == player_team_id` → 改寫入 `player_forced_event` 而非直接解算
- **討論**：待討論

---

### 🟠 中優先

#### G-02. 征服（戰後強制加入）
- **NPC**：`interaction_system._try_subjugate` — 戰後贏家可強制敗者加入勢力
- **玩家**：勝戰只得戰利品（last_encounter_result），沒有「征服/收編」選項
- **問題待討論**：
  - 玩家勝戰後是否出現「要求投降/加入」選項？
  - 還是改走 propose_alliance（已有）？
  - 一次性征服 vs 外交結盟語意上的差別是什麼？
- **討論**：待討論

#### G-03. 背叛/離開勢力
- **NPC**：`diplomatic_ai_system.consider_betrayal` → `_execute_betrayal`
- **玩家**：加入勢力後無法離開；無 leave_faction / betray_faction 指令
- **問題待討論**：
  - 玩家是否能主動離開？（自願脫離 vs 背叛）
  - 脫離後是否有外交代價？
  - 玩家是 leader 時解散勢力的情境？
- **討論**：待討論

#### G-04. 通知機制
- **NPC**：不需要，每 tick 直讀 WorldState
- **玩家**：只有 `player_forced_event` 輪詢；攻擊警告、資源告急、勢力事件等無 push
- **問題待討論**：
  - 需要哪些通知類型？（被攻擊、食物不足、勢力成員叛離）
  - 實作方式：snapshot 加 `pending_alerts: Array`？還是另立欄位？
  - 優先順序：攻擊警告最緊急，但遭遇戰已有路徑
- **討論**：待討論

#### G-05. 據點/建設指令
- **NPC**：FactionAI 設 `TASK_BUILD_OUTPOST` → sim_runner 呼叫 `outpost_system.try_build`
- **玩家**：無 API 指令建/拆據點

- **討論結論**：✅ 2026-06-03

**建設邏輯：**
- 玩家完全吃 NPC 路徑：`execute_action("build_outpost")` → 設 `current_task = "建設"`，sim_runner 照常推進
- 限當格建造（遠端建造靠子隊，待 G-06）
- 資源消耗同 NPC（BUILD_COST 表：material / coin / weapon）
- 建設時間同 NPC（BUILD_TICKS / team.population）

**暫停/接手機制：**
- NPC 已有暫停邏輯（`outpost_system._tick_construction` line 68–69：施工隊離格自動暫停，`construction_ticks_left` 存 tile 上）
- 被攻擊後移離 → **自動暫停**，回來自動續建（免費取得）
- 玩家不需要 cancel_build
- `_tick_construction` 需小改：允許**任何**在格上 `current_task == "建設"` 的 team 推進施工並接手 owner
  - 現行：只有原始 `construction_team_id` 可推進 → 改為：格上任何 `current_task == "建設"` team 皆可
  - `_complete_construction` 完成時 owner = 當下施工 team（非原始）

**拆除邏輯：**
- 施工中（未完成）：任何 team 到格上可清除（無所有權，無限制）
- 已完成據點：需**支配權**
  - `_has_control(state, team_id, tile) → bool`：
    1. `tile.outpost_owner == team_id` → true
    2. owner 所屬勢力 == team_id 所屬勢力（faction_id 相同且非 -1）→ true
    3. `tile.outpost_owner` 的 team 不存在（已滅）→ true（無主）
    4. 格上無任何 owner 同勢力 team 在場 → true（無人駐守，任何佔領者可拆）
    5. 以上皆否 → false

**玩家 action 清單（G-05）：**
| action_id | 條件 |
|---|---|
| `build_outpost` | 當格無據點無施工；扣 BUILD_COST |
| `upgrade_outpost` | 當格有據點且有支配權；扣 BUILD_COST |
| `upgrade_farming` | civilian 據點且有支配權 |
| `upgrade_manufacturing` | civilian 據點且有支配權 |
| `demolish_outpost` | 完成→需支配權；施工中→任何人 |

**依賴項目（後續實作）：**
- **TASK_GARRISON（駐守）**：team 待在格上不移動；FactionAI / StrategicAI 需新增派守邏輯
  - 駐守 team 物理在格 → 算支配 owner 勢力控制該格
- **TASK_PATROL（巡邏）**：team 循 `patrol_waypoints: Array[Vector2i]` 路線移動
  - 需 `TeamData.patrol_waypoints` 新欄位
  - MovementSystem 擴充：到達 waypoint 後自動設下一個目標（循環）
  - 控制判斷：只在 team 物理上在格時算有效（間歇控制，有策略空隙可利用）
  - 先做駐守，巡邏獨立 feature
- 子隊遠端建造：待 G-06 完成後接入（子隊繼承同一 NPC 路徑）
- 完整支配權（同盟）：暫不實作，待外交系統成熟後擴充

#### G-06. 子隊管理
- **NPC**：`subteam_system` + `population_system` 自動 dispatch/merge
- **玩家**：無 dispatch_subteam / recall_subteam 指令

- **討論結論**：✅ 2026-06-03

**玩家 team 人口結構：**
- 原設計「全記名、無匿名」過於理想化，改為**記名 + 匿名混合**（同 NPC）
- 需更新 game-design.md 相關說明

**底層已完整，G-06 只需 API 接線：**
- `SubteamSystem.dispatch(parent_id, sub_leader_id, pop_count, task, move_target, ...)` — 已有
- `SubteamSystem.try_merge_back(sub_id)` — 同格自動合回，已有
- `SubteamSystem._pick_subteam_leader(team, task)` — 按任務選最適 leader，已有
- TASK 常數全齊：TASK_HERALD / TASK_ESCORT / TASK_PATROL / TASK_BUILD / TASK_MERGE...

**玩家 action 清單（G-06）：**
| action_id | 底層呼叫 |
|---|---|
| `dispatch_subteam` | `SubteamSystem.dispatch(...)` |
| `order_subteam` | 直接設 subteam `current_task` + `move_target` |
| `recall_subteam` | 派信使子隊（TASK_HERALD）→ `_deliver_order` → 目標設 TASK_MERGE + 快照座標 |

**子隊 task 指派：**
- 派出時必須指定 task（無預設）
- 完成後 → TASK_IDLE → faction AI 接管
- 跟隨主隊 = TASK_ESCORT（已有）

**子隊服從邏輯：**
- 玩家指令是「建議」，子隊 AI 仍運作
- values / loyalty 偏差大 → unrest 累積 → 現有事件觸發（split / defect）
- 零新模擬邏輯，吃現有系統

**召回機制：**
- 遠端召回 = 玩家派信使子隊（TASK_HERALD）帶「召回令」
  - `order_task = TASK_MERGE`，`order_target_id = parent_team_id`
  - 信使抵達 → `_deliver_order`：目標取得 TASK_MERGE + `move_target = 信使母隊快照座標`
- 子隊移動到快照座標；若母隊已不在該格：
  - 進入視野後（`team_discovered` 有 parent）→ MovementSystem/sim_runner 更新 `move_target`
  - 原則：視野外不知道母隊在哪，進視野才追蹤（符合資訊不透明設計）
- 抵達同格 → `try_merge_back` 自動觸發

**需補的小修：**
1. `_deliver_order`：傳達 TASK_MERGE 時補設 `target.move_target = origin.tile_pos`
2. MovementSystem 或 sim_runner：TASK_MERGE team 若目標在 `team_discovered` → 更新 `move_target`

---

### 🟡 低優先

#### G-07. 投降
- **NPC**：`handle_diplomacy_message "offer_surrender"`
- **玩家**：無主動投降選項
- **問題待討論**：
  - 玩家敗戰後是否有投降UI？還是直接逃跑/死亡？
  - 投降後的後果（被征服、資源轉移）
- **討論**：待討論

#### G-08. 設定徵收率
- **NPC**：`faction.tribute_rate` 由 FactionAI 隱式管理
- **玩家**：無法改變勢力的 tribute_rate
- **問題待討論**：
  - 玩家作為勢力 leader 應能設定徵收率嗎？
  - 還是 tribute_rate 是系統計算，非玩家決策？
- **討論**：待討論

#### G-09. 勢力策略下令
- **NPC**：`faction_ai_system` + `strategic_ai_system` 每 tick 自動設 goals/strategy
- **玩家**：無法改 faction goals 或對成員下戰略指令
- **問題待討論**：
  - 玩家作為勢力 leader 是否需要手動指令？
  - 還是 AI 自動跑就夠了，玩家只透過 propose_alliance/demand_tribute 間接影響？
  - 若要加：指令範圍（expand/defend/trade_net）？
- **討論**：待討論

---

### 🔵 技術債（非互動缺口）

#### T-01. 架構可擴充性
- **現況**：`execute_action` switch 隨 action_id 增加；新行動需手動加 3 處（player_command_system + player_query_api + player_api_mapper）
- **考量**：目前 ~15 個 action_id，還在可維護範圍
- **建議**：超過 ~20 個再考慮 action registry 模式（Dict of Callables）
- **討論**：待討論

---

## 討論紀錄

*(逐條更新)*

| 缺口 | 結論 | 日期 |
|---|---|---|
| G-05 據點/建設 | 吃 NPC 路徑；接手機制改 _tick_construction；支配權 _has_control；駐守/巡邏 task 後續實作 | 2026-06-03 |
| G-06 子隊管理 | 混合記名/匿名；底層已齊只需 API 接線；召回=信使(TASK_HERALD)帶快照座標；進視野自動追蹤；_deliver_order 補 move_target 設定 | 2026-06-03 |
