# P2a survival options — 投靠/紮營/乞食 納統一引擎（unified 隊補齊絕境 repertoire）

> 系統 HOW spec。承他域 ruling `2026-06-22-otherdomain-ruling` + 統一框架 arc。P2 切兩片，**本 spec = P2a（低風險：純加 option，不退役、不碰 non-unified）**。
> P2b（退役舊 `_evaluate_survival` 雙 owner + non-unified survival 動作選擇改呼 engine）= 下 session 高風險塊，本 spec 不做。
> **交付**：閉藍圖**標記1債**——「loot/join 必還經濟隊」之 **join**（敗商隊投靠=經濟↔衝突橋）。loot 已 P1 done；本塊補 join（+camp/beg 完整化）。

## 背景：雙 owner 現況（探碼證）

- unified 隊（`TAG_MERCHANT`|`TAG_PRODUCE`）survival 已折進 `DecisionEngine`（gate `faction_ai:783/1019/2237`）。engine 現覆蓋 survival **4/6**：`掠奪`(loot,P1)/`覓食`(forage)/`survival`(FLEE)/`返家補給`(restock)。
- **缺 3**：`投靠`(JOIN)/`紮營`(CAMP)/`乞食`(BEG)——舊 `_trigger_survival` homeless 分支（`faction_ai:2410-2472`）有，engine 沒有。
- 後果：**無家 unified 隊**（敗商隊/流民）深危時，engine 只能 forage（pop≤15 才行）或 loot（須殘忍 leader+弱獵物）→ 多數無家溫和大隊**無絕境出路 → 餓死**（標記1債的具體缺口）。
- non-unified（軍隊等）仍走舊 `_trigger_survival` 全路徑 = **本塊零碰**（P2b 才退役）。

## 範圍（緊，防 sprawl）

**只做**：給 unified 隊加三個 engine survival option（複用既有 pref 公式/target finder/TASK_*）：
1. **`投靠`**（JOIN）— 投靠強鄰（義氣/信義/求生欲 leader）。**= 標記1 join 債**。
2. **`紮營`**（CAMP）— 無主可農地立 crude camp 定居（野心/統領/求生欲 leader）。
3. **`乞食`**（BEG）— 向有餘糧隊乞食（墊底，人人可）。

**非目標**（明文排除）：
- **不退役** `_evaluate_survival`/`_trigger_survival`（P2b）。**不碰 non-unified 隊**舊路徑（原樣零改）。
- **不改 ~20 個 headless_test 直呼 `_evaluate_survival`/`_trigger_survival` 點**（P2b 退役時才動）。
- 不做 hunt（`try_hunt_predator` 無 TASK、直呼戰鬥；engine option 化延 P2b）。
- 不新 TASK_*（`TASK_JOIN`/`TASK_CAMP`/`TASK_BEG` 既有，已在 `SURVIVAL_TASKS`）。
- 不改 target finder（`_find_strong_neighbor`/`_find_unowned_farmable_tile`/`_find_aid_target` 複用）。
- 不改 crude camp 立營 / forced join 機制（既有複用）。

## 設計：三個絕境 option（複用既有 pref/target/task）

### 1. REGISTRY（`options.gd`）
```
"投靠": [["join_drive", "join"]],
"紮營": [["camp_drive", "camp"]],
"乞食": [["beg_drive",  "beg"]],
```

### 2. terms（`terms.gd`）
- **drive eval = desperation magnitude**（食物越低越強，吃飽→0=健康隊不選）：
  - `join_drive`：`opt=="投靠"` → `DESPERATION_SCALE × max(0, DESPERATION_DAYS − food_days)`（has_strong_neighbor 時，否則 0）。
  - `camp_drive`：`opt=="紮營"` → 同式（has_farmable_tile 時）。
  - `beg_drive`：`opt=="乞食"` → 同式 **× BEG_FLOOR_FACTOR**（< 1，beg 是墊底序，drive 略低於 join/camp，對齊舊 fallthrough 排序）。
- **weight（人格，複用既有 `_loot_pref` 對齊三式）**：
  - `join`：`義氣×0.4 + 信義×0.3 + 求生欲×0.3`（複用 `_join_pref`）。
  - `camp`：`野心×0.4 + 統領×0.3 + 求生欲×0.3`（複用 `_camp_pref`）。
  - `beg`：`求生欲`（人人可乞，flat-ish；墊底由 drive×BEG_FLOOR_FACTOR 壓低，非靠 weight）。
- **量級對齊**：危時 `survival_pressure`(4×(3−food))/`restock_need`(1.5×(5−food)) 仍量級支配 → 有家先返家補給、覓食划算先覓食；join/camp/beg 為「無家又無覓食出路」的絕境分流。`DESPERATION_SCALE` 調至 join/camp 與 survival-class 同域但不碾壓 forage/restock（TEST VALUE，plan 定）。

### 3. applicable（`options.gd`）— 絕境守衛（健康隊不入榜）
```
"投靠": ctx.food_days < DESPERATION_DAYS and ctx.has_strong_neighbor
"紮營": ctx.food_days < DESPERATION_DAYS and ctx.has_farmable_tile and not ctx.has_own_outpost  # 無家才紮新營
"乞食": ctx.food_days < DESPERATION_DAYS and ctx.has_aid_target
```
- 健康隊 food_days≥DESPERATION → 三者皆不 applicable → TC1/4/6/7 零影響、ranking 不變。

### 4. to_task（`options.gd`）
```
"投靠": {task=TASK_JOIN,  target=strong_neighbor_pos, combat_target=strong_neighbor_id}
"紮營": {task=TASK_CAMP,  target=farmable_pos}
"乞食": {task=TASK_BEG,   target=aid_pos, combat_target=aid_target_id}
```
（複用既有 finder；無目標→IDLE/(-1,-1)，`_decide_unified` 退次佳 dispatch-fallback 既有）。

### 5. DecisionContext（`decision_context.gd`）新欄 + gather
- `has_strong_neighbor`/`strong_neighbor_id`/`strong_neighbor_pos`（`_find_strong_neighbor`）。
- `has_farmable_tile`/`farmable_pos`（`_find_unowned_farmable_tile`）。
- `has_aid_target`/`aid_target_id`/`aid_target_pos`（`_find_aid_target`）。
- gather 複用 `FactionAISystem.new()._find_*`（對齊既有 ctx 既呼 `_find_weakest_prey` 風格）。

## 兩處 seam wrinkle（必處理，否則行為斷）

### W1. camp 到達立營 hoist（unified 隊現跳過）
`_evaluate_survival` 對 unified 隊 line 2237 early-return → **跳過 camp-arrival 結算**（2263-2275，`establish_crude_camp`+release）。今天無妨（engine 無 camp option）；P2a 後 unified 隊走到 camp tile **卻永不立營**（凍在途）。
**修**：把 camp-arrival block（2263-2275）**hoist 到 unified gate（2237）之前**（player early-return 2235 之後）。camp-arrival 純物理（站上無主可農地→立營），不依賴 `days_left`（在 2256 食物計算前可安全前移），對所有持 `TASK_CAMP` 隊成立。non-unified 行為不變（原本就走到這）。

### W2. player-join forced event（unified NPC 投靠玩家）
舊路徑投靠對象=玩家且同格 → 走 `_maybe_request_join_player`（forced_event 讓玩家決定收留），**非自動 merge**（對稱性 + 玩家 UX）。`_decide_unified` 不經此 → unified NPC 投靠玩家會誤自動併。
**修**：`_decide_unified` dispatch `TASK_JOIN`（opt=="投靠"）前加 guard：target 隊==玩家隊且同格 → `_maybe_request_join_player` 成功則 return（不 try_set 自動 join），對齊舊路徑。

## believability

- **絕境分流個體人格 weigh**（守 ruling #1）：義氣高→投靠、野心/統領高→紮營自立、皆無→乞食墊底。湧現非 scripted。
- **健康隊零影響**：applicable food_days gate → 三 option 只在 desperate 入榜。
- **危時序對齊舊行為**：有家→返家補給（restock 量級支配）；可覓食→覓食；無家無覓食→join/camp/beg 按人格分流（複用舊 pref 公式 = 行為連續）。
- **敗商隊投靠 = 標記1**：無家溫和 unified 商隊深危→投靠強鄰（義氣 weigh），不再餓死=經濟↔衝突橋活。

## 驗收

- **unified 隊三 option 可選 + 人格分歧**：headless 新測——無家深危 unified 隊：義氣高→`投靠`(TASK_JOIN)、野心高→`紮營`(TASK_CAMP)、皆低→`乞食`(TASK_BEG)。
- **健康 unified 隊不選絕境 option**：food_days≥DESPERATION → 三者不 applicable，選貿易/生產/駐守原樣。
- **W1 camp 立營**：unified 隊選 `紮營` → 移動到 farmable → `establish_crude_camp` fire（`[CrudeCamp]`）→ release 轉正常 collect（非凍在途）。
- **W2 投靠玩家**：unified NPC 同格玩家投靠 → forced_event(`join_request`) 非自動 merge。
- **non-unified 零影響**：舊 `_trigger_survival` 路徑全綠（既有絕境/camp/beg/join/飢餓測原樣）。
- **TC1/4/6/7 原樣**（健康隊 gate 擋）。
- **守恆**：join(merge_teams)/camp(立營不耗有限資源)/beg(施捨消耗品) 走既有守恆；coin_eq 0、InvariantAudit 0。
- **world_sim 不崩**：2yr 不全滅、無家深危 unified 隊有 join/camp/beg emergent（非全餓死）、無 over-camp/join（健康隊照貿易生產）。framework S1-S6 PASS。

## 檔案

- `scripts/simulation/decision/terms.gd`：新 const `DESPERATION_DAYS`/`DESPERATION_SCALE`/`BEG_FLOOR_FACTOR`；term `join_drive`/`camp_drive`/`beg_drive` eval + weight `join`/`camp`/`beg`。
- `scripts/simulation/decision/options.gd`：REGISTRY 加三 option、applicable、to_task。
- `scripts/simulation/decision/decision_context.gd`：新欄 + gather 複用 `_find_strong_neighbor`/`_find_unowned_farmable_tile`/`_find_aid_target`。
- `scripts/simulation/faction_ai_system.gd`：W1（camp-arrival hoist 到 unified gate 前）、W2（`_decide_unified` player-join guard）。**不動 `_trigger_survival`/`_evaluate_survival` 其餘**。
- `scripts/debug/headless_test.gd`：新測（三 option 人格分歧 + 健康不選 + camp 立營 + 投靠玩家 forced + non-unified 不變）。

## 風險 + 緩解

- **絕境 option 量級失衡**（碾壓 forage/restock 或被碾壓不 fire）：`DESPERATION_SCALE` 對齊 survival-class 域但不超 restock/forage；headless 驗序（有家→返家、可覓食→覓食、無家無覓→join/camp/beg）。過頻/不 fire 調係數（TEST VALUE）。
- **camp tag 轉換**（unified 商隊紮營→produce/military tag、erase 流亡）：= 既有 `establish_crude_camp` 行為（emergent 角色轉換，敗商隊定居），believable，不視為 bug。
- **applicable food_days gate flapping**（食物跨閾抖）：COMMITMENT_BONUS 既有防抖 + survival task 在 `SURVIVAL_TASKS`（`_decide_unified:848` sticky）→ 選定後續黏。世界量 churn，過抖記 backlog。
- **scope sprawl（P0 教訓）**：明文非目標 + 只碰 decision/ 三檔 + faction_ai 兩 wrinkle（hoist + guard，非 exemption 鏈）+ non-unified 短路零改。**不退役雙 owner、不動 ~20 test 直呼點**（P2b）。

## 開放細節（plan 定）

- `DESPERATION_DAYS`（對齊舊 `WARNING_DAYS`？）/`DESPERATION_SCALE`/`BEG_FLOOR_FACTOR` 初值（TEST VALUE）。
- `_find_*` 從 context 呼叫簽名（`FactionAISystem.new()._find_*` 既有風格 vs 抽 static）。
- W1 hoist 後 camp-arrival 與 2280 recovery-release 對 unified 隊的互動（unified 走 PRIO_DISPATCH，release 由 engine 重排接手；確認無雙重 release）。
