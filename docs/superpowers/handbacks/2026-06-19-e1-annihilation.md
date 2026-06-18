# Hand Back: E-1 結構免疫退化修 + 武裝下限

branch: `feat/e1-annihilation`（已 push origin，未 merge）
plan: `docs/superpowers/plans/2026-06-19-e1-annihilation-degenerate.md`（5 task 全做完）

## 實作摘要

- `scripts/simulation/anon_tier_system.gd`：`kill_random` 加選用第 4 參數 `tier_weight`（預設 `{}` = 現行 count 比例，不破既有 caller）；非空時各 tier 抽中權重 ∝ count×weight。新增 const `SURVIVAL_KILL_WEIGHT`（平民1.0/新兵0.6/老兵0.3/菁英0.15，TEST VALUE）。
- `scripts/simulation/encounter_system.gd`：
  - 新增 const `RESERVE_CASUALTY_MULT=1.0`、`ARMED_RATIO_FLOOR=0.1`（TEST VALUE）。
  - 新增 helper `_apply_reserve_casualty(state, team_id, onfield_anon, dead_anon)`：敗方未上場 reserve 按上場陣亡率連坐，tier 加權存活。
  - `resolve_encounter_end`：on-field kill 迴圈改造，量 onfield_anon，**僅敗方**呼 reserve 連坐。
  - 武裝下限套在 spawn 兩處：position 配額（init_encounter else 分支）+ **真正 spawn 閘 `_spawn_team_units:1075**`（`armed_count` 用 floored ratio）。
- `scripts/simulation/npc_combat_system.gd`：新增 const `LOSER_CASUALTY_RATE=0.2`、`ARMED_RATIO_FLOOR=0.1`；`_end_combat` loot/記憶結算後、`_apply_pursuit` 前加敗方整隊 pop 損耗（tier 加權）；`_strength_raw` anon 戰力用 floored ratio。
- `scripts/debug/headless_test.gd`：加 5 測試並註冊——`_test_kill_random_survival_bias` / `_test_e1_encounter_reserve_casualty` / `_test_e1_npc_combat_loser_pop_loss` / `_test_e1_armed_floor` / `_test_e1_converges`。
- `docs/invariants.md`：加「敗方損耗對稱」不變量。
- `docs/known_issues.md`：E-1 標退化修已實作（A+B+C），完整意志/人海模型仍待母 spec 後續。

## 與 spec/plan 的差異

- **武裝下限消費點修正**：plan Task4 指 `encounter:247-248` 為 spawn anon 點，但那只是 position 配額；真正決定 spawn 幾個 anon 的閘是 `_spawn_team_units:1075`（`armed_count = pop × armed_anon_ratio`）。我兩處都套 floor（position 配額 + 1075 真閘），否則 0 武裝隊 position 雖留位但 1075 仍算 0 → spawn 0。測試最初即因此 fail，修 1075 後過。
- 其餘照 plan。helper `winner_leader_set` 改內聯（plan 允許）。

## 回歸閘結果

`--import` 後跑 `headless_test.gd`：`=== DONE ===`、SCRIPT ERROR / Assertion failed = 0、InvariantAudit population/faction/subteam OK、coin_eq 守恆 assert 全過、sim 200-tick + 全 scenario 無崩潰。5 個新測試全綠（reserve -72、E1Defeat -10、armed floor>0、converges <before/2）。

## 連動風險（主 session 決定是否補修）

- **既有 encounter/npc_combat 平衡測試漂移**：本次跑全綠未見漂移，但 reserve 連坐 + 敗方 pop 損耗會讓「敗方大隊」結算後 pop 明顯下降。若日後加更嚴的 pop 斷言測試需留意這是預期行為變更，非 bug。
- **繼承統一 plan 依賴**：`_test_e1_converges` 只驗 anon 趨減（<before/2），**未驗滅團**。「打到死」整鏈（anon→0 → `on_leader_death` 無 anon fallback → 滅團）需繼承統一 plan（`2026-06-19-leader-succession-single-source`）合入才完整。兩 plan 各自可獨立 land。
- **npc_combat 路徑**：known_issues #3 曾裁「兩病灶全在 encounter，不需碰 npc_combat」，但本 plan（spec 已演進為對稱母 spec）刻意對 npc_combat `_end_combat` 加對稱 pop 損耗。請確認此對稱性裁定一致（spec `e1-annihilation-degenerate` + 母 spec `combat-unification-umbrella`）。

## 待主 session 確認

- **全 TEST VALUE 待平衡**：`SURVIVAL_KILL_WEIGHT` / `RESERVE_CASUALTY_MULT=1.0` / `LOSER_CASUALTY_RATE=0.2` / `ARMED_RATIO_FLOOR=0.1` 全測試值，正式平衡 pass 再調。`RESERVE_CASUALTY_MULT=1.0` 意味敗方 reserve 與上場同陣亡率，可能偏狠。
- **ARMED_RATIO_FLOOR 各檔重複 const**：encounter / npc_combat 各自 0.1（MVP 各檔 const，未共用 config 鍵）。若要單一來源請主 session 決定移 config。
- **reserve 量測時點近似**：`_apply_reserve_casualty` 在 on-field `kill_random` 之後量 `total_anon`，故 reserve 用 `total_anon − onfield_anon` 會少算已死上場那批（TEST VALUE 容忍，照 plan 寫法）。若要精確，需在 on-field kill 前快照 total。

## 建議後續 task

- 繼承統一 plan 合入後，把 `_test_e1_converges` 升級為驗滅團（anon→0 → 團 erase）。
