# Hand Back: UnrestBank 單一 owner（Pattern B 第一池）

## 實作摘要

新增 `UnrestBank` static banker，`unrest_turns` 全 production 寫者路由進 bank，禁裸絕對 set。純路由（行為不變，同 delta/reset 數學）。

### UnrestBank API（`scripts/simulation/unrest_bank.gd`，新檔）
- `UnrestBank.add(team: TeamData, n: int, reason := "")` → `team.unrest_turns = maxi(unrest_turns + n, 0)`（對齊原 `+= n`）
- `UnrestBank.reduce(team: TeamData, n: int, reason := "")` → `team.unrest_turns = maxi(unrest_turns - n, 0)`（對齊原 `maxi(cur - n, 0)`）
- `UnrestBank.reset(team: TeamData, reason := "")` → `team.unrest_turns = 0` + `Probe.bump("g1.unrest_reset")`（唯一蓄意歸零路徑，split-resolution 類）
- `reason` 字串供未來審計（誰改民怨），目前僅參數，無 side-effect。

### 改檔（每檔一行）
- `scripts/simulation/unrest_bank.gd`：新 banker（唯一允許裸 `unrest_turns =` 之處）。
- `scripts/debug/headless_test.gd`：加 `_test_unrest_bank()`（add/reduce/clamp/reset 斷言），註冊進 `_run_sim_test`（接於 `_test_pacify_subteam()` 後）。
- `scripts/simulation/faction_ai_system.gd`：2 處 → `add(...,"faction")`。
- `scripts/simulation/events/event_unrest_split.gd`：2 處 → `reset(...,"split")`。
- `scripts/simulation/events/event_unrest_replace.gd`：1 處 → `reduce(...,"replace")`。
- `scripts/simulation/interaction_system.gd`：1 add(tax) + 1 reduce(pacify)。
- `scripts/simulation/player_command_system.gd`：2 處 → `add(...,"player")`（索貢+2、勒索+1）。
- `scripts/simulation/reaction_system.gd`：1 reduce(recover, P4_expand) + 1 add(reaction, N2_riot)。
- `scripts/simulation/resource_system.gd`：1 處 → `add(...,"famine")`。
- `scripts/simulation/salary_system.gd`：1 處 → `add(...,"salary")`。
- `scripts/simulation/task_arbiter.gd`：1 處 → `add(...,"task")`。

## 路由完整清單（grep 定位的 13 production 寫者，全已路由）

| 檔案 | 原運算 | 路由 | reason |
|---|---|---|---|
| faction_ai_system.gd（抗拒玩家指令）| `+= 1` | add | faction |
| faction_ai_system.gd（徵用 extract）| `+= 1` | add | faction |
| event_unrest_split.gd（分裂主團）| `= 0` | reset | split |
| event_unrest_split.gd（分裂母團）| `= 0` | reset | split |
| event_unrest_replace.gd（領袖替換）| `maxi(cur - UNREST_REPLACE_THRESHOLD, 0)` | reduce | replace |
| interaction_system.gd（徵收 tribute）| `+= 1` | add | tax |
| interaction_system.gd（安撫 pacify）| `maxi(cur - 1, 0)` | reduce | pacify |
| task_arbiter.gd（慾望壓抑）| `+= 1` | add | task |
| salary_system.gd（減薪）| `+= 1` | add | salary |
| resource_system.gd（leader 長期高壓）| `+= 1` | add | famine |
| reaction_system.gd（P4_expand）| `maxi(cur - 1, 0)` | reduce | recover |
| reaction_system.gd（N2_riot）| `+= 1` | add | reaction |
| player_command_system.gd（索貢成功）| `+= 2` | add | player |
| player_command_system.gd（勒索遭拒）| `+= 1` | add | player |

> 註：表為 14 列（plan 文字稱「13」，因 replace 那條在 plan Step5 清單與其餘並列共 14 條；以實際 grep 為準 = 14 production 寫點，全路由）。

## grep 驗證（無漏網裸寫）

`scripts/simulation/**` 全域 grep `unrest_turns\s*(=|\+=|-=)` 後，僅 `unrest_bank.gd` 命中（banker 本體 + 1 行註解），其餘 production 寫點全經 UnrestBank。讀取式（如 `float(team.unrest_turns) / 30.0` morale 計算）不受影響。`headless_test.gd` 的 fixture 設定（`team.unrest_turns = N` 測試初始化）依規定 **不路由**。

## 2 年 world_sim 結果

`world_sim.gd`（max_ticks=172800 = 2 年，無 seed），結果：
- `=== world_sim DONE ===`，`不變量違反累計=0`，0 SCRIPT ERROR。
- unrest 經 bank 正常累積/削減：尾端 Trace 各隊 unr 值有別（T0 unr146、T2 unr0、T4 unr8）→ add/reduce 路由生效。
- **本 run 無 split/replace/uprising 事件觸發**（grep 計數 0）→ `g1.unrest_reset` 未現於 ProbeSummary。此為本 seedless run 的 baseline 特性（split 需 dissenter loyalty/stress 條件 + 事件 cadence，本 run 未滿足），**非本次路由造成的回歸**：純路由保留同數學，reset 路徑由專屬單元測試（`_test_uprising_*`、`_test_unrest_bank` reset 斷言）覆蓋並全綠。
- 建議主 session 若要在 sim 內見 reset，可調 seed 或 split 觸發門檻；屬平衡範疇非本 task。

## 回歸

`headless_test.gd` 全綠：`=== DONE ===` ×1、SCRIPT ERROR ×0、Assertion failed ×0。守恆 OK（trade/storage/extract/mint/massacre/投靠 coin_eq 全 OK）。InvariantAudit population/faction/subteam 全 OK。`unrest bank OK`、`Resident Task12 OK`（pacify reduce）、`起義觸發`/`uprising paths` 全過 → 既有 unrest/叛亂/替換/分裂/減薪/安撫測未動而保持 GREEN，確認語意對齊（無 add/reduce/reset 誤置）。

## 連動風險
- 無已知連動風險。純路由，data model 未動，守恆無關（unrest 非守恆量）。
- `reason` 參數目前 inert（無 consumer）；未來若加 unrest 審計 dashboard 可消費。

## 待主 session 確認 / Pattern B 後續
- **Pattern B 剩餘 banker**：`loyalty` / `resources` / `anon_treasury` / `outpost_owner` 尚未收為單一 owner。其中 `resources` / `anon_treasury` 守恆敏感（coin_eq / InvariantAudit），收編需嚴審守恆路由，建議各自獨立 sub-session。
- 本 task 為 Pattern B 第一池示範，後續可沿同模式（add/reduce/reset + reason + probe）推進。
