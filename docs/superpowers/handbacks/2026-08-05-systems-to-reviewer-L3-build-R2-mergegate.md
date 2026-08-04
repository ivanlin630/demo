---
from: systems
to: reviewer
status: consumed
topic: "[R² merge-gate 審 L3 循環貿易實作(feat/L3-circuit-trade 06c8b452、HOW spec R² 你上輪 CLEAN、現審 build diff 對 spec 一致+無新問題才過 merge-gate)·實作:①_nearest_market_outpost naive→genuine _best_market_target visit-util(gain[arb+staleness]×archetype − trip×慎重、gain/cost 分離)②team_market_last_read store(read_market_board 到場 stamp、未讀=stale MAX 探索未知)③options 貿易 applicable += has_market_visit_value(settled 產隊進得去、cadence 快取 perf)·★calibration DERIVED(trip=/MERCHANT_MAX_RANGE、stale=/SCOUT_TIMEOUT、arb=/100)非 fire-crank(你上輪輕追蹤=錨真值,查交代依據)·gate:l3_test 6/6+headless 0-new(修 archetype gain-only modulate+抓 per-gather harvest 迴歸 cadence-gate)+constitution 74+determinism 31B85CC9 byte-identical(≠baseline=trade 真改)·審點:感知鐵律(visit-util 讀 belief staleness/heard-arb reuse best_arbitrage_order belief-only、非市集 live stock)/naive helper 保留買料 caller 不動/主 argmax 非平行機制/人格 modulate 真值·R² CLEAN→measurer 量(遠距跨勢力 deal>0+訪市人格分化 per-option util dump)→QA→systems merge·ledger build implementer 續·地基 KEEP"
---

# R² merge-gate 審 L3 循環貿易實作

HOW spec R² 你上輪 CLEAN → implementer build 完（`feat/L3-circuit-trade` `06c8b452`）→ **R² merge-gate 審 build diff**（對 spec 一致 + 無新問題才過）。

## 實作（對 HOW spec 三塊）
- 塊①`_nearest_market_outpost` naive → genuine `_best_market_target` visit-util（`gain[arb+staleness] × archetype − trip × 慎重`、gain/cost 分離）。
- 塊② `team_market_last_read` store（`read_market_board` 到場 stamp、**未讀=stale MAX** 探索未知市集）。
- 塊③ `options 貿易.applicable += has_market_visit_value`（settled 產隊進得去、cadence 快取 perf）。
- naive helper 保留給買料 caller（`_nearest_market_outpost_with` 不動）。

## gate 全綠
l3_test **6/6** + headless **0-new**（修 archetype gain-only modulate + 抓 per-gather harvest 迴歸並 cadence-gate）+ constitution **74** + determinism **31B85CC9 byte-identical**（≠baseline=trade 行為真改）。

## 審點
- **感知鐵律**：visit-util 讀 belief（staleness = `team_market_last_read` 自我記憶 / arb = reuse `best_arbitrage_order` belief-only、你上輪親驗過只讀 received orders），**非市集 live public_storage 真值**。
- **★calibration DERIVED**（你上輪輕追蹤）：`trip=/MERCHANT_MAX_RANGE`、`stale=/SCOUT_TIMEOUT`、`arb=/100`——查交代錨定依據、非反推調到剛好 fire。
- 主 argmax（訪市=body 移動、非平行「訪市」機制）；人格 modulate 真值非 crank。

## 序
R² CLEAN → measurer 量（**遠距跨勢力 deal>0 + 訪市人格分化** per-option util dump、含 settled 經濟床/rep 床）→ QA（長跑故事）→ systems merge。ledger build implementer 續。地基 KEEP。
