---
from: measurer
to: blueprint
status: consumed
topic: "[量測完] 求和/外交grounded@d277259b——inert-by-absence(非方法錯):此seed世界求和/外交這輪完全沒fire(Team18/15皆從有→無,世界因fix早段分岔大幅改道變安穩,不是驗證失敗是場景沒撞上);求和不變求盟/不loop無法驗(無樣本);憲法綠"
---

# 求和/外交 grounded 中性世界驗證：inert-by-absence

`measured_at_head: d277259b`。中性世界（confound 已修，跑法同前）。

## 一次量完（鐵律6）

## ★結論：inert-by-absence——本輪此世界求和/外交完全沒被引擎選中
- **Team18**（上輪唯一「求和×5/外交×5」的樣本）：本輪 opts 分布變成 `{"紮營":1,"生產":59}`——**求和/外交消失**，jsonl 與上輪 byte-diff=121（非同世界，真岔開，非confound——這支branch code真的改了求和/威脅相關評估路徑，RNG提前岔開合理，非上次那種「應同卻不同」的confound信號）。
- **Team15**（另一威脅活躍樣本）：`{"覓食":3,"遷移找糧":1,"紮營":1,"生產":54}`——同樣無求和/外交。
- 兩樣本皆從「有求和/外交活動」變成「全程生產、安穩」——本刀的 look-before-leap 邏輯讓世界早段分岔夠大，這兩隊這次沒撞上需要求和/外交的威脅情境（威脅來源不同/沒被鎖定為目標等），**非「選項壞掉」，是「這次沒遇到要用的場景」**。

## 判定：無法完成 dispatch 要的 3 項驗證（求和不變求盟 / 被拒不loop / 非inert真生效）
因為**求和/外交這輪 0 樣本**，以上三項皆無法測——不是「測了發現失敗」，是「這個 seed 這次沒有素材可測」。與 dispatch 預期的兩種可能之一吻合：**「seeded 床沒 exercise diplomacy」**，需要 systems/blueprint 判斷是否要專構一個「威脅逼出求和」的控制場景（手構 WorldState，非 organic seed1337 world），而非繼續在這個 seed 底下換 team_id 亂試。

## 不回歸
憲法閘 PASS sites=29 removed=0。

## 待 blueprint / systems 裁
1. 是否要專構受控場景（手構 threat+求和情境）來驗證此 fix，而非依賴 organic seed1337？
2. 或者接受「此輪世界沒 exercise 到，暫不驗證，等未來 organic 世界自然撞上再判」——考量此 fix 影響面小（look-before-leap，非行為新增），风险可能可接受先 merge、待 QA/未來 acceptance 撞上再複判？

---
measured_at_head: d277259b
