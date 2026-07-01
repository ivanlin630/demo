# 覓食 = 苟活地板（產出 capped、繁榮須交易）— 讀 B arc

> 系統 HOW spec。承藍圖 `econ-floor-readingB`（🟡 判定=讀 B：站穩須交易環）+ `a-milestone-go-parallel`（轉平行、讀 B 推經濟沙盒維度）。
> WHAT（藍圖，settled）：**覓食 = survival floor（產出 capped、餵不起繁榮成長）；surplus/繁榮須交易。** 延伸早先「覓食限 pop≤15」→ 擴成「覓食=苟活地板非 growth engine」。**非 nerf 覓食決策權重補丁、非 nerf 地形 regen。**

## 診斷（measured + 碼證，確定）

覓食-換糧環（`econ-floor` 8cbd1d8 merged：返家 home-empty gate + has_specie 納特產）已修結構閘，但 **trade loop 仍沒 fire**。真根不在交易入口，在 **覓食本身無產出上限 → 自足碾壓交易需求**：

1. **覓食產出無 cap**：`hunt_small_game`（`hunt_system.gd:9-22`）`FOOD_PER_GAME=12` → 累 `forage_today` → `flush_forage_episodes`（`resource_system.gd:193-209`）入 team food。唯一限制 = `wild_game` tile 枯竭/regen（item 5）+ pop≤15 eligibility guard（`FORAGE_VIABLE_POP=15`，`faction_ai_system.gd:59`；`options.gd:48` 只 gate「是否 offer 覓食 option」，**非產出量**）。
2. **覓食食物直接餵成長**：`reaction_system.gd:201` `surplus_ok = effective_food(state,t) > pop*2.4*7.0` → 覓食入 `effective_food`（`resource_system.gd:354`：team food + 自家 granary）→ 可推 `surplus_ok`=true → breed（`P5_breed`，minor_population+1）。
3. 結果：小群覓食不只苟活，**能囤 surplus → 繁榮成長 → 永不需交易**。特化-交易網無題材、G3 貿易戰沒地基（貿易戰要先有貿易）。

## 修（覓食 = 純地板，不碰地形 regen、不碰決策權重）

**核心 seam：覓食產出 net-bank 上限 = 餬口（餵當日消耗），surplus 不入可累積食物。** 覓食只能撐今天的嘴，長大的 surplus 只能來自 granary（定居 tile harvest / 貿易換糧）。

### A. 覓食 subsistence cap（產出端，不 nerf 單次 yield）
- **不改 `FOOD_PER_GAME` / regen / hit chance**（保覓食單次真實、保地形 regen）。
- 改 **覓食對可累積食物的淨貢獻上限**：team 的覓食來源食物（forage_today flush）**只補到 subsistence buffer**（`SUBSIST_BUFFER = pop × FOOD_PER_PERSON_PER_DAY × FORAGE_FLOOR_DAYS`，TEST VALUE，`FORAGE_FLOOR_DAYS≈1~2`）。超過 buffer 的覓食產出**不 bank**（`wild_game` 亦不消耗 → 留給 regen，不浪費世界資源、不憑空生食）。
- 效果：覓食隊食物 latch 在苟活線；想過線囤 surplus → 覓食給不了 → 須 granary（harvest/貿易）。

### B. 成長 surplus 只認可累積食物（覓食不驅動 breeding）
- A 落地後，覓食食物 net 停在 subsistence → 自然無法推 `surplus_ok`（surplus 定義 = 超 7 日存糧）。**A 是主 seam，B 是驗收面**：驗 breeding surplus 只由 granary（定居/貿易）餵，非覓食。
- 若量級沒乾淨切（覓食 buffer 仍偶推 surplus），fallback：`reaction_system` growth 的 `effective_food` 換成「排除純覓食來源的可累積食物」= granary-only surplus test（plan 定，傾向 A 的 buffer cap 夠、不動 growth 公式）。

### C. 地形特化差（自動保留、非新增）
- **plains 定居**：outpost harvest regen 8 → granary 填得起 → 原生繁榮成長（不靠交易）。
- **forest/mountain 定居**：regen 3/0.5 → granary 薄 → 想繁榮須賣木/礦換糧（`econ-floor` 換糧環現有題材）。
- **無據點/游走隊**：`collect_resources`（`resource_system.gd:48`）無據點零被動 → 只覓食 → subsistence 地板封頂 → 想長須定居或交易。
- = 特化↔交易互賴網真轉，覓食不再是萬用 growth engine。

## believability（守藍圖 guard）
- **不 nerf 地形**：REGEN_RATE 不動（forest food 3、material 12 特化保留）。
- **不 nerf 覓食決策權重**：`terms.gd` forage util 不動（覓食該做時仍做，只是產出封頂）。修在**產出真實性**（採野果餵小群可信、致富不可信）非決策偏壓。
- **driver-complete**：覓食 driver 仍 = 求生取食；cap 不改 driver，只改世界產出上限。

## 驗收（修完自驗）
- **覓食隊**：食物 latch 在 subsistence（pop 小群苟活、不無限囤糧、不靠覓食 breed 成長）。
- **繁榮須交易**：forest/mountain 定居隊繁榮成長只在賣特產換糧 fire 後出現（trade loop 真轉、非覓食自足）；plains 定居仍原生繁榮（harvest）。
- **戰國 seed**：覓食隊不再無交易自足膨脹；特化-交易網（forest 賣木、plains 賣糧）可見；trade loop fire（`econ-floor` 換糧環在覓食封頂後有需求驅動）。
- **不 nerf**：REGEN_RATE 碼不改、forage util 權重不改。
- **守恆**：coin_eq delta=0、pop 守恆、1000+ tick 無錯、framework S1-S6 PASS。超 buffer 覓食不 bank 且不耗 wild_game（不憑空生/滅食物）。

## 檔案
- `scripts/simulation/resource_system.gd`：`flush_forage_episodes`（193-209）或 `hunt_small_game` 累積端加 subsistence cap（forage net-bank ≤ `SUBSIST_BUFFER`；超額不 bank、不耗 wild_game）。常數 `FORAGE_FLOOR_DAYS`。
- `scripts/simulation/hunt_system.gd`：若 cap 落在產出端（`forage_today` 累積前查 buffer），改此；傾向 cap 在 flush（team 級 buffer 好算）。
- `scripts/simulation/reaction_system.gd`：B fallback only（若 A 沒乾淨切，growth surplus test 排除覓食來源）—傾向不動。
- `scripts/debug/headless_test.gd`：新測（覓食隊食物 latch subsistence、不 breed；定居/貿易隊才 surplus 成長）。
- 驗證：`warring_states_seed` + `econ_bed.json` 變體重跑（覓食隊不膨脹、trade loop fire、plains 仍繁榮）。

## 風險 + 緩解
- **subsistence buffer 量級**（太低=覓食隊餓死潮、太高=仍自足）：TEST VALUE，戰國 seed 校 `FORAGE_FLOOR_DAYS`（1~2 起）。先驗覓食隊苟活不死、也不膨脹。
- **cap 誤傷定居隊**（定居隊也覓食）：cap 只封覓食來源食物；定居隊 granary（harvest）不受 cap → 仍繁榮。確認 cap 作用在 forage_today/flush 非 granary。
- **wild_game 不消耗的世界效果**（超 buffer 不獵 → wild_game 少枯竭）：正面（世界資源不被無效耗）；守恆上憑空生/滅=0（不 bank 且不耗）。
- **trade loop 仍不 fire**（覓食封頂但換糧入口另有閘）：`econ-floor` 已修返家/has_specie 兩閘；若仍不 fire = measure（別猜），可能 buyfood weight 需提（`econ-floor` spec §C 已標 TEST VALUE）。
- **scope**：只 resource/hunt cap + 測（+ reaction fallback if needed）。**不碰 REGEN_RATE、不碰 forage util 權重、不碰戰鬥/P1/交易數學**。

## 開放細節（plan 定）
- cap 落點：`flush_forage_episodes`（team 級、好算 buffer）vs `hunt_system` 累積端（單次 granular）。傾向 flush（team subsistence buffer 一次算）。
- `SUBSIST_BUFFER` 定義：`pop × FOOD_PER_PERSON_PER_DAY × FORAGE_FLOOR_DAYS` vs 對定居隊是否額外寬鬆（傾向統一公式，pop 已含定居隊、buffer 不誤傷因 granary 另計）。
- `FORAGE_FLOOR_DAYS` 值（1 = 純當日餬口、2 = 小緩衝）；seed 校。
- B fallback 是否需要（傾向 A 的 buffer 夠、growth 公式不動）。
