# Hand Back: 階段1 Plan 2b-2 野獸伏擊 + 偵測

branch: `feat/ambush`

## 實作摘要

- `scripts/simulation/ambush_system.gd`（新）：`AmbushSystem`
  - `detect()` — 隊 偵查(+求生×0.5) vs 掠食者 exposure×地形隱蔽，確定性門檻 `>0.4`。
  - `check_ambush()` — 編排：野獸隊/戰鬥中/已 encounter skip；predator 格才 roll；偵測到→`_on_detected`（長技能 + 玩家預警），未偵測 + `randf()<AMBUSH_BASE_CHANCE`→`_trigger_ambush`。
  - `_trigger_ambush()` — 生 beast，玩家走 `EncounterSystem.init_encounter`，NPC 走 `NpcCombatSystem.start_combat`（Bug9 分流）。predator_density -1。
  - `record_infamy()` — tile `predator_infamy` +1。
- `scripts/data/tile_data.gd`（改）：加 `var predator_infamy: int = 0`。
- `scripts/simulation/sim_runner.gd`（改）：`_ambush_system` 成員 + init；`_step_ambush_check`；near cadence（faction_snapshot 後）接入並在 `encounter_active` 時 `return "player_turn"` 交還 bridge；far cadence 接入（不阻塞）。
- `scripts/simulation/beast_system.gd`（改）：`reward_and_cleanup` 勝方 leader/named 長 `戰鬥` exp +0.003（TEST VALUE）。
- `scripts/simulation/encounter_system.gd`（改）：野獸結算「獸贏」分支記 `record_infamy(winner.tile_pos)`。
- `scripts/simulation/npc_combat_system.gd`（改）：`_end_combat` 獸贏分支記 `record_infamy(winner.tile_pos)`。
- `scripts/simulation/faction_ai_system.gd`（改）：`try_hunt_predator()`（人多≥8 + 戰鬥≥0.3 + predator 格 → npc_combat 起獵）；接入 `_trigger_survival` Path 3.4（forage 之前）。
- `scripts/debug/headless_test.gd`（改）：7 新測試 + 註冊。

與 spec 無差異。偵測採確定性（plan 指定）。

## 驗證

- headless：7 新測試全 OK（`ambush detect/player/npc/detected-no-fight OK`、`beast reward exp OK`、`predator infamy OK`、`npc active hunt OK`），`=== DONE ===`。SCRIPT ERROR 計數 = 1，與 baseline 相同（Bug8「food 應進公庫」，非本 plan 引入）。
- 2-season multi（survival_start, tyrant, warzone）：三 config `died=no`、`coin_eq delta=0.00`、0 SCRIPT ERROR、全 21600 ticks。`[Ambush]`×5（NPC + 玩家各有）、`[BeastHunt]`×4 出現。**Bug9 未觸發**：NPC 被伏擊走 npc_combat、玩家 Team0 被伏擊起 encounter 後 sim 仍跑完整 ticks，無 `encounter_active` 卡死、無負 id beast 殘留。

## 連動風險

- `sim_runner` near cadence 新增 `return "player_turn"`：伏擊起玩家 encounter 時中途返回，跳過該 tick 剩餘 near/far/cleanup 步驟（同既有 encounter_active 開頭分支語意）。multi 已驗無回歸，但**真實玩家 UI bridge 對「伏擊起 encounter」的 `player_turn` 回傳處理需主 session 確認**（與既有玩家遭遇戰是否走同一進場路徑）。
- `faction_ai_system` Path 3.4 插在 return_home/loot 之後、forage 之前：飢餓且 pop≥8 戰隊在 predator 格會優先獵獸而非覓食/乞食。可能影響 NPC 生存決策分布；TEST VALUE 門檻待量測。
- `EncounterSystem.new()` / `NpcCombatSystem.new()` 在 ambush_system 內各自 new 實例（encounter 狀態存 state，安全）；與 sim_runner 持有的 `_encounter_system` 實例不同物件，但無實例成員狀態依賴。

## 待主 session 確認

- **TEST VALUE 一起量測 tune**：`AMBUSH_BASE_CHANCE=0.15`、detect 門檻 `0.4`、`PREDATOR_EXPOSURE_BASE=0.3`、獵勝 exp `0.003`、NPC 獵獸門檻（pop≥8 / 戰鬥≥0.3）。重點觀測：玩家被伏擊頻率是否惱人、NPC 是否大量送死獵獸。連同 2b-1 BEAST_PROFILE 一起調。
- **玩家伏擊 encounter 的 bridge 進場**：確認 `return "player_turn"` 與既有玩家遭遇戰 UI 流程一致（本 plan 僅 headless + multi 驗，未走真實 UI）。
- 持久惡獸實體 / bounty 任務屬任務系統 spec，本 plan 只做 `predator_infamy` 計數 hook，無惡獸遊蕩。
- baseline Bug8（`food 應進公庫` 斷言）非本 plan 範圍，沿用既有 known issue。
