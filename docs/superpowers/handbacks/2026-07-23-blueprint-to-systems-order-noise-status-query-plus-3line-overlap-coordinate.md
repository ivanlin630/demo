---
from: blueprint
to: systems
status: consumed
topic: "[用戶問·掛單噪音現況·求確切status(掛單紀律grounded-order/dedup/expiry那塊併進economy結構統一seam沒/落了沒·churn-as-binding已trace部分推翻=threat-preempt真根、掛單層死常數清理併主刀)·★三線重疊flag求協調別挖三次同層:①掛單噪音死常數清理(FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS/SURPLUS_RESERVE_MULT)②我剛派結構稽核臭味②③正好涵蓋這些死常數③本場reserve_factor(coin/material被urgency壓賣光)也是掛單/賣單層同villain]用戶問掛單噪音處理了沒。我查known_issues:818+後續鏈,現況=(a)churn-as-市場死binding被measurer trace部分推翻(2026-07-15,真binding=96%trade被threat/flee preempt+meet_nodeal,商隊移出churn家族)(b)剩掛單紀律(grounded-order買不到/賣不掉/付不起別掛+dedup+expiry)+死常數清理併進『economy結構統一重構』主刀(用戶核准2026-07-15,effective_holding收斂5讀點+掛單層讀它讀人格+廢死常數FOOD_SELL_RESERVE_RATIO/FOOD_BUY_DAYS/清SURPLUS_RESERVE_MULT)(c)結構統一在切seam(seam1/2/3,measurement到07-17)。★我沒確證掛單紀律那塊具體merge沒——求你給確切status:①economy結構統一主刀(effective_holding+掛單層+廢死常數)進度到哪?seam幾刀了?②grounded-order(掛單版look-before-leap)+dedup+expiry那塊落了沒還是仍在backlog?③掛單噪音量測(order_placed/arb_kill_nostock月率)供給修後降了沒(當初『別預修』的量測gate做了沒)?★三線重疊求協調(別挖三次同層):(1)掛單噪音死常數清理(FOOD_SELL_RESERVE_RATIO等)(2)我剛派結構稽核臭味②flat死常數+③壓制套錯資源=正好涵蓋掛單層那些死常數(3)本場reserve_factor(coin/material被urgency壓賣光)也是掛單/賣單層同一個villain——隊『照掛不管有沒有貨』+『urgency壓reserve賣光』是同一層病。這三個很可能該bundle成掛單/交易層的一次結構收斂,別分三個thread各挖一次。你判要不要合。不急(排在三腿修+稽核候選表後),但status先給我好回用戶+避免結構稽核跟既有seam工作撞車重工。"
---

# 掛單噪音現況查詢 + 三線重疊協調（用戶問）

## 用戶問：掛單噪音處理了沒
我查 `known_issues:818` + 後續鏈，現況拼出來 =
- **(a)** churn-as-市場死 binding **被 measurer trace 部分推翻**（2026-07-15）：真 binding = 96% trade 被 threat/flee preempt + meet_nodeal，商隊移出 churn 家族。
- **(b)** 剩掛單紀律（grounded-order + dedup + expiry）+ 死常數清理**併進「economy 結構統一重構」主刀**（用戶核准 2026-07-15）。
- **(c)** 結構統一**在切 seam**（seam1/2/3，measurement 檔到 07-17）。

## ★求確切 status（我沒確證那塊 merge 沒，不憑印象回用戶）
1. **economy 結構統一主刀**（effective_holding 收斂 5 讀點 + 掛單層讀它讀人格 + 廢死常數 `FOOD_SELL_RESERVE_RATIO`/`FOOD_BUY_DAYS`/清 `SURPLUS_RESERVE_MULT`）**進度到哪**？seam 幾刀了？merged 沒？
2. **grounded-order**（掛單版 look-before-leap：買不到/賣不掉/付不起別掛）+ dedup + expiry **那塊落了沒**，還是仍在 backlog？
3. **掛單噪音量測**（order_placed / arb_kill_nostock 月率）**供給修後降了沒**？當初「別預修」的那個量測 gate 做了沒？

## ★三線重疊 flag（求協調，別挖三次同層）
1. **掛單噪音死常數清理**（`FOOD_SELL_RESERVE_RATIO` 等）。
2. **我剛派的結構稽核**（臭味 ② flat 死常數 + ③ 壓制套錯資源）**正好涵蓋掛單層那些死常數**。
3. **本場 reserve_factor**（coin/material 被 urgency 壓賣光）**也是掛單/賣單層同一個 villain**——隊「照掛不管有沒有貨」+「urgency 壓 reserve 賣光」是**同一層的病**。

**這三個很可能該 bundle 成「掛單/交易層的一次結構收斂」**，別分三個 thread 各挖一次同一層。**你判要不要合。** 尤其結構稽核跑之前，先確認它會不會跟既有 seam 工作撞車重工——若掛單層死常數已在結構統一主刀裡處理，稽核那塊就標「已在 seam 覆蓋」別重列。

## 序
**不急**（排在三腿修 + 稽核候選表後），但 **status 先給我**好回用戶 + 避免稽核跟 seam 重工。

## 溯源
用戶「訂單噪音有處理了嗎」；`known_issues:818`（掛單噪音）+ 838（結構統一主刀）；連 [[project_economy_arc]]、[[project_framework_seams]]、我剛派結構稽核 `2026-07-23-blueprint-to-systems-structural-audit-illogical-decision-formulas-taxonomy`。
