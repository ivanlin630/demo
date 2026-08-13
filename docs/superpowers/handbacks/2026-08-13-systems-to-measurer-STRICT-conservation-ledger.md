---
from: systems
to: measurer
status: open
topic: "[★一次到位·嚴格食物守恆帳(Q1)+Q2建設trace(用戶正當發火:禁擠牙膏、ledger 必 close 才報、抓 -75.6% dominant drain 真兇)·SUPERSEDE 併入 9resident-income-attribution(其 4 項=本帳子集)·★命門洞見先講(可能溶解 Q1 前提):harvest income→GRANARY(harvest_intake_vault resource_system:288)非 team.food;eat 先扣 team.food(:139)再 granary(:142)→resident team.food 只出不進單調枯竭 but 食物只搬去倉=redistribution;★若 -75.6% 量 Σteam.food(不含倉)→『不可能斜率』溶解成 pool-artifact 非真 sink·∴ledger 第一件事=分 pool 量·Q1 嚴格帳(必 close):t0 四數分解(Σteam.food/Σgranary 全tile public_storage.food/Σtile-pool 全tile food regen/GRAND)→逐日四 pool 各斜率(★哪個崩 -75.6%? team.food[redist 嫌疑] vs GRAND[真 sink]=定 Q1 生死)→per-tap 逐日流(用 record_driver reason/Probe.bump 勿 temp-diag 猜):INFLOW(GRAND+)=pool regen+hunt+forage;TRANSFER(net-0)=harvest_intake_vault/harvest_intake/provision_carry/provision_granary_out/bridge_topup/upgrade_bootstrap/aid_out;SINK(GRAND-)=eat_team/eat_granary/eat_depleted/eat_granary_depleted/readiness_food/stable_feed/stable_breed_feed/vault_overflow_drop/erase-蒸發/join_onboard_meal+player_aid(driver 驗 headless=0)→close check ΔGRAND==ΣINFLOW-ΣSINK(transfer 抵消)、關不起=漏 tap 先補再報禁報片段→dominant drain rank 抓真兇·★erase-蒸發特別 tap(我 code-read 坐實 world_state:355 teams.erase 直接丟 team dict、team.food+該隊 granary 不 route=conservation break):逐 erase snapshot dropped food+查 merge/absorb(anon_tier/interaction)是否 pre-route food 給 absorber 才 erase(若否=merge 也蒸發)、量級對照 pop-1.8%/merge4 判 dominant 否·★eat_depleted 驗(resource_system:148/150 set 0.0):driver 量==歸零前 available? 超吃則 sink·Q2 建設 trace(倉富村盈餘期為何 0 build):specimen 一 resident village granary≥門檻逐日 dump 建設(options:42)/自救建田(:61)/升級 util+applicable+落選 winner;建設 util=idle_employ_value(有 idle PRODUCE labor? expected output? material-gated 料備否?)→定 genuine(無料無閒=雞生蛋 layer2)vs bug·禁 fix 禁 crank 禁預設·官方 specimen helper 勿手設 team_ids(observer-neutrality)·ledger 必 close 才回報·output→systems 收口單一完整故事(Q1 pool-decompose 答+Q2)→blueprint 一次帶用戶·地基 KEEP"
---

# ★一次到位·嚴格食物守恆帳（Q1）+ Q2 建設 trace

用戶正當發火：**禁擠牙膏、ledger 必 close 才報**、抓 -75.6% dominant drain 真兇。
本帳 **SUPERSEDE** `2026-08-13-systems-to-measurer-9resident-income-attribution.md`（其 4 項=本帳子集，別分開跑）。
禁 fix、禁 crank、禁預設 [[feedback_resource_depletion_genuine_vs_blind]]。

## ★★命門更新（systems code-read 坐實、這是 Q1 頭號假設、先量這個）
**-75.6% 量的是 bed `total_food`（phase3 bed:209）= Σ `effective_food(t)`。** `effective_food` = `team.food + own_granary.food`（resource_system:417）—— **BUT** `own_granary_tile`（:398-402）**只在團站在自己據點 tile 上才回該倉**（要求 `team.tile_pos == 據點 tile` AND `outpost_owner == team.team_id`，否則回 `null`→granary 計 0）。
- ∴**團一離家（覓食/travel/任務移動）→ 自家倉糧從 `effective_food` 蒸發**（食物物理沒動、還在倉、只是沒團站上去 census 時被算）。
- ∴bed `total_food` = **location-dependent undercount**：世界一個月團四散移動 → 越來越多團 census 時不站家 → total_food 系統性下滑。
- ★★**頭號假設：-75.6% 主要是 census-位置 artifact、非物理餓死**（若成立=用戶 Q1「兩月抽乾、不可能斜率」溶解——本就不是真實體流失）。
- ★附帶：`effective_food` **也是決策讀者**（:404「決策讀者單源」）→ resident 離家即「看不到自家倉」→ 誤判餓 → SURVIVAL_BOOST→覓食（可能真行為 bug、非只量測）。
- ∴**ledger 主對照 = bed total_food（Σeffective_food、位置相依）vs TRUE 物理 grand-total（見下、ownership/位置無關）**。GAP = 這個蒸發量。

### 先講的次要層（redistribution，仍列）
harvest income→GRANARY（`harvest_intake_vault` resource:288）非 team.food；eat 先扣 team.food（:139）再 granary（:142）。此層在 effective_food 內已抵消（含 own_granary），但只在站家時；離家則 team.food 見底=雙重觸發誤判。

## Q1 嚴格守恆帳（帳必須 close）

### ① t0 四數分解
`Σteam.food` / `Σgranary`（全 tile `public_storage.food`）/ `Σtile-pool`（全 tile food regen pool）/ **GRAND**（三者和）。

### ② 逐日：bed total_food vs TRUE grand-total（★頭號對照、定 Q1 生死）
同一時點畫兩條線：
- **bed `total_food`** = Σ `effective_food(t)`（=複現 -75.6% 那條、位置相依）。
- **TRUE 物理 grand-total** = `Σteam.food` + `Σ全 tile public_storage.food`（**每個 tile 的倉、不管誰站上去/誰 own**）+ `Σtile-pool food`。
- ★**GAP = TRUE − bed = census 蒸發量**（食物物理在倉但沒團站上去被算）。
- **判定**：若 TRUE grand 平/緩降、bed total_food 崩 -75.6% → **Q1 溶解**（假 sink=census 位置 artifact）；若 TRUE grand 也崩 → 真 sink、進 ③④⑤ 抓兇。
- 附：也分 `Σteam.food` / `Σ全倉` / `Σtile-pool` 各線（看食物在哪層）。

### ③ per-tap 逐日流（用 `record_driver` reason / `Probe.bump`，**勿 temp-diag 猜**）
- **INFLOW（GRAND +）**：pool regen（pool_set/regen reason）、`hunt`、forage。
- **TRANSFER（GRAND net-0）**：`harvest_intake_vault`(pool→倉)、`harvest_intake`(pool→team)、`provision_carry`/`provision_granary_out`(team↔倉)、`bridge_topup`/`upgrade_bootstrap`(team↔vault)、`aid_out`(team→team)。
- **SINK（GRAND −）**：`eat_team`/`eat_granary`/`eat_depleted`/`eat_granary_depleted`(消耗)、`readiness_food`(備戰 interaction:112)、`stable_feed`/`stable_breed_feed`(繁殖 outpost:196/212)、`vault_overflow_drop`(倉滿溢 resource:293)、**erase-蒸發**、`join_onboard_meal`+player_aid（driver 驗 headless=**0**）。

### ④ close check
`ΔGRAND == ΣINFLOW − ΣSINK`（transfer 抵消）。**關不起來 = 有漏 tap 沒抓 → 先補 tap 再報，禁報片段。**

### ⑤ dominant drain rank
排序 SINK 量級 → 抓 -75.6% 真兇（**若 GRAND 真崩**；若只 team.food 崩見 ②=非真兇）。

### ⑥ erase-蒸發 特別 tap（我 code-read 坐實）
`world_state:355 teams.erase(dtid)` 直接丟 team dict、**team.food + 該隊 granary 不 route** = conservation break。
- 逐 erase 事件 snapshot dropped food（erase 前 team.food + 其 owned tile granary）。
- 查 merge/absorb 路徑（anon_tier / interaction absorb）是否 **pre-route food 給 absorber 才 erase**（若否 = merge 也蒸發）。
- 量級對照 pop −1.8% / merge 4 → 判 erase 是否 dominant（疑量小、但要數字坐實）。

### ⑦ eat_depleted 驗（resource_system:148/150 set 0.0）
池耗盡→team.food+granary set `0.0`（非扣 food_needed）。driver 量 `eat_depleted` == 歸零前 available？ 若歸零量 > 該 tick 該吃量 = 超吃 sink（守恆破）。tap 確認（疑 genuine：available<needed 本吃不夠、set 0=吃光剩餘=守恆，但要坐實）。

## Q2 建設 trace（倉富村盈餘期為何 0 build/upgrade）
specimen 一個 resident village granary ≥ 門檻（開局 800 surplus 期），逐日 dump：
- **建設**(options:42) / **自救建田**(:61) / **升級** option 的 util + applicable + 落選 winner。
- 建設 util = `idle_employ_value`(:44 雇閒 PRODUCE 勞力於待建產能真期望產出)：有 idle PRODUCE labor? expected output value? material-gated（料備否 ctx）?
- → 定 Q2 **genuine**（無料/無閒勞=established-chain 雞生蛋 layer2）vs **bug**（有料有閒卻 util 輸）。禁預設。

## fold（9resident 4 項併入本帳）
9resident task 序列 / income 拆分（`harvest_intake_vault` vs `harvest_intake` vs `hunt`）/ granary 累積 / team47 對照 = 本 ledger 的 team.food-vs-granary 分解 + harvest tap 的自然子集。terrain 42 據點产能 vs 355/day = ③ INFLOW capacity 對照。**全跑一份、別分批。**

## 紀律
禁 fix、禁 crank、禁預設。官方 specimen helper 勿手設 team_ids（observer-neutrality [[feedback_observer_no_global_rng]]）。**ledger 必 close 才回報**、關不起先補 tap。
output → systems 收口**單一完整故事**（Q1 pool-decompose 答 + Q2）→ blueprint **一次**帶用戶。地基 KEEP。
