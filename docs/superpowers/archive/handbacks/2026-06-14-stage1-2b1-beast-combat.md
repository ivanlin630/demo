# Hand Back: 階段1 Plan 2b-1 野獸戰鬥核心

branch：`feat/beast-combat`（從 main d5323cc 分出）

## 實作摘要

reuse 既有人類戰鬥機制，野獸 = 臨時 pseudo-team（負 id，`TAG_BEAST`，無 leader/faction/coin）。未另寫戰鬥引擎。

- `scripts/data/item_attributes.gd`：ITEM_REGISTRY 加 `beast_claw_light`(dmg12)/`beast_claw_heavy`(dmg22)，weapon 類 range=1、weight 0、parry 0。
- `scripts/data/team_data.gd`：`TAG_BEAST := "野獸"` const；`beast_kind`/`beast_strength` 兩欄位。
- `scripts/simulation/world_generator.gd`：predator 生成率 const（森林 12% / 山 15%、上限 2）；`_apply_resources` 森林/山灑 `predator_density`，計入 `resource_cap`（在 wild_game 區塊後，比照 2a 做法）。
- `scripts/simulation/harvest_system.gd`：`_regen_predator`（月邊界、10% +1、cap 用 resource_cap、僅 forest/mountain），`tick_all` 接入。
- `scripts/simulation/beast_system.gd`（新）：`BEAST_PROFILE`（deer/boar/bear/wolves → count/hp_mult/combat/claw/behavior/meat/hide/strength）；`build_beast_team`（造 pseudo-team 入 state.teams + team_known/discovered）；`reward_and_cleanup`（勝方得肉→food+forage_today、皮→material，清除獸隊）；`_cleanup`。
- `scripts/simulation/encounter_system.gd`：`_spawn_team_units` beast 分流 → `_spawn_beast_units`（claw 裝 hand_1 `type:"innate"`、戰鬥 skill、body_parts HP × hp_mult、`is_beast`/`beast_behavior`）；`_decide_action` beast 分支（flee→retreat、fight/predator→撲最近敵）；`resolve_encounter_end` beast 結算（不走人類 loot/subjugate/outpost，勝方獵獸得肉、獸隊清除，涵蓋 win/lose/draw）。
- `scripts/simulation/npc_combat_system.gd`：`team_strength` 對 beast 回 `beast_strength`；`_end_combat` + `_force_retreat` beast 守衛（不走 loot/subjugate/capture/pursuit，勝獵得肉、其餘僅清除）。
- `scripts/simulation/player_command_system.gd`：registry 加 `hunt_beast` → `_action_hunt_beast`（腳下 predator_density>0 → 枯竭 1、造獸隊、`_encounter.init_encounter` 起遭遇戰；山→bear 其餘→boar）。比照既有 `_action_attack` 用 `_encounter` 成員實例，非新建。
- `scripts/debug/headless_test.gd`：6 新測試 + 註冊。

### 與 spec/plan 的差異
- **Task 4d（`_get_weapon_grade` innate 分支）無需改動**：既有 `_get_weapon_grade` 對 `type` 不在 `["none","2h_ref",""]` 者一律回 `grade`，故 `type:"innate"` 直接取得爪牙傷害。
- **獵勝隊不獲戰鬥存活 exp**：beast 結算插在 resolve_encounter_end 的傷亡/sync 之後、exp/loot 之前並 early-return，故獵獸不觸發 anon tier exp。守恆與 sync_back（武器歸還）不受影響。可於 2b-2 視需要補。
- BEAST_PROFILE 全數值 + predator 生成/再生率 = TEST VALUE，待 2b-2 接入伏擊後一起量測 tune。

## 驗收
- headless：6 新測試全過（`beast claw OK` / `predator seeded OK` / `build beast OK` / `beast encounter OK (attacker_win, food=40)` / `NPC hunt beast OK` / `player hunt_beast OK`）。
- multi 2 年（survival_start,tyrant,warzone）：三 config `died=no`、`coin_eq delta=0.00`、**multi 內 SCRIPT ERROR=0**、無 beast 殘留（multi 不自然生成獸隊，符合預期）。
- baseline 既有 `_test_on_team_extinct_to_storage`「food 應進公庫」SCRIPT ERROR 於 main 同樣出現，**非本 plan 新增**（plan 已標 Bug8 baseline 可接受）。

## 連動風險
- **EncounterSystem 在 `player_id == -1` 時把 anon 當玩家**：anon/beast 單位 `person_id=-1`，`advance_encounter_tick` 以 `person_id == state.player_id` 判定玩家；若無玩家（player_id 預設 -1）則 anon 全被當玩家 → 回 `player_turn` 停手。屬**既有潛在問題**，正式遊戲 player_id 必為 >=0 的真人 id 故不觸發；NPC vs NPC 走 npc_combat 不走 encounter 故 multi 亦不觸發。本次測試以 `state.player_id = -999` 迴避。建議主 session 評估是否在 `advance_encounter_tick` 玩家判定加 `state.player_id != -1` 守衛（防未來無玩家跑 EncounterSystem）。
- **beast 隊負 id 遍歷**：beast id 從 -1000000 遞減、無 faction、戰畢即清。multi 2 年未見負 id team 累積或誤處理。若 2b-2 接入 NPC 主動獵獸需再驗 faction_ai/vision 各遍歷對 beast 隊免疫。
- **NPC 獵獸 `_apply_casualties`**：beast 無 named → 一律 `wounded+=1`；`on_anon_casualties` 因 beast resources={} 提前 return（pool_total 0）安全。獸 population 抽象傷亡，不個別建模。

## 待主 session 確認
- 設計：獵勝不給 exp（見上）是否可接受，或 2b-2 補。
- 建議後續（2b-2）：伏擊偵測 + infamy + NPC 主動獵獸（本 plan 未做）；predator/BEAST_PROFILE 數值量測 tune；上述 `player_id == -1` 守衛是否補。
