# Hand Back: Coin Economy + Outpost Public Storage

分支：`feat/coin-economy-and-storage`（14 Tasks 全完成）

## 實作摘要（每檔一行）

- `scripts/data/team_data.gd`：加 `anon_treasury`（匿名兵 wage 沉澱）
- `scripts/data/tile_data.gd`（class `HexTileData`）：加 `public_storage` / `abandoned_coin` / `mint_level`
- `scripts/simulation/outpost_system.gd`：`OUTPOST_STORAGE_CAP` + `_get_storage_cap`；FACILITY_DEF 加 `mint`；`MINT_*` 常數 + `_tick_mint`（hourly，由 `tick_all` 驅動）
- `scripts/simulation/resource_system.gd`：`PUBLIC_RESOURCES`（ore_*）；`_collect_from_tile` 加 `state` 參數，礦進自家 outpost 公庫；`resolve_consumption` 結尾加飢餓緊急徵用
- `scripts/simulation/manufacturing_system.gd`：`_add_output` helper，成品（goods/weapon_*）→ 公庫；冶煉中間產物 `ore_steel` 仍留 team（保持製造鏈）
- `scripts/simulation/salary_system.gd`：`_pay_salary` anon wage → `anon_treasury`
- `scripts/simulation/person_generator.gd`：`generate_for_team` 升 anon 帶 ×3 treasury share
- `scripts/simulation/faction_ai_system.gd`：`_check_ore_surplus`、`_extract_treasury`（加 amt<1 噪音 guard）、`_consider_extraction`（月 cadence）、`_on_team_extinct`、`_calc_team_need`、`_evaluate_storage_visit`
- `scripts/simulation/encounter_system.gd`：`_loot_treasury_share` + `resolve_encounter_end` 按 anon 損失比例 loot
- `scripts/simulation/movement_system.gd`：`_on_arrival` 加 abandoned_coin pickup + NPC 自家 outpost 自動領存
- `scripts/simulation/subteam_system.gd`：dispatch + 兩個 merge 函數 treasury 按 frac 分配（全併入則全帶走）
- `scripts/simulation/player_command_system.gd`：3 actions `extract_treasury` / `withdraw_from_storage` / `deposit_to_storage`；recruit_anon 帶走原團 treasury 份額
- `scripts/debug/headless_test.gd`：16 個 CoinStorage 測試

## 與 spec 的差異

- **manufacturing 成品才進公庫**：spec 寫「產出流向公庫」，但若冶煉中間產物 `ore_steel` 也進公庫，會切斷「冶煉→武器」同團製造鏈（武器配方從 `team.resources` 讀 steel）。故只把最終成品（goods / weapon_*）導向公庫，steel 留 team。
- **`_extract_treasury` 加 `amt < 1.0: return` guard**：原 `_consider_extraction` 月評估在 treasury 極小時會印「徵用 0 coin」並虛增 `unrest_turns`，加 guard 消除噪音與假動亂。
- **`_on_team_extinct` 整合點**：現有 codebase 不在 population==0 時移除 team。改在 `faction_ai.evaluate_all` team loop 用 `population<=0 且仍有資產` 的 idempotent guard 觸發，只轉移資產不刪 team。

## 連動風險

- **`ore_*` 來源/消費斷層（重要）**：`PUBLIC_RESOURCES` 把 ore_gold/silver/iron/steel 採集導向 `public_storage`，但 `manufacturing_system` 的武器配方仍從 `team.resources` 讀 ore_iron/ore_steel。`_calc_team_need` 未列 ore_*，故 NPC 自動領存不會把 ore 從公庫搬回 team → NPC 武器生產可能停擺。需主 session 決定：(a) `_calc_team_need` 加 ore_* 需求，或 (b) 製造改從公庫讀 ore。
- **`_collect_from_tile` 簽名加 `state`**：已確認唯一呼叫端在 `resource_system` 內部，已更新。
- **`team.resources.clear()` on extinct**：滅團後 resources 字典清空（非保留 0 值 key）。其他系統多用 `.get(k, 0)` 故安全，但若有直接索引 `resources["food"]` 的程式會 KeyError，未全面審。
- **公庫 ↔ team 資源雙軌**：採礦/製造成品入公庫後，team.resources 對應 key 不再增長；UI / 既有以 team.resources 判斷富裕度的邏輯（外交、AI 目標）數值會偏低。
- **`_evaluate_storage_visit` deposit 門檻**：team_have > need×2 才存，food need = pop×14（約半月份），數值為測試值待平衡。

## 待主 session 確認

- ore_* 製造輸入斷層（見上，建議優先）
- `_calc_team_need` / mint 轉換率 / storage cap 等皆測試值，待平衡期調整（見 [[feedback_tick_balance]]）
- 公庫 UI 顯示（玩家看不到 public_storage / abandoned_coin）
- 上交皇糧（居民食物自動流公庫）獨立 spec
- 慶典/賑災事件 sink、賭博/賄賂 person.coin 用途
- mint facility 的 NPC 自動建造（trigger_check `_check_ore_surplus` 已接好，但實際 dispatch 路徑未端到端驗證）

## 測試結果

- `headless_test.gd`：`=== DONE ===`，16 個 CoinStorage Task 全 OK，無 SCRIPT ERROR
- `game_sim_test.gd`：`ALL INVARIANTS PASSED (violations=0)`，無 SCRIPT ERROR
  - `[FEATURE FAIL] Trade trade_success=0` 為 **main baseline 既有**，非本分支造成
