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
- **討論結論**：✅ 2026-06-03

**修改位置**：`diplomatic_ai_system.gd` → `try_proactive_diplomacy` → 發送前判斷：

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
覆蓋：NPC 主動提同盟、要求納貢、提議貿易三條路徑。

---

### 🟠 中優先

#### G-02. 征服（戰後強制加入）
- **NPC**：`interaction_system._try_subjugate` — 戰後贏家可強制敗者加入勢力（自動觸發）
- **玩家**：勝戰只得戰利品（last_encounter_result），沒有「征服/收編」選項
- **討論結論**：✅ 2026-06-04 — 選 C

**俘虜與征服的關係（獨立機制）：**
- 俘虜（`prisoner_population`）= 戰中被制伏的個體，存入 winner
- 征服（`_try_subjugate`）= 戰後整個 team 加入勢力（team 層級）
- 兩者共存：勝戰可同時擁有俘虜 + 征服敵 team
- NPC 現行邏輯：`_try_subjugate` 在 `_resolve_combat_end` 自動呼叫；玩家版改為玩家主動選擇

**結論（C = A + B 並存）：**

| 路徑 | 做法 | 語意 |
|---|---|---|
| **強制收編** | `last_encounter_result` 加 `can_subjugate` flag；take_loot 畫面加「收編」→ 呼叫 `_try_subjugate` | 強制臣服；敗者 loyalty 低，日後叛離風險高 |
| **外交收編** | 戰後主動 `propose_alliance`，敗者仍可拒絕 | 平等外交，接受者 loyalty 較高 |

玩家自選路徑，各有後果。

#### G-03. 背叛/離開勢力
- **NPC**：`diplomatic_ai_system.consider_betrayal` → `_execute_betrayal`
- **玩家**：加入勢力後無法離開；無 leave_faction / betray_faction 指令
- **討論結論**：✅ 2026-06-04 — A + B 都實作

**情境 A：玩家是成員（非 leader）**

| 行動 | 直接後果 | 機制 |
|---|---|---|
| `leave_faction`（自願） | 玩家 `faction_id = -1`；原 leader loyalty 下降 | 寫 diplomatic message；原 leader AI 重算關係；不立刻宣戰 |
| `betray_faction`（背叛） | 原勢力所有成員 → `player_hostile_teams`；宣告敵對 | 吃 `_execute_betrayal` 等效邏輯；廣播背叛訊息 |

**全域背叛代價**：`player_state["betrayal_count"] += 1` → diplomatic AI 的 `handle_diplomacy_message` 讀此值調整未來外交接受機率。

**情境 B：玩家是 leader**
- `disband_faction`：`world_state.disband_faction()`（底層已有）；所有成員 `faction_id = -1`；各成員 loyalty 劇降

**玩家 action 清單（G-03）：**
| action_id | 適用情境 | 底層呼叫 |
|---|---|---|
| `leave_faction` | 玩家為成員 | `faction_id = -1`；發 diplomatic message |
| `betray_faction` | 玩家為成員 | `_execute_betrayal` 等效；`player_hostile_teams`；`betrayal_count++` |
| `disband_faction` | 玩家為 leader | `world_state.disband_faction()` |

#### G-04. 通知機制
- **玩家**：只有 `player_forced_event` 輪詢；攻擊警告、資源告急、勢力事件等無 push
- **T-02 後更正**：NPC AI 改讀 `team_intel` / `faction_snapshot`（非直讀 WorldState），NPC 亦受資訊限制——見 T-02 結論
- **討論結論**：✅ 2026-06-04

**提議資料結構**：
```gdscript
# world_state.gd 加（獨立欄位，比塞進 player_state 更乾淨）
var player_alerts: Array = []  # Array[Dictionary]
# alert 格式：{ "type": String, "tick": int, "data": Dictionary }
```

**通知類型建議（優先順序）：**

| 類型 | 觸發點 | 緊急度 |
|---|---|---|
| `food_critical` | `resource_system`：`needs["food"] < 0.3` | 🔴 高 |
| `member_defected` | `event_N3_defect`：目標 team == 玩家 | 🟠 中 |
| `faction_member_betrayed` | `_execute_betrayal`：betrayer 所屬勢力 == 玩家勢力 | 🟠 中 |
| `subteam_destroyed` | `encounter_system`：loser 是玩家子隊 | 🟠 中 |
| `outpost_captured` | `_complete_construction`：舊 owner 是玩家 | 🟡 低 |

攻擊警告已由 `encounter_active` + `encounter_view` 覆蓋，不需重複。  
UI 端輪詢 `player_alerts`，顯示後清空（同 `forced_event` 模式）。待確認類型清單。

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

**現有路徑（已實作）：**
- `player_api_mapper.gd:234`：player 可**回應** NPC 送來的 surrender offer（accept/reject）
- `player_command_system.gd:300`：`"alliance", "surrender"` 回應處理
- → 玩家可回應 NPC 主動投降，但**無法主動發起**

**缺口：玩家主動投降**

| 選項 | 時機 | 後果 |
|---|---|---|
| **A. 遭遇戰中加投降按鈕** | 戰中玩家主動觸發 | 資源轉移 + 被收編（`_try_subjugate`）；winner 決定是否接受 |
| **B. 外交 `offer_surrender` action** | 任意時機（含開戰前、信使送達） | 同上，透過 diplomatic 路徑 |

**結論（A+B）**：A 戰中即時 + B 外交通道。接收端 `diplomatic_ai_system:offer_surrender` 底層已有。

**玩家 action 清單（G-07）：**
| action_id | 時機 | 底層 |
|---|---|---|
| `offer_surrender`（外交） | 任意時機 | `player_forced_event` → diplomatic 路徑；對方 AI 按好戰/慎重/實力比決定接受 |
| 遭遇戰投降按鈕 | `encounter_active` 期間 | 呼叫同 `offer_surrender`；winner 接受 → 資源轉移 + `_try_subjugate` |

- **討論結論**：✅ 2026-06-04

#### G-08. 設定徵收率
- **NPC**：`faction.tribute_rate` 由 FactionAI 隱式管理
- **玩家**：無法改變勢力的 tribute_rate
- **討論**：待確認

**兩個不同概念（勿混淆）：**

| | `tribute_rate` | `demand_tribute` |
|---|---|---|
| 定義 | 勢力 leader 向**成員**抽取的內部比例 | 向**外部** team 要求納貢（一次性） |
| 拒絕機制 | 無拒絕；高率 → 成員 loyalty 下降 → unrest/defect | 對方 AI `handle_diplomacy_message` 按 好戰/慎重/信義 + 實力比判斷 |

設 `tribute_rate` 的後果：高率 → 成員 loyalty 掉 → 現有 `event_N3_defect` / `event_split` 觸發。**完全吃現有機制，零新邏輯。**

**提議選項：**

| 選項 | 做法 |
|---|---|
| **A. 玩家 leader 直接設定** | `set_tribute_rate` action；接受 0.0–1.0；底層 `tribute_rate` 欄位已有 |
| **B. AI 管理，玩家不直接控制** | 不實作，玩家用 `demand_tribute` 一次性徵收 |

**結論（A）**：`set_tribute_rate` action；接受 0.0–1.0；`faction.tribute_rate` 欄位已有。高率 → 成員 loyalty↓ → 現有 `event_N3_defect` / `event_split` 自動觸發，零新邏輯。

- **討論結論**：✅ 2026-06-04

#### G-09. 勢力策略下令
- **NPC**：`faction_ai_system` + `strategic_ai_system` 每 tick 自動設 goals/strategy
- **玩家**：無法改 faction goals 或對成員下戰略指令
- **討論結論**：✅ 2026-06-04 — 選 D（B + C）

**結論（D = B + C）：**

**B：玩家設定 faction goal**
- `set_faction_goal` action；接受 `expand / defend / trade_net`
- 寫入 `faction.player_goal_override`；faction_ai 讀此 override 跳過自動計算
- 抗命：好戰/野心高成員 → values 衝突 → unrest 累積 → 閾值後忽略 override，恢復自主 AI → 長期 event_split / N3_defect

**C：對個別成員下令**
- `order_faction_member` action；直設 target team `player_commanded_task` + `move_target`
- 抗命層一：faction_ai 每 `STRATEGIC_INTERVAL` 重跑 → values 衝突自然覆寫
- 抗命層二：loyalty 門檻
  ```
  if loyalty > 0.4 → 執行 player_commanded_task
  else → 執行 AI 自算 task；unrest++
  unrest > MAX → event_split / N3_defect
  ```

**新增欄位：**
| 欄位 | 位置 | 說明 |
|---|---|---|
| `player_goal_override: String` | `FactionData` | `""` = 無 override |
| `player_commanded_task: String` | `TeamData` | `""` = 無命令 |

零新事件，吃現有 unrest / split / defect 系統。

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

#### T-02. NPC AI 全知（`team_intel` 未接入）
- **現況**：`vision_system` 每 tick 寫入 `team_intel[obs][tgt]`（含噪音 `population_est`、粗略 `resource_scale`），但所有 AI 直讀 `WorldState` 精確值
- **影響**：NPC 外交/叛盟/攻擊決策用精確人口/資源，不受視野限制
- **討論結論**：✅ 2026-06-03 — 選方案 B

**方案 B 結論（外部目標）：**

AI 對「已發現的非勢力」team 統一改讀 `team_intel`；dist=0 時 noise=0 → `population_est` 本身即精確，無需特判。

**外部目標修改（三處）：**

| 函式 | 現況 | 改成 |
|---|---|---|
| `diplomatic_ai._calc_diplomacy_score` | `other_team.population`（精確） | `team_intel[self_id][other_id]["population_est"]`，fallback = `self_team.population`（謹慎估算） |
| `diplomatic_ai.consider_betrayal` | `ally_team.population`（精確） | 讀 `f.known_member_states[ally_id]["population"]`（快照） |
| `strategic_ai._evaluate_alliance_need` | `t.population`（精確） | `team_intel[mid][tid]["population_est"]` |
| `strategic_ai._assign_encirclement` | `target.tile_pos`（即時） | `team_intel[leader_id][target_id]["tile_pos"]` |

**Fallback**：無 `team_intel` → `team_discovered` 已過濾，理論不發生；防禦性 fallback = 視對方與自己等強。

---

**勢力內部延遲（A+B 方案）：**

`strategic_ai` 讀成員狀態改從 `f.known_member_states[tid]` 讀（快照），而非直讀 WorldState。

**快照更新觸發：**

| 方案 | 觸發點 | 實作 |
|---|---|---|
| **A. 信使抵達** | `_deliver_order` 執行時 | 加一行：`state.snapshot_faction_member(herald.parent_team_id, tick)` |
| **B. 同格同勢力接觸** | `sim_runner` 每 tick | 同格 team 中有同 `faction_id` 者 → `snapshot_faction_member` |

**成員快照讀取替換（三處）：**

| 函式 | 現況 | 改成 |
|---|---|---|
| `strategic_ai._find_weakest_member` | `t.population` | `f.known_member_states.get(tid, {}).get("population", 9999)` |
| `strategic_ai._faction_total_pop` | `t.population` | 快照 population 加總 |
| `strategic_ai._assign_encirclement` members | 直讀 member position | 快照 `tile_pos` |

**遊戲效果：**
- 遠方成員斷聯 → leader 無法知道最新狀態 → 可能派兵支援已滅的成員
- 信使系統（G-06）有額外戰略價值：不只召回子隊，也傳遞情報
- 「派信使回報戰況」成為玩家/NPC 的合理行動

---

## 討論紀錄

*(逐條更新)*

| 缺口 | 結論 | 日期 |
|---|---|---|
| G-02 征服 | A+B 並存：強制收編（_try_subjugate + can_subjugate flag）+ 外交收編（propose_alliance）；玩家自選 | 2026-06-04 |
| G-03 背叛/離開勢力 | A+B：成員可 leave/betray（betrayal_count++）；leader 可 disband_faction | 2026-06-04 |
| G-04 通知機制 | player_alerts Array；food_critical/member_defected/faction_member_betrayed/subteam_destroyed/outpost_captured | 2026-06-04 |
| G-07 投降 | A+B：遭遇戰按鈕 + 外交 offer_surrender；底層已有 | 2026-06-04 |
| G-08 設定徵收率 | set_tribute_rate action；0.0–1.0；高率→loyalty↓→現有事件觸發 | 2026-06-04 |
| G-09 勢力策略下令 | D：set_faction_goal（player_goal_override）+ order_faction_member（player_commanded_task）；loyalty門檻+unrest抗命 | 2026-06-04 |
| G-05 據點/建設 | 吃 NPC 路徑；接手機制改 _tick_construction；支配權 _has_control；駐守/巡邏 task 後續實作 | 2026-06-03 |
| G-06 子隊管理 | 混合記名/匿名；底層已齊只需 API 接線；召回=信使(TASK_HERALD)帶快照座標；進視野自動追蹤；_deliver_order 補 move_target 設定 | 2026-06-03 |
| G-01 NPC外交繞過 | diplomatic_ai try_proactive_diplomacy 加 player 攔截 → player_forced_event；零額外介面 | 2026-06-03 |
| T-01 架構可擴充 | G-05+G-06 加完後達~23 action_id 再重構 registry；現在不動 | 2026-06-03 |
| T-02 NPC AI 全知 | 外部目標改讀 team_intel；勢力內部改讀 faction_snapshot（A+B更新：信使抵達+同格接觸） | 2026-06-03 |
