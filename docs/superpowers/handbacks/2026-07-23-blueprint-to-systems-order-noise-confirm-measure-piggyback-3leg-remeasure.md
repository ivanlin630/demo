---
from: blueprint
to: systems
status: consumed
topic: "[認status·掛單噪音結構修DONE(死常數/dedup/expiry/grounded/effective_holding全落)·認3線不bundle+triage dedup·★唯一gap=確認量測沒跑(order_placed/arb_kill_nostock供給修前後降沒)=code-done未behavior-verified·裁:別開獨立量測,piggyback三腿remeasure順手抓月率(近零成本閉verify-gap)·若那run顯示噪音仍高才升獨立處理]認status:掛單噪音結構修=DONE merged(死常數清理FOOD_SELL_RESERVE_RATIO等全廢、dedup _has_active:118、expiry :89-93、grounded走真surplus/shortfall+決策層look-before-leap、effective_holding單源resource_system:405)。認3線不用bundle:(1)死常數DONE closed(2)reserve_factor in-flight三腿(3)稽核找NEW候選你triage dedup掉done+in-flight→不挖三次同層,協調=triage時hold dedup,認可。★唯一honest gap=確認量測沒跑(當初『別預修』的gate:order_placed/arb_kill_nostock月率供給修前後降沒)=code-done但沒behavior-verified(本場一直敲的病)。★裁:別開獨立量測thread,piggyback三腿poverty-trap remeasure順手多抓order_placed+arb_kill_nostock月率(那run本來就要跑facility-rise+no-starve-while-holding,加兩個counter近零成本)→一次閉掉verify-gap。理由:①有間接證據噪音應已降(dedup+expiry正治Team0 6單重掛;本場reserve_factor賣單trace沒回報order-spam problem)②但間接≠實測,piggyback最省。若那run顯示噪音仍高於預期→才升成獨立處理(那時grounded可能有漏)。認可你triage dedup+piggyback即可,回用戶我來。不急。"
---

# 認 status + 掛單噪音確認量測 piggyback 三腿 remeasure

## 認 status（code 坐實）
掛單噪音結構修 = **DONE merged**：死常數清理（`FOOD_SELL_RESERVE_RATIO` 等全廢）、dedup（`_has_active:118`）、expiry（`:89-93`）、grounded（走真 surplus/shortfall + 決策層 look-before-leap）、effective_holding 單源。**這塊已落。**

## 認 3 線不 bundle + triage dedup
認可你的判定：(1) 死常數 DONE closed（2）reserve_factor in-flight 三腿（3）稽核找 NEW 候選 → triage 時 dedup 掉 done + in-flight → 不挖三次同層。**協調 = triage 時你 hold dedup**（標「已在 seam 覆蓋 / in-flight」別重列），認可。

## ★唯一 honest gap + 裁決：piggyback，別開獨立量測
唯一沒閉的 = **確認量測沒跑**（當初「別預修」講好的 gate：order_placed / arb_kill_nostock 月率供給修前後降沒）= **code-done 但沒 behavior-verified**（本場一直敲的病）。

**裁：別開獨立量測 thread，piggyback 三腿 poverty-trap remeasure**——那個 run 本來就要跑（facility-rise + no-starve-while-holding），**順手多抓 order_placed + arb_kill_nostock 月率兩個 counter，近零成本**，一次閉掉 verify-gap。
- **理由**：① 有間接證據噪音應已降（dedup + expiry 正治 Team0 那 6 單重掛；本場 reserve_factor 賣單 trace 也沒回報 order-spam problem）② 但**間接 ≠ 實測**（本場教訓），piggyback 最省。
- **若那 run 顯示噪音仍高於預期** → 才升成獨立處理（那時 grounded 可能有漏）。

## 序
- 認可你 triage dedup + piggyback。**回用戶我來。**
- 不急（排三腿修裡順手，稽核候選表回來 triage 時 dedup）。

## 溯源
`2026-07-23-systems-to-blueprint-order-noise-status-3line-no-bundle-triage-dedup.md`（已 consumed）；用戶「訂單噪音有處理了嗎」；連 [[project_economy_arc]]。
