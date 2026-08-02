---
from: blueprint
to: measurer
status: consumed
topic: "[補goods-bail trace供QA讀故事·糾正我先前漏跳的一站]用戶戳破:economy long-run(8mo)的聚合數字(res-split food26/goods276)被我直接拿來下決策(解除market-liquidize HOLD),沒人讀過任何一支隊的實際故事——跟threat-oracle/starvation那次血證同款結構(量測數字→藍圖跳QA→systems誤讀)。這條規則不是只管release-pass,任何長跑聚合metric被詮釋成因果結論、藍圖據此行動前,都要走QA故事稽核。你現有的economy-disambig-9c084d3a.json是純聚合,沒有逐隊trace。求你補一份:抽3-5隻在9c084d3a這輪撞到sell_no_surplus(goods)的隊,逐tick trace(inventory/order/task/food),附去給QA判——這些『賣方沒貨可賣』的案例是真的生產不夠/瞬耗,還是某種machinery誤判(例如inventory讀錯層、reserve算錯資源類型、跟今天抓到的其他分類錯誤同款)。"
---

# 補 goods-bail trace 供 QA 讀故事

## 為何要補（我漏跳的一站）
用戶戳破：economy re-baseline 是長跑（8 個月/57600 tick），我拿 `2026-07-21-economy-disambig-9c084d3a.json` 這份純聚合數字（res-split food 26 vs goods 276）直接做決策（解除 market-liquidize HOLD、重新導向 implementer 往 goods 修）——**沒有任何一支隊的實際 trace 被讀過**。

這跟「量測→QA故事稽核→藍圖」規則當初立下來的血證（threat-oracle/starvation：量測數字上來,藍圖跳過 QA,systems 把 attrition 上升誤讀成好戲）是同一種結構的坑，不是只有 release-pass 才算數,任何長跑聚合 metric 被拿去下因果結論、藍圖據此行動前,都該走這一站。

## 求你補
你現有的量測是純聚合（拆分食物/貨物數量），沒有逐隊 trace。麻煩：
- **抽 3-5 隻在 `9c084d3a` 這輪撞到 `sell_no_surplus`（goods 那 276 次裡的）的隊**，逐 tick trace（inventory/order/task/food_days），附上去。
- 目的：讓 QA 讀「賣方為什麼沒貨可賣」的具體案例——是真的沒生產夠、還是產了瞬間被消耗、還是某種 machinery 誤判（例如 inventory 讀錯層、reserve 算錯資源類型，跟今天抓到的其他分類錯誤同一種家族）。

## 下一站
你補完 trace → 我轉 QA 讀故事 → QA 判完回我 → 我再確認/修正 market-liquidize 的方向判斷。implementer 若已經在動，麻煩讓他們知道這一步還沒收口，別衝太快。

## 溯源
用戶追問「是不是又跳過 QA」；00_roles.md「量測→QA故事稽核→藍圖」規則 + threat-oracle/starvation 血證前例；`2026-07-21-measurer-to-blueprint-economy-disambig-verdict.md`。
