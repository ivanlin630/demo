# Hand Back: ResourceBank — Pattern B 第五池（resources 單一 owner）

## 實作摘要

新增 `scripts/simulation/resource_bank.gd`（Pattern B banker，簡 wrapper，逐 site 保原數學 → 守恆 by construction）：

```gdscript
class_name ResourceBank
static func add(team, res, amt, reason="") -> void        # team.resources[res] = get(res,0) + amt（可負）
static func remove(team, res, amt, reason="") -> float    # clampf(amt,0,have)，回實扣量，不透支
static func set_amt(team, res, amt, reason="") -> void    # 絕對設值
static func clear_all(team, reason="") -> void            # team.resources.clear()
```

**單測**（`headless_test.gd::_test_resource_bank`，已註冊）：add→50 / remove 20→30 / remove 999→clamp 0 / set_amt→100 / clear_all→空。

### 改的檔（路由 team.resources → ResourceBank）
| 檔 | site | 改了什麼 |
|---|---|---|
| resource_bank.gd | — | 新增 banker |
| headless_test.gd | — | 加 `_test_resource_bank` + 註冊 |
| interaction_system.gd | 24 | trade/extort/raid/tribute/barter/market/借還公庫/aid |
| player_command_system.gd | 18 | 訓練/存取公庫/索貢/收取loot/投降/收留餵食/aid/招募anon+named/裝備swap |
| encounter_system.gd | 18 | 裝備上場扣pool/歸還/loot(mounts/horses)/arrows耗/屠村吸收 |
| faction_ai_system.gd | 11 | auto-withdraw mounts/extract公庫/滅團clear×2/NPC領存公庫/基建子隊撥付 |
| resource_system.gd | 8 | mount/horse 草料/吃糧/採集intake/一般稅（tile.resources 不動） |
| subteam_system.gd | 6 | 分隊比例搬資/合併吸收 |
| health_system.gd | 5 | 醫療消耗 medicine/tools |
| player_trade_system.gd | 4 | 玩家 gives/wants 雙向轉移 |
| game_setup.gd | 4 | 初始 starting/preset set_amt（tile init 不動） |
| equipment_system.gd | 4 | named 裝/卸/陣亡回收/anon 回收 |
| outpost_system.gd | 3 | 馬廄草料/建造取消退款/建造扣款 |
| npc_combat_system.gd | 3 | NPC loot 雙向/死者 coin 退團 |
| beast_system.gd | 3 | 獸隊 init clear/獸戰 food+material 獎勵 |
| salary_system.gd | 2 | named/anon 薪資扣公庫（remove clamp） |
| reaction_system.gd | 2 | N4_shirk 吃糧/N5_extort 偷 coin |
| population_system.gd | 2 | 溢出建隊比例搬資 |
| player_system.gd | 2 | 玩家 take/deposit team |
| manufacturing_system.gd | 2 | 配方產出/投入 |
| hunt_system.gd | 1 | 狩獵得糧 |
| anon_tier_system.gd | 1 | 訓練成本扣（coin 入公庫） |
| events/event_unrest_split.gd | 1 | 分裂新隊 resources init（全0 dict → clear_all 等價） |

**總計 124 routed sites / 21 檔**（不含 resource_bank.gd / headless_test.gd）。

### clamp 變異處理（逐 site 對齊原數學）
- `r[k] += x` / `r[k] = get(k,0)+x` → `add(t,k,x)`
- `r[k] -= x` 原 **有** maxf clamp（salary/arrows/construction_pay/mount_feed/heal_anon）→ `remove(t,k,x)`
- `r[k] -= x` / `r[k] = get-x` 原 **無** clamp（可負：manufacture_input/extort/tax/loot_out/transfer 各端）→ `add(t,k,-x)` 保負可
- `r[k] = <絕對 expr>`（init/借還公庫/吃糧歸零/分隊 sub 端/裝備 pool 重算）→ `set_amt(t,k,expr)`
- `r = {}` / `r.clear()`（beast init/滅團×2/split init）→ `clear_all(t)`
- 方法分佈：add 84 / set_amt 28 / remove 8 / clear_all 4

### scope 邊界（重要）
**`tile.resources`（HexTileData，野馬/獵物/猛獸/herb/ore/食材再生池）非 team.resources，不在 banker 範圍**（banker 簽名 `team: TeamData`）。world_generator(16)/harvest(tile sites)/ambush(1)/resource_system regen 等 tile.resources 寫保持原樣。這是兩個不同的資源池，plan 的「resources 單一 owner」指 team.resources。

## coin 守恆證據

### 每組後 headless（增量閘）
4 組路由後每組跑 `headless_test.gd`，**coin_eq / 各 conservation 測 + InvariantAudit 全綠**：
- trade conservation OK / Bug10 massacre conservation OK (coin=190.0) / storage conservation OK / extract_treasury conservation OK / 投靠守恆整合(coin_eq) / N5 coin 守恆
- InvariantAudit population/faction/subteam 雙向 OK

### 最終全回歸（Task 6）
`headless_test.gd`：**SCRIPT_ERR=0 / PARSE_ERR=0 / ASSERT_FAIL=0 / === DONE ===**。

### 2 年 world_sim
`world_sim.gd` 跑滿 **d720（2 年）**：SCRIPT_ERR=0、`=== world_sim DONE ===`、**`[world_sim] 不變量違反累計=0`**（InvariantAudit 每 cadence check 全程 0）。資源流動正常（G1 coin/food/mat、Salary、Extract、trade、loot 皆運作）。

> 註：`InvariantAudit.check` 目前 **未** 包含獨立 coin_eq `_check_*`（檔內註解列為「真存守恆量(coin_eq)」候選但尚未註冊）。故 2 年 world_sim 的「不變量=0」證 population/faction/subteam/cohort/dangling 完整，coin 守恆則由 headless 專測（trade/massacre/storage/extract_treasury/coin_eq 全綠）+ banker by-construction 保證。**建議後續**：把 coin_eq 註冊進 `InvariantAudit._check_coin_conservation`，讓 world_sim 長跑自動守 coin（目前 plan 措辭「2yr CoinAudit delta=0」無對應 harness，實際以 headless coin 套件 + 不變量0 + by-construction 三證取代）。

### 多場景 sanity
`game_sim_multi.gd`：SCRIPT_ERR=0，game_sim_test/tyrant/merchant/warzone 全跑完無崩潰。

## grep 驗證（無裸寫殘留）
```
grep -rnE '<ident>.resources[...] =/+=/-=  |  .resources = {  |  .resources.clear()'
  排除 ==/!= / tile|ntile|src_tile|dst_tile|gtile.resources / .resource_cap / resource_bank.gd
→ 0 筆殘留
```
scripts/simulation/** 內所有 team.resources 寫已全走 banker。

## 連動風險
- **無新行為**：banker 是純 wrapper，逐 site 保原數學，零語義變動 → 對其他系統透明。
- `reason` 參數目前未被消費（純文件/未來 audit hook 用），不影響行為。
- `tile.resources` 仍為裸寫（不同池，刻意排除）。若未來要統一 tile 池 owner，是另一個 Pattern B banker（`TileResourceBank`），不在本 arc。

## 待主 session 確認
1. **coin_eq 註冊進 InvariantAudit**（見上「2 年 world_sim」註）：讓長跑自動守 coin 守恆，補上目前靠專測+by-construction 的缺口。建議後續 task。
2. `reason` 字串是否要接 audit/probe（目前 dormant 參數）。
3. `tile.resources` 是否要開第六個 banker（TileResourceBank）統一地圖資源池 owner。

## Pattern B 狀態
**Pattern B 5/5 池完成**（resources = 第五池，最後一池）。team.resources 已單一 owner = ResourceBank。
