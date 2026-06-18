# Leader 繼承單一真值源（修 E-1 繼承分叉）— Design

> 來源：2026-06-19 #3 E-1 深挖（`known_issues.md` E-1「分叉解剖」）。leader 死亡/失效後的繼承邏輯**散在三處、行為不一致** → 玩測觀察到「named 全滅隊變永久 leaderless anon blob」。
> 目標：繼承邏輯**單一 owner**，任何使 `leader_id` 失效的路徑都走它；補所有權圖第一條 invariant。**行為保留**（anon 晉升、player choose_heir 凍世界皆是既有設計，本 spec 只消除分叉，不改玩法、不碰殲滅模型）。

## 問題：三個繼承入口分叉

| 入口 | 觸發 | 行為 | anon fallback | player heir 分支 |
|---|---|---|---|---|
| `EventSystem.on_leader_death`(event:26) | `npc_combat:456` 殺 leader 同步呼 | 掃 named 找最高統領≥0.3，無則 `generate_for_team` 晉升 anon | ✓ | ✗ |
| `FactionAiSystem._promote_successor`(faction_ai:1066)，偵測點:502 | 每 tick `leader_id==-1 且 named 非空` | 只從 named 拔最高統領（無下限）；player→`_handle_player_leader_death`(forced choose_heir / 絕後 game_over) | ✗ | ✓ |
| `encounter_system:1184` | 遭遇戰結算 leader 陣亡 | **只 `leader_id=-1`，不繼承**，靠 faction_ai:502 補 | ✗ | ✗ |

**分叉後果**：
- encounter 殺光 named → `leader_id=-1` 且 `named 空` → faction_ai:502 gate（`named 非空`）擋住 → **不晉升 anon** → 永久 leaderless anon blob。
- 對照 npc_combat 路徑同情境會 `on_leader_death`→anon 晉升 ✓ → **同樣「死 leader」兩路徑結局相反 = 違單一真值源**。
- （結構免疫 = 另一病灶，屬藍圖殲滅模型決策，不在本 spec。）

## 設計：`on_leader_death` 升為繼承單一 owner

### 規則
`EventSystem.on_leader_death(state, team) -> bool` 成**唯一繼承權威**。任何使 `leader_id` 失效的路徑（combat / encounter / 將來饑荒/erase 等）**只呼叫它**，不得自行 promote 或裸置 `leader_id = -1`。

統一後內部分派（吸收現三處全部行為）：
1. **player team**（`team.team_id == player_team_id`）：內聚現 `_handle_player_leader_death` 邏輯——
   - `named 空` → `game_over`（玩家絕後），回 `false`。
   - 否則 → 設 `state.player_forced_event = {action:"choose_heir", ...}` 凍世界等選，回 `true`（succession in progress；leader 待玩家選定，**不視為已有 leader**）。
   - **沿用 forced-event 單一源 spec**（`2026-06-18-forced-event-single-source-design.md`）：choose_heir forced 的 options/label/respond 三聯不動，本 spec 只改「誰設 forced_event」。
2. **NPC team**：掃 team `named_members` 取**統領最高者晉升（不設門檻，best named 即上位）**；無任何 named → `generate_for_team` 從 anon 晉升；anon 也無 → 回 `false`。
   - **刪 `COMMAND_SKILL_MIN`(0.3) 門檻**（原 on_leader_death 有、`_promote_successor` 無 → 門檻本身即分叉源之一）。弱 leader 是合法結局，後果交既有回饋鏈處理（見下）。
   - 晉升後**比照 event:44 呼 `PopulationSystem.check_overflow_for_team`**：弱 leader → `pop_cap_from_leadership` 低 → 溢出 → dispatch advisor 分子隊 / `_create_overflow_team` 流亡隊。三入口都要有此 overflow 呼叫（單一 owner 內統一呼，免 caller 各自記）。

### 回傳契約（釘死）
- `true` = 已處理（含「player 待選 heir」的 pending 態）→ caller **不得**解散團/faction。
- `false` = 無繼承人（NPC anon 耗盡 / player 絕後）→ caller 走滅團/faction 解散（npc_combat:457-460 既有；encounter 比照）。

### roster 掃描修正（順手單一源）
現 `on_leader_death:29-36` 掃 **`state.persons` by team_id**（脆：encounter 死者未 erase persons → 殭屍會被選為繼承人）。改掃 **`team.named_members`**（live roster，= `_promote_successor` 既有做法）。encounter 死者已從 named_members erase(:1183) → 不會被選。單一 roster 來源。

### 三入口改動（只動 2 檔，encounter 不碰）
- **npc_combat:456**：已呼 `on_leader_death` ✓，**不動**（戰中即時繼承；自動獲得 player 分支保險，雖現流程 player 不走 npc_combat）。
- **encounter_system:1184**：**不動**，維持 `t.leader_id = -1`（裸置）。理由：encounter 死者 persons 未 erase + 戰中呼 forced-event 時序風險高；改由 faction_ai 安全網次 tick 捕捉（= 現行 player 繼承路徑，零行為變動、低風險）。
- **faction_ai:502 偵測點**：升為**唯一通用安全網**——`if team.leader_id == -1`（**拿掉 `named 非空` gate**）→ 呼 `on_leader_death`（捕捉任何 leaderless：戰後/饑荒/裸置，自動帶 anon fallback + player 分支）。**刪 `_promote_successor` + `_handle_player_leader_death`**（邏輯內聚進 on_leader_death）。faction_ai 主迴圈(:493)每 tick 掃所有 team → 安全網可靠、無漏。

### owner 落點
繼承**邏輯**單一 owner = `EventSystem.on_leader_death`（既有，已含 anon fallback）；**偵測**單一點 = faction_ai:502 安全網（+ npc_combat 戰中即時呼，為效能捷徑，非另一 owner）。把 player 分支內聚進 on_leader_death（`_handle_player_leader_death` 僅 15 行、只依賴 `state`，無 faction_ai 真依賴 → 安全內聚，不新增 SuccessionSystem，YAGNI）。
`_get_player_team_id` 現重複 2 份（faction_ai:1038 + player_command:1085）→ event_system 需第 3 處用。**抽到 `WorldState.get_player_team_id()` 單一源**，on_leader_death 用它；既有 2 份改 delegate（順手收，同屬繼承 seam）。

## 連動 / 風險

- **encounter player 繼承時序（不變）**：encounter 結算只 null leader_id；次 faction_ai tick :502 安全網 → on_leader_death → player 分支 → choose_heir forced（= 現行路徑，零變動）。1-tick leaderless 窗與現行相同，各系統已容忍 null leader。`sim_runner:99` choose_heir 排除超時清除不動。
- **既有 latent 修**：原 faction_ai:502 gate `named 非空` → player leader 死且 named 空時**不觸發** → 玩家隊永久 leaderless husk（game_over 未設）。拿掉 gate 後 → on_leader_death player 分支 named 空 → `game_over`。順手修此 latent。
- **faction_ai 安全網每 tick 重呼**：player team 持續 leaderless（等選 heir）時，:502 會每 tick 再呼 on_leader_death → 須**冪等**：already-pending forced_event（同 team 的 choose_heir 未決）時不重設。on_leader_death player 分支加 guard：`state.player_forced_event` 已是本 team choose_heir → 直接 return true 不重設。
- **`generate_for_team` 副作用**：晉升 anon 會從 cohort 移除 1（`invariants.md` anon 單一源規則），既有行為，不變。
- **回傳 false 對 player team**：game_over 已設；caller(npc_combat:457) 接著試 faction 解散 → 對 player team 無害（player 通常無 faction leader_team 角色衝突），但 spec 釘：caller 在 game_over 已設時跳過 faction 解散，避免多餘訊息。
- **門檻取捨（用戶 2026-06-19 裁）**：採「無門檻、best named 硬上位」（= `_promote_successor` 既有規則），**刪** on_leader_death 的 0.3 門檻。理由：弱領導後果已有回饋鏈——`pop_cap_from_leadership`(population_system:35/39) 低統領→低 pop cap→`check_overflow_for_team` 分團/流亡；外加 `event_unrest_replace`（統領弱+unrest 高→換強 named）。門檻反而短路此設計。**驗測**：低統領 named 繼任 → 該隊後續觸發 overflow 分團/流亡（證回饋鏈活）。
- **anon-晉升 leader 的 overflow**：`generate_for_team` 生的 leader 統領也可能低 → 同樣 overflow，行為一致，非 bug。

## 測試標準

- headless 新增：
  - `_test_succession_encounter_named_wipe`：encounter 打到某 NPC 隊 named 全滅但 anon>0 → 戰後該隊**有新 leader（anon 晉升）**，非 leaderless blob（直接複現 E-1 繼承病灶 → 證修）。
  - `_test_succession_single_owner`：encounter/npc_combat/faction-detection 三路徑殺 leader → 同初始條件**結局一致**（都晉升或都滅團）。
  - `_test_succession_player_encounter`：玩家隊 encounter 中 leader 死 → `player_forced_event.action=="choose_heir"`、candidates 正確、未重複設（冪等）。
  - `_test_succession_anon_exhausted`：NPC 隊 named 空 + anon 空 → on_leader_death 回 false → 滅團/faction 解散。
  - `_test_succession_weak_leader_overflow`：低統領 named 繼任 → 晉升後 `check_overflow_for_team` 觸發溢出（pop>cap）→ 分子隊/流亡隊生成（證「硬當沒差，跑回饋鏈」）。
- 回歸：既有 `on_leader_death`/choose_heir forced 測試全綠；`=== DONE ===`、coin_eq=0、全 invariant 0、1000 Tick 無崩潰。

## invariants.md 新增（所有權圖第一條）

> **Leader 繼承邏輯單一 owner = `EventSystem.on_leader_death(state, team)->bool`。** 偵測單一點 = `faction_ai` 每-tick 安全網（`leader_id==-1`→呼 owner）；npc_combat 戰中即時呼為捷徑。**禁止在 on_leader_death 外自行決定繼承人 / promote**（裸置 `leader_id=-1` 僅允許作為 transient，須由安全網次 tick 補位）。分派：player→forced `choose_heir`（named 空則 game_over）/ NPC→best named 無門檻晉升→無 named 則 anon 晉升→皆無回 false 滅團。晉升後呼 `check_overflow_for_team`（弱 leader→溢出回饋）。回傳 true=已處理（含 pending）、false=無繼承人。

## 範圍

本 spec = leader 繼承三入口單一源化 + 安全網冪等 + 1 條 invariant。**不含**：結構免疫/殲滅模型(藍圖 WHAT 待裁，handback `systems-to-blueprint-annihilation-model`)、E-2 撤退門檻、E-3 玩家逃離 wire、anon 2c-2。完整 E-1 收斂 spec 待藍圖回殲滅模型後與本 spec 合成。
