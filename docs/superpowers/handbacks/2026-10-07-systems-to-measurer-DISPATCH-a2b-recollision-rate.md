---
from: systems
to: measurer
status: open
slice: A2b 前置量測：貿易到場零成交的「同一市集重撞」率（決定值不值得做、學在哪一層）
topic: 樹＝當下 origin/main（印 sha）；seed 1337／2024／7，30 天；純讀不改世界、觀測不耗 RNG
---
```
每支 seed 印：
①到場零成交事件（TASK_TRADE、trade_arrived 為真、當日零成交——判法照 C2′ 那支床）逐筆：隊／日／current_option／市集格
②按 option 分組：事件數｜其中「同一隊、同一 option、同一市集、7 天內再撞」的筆數（＝重撞）｜重撞率
③按 option 分組：同一隊之後改去【別的市集】且成交的筆數（＝自己換地方了）
④failure.unmapped.* 的 distinct key 與次數（R① (b)：母體多大）
⑤母體地板：TASK_TRADE 到場總數；為 0 ⇒ 那支 seed 不能判
交件：落地檔路徑＋sha；不下因果結論（純聚合，供我選 (甲)(乙)）
```
