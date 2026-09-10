---
from: systems
to: reviewer
status: open
slice: 登記錨 ④a
topic: ★★★**R①（factcheck 前提）**：本票唯一的未驗前提是**「按站位判定的呼叫點清單是完整的」** —— 而我列的是**我掃到的**，不是**窮盡的**｜★★漏一站的後果不是「少改一處」，是**兩套真相並存而沒有任何一格會紅**（那一站繼續讀站位、其餘讀登記）｜★spec：`specs/2026-09-10-registry-anchor-slice1-HOW.md`
---

# ① 我要你做的（★不是審設計，是**窮盡**）

```
母體：**所有「用腳下那格 ＋ 所有權/同 faction 判定一支隊算不算居民」的地方**。
★★而請**不要**只掃 `is_resident_static` 這個名字 ——
  ★★★**inline 重寫一份同樣邏輯的地方，正是這種普查最常漏的**
  （今天已經有一個同型血證：`_home_granary_food` 是 `_find_own_outpost` 的**複製品**，
   它沒有呼叫那支函式，它**抄了那支函式的身體** ⇒ 任何以呼叫點為母體的普查對它是盲的）。
⇒ 請以**身體特徵**掃：`outpost_level`／`outpost_owner`／`faction_id ==` 三者的組合，
  再逐處判「它問的是不是【這支隊算不算這座村的居民】」。
```

# ② 我目前的清單（★請當成【待推翻】不是【待確認】）

```
faction_ai_system.gd:600-613  is_resident_static（謂詞本體）／:595 _is_resident_team（包裝）
呼叫點：decision_context.gd:404／goal_resolver.gd:377／options.gd:25／options.gd:474
        faction_ai_system.gd:1205／:7019／:7240／:7360／movement_system.gd:72
        sim_runner.gd:459／observer_query_api.gd:174,181,190
```

# ③ ★而有兩條我**故意排除**，請你打這個排除對不對

```
`ResourceSystem.own_granary_tile`（:584-588）與 `_home_granary_food`／`has_home_outpost`
⇒ ★我判它們是**所有權**判定不是**站位**判定，且「房客能不能吃」由**卡①的稅軌分成**回答
⇒ ★★所以本票不動它們。
⇒ ★★★請打：**這個切線會不會讓世界在 slice 1 之後處於一個不自洽的中間態？**
  （例如：一支隊在登記上是居民，而在吃糧上不是 ⇒ 它現在**就是**這樣，而本票沒有改變它 ——
   ★我認為「維持現狀的不自洽」比「順手改一半」安全，但這一句要你打。）
```

# ④ 若你找到漏網的站

```
★請直接給 file:line ＋ 它現在**怎麼判**（而不是「這裡也要改」）——
  ★★因為有些站可能**應該繼續讀站位**（例如觀察者 API 要顯示「此刻站在這格的居民」），
  ★★★而那正是「全改讀此欄」這句話會誤傷的地方。
```
