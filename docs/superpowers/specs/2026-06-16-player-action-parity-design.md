# 玩家動作 Parity + 主隊 Task 控制權收口 — Design

> 來源：2026-06-16 QA P5 抓 C-1~C-6 對稱缺口 → brainstorm 走查重frame。
> 取代 known_issues P5 的 C-1~C-6 原框架（「玩家自隊 task 控制」）。

## 問題重frame

QA C-1~C-6 原框架把 **NPC task（AI 抽象）** 和 **玩家能力（直接動作）** 混為一談。走查結論：

- **NPC 的 task = AI 自動駕駛抽象**：NPC leader 無人微操，AI 設持續 `current_task` 驅動多 tick 自動行為（覓食→走去食物格→採集）。
- **玩家 = 直接控制**，每 tick 親自下令。玩家**不需要、也不想要**持續 auto-task（設了放著自己跑 = 違反直接控）。
- 真正的對稱 **不是 task 對 task，是「能力結果」對「能力結果」**：NPC 用 TASK_X 達成的事，玩家應有**一次性動作**達成同事，而非設 task。

### NPC→玩家 行為 parity（系統對照結論）

| NPC | 玩家 | 判定 |
|---|---|---|
| 攻擊/掠奪/徵收/外交/貿易/建設/製造/乞食/起義/守城/迎戰/偵查/合併/治理/安頓(子隊) | attack/take_loot/demand_tribute/propose_alliance/trade/build_*/upgrade_*/beg/leave_faction/accept_encounter/gather_intel/subjugate/faction cmd/dispatch_subteam | ✅ 已有 |
| 生產 | outpost 自動採集 | ✅ 被動 |
| 逃跑 | 直接移動（玩家直接控，**不需 action**）| ✅ by design |
| **訓練**（anon 升 tier）| **無** | 🔴 真缺口（高）→ 本批做 |
| **紮營**（crude camp，免材料瞬間落腳）| build_outpost 需材料+施工 ≠ | 🔴 真缺口（中，生存期落腳）→ 本批做 |
| 覓食 forage | hunt/hunt_beast 重疊 | 🟡 冗餘 → 擱置 |
| 主動投靠他隊 | 被動 join_request(A-1) 有，主動無 | 🟡 邊緣 → 擱置 |

## 本批 Scope（4 項）

1. **訓練/晉升動作**（C-4，新 player command）
2. **紮營動作**（C-2，新 player command，「Y 版」加限制）
3. **Panic 收口**（玩家主隊不被恐慌橋劫持 task）
4. **顯示 label**（玩家隊「任務:」→「狀態:」）

**明確不做（擱置 roadmap）**：覓食（冗餘 hunt）、pacify、settle（階段3 過早）、主動投靠、C-1 設自隊 task（玩家不要 auto-task）。

---

## 設計

### 1. 訓練/晉升動作（C-4）

**動機**：玩家 anon 現在永遠 tier0（平民），唯一升階路是打贏遭遇戰被動 add_exp。NPC 經 TASK_TRAIN 自動 `add_exp + try_promote` 升階（平民→新兵→老兵→菁英），玩家無對應入口。

**做法 — 一次性 command，不設 task=訓練**：
- 新 `_action_train`（registry `"train"`）。
- 玩家按 → **花 coin** → 對自隊 anon **直接呼既有** `AnonTierSystem.add_exp(...)` + `try_promote(...)` 一次（一批 exp，可能升一階）。
- **不**走 training_system 的每-tick task 機制（那是 NPC 持續 task；玩家要一次性）。
- 前提：自隊有 anon（`AnonTierSystem.total_pop > named`）、coin 足。

**常數（TEST VALUE，待平衡）**：
- `TRAIN_COST_COIN`：一次訓練**固定**成本（起手 30 coin，標 TEST VALUE）。**固定一筆，不 per-anon scaling**（起手簡單，平衡時再議）。
- `TRAIN_EXP_GAIN`：一次給的 exp（推進「約 1/3 階」量，沿用 AnonTierSystem 既有 exp 尺度，標 TEST VALUE）。
- exp 施加對象：自隊 anon pool 經既有 `AnonTierSystem.add_exp` + `try_promote`（沿用其內部分配/升階規則，勿自訂）。

**守恆（決斷）**：訓練 coin = **消耗 sink**（食宿/教官開銷，coin 離開經濟）。**必須在 coin_eq 審計把訓練 sink 標為合法消耗**（同 onboarding 食物模式），否則破壞 coin 守恆審計。實作對齊既有合法 coin sink 慣例（查 coin_eq 審計如何排除合法 sink）。

**UI（定錨）**：self-action，置於互動模式**目標選擇階段**與 hunt 並列（同 P4-2 self-action 分類，不需先選隊）。顯示「訓練（-%d coin → anon +exp）」+ 結果 feedback（升階則報「平民→新兵」之類）。

### 2. 紮營動作（C-2，Y 版）

**動機**：游牧生存玩家**有糧無材料**時 build_outpost（需 OUTPOST_COST material + 施工）建不了 → 無法從零落腳。crude camp 免材料填這洞。

**做法 — 一次性 command，加限制（Y 版，去剝削）**：
- 新 `_action_camp`（registry `"camp"`）。
- 沿用 `establish_crude_camp` 的 tile 硬限制：腳下 tile **無主**（outpost_owner=-1）、**未開發**（outpost_level=0）、**非山地**。
- **加 build_outpost 的距離 spacing**（`OutpostSystem._check_distance`：離既有據點太近不准，防群聚 spam）。
- **加施工時間**（construction ticks，比 build_outpost 短 → 走既有 `construction_ticks_left` 機制；紮營中脆弱，不能瞬間 spam）。
- **免材料成本**（與 build_outpost 的分水嶺，維持生存 niche）。
- **無即時糧**（去剝削關鍵）：**只抬 food cap**（`tile.resource_cap["food"]` 技術必要，否則 regen 池卡地形預設≈0，據點無用），**不塞即時 `tile.resources["food"]=40`**。→ 糧靠之後 regen 慢慢長，不送免費飯。
- **type 玩家選**（civilian/military），非 NPC 的個性自動判。
- 完成後：tile lvl1 outpost owner=玩家隊、team tag 升 軍/生產、清「流亡」（沿用 establish_crude_camp 後段）。

**常數（TEST VALUE）**：
- `CAMP_BUILD_TICKS`：紮營施工時間（建議 build_outpost lvl1 ticks 的一半，標 TEST VALUE）。
- food cap 抬到的值沿用 `CRUDE_CAMP_FOOD_SEED=40` 當 **cap** 目標（非即時糧）。

**反 spam 來源**（取代 NPC 的「AI 絕境 gating」這層玩家沒有的約束）：距離 spacing + 施工時間 + tile claim（同格不能重紮）+ 無即時糧誘因。**不加**每隊/全圖數量上限或 cooldown（YAGNI，上述已足）。

**UI**：self-action，需玩家先選 type（civilian/military）。腳下不合格（有主/山地/太近）→ 灰掉或 feedback 原因。

### 3. Panic 收口（玩家主隊不被恐慌劫持）

**現況（量測+讀碼）**：reaction 恐慌橋（`reaction_system.gd:45-55`）在隊內 ≥30% flee 時 `TaskArbiter.try_set(team, "逃跑", flee_target, PRIO_THREAT)` → **同時寫 current_task=逃跑 + move_target**。對玩家隊**不跳過**。`PRIO_THREAT(70) > PRIO_PLAYER(60)` → 結構上會蓋玩家移動令。實機觀察：玩家看到「逃跑」task 但**未見實際移動劫持**（movement 另有屏障，未深究——避免鑽牛角尖，以實機觀察為準）。

**做法 — 精準守衛，只擋 task 劫持，保留所有恐慌負面效果**：
- `reaction_system.gd` 恐慌橋那行 `try_set("逃跑")` 前加 `if team.leader_id != state.player_id`（仿 faction_ai:141 / SoloAI:907 既有玩家跳過模式）→ **玩家主隊不被自動設逃跑 task / 不被奪 move_target**。
- **其餘恐慌效果全不動，玩家隊照吃**：
  - work_morale 生產減益（`resource_system:194 gain *= work_morale`）✅ 留
  - 個人掉忠誠/壓力/叛逃（N1_flee/N3_defect/N2_riot，reaction 每-person loop 不跳玩家隊）✅ 留
  - 戰場單位潰逃（`encounter_system:44-46` 獨立系統）✅ 留

**結果**：玩家隊恐慌 → 產出掉、手下掉忠誠/叛逃、打仗單位潰 → **該痛照痛**，只是移動權留給玩家（系統不強拖著跑）。

### 4. 顯示 label（玩家隊 task 語意）

**現況**：`text_ui_main.gd:654` 玩家狀態列「任務: %s」← DTO task_summary ← current_task。玩家隊 current_task 對玩家無意義（收口後僅剩系統自動狀態如恐慌殘留 / idle），「任務」label 誤導成像玩家令。

**做法**：玩家隊狀態列「任務:」→「**狀態:**」（誠實標示=自動狀態，非玩家令）。
- 收口後玩家隊多為 idle；若有殘留自動狀態（如某 tick 的反應）顯示為狀態無妨。
- 不顯也是選項，但保留「狀態」當 legibility（玩家知道隊在恐慌/正常）較好。

---

## 不做 / 後續（roadmap）

- **覓食 forage**：冗餘 hunt/hunt_beast，YAGNI。
- **pacify / settle（主動定居）/ 主動投靠**：niche / 階段3 過早 / 邊緣。
- **C-1 設自隊持續 task**：玩家不要 auto-task，砍。
- **NPC crude_camp 即時糧軟化絕境（獨立平衡 task）**：NPC 紮營送 40 即時糧（≈小隊 2 天糧），受「AI 絕境才紮 + tile claim + 無主非山地格」自我約束，但邏輯上仍軟化絕境。**先量測**（NPC 是否靠紮營免死、移除即時糧對 2yr×4config died/pop 影響）再決定是否同步去即時糧。**本批不動 NPC 版**（避免改動已調平衡世界，需重 sim）。

## 連動 / 風險

- **訓練 coin sink 守恆**：訓練消耗 coin 必須在 coin_eq 審計標為合法 sink，否則破壞守恆審計（同 onboarding 食物模式）。實作對齊既有合法 sink。
- **紮營走既有 construction 機制**：複用 `construction_ticks_left` / `_check_distance` / establish_crude_camp 後段 tag 邏輯，勿複製。Y 版差異 = 免材料 + 無即時糧 + cap-only。
- **panic 守衛**：只加一行 `leader_id != player_id`，不動 reaction 其餘路徑（NPC 恐慌不變，sanity 應無影響）。
- **既有測試**：訓練/紮營加 headless（守恆 + 升階 + tile 狀態）+ ui_flow（可達 + 端到端）；panic 守衛加 headless（玩家隊恐慌不被設逃跑 task，但 work_morale/loyalty 仍受影響）。

## 測試標準

- headless：`=== DONE ===`，無 SCRIPT ERROR，新測全綠。
- coin_eq 守恆：訓練 coin sink 標記後 delta=0（合法 sink 不算破口）。
- ui_flow：訓練/紮營 self-action 可達 + 端到端（exp 增/tile 變 outpost）。
- sanity multi（survival_start）：died=no、coin_eq delta=0、panic 守衛不破壞 NPC 行為。
