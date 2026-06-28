# 統一統領決策 v2 — 意圖驅動（戰略意圖→協同子命令，每令帶 why）

> 系統 HOW spec。承藍圖 ruling `2026-06-28-...-intent-driver-invariant`（**修正：單姿態方向作廢**，改意圖驅動推理多重性）+ 新北極星不變量「凡 named 意圖必有可解釋驅動」（已納 invariants.md）。
> **v1 單姿態 spec 作廢**（branch `feat/commander-decision-unify` 不 merge，僅 Task 2 revert war-priority 部分理念保留）。統一決策 arc 另一半（統領層），排玩家面之前。

## 真根 + 願景修正

`_update_goals`（faction_ai:632-712）= 多閾值並行 append：各大事過閾全發。**measure 基準**（`commander_directive_measure` merge `8c6781d`）：每 persona 同發 ≥2 令、好戰霸主 4 令。

**v1 誤判**：以為病在「發多令」→ 收斂單姿態。**藍圖校正**：氣點不是發兩令，是**令無法解釋從哪來、為什麼**（閾值憑空跳、無父意圖）。**多令 OK 甚至嚮往**——主戰統領發「攻擊+外交」是對的，只要外交是**服務戰爭的欺敵 feint**（可解釋）。

= 北極星不變量：**凡 named 意圖必有可解釋驅動**（追回 need/value/belief/父意圖）。統領層 = 第一處落實。

## 願景（藍圖 A，類深度 AI 推理）

1. **意圖驅動**：統領先 utility 選一個**戰略意圖**（征服敵X / 防衛 / 致富 / 擴張 / 守成）。
2. **意圖生成協同子命令**：征服X → 攻擊X（手段）+ 對X盟友外交（欺敵拖住）+ 徵收（籌軍費）= 多令服務同一意圖。
3. **每令帶 why**（連回父意圖）：外交不是獨立閾值跳出，是**因為**服務征服X、且是**不真心戰術外交**。
4. **連貫來自共享意圖，非單一命令**。多重性是 feature。
5. 意圖要 commitment-hysteresis（統領最該硬）、吃人格、吃 belief 非真相；成熟並行軌（多意圖同時）= 制度化擴充（未來）。

## 範圍

**做**：refactor `_update_goals` 從多閾值 append → **意圖 argmax → 協同子命令生成（帶 driver）**。
- 統領每 cadence utility 選**一個戰略意圖**（persona×belief×條件 + 承諾 hysteresis）。
- 意圖 → 確定性展開**協同子命令集** `f.goals`（可多令），每令記**父意圖 + why**（driver metadata，滿足北極星不變量）。
- 成員照 P3/P4 混合協調響應子命令（按人格分配到攻擊/欺敵外交/徵收 = 多重性 feature，非衝突）。

**意圖集（v1 姿態集升級）**：`{守成(default), 征服X, 防衛, 致富, 擴張}`。
- **征服X** → {攻擊X, 外交(X盟友,欺敵), 徵收(軍費)}。
- **防衛** → {守成/徵收(備戰)}（威脅高時）。
- **致富** → {徵收, 外交(貿易締約,真心)}。
- **擴張** → {立國(若未established) / 攻擊(弱鄰) / 建設}。
- **守成** → {}（無 stakes 令，default）。

**非目標**（明文）：
- **不收斂單一命令**（v1 錯）：意圖單一，子命令可多。
- **不碰成員側 P3/P4 option**（攻擊/徵收/外交 engine option 原樣）；成員按人格分配到子命令=多重性。
- **war-priority 移除**（FACTION_DUTY_DRIVE_LESSER revert）：成員選欺敵外交 ≠ skip 戰爭（driver=征服）→ 無需戰>和分級。
- **不碰 `strategic_ai._update_faction_goals`**（expand/defend/trade_net 另層）。
- **成熟並行軌（多意圖同發）= 未來**（制度化擴充，P3 軸#3）；現在單一意圖。
- **不給所有 action 塞 driver 欄重寫**（範圍紀律）：**只統領層落實 driver**；其餘審計鏡頭逐步補。
- 緊急徵收（food emergency）= survival override（意圖前 return）。立國 = 擴張意圖的子命令 or 分離 gate（plan 定）。不新 TASK_*。

## 設計

### 1. FactionData：意圖 + driver
```gdscript
var intent: Dictionary = {}   # {type:"征服"/"防衛"/..., target_id:int(-1), why:String} 戰略意圖（承諾追蹤）
# f.goals 保 Array[String]（成員消費端不變：X in f.goals）
var goal_drivers: Dictionary = {}   # goal(String) → {intent:String, why:String} 每令的 driver（北極星：可解釋）
```
> 成員消費端（leader dispatch / member 802-827 / unified faction_stakes）讀 `X in f.goals` **不變**。`goal_drivers` = legibility/audit/玩家 C metadata（UI/inquiry 可讀，本塊先存不強求 UI）。

### 2. `_update_goals` 重構（意圖 argmax → 子命令展開）
```
_update_goals(state, f):
    f.goals.clear(); f.goal_drivers.clear()
    leader / leader_p
    1. player override（保留）
    2. 緊急徵收 override（food<emergency）→ f.goals=["徵收"]; goal_drivers["徵收"]={intent:"survival",why:"飢荒籌糧"}; return
    3. 意圖 argmax：score 每意圖 = Σ(人格權重×驅力) + 承諾 bonus(==f.intent.type)
        征服:  好戰/野心 × belief-弱敵存在 × readiness（既有 attack gate→有合格 target 才 score>0）
        防衛:  威脅(鄰強敵) × 慎重
        致富:  貪婪 × (有貿易對象/富 member)
        擴張:  野心 × (未established or 有弱鄰/建設空間)
        守成:  default base（知足/低野心，TEST VALUE）
        argmax → f.intent = {type, target_id, why}
    4. 意圖展開子命令（確定性，每令記 driver）：
        match f.intent.type:
            "征服": _emit("攻擊", intent="征服X", why="攻取X")
                    if X 有盟友: _emit("外交", intent="征服X", why="欺敵拖住X盟友", insincere=true)
                    if 軍費不足: _emit("徵收", intent="征服X", why="籌軍費")
            "防衛": _emit("守成"/"徵收", why="備戰")
            "致富": _emit("徵收", why="斂財"); _emit("外交", why="貿易締約"(真心))
            "擴張": 未established→立國; else _emit("攻擊"弱鄰/"建設", why="拓土")
            "守成": （無令）
    （_emit(goal, intent, why) = f.goals.append(goal) + f.goal_drivers[goal]={intent,why}）
```
- **承諾 hysteresis**（WHAT#5，統領最該硬）：意圖 argmax 對 `==f.intent.type` 加 `COMMANDER_COMMITMENT_BONUS`（>隊層 0.3）。情勢無實質變不翻意圖（防戰略反覆）。釋放：意圖條件 gate fail（敵消失/readiness 掉/belief 變）。
- **吃 belief**（WHAT#4）：征服意圖的 target/strength 用 `BeliefSystem.best_estimate`（既有 attack gate 保留）→ 按以為的敵強度選征服。
- **欺敵嵌入北極星**：外交子命令 driver=「服務征服、不真心」→ 玩家見「攻擊X + 外交X盟友」可推「征服X、外交是 feint」；賭錯被咬。

### 3. war-priority OK繃移除
意圖驅動下，成員選欺敵外交 = 服務征服（driver 正當）非 skip 戰爭 → 戰>和分級 moot。**revert** `FACTION_DUTY_DRIVE_LESSER`（徵收/外交 drive 回 1.5）。成員按人格分配到子命令（好戰→攻擊、義氣/計謀→欺敵外交、貪婪→徵收）= 多重性 feature。

## believability（守 ruling A + 北極星）
- **意圖可解釋**：每令追回父意圖（f.goal_drivers）→ 北極星不變量滿足（統領層）。
- **多重性=feature**：征服→攻擊+欺敵外交+徵收，連貫來自共享意圖。
- **承諾**：意圖不每 cadence 翻。**吃人格**：好戰→征服、貪婪→致富、慎重→防衛/守成。**吃 belief**：按以為的敵強度征服。
- **欺敵=玩家 C**：driver 真（征服）+ action 假（外交 feint）→ 情報遊戲。

## 驗收
- **意圖單一、子命令協同帶 driver**：`commander_directive_measure` 重跑（擴量 driver）——好戰霸主→意圖「征服X」+ 子令[攻擊X(why攻取),外交(why欺敵),徵收(why軍費)]，**每令有 goal_drivers**。商業 leader→意圖「致富」+[徵收,外交(真心貿易)]。溫和→「守成」(無令)。**無無因令**（每令追回意圖）。
- **承諾 hysteresis**：committed 征服隊連續 cadence 不翻意圖（情勢不變）。
- **吃人格/belief**：好戰→征服 vs 商業→致富分歧；敵 belief 顯強→不選征服。
- **P3/P4 不回歸 + war-priority 移除**：`p3_war_scenario` 跟戰——統領「征服」下攻擊+欺敵外交，好戰 member→攻擊、義氣 member→欺敵外交（**driver=征服故非 skip**）；跟戰數記錄（可能非 3/4，但**每個選擇可解釋**=新驗收標準，非硬湊 3/4）。P4 徵收/外交 member 響應在意圖子命令下成立。
- **緊急徵收 override**：food<emergency → 強制徵收(driver=survival)，不論意圖。
- **守恆+魂驗**：coin_eq 0、InvariantAudit 0、framework S1-S6 PASS（S1 立國=擴張意圖子命令/S2 feud 仍 fire）。
- **world_sim**：2yr 不崩、派系下協同令（有 driver）、意圖穩定（無反覆）、征服稀有（多數守成/致富）。

## 檔案
- `scripts/simulation/faction_ai_system.gd`：`_update_goals` 重構（意圖 argmax + 子命令展開 + driver tagging + 承諾 hysteresis + 緊急徵收 override）；helper `_score_intent`/`_emit_goal`。
- `scripts/data/faction_data.gd`：`intent: Dictionary` + `goal_drivers: Dictionary`。
- `scripts/simulation/decision/terms.gd`：revert `FACTION_DUTY_DRIVE_LESSER`。
- `docs/invariants.md`：意圖驅動段已納（北極星）；「隊目標單一 owner」段補統領=意圖→協同子命令（非並行閾值/非收斂單一）。
- `scripts/debug/headless_test.gd`：新測（意圖 argmax + 子命令帶 driver + 每令可解釋 + hysteresis + 人格/belief 分歧 + 緊急徵收 override + war-priority 移除不回歸）。
- `scripts/debug/commander_directive_measure.gd`：擴量 driver（每令印 intent+why、驗無無因令）。
- `scripts/debug/p3_war_scenario.gd`：意圖模式下跟戰 + driver 可解釋。

## 風險 + 緩解
- **過度設計（driver 欄滿天飛）**：範圍紀律——**只統領層** f.intent/goal_drivers，不擴全 action。其餘審計鏡頭。
- **欺敵外交真消費**：外交子命令 driver=欺敵，但執行走既有 TASK_DIPLOMACY（成員到場斡旋）。「不真心」目前 = driver metadata（玩家 C 用）；外交實際效果（締約 vs 拖延）= 既有 interaction，本塊不改其結算（記 backlog：欺敵外交的真戰術效果=未來）。
- **P3/P4 跟戰非 3/4**：意圖驅動下成員分配到子命令（攻擊/欺敵外交）→ 跟戰可能 <3/4，但**每選擇可解釋**=新標準。驗收改「無無因令 + 每令追回意圖」，非硬湊跟戰數。**若藍圖要特定跟戰 feel → 回報**。
- **承諾過硬/鬆**：`COMMANDER_COMMITMENT_BONUS` TEST VALUE + gate fail 釋放。
- **scope sprawl**：只 `_update_goals` + faction_data 2 欄 + terms revert + 測。不碰成員 option/strategic_ai/並行軌/外交結算。
- **v1 branch 處置**：`feat/commander-decision-unify`（單姿態）不 merge（作廢方向）；本 v2 重實作。Task 2 的 war-priority revert 理念保留。

## 開放細節（plan 定）
- 意圖集最終（征服/防衛/致富/擴張/守成）+ 各 score 公式（複用 attack_score/loot_score/threat 重組）。
- 子命令展開規則（征服→哪些子令的條件：有盟友才欺敵外交、軍費不足才徵收）。
- `f.intent`/`goal_drivers` 結構 + 消費端（先存，UI/inquiry 讀=後續）。
- `COMMANDER_COMMITMENT_BONUS`/`SETTLE_BASE` 量級。
- 立國 = 擴張子命令 vs 分離 gate。
- 欺敵外交真效果（本塊 driver-only vs 結算改）= 傾向 driver-only（範圍紀律），結算記 backlog。
- 跟戰 feel 是否需對齊特定數（傾向否，改「可解釋」標準，但回報藍圖）。
