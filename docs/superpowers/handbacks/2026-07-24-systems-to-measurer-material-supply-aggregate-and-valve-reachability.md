---
from: systems
to: measurer
status: open
topic: "[measure·material供給診斷(用戶方向定案後·measure-first定閥修多強)·2問:①aggregate forest-material夠不夠讓修閥就普世解鎖vs緊到本質競爭②缺料plains隊BUY/EXPAND哪閥最可達→先修哪·別假設aggregate夠不夠measure·MIGRATE非material閥(TASK_MIGRATE只food-driven)·base=current main a728fe90 post-material-hold·seed1337/42·piggyback order-noise月率baseline] 用戶裁material=地理張力feature(不加供給側設施/不regen rebalance),脫貧material脊椎=純取得閥(BUY/EXPAND/遷徙)。measure-first定閥強度前必答:★Q1 aggregate sufficiency=世界forest material總throughput夠幾隊發展?(forest tile數×regen12/tick=總供給/月 vs 發展一隊facility material需~105[cost70×1.5] → 供給能撐幾隊%=valve-fix普世解鎖[供給>>需求,隊只是沒取得] vs 本質競爭[供給<<需求,只少數控地隊能發展])。★Q2 valve reachability=抽樣缺料plains隊(material<50/無mil-facility/plains-home),逐隊查三閥可達性:(a)BUY=有可達市集+material賣單在市+隊有coin?買料option(options:259)fire/win沒?(b)EXPAND=pop≥6+視野內unowned forest tile在settle range+advisor?settle(_dispatch_subteam_settle:573)fire沒?(c)MIGRATE=標記非material閥(現只food-driven,無material-migrate option)→算『需建』非『可達』。tally哪閥對缺料隊最可達→定先修哪(別三個都猜)。★關鍵連動:若Q1供給薄(forest隊自用都不夠)→無surplus賣→BUY對plains隊結構死→EXPAND(自搶forest tile)才是真閥;但別假設,measure坐實。piggyback:順手抓order_placed/arb_kill_nostock月率當pre-fix baseline(近零成本,earlier piggyback ruling)。is_sim=true,seed1337/42,base current main a728fe90。→回to:systems(我據數定閥強度+序,spec前)。"
branch: main (a728fe90, post-material-hold-merge)
---

# measure：material 供給診斷（aggregate sufficiency + valve reachability）

用戶裁定 material = 地理張力 feature（**不加供給側設施、不 regen rebalance**）。脫貧 material 脊椎解 = 純**取得閥**。**measure-first**：定閥修多強前，先答用戶兩問（**別假設 aggregate 夠不夠，measure**）。

## ★Q1：aggregate material sufficiency（決定閥強度 + 是否接受競爭性發展）
- **總供給**：世界 forest tile 數 × regen（`resource_system:35-37` forest material **12**/tick）= 材料總 throughput/月。實際被採量（positional harvest 限制：站 forest 才採）。
- **發展需求**：發展一隊 = ~**105** material（facility cost 70 × 1.5 afford buffer）× N 隊 = aggregate 需求。
- **交付數字**：世界 forest-material 總 throughput 能撐**幾隊%發展**？
  - 供給 >> 需求 → **valve-fix 普世解鎖**（隊只是沒取得，修閥全隊可發展）。
  - 供給 << 需求 → **本質競爭**（只少數控 forest 地隊能發展，用戶已接受此後果=設計）。

## ★Q2：valve reachability（缺料 plains 隊三閥哪個最可達 → 先修哪，別三個都猜）
抽樣缺料 plains 隊（material holding <50 / 無 mil-facility / plains-home），逐隊查：
| 閥 | 存在? | 可達性檢查 |
|---|---|---|
| **BUY**（買料 `options:259`）| ✓ 已實作 | 有可達市集 + material 賣單**在市** + 隊有 coin？買料 option fire/win 沒？|
| **EXPAND**（settle `_dispatch_subteam_settle:573`）| ✓ 已實作 | pop≥6 + 視野內 unowned forest tile 在 settle range + advisor available？settle fire 沒？|
| **MIGRATE** | ✗ 非 material 閥 | `TASK_MIGRATE` 只 food-driven（Fix B 遷移找糧），無 material-migrate option → 算**「需建」非「可達」**，標記即可 |

**tally**：哪閥對缺料隊**最可達** → 定先修哪。

## ★關鍵連動假設（measure 坐實，別假設）
若 Q1 供給薄（forest 隊自用都不夠）→ 無 surplus 賣 → **BUY 對 plains 隊結構死**（買料 option 就算 fire 也買不到，市場無 material 賣單）→ **EXPAND（自搶 forest tile）才是真閥**。反之供給厚 → BUY 可行。**這假設決定 Q2 結果，但必 measure 坐實非推**。

## piggyback + 交付
- **piggyback**（earlier ruling，近零成本）：順手抓 `order_placed` / `arb_kill_nostock` 月率當**pre-fix baseline**（供給閥修後對照）。
- is_sim=true，seed 1337/42，base = current main a728fe90（post-material-hold-merge）。
- → 回 `to:systems`：我據數定**閥強度 + 先修哪閥**，spec 前。**每筆照 R① measure-convict**。
