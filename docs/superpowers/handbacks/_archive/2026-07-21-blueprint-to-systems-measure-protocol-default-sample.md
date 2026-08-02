---
from: blueprint
to: systems
status: consumed
topic: "[流程改善提議·量測協議加預設條款:任何decision-bearing聚合數字探針必須同時存bounded具體案例(3-10個),非事後補]今天economy disambig漏了這個——res-split探針只存聚合計數(food26/goods276),沒存具體案例,導致我用聚合數字直接下決策(解除HOLD),事後被用戶戳出沒人讀過故事,得回頭請measurer補trace。用戶指出開銷根本不是理由——sim主要成本是跑模擬本身,探針偵測到事件時順手多印幾行(tick/隊/資源/相關狀態)幾乎免費,範圍限制的小樣本讀起來也不貴。★提議:量測協議(reference_measurement_protocol/03b_implementer流程)加一條標準門檻——任何會被拿去支撐WHAT級決策(方向判斷/release-pass/HOLD解除等)的聚合探針,寫的時候就該同時捕3-10個具體instance(有上限,非全dump),不是計數器單獨存在。這樣任何『決定性數字』出來時故事材料已經在旁邊,不用事後回頭補一輪。你HOW定怎麼寫進協議/checklist,我只提這個WHAT級的預防原則。"
---

# 流程改善提議：量測協議加「決策級探針必存具體案例」門檻

## 觸發
今天 economy disambig（food vs goods res-split）漏了這個——探針只存了聚合計數（food 26 / goods 276），沒有存任何具體案例。我直接拿聚合數字下了決策（解除 market-liquidize HOLD），被用戶戳出沒人讀過故事，得回頭請 measurer 補 trace，多繞一輪。

## 用戶點破的關鍵
開銷不是理由——sim 本身跑 8 個月才是主要時間成本，探針偵測到事件時順手多印幾行（tick/隊/資源/相關狀態）幾乎免費（不用多跑一次，就在計數器 +1 的同一行程式碼旁邊多存）。範圍受限的小樣本（3-10 個）讀起來也不貴，跟今天大多數探針（SITRACE/finder-check）已經在做的事一樣。

## 提議：量測協議加標準門檻
**任何會被拿去支撐 WHAT 級決策的聚合探針（方向判斷/release-pass/HOLD 解除等），寫的時候就該同時捕 3-10 個具體 instance（有上限，非全 dump），不是只留計數器。**

這樣任何「決定性數字」出來的時候，故事材料已經在旁邊，不用事後回頭補一輪、不用等我戳了才追加。今天大部分探針已經自然這樣做（有範圍的死隊 lockpoint trace），這次是個例外沒做到，值得補成標準門檻避免下次又漏。

HOW（寫進 `reference_measurement_protocol`/`03b_implementer.md` 流程 checklist 的哪個位置、具體怎麼要求）你定，我只提這個 WHAT 級的預防原則。

## 溯源
用戶今天連續追問「QA是不是又被忘了」+「量測沒全探針」+「存log不會花多少時間」三問逼出的流程改善。
