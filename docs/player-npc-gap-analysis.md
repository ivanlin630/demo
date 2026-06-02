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
- **討論**：待確認

**提議選項（1 個明確修法，無爭議）：**

修改位置：`diplomatic_ai_system.gd` → `try_proactive_diplomacy` → 發送前判斷：

```gdscript
if target_id == state.teams[state.player_id].team_id:
    state.player_forced_event = {
        "type": "diplomacy",
        "from_id": from_id,
        "msg_type": msg_type,
        # ... 其餘同 handle_diplomacy_message 所需資料
    }
    state.player_forced_event_id = str(randi())
    return  # 不直接解算
```

`player_api_mapper` 已有 diplomacy 回應路徑（accept/reject/counter），**零額外介面**。
此修法覆蓋：NPC 主動提同盟、要求納貢、提議貿易三條路徑。

---

### 🟠 中優先

#### G-02. 征服（戰後強制加入）
- **NPC**：`interaction_system._try_subjugate` — 戰後贏家可強制敗者加入勢力
- **玩家**：勝戰只得戰利品（last_encounter_result），沒有「征服/收編」選項
- **討論**：待確認

**提議選項：**

| 選項 | 做法 | 語意差異 | 複雜度 |
|---|---|---|---|
| **A. 戰後加入 subjugate 選項** | 遭遇戰結束後 `last_encounter_result` 多一個 `can_subjugate` flag；玩家在 take_loot 畫面多一個「收編」按鈕 → 呼叫 `_try_subjugate` | 強制臣服，非自願結盟；敗者 loyalty 低、日後叛離機率高 | 低（底層已有） |
| **B. 只走 propose_alliance（現有）** | 戰後主動提同盟，敗者仍可拒絕 | 外交語意，平等；不強制 | 零（已有） |
| **C. 兩者皆有** | A + B 同時存在；征服 vs 外交各有後果 | 最貼近歷史感 | 中 |

推薦 **A**（語意獨特，底層 0 成本，已有 NPC 路徑）。B 已存在可保留，C 是 A 的自然延伸。

#### G-03. 背叛/離開勢力
- **NPC**：`diplomatic_ai_system.consider_betrayal` → `_execute_betrayal`
- **玩家**：加入勢力後無法離開；無 leave_faction / betray_faction 指令
- **討論**：待確認

**提議選項：**

三種情境分開處理：

**情境 A：玩家是成員（非 leader）**
- `leave_faction`（自願脫離）：玩家 `faction_id = -1`；原 leader 收到外交訊息；聲望/loyalty 小懲
- `betray_faction`（背叛）：吃 `_execute_betrayal` 同等邏輯；宣告敵對，中斷同盟

**情境 B：玩家是 leader**
- `disband_faction`（解散）：`world_state.disband_faction(faction_id)`（已有）；所有成員 `faction_id = -1`；大量外交代價

**情境 C：不實作**
- 加入勢力是永久承諾，只有被驅逐或勢力滅亡才能離開

推薦 **情境 A + B**，情境 C 太嚴苛影響玩家體驗。  
`disband_faction` 已有底層，`leave_faction` 只需設 `faction_id` + 寫 diplomatic message。

#### G-04. 通知機制
- **NPC**：不需要，每 tick 直讀 WorldState
- **玩家**：只有 `player_forced_event` 輪詢；攻擊警告、資源告急、勢力事件等無 push
- **討論**：待確認

**提議選項：**

**資料結構**（推薦）：
```gdscript
# world_state.gd 加
var player_alerts: Array = []  # Array[Dictionary]
# alert 格式：{ "type": String, "tick": int, "data": Dictionary }
```

`player_state` dict 已被其他用途佔用，獨立欄位更乾淨。

**通知類型建議（優先順序）：**

| 類型 | 觸發點 | 緊急度 |
|---|---|---|
| `food_critical` | `resource_system`：`needs["food"] < 0.3` | 🔴 高 |
| `member_defected` | `event_N3_defect`：目標 team == 玩家 | 🟠 中 |
| `faction_member_betrayed` | `_execute_betrayal`：betrayer 所屬勢力 == 玩家勢力 | 🟠 中 |
| `subteam_destroyed` | `encounter_system`：loser 是玩家子隊 | 🟠 中 |
| `outpost_captured` | `_complete_construction`：舊 owner 是玩家 | 🟡 低 |

**注意**：攻擊警告已由 `encounter_active` + `encounter_view` 覆蓋，不需重複。  
UI 端輪詢 `player_alerts`，顯示後清空（同 `forced_event` 模式）。

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
- **討論**：待確認

**提議選項：**

| 選項 | 時機 | 後果 | 備註 |
|---|---|---|---|
| **A. 遭遇戰中投降按鈕** | 敗況時（如 HP < 50%）出現「投降」 | 資源轉移 + 被收編（同 `_try_subjugate`） | 最自然觸發點 |
| **B. 外交主動投降** | 任意時機，`offer_surrender` action | 同上，但主動性更高 | 底層已有路徑 |
| **C. 不實作，只有逃跑** | 戰敗只能逃（`TASK_FLEE`） | 無投降選項 | 最簡單 |

推薦 **A**（體驗感最強，不需新 action，遭遇戰畫面加一個按鈕）。  
後果邏輯共用 `_try_subjugate`：winner 決定是否接受，敗者加入 winner 勢力。

#### G-08. 設定徵收率
- **NPC**：`faction.tribute_rate` 由 FactionAI 隱式管理
- **玩家**：無法改變勢力的 tribute_rate
- **討論**：待確認

**提議選項：**

| 選項 | 做法 | 後果設計 |
|---|---|---|
| **A. 玩家 leader 可直接設定** | 新增 `set_tribute_rate` action；接受 0.0–1.0 float | 高率 → 成員 loyalty 下降（已有機制）；低率 → 領袖資源收益少 |
| **B. tribute_rate 系統計算，玩家間接影響** | AI 按 faction 資源/壓力自動調整；玩家只透過 `demand_tribute` 觸發一次性徵收 | 不直接控制，節省設計複雜度 |
| **C. 玩家 leader 設定上下限，AI 在範圍內調整** | 玩家設 `tribute_rate_min` + `tribute_rate_max` | 折衷，較複雜 |

推薦 **A**（體驗最直接，底層 `tribute_rate` 欄位已有，只需 API + UI）。  
B 適合早期 demo，A 適合中期加入。

#### G-09. 勢力策略下令
- **NPC**：`faction_ai_system` + `strategic_ai_system` 每 tick 自動設 goals/strategy
- **玩家**：無法改 faction goals 或對成員下戰略指令
- **討論**：待確認

**提議選項：**

| 選項 | 做法 | 玩家影響力 |
|---|---|---|
| **A. 完全 AI 管理** | 不實作；玩家只透過 diplomacy/tribute 間接影響 | 低（間接） |
| **B. 玩家設定 faction goal** | 新增 `set_faction_goal` action；接受 `expand/defend/trade_net`；faction_ai 讀此 override | 中（影響 AI 目標選擇） |
| **C. 玩家可對個別成員 team 下令** | 新增 `order_faction_member` action；直接設 target team 的 `current_task` + `move_target` | 高（微觀控制） |
| **D. B + C 組合** | 既可設總策略又可個別下令 | 最高 |

推薦 **A 作為現階段預設**，B 作為後期加入目標（faction goal 已有架構，只需 override 入口）。  
C/D 涉及 NPC 服從/unrest 邏輯，建議 G-06 子隊機制穩定後再實作。

---

### 🔵 技術債（非互動缺口）

#### T-01. 架構可擴充性
- **現況**：`execute_action` switch 隨 action_id 增加；新行動需手動加 3 處（player_command_system + player_query_api + player_api_mapper）
- **考量**：目前 ~15 個 action_id，還在可維護範圍
- **建議**：超過 ~20 個再考慮 action registry 模式（Dict of Callables）
- **討論**：待確認

**提議**：**暫不動（YAGNI）**。

G-05 加 5 個、G-06 加 3 個 → 合計約 23 個 action_id。  
屆時可一次重構為 registry 模式，比現在做更有資訊（知道完整列表）。  
重構範圍：`player_command_system.gd` 的 `execute_action` switch → `_action_registry: Dictionary`（`action_id: Callable`）。

---

## 討論紀錄

*(逐條更新)*

| 缺口 | 結論 | 日期 |
|---|---|---|
| G-05 據點/建設 | 吃 NPC 路徑；接手機制改 _tick_construction；支配權 _has_control；駐守/巡邏 task 後續實作 | 2026-06-03 |
| G-06 子隊管理 | 混合記名/匿名；底層已齊只需 API 接線；召回=信使(TASK_HERALD)帶快照座標；進視野自動追蹤；_deliver_order 補 move_target 設定 | 2026-06-03 |
