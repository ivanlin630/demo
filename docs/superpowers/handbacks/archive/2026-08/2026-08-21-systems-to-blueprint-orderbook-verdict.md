---
from: systems
to: blueprint
status: consumed
topic: "[訂單簿健康度(用戶追問的舊懸案)世界級數字到手+我的 HOW 判斷·★數字(peaceful 90 天完整):placed 1001 / filled 【7】/ abandoned 945 → 成交率【0.7%】、abandon 率 94.4%;★★『壽命』不是分布是【硬常數牆】——ORDER_LIFETIME=5 天寫死(order_system.gd:3)、16 筆 abandon 樣本 age_ticks 全部=1200【零變異】→ 每張被砍的單都活滿整整 5 天;★重掛 churn=【0%】(order.replaced 全期 0 次,硬證據)→我先前的 churn 懷疑撤回·★★我的 HOW 判斷(要你知道、因為它影響『下一步該修哪』):measurer 建議的直接槓桿是『5 天常數是否夠長』,但我【不建議先動它】——0.7% 成交率與已知 GATE-B 的 buy-fill 【0.5%】(seek 1363→arrive 333→fill 4、interaction:781 只從抵達 tile 的 granary 買=空間錯配)幾乎一致,∴真 binding 疑為【貨根本到不了】而非【窗太短】;先拉長 ORDER_LIFETIME 只會把『到不了貨』變成『更久之後才被砍』=在結構性斷點上調參(同 crank 家族)·★正確順序:先修 GATE-B(貨能到)→再看成交率是否自然上來→若仍低才檢討 5 天窗·★另有一個【兩份證據矛盾】我已派 measurer 釐清:QA 在大考讀到 team8 買糧單 qty_rem 17→21【不減反增】(像重掛),但 replaced=0;若真相是『同一張單就地加碼』,那『無 churn』只對新單成立、對就地改量不成立(那一樣是反覆改主意的病徵)·★不需你裁,除非你要把 ORDER_LIFETIME 排進 tuning 議程"
---

# 訂單簿健康度：世界級數字 + 我的 HOW 判斷

**★數字**（peaceful 90 天完整）：`placed 1001` ／ `filled` **7** ／ `abandoned 945` → **成交率 0.7%**、abandon 率 **94.4%**。
**★★「壽命」不是分布、是硬常數牆**：`ORDER_LIFETIME = 5 天`**寫死**（`order_system.gd:3`）；16 筆 abandon 樣本 `age_ticks` **全部 = 1200、零變異** → **每張被砍的單都活滿整整 5 天**。
**★重掛 churn ＝ 0%**（`order.replaced` 全期 0 次、硬證據）→ **我先前的 churn 懷疑撤回**。

## ★★我的 HOW 判斷（影響「下一步該修哪」）
measurer 建議的直接槓桿是「**5 天常數是否夠長**」，但**我不建議先動它**：
**0.7% 成交率**與已知 **GATE-B 的 buy-fill 0.5%**（seek 1363 → arrive 333 → **fill 4**；`interaction:781` **只從抵達 tile 的 granary 買 ＝ 空間錯配**）**幾乎一致**。
∴ **真 binding 疑為「貨根本到不了」，而非「窗太短」**。**先拉長 `ORDER_LIFETIME` 只會把「到不了貨」變成「更久之後才被砍」＝在結構性斷點上調參**（同 crank 家族）。

**★正確順序**：先修 **GATE-B**（貨能到）→ 再看成交率是否自然上來 → **若仍低才檢討 5 天窗**。

## ★另有一個「兩份證據矛盾」我已派 measurer 釐清
QA 在大考讀到 **team8 買糧單 `qty_rem` 17→21 不減反增**（**像重掛**），但 `replaced = 0`。
若真相是「**同一張單就地加碼**」，那「**無 churn**」**只對新單成立、對就地改量不成立**——而後者**一樣是反覆改主意的病徵**。

★**不需你裁**，除非你要把 `ORDER_LIFETIME` 排進 tuning 議程。
