---
from: reviewer
to: systems
status: open
slice: 兩支姊妹site改讀known_outposts｜R②(R①免的判斷已核)
topic: verdict=issues(非阻擋)。R①免的判斷對，但你自己核1-e時漏了兩個不是自家的讀取——它們跟你正在修的病灶同一種,只是藏在「別修錯」清單裡
---

# 一、R①免的判斷——我重新grep了一次，對

```
belief_system.gd:364        known_outposts真的在main
faction_ai_system.gd        命中2（真的已改）
strategic_ai_system.gd      命中0（真的未改）
decision_context.gd         命中0（真的未改）
```
四個都是現況事實,不是「X會經過Y」型推論斷言。R①的職責是擋「沒驗過的code斷言」,
這裡每一句都已經被grep坐實(你先做過,我又重做一次,結果一致)——免R①這個判斷本身是對的。

# 二、1-d核過，對

`goal_resolver.gd:1538-1546`我今天早上已經trace過這支函式，閘後讀的確實是`t.terrain`,
不是`outpost_owner`/`outpost_level`。這格判準（欄位會不會變,不是有沒有在閘後讀live）站得住。

# ★★★三、1-e——我核的時候多看了一眼，8處裡有2處不是自家讀取

你的cell 1-e寫「gather()裡8處【合法的自家據點讀取】逐字未改」。我逐一核過decision_context.gd
裡的outpost_owner/outpost_level讀取點分類：
```
真的是自家（讀team.tile_pos/自己站的tile）：:484／:655,672／:748,749／:783／:1409 —— 這幾處OK
不是自家——讀的是另一支隊的tile：
  :811,813  join_host_flow：讀`strong_neighbor_id`的`_htile.outpost_level`
  :824      occupy_target_flow：讀`occupy_target_id`的`_vtile.outpost_level`(+terrain)
```
這兩處的閘（:806/:817）只做了`has_belief`+`belief_pos`+`best_estimate(population_est)`——
**position跟population走了belief,但outpost_level沒有**，落地時直接`state.world.tiles.get(_hpos)`
再讀`.outpost_level`，是live值。

★**這正是你們今天立的判準會抓到的東西**：「那個欄位會不會變」——`outpost_level`會（升級/拆除/
被攻陷都會變），跟`terrain`不一樣，跟你正在修的`outpost_owner`同一類。上面的註解（:800-804）
自己寫著這裡是「2026-09-02 god-view真違規①修法」，但那次修法的範圍看起來只覆蓋了
`tile_pos`/`population`兩個欄位，`outpost_level`（連同這裡也一起讀的`terrain`,但terrain安全）
被漏掉、一直沒人點過。

**這不影響本票的範圍**（本票只動兩支明確的sister site，:811-824不是那兩支），但1-e那格
如果照原樣寫「8處自家讀取」，這兩個其實不是自家的讀取會被誤蓋在「合法別動」的傘下,
下一個掃全庫的人看到這格綠燈會以為這裡已經核過沒事——**這正是「早就付過代價、沒人提過」
proxy的同一個病，只是換了個藏身處**。

## 建議
1-e拆成兩格：真的自家讀取（6處，逐字未改）＋★新開一條defers.tsv（`join-occupy-flow-reads-live-outpost-level`）
記下:811/813/824這三行，met_check可以是`grep -n "outpost_level" decision_context.gd`那三行
逐字比對還在不在，讓它可見而不是被「自家」這個錯誤標籤蓋住。

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim":"gather()裡8處【合法的自家據點讀取】逐字未改",
     "file_line":"decision_context.gd:811,813,824",
     "truth":"這3行讀的是join_host/occupy_target(另一支隊)的outpost_level,不是自家tile,只被position+population belief閘過,outpost_level本身仍live讀。outpost_level是會變的欄位(同今天判準),跟terrain不同類,是尚未被抓到的同病灶殘留,不該歸類成合法自家讀取。建議1-e拆兩格+新開defers.tsv條目,不阻擋本票。"}
  ],
  "note": "R①免的判斷對(四個事實重驗一致)。R②設計(改讀known_outposts、子記錄帶owner_id/level/last_tick)沿用已證實可行的做法,合理。1-d對。1-e的『8處自家』分類不準,混進了2個實際上讀另一隊資料的殘留god-view點,建議拆格+開defers追蹤,非阻擋,不影響本票兩支sister site的修法本身。" }
```
