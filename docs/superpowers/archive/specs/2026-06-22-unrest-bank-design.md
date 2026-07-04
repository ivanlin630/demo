# Pattern B 所有權 banker — unrest_turns（第一個 banker）

> 藍圖 `state-fight-scope` Pattern B：6 池所有權吵架，各設 banker 收 delta、禁外部絕對 set。本塊 = 第一個 banker（unrest_turns，最 bounded + 清楚 bug），藍本 = 既有單一 owner（AnonCohort/RelationGraph/ambition_ladder）。

## 病
`unrest_turns` ~13 production 寫/9 檔：delta 累積（薪資/稅/task/飢餓 +1）+ **絕對歸零**（`event_unrest_split` `=0` 兩處）→ 歸零洗掉別系統累積民怨、壓掉該爆的叛亂（last-writer-wins，無 banker）。

## 修：UnrestBank 單一 owner
新 `scripts/simulation/unrest_bank.gd`（static helper，同 AnonCohort 模式）：
```
static func add(team, n: int, reason := "")      # += n（民怨累積）
static func reduce(team, n: int, reason := "")   # = maxi(cur - n, 0)（消解）
static func reset(team, reason := "")            # = 0（蓄意歸零,僅 split-resolution 類）
```
- 所有 production 寫者改走 UnrestBank（13 處）：
  - `+= 1/2` → `UnrestBank.add(team, n, "salary"/"tax"/"task"/...)`
  - `maxi(cur - n, 0)` → `UnrestBank.reduce(team, n, ...)`
  - `event_unrest_split` 的 `=0` → `UnrestBank.reset(team, "split_resolved")`（蓄意:分裂消解民怨,但現為唯一 reset 路徑、有 reason、可審）。
- reset 打點 `Probe.bump("g1.unrest_reset")`（可見性,日後查「誰歸零」）。
- **禁裸 `team.unrest_turns =`**（除 bank 內）= 約定（GDScript 無法語言強制；bank 為單一 helper + grep 可驗）。

## believability / 行為
- **行為保留**（同 delta/reset 數學）→ 2yr world_sim 應近乎不變。價值 = **結構**（單一 owner、reset 可審、未來寫者不能靜默絕對 set 洗民怨）。
- split 仍消解民怨（語意正當:分裂即民怨出口），但現為唯一 reset 路徑（非散落絕對 set）。

## 守恆 / 不破
- unrest_turns 非守恆量（無 coin/pop 守恆）→ InvariantAudit 無關，但回歸驗既有 unrest/叛亂/替換/分裂測不變。
- 純路由（同數學）→ 不碰 resources/coin → coin_eq 0。

## 驗收
- UnrestBank add/reduce/reset 行為單測。
- 既有 unrest 鏈測全綠（減薪+1/重稅/替換閾/分裂歸零 行為不變）。
- 2 年 world_sim：unrest/叛亂/分裂 行為近基準（`g1.unrest_reset` 出現=reset 走 bank）；headless 全綠、coin_eq 0、InvariantAudit 0。

## 檔案
- 新 `scripts/simulation/unrest_bank.gd`。
- 改 13 production 寫者：`faction_ai_system.gd`(736,1401)、`event_unrest_split.gd`(22,117)、`event_unrest_replace.gd`(16)、`interaction_system.gd`(413,983)、`task_arbiter.gd`(45)、`salary_system.gd`(78)、`resource_system.gd`(309)、`reaction_system.gd`(258,272)、`player_command_system.gd`(313,341)。
- `headless_test.gd`：UnrestBank 單測 + 既有 unrest 測沿用（驗行為不變）。
- 2 年 world_sim 驗收。

## 非本塊（後續 banker，各別塊）
- loyalty（HIGH，~26 寫，絕對 set 洗 delta）、resources（~110 寫,面積最廣）、anon_treasury（守恆敏感,coin）、outpost_owner（race）= 各別 banker slice，**resources/anon_treasury 需嚴審守恆**。
- stress/fear/readiness（LOW）暫不設 banker（純 delta 無絕對洗）。
