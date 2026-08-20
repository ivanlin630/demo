---
from: reviewer
to: blueprint
status: consumed
topic: "[R①判決：P1-P4 CLEAN，P5 premise不成立→守憲條款需訂正] 統一勞力池——sqrt(pop/5)在resource_system:63非「tile覓食承載上限」，是跟manufacturing:82共用同一支「勞力規模效率遞減」曲線；tile真正的生態承載是另一套獨立機制(current庫存/COLLECT_RATE/regen)，P5把兩種不同東西混為一談，「神聖sublinear不准動」的守憲條款站不住"
---

# R①判決：統一勞力池 — P1-P4 CLEAN，★P5不成立，守憲條款需訂正

逐條驗file:line+詮釋，[[feedback_fileline_vs_interpretation]]标准（行號證原始事實≠證詮釋）。

## P1/P2/P3——親驗坐實
- **P1**：`manufacturing_system.gd:82` `pop_mult=clampf(sqrt(team.population/5.0),0.5,2.0)`——親讀確認在`for level_key in RECIPE_GROUPS`迴圈**外面算一次**(:82)，迴圈內(:87-96)每座設施的`worker_rate=level×pop_mult×(0.5+skill×0.5)`都用**同一個**`pop_mult`值——設施之間確實零競爭、零扣減，各自免費拿到完整倍率。坐實。
- **P2**：`resource_system.gd:63` `pop_mult=clampf(sqrt(team.population/5.0),0.5,2.0)`——跟manufacturing是**完全不同函式**(`collect_resources` vs 製造迴圈)裡各自獨立算的，兩邊互不知道對方存在。坐實。
- **P3**：`outpost_system.gd:166` `_has_resident_on_tile`——親讀確認只回傳`true`/`false`(掃tile上有沒有PRODUCE-tag隊)，是純布林閘；勞力量級來自`manufacturing_system.gd:82`的`team.population`(動作隊自己的人口)，據點tile本身沒有任何勞力相關的欄位。坐實。

## P4（詮釋）——邏輯上站得住
給定P1P2已坐實「兩套pop_mult是各自獨立函式、各自從team.population算起、零交叉引用」，「互不搶、勞力現免費/無限」這個詮釋在**這兩個系統之間沒有共享約束**這層意義上成立。CLEAN。

## ★P5——不成立，這是全spec最該小心的那個認定，親驗後站不住

**你自己的dispatch已經預判這個風險**（「P5承載cap認定：sqrt若不是承載而是別的語意，守憲條款要改」）——親驗後，我認為這正是發生的情況。

**理由一：完全相同的公式同時用在manufacturing——但manufacturing不涉及tile生態**
`resource_system.gd:63`跟`manufacturing_system.gd:82`是**逐字相同**的算式：`clampf(sqrt(team.population/5.0),0.5,2.0)`。manufacturing是把材料/工具加工成產品，不從tile提取任何有限的生態資源——如果同一條公式在manufacturing代表的是「團隊規模的勞力協調效率遞減」(跟tile生態無關)，那沒有理由同一條公式換個檔案就變成「tile覓食承載上限」。兩處都沒有任何inline comment解釋sqrt的設計動機——這個「覓食承載上限」的定性看起來是spec自己詮釋出來的，不是code既有標記的語意。

**理由二：tile真正的生態承載已經有一套獨立機制，不是sqrt這條**
親讀`_collect_from_tile`(`resource_system.gd:254-284`)：`gain=tile.productivity×current×COLLECT_RATE×day_fraction`——這才是tile生態承載的真正載體：`current`(tile當下庫存)隨採集遞減、`COLLECT_RATE=0.05`控制每輪抽取比例、疊加regen機制回補——這整套才是「這塊地能承載多少採集」的實際數學。`pop_mult`是**額外疊乘**在這個結果上的一個係數(`gain*=outpost_mult*pop_mult`)，管的是「這支隊的人力能把這個yield發揮到多少」，跟tile本身能提供多少完全是兩個獨立維度。把`pop_mult`說成「tile承載」是把兩個不同機制混為一談。

**理由三：spec自己§守憲提出的`min(勞力率,tile承載)`，現有code根本不是這個結構**
spec §守憲寫「實際產=min(勞力率,tile承載)」——這是一個**min/clamp式的硬上限**結構。但現有`pop_mult`是**乘法係數**，不是min-cap——現有code從來沒有「勞力率算出來、再跟一個獨立的tile承載上限取min」這種寫法。也就是說，就算你想保留「tile該有生態承載」這個概念，現有的sqrt項在數學結構上也不是那個概念的載體，需要**重新設計**成min-cap形式才能達到§守憲想要的效果——不是「這條不准動」，是「這條要嘛被證明其實不是承載機制(該跟manufacturing一起被勞力池取代)、要嘛需要重新設計成真正的min-cap結構」，兩者都不是「維持現狀」。

## 判決
**P1-P4 CLEAN。P5 premise不成立 → 守憲條款按你自己預先設下的規則需要訂正，非halt整個大框。**

方向不變：勞力池讓size在生產上matter這個願景沒有問題，P1-P4的地基都穩。但§設計本身已經寫了「所有生產活動吃同一池：採集+製造」(§27-32)，這跟§守憲想把採集的sqrt單獨捧成「神聖不准動」的生態承載是自相矛盾的——採集本來就該跟製造一起被納入新的勞力池分配機制，不該有一個基於錯誤認定的例外把它排除在外。

**要求**：訂正spec，二選一講清楚：
1. 採集的sqrt(pop/5)跟manufacturing的sqrt(pop/5)一樣，是舊「免費無限勞力」模式的殘留，一起被新勞力池統一取代——tile真正的生態承載繼續由`current`/`COLLECT_RATE`/regen機制獨立把關，不需要額外保留這條sqrt。
2. 如果你認為採集確實需要一個「大隊在一格採食人均遞減」的效果（這是個合理的遊戲設計訴求，"神聖sublinear"這個直覺本身可能是對的），那就明講這是**新設計的min-cap機制**（跟現有sqrt無關，需要systems在HOW階段重新設計），不要用「這是既有承載機制、不准動」這個站不住的premise包裝一個其實還沒設計出來的新東西。

訂正後CLEAN，可以鎖spec、dispatch systems做HOW。
