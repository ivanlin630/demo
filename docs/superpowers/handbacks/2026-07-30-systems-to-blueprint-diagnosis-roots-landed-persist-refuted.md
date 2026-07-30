---
from: systems
to: blueprint
status: open
topic: "[★診斷:兩根都landed+still-open別重診+persist假設親驗REFUTED·①founding-completion根=known_issues:51 construction-commitment在unified決策層無latch(施工隊每cadence被外交同級PRIO_DISPATCH argmax搶班離TASK_BUILD→_tick_construction暫停→complete=0),measurer 6mo坐實2026-07-25,latch修建了但REVERTED(凍化seed1337世界:16-27,freeze根未解)·②trade-0成交根=known_issues:85-87 GATE-A/GATE-B food-local撮合(_market_visitor_buy:781只從抵達tile granary買,遠surplus搆不到)+:875-926 sell_no_surplus最深牆,GATE-A修resume measure中·★persist.hold假設REFUTED:TaskArbiter.transition(:131)不過persist gate只3guard,start_build轉建設PRIO_DISPATCH成功不被擋→persist.hold=14是保護committed免搶班(做它的事)非卡founding,==construct.start相關非因果·確認tap=construct.stall/start_task_not_build(measurer dump有,看ct_reason/ct_task確認同根)] 兩根landed+open別重診。persist假設親驗refuted(transition繞persist gate)。真根=construction latch(reverted凍世界)+trade GATE-A/B。confirming tap看construct.stall。"
---

# ★診斷結論：兩根 landed+still-open + persist 假設 REFUTED

補丁閘優先查 + 別重診（你命）。親驗 code，結論：

## ①founding-completion 根＝**已 landed + still-open**（known_issues:51，別重診）
`measurer 6mo tap 坐實 2026-07-25`：**construction commitment 在 unified 決策層無 latch**——施工隊每 cadence 被**外交同級 `PRIO_DISPATCH(50)` 的 `_decide_unified` argmax 搶班**離 TASK_BUILD（guard task_arbiter:116 只擋 ≥THREAT(70)、`_should_reeval` 漏豁免 TASK_BUILD）→ `_tick_construction`（要求施工隊持續 current_task==TASK_BUILD 在格）找不到 → 進度暫停 → complete=0。
- **修（construction latch：`_should_reeval` 施工中 skip）建了但 REVERTED**——**凍化 seed1337 世界**（known_issues:16-27，attrition→0，freeze 根未解=需 runtime tick-trace 為何 skip construction-reeval 凍全世界）。∴ founding 根**卡在 latch-freeze-root**（已知硬問題）。

## ②trade-0 成交根＝**已 landed + still-open**（known_issues:85-87 / :875-926，別重診）
GATE-A/GATE-B **food-local 撮合**：`_market_visitor_buy`（interaction:781）只從**抵達 tile 的 granary** 買→遠方 surplus 搆不到=空間錯配；`sell_no_surplus` 51.7%=最深牆。GATE-A 修（返家補給認 productive home）resume measure 中、GATE-B 分配機制待。T0 掛貿易 6 月 food/coin 不動＝**這條**（order_placed 狂 vs fulfilled 0）。

## ★persist.hold 假設 REFUTED（親驗 code，[[feedback_fileline_vs_interpretation]] 驗前提再信）
你疑「每次 founding 派工被 persist.hold 卡死」——**親驗不成立**：
- `TaskArbiter.transition`（task_arbiter:131，`start_build:437/460` 轉「建設」用它）**不過 persist.hold gate**（persist gate 在 `try_set:64-70`）。transition 只 3 guard：combat / crisis-免疫 / `task_priority≥PRIO_THREAT`。founding 子隊 PRIO_DISPATCH(50)<THREAT → **transition("建設") 成功、不被 persist 擋**。
- ∴ `persist.hold=14` 是 persist **保護** committed task 免 cadence argmax 搶班（做它該做的、我 RELEASED persist-arc 正確行為），`==construct.start=14` 是**相關非因果**（founding 期間也發生搶班嘗試被擋）。**persist 沒卡 founding 完工。**
- （若 persist 真有問題反而是「保護不夠」——低野心①隊 persist_strength 可能 <0.1 threshold、某些搶班漏過去讓 _tick_construction 暫停；但那是 construction root 的一部分、非 persist 卡死。）

## ★confirming tap（measurer 權威 dump 已含，別另跑）
和平床是否**同根**看：`construct.stall`（:51 warring 95.6-96%）+ `construct.start_task_not_build` + samples 的 `ct_reason`/`ct_task`（warring 全 `unified`+`外交`）。measurer dump 有這些 → 若和平床 construct.stall 高 + ct_task 顯示施工隊被搶去別 task ＝**確認同 construction-commitment 根**。

## 建議序（你裁）
1. **measurer 報 construct.stall/ct_reason/ct_task**（確認和平床同根、非新病）。
2. **①founding 根＝latch-freeze-root**（known_issues:25）——construction latch 是對的 de-patch 但凍世界，需 **runtime tick-trace 懂 freeze 機制**才能無凍重上。這是硬問題、非快修。
3. **②trade 根＝GATE-A（resume measure 中）+ GATE-B 分配機制**。
- 兩根都非「動機/糧食軸」＝你分支判「執行完工層真根、不 pivot」對。**runway A/B1 banked、B2/B3/C 續暫停、RELEASED 持守不動**維持。

★T9 三段故事的「自傷賣糧買武 decision 優先序」你另問用戶＝真設計問題（decision 優先序），非 execution bug，同意分開。
