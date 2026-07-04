# Hand Back: Faction 雙向單一入口（faction_id ↔ member_team_ids）

實作 plan `docs/superpowers/plans/2026-06-17-faction-bidir-single-entry.md`，master invariant spec 規則 3 之 faction 雙向部分。

## 實作摘要

| 檔案 | 改動 |
|---|---|
| `scripts/data/world_state.gd` | 加 `set_team_faction(team, fid)` / `clear_team_faction(team)` 雙向單一入口（換 faction 自動退舊入新、idempotent early-return） |
| `scripts/debug/headless_test.gd` | 加 `_test_set_team_faction`（入/換/清/idempotent 四案）+ 註冊 |
| `scripts/simulation/subteam_system.gd` | **主 bug**：子隊 faction 繼承由 `sub.faction_id = parent.faction_id`（單側）改為 `state.teams[...]=sub` 後 `state.set_team_faction(sub, parent.faction_id)` |
| `scripts/simulation/npc_combat_system.gd` | subjugate 敗方入勝方 faction 走入口（刪 member append + 單側賦值） |
| `scripts/simulation/interaction_system.gd` | join faction（外交招募 :380、安頓 `_execute_settlement`）走入口 |
| `scripts/simulation/events/event_faction_defect.gd` | defect 離團走 `clear_team_faction`（解散判斷在 clear 後讀，保留） |
| `scripts/simulation/diplomatic_ai_system.gd` | 結盟入 faction（a/b 兩段）走入口；背叛離團走 `clear_team_faction` |
| `scripts/simulation/faction_ai_system.gd` | 起義守城/流亡、defection 投降強鄰/獨立 4 點走入口 |
| `scripts/simulation/player_command_system.gd` | 玩家 leave/betray faction 走 `clear_team_faction` |
| `scripts/simulation/game_setup.gd` | setup 入 faction 3 點走入口；`_build_explicit_team` faction_id 初始改 -1（見下「設計決策」） |
| `scripts/simulation/encounter_system.gd` | **殘留修**：`_massacre_residents` 滅團前 `clear_team_faction` + 清 `known_member_states`（消 faction 懸空） |

## 驗證

`headless_test.gd` → `=== DONE ===`、`[OK] _test_set_team_faction`、無 `SCRIPT ERROR`。

`game_sim_multi.gd`（4 config）：

| 指標 | baseline | 修後 |
|---|---|---|
| `faction 反向破` | ~1431 取樣（plan 紀錄） | **0** |
| `faction 雙向破` | >0 | **0** |
| `faction 懸空` | >0（warzone） | **0** |
| `coin_eq delta` | 0 | **0**（4 config 維持） |
| population drift | 0 | 0 維持（無 SCRIPT ERROR） |

`game_sim_test` / `tyrant` / `merchant` 違反取樣總計=0。`warzone` 殘留 16 = **全為 subteam 不變量**（見下連動風險），非 faction。

## 設計決策（plan 未完全覆蓋）

1. **`game_setup._build_explicit_team` faction_id 初始改 -1**：原本 `team.faction_id = config` 在 factions 建立前先設。入口有 idempotent early-return（`team.faction_id == fid` 時直接 return），若此處先設 faction_id，第三段 `set_team_faction` 會早退 → member_team_ids 漏 append。故改為純 -1 初始，由 `create_faction`（leader）/ 第三段 `set_team_faction`（非 leader）作唯一設定者。

## 連動風險

- **subteam 雙向不變量未修（建議後續 plan）**：`encounter_system._massacre_residents` 直接 `state.teams.erase(rid)`，雖已補 faction 清理，但**未清 parent 的 `subteam_ids` / 子隊 `parent_team_id`**。warzone 殘留 16 全為此根：`subteam 雙向破`、`subteam 懸空 TeamN.subteam_ids 含已不存在`。此屬 subteam 單一入口問題（同哲學另一條 bidir），不在本 faction plan 範圍。建議開 `subteam-bidir-single-entry` plan，或令滅團路徑統一走 `_on_team_extinct`（已含 faction 清理 + 延後 erase）取代各處 direct erase。
- **滅團路徑不統一**：目前 team erase 散在 `_on_team_extinct`(正規)、`_massacre_residents`、`encounter:1415`、`subteam._erase_absorbed_team`、`beast`。`_erase_absorbed_team` 已清 faction；beast 無 faction；`_massacre_residents` 本次補齊 faction。長期建議全收斂 `_on_team_extinct`。
- **brand-new team init `= -1` 未動**（beast:28 / population:59 / reaction:323 / event_unrest_split:67 / game_setup:444）：非轉移，留原樣。

## 與 spec

實作 master invariant spec（`2026-06-17-invariant-architecture-design.md`）規則 3 faction 雙向部分。audit 網 `_check_faction_bidir` 已存、簽名不變，現 4/4 config faction 不變量綠。所有遷移點刪手動 member 維護後，雙向唯一維護者 = `set_team_faction` / `clear_team_faction`。

## 待主 session 確認

- subteam 雙向不變量殘留是否開後續 plan（建議：是）。
- 滅團路徑是否統一收斂 `_on_team_extinct`（架構債）。
