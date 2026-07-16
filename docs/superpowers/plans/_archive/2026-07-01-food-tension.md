# Plan — B 食物張力（R1 cadence + R2 flow）

> spec = `specs/2026-07-01-food-tension-design.md`。**張力非死亡,bed 驗每步**。
> 前置：headless 基準 PASS + coin_eq(全池) 0 記下。econ_bed baseline（forest/plains pop 曲線）記下。

## Task 1 — R2 flow-not-stock growth（先做,較安全不改供給量）
- flow 訊號：`team_data` 加 rolling food net（日均 收入−消耗 over N 日,或算子）。
- `reaction_system:201` surplus gate `effective_food(stock)` → **持續盈餘 flow**（net>0 持續 N 日）。`ambition_ladder:45-56` surplus_need 同改若讀 stock。
- **測**：純覓食隊(net~0)不成長;有 trade net 隊成長。
- **bed 驗**：econ_bed forest 定居隊——granary 滿但 net~0 → **不再爆倉驅動成長**（stock 不再驅動）。plains net>0 仍長。
- **DoD**：growth 讀 flow;覓食/爆倉不驅動成長;bed 證定居 forest 停爆倉成長、plains 仍長。

## Task 2 — R1 供給 cadence 對齊（配 re-tune,bed 逐步）
- `resource_system:78`(regen)+`:222`(harvest) 乘 day_fraction（與 consumption 同基準）。**REGEN_RATE 常數不改**。
- **★張力校準（核心,bed 逐步）**：R1 後全地形供給÷24 → re-tune 食物常數（TEST VALUE）使 **plains 原生繁榮**（regen 8/day 夠小成長）、**forest/mountain 苟活須交易**、**不 mass-starve**。小 econ_bed 逐常數校,每步量餓死率。
- **DoD**：小 bed forest 苟活不死、無交易長不了;plains 繁榮;**餓死不成潮**（張力非死亡硬驗）。

## Task 3 — 致富錨→交易→成長鏈驗（specimen）
- specimen_bed merchant：致富 intent → 賣木買糧 → net flow 轉正 → 繁榮。tracer 復驗「想=致富→做=貿易→net>0→成長」全鏈接上。
- **DoD**：致富驅動交易**有牙**（食物壓力使交易 matter、成長來自交易 net 非爆倉）。

## Task 4 — 活世界驗（不 mass-starve + 交易網轉）
- warring seed（bg）：不 mass-starve（餓死率有界）、trade loop fire（交易網真轉,前 econ-floor 沒 fire 的真閘=granary 現修）、非 plains 隊靠交易繁榮、pop 能長。
- **DoD**：warring 不餓死潮 + 交易網轉證 + 誠實標經濟維度 emergence（「繁榮須交易」到不到）。

## Task 5 — 守恆閘
- headless PASS≥基準、coin_eq(全池)0、pop 守恆、framework S1-S6 PASS、無 GDScript 錯。

## 不碰（scope + 並行 guard）
- tile-granary-bank（單寫者後 slice）、resource_bank ledger（單寫者軌）、roster、faction_ai intent、combat_target。**只碰 resource_system 經濟函數 + reaction growth + ambition + team_data flow 欄 + bed**。

## 完成
- handback：R1+R2 落地、張力校準結果（餓死率/交易網轉/pop 曲線）、致富→交易鏈有牙、**誠實標**經濟維度 emergence 到不到 + mass-starve 有無。
- ⚠ 與單寫者/征服 measure 並行同觸 reaction_system 不同函數 → 系統 merge 序解。
