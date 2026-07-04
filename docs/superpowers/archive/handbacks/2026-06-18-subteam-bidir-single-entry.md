# Hand Back: Subteam 雙向單一入口（parent_team_id ↔ subteam_ids 根治）

## 實作摘要

加 `WorldState.set_subteam_parent(child, parent_id)` / `detach_subteam(child)` 單一入口（一處同維護 `child.parent_team_id` ↔ `parent.subteam_ids`），散落的母子關係變動全走入口，並補「子隊滅團未從 `parent.subteam_ids` 移除」缺口。

- `scripts/data/world_state.gd`：加 `set_subteam_parent` / `detach_subteam`（接在 `clear_team_faction` 後，對齊 `set_team_faction` 雙向模式；idempotent，換 parent 自動退舊母入新母）。
- `scripts/simulation/faction_ai_system.gd`：
  - `cleanup_extinct_teams`：`teams.erase` 前 `detach_subteam`（**主缺口** — 子隊滅團路徑原只清 faction member、漏母側 → 懸空大宗）。
  - `_check_discipline_fail`（~:843）：紀律失效脫離改 `state.detach_subteam(sub)`，刪手動 erase + 單側 `=-1`。
- `scripts/simulation/subteam_system.gd`：
  - `dispatch`：刪 `sub.parent_team_id = parent_id` + `parent.subteam_ids.append`，在 `teams[sub.team_id]=sub` 後 `state.set_subteam_parent(sub, parent_id)`。
  - `merge_teams` 完全合併分支：`detach_subteam`（滅團前清母側）；部分合併分支：`set_subteam_parent`（absorbed 成 absorber 子隊，順帶退舊母）。
  - `_merge_into` 母團滿回歸失敗 split、合併後脫離兩處：改 `state.detach_subteam(absorbed)`，刪手動 erase。
- `scripts/simulation/outpost_system.gd`：`_auto_settle_builder` 完工安頓 → `state.detach_subteam(team)`，刪兩行。
- `scripts/simulation/interaction_system.gd`：`_convert_to_resident` 變居民單側 `=-1` → `state.detach_subteam(subteam)`。
- `scripts/debug/headless_test.gd`：加 `_test_set_subteam_parent`（入/換/detach/idempotent 四斷言）+ 註冊 `_initialize()`。

與 spec 無差異。

## 驗證

- `headless_test.gd`：`=== DONE ===`、無 `SCRIPT ERROR`、`[OK] _test_set_subteam_parent`、`[MergeTest] _merge_into cleanup ok`、merge_teams 測試全綠。
- `game_sim_multi.gd`（4 config：game_sim_test / tyrant / merchant / warzone）：
  - `[InvariantSummary] … 違反取樣總計=0`（含 subteam 雙向破/懸空 → **0**；baseline 目標 ~13 → 0）。
  - `coin_eq` delta=0.00（4 config）。
  - 無 `SCRIPT ERROR`。

## 與 spec

完成 master invariant spec **規則 3 的 subteam 雙向部分**（`set_subteam_parent`/`detach_subteam` + 散落改走入口 + 滅團 detach 缺口）。audit `_check_subteam_bidir`（`invariant_audit.gd:53`）為現成守門，本次未動其簽名。

**規則 3 全竣（faction ✅ + subteam ✅）→ 整個「散落不變量」債類根除。**

## 連動風險

- `merge_teams` / `_merge_into` 也被一般併團路徑呼叫（流民投靠 / 投降 / player 收留，absorbed.parent_team_id 通常 = -1）：此時 `detach_subteam` 為 no-op（與原 `subteam_ids.erase` no-op 同），若 absorbed 確有真母則改為正確清母側（嚴格更好，順帶修 `_erase_absorbed_team` 路徑的潛在懸空）。已過 headless + multi 回歸，無 regression。
- 無其他已知連動風險。

## 待主 session 確認

- baseline multi 的 subteam 違反精確值未單獨記錄（直接驗最終 = 0，達標）。
- 建議後續：規則 3 全竣後可考慮把 `_check_subteam_bidir` / `_check_faction_bidir` 由「取樣」升為每 N tick 全量斷言（若效能允許），把雙向債從偵測轉為硬 guard。
