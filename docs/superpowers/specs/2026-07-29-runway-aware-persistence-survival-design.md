# 糧流感知（Food-Flow / Runway Awareness）— WHAT 設計

**日期**：2026-07-29
**owner**：blueprint（WHAT）→ 交 systems 做 HOW
**狀態**：WHAT 定案（待用戶複審 spec）
**精度層級**：乙級（tile-local 內生糧流），非丙級（全地圖糧源搜索）

---

## 0. 一句話

給**每支隊一個「糧流感官」**——隨時（每日一次）知道「這塊地能可持續餵我多少 vs 我在燒多少」，據此判斷該守、該撤、該提早未雨綢繆。把盲目死守變成**算過的賭**，把「等餓死才反應」變成**饑荒前的前瞻**，並順手解掉「子隊遠征立國餓死」。

---

## 1. 病根（為什麼要做）

持守統一 arc 已讓「committed builder 不被非危機搶走」（手不聽腦修好、世界不凍、固執/務實分化）。但 QA 逐 tick 稽核的 nuance 深挖 code 坐實了根：

- **持守盲目**。`persist_strength.gd:44-47`：持守強度 = `PERSIST_CAP(0.3) × 進度(sunk-cost) × 人格lean`——**只讀「已投入多少」+「多固執」，零糧食、零剩餘工期、零 runway**。
- **執行 hold 也盲目**。`task_arbiter.gd:64-70`：committed BUILD 擋掉一切「優先權 < 危機級(70)」搶班，跟糧食多低、候選 util 多高都無關。只被 `PRIO_SURVIVAL(80)` 破（`faction_ai_system.gd:81 CRISIS_FLOOR=1.5`）。
- **更廣的病**：一般隊也**只在快餓死（food≈1.5）才反應**，看不到糧倉慢慢乾的下坡 → 沒有前瞻。
- team14（QA specimen）撐到 food=0 才放手，是「兩條 util 剛好在餓死線交叉」的**盲目巧合**。QA 分佈驗證實它是個案，但揭露的根是真的：**腦（means-end 長程計畫）和手在糧食軸上沒接線**——沒有一個「我糧夠不夠、糧倉在漲還在跌」的感官餵給決策。

## 2. 缺的兩個東西

1. **人格維度**：現在只有 **固執 vs 務實**（多黏），缺 **精明 vs 魯莽**（會不會算風險）。
2. **前瞻**：現在只有「快餓死才逃」的反應式，缺「看到下坡提早未雨綢繆」的計畫式——這正是整條 arc 要的 means-end 腦，在**經濟行為**上現身。

---

## 3. 核心設計：一個感官，每日算，三個消費者

### 3.0 糧流感官（每支隊都有，非存活專用）

每支隊持有一個糧流狀態（快取在 team 上，如同 `team.persist_strength`）：

```
burn/日   = (pop + minor_pop) × 食/人/日 + 坐騎 × 草料/日        （現成，resource_system:126）
inflow/日 = 這塊地「可持續」內生糧產出（見 3.1）
net       = inflow − burn
net ≥ 0 → runway = ∞（在回填）
net < 0 → runway_days = 現有存糧 ÷ (−net)
```

**算的時機（perf）：每日一次（cadence），不是每 tick。** 糧流本來就是「每日」量（burn/regen 都以 day_fraction 結算），算比天更細只是雜訊。用既有決策/rank cadence（persist_strength 已在此 cadence 自算，`persist_strength.gd:12`），在日邊界 snapshot 一次、快取、三消費者當日讀快取。另在**大跳事件**補算（抵達新格 / 人口大變 / 據點蓋好）避免感官過時。

### 3.1 inflow 只算「內生」，外生一律不預測

| | 內生（自己撐得住）| 外生（靠別人）|
|---|---|---|
| 例 | 腳下這格可持續收成、可打的獵物 | 商隊買糧、母隊送糧、盟友接濟 |
| 誰決定它來不來 | **我**（我站這、我採） | **別人**（商隊高興才來） |
| 未來可靠嗎 | 地還在、池還在回補 → 可靠 | **可能再也不來** |

**inflow 只准算內生。外生糧從不以「我預期它會來」進計算——只在真到帳那刻、以「存糧變多」的形式出現（下次算 runway 自然變長）。**

這一刀解掉兩個顧慮：
- **「商隊再也不來」永遠背叛不了隊**——從沒把商隊算進活命線。來了純賺、不來不受傷。
- **「用過去猜未來」怪味沒了**——內生不是「靠歷史重演」，是「地還在」（地形回補是這塊地此刻的性質，非手氣）。故內生讀**「這塊地可持續餵我多少」的前瞻性質**，不讀「上週收了多少」（後者會在把池採乾時高估）。

貿易城也判得對：存糧厚→runway 長→正常；糧道真斷→存糧見底→runway 縮→正確地慌。

### 3.2 三個消費者共用這一個感官

| 消費者 | 用糧流幹嘛 | 接哪裡 |
|---|---|---|
| **① 存活/持守** | 別 committed 到自己撐不住的事（team14 那條）| `persist_strength` 被 `safe_ratio` 調制 |
| **② 派遣/配糧**（離家隊）| 出發前算糧橋 + 載重限（見 §4）| 出發決策 + 半路求生重算 |
| **③ 在家前瞻** | 看到糧倉下坡 → 饑荒前主動擴/立/買/遷 | **既有 `maintain_food` goal 加前瞻觸發**（見 §3.4）|

**立國只是 ② 的極端案例，不是特例機制。**

### 3.3 存活/持守（消費者①）：safe_ratio + 人格餘裕

```
ETA_days   = 還要多久做完（例 construction_ticks_left ÷ TICKS_PER_DAY，現成）
safe_ratio = runway_days ÷ ETA_days
```

`persist_strength` 被 `safe_ratio` 調制（**決策層調 util 偏置，不在執行閘加硬鎖**）：
- safe_ratio 高 → persist 維持 → 守。
- 接近/低於門檻 → persist 塌 → 撤/覓食/搬家。
- **人格 = 餘裕門檻**：慎重厚（~1.5 才安心，早撤）；野心/莽薄（~1.0 甚至更低，貼著賭）。莽夫 runway<ETA 還硬守 → 蓋一半餓死＝**湧現真後果，非 bug**。

**team14 自動判對**：肥沃地 net≈0 → runway ∞ → safe_ratio 爆表 → 放心守到低不誤逃。戲保在「真安全」的地方。

### 3.4 在家前瞻（消費者③）：餵既有 maintain_food goal

means-end 已有 `maintain_food` goal（`goal_registry.gd:16-40`，`holding < need_keep(food)` → active → 自動走前置鏈：買糧/覓食/擴地/立國…）。

**本設計加一個前瞻觸發**：不只「存糧已低」啟動，「**糧流下坡**（net<0 且 runway_days < 計畫視野）」也啟動。→ 隊在饑荒前就把「保糧」列為 active goal，交既有 planner 拆解（擴這格 / 派子隊去別處立國 / 買糧 / 搬家）。

**這是給既有 goal 加感測觸發，不是新 planner。** 一塊地養不起漲起來的人口 → 隊**在饑荒前**主動派立國隊/買糧，而非撐到餓死才逃＝文明該有的前瞻湧現。

---

## 4. 派遣/離家隊（消費者②）：過「糧橋」，立國為極端示範

真正的分界不是「立國 vs 其他」，是「**在食物基地上 vs 離開基地被派出去**」。離家隊（立國/打劫/長途商隊/遠征）都問同一句：**背的糧撐不撐得到做完/回到吃得飽的地方**。

```
橋長       = 路程天數 + 目標工期（立國=蓋據點；打劫=打完回；商隊=賣完回）
過橋淨缺口 = 橋長 × (burn − 沿路內生打獵)     （據點蓋好前無被動收成，resource_system:57-61）
```

### 4.1 出發點：配糧 + go/no-go
```
母隊算過橋要多少糧 → 拿得出 + 背得下 → 配糧出發（runway 從一開始 ≥ 橋長）
                   → 拿不出/背不下 →
                       ├ 帶馬車/馱獸（↑載重）
                       ├ 挑近/綠的路（↓缺口，沿路打獵抵消）
                       ├ 太遠太貧 → 別去 / 之後靠後勤
```
**送死的派遣從一開始就不出發**——直接解掉「子隊遠征半路餓死」那個 PARK 的病。

### 4.2 半路：求生重算，橋真斷才撤
配足的隊出門就餵飽、一路平靜做完、**不神經質**。只有橋**真斷了**（超時/打獵比預期差）才 runway 見底 → 撤回 / 就近併入。**那時撤是正確求生、非 bug，且應罕見。**

### 4.3 載重 = 天然的派遣範圍限制器（現成模型）
`movement_system.gd:137`：`carry_capacity = pop×BASE_CARRY + effective_mounts×MOUNT_BONUS + effective_wagons×WAGON_BONUS`；food 單位重 0.1（`:161`）。能背的糧 = `remaining_carry_space ÷ 0.1`。配糧覆蓋**淨缺口**、受載重限。**馬車/坐騎終於有真用途**（備駝隊才走得遠）。**載重上限 = 「背糧就夠」vs「必須上後勤」的天然分界。**

---

## 5. 範圍（本 spec）與非範圍

**本 spec 做**：糧流感官（通用、每日算、快取）+ 內生-only + 三消費者全接——①存活/持守（safe_ratio×人格餘裕）②派遣/配糧（糧橋+載重，接現成模型）③在家前瞻（餵既有 maintain_food 加前瞻觸發）。**多為現有零件重新接線**（burn、載重、地形回補、打獵、crisis-免疫、persist_strength/lean、maintain_food goal 皆現成）。

**非範圍（後續後勤 arc）**：母隊持續補給車隊（現在沒做，只有出發一次性分家 `subteam_system.gd:36-42`）。**本設計自動接得住**——以後真做了補給，車到＝存糧漲＝runway 自然變長，不用改。後勤專門延長糧橋範圍（超出載重的遠地派遣）。

---

## 6. 憲法對齊

- **utility weigh 非 scripted**：runway 調 `persist_strength`（util 偏置）、餵 `maintain_food`（既有 goal util），非寫死 edge。
- **人格 WEIGH 不 GATE**：safe_ratio 門檻是連續人格權重（慎重厚/莽薄），非硬類別閘。
- **非硬鎖、世界不凍**：糧流感知只讓「該撤/該未雨綢繆時更會動」→ 世界更活、更遠離 latch。
- **全量暫態可觀測性**：糧流狀態（inflow/burn/net/runway/safe_ratio）+ 配糧決策 + maintain_food 前瞻觸發皆須接 tap（撐 QA 逐 tick 故事稽核）。

---

## 7. 開放調參（交 HOW/量測）

- safe_ratio 各人格門檻值（慎重/中性/莽）。
- 在家前瞻的「計畫視野」（runway_days < 幾天算下坡、觸發 maintain_food）。
- 內生 inflow「可持續量」估法（地形回補率 × 採集能力；打獵可持續量）。
- 感官 cadence 的確切 tick 值 + 大跳事件補算清單（抵達/人口/據點）。
- 無收成歷史的隊 warmup（剛到/立國中）→ 地形預期值墊，有真資料切換。
- 沿路打獵抵消缺口估法（route 逐格 or 目的地 proxy）。
- 抖動減震沿用現成（人格餘裕 + `CRISIS_IMMUNITY` 窗）。

---

## 8. 驗過的 premises（供 R② 覆核，非猜）

| 斷言 | 坐實 |
|---|---|
| persist_strength 只讀 sunk-cost + 人格、不讀糧 | `persist_strength.gd:44-47` |
| 執行 hold 是純優先權閘、跟 util/糧無關、只被 ≥PRIO_THREAT(70)/survival 破 | `task_arbiter.gd:64-70` + `faction_ai_system.gd:81 CRISIS_FLOOR=1.5` |
| burn 現成、每日 cadence 結算 | `resource_system.gd:126,108-109` |
| 決策/persist 已在 rank cadence 自算（非每 tick） | `persist_strength.gd:12` |
| 無據點 tile 零被動食、只打獵 | `resource_system.gd:57-61` |
| 載重模型現成（pop+mounts+wagons，food=0.1） | `movement_system.gd:137-140,161` |
| means-end 已有 maintain_food goal + 前置鏈拆解 | `goal_registry.gd:16-40` |
| 母隊補給只有出發一次性分家、無持續 | `subteam_system.gd:36-42` |

---

## 9. 本設計修/接的東西

- 持守 nuance（team14 盲目撐到 food=0）→ 算過的持守。
- 立國可行性（PARK 的子隊遠征餓死）→ 出發點配糧 go/no-go 解掉。
- 新人格軸「精明 vs 魯莽」→ 湧現。
- **經濟前瞻**（饑荒前主動擴/立/買/遷，非撐到餓死才逃）→ means-end 腦在經濟行為現身。
- 後勤補給的必要邊界（超出載重才需要）→ 釐清，留後續 arc。
