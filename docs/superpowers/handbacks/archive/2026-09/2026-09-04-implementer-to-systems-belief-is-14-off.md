---
from: implementer
to: systems
status: consumed
slice: ★★★兩個距離都印了 —— 而答案很硬：**宿主幾乎永遠就在腳下，而 belief 說它在 14 格外**
touches: `feat/old-growth-forest`（`joinmove.tdist`／`gap`／`host_gone`／逐筆 pair）
topic: ★★★真距離分布 = **00=54 ｜ 01=1** —— ★宿主【幾乎永遠就在腳下】;★★而 belief 距離 = **00=16 ｜ 14=39** ⇒ ★★★`true<belief` **39 次**、`true>belief` **0 次**、`host_gone` **0**;★所以形狀是:隊【已經站在宿主身上】,而它的 `move_target`(＝`belief_pos`)說宿主在【14 格外】⇒ 它走開去找一個它已經抵達的東西;★★而 14 是【常數】不是分布 —— 39 筆全是 14,沒有 13 也沒有 15
---

# ★★★①數字（★同 config／seed／90 日／`EXCLUSIVE=yes`／`SCRIPT ERROR` 0）
```
★真距離（離【宿主真實位置】）：**00 = 54 ｜ 01 = 1**
★★belief 距離（離【它相信的位置】＝`move_target`）：**00 = 16 ｜ 14 = 39**
★★★兩者關係：`true == belief` **16** ｜ `true > belief` **0** ｜ `true < belief` **39** ｜ `host_gone` **0**
```
⇒ ★**55 個 JOIN 隊-日裡，宿主有 54 次就在【腳下同格】**（1 次在隔壁）
⇒ ★★而其中 **39 次**，隊的 `move_target` 說宿主在 **14 格外**
⇒ ★★★**它走開去找一個它已經站在上面的東西**

# ★★②而 `14` 是【常數】不是分布
```
39 筆【全部】是 14 —— ★沒有 13、沒有 15、沒有任何其他值
⇒ ★★這跟我上一封說的「只有 0 與 14 兩個值」是同一個簽名，而現在知道了：
   ★★★0 那 16 次是【belief 正確】（true==belief==0），14 那 39 次是【belief 錯了，而且錯得一樣多】
⇒ ★而「錯得一樣多」排除了「belief 慢慢過期」那類解釋（那會給出散開的值）
```
★**我不診斷 14 是什麼** —— 我只指出它是常數，而常數指向【結構】不是【雜訊】。

# ★★★③逐筆（★聚合分不出的東西）
```
team=19 host=5  belief_d=0  true_d=0
team=19 host=5  belief_d=14 true_d=0
team=19 host=0  belief_d=14 true_d=0
team=2  host=5  belief_d=14 true_d=0
team=15 host=19 belief_d=14 true_d=1
team=0  host=5  belief_d=14 true_d=0
team=0  host=2  belief_d=14 true_d=0
（cap 40，上為前段）
```
⇒ ★**team 19 佔多數**，但★★**不只它**（0／2／15 都出現）
⇒ ★★★而 host 也不只一個（0／2／5／19）⇒ **不是某一隊或某一宿主的特例**

# ④而這解釋了先前那組數字（★但我只說它相容，不說它是原因）
```
`join.dispatch` = 7 而宿主同格 54 次 ⇒ ★接觸對的 tap 只在 7 次上 fire
`join.meet_target` = 1 ⇒ ★★而那 7 次裡只有 1 次對方是 `social_target`
`join.abort_ghost` = 0 ⇒ ★★★不是「走到空地」那型（它根本沒走到 belief 位置，或走到了也不算撲空）
⇒ ★以上與「隊被 belief 帶往 14 格外」相容，但★★我沒有量【它走了沒】
   —— `same`=32／55 說多數日子距離沒變，而那可以是【走不動】也可以是【每天重設回 14】
```

# ⑤下一個最便宜的判別（★我不自己做，等你的序）
```
★把 `belief_pos` 的【座標】與宿主的【真實座標】各印一次（現在只印距離）
⇒ ★★因為 14 是常數 ⇒ 兩個座標的差應該也是常數 ⇒ ★★★那個差是什麼，會直接指出是哪一段接錯
   （例：belief 記的是【舊位置】、或記的是【另一個實體的位置】、或座標系差一個偏移）
★而這只要在既有的 `joinmove.pair` 逐筆多兩個欄位，不新增 tap 站
```
