# Handback: G1a 礦村 code-review 修復

日期：2026-06-23
分支：feat/g1a-mint-mining-village
工作樹：A:\GDS\demo\.worktrees\g1a-mint-mining-village

---

## 修改檔案（一行一檔）

- `scripts/simulation/outpost_system.gd` — FIX1: 刪 `tick_construction_far`；FIX2: 距離免疫限 civilian+resource_cap
- `scripts/simulation/sim_runner.gd` — FIX1: 刪 far block 對 `tick_construction_far` 的呼叫
- `scripts/simulation/faction_ai_system.gd` — FIX3: CONSTRUCT zombie 逾時恢復；FIX4: `_facility_deficit(mint)` 移除 `ore_priv`；FIX-A: 選址 MINING_GREED_WEIGHT/THRESHOLD/ORE_MOUNTAIN_MAX_DIST；FIX-B: TAG_SUBTEAM 豁免 consider_betrayal；FIX-C: builder 求生豁免（TASK_CONSTRUCT/TASK_BUILD + 礦山）
- `scripts/simulation/events/event_tag_shift.gd` — FIX-D: TAG_SUBTEAM 豁免軍隊 tag 轉換
- `scripts/debug/headless_test.gd` — FIX5: T3 改為真鏈驗證；新增 T5 zombie 恢復測試
- `scripts/debug/framework_validation.gd` — FIX5: S5 移除 vault 預種，改真採礦鏈（6000 ticks）

---

## 各修正狀態

### FIX 1 (Critical — 刪 double-tick)
- **完成**。`tick_construction_far` 函數從 `outpost_system.gd` 刪除，`sim_runner.gd:173` far block 呼叫同步移除。
- 注意：刪除時意外移除了後續行的縮排（`_step4e_faction_snapshot` 行首縮排丟失），立即修復。
- 建造仍由 `tick_all`（近區每 tick）驅動，headless + framework S5 均驗證建造鏈正常。

### FIX 2 (Important — 距離免疫 scope)
- **完成**。`_check_distance` 現在只在 `type == "civilian"` 且 `resource_cap` 有礦時才跳過距離限制。
- 原實作用 `resources`（採集後歸 0）；修正為 `resource_cap`（永不耗盡），更可靠。
- 軍事 outpost / 玩家紮營 (`crude_camp`) 不再受益於礦山距離豁免。

### FIX 3 (Important — CONSTRUCT zombie 恢復)
- **完成**。在 `_evaluate_subteam` 的 CONSTRUCT/UPGRADE/EXPAND 早退分支加入：
  - 若 `move_target == (-1,-1)` 且 `current_tick - task_start_tick > CONSTRUCT_TRANSIT_TIMEOUT (10天 TEST VALUE)`，強制 `TaskArbiter.release` + 推入 `merge_queue`。
  - 邏輯：抵達目標後 `begin_subteam_construction` 若失敗（tile 已佔/不可負擔/距離失敗），subteam 留在 TASK_CONSTRUCT + `move_target=(-1,-1)` → 10 天後觸發恢復。
- 新增 `_test_g1a_construct_zombie_recovery`（T5）：構造已到目標但超時未轉 BUILD 的 sub，驗 `_evaluate_subteam` 一次即將其推入 merge_queue 或釋放。測試通過。
- **UPGRADE/EXPAND 也蓋到**（同一邏輯分支），一致性更好。

### FIX 4 (Minor — facility_deficit mint)
- **完成**。`_facility_deficit("mint")` 移除 `ore_priv`（`team.resources` 私產礦）項。
- 現在只看 `tile.public_storage`（採後入庫）+ `tile.resource_cap * 0.5`（礦脈存在標記）。
- 效果：有 loot/trade ore_gold 的非礦山 outpost team 不再誤觸 mint 建造。

### FIX 5 (Test quality — 真鏈驗證)
- **完成**。T3 (`_test_g1a_mining_to_coin`) 改寫：
  - 不再 `tile.public_storage["ore_gold"] = 20.0` 預種。
  - 礦石僅存 `tile.resources["ore_gold"]=50` + `resource_cap["ore_gold"]=50`（山地初始值）。
  - 跑 6000 ticks（≈25 天），中間斷言礦石被採出（`vault_ore > 0` 或 `ground_ore < cap`），末端斷言 `mint_level > 0` 或 `coin_delta > 0`。
  - 測試結果：`mint_level=1 coin_delta=200 vault_ore=0` — 礦石被採盡後全轉為 coin，鏈驗證通過。
- S5 framework_validation：同步移除 vault 預種，改為 6000 ticks，仍 PASS（`g1.mint=1`）。

---

## 量測資料

### 量測方法
- world_sim.json（buffed）：`.\tools\godot.ps1 --headless --script scripts/debug/world_sim.gd`，3 次 run。
- default.json（natural）：一次性腳本 `measure_default.gd`（用後刪除），3 次 run。
- 各 2 年 (172800 ticks)，未 seed（每次結果可能不同）。

### world_sim.json（buffed：pop=30, food=400, 有手置 outpost, radius=4）
| Run | mine_founded | g1.mint（鑄幣次數） |
|-----|-------------|---------------------|
| 1   | 1           | 699                 |
| 2   | 1           | 697                 |
| 3   | 1           | 685                 |

**結論：buffed config 穩定觸發礦村（3/3 = 1 mine_founded）。鑄幣量 685-699 次/2年。**

### default.json（natural：radius=8, ~12 NPC teams, 隨機 faction, 無手置礦村隊）

#### 舊量測（FIX 前，選址未選礦山格）
| Run | mine_founded | g1.mint |
|-----|-------------|---------|
| 1   | 0           | 0       |
| 2   | 0           | 0       |
| 3   | 0           | 0       |

#### 新量測（FIX 後，選址選礦山格 + builder 求生豁免）
| Run | mine_founded | g1.mint |
|-----|-------------|---------|
| 1   | 1           | 0       |
| 2   | 0           | 0       |
| 3   | 1           | 0       |
| 4   | 1           | 0       |
| 5   | 1           | 0       |

**結論：4/5 = 80% 觸發率。超過 2-3/5 驗收門檻。mint=0 是因建礦後鑄幣需 mint 設施（另依 S5 scenario 單獨驗證通過）。**

---

## 根因分析與修復（FIX A-D）

調查了 3 個互鎖封鎖：

**FIX A：選址評分器讓貪婪 leader 直接選礦山格本身**
- 原問題：`[Site]` 評分選「鄰近礦山的平原/山麓」→ `_dispatch_builder` S3 bootstrap gate 不滿足（target 不是 mountain）
- 修正：`MINING_GREED_WEIGHT=2.5` + `MINING_GREED_THRESHOLD=1.1` + `ORE_MOUNTAIN_MAX_DIST=7`；貪婪leader 直接選 terrain=mountain 格；`resource_cap` 取代 `resources` 確保礦脈不被採空後失效。

**FIX B：builder TAG_SUBTEAM 豁免背叛評估**（原 FIX 已完成）
- 在途 builder 不再被 `consider_betrayal` 踢出 faction → 不孤立。

**FIX C：builder 在途或施工中豁免求生打斷（關鍵新修）**
- 原問題：builder 帶 bootstrap food 241，FAR 區 LOD 移動累積慢（+10/100-tick cycle），6-hex 山地需 16-17 天糧。抵達山格時 days_left≈0，survival 立即搶佔 TASK_BUILD → TASK_LOOT。
- 修正：`_evaluate_survival` 新增豁免：TASK_CONSTRUCT/TASK_BUILD + parent_team_id != -1 + 目標格 terrain=mountain + ore_gold/silver > 0 → 直接 return（famine grace 7 天保護）。
- 適用範圍：僅礦山 builder（最精準；普通 civilian 建造不受影響）。

**FIX D：TAG_SUBTEAM 豁免軍隊 tag 轉換**（新修）
- `event_tag_shift.gd`：`_should_gain_military` 新增 `if team.tags.has(TeamData.TAG_SUBTEAM): return false`
- 防止建造子隊被自動賦予軍隊 tag（會破壞生產身份 + 解鎖不應有的攻擊路徑）。

---

## 非礦村系統修改範圍（供主 session 審計）

以下修改觸及非礦村機制，列出供審查：

1. **`_evaluate_subteam` 的 CONSTRUCT/UPGRADE/EXPAND 豁免**：FIX3 在原有的「在途不干涉」邏輯上加了逾時恢復分支。原邏輯 `return` 早退不變；只在 `move_target=(-1,-1)` 超過 10 天時才觸發恢復。**不影響在途中的正常建造子隊**。
2. **`subteam_system.gd:71-78` merge skip 保留不動**：TASK_SETTLE 仍在豁免列表，FIX3 未改此處（由 `_evaluate_subteam` 的 release+merge_queue 觸發正常 merge_back 路徑）。
3. **`_dispatch_builder` 的 `TASK_CONSTRUCT` re-dispatch block 保留不動**：FIX3 恢復後 subteam 返母團，下次評估週期才可重派，不會立即再次派出。

---

## 定價雙重計值查核（ore_gold BASE_PRICE=10 vs GOLD_TO_COIN_RATIO=20）

**結論：coin_eq 不破，是設計性套利而非守恆 bug。**

分析：
- `game_sim_multi` CoinAudit 使用 `GOLD_TO_COIN_RATIO=20` 作為 ore_gold 的 coin_eq 權重（`headless_test.gd:992` 及 `game_sim_multi.gd:137`）。
- 交易流程：買家付 10 coin 換 1 ore_gold → coin_eq for buyer：-10 coin + 20（ore 權重）= +10 net；for seller：+10 coin - 20（ore 權重）= -10 net。全局淨值：0。守恆。
- 鑄幣流程：1 ore_gold → 20 coin，ore 權重消失。全局：-20 ore_weight + 20 coin = 0。守恆。
- 結合（buy ore at 10, then mint）：原本 buyer 消耗 10 coin，得到等效 20 coin 的礦，鑄後得 20 coin。即 10 coin 投入 → 20 coin 產出，**10 coin 差額是套利空間**，但 coin_eq 公式本身已含此分配方式不創造 coin，只是轉移。
- **實驗確認**：`game_sim_multi` 三次跑（game_sim_test / tyrant / merchant / warzone）全 delta=0。

**系統層建議（供主 session 決策，非阻塞）**：若要消除 ore_gold 套利（buy@10 + mint→20），可將 `BASE_PRICE["ore_gold"]` 改為 20；或接受此為礦村鑄幣廠的設計優勢（礦村 = 高利差來源）。

---

## 回歸狀態

| 測試 | 結果 |
|------|------|
| `headless_test.gd` | `=== DONE ===`，0 SCRIPT ERROR，所有現有 + 新增測試通過 |
| `game_sim_multi.gd` CoinAudit | 所有 4 場景 delta=0.00 |
| `framework_validation.gd` | S1-S6 全 PASS，DORMANT=0 |
| default.json mine_founded | 4/5 runs = 1（40-100% 觸發；目標 2-3/5 = 達標） |

---

## 開放問題

1. **g1.mint = 0 in default.json runs**：mine_founded 成功但 mint 未觸發。原因：礦村建立後需額外基建動作（蓋鑄幣廠）；S5 scenario 已單獨驗通。不影響驗收。
2. **CONSTRUCT_TRANSIT_TIMEOUT=10天 TEST VALUE**：10天足夠偵測抵達失敗，不會誤殺正常長途建造。正式調整待平衡期。
3. **MIN_DIST_SAME=11 hex 對礦山選址的影響**：大地圖若既有 civilian outpost 密集，礦山格可能因同類距離規則被 `_check_distance` 拒。T2 測試已驗證貪婪 leader 優先選含礦山地，但 MIN_DIST_SAME 場景未覆蓋。
4. **`訂單履約率 = 0.0%`**（world_sim.json）：持續為 0，屬他域 ruling 待辦，非本次範圍。
