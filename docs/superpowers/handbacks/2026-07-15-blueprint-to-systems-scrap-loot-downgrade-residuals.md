---
from: blueprint
to: systems
status: consumed
topic: [scrap+降級] 掠奪根fix inert不merge(byte-identical);Team26殘留(day24-26 churn非致命+loot-mismatch連貫死)降backlog/observe-later,停追(rabbit-hole);真thrash根=_evaluate_survival每-tick重觸,備future非urgent
---

# 掠奪根 scrap + Team26 殘留降級（停止 rabbit-hole）

measurer 逐 byte 驗：掠奪根 fix **完全 inert**（Team26 byte-identical，thrash 88/56 不變、死 tick 不變）。**我裁：不 merge，scrap；殘留降級停追。**

## scrap 掠奪根 fix
- inert 根因：target-weighting（`food_est` 進公式但 `FOOD_PULL=1.0` 權重太弱、遠小於 pop_est 量級）+ Team26 危機期只一個候選（無得選）。**方法錯，不 merge。** 分支可棄。

## Team26 殘留降級（rabbit-hole 停損，[[feedback_avoid_rabbithole]]）
逐一判，都非 coherence-critical，**停追**：
1. **day24-26 churn**：真源＝**`_evaluate_survival` 每-tick 重觸**（measurer 定位，legacy，非掠奪選擇）。但**非致命**——Team26 挺過 churn、期間仍行動（有 loot）、**死在 60 天後（day85）**。churn 非死因＝噪音非 bug。→ **backlog**（「survival-latch：`_evaluate_survival` 別同快照重觸」＝原執行鎖意圖但對的層，future 若觀察到 churn 普遍+perf 貴再做，非 urgent）。
2. **loot resource-mismatch**：Team26 死於「搶到料沒糧」，**但 QA 已判此死連貫**（搶了個也沒糧的鄰居＝真實悲劇）。→ **observe-later**（「絕境掠奪要不要優先搶糧＋強化權重」＝desperation-economy arc，若觀察到 raiders 系統性搶不到糧才做）。

**核心判斷**：真正的贏（連貫死＋去幻覺）已在 desperation merge 拿到。Team26 剩的是邊際噪音，我一路把它每個 quirk 當根追（執行鎖→買糧→migration→掠奪）＝對自己犯 rabbit-hole。**停。**

## known_issues 記
- survival-latch（`_evaluate_survival` 同快照重觸）＝non-fatal churn，backlog。
- 絕境掠奪搶糧優先＋權重量級＝desperation-economy arc observe-later。

## 現在方向（用戶批「照你順序」）
掠奪根收攤 → **感知腳位置 god-view = 下個主 arc（另信開）** → full-HD 觀察 → 照妖鏡。求和/外交 grounded 續飛。
