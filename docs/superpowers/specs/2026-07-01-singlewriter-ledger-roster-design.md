# 單寫者 slice2：Pattern B driver-ledger + roster chokepoint — 設計 spec

> 系統 HOW spec。承藍圖 `trio-rulings`（單寫者剩餘 arc = 強制閘前提）。統一矩陣 F-S2（ledger stub）+ F-S3（roster 無 chokepoint）。
> **目標**：第3不變量「凡 state 變化必有單寫者/driver」真落地一塊——**driver-ledger 真記**（現全 5 bank stub 丟 reason）+ **roster named_members 單寫者**（現 59 直寫）。= 強制閘有可查對象的前提。
> **tile-granary-bank 延**（B 食物要重做 granary 流,避撞+被重做）。**combat_target 延**（綁 BEG/JOIN 社交語意拆下輪）。本 slice 只 ledger + roster。

## 現況（矩陣證）
- **F-S2 Pattern B driver-ledger=stub**：`resource_bank.gd` + 4 bank（anon_treasury/outpost_owner/loyalty/unrest）每 fn 收 `reason` 參數但**丟棄不記**。第3不變量 driver 面未實現。
- **F-S3 roster 無 chokepoint**：`named_members` 59 直寫 site/17 檔（`.append/.erase/.clear`），person↔team 無 bidir（team_id 一邊寫、named_members 另邊寫,可 desync）。

## 設計

### A. Pattern B driver-ledger 真記
- 統一 ledger sink：state 級 `driver_ledger`（或 Probe-style 累計）記每筆 bank 操作 `{tick, entity, field, delta, reason}`。
- 5 bank（ResourceBank/AnonTreasuryBank/OutpostOwnerBank/LoyaltyBank/UnrestBank）的 `reason` 參數 → **真 append 進 ledger**（現丟棄）。
- **LOD/成本**：ledger 預設 off 或 ring-buffer（cap N,避無界增長——連 scaling 評估）;debug/audit/強制閘時開。正常 run 零成本或 bounded。
- **用途**：強制閘可查「這筆 state change 的 driver」;審計「凡變化有 driver」;debug 溯源。

### B. roster named_members 單寫者 + bidir
- 加 chokepoint：`WorldState.add_member(team, person)` / `remove_member(team, person)`（維護 `team.named_members` ↔ `person.team_id` bidir,類比 set_team_faction）。
- 改 59 直寫 site → 走 chokepoint（subteam 9/reaction 3/health 2/faction_ai/… 逐檔）。
- leader 特例（leader_id）：leader 也是 named_members? 確認語意（plan 定,傾向 leader_id 獨立 + named_members 為非-leader named,或 chokepoint 涵蓋兩者）。
- **bidir 保證**：add→both set、remove→both clear;`InvariantAudit` 加 named_members↔team_id 雙向自洽（類比 faction bidir audit）。

## 驗收
- **ledger**：5 bank 操作真記 driver（測：一筆 ResourceBank.add 後 ledger 有該筆 reason）;正常 run bounded/off 零成本;守恆不變。
- **roster**：59 直寫全走 chokepoint;named_members↔team_id bidir 自洽（InvariantAudit 新測綠）;無 desync。
- 守恆：coin_eq（全池）0、pop 守恆、framework S1-S6 PASS、headless 全綠、InvariantAudit（含新 roster bidir）0。
- **零行為變**（純所有權重構,結果不變）。

## 檔案
- `resource_bank.gd` + `anon_treasury_bank.gd` + `outpost_owner_bank.gd` + `loyalty_bank.gd` + `unrest_bank.gd`：reason → ledger append。
- `world_state.gd`：`driver_ledger` + `add_member`/`remove_member` chokepoint（bidir）。
- 59 roster 直寫 site（`subteam_system`/`reaction_system`/`health_system`/`faction_ai_system`/`event_*`/`game_setup`/`person_generator`…）→ 走 chokepoint。
- `invariant_audit.gd`：named_members↔team_id bidir 自洽。
- `headless_test.gd`：ledger 記錄測 + roster bidir 測 + 零行為變回歸。

## 風險 + 緩解
- **59 site 改動面大**：逐檔 TDD、每檔跑 headless、零行為變硬驗（結果不變）。leader/named 語意先定清。
- **ledger 無界增長**（連 scaling）：ring-buffer cap or off-by-default。
- **與 B 食物/征服 measure 並行**：本軌碰 banks + world_state + roster site（含 reaction_system 的 named_members 寫,**非** reaction growth 函數）→ B 食物碰 reaction growth（不同函數）、faction_ai roster 寫（征服 measure 碰 faction_ai _decide_unified,不同函數）→ 多數 disjoint,同檔不同函數 merge 順序解。
- **scope**：只 ledger + roster。**不碰** tile-granary-bank（B 食物後）/combat_target（BEG-JOIN 綁）/tile.resources bank（後）。

## 開放細節（plan 定）
- ledger sink 形式（state 欄 ring-buffer vs Probe 擴充）+ 預設 on/off。
- leader_id vs named_members chokepoint 涵蓋範圍。
- 59 site 分批序（先 subteam/reaction 熱點）。
