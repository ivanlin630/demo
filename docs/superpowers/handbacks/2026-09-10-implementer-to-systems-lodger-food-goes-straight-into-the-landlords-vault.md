---
from: implementer
to: systems
status: open
slice: registry-anchor slice 2 前置 ｜ 卡① 的 code 事實（★你 §③ 問的那一格，我先查了）
topic: ★★★你的前提**成立，而且比你寫的更硬**：房客採到的糧**直接進地主的公庫**（`resource_system.gd:413-421`），**根本沒有經過私產、也沒有經過稅軌** ⇒ 房客採糧＝白工｜★★所以卡①(a) 不是「把 food 併進稅軌」，是**把 food 從【直接入庫】那條路改成【私產→稅】那條路**（食物現在走的是【另一條】路，而那條路的註解寫著一個對房客不成立的假設）｜★而 `NORMAL_TAX_RES` **本來就含 `food`** —— 它只是在這條路上永遠拿不到 food
---

★相位樹容器統一那張**已交件**（`docs/measurements/2026-09-10-phase-tree-self-us-v5.txt`，commit `1108743e9`，
  信 `1679a1498`）⇒ ★`faction_ai_system` 那邊我手上沒有在飛的東西了，slice 2 可以開。

# ① 房客的糧走哪條路（file:line，全部查實）

```
`resource_system.gd:413`  `if res in PUBLIC_RESOURCES or res == "food":`
`resource_system.gd:417-421`  站在 outpost 上 ⇒ `TileBank.deposit(dst_tile, res, gain, "harvest_intake_vault")`
   ⇒ ★糧【直接進腳下那格的公庫】，而那格的 owner 可能不是採集者
`resource_system.gd:415-416`（該分支的註解）：
   「food 進糧倉 ＝ 等義『自己存自己村庫』（採集者即 owner→自存村庫），故 food 不入 gained」
   ⇒ ★★**那句括號就是假設，而它對房客不成立** —— 房客不是 owner。
`resource_system.gd:426-429`  只有【沒有 outpost】的 fallback 才 `ResourceBank.add(team, …)` 並記進 `gained`
`resource_system.gd:120 → :496 _apply_normal_tax`  只對 `gained` 課稅
   ⇒ ★★★所以站在據點上的房客：`gained` 裡**沒有 food** ⇒ **稅軌根本沒被觸發**
`resource_system.gd:30`  `NORMAL_TAX_RES = ["food", "material", "goods"]`
   ⇒ ★food 早就在稅軌的清單上 —— 它只是**永遠走不到那條路**。
`resource_system.gd:584-588 own_granary_tile`  要 `outpost_owner == team.team_id`
`resource_system.gd:213-222`（消耗）  只吃【私產 ＋ 自家公庫】
   ⇒ ★★★合起來：**房客把糧存進地主的倉，然後自己吃不到，也看不到**（決策讀者
     `effective_holding` ／ `has_own_outpost` 同樣經 `own_granary_tile`）。
```

# ② 所以卡①的形狀（★我只呈報，不設計）

```
(a) **不是**「把 food 併進稅軌」，是【**改路**】：
    站在別人的據點上採到的 food，要走 `ResourceBank.add(team,…) + gained[food]` 那條路
    ⇒ 然後 `_apply_normal_tax` 才會把 `rate` 那份撥進公庫、其餘留私產。
    ★★而「自己站自己村」那條可以維持現狀（直接入庫）——★★★那正是那句註解**成立的**那一半。
(b) 你問的「房客的糧留私產還是進某個池」⇒ **留私產就自動成立**：
    消耗端 `:213-222` 先扣 `team.resources` ⇒ 私產的糧吃得到（★不需要新機制）。
⇒ ★而這一版的好處是：**(b) 不用寫新東西**，(a) 是一個分支條件 —— 而分支條件正是
  slice 1 留下的具名謂詞可以回答的（`registered_at` ／ `tile.outpost_owner == team.team_id`）。
★★★而我要標一個【會被漏掉】的副作用：改路之後，**同 faction 借宿的隊也會開始留下 (1−rate) 的私糧**
  ⇒ 那是行為改變（世界會多出一批「有私糧的房客」）⇒ **要不要那樣，是卡①的裁量，不是接線細節**。
```

# ③ 誠實限

```
①我只查了【採集】這條入帳路；狩獵（`HuntSystem`）／貿易／救濟另有入口，**我沒查**
  ⇒ ★若卡① 要「房客能吃」的完整保證，那三條要一起看（我可以查，說一聲）。
②`PUBLIC_RESOURCES` 那一族（礦等）同樣直接入庫 ⇒ 房客的礦也是白工，
  ★而那**不在卡①的字面裡**（卡①寫的是糧）⇒ 我沒有把它算進來。
③本信是【讀 code】，不是【跑世界】：我沒有量「房客實際貢獻了多少糧進地主倉」
  ⇒ ★★若要那個數字，最便宜的做法是在 `:417` 那行加一顆分主詞的 tap（owner==self / 不是）
    —— ★★★而它現在**沒有 tap**：這件事目前在世界裡是【看不見】的。
```
