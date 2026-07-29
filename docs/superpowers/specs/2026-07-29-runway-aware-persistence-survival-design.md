# 生存 runway 感知的持守（Runway-Aware Persistence）— WHAT 設計

**日期**：2026-07-29
**owner**：blueprint（WHAT）→ 交 systems 做 HOW
**狀態**：WHAT 定案（待用戶複審 spec）
**精度層級**：乙級（tile-local 內生糧流），非丙級（全地圖糧源搜索）

---

## 0. 一句話

讓「持守（committed 死守一個目標）」**會算自己會不會餓死**——用「這塊地能可持續餵我多少 vs 我做完想做的事要多久」判斷該守還是該撤，人格決定留多少安全餘裕。把盲目死守變成**算過的賭**，並順手解掉「子隊遠征立國餓死」。

---

## 1. 病根（為什麼要做）

持守統一 arc 已讓「committed builder 不被非危機搶走」（手不聽腦修好、世界不凍、固執/務實分化）。但 QA 逐 tick 稽核發現一個 nuance，深挖 code 坐實了根：

- **持守是盲目的**。`persist_strength.gd:44-47`：持守強度 = `PERSIST_CAP(0.3) × 進度(sunk-cost) × 人格lean`——**只讀「已投入多少」+「多固執」，零糧食、零剩餘工期、零 runway**。
- **執行層 hold 也盲目**。`task_arbiter.gd:64-70`：committed BUILD 擋掉一切「優先權 < 危機級(70)」的搶班，**跟糧食多低、候選 util 多高都無關**。唯一能破 hold 的是被升到 `PRIO_SURVIVAL(80)` 的生存危機（`faction_ai_system.gd:81 CRISIS_FLOOR=1.5`）。
- **後果**：team14（QA specimen）撐到 food=0 才放手，是「兩條 util 剛好在餓死線交叉」的**盲目巧合**，不是「算過賭得起」。QA 分佈驗證實它是 9 筆裡唯一 1 筆（個案），但揭露的根是真的：**腦（means-end 長程計畫）和手（持守）在生存軸上沒接線**——hold 從不問「我糧夠不夠撐到做完」。

means-end 系統當初就是為「算得完算不完」而建，這條線該接上。

## 2. 缺的行為維度

現在的人格分化只有 **固執 vs 務實**（多黏）。缺 **精明 vs 魯莽**（會不會算風險）。少了後者，「依人格自由發展」缺一整條軸。本設計補的正是這條：精明的算得清、莽的賭過頭**真的會餓死**（湧現的真後果）。

---

## 3. 核心設計

### 3.1 活命線（runway）只算「內生」，外生一律不預測

| | 內生（自己撐得住）| 外生（靠別人）|
|---|---|---|
| 例 | 腳下這格的可持續收成、可打的獵物 | 商隊買糧、母隊送糧、盟友接濟 |
| 誰決定它來不來 | **我**（我站這、我採） | **別人**（商隊高興才來） |
| 未來可靠嗎 | 地還在、池還在回補 → 可靠 | **可能再也不來** |

**活命線只准算內生。外生糧從不以「我預期它會來」進計算——只在真到帳那一刻、以「存糧變多」的形式出現（下次重算 runway 自然變長）。**

這一刀同時解掉兩個顧慮：
- **「商隊再也不來」永遠背叛不了隊**——因為隊從沒把商隊算進活命線。來了純賺、不來不受傷。
- **「用過去猜未來」的怪味沒了**——內生不是「靠歷史重演」，是「地還在」（地形回補是這塊地此刻的性質，不是手氣）。所以內生要讀**「這塊地可持續餵我多少」的前瞻性質**，不要讀「我上週收了多少」（那個會在把池採乾時高估）。

**貿易城也判得對**：平時存糧厚 → runway 長 → 正常運作；糧道真斷 → 存糧見底 → runway 縮 → 正確地慌（一個被切斷糧道的貿易城本來就該慌）。

### 3.2 runway 公式

```
burn/日      = (pop + minor_pop) × 食/人/日 + 坐騎 × 草料/日        （現成，resource_system:126）
inflow/日    = 這塊地的「可持續」內生糧產出（地形回補 × 我採得動的量；打獵可持續量）
net          = inflow − burn
net ≥ 0  → runway = ∞（在回填，隨便守）
net < 0  → runway_days = 現有存糧 ÷ (−net)
```

外生糧（trade/supply/gift）**不進 inflow**。

### 3.3 決策：safe_ratio + 人格餘裕

```
ETA_days    = 還要多久做完（例：construction_ticks_left ÷ TICKS_PER_DAY，現成）
safe_ratio  = runway_days ÷ ETA_days
```

`persist_strength` 被 `safe_ratio` 調制（**在決策層調 util 偏置，不在執行閘加硬鎖**）：

- safe_ratio 高（糧撐得過做完）→ persist 維持 → 守。
- safe_ratio 接近/低於門檻 → persist 塌 → 撤/改覓食/搬家。
- **人格 = 餘裕門檻**：慎重要厚餘裕（safe_ratio ≥ ~1.5 才安心，早撤留活路）；野心/莽薄餘裕（~1.0 甚至更低，貼著賭）。莽夫遇到 runway < ETA 還硬守 → **蓋一半餓死＝湧現真後果，非 bug**。

**team14 自動判對**：肥沃地 net≈0 → runway ∞ → safe_ratio 爆表 → 放心守到很低不誤逃。這齣戲保在「真的安全」的地方。

---

## 4. 立國 = 過「糧橋」（順手解掉 PARK 的子隊餓死）

立國 = 從**母隊糧倉**走到**新據點自己會產糧**那天。中間這段沒自產糧、只靠背的乾糧 + 沿路打獵。

```
橋長        = 路程天數 + 蓋據點天數
過橋淨缺口  = 橋長 × (burn − 沿路內生打獵)        （據點蓋好前無被動收成，見 resource_system:57-61）
```

**同一條 runway 數學用在兩個決策點：**

### 4.1 出發點：配糧 + go/no-go（殺掉送死立國）

```
母隊算過橋要多少糧 → 拿得出 + 背得下 → 配糧出發（runway 從一開始 ≥ 橋長）
                   → 拿不出/背不下 →
                       ├ 帶馬車/馱獸（↑載重）
                       ├ 挑近一點/綠一點的路（↓缺口，沿路打獵抵消）
                       ├ 太遠太貧 → 別立 / 之後靠後勤
```

**送死的立國從一開始就不出發**——直接解掉「子隊遠征半路餓死/到不了」那個 PARK 住的病。

### 4.2 半路：求生重算，橋真斷才撤

配足了的子隊出門就是餵飽的、一路平靜蓋完、**不神經質**。只有橋**真的斷了**（蓋超時、打獵比預期差）才 runway 見底 → 撤回母隊 / 就近併入。**那時撤是正確的求生，不是 bug，且應罕見**（出發前算過）。

### 4.3 載重是天然的立國範圍限制器（現成模型）

`movement_system.gd:137`：
```
carry_capacity = pop × BASE_CARRY + effective_mounts × MOUNT_BONUS + effective_wagons × WAGON_BONUS
food 單位重 = 0.1（movement_system:161）
能背的糧 = remaining_carry_space ÷ 0.1
```

配糧覆蓋**淨缺口**、受 `remaining_carry_space` 限。**馬車/坐騎終於有真用途**（立國隊備駝隊才走得遠）。**載重上限 = 「背糧就夠」vs「必須上後勤」的天然分界。**

---

## 5. 範圍（甲，本 spec）與非範圍（後勤，後續 arc）

**本 spec 做（甲）**：runway 數學 + 內生-only 活命判斷 + 人格餘裕 + 出發點糧橋配糧（接現成載重/馬車模型）+ 半路真斷才撤。**多為現有零件重新接線**（burn、載重、地形回補、打獵、crisis-免疫、persist_strength/lean 皆現成）。

**非範圍（後續後勤 arc）**：母隊持續補給車隊（現在沒做，只有出發一次性分家 `subteam_system.gd:36-42`）。**乙 自動接得住**——以後真做了補給，車到＝存糧漲＝runway 自然變長，不用改本設計。後勤專門延長糧橋範圍（超出載重的遠地立國）。

---

## 6. 憲法對齊

- **utility weigh 非 scripted**：runway 調制 `persist_strength`（util 偏置），非寫死 edge。
- **人格 WEIGH 不 GATE**：safe_ratio 門檻是連續人格權重（慎重厚/莽薄），非硬類別閘。
- **非硬鎖、世界不凍**：runway 感知只讓「該撤時更會撤」→ 世界更活、更不凍（比現況更遠離 latch）。
- **全量暫態可觀測性**：runway/inflow/safe_ratio/配糧決策皆須接 tap（新 decision/state 必觀測，撐 QA 逐 tick 故事稽核）。

---

## 7. 開放調參（交 HOW/量測）

- safe_ratio 各人格門檻的確切值（慎重/中性/莽）。
- 內生 inflow 的「可持續量」估法（地形回補率 × 採集能力的具體式；打獵可持續量）。
- 無收成歷史的隊 warmup（剛到新地/立國中）→ 用地形預期值墊，有真資料後切換。
- 沿路打獵抵消缺口的估法（route 逐格 or 目的地 proxy）。
- 抖動減震沿用現成（人格餘裕 + `CRISIS_IMMUNITY` 窗）。

---

## 8. 驗過的 premises（供 R② 覆核，非猜）

| 斷言 | 坐實 |
|---|---|
| persist_strength 只讀 sunk-cost + 人格、不讀糧 | `persist_strength.gd:44-47` |
| 執行 hold 是純優先權閘、跟 util/糧無關 | `task_arbiter.gd:64-70` |
| hold 只被 ≥PRIO_THREAT(70)/survival 破 | `task_arbiter.gd:66` + `faction_ai_system.gd:81 CRISIS_FLOOR=1.5` |
| burn 現成 | `resource_system.gd:126` |
| 無據點 tile 零被動食、只打獵 | `resource_system.gd:57-61` |
| 載重模型現成（pop+mounts+wagons，food=0.1） | `movement_system.gd:137-140,161` |
| 母隊補給只有出發一次性分家、無持續 | `subteam_system.gd:36-42` |

---

## 9. 本設計修/接的東西

- 持守 nuance（team14 盲目撐到 food=0）→ 變成算過的持守。
- 立國可行性（PARK 的子隊遠征餓死）→ 出發點配糧 go/no-go 解掉。
- 新人格軸「精明 vs 魯莽」→ 湧現。
- 後勤補給的必要邊界（超出載重才需要）→ 釐清，留後續 arc。
