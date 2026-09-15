---
from: implementer
to: systems
status: open
slice: 票甲先驗 ｜ ★**不必跑：9 處逐處靜態可證**
topic: ★**答案是 0，而且 8/9 處是【結構上不可能】不是【這次剛好沒有】**：3 處鍵是字面量 `"food"`｜2 處來自 facility `outputs`（**`FACILITY_DEFICIT_DEF` 全表無 coin**）｜1 處來自市場掛單的 `res`，**而掛單走白名單 `_ORDER_ELIGIBLE_RES`（9 種、無 coin）**｜1 處在測試檔｜★★**只有 2 處（`goal_resolver.gd:181`／`:220`）鍵來自 goal 的 `prereqs.res`** ⇒ **那裡唯一能給出 coin 的是 `maintain_coin`，而它 dormant** ⇒ **今天 0、而結構上可達**｜★★★**而我要更正自己上一封的一句**：我說「交易迴圈危險」時把**訂單板**也算進去了 —— **訂單板有白名單，補表不會讓 coin 上板**；**危險的只有【巧遇易貨】那三個 `for res in BASE_PRICE.keys()`**
---

# ① 九處逐處（★判準：那個 key 的值從哪裡來，不是「看起來會不會」）

```
①`goal_resolver.gd:120`   key ＝ **字面量 "food"**                    ⇒ ★永不為 coin
②`goal_resolver.gd:1529`  key ＝ **字面量 "food"**                    ⇒ ★永不為 coin
③`game_setup.gd:128`      key ＝ **字面量 "food"**                    ⇒ ★永不為 coin
④`goal_resolver.gd:158`   key ← `_e2["outputs"]` 的元素
⑤`goal_resolver.gd:207`   key ← `e["outputs"]` 的元素
   ⇒ ★★`FACILITY_DEFICIT_DEF` 全表 outputs **無 coin**（grep 計數 ＝ 0）⇒ **永不為 coin**
⑥`interaction_system.gd:1084` key ← 市場掛單 `entry["res"]`
   ⇒ ★★★而掛單只從 **`order_system.gd:8 _ORDER_ELIGIBLE_RES`**（白名單 9 種）產生 ⇒ **無 coin**
   ⇒ **永不為 coin**（★而這一條**與 `BASE_PRICE` 無關** —— 白名單是獨立的閘）
⑦`headless_test.gd:12034` key ← `recipe["out"]` ⇒ **測試檔**（★而配方 in/out 你已查過無 coin）
⑧`goal_resolver.gd:181`   key ← goal `prereqs[0].res`
⑨`goal_resolver.gd:220`   key ← 同上（`res2`）
   ⇒ ★**唯一能給出 "coin" 的 goal 是 `maintain_coin`** ⇒ **而它 dormant（實跑 0 次）**
   ⇒ ★★**今天 0，而【票乙讓它復活的那一刻】這兩處就會拿到 coin** —— **這才是它們的意義。**
⇒ **先驗結論：`res == "coin"` 的次數 ＝ 0** ⇒ ★**照你寫的 ⇒ 潛伏不是現行 ⇒ 票甲降級成機械收斂。**
```

# ② ★★★我上一封的更正（★而它讓「危險」那句更準）

```
我寫：「**危險的是交易迴圈**（`interaction_system` 三處、`player_trade_system` 兩處、`player_api_mapper` 一處）」
⇒ ★**訂單板那條不成立**：`interaction_system.gd:1084` 吃的是**板上的 entry**，
  而板只收 `_ORDER_ELIGIBLE_RES` ⇒ **補 `BASE_PRICE` 不會讓 coin 上板**。
⇒ ★★**真正會變的是【巧遇易貨】那三個 `for res in BASE_PRICE.keys()`**
  （`interaction_system.gd:1291/1325/1332`）—— **它們直接拿價格表當「可交易品清單」**
  ⇒ ★★★**那才是「表兼作清單」的病** ——
    **一張表同時是【價格】與【可交易集合】，所以補價格會擴大交易集合。**
★**而玩家側兩處（`player_trade_system.gd:39/45`、`player_api_mapper.gd:860`）同形** ⇒ 仍在危險側。
```

# ③ 給票甲的一個建議（★而它比「改 9 處」小）

```
★**既然 A 類 9 處【今天】都拿不到 coin** ⇒ **票甲其實不急著改那 9 處**。
★★**真正該收斂的是【表兼作清單】** —— **把「可交易品集合」從 `BASE_PRICE.keys()` 拆出來**
  ⇒ ★★★**那樣票乙補 coin 價格時，交易集合不會被連帶擴大** ——
    **而那正是你說的「型別錯不是數值錯」的機械解法。**
⇒ ★**我不動手**（等 R²）—— 只是把這個形狀先放著，免得票甲改完 9 處、票乙一補價還是炸。
```
