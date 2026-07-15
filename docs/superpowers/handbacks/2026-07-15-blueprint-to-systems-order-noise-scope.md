---
from: blueprint
to: systems
status: consumed
topic: [經濟arc+項·用戶抓] 掛單噪音=另一問題(539-850單/月+撮合空轉數千aborts);churn家族(掛買不到賣不掉的單還一直重掛);供給seam修後量噪音降多少+剩的用掛單紀律(grounded-order/dedup/expiry)治
---

# 掛單噪音（用戶抓）：納入經濟 arc

用戶抓:供給 seam 外,**掛單本身是噪音**——`order_placed` 539-850/月、`arb_call` 數千/月、`arb_kill_nostock` 8372-20331/月。**就算供給修好,這量還是噪音。**

## 這是 churn 家族又一個
Team0 常駐 6 張單（買武器×6/買糧×26/賣料×30/買礦×2種）**跨 tick 不變、每 cycle 重數/重掛** → 撮合引擎狂空轉。**同 flee 每 tick 重 commit、買糧幻覺重試同精神:掛了成不了的單還一直重掛。**

## 兩層（供給修後才分得清）
1. **供給 seam 修後可能自消一部分**:有貨可撮→單成交清掉→常駐 spam 減。（像 flee 修好 N1_flee 回落。）
2. **剩的獨立 churn**:隊不管有沒有貨/買不買得起,照掛 20-50 張/月/隊 → 需**掛單紀律**：
   - **grounded-order**（掛單版 look-before-leap）：買不到（無賣方）/賣不掉（無買方）/付不起（coin 不足）的單**別掛**。跟我們一路修的「別選做不成的」同一套。
   - **dedup**：常駐單去重（別每 cycle 重掛同一張）。
   - **expiry**：過期單清（掛太久沒成交 release）。

## 納入經濟 arc scope
供給 seam 第一刀 → 重跑時**順帶量掛單噪音降多少**（order_placed/arb_kill_nostock 供給修後回落?）→ 剩的獨立 churn 用掛單紀律治（可同刀或下一刀,看噪音組成）。

## 為何一起
掛單噪音 + 供給 seam 都是「市場經濟」的病,同 arc。而且掛單紀律（grounded-order）跟結構稽核的 grounded-ness 家族同精神——**訂單也是一種「決策/行動」,該 grounded**。

## 下一站
系統供給 seam spec 時**把掛單噪音量測納驗收**（供給修前後 order_placed/fulfilled/arb_kill_nostock 對比）→ 看噪音是供給下游還是獨立 churn → 定掛單紀律要不要同刀。回我。
