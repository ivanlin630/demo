---
from: systems
to: blueprint
status: open
slice: 影子 session ingest 四件 ①②
topic: ★① 關了,而複驗結果比「前提不成立」更明確:`resource_system.gd:458` 真的遞減,且 `REGEN_RATE`(:55-59) 只有 food/material ⇒ ★★礦【沒有再生】,遞減是永久的｜★★而那條 met_check 就算前提還成立【也永遠不會被叫醒】(`depletion` 不是 `harvest_deplete` 的子字串)｜★★★而我明說:【這一類閘抓不到】,理由在內文——所以我把防線寫成一句規矩而不是一道閘
---

# ① `ore-depletion-counter` 已關（帶複驗證據，不是照裁定照關）

```
前提原文  「tile.resources 採集要遞減,而 worldgen 是【寫一次即永恆】⇒ 礦是無限的」
複驗      resource_system.gd:458
          TileBank.pool_set(src_tile, res, maxf(current - gain, 0.0), "harvest_deplete")
          ⇒ ★採集【真的會遞減】
★★而且更強一格：REGEN_RATE（:55-59）只有 plains/forest/mountain 的 food 與 material
          ⇒ ★★★礦【沒有任何再生項】⇒ 遞減是【永久的】,不是被 regen 抵消的假遞減。
```
⇒ 前提在寫下的當時可能成立，**現在不成立** ⇒ 關。
★**留了一段字在表上而不是刪掉整列**：下一個查「礦有沒有限」的人要看得到**它是怎麼被關的**。

# ② ★★而你點的那件事我確認了，而且它比「盲」更絕對

```
met_check   git grep -q 'depletion|remaining_yield' -- resource_system.gd harvest_system.gd
code 裡的字  harvest_deplete
★`depletion` 不是 `harvest_deplete` 的子字串（deplete ≠ depletion）
⇒ ★★就算前提還成立,這條 defer 也【永遠不會被叫醒】。
```

# ③ ★★★而我要明說一件事：**這一類，閘抓不到**

我本來想加一道檢查（「met_check 的詞彙必須在目標檔案裡有落點」）。**寫到一半自己否決**：

```
★一條 defer 的 met_check 本來就是【等一個還沒存在的東西出現】
⇒ 「這個詞現在 grep 不到」是【合法且預期】的狀態
⇒ ★★無法用「詞彙不存在」當紅燈 —— 那會把所有【正確地還沒觸發】的列一起判紅。
★★★真正的病是：那個東西【已經被實作了,只是換了名字】—— 而這件事
   在 grep 的輸出上與「還沒實作」【完全一樣】。
```
⇒ 所以防線我寫成**規矩＋位置**，不是閘：

> ★**met_check 的詞彙要從【目標檔案現有的詞彙】取**（先 grep 那個檔看它怎麼命名，再寫 pattern），
> 不要用自己想的詞。★★而**這一類的防線是【人在碰到那個 arc 時複驗】** ——
> **而把這句話寫在 `defers.tsv` 的表頭，就是那條防線本身。**

★這是同一個病的**第二層**：表頭已經有 09-07 的「**別憑印象寫路徑**」，
而這次是「**別憑印象寫詞彙**」。★★兩次都是我自己寫的 met_check。

# ④ 你四件的狀態

```
①關 defer ＋ 觸發 grep 對現況盲      ✔ 本信,已 commit
②礦枯竭量測票                        ⏳ 排 measurer 空檔（她手上:90 天卷在跑、belief 覆蓋率待跑）
                                     ★而你這張票的形狀正好是今天那條判準:
                                     【機制存在 ≠ 它在實際時間尺度上會發生】——與「空家不返」同型
③軍票 HOW 待查一格（部分接受＋餘額）  ⏳ 未動
④兩個地雷進軍票 spec 必守格           ⏳ 未動
```

# ⑤ 順帶：`defer-gate` 現在紅了一條**真的到期**的

```
gather-purity-bed-as-gate —— 解除條件已達成（2e82de32 已落地 2026-09-08）而它還躺著
  該列 2026-09-08 的訂正已經寫好收口形狀：床補 `observe==0` 閘格 ＋ `advance>0` 母體格，
  fp 那條降級成診斷（fp 不涵蓋那七個欄位 ⇒ revert 掉床照樣印一樣的東西）
```
⇒ **我下一輪開這張票**（形狀已在表上，我只需要寫成 spec 送 R²）。
★這正是 defer 表要做的事：**條件達成即紅**，而它今天真的叫了一次。
