# Hand Back: 代碼健康 批次2（TASK_* enum 單一真值源）

## 實作摘要

純去重，**零行為變更**（所有 task 字串值不變，只把裸字串換成等值常數）。

### Task 1：補齊缺的 TASK_* 常數（`scripts/data/team_data.gd`）

逐一確認候選字串「確實被賦值給 task 欄位」（`current_task` via `TaskArbiter.try_set` 第 3 參 / `SubteamSystem.dispatch` task 參 / 直接 `current_task =`）後，補 7 個常數：

| 常數 | 值 | 確認賦值點 |
|---|---|---|
| `TASK_SETTLE` | `安頓` | `try_set`(faction_ai:412)、`dispatch`(396)、recruit/sub |
| `TASK_PACIFY` | `安撫` | 僅比較 `current_task ==`(interaction:276/278)；目前無 production 賦值點，但語意確為 current_task 值 |
| `TASK_BEG` | `乞食` | `try_set`(faction_ai:2205)、headless harness |
| `TASK_JOIN` | `投靠` | `try_set`(faction_ai:2180)、`current_task =`(recruit_tutorial:16) |
| `TASK_RETURN_HOME` | `return_home` | `try_set`(faction_ai:2146) |
| `TASK_REVOLT` | `起義` | `try_set`(faction_ai:2379) — **確認為 team current_task，非單純 event** |
| `TASK_REST` | `rest` | 比較 `current_task ==`(sim_runner:273 fatigue 恢復、npc_combat:489 夜襲)；與既有 `TASK_CAMP="紮營"` 是**不同字串值**，各自獨立 task |

> Plan 對 `起義`/`rest` 要求先確認語意：兩者皆證實是 `current_task` 值（起義經 try_set 賦值；rest 在 fatigue/夜襲邏輯比較 current_task），故納入。

### Task 2：production 裸 task 字串 → `TeamData.TASK_*`（每檔一行）

- `scripts/simulation/faction_ai_system.gd`：`SURVIVAL_TASKS` const 內字面（乞食/投靠/return_home）全改 const；solo-AI `scores` 鍵 + `match best_task` 臂 + `_tag_weight` 字典鍵（task 參數）+ faction goal 派任務 `try_set`/`dispatch`/`_pick_subteam_leader` task 參 + 各 `current_task ==/!=/in` 比較，全改常數。`f.goals.append("攻擊")`、`_tag_weight` 字典「值」(tag 陣列) 等**非 task 欄位**未動。
- `scripts/simulation/interaction_system.gd`：`_try_interact` 整段 `current_task ==` 分流（徵收/信使/idle/安頓/安撫/外交/乞食/攻擊/掠奪/逃跑）+ herald `order` 預設 `idle` + bluff 判定 `current_task in [攻擊,掠奪]`。`b.tags.has(TAG_PRODUCE)` 維持 tag。
- `scripts/simulation/movement_system.gd`：護衛/逃跑比較 + 居民脫離清單（逃跑/投靠/起義 改 const，`遷徙` 無 const 保留）。
- `scripts/simulation/npc_combat_system.gd`：護衛(×2)/逃跑/rest 比較。
- `scripts/simulation/npc_ai_system.gd`：`_goal_task_delta` 內 `task in [...]` 全部 task 清單改 const（goal `"type"` match 臂如 `"wealth"` 是 goal 型別，保留）。
- `scripts/simulation/reaction_system.gd`：bridge panic `try_set 逃跑`、生產 active 判定 `current_task == 生產`、恐慌排除清單 `[逃跑,護衛]`。
- `scripts/simulation/recruit_tutorial.gd`：tutorial 流民 `current_task = 投靠`。
- `scripts/simulation/sim_runner.gd`：fatigue 恢復 `current_task == rest`。
- `scripts/simulation/subteam_system.gd`：merge_back 守門 `current_task == 安頓`。
- `scripts/data/team_data.gd`：欄位預設 `var current_task := TASK_IDLE`（原 `"idle"`）。

### Task 3：測試檔對齊（`scripts/debug/headless_test.gd`）

71 處 `current_task/order_task/solo_intent/previous_task == / != / =` 直接 task-欄位字面（含 `previous_task`）改 `TeamData.TASK_*`（含跨 struct 如 `t1.current_task == "投靠"`）。`%s` 格式化只讀值處不含字面，未動。`game_sim_test.gd` / `game_sim_multi.gd` 僅 print/display fallback（如 `else "?"`），未動。

## 判為「非 task 欄位」或「無對應常數」**未轉**的字串（清單）

這些刻意保留為字面（plan 未列、或非 task 欄位語意）：

**無對應常數的真 task 值（plan 未要求建常數，保持字面）：**
- `治理`（faction_ai try_set/scores/`match`、headless 斷言）
- `守城`（faction_ai try_set/比較、headless 斷言）
- `遷徙`（movement 居民脫離清單，僅出現於該清單，無賦值點）
- `建造` / `升級` / `擴建`（subteam dispatch task 參 + outpost/movement 比較 + headless）
- `tribute_offer`（`order_task = "tribute_offer"`，faction_ai:280 / headless 斷言）→ 是 order_task 值但無常數

**非 task 欄位的同形字串（語意不同，保留）：**
- `f.goals.append("攻擊")` / `"掠奪"` 等：**faction goal** 字串（非 current_task）
- `_tag_weight(...)` 回傳的 tag 陣列值 `["軍隊"]`/`["生產"]` 等：**tag**
- `t.tags.has("生產")`、`tags = ["子團"/"流亡"/"軍隊"/"商隊"]`：**tag**
- `回歸`（faction_ai 子隊 scores sentinel）：不是 task（命中時僅設 move_target，永不進 try_set）
- `opt["kind"]` 的 `"loot"/"join"/"camp"`：survival 內部 kind 標籤，非 task 值
- `"alliance"`（interaction:220 proposal 預設）：外交提案值，非 task
- `goal "type"`（`"wealth"/"escape_war"/...`）：goal 型別，非 task
- display/print/`"?"`/`"current_task"` dict 鍵字串：序列化/顯示，非 task 比較

## 驗證

- `headless_test.gd` → `=== DONE ===`，無 `SCRIPT ERROR`（Task 1/2/3 各跑過）。
- `game_sim_multi.gd` 4 情境全綠：
  - coin_eq delta：game_sim_test=0.00 / tyrant=0.00 / merchant=-0.00 / warzone=0.00
  - InvariantSummary 違反取樣總計＝0（全 4 情境）
  - 無 SCRIPT ERROR / null instance / Invalid
- 行為等價：所有 task 字串值不變，僅常數替換 → 邏輯路徑完全相同。

## 連動風險

無已知連動風險。純文字替換，無新增/刪除邏輯分支，無資料模型變動。`SURVIVAL_TASKS`/`STUCK_TASKS`/`interruptible` const 陣列現全為 `TeamData.TASK_*` 引用（const 引 const，合法）。

## 待主 session 確認

- **批次3**（ResourceKeys 鍵權威 + `resources.get` helper）：中/低優先，可選。
- **建議後續（可選）**：本批刻意未建常數的真 task 值（`治理`/`守城`/`遷徙`/`建造`/`升級`/`擴建`/`tribute_offer`）仍為散落字面。若要徹底單一真值源，可在批次3 或獨立小批補這批常數並轉引用。本批嚴守 plan 候選清單，未自行擴充。
