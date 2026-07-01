# B 食物張力（R1 供給 cadence + R2 flow-not-stock）— 設計 spec

> 系統 HOW spec。承藍圖 `trio-rulings`（B 食物給致富牙、**目標張力非死亡**、bed 驗每步）+ granary 定位 `granary-rootcause-cadence`。
> **前提已就位**：致富錨接上（首燒 merged，獨立商隊有致富 intent）→ 現食物壓力有意義（缺食→交易換糧→致富驅動有牙）。
> **鐵律（藍圖）**：目標=**張力（獲取值得）非死亡（餓死潮）**。**別 nerf 地形 regen 常數**（forest 仍 3，只修 cadence bug 讓它真 per-day）。bed 驗每步。

## 診斷（碼證，確定）
供需 cadence 24× 不對稱：
- **regen**（`resource_system.gd:78`）+ **harvest**（`_collect_from_tile:222`）**未 day_fraction 縮放**、每小時全速。
- **consumption**（`:91,108`）**有** day_fraction。
- → 供給 24× 快於需求 → forest 秘密 net-positive → 超額 trap 進封頂 granary（爆倉）→ growth 讀 `effective_food`(stock 含 granary，`reaction_system:201`)→「糧倉滿」驅動成長,不靠 flow。

## 修（兩層耦合，張力校準）

### R1 — 供給側對齊 day_fraction（修 cadence bug，非 nerf）
- `regen`（:78）+ `harvest`（:222）乘 day_fraction（與 consumption 同 cadence 基準）→ forest 真 3/day、marginal。**常數不改**（REGEN_RATE forest 3 保留，只是不再秘密×24）。
- **這是 economy-wide（全地形供給÷24）→ 大 rebalance**。**張力校準（核心）**：re-tune 食物常數使**不 mass-starve 但食物真稀缺**——plains 原生繁榮（regen 8/day 夠自足小成長）、forest/mountain 苟活須交易繁榮。TEST VALUE，bed 逐步校。

### R2 — 成長吃 flow 非 stock
- `reaction_system:201` surplus gate：`effective_food(stock)` → **持續盈餘 flow**（近窗 收入>消耗，如「日均 net food > 0 持續 N 日」）。不靠 stale 滿倉。
- 需一個 flow 訊號：team 日均食物淨變（收入[harvest+trade]−消耗）over rolling window。落 team 欄或算子（plan 定）。
- 效果：forest 定居隊 granary 不再靠爆倉驅動成長;想繁榮須 net flow 轉正 = 賣特產換糧（致富 intent 驅動）。

### 校準目標（bed 驗每步）
- forest 苟活隊：不餓死潮、pop 苟活線;**想長必須交易**（覓食 capped[已 merged] + regen 修正[R1] + flow gate[R2] → 無交易長不了）。
- plains 定居：原生繁榮（regen 8 夠）。
- **致富錨驅動交易真有牙**：specimen 商隊 致富 intent → 賣木買糧 → net flow 轉正 → 繁榮。tracer 復驗「致富→交易→成長」鏈。
- **張力非死亡**：每步 bed 量餓死率（不得成潮）+ 交易網轉（trade loop fire）+ pop 能長（交易後）。

## believability / 守恆
- 不 nerf 地形常數（修 cadence bug）。特化↔交易互賴網真轉。
- 守恆：coin_eq（全池,含 coin slice）0、pop 守恆、framework S1-S6 PASS、warring 不 mass-starve。

## 檔案
- `resource_system.gd`：regen(:78)/harvest(:222) day_fraction 對齊;食物常數 re-tune（TEST VALUE）。
- `reaction_system.gd`：growth surplus gate 改 flow（:201）;flow 訊號算子。
- `ambition_ladder.gd`：surplus_need gate 若讀 stock 亦改 flow（:45-56）。
- `team_data.gd`：flow window 欄（如 food_flow_avg，若需）。
- `scripts/debug/`：econ_bed 逐步校 + warring 不 mass-starve 驗 + specimen 致富→交易→成長 復驗。

## 風險 + 緩解
- **★mass starvation（最大風險）**：R1 供給÷24 若不配 re-tune → 餓死潮。**緩解=bed 逐步校、每步量餓死率、張力非死亡為硬驗收**。先 R1 小地圖 bed 校常數穩,再 warring。
- **flow 訊號雜訊**（單日淨變抖）→ rolling window 平滑（N 日均）。
- **與單寫者/征服 measure 並行**：本軌碰 resource_system(經濟函數)/reaction(growth)/ambition — **不碰** resource_bank ledger(單寫者)/roster/faction_ai intent(首燒已 merged)/combat_target。單寫者軌碰 resource_bank 不碰 resource_system 經濟函數 → 不同檔/函數。
- **scope**：食物 cadence + growth flow + 校準。**不碰** tile-granary-bank（單寫者後 slice）、決策/戰鬥。

## 開放細節（plan 定）
- flow window 長度 + 「持續盈餘」門檻（TEST VALUE）。
- re-tune 哪些常數（FOOD_PER_PERSON / breed 門檻 / provision buffer / regen 校準值）。
- R1+R2 上線序（傾向先 R2 flow gate 較安全[不改供給量]、再 R1 cadence[配 re-tune]；或先 R1 小 bed 校穩。plan 定）。
