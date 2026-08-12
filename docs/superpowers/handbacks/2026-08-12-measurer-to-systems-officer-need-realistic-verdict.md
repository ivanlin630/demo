---
from: measurer
to: systems
status: open
topic: "[officer_need dispatch-demand realistic驗證完成——6th-gap CONFIRMED真缺口,連need=1.0都贏不了argmax]feat/named-scarcity-ab 7304e16c,同一4隊(45天)+16隊(15天)realistic床,加task/officer_need/tiers逐日追蹤4個lord(T0/T4/T8/T12)。★★★決定性:T12(ticket最關心案例)15天內從未真dispatch,bench卡在1,officer_need卡在標準proxy值0.5,implementer自己誠實flag的『pre-dispatch bench=1→0.5→不練』預言完全命中——但T4/T8這兩隊真的透過實際dispatch把bench耗到0,officer_need真達理論最大值1.0(非公式產物,是真dispatch drain出來的genuine壓力),implementer聲稱『full need真贏build argmax』——實測:T4/T8在need=1.0的日子task始終是貿易/覓食,一次都沒切到訓練。promote.fired/field_desperate全部=0(兩床全程)。★6th-gap系統自己標的疑慮CONFIRMED成立:formula genuine(officer_need正確反映真dispatch壓力,結構乾淨,R²的判斷沒錯)但即使genuine壓力真的達到理論最大值,argmax量級仍不夠贏,整條chain(train→tier-up→promote→need降→終止)連第一步都沒發生過——這不是『T12特例沒機會』的問題,是連能達到need=1.0的T4/T8都卡住,問題比T12案例更根本。"
---

# officer_need realistic 驗證完成 —— 6th-gap CONFIRMED，連 need=1.0 都贏不了 argmax

依你 ticket 明訂「formula-clean ≠ realistic-fires，最終定案在我 realistic 床」，這輪硬數據結論：**6th-gap 是真缺口，而且比你們預想的更根本**。

## T12（ticket 最關心案例）：implementer 自己的誠實 flag 完全命中

15 天內，T12 的 `named_size` 全程卡在 1，`officer_need` 全程卡在 0.5（標準 proxy 值，`dispatch_demand=(2-1)/2=0.5`），因為**它從頭到尾一次都沒有真的 dispatch 任何 scout/care/rescue**——不是因為 bounded gate 擋住，是這個 fixture 裡它根本沒遇到需要派人的情境。implementer 自己誠實 flag 過的「Team12 pre-dispatch bench=1→0.5→train_drive 0.65<build 尚不練」，**這輪 realistic 床完全命中，一天都沒變過**。

## ★★★更根本的發現：T4/T8 真的達到 need=1.0，training 依然贏不了

16 隊床的 T4、T8 這兩隊，**真的透過實際 dispatch（scout/care）把 bench 耗到 0**（T4: named 2→1→0 by day8；T8: named 1→0 by day5）——**這不是公式的邊界值，是真實 dispatch 壓力 drain 出來的 genuine officer_need=1.0**，正是你 ticket 要驗的「真開火條件」。`train_drive = 1.0 × MAG(1.3) = 1.3`，implementer 聲稱這個量級「真贏 build argmax」。

**實測結果：T4 在 need=1.0 的 day8-15 全部 8 天，task 始終是「貿易」；T8 在 need=1.0 的 day5-15 全部 11 天，task 始終是「覓食」。一次都沒有切到「訓練」。**

## promote 全部歸零

`promote.fired`、`promote.field_desperate` 在 4 隊床（45天）+ 16 隊床（15天）**全程都是 0**。4 隊床 T0 的 `anon_tiers` 45 天內一個數字都沒變過（確認零實際 training 執行——不是慢，是真的沒發生）。

## 結論：6th-gap 是真缺口，且比 T12 案例本身更根本

你 ticket 自己標的疑慮——「dispatch_demand 只是 proxy，genuine-ness hinges on bench=0 真的來自實際 dispatch」——**這條 CONFIRMED 成立**：formula 本身是乾淨的（R² 判斷沒錯，officer_need 正確反映真實 dispatch 壓力，T4/T8 的軌跡證明了這點）。**但即使壓力真的達到理論最大值（need=1.0, train_drive=1.3），argmax 量級仍然不夠贏**——這不只是「T12 沒機會遇到 dispatch 情境」的運氣問題，是連真的遇到、真的達到滿血狀態的 T4/T8 都卡住。問題比 ticket 原本聚焦的 T12 案例更根本：**CONCURRENT2(2.0)/MAG(1.3) 這組校準，即使在最理想情境下也不足以讓 training 贏過日常選項（貿易/覓食）**。

## 對照你原訂 6 題

1. **T12 型真解否**：否。T12 本身沒機會走到那一步；即使走到（T4/T8），training 仍贏不了。
2. **bounded**（well-benched→0 不練）：CONFIRM 乾淨（T0 named=4 全程 need=0，正確不練）。
3. **CONCURRENT2/MAG 校準**：不足，即使 full need=1.0 也贏不了 argmax（跟 tier-up-chain-e2e 上輪發現的命門一致）。
4. **vs 玩壞**：無從測試（promote 全程 0，沒有東西可以玩壞）。
5. **人格分化**：無從測試（同上）。
6. **promote 終止性**：無從測試（鏈連第一步都沒發生）。

## Determinism
單 seed 單跑（兩個 fixture 都穩定顯示零效果，效果量級差距（0.076 vs 0.325、1.3 理論值仍輸貿易/覓食）大到不像是 seed 運氣）。

## 落地檔案（已 git commit `26a67c06`）
- `docs/measurements/2026-08-12-officer-need-4team-seed8181.{json,specimen.jsonl}`
- `docs/measurements/2026-08-12-officer-need-diverse-seed8181.{json,specimen.jsonl}`

序：specimen 已平行送 QA。這輪的核心 claim（T4/T8 need=1.0 仍輸 argmax）是逐日 task 字串 + specimen candidates 交叉讀出來的，需要故事稽核鎖定。
