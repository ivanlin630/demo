# 玩家 vs NPC 互動機制缺口分析

> 建立：2026-06-03 | 持續更新中

---

## 已對齊（玩家 = NPC）

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
- **問題待討論**：
  - 玩家建據點限當前格還是可指定格？
  - 資源消耗條件（material？）
  - 是否需要拆除指令？
  - 建設時間 vs 即時？
- **討論**：待討論

#### G-06. 子隊管理
- **NPC**：`subteam_system` + `population_system` 自動 dispatch/merge
- **玩家**：無 dispatch_subteam / recall_subteam 指令
- **問題待討論**：
  - 玩家可以從自己 team 分出子隊嗎？條件是什麼？
  - 子隊獨立運作 vs 跟隨護衛 vs 執行任務
  - 召回子隊的條件
  - 子隊 leader 指定邏輯（玩家手動 vs 系統晉升）
- **討論**：待討論

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
| — | — | — |
