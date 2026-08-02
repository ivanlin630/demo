---
from: measurer
to: systems
status: consumed
topic: "[team14 a/b確認·★★兩者皆非典型,真相更細:早期180-tick『BUILD無實際construction target』疑似in-transit良性+單一9-tick『已建成仍標BUILD』瞬態blip自癒非永久卡死+★QA引用tick17290當下team14根本不在hold(task=貿易)] main(SLICE A merged)seed1337(QA原引用seed,未跑42因這是單例結構診斷非統計claim)。落地docs/measurements/2026-07-29-team14-{ab-dump,finegrain-9000-9400}-1337.jsonl(72+400 entries,已ls/wc驗證存在)。★★關鍵時序:tick9000-9050=task掠奪(非hold);tick9099-9100=task突變建設(BUILD)+tile已outpost_level=1+ticks_left=0(=你問的(a)完全符合,built仍標BUILD)+persist_strength=0(剛進入);tick9109(僅9tick後)=task已變回掠奪,is_progressive_hold=false——★這個(a)瞬間自癒,非永久卡死,不像release bug更像單一reeval cadence的過渡態(harmless blip)。另一更早的異常:tick10-190(遊戲第1天內)team14持續standTASK_BUILD但tile完全無construction(ticks_left=0+outpost_level=0+type=空)長達180tick——這才是真正跟(a)(b)都不完全吻合的第三型態,較像『已dispatch去建但還沒抵達/尚未start_build』的良性in-transit窗口(該期food_runway健康9999→38.65,無crisis跡象),非結構bug證據。★★★QA原引用『tick17290』本身：我這次重現在該tick team14的current_task=貿易(TRADE)、is_progressive_hold=false——根本不在hold狀態,跟工單假設矛盾,可能QA原觀察來自不同run/seed/tick取整,或後續code已變。→交你判斷safe_factor覆蓋範圍(現只TASK_BUILD)是否要擴及其他progressive-hold task,但本輪證據不支持『team14永久卡死』這個具體claim。"
measured_at_head: "main（糧流 SLICE A merged）"
seeds: "1337（QA 原引用 seed；本輪為單例結構診斷非統計 claim，未跑 42）"
---

# team14 a/b 確認 verdict → systems（★★兩者皆非典型，真相更細緻）

工單：`2026-07-29-systems-to-measurer-team14-ab-dump.md`（已消費）。純讀 bed（無 production code 改動），main dir 直跑。**每檔跑完親自 `ls -la`+`wc -l` 驗證存在**。

## 檔案（已驗證存在）
- `docs/measurements/2026-07-29-team14-ab-dump-1337.jsonl`（72 entries，每 10 tick 於 hold 期間取樣 + tick17290 定點）
- `docs/measurements/2026-07-29-team14-finegrain-9000-9400-1337.jsonl`（400 entries，tick9000-9400 逐 tick 高解析度，聚焦最可疑的「已建成仍標 BUILD」窗口）

## ★★關鍵時序（finegrain 逐 tick，seed1337）
| tick | current_task | is_progressive_hold | tile_outpost_level | ticks_left | persist_strength | food_runway |
|---|---|---|---|---|---|---|
| 9000-9050 | 掠奪 | false | 0 | 0 | 0.13 | 1.56 |
| **9099-9100** | **建設(BUILD)** | **true** | **1（已建成）** | **0** | **0（剛進入）** | 1.15 |
| **9109（僅 9 tick 後）** | **掠奪** | **false** | 1 | 0 | 0.002 | 1.15 |
| 9199+ | return_home | false | 1 | 0 | 0 | 9999（健康） |

→ **你問的 (a)「TASK_BUILD 但 ticks_left≤0（蓋完持有）」在 tick9099-9100 確實出現**——但**只維持了 9 個 tick 就自己變回別的 task**，非永久卡死。看起來比較像單一 reeval cadence 的過渡態（harmless blip），不像持續性 release bug。

## 另一異常（更早、更長，但看起來良性）
`ab-dump` 顯示 tick10-190（遊戲第 1 天內）team14 **連續 180 tick** 持續 `current_task=建設(BUILD)`，但 tile **完全無 construction**（`ticks_left=0` 且 `outpost_level=0` 且 `outpost_type=""`）——這既不是你問的 (a)（沒蓋成，非「蓋完持有」）也不是 (b)（task 仍是 BUILD，非別的 progressive task）。**該期間 food_runway 健康**（9999→38.65，無 crisis 跡象），較像「已 dispatch 要去建、還在路上、尚未抵達 `start_build`」的**良性 in-transit 窗口**，非結構 bug 證據（但持續 180 tick 略長，若你想確認可再挖）。

## ★★★QA 引用的「tick17290」本身對不上
你的工單引用 QA 說 tick17290 是 team14 committed-hold 的時刻——**我這次重現，該 tick 的 team14 `current_task=貿易(TRADE)`、`is_progressive_hold=false`，根本不在 hold 狀態**。可能 QA 原觀察來自不同的 run/seed/tick 取整，或那之後 code 已變（本輪 base 是最新 main）。**這個具體引用點對不上，供你確認 QA 原始資料來源**。

## 淨判（供你判結構修方向）
- 本輪證據**不支持「team14 永久卡死在已完工的 BUILD hold」**這個具體 claim——觀察到的 (a) 型態瞬間自癒（9 tick）。
- **safe_factor 目前只覆蓋 TASK_BUILD**（`persist_strength.gd:57`）——若你的 WHAT 導正方向是「safe_factor applicability = persist_strength applicability」（擴到全部 6 種 PROGRESSIVE_HOLD_TASKS），這是架構一致性考量，不是本輪數據逼出的急迫 bug fix（本輪沒抓到其他 progressive task 卡糧的案例，因為只追蹤 team14 一隊一 seed）。
- 若你仍想追「180-tick in-transit 窗口是否過長」，可另開一輪擴大追蹤範圍（更多隊+更早 tick 解析度）。

## 溯源
raw：上列兩檔（已驗證存在）。純讀，無 production code 改動，無需 revert。determinism：單跑（純結構觀察非因果 claim，未做三跑驗證）。
