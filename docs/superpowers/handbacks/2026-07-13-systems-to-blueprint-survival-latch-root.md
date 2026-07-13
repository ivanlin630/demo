---
from: systems
to: blueprint
status: open
topic: [零跑結論] cadence gate有接非bug;但追的餓隊被另一把鎖(survival-latch:_evaluate_survival早退+PRIO_SURVIVAL擋主rank)——cadence修DISPATCH-tier沒碰survival-tier;真根+推薦
---

# 零跑結論：cadence 有接，但餓隊被 survival-latch（另一把鎖）

## 1. cadence gate 沒 bug、真的接上（你假設①/②排除）
- `_evaluate_solo` gate 改寫正確：`_due = current_tick >= decision_eval_next_tick`，初值 0→首次即 due，之後 +DECISION_CADENCE(1日)。邏輯健全、無符號/單位錯。
- rank_scored **每日真的跑**（gate 放行）。**非 wiring bug、非 due 邏輯錯**。

## 2. ★但追的餓隊被 survival-latch 鎖（cadence 沒碰的另一把鎖）
被追的 Team7/Team12 都是**餓隊**（pop 掉到 1=持續缺糧）→處 survival-latch，**兩重鎖**：
- **`_evaluate_survival:3023-3028`**：
  ```
  if team.current_task in SURVIVAL_TASKS:
      if days_left >= SURVIVAL_RECOVER_DAYS(7): release   # 只在糧恢復才釋放
      return                                              # 已在 survival→一律 early-return
  ```
  `_trigger_survival`(rank_survival 重選 survival option)在 `:3032`，**在 3028 early-return 之後**→**已在 survival 的隊永不重選**。餓隊覓食失效→days_left 永低→永不到 RECOVER→**永鎖 forage 直到死**（沒機會換買糧/掠奪/併入/移動）。
- **`try_set:42` + `_trigger_survival:3127` PRIO_SURVIVAL(80)**：survival task 設 prio 80；`_evaluate_solo` 主-rank 重評 dispatch PRIO_DISPATCH(50)<80→try_set 失敗→no-op。即使 cadence 放行 rank_scored，換不動 survival task。

∴ **cadence 重構修的是 PRIO_DISPATCH-tier 鎖**（生產/駐守/建設 等常態隊,PRIO_DISPATCH 同層 self-replace 可重評=有效）；**沒碰 survival-tier 鎖**（餓隊）。**你追的餓隊正是沒被修的那類**——所以看不到改善,但非 cadence 沒接,是餓隊走另一條被鎖的路。

## 3. 真根（餓隊 90 天鎖死）= survival-latch 不重選 survival option
Team7 覓食 90 天=餓隊卡 survival-latch:forage 一直失效(pop 降)卻永不換策略。**cognitive 隊該在 forage 失效時試買糧/掠奪/併入/移動**,但 3023 early-return 鎖死首選 survival option 直到糧恢復(永不)。

## 4. 附：trace 可見性（次要）
solo 路(`_evaluate_solo` 迴圈)**無 `SpecimenTracer.capture_decision`**（只 _decide_unified/3131 有）→ 純 solo 隊決策 trace 可能 under-count（capture_options 設 scratch 但不 append entry）。measurer「1 次決策」部分或受此影響。建議補 capture_decision 到 solo 路（純觀測）以正確驗重評頻率。

## 判斷請求（推薦）
- **cadence 重構(T-cad1/2)不作廢**:它修 PRIO_DISPATCH-tier(生產/駐守/建設)重評,對非-餓常態隊有效。**建議先 trace 一支非-餓 PRIO_DISPATCH 隊確認 cadence 對它們生效**(隔離證明),再定 survival-tier 修法。
- **真根修=survival-latch 重選**:`_evaluate_survival` 對「已在 survival task 且仍餓(days_left<WARNING)且 cadence 到」→**重跑 `_trigger_survival`(rank_survival 重選)**,而非 early-return。讓餓隊 forage 失效時換買糧/掠奪/併入。這是 cadence 概念延伸到 survival 路(可納本 slice T-cad 或新 task)。
- **序**:①先 trace 非-餓隊隔離證 cadence 生效(measurer,+補 solo capture_decision 可見性)②survival-latch 重選修(我出增補,R②,dispatch)。

裁：①先隔離證 cadence 對常態隊生效 + 補 trace 可見性,再 ②survival-latch 修?還是直接併 survival-latch 修入本 slice?我推薦①→②(先證 cadence 半邊有效、隔離變因,再攻 survival 半邊),避免兩鎖混一輪難歸因(同 R② 拆 T-cad3 精神)。

零跑至此(code 審 _evaluate_solo/_evaluate_survival/try_set/_trigger_survival,無跑 sim)。等你裁序。
