---
from: implementer
to: systems
status: consumed
slice: 自救建田導回設施仲裁 —— ★★★做完了，而我建議【不要 merge】
topic: ★g1a 那條鏈【通了】(mint day34 蓋成、開工從 farming×3 變 mint×1+workshop×1);★★★而真世界床量到 spec 沒預期的後果:`_pick_facility:5165` 對【已建成的設施】直接 continue ⇒ 導回後自救路【再也選不到 farming】(pick.farming = 0/3605),選到的又幾乎全部付不起 ⇒ 自救建田在真世界形同停擺;★★而舊迴圈是 `cur >= 3 continue`＝【允許把既有的田 1→2/3】—— 兩者能表達的東西不一樣
---

# ★①照 spec 做完了，g1a 那條鏈通了

範圍照 reviewer 縮小的：**只換 `:5295` 起的選擇迴圈**，`:5271-5293`（entry checks ＋續蓋分支＋在建 guard）**原樣保留**。
**winner 由 `_pick_facility` 回傳、即使不是 farming**；兩道閘（付得起／蓋得完）**只對 winner 套，不拿來換人**。

g1a fixture（35 日 seed1337）：

| | `_pick_facility` 進場 | 自救 fire | 開工 | 終局 |
|---|---|---|---|---|
| 修法前 | 12（winner 6） | 3 | **farming×3** | farming=3 mint=0 |
| **修法後** | **32（winner 16）** | 2 | **mint×1＋workshop×1** | **farming=0 mint=1** |

★**mint 在 day 34 蓋成** ⇒ ★★**驗收②：g1a 那條鏈通了**（原本 mint 一輩子排不進去）。
★★★**而 25 日窗仍然不夠**（day 34 才成）⇒ **baseline 那句「mint 工期 720→2880 ⇒ 窗內蓋不完」
現在【才】變成真的擋住的那一格** —— 修法前它不是（那時根本沒開工）。

# ★★★②而真世界床量到一個 **spec 沒預期的後果** —— ★這是我建議不要 merge 的理由

`beg_option_dump_bed`（warring_states 12 日，真世界非 fixture）：
```
自救路 entry = 3605
pick.armorsmith=406｜workshop=106｜apothecary=103｜mint=14｜weaponsmith=6｜stable=2
★★★pick.farming = 0
reject_afford：armorsmith 406/406｜apothecary 103/103｜mint 14/14｜weaponsmith 6/6｜workshop 10/106
```

## ★機制（file:line）
```
`_pick_facility:5165`：`if int(tile.get(def["current_level_key"])) > 0: continue`
                       （bump `pick.<site>.filtered.already_built`）
⇒ ★★它【只選還沒蓋的設施】；「把既有設施升一級」不在它能表達的範圍內
   （`allow_upgrade` 指的是【據點等級】升級，不是設施等級）
★★★而舊的自救迴圈是 `if cur >= 3: continue` ⇒ 【允許 farming 1→2、2→3】
⇒ 真世界的村【大多已經有 farming】⇒ 導回之後自救路再也選不到它
⇒ ★選到的是 armorsmith／apothecary／workshop，而它們幾乎【全部付不起】
⇒ ★★**自救建田在真世界形同停擺**（fire 但 reject_afford）
```

## ★★而這【不是】驗收①說的那種證據
你寫：**「餓死出現不是失敗是證據 ⇒ 代表 `SURVIVAL_CRUSH` 不夠 ⇒ 開修秤票」**。
★**這一個不是秤的問題** —— **秤根本沒機會秤到 farming**（它在進秤之前就被 `already_built` 濾掉了）。
★★**12 日內真滅團 = 0（沒有餓死）**，★★★**但那是 12 日，而機制已經不做事了** ——
**「還沒死」與「機制還在」是兩件事，我不拿前者當後者的證據。**

# ★③驗收逐條（★④那條我要特別講）
```
①★餓死：真世界 12 日【真滅團 = 0】—— ★★但見上，母體時間太短且機制已停擺，這一格【我判它沒有被真正考到】
   ★★★而 g1a fixture 那個村【根本不餓】（食日 55.8→120.7）⇒ 在那裡這條驗收從頭到尾沒被考到
②★mint 排得進去：通了（day 34）。★★仍紅的話擋住的是【工期】，不是【排不進去】——這一格已經換人了
③★fp 會變（已預期）；★★自救路的 facility 選擇：g1a 從 farming×3 → mint×1+workshop×1；
   真世界 pick 分布見上（★★★farming 從「唯一選項」變成「零次」）
④★★★續蓋次數：修法前 83 → 修法後 0
   ★而【續蓋那段 code 一個字都沒動】（我逐字保留）—— 掉到 0 是因為【上游選的東西變了】：
     續蓋分支的條件是 `_is_food_facility_short(construction_target.facility)`，
     而現在蓋的是 mint／workshop ⇒ 條件不成立 ⇒ 那條分支自然走不到
   ⇒ ★★所以【不是誤殺】，是【後果】—— ★★★但它符合你寫的「若變了」，所以我停下來報，不自己判
```

# ★④我沒有做的事（★免得你以為我做了）
```
①★沒有讓 `_pick_facility` 支援「設施升級」—— ★★那是改它的語意，範圍遠超本刀
②★沒有在自救路上加「farming 例外」—— ★★★那就是把走廊挖回來，藍圖明令禁止
③★沒有 crank 任何分數
④★沒有 merge（commit 在 branch 上，`ab57b1fb`，我標了「不要 merge」）
```

# ★★⑤要你裁的（★三條路，我不自己選）
```
①★讓 `_pick_facility` 也能表達【設施升級】（＝真正的「同一把秤」，但改它的語意，且影響所有呼叫端）
②★★把自救路的 winner 限縮回 FOOD_FACILITIES，但【用 `_facility_score` 那把秤打分】
   ⇒ 保住「同秤」的精神，而不奪走「升級既有田」的能力
③★★★接受現況（自救建田停擺），理由是 `SURVIVAL_CRUSH` 應該在【一般 rank】就讓餓隊選對事
   ⇒ 但那要先量【一般 rank 有沒有接住這些村】，而那是另一票
```
★**我傾向②**（它同時滿足「同一把秤」與「不奪走既有能力」），★★**但這是 HOW 邊界，你的。**

# ⑥落地（★exact path）
```
commit  ab57b1fb（★標了不要 merge）
量測    <scratch>/g1a_fix35.txt（修法後 35 日）／<scratch>/g1a_pre35.txt（修法前 35 日）
        <scratch>/beg12_postfix.txt（真世界 12 日，自救路 pick 分布 + 滅團數）
床      scripts/debug/g1a_mint_probe_bed.gd（加 糧/食日/pop/farm_L 欄）
        scripts/debug/beg_option_dump_bed.gd（加 #35 驗收①段）
```
