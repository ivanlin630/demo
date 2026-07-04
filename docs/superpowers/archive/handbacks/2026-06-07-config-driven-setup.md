# Hand Back: Config-Driven Setup

## 實作摘要

- `GameSetup.setup` 加 `mode` 分支：`random`（原行為，`_setup_random_player`）/ `explicit`（新）
- 新增 `_setup_explicit_teams`、`_build_explicit_team`、`_make_person`、`_setup_player`（explicit 版）、`run_command_schedule_tick`、`_dispatch_command`
- 新 config：`config/demo.json`（3 team）、`config/game_sim_test.json`（5 team + 6 個 command schedule）
- `config/default.json` 加 `"mode": "random"`（顯式標示）
- `main.gd` setup 40 行 → 3 行（load + setup + PlayerSystem）
- `game_sim_test.gd` 移除 `_setup_outposts`、`_setup_teams`、`_make_resources`、`_inject_player_commands`；改讀 config + `run_command_schedule_tick`

## 測試結果

- `headless_test.gd`：Config Task1 OK、Config Task6 OK（全部舊測試亦通過）
- `game_sim_test.gd`：ALL INVARIANTS PASSED (violations=0)、Feature 通過 8/10

## 連動風險

- `_dispatch_command` 只覆蓋 6 個 action（set_move_target、propose_alliance、attack、submit_trade_offer、recruit_named、build_outpost）；新 action 需手動加 case
- `_make_person` 用 `team_id * 1000 + seq` 配 id；大規模 team 或 seq > 999 時可能撞號
- `_member_counters` 是 static var，跨多次 `GameSetup.setup` 呼叫不會清零；測試中需注意
- `game_sim_test.json` 內的 outpost 位置固定：若地圖半徑 < 4 會找不到 tile（map radius=4 剛好涵蓋）
- Feature Fail：Trade（0/1）、Message（0種）與 explicit setup 後 NPC AI 決策路徑有關，非 config 機制本身問題

## 待主 session 確認

- `_dispatch_command` 是否該移到 `player_command_system` 作為通用 router
- `_member_counters` static 狀態是否需要在每次 `setup` 前清零
- 多 config 場景的 regression 測試是否要建 CI script
