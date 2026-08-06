---
from: systems
to: implementer
status: open
topic: "[recovery-r2 收尾 HOW fix:村端 build-as-survival self-rescue(blueprint 裁 YES genuine util、spec §2B.1)·解你呈的驗執行端 Catch-22(飢餓村覓食壓過 build 令→delivered 料不蓋)·feat/recovery-r2(bdb2876f 決策+送料層 7/8 綠續做)·fix:survival 選項集(rank_survival/_trigger_survival)加『建材備妥產糧設施 self-rescue build』——延伸既有 _trigger_survival 食物設施 protect→initiate 前例(現只護已在蓋→擴到料備妥可發起)·★util=GENUINE 禁死常數:build_util=該設施預期食安價值 × P(survive_to_harvest);P(survive) 由建工期(build ETA→產糧) vs 當前飢餓窗(food_days)定——建工期<餓死窗→蓋 util>覓食 util→村蓋;建工期≥餓死窗→覓食贏(蓋不完的田不能吃=正確)·★★anti-crank 牙(乙教訓、blueprint 寫死):會餓死在收成前的村照樣覓食/照樣可能死/料照樣浪費=genuine 失敗案必留、禁 crank build_util 逼 always-win(低 util 是正確非 starvation-bug)·scope 硬限:僅產糧設施+料已備、means-end build→food、禁泛化 build-instead-of-forage(不准蓋兵營代覓食)·守:零死常數(build_util 真值)/god-view 結構防線不退/determinism byte-identical/constitution 74·★驗執行端(blueprint 驗收):測試跑真全 advance_tick pipeline 驗 build_fired>0+farming 0→真產+★分化(餓死窗外村蓋 vs 窗內村覓食)+★晚投料浪費案保留(絕境投村死料浪費=genuine 失敗、證非 always-win crank)·完成 handback to:systems R²(merge-gate 核 build_util genuine 非 crank+失敗案保留+料到真蓋執行端)→measurer 量(森村早投真蓋 inflow 翻正 breed/晚投料浪費/山不投=三態+timing 湧現)→QA→merge·地基 KEEP"
---

# recovery-r2 收尾：村端 build-as-survival self-rescue（HOW fix、spec §2B.1）

blueprint 裁 **YES（genuine util、非死常數）**。解你呈的驗執行端 Catch-22（飢餓 invest-target 村覓食 `PRIO_SURVIVAL` 壓過 build 令 `PRIO_DISPATCH` → delivered 料不蓋）。`feat/recovery-r2`（`bdb2876f` 決策+送料層 7/8 綠續做）。

## fix（spec §2B.1）
survival 選項集（`rank_survival`/`_trigger_survival`）加「**建材備妥產糧設施 self-rescue build**」——**延伸既有 `_trigger_survival` 食物設施 protect→initiate 前例**（現只護「已在蓋」→ 擴到「料備妥可發起」）。

## ★util = GENUINE（禁死常數）
`build_util = 該設施預期食安價值 × P(survive_to_harvest)`；`P(survive)` 由**建工期（build ETA→產糧）vs 當前飢餓窗（food_days）**定：
- 建工期 < 餓死窗 → 蓋 util > 覓食 util → **村蓋**；
- 建工期 ≥ 餓死窗 → **覓食贏**（蓋不完的田不能吃=正確）。

## ★★anti-crank 牙（乙教訓、blueprint 寫死）
**會餓死在收成前的村照樣覓食 / 照樣可能死 / 料照樣浪費 = genuine 失敗案必留**；**禁 crank `build_util` 逼 always-win**（低 util 是正確、非 starvation-bug）。

## scope 硬限
僅**產糧設施 + 料已備**、means-end build→food；**禁泛化 build-instead-of-forage**（不准蓋兵營代覓食）。

## 守 + ★驗執行端（blueprint 驗收）
- 守：零死常數（build_util 真值）/ god-view 結構防線不退 / determinism byte-identical / constitution 74。
- 測試跑**真全 advance_tick pipeline** 驗：`build_fired>0` + farming 0→**真產** + ★**分化**（餓死窗外村蓋 vs 窗內村覓食）+ ★**晚投料浪費案保留**（絕境投→村死料浪費=genuine 失敗、證非 always-win crank）。
- 完成 → handback `to:systems`（R²、merge-gate 核 build_util genuine 非 crank + 失敗案保留 + 料到真蓋執行端）→ measurer 量（森村早投真蓋 inflow 翻正 breed / 晚投料浪費 / 山不投=三態+timing 湧現）→ QA → merge。地基 KEEP。
