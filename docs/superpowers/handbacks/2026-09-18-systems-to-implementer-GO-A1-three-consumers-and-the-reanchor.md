---
from: systems
to: implementer
status: consumed
slice: 凍結終線｜A1（把亂數抽取搬到消費點）— **R² 回來了：issues（非阻擋）⇒ 可以動了**
topic: ★**GO**：WHAT 已准、R② 已審（issues 非阻擋）｜★★★**遷移清單是【三處】不是兩處** —— R² 全庫掃出我們兩個都漏的第三個：`headless_test.gd:9260-9263`（`assert(r.get("speed",0) > 0)`）⇒ A1 後變成 `0>0` ＝ **loud fail**｜★★R² 也解掉我那個「雙抽會放大不一致」的疑慮：**A1 其實是【減少】總 RNG 消耗**
---

# 一、GO 的條件都齊了

```
WHAT   核准「世界改變一次」＋綁兩條件（見下）
R②     issues（非阻擋）——流程違規那格他明說「處置正確，不用再談」
⇒ ★A1 可以動 production 了；(丙-2) 其餘欄位在 A1 落地＋重錨之後再回去做
```

# 二、★★★遷移清單＝**三處**

```
path_system.gd:291   predict_intercept       讀 obs["speed"]
path_system.gd:257   estimate_catch_up       讀 obs["speed"]
★scripts/debug/headless_test.gd:9260-9263    assert(r.get("speed", 0) > 0, …) ＋ print
```
★**第三個的性質要講清楚**：它**不是沉默讀者，是 loud fail**（`0 > 0` ⇒ 斷言真的會炸）。
⇒ ★★**但不順手改，headless 回歸會多一支新紅要解釋** —— 而那會讓「**HARD-FAILS ＝ baseline**」
那條核對本身變混亂。**一支「預期中的紅」與一支「真的紅」在那張表上長得一樣。**

★**而 R² 核過的另一半**：`threat_assessment.gd:74-77` 只讀 `visible`／`direction`，
**從來沒讀 `speed`** ⇒ 拿掉那個鍵對它**零影響**，不是「沉默通過」的風險，是**本來就不需要**。

# 三、我那個疑慮被解掉了（記著，免得下次又擔心一次）

```
我問：兩個消費者各自呼一次 observed_speed ⇒ 會不會變成同一 tick 抽兩次、放大 A2 那個不一致？
R²答：★那個關係【現在就存在】—— estimate_catch_up 與 predict_intercept 現在就是各自呼
      observe_velocity、各自抽一次 ⇒ A1 前後【形狀完全一樣】
      ★★A1 唯一改變的是【移除 _approach_score 那條路上白抽的那一次】
      ⇒ ★★★A1 是【減少】總 RNG 消耗，不是放大不一致；A2 的範圍沒有被本票偷偷擴大或縮小
```

# 四、落地步驟（順序有意義）

1. **A1 三處遷移** ＋ `observe_velocity()` 回 `{visible, direction, noise_factor}`。
2. ★**WHAT 綁的①：三跑 byte-identical**（「觀測儀器禁耗 global RNG」家族的既有驗法）。
3. ★★**重錨基線**：既有 fp 基線**全部作廢一次**（含你床裡那顆 `3951597c0fd9…`）
   ⇒ 新基線釘進床，**並標明從哪一顆 commit 起**。
4. ★★★**WHAT 綁的②**：**跨這顆 commit 的單 seed 前後對照【不可歸因】** ⇒ **卷面上註明**
   （不要拿修法前後的單 seed 數字去比效能 —— 那是兩個世界）。
5. 然後回去做 **(丙-2)** 其餘欄位（含 1-i 內容錨）。

★**判準軸我也寫進 spec 了**（R² 要的那一句）：**「我要驗的那個變因，在不在同一棵樹裡？」**
在樹內（旗標／開關）⇒ 同輪比、禁釘歷史字串；**就是樹本身（修法前後）⇒ 必須釘另一棵樹的產物 ＋ 標 commit**。
⇒ ★**所以 1-e 被合法改動打紅不是缺點、是功能**；世界一旦被核准改變一次，**正確動作是重錨，不是放寬判準**。
