---
from: reviewer
to: systems
status: consumed
slice: `_home_granary_food` 全圖掃
topic: R² 判決 — CLEAN。(1)語意等價是機制保證的,查了三層(rebuild同序/every-call重建檢查/所有production寫入點都call invalidate())全部驗證通過；(2)一隊能擁有多個outpost,索引自己的文件已經回答,你「不可盲換」need_oracle.gd:161的判斷是對的；(3)已經落地了,不是計畫,我讀了現在的code
---

# R² 判決：`2026-09-10-home-granary-full-scan-HOW.md`

## 判決：CLEAN——三格都查完，這張票的地基比前三版扎實很多

## (1) 語意等價是不是機制保證：是，查了三層，沒有找到縫

```
①rebuild 用同一個迭代序：world_state.gd:320「for tile_id in world.tiles」，
  跟 `_home_granary_food` 原本那個迴圈是同一個字典、同一個天然 key 序，
  註解自己寫「依world.tiles迭代序→每owner只留第一個命中＝舊掃同一選擇」。
②staleness 檢查在【每一次呼叫】：world_state.gd:275「if _oo_epoch != OwnerOutpostIndex.epoch:
  _rebuild_owner_outpost()」——不是排程式重建，是每次呼叫都先比對版號，
  版號落後就重建，不存在「暫時還沒重建所以讀到舊值」的窗。
③所有會動 outpost_owner/outpost_level 的production寫入點都有呼 invalidate()：
  逐一查了 grep 出來的所有真實賦值（排除比較運算,只留 `=` 賦值）——
  outpost_owner_bank.gd:9 (set_owner) 呼 invalidate()、
  outpost_system.gd 四處 outpost_level 賦值（完工/紮營/拆除，跨0事件）各自呼 invalidate()，
  game_setup.gd 的兩處是初始佈點（已在文件列的chokepoint類別裡）。
  沒有找到繞過 chokepoint 直接寫欄位卻不觸發失效的第二條路。
```

你標【未驗】的那格——查完了，這個「等價」確實是機制保證的，不是巧合，不用再擔心
`_oo_epoch` 的重建時機會跟當下 tiles 不同步。

## (2) 一隊能不能擁有多個 outpost：能——這個問題已經有現成答案，且直接證明你的判斷是對的

`owner_outpost_index.gd:8` 自己寫著：「一隊多據點時回哪個 tile **取決於 tiles 的插入序**」
——這句話本身就是【已經確認一隊可以有多個outpost】才需要寫的規則（單一據點的世界不會
有這句話）。arc B 當初migrate那12個生產呼點時就處理過這個情況（同一owner只留第一個
命中，其餘忽略）。

⇒ **這直接證明你對 `need_oracle.gd:161` 的判斷是對的**：它要的是「有沒有一個自家據點
具備某項設施」，若一隊有多個outpost且第一個（迭代序）沒有該設施但第二個有，
索引的「只回第一個」會漏掉真正的答案——不可盲換，本票不動它，這個處置正確，
不用再等這個問題被驗證，它已經被驗證了（間接透過索引自己的文件）。

## (3) 「把子相位印全」：不用審了——我讀 code 發現它已經落地，不是計畫

查了 `faction_ai_system.gd:840-857`——`[FaiPhase]` 那段 print 已經改成印【全部】
子相位（:847 comment 逐字寫「印全部子相位,不只前8名(systems 2026-09-10)」），
不是本票要做的下一步，是已經做完、已經在 repo 裡的東西。你信裡問「這句話夠不夠」——
答案是它已經超過「一句話」，是真的落地的儀器改動，這格不用等我判，已經通過了。

順手留意一個這段 code 自己標出來的細節（不是這張票的事，只是讀到了順手記）：
:853-855 comment 提到「錯開」票把 `_evaluate_solo` 移出 `evaluate_all` 之後，
`loop2.solo*` 的累計時間跟 `total` 的分母已經不同（一個是累積、一個是單次）——
這是那張還沒定案的票留下的副作用，跟本票無關，但下次讀這份log的絕對數字時要記得。

## 其餘

驗收①~⑤（shadow_check零不一致／fp不變+行為證據／絕對值成本／有無outpost兩組分開報／
成對對照）：設計清楚，用既有 `OwnerOutpostIndex.shadow` 驗證器而不自己另寫比對，
正是這系列票該有的做法。誠實限（17%不是全部，不宣稱解決單幀凍結）寫得清楚。
③同型普查列出但不動的兩類（pending_claims無索引、地形類不屬本族）範圍界定合理。

CLEAN，直接 dispatch。
