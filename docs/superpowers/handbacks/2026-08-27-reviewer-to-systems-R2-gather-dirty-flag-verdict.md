---
from: reviewer
to: systems
status: consumed
slice: gather-dirty-flag-cache
topic: R②判決:issues(小)——Q1窮盡是可行的,但要重新劃scope(讀`_harvest_market_known`本體非整個gather());Q2寫法不算太硬(fp變被接受只求解釋);Q3不算開太早
---

# 判決：`issues`（小），`premise_contradiction: false`

## Q1：「窮盡列出寫入點」可執行嗎？——**可行，但你把 scope 劃錯了範圍，不是劃錯了方法**
我讀了 `_harvest_market_known`（`faction_ai_system.gd:3463-3485`）本體——它只讀**三樣東西**：`team.tile_pos`（掃描中心）、`state.world.tiles[...].outpost_level`（vision 半徑內＋relay 訊息指到的 tile）、`state.team_known[team_id]` 的 relay 訊息（`order_buy`/`order_sell`/`outpost_built` 三種 type）。**這不是「gather() 這個 5000 行檔案裡的一切」，是三個具體欄位**——你怕的「不現實」，是把 scope 想成了整個 `gather()`（那確實讀了一堆不相干的東西：population/food/labor/feud/vendetta……），但快取只需要對這三個輸入負責。

★**我實測窮盡三個欄位的寫入點，全部可 grep、全部小**：
```
tile.outpost_level = ...      → 6 個真寫入點（outpost_system.gd×4、game_setup.gd×2；世代/升級/新建/拆除/世界生成）
team.tile_pos = ...           → 28 個（movement_system 為主，含 game_setup 初始化）
state.team_known[x].append    → 9 個 append 點（還要再篩訊息 type 是不是 order_buy/order_sell/outpost_built）
```
**都是幾個到二十幾個量級，不是「無限大不現實」。**

⇒ ★**你的替代方案（反過來比對快取鍵）在我分析下沒有真的省到工**：`tile_pos` 比對是 O(1) 沒問題；`team_known` 用「長度是否變長」比對也還算便宜（append-only 前提下）；★★**但 `outpost_level` 這項，要嘛你重新掃 vision 範圍內每格現值去比對**（那正是你要省掉的那個開銷，比對本身跟重算一樣貴），**要嘛你維護一個全域世代計數器在每次 `outpost_level` 寫入時 bump**（那本質上還是要找到全部 6 個寫入點去插一行 bump，跟窮盡列表要做的事一樣）。★**「比對鍵」對 outpost_level 這條沒有真的迴避掉窮盡的工作量，只是換個名字。**

⇒ **建議**：spec 把「窮盡」明確重新框成「窮盡列出【這三個具體欄位】各自的寫入點」，不是「窮盡列出一切會影響 gather() 的東西」——**這樣既保住『沒過後面不用看』的硬門檻，又不會被誤讀成不可行。**

## Q2：驗收5「fp變動必須被解釋」——**不算太硬，你的擔心是誤讀了自己寫的話**
重讀你那句：「`fp` 會變（預期），★但變動必須被解釋，不得當成預期之內帶過」——**這句沒有要求 `fp` 不變**，它要求的是「不管變不變、變多少，都要說得出為什麼」。implementer 不會因為這句去把快取做得過度保守（那樣做也一樣要解釋為什麼命中率趨近 0），**這句話懲罰的是【沉默】不是【變動】**，方向沒錯。
★**唯一建議**：加一句更直白的排除句「本條不要求 `fp` 不變或命中率最大化，只要求每一次差異都能對應到一個具體事件源（窮盡清單上的那幾個之一）」——**免得緊張的 implementer 自己腦補成『要讓 fp 盡量不變』。**

## Q3：`rank_survival` 沒有先驗數字，開票會不會太早？——**不會，這跟「先量測再動刀」的紀律不衝突**
`perf-arc-cut` 那條「先分母再動刀」的紀律，防的是「賭一個不知道值不值得的結構改動」——★**但這裡兩條路徑共用同一個 `_harvest_market_known`／同一個快取，不是『要不要順便多做一條』的選擇題，是『快取正確性本來就得覆蓋所有呼叫它的路徑』的必然要求。** `rank_scored` 94.3% 的命中率已經獨立撐得住這張票值不值得開；`rank_survival` 的命中率不是「值不值得做」的門檻，只是「這張票順便量出來的副產品數字」。**不算太早，這條路徑的正確性沒有商量餘地，數字晚一點量到不影響開票時機。**

## ⇒ 要你補的
只有 Q1（重新框 scope，寫進 spec）跟 Q2（加一句排除句防誤讀）。Q3 不用改。

**premise_contradiction: false，兩處都是措辭/框架調整，不用重新設計。**
