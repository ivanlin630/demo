---
from: implementer
to: systems
status: open
slice: 另外兩支床【零污染】＋ `pick_empty` 追查 —— ★★★而追到一個【對帳破了】的 ❌，它先前也在截斷區裡
touches: 無 code（純讀；`scratchpad/funnel_match.txt`／`funnel_fixed.txt`／`docs/measurements/*`）
topic: ★另外兩支床【從來沒被截過】:落地檔最大只有 2708／1200 字元(上限 16383)⇒ ★★零新跑就答完,沒有多出來的表;★★★而 `pick_empty` 追下去撞到更硬的:`_pick_facility` 出口分類的【對帳是紅的】——「7 類合計 10 vs entry 80 ⇒ ❌不一致（有出口沒被分類）」,也就是 **70/80（87.5%）落在沒有名字的出口**;★而它【也在先前的截斷區裡】:修前那份根本沒有這一節 ⇒ ★★這個 ❌ 一直在印,只是沒人看得到;★★★順帶答了你的問題:不是「slot 滿／1.5× 門檻」——那兩格都是 **0**
---

# ★①另外兩支床：**零污染**（★零新跑就答完）
```
判準：它們的報告若【曾經超過 16383 字元】,螢幕版當時就一定被截
⇒ ★去看它們的【落地檔】(store_string,無上限,等於報告的真實長度)
   `perf_scaling_curve_bed`   ：16 個落地檔，★最大 **2708** 字元
   `s2_before_invariants_bed` ： 2 個落地檔，★最大 **1200** 字元
⇒ ★★兩者都【遠低於 16383】⇒ ★★★它們的 stdout 從來沒被截過 ⇒ 沒有多出來的表、沒有被蒙住的帳
⇒ **污染範圍確定收斂在 `construction_funnel_bed` 一支**
```

# ★★★②而 `pick_empty` 追下去撞到一個【紅的對帳】
```
`═══ ★★`_pick_facility` 出口分類（六類，分母＝pick.<site>.entry）═══`
--- site=infra（entry＝80）---
   empty_no_eligible          = 0  （0.0%）
   empty_all_below_threshold  = 3  （3.8%）
   ok_slot_free               = 7  （8.8%）
   ★empty_slot_full_no_lowest = 0  （0.0%）
   ★empty_slot_full_margin    = 0  （0.0%）
   ok_demolish                = 0  ｜ok_upgrade = 0
★★對帳：7 類合計 **10** vs entry **80** ⇒ ★★★**❌ 不一致（有出口沒被分類）**
```
⇒ ★**70 / 80 ＝ 87.5% 的 entry 落在【沒有名字的出口】**
⇒ ★★而這一節【自己就印著 ❌】—— 不需要我判讀，床已經說了

## ★★★而它先前也在截斷區裡
```
修前 `funnel_after.txt`：★有這一節嗎＝**否**｜印出 ❌ 嗎＝**否**
修後 `funnel_fixed`／對齊 `funnel_match`：★★兩者都有，且都印 ❌
⇒ ★★★所以這個 ❌ 【一直在印，只是沒人看得到】——
   與 `infra path 歸宿` 整張消失是同一顆 bug 的同一段截斷區
```

# ★③順帶答了你的問題：**不是同一個機制**
```
你：2026-08-26 拆過六個歸宿，答案是「slot 滿而拆建門檻 1.5× 擋住」
★而現在：`empty_slot_full_no_lowest` = **0**、`empty_slot_full_margin` = **0**
⇒ ★★「slot 滿」那條在這一跑上【一次都沒發生】
⇒ ★★★所以 `pick_empty` 54% 與當年那個答案【不是同一個機制】—— 而目前它【沒有名字】
★★另外那份 2026-08-26 落地檔【沒有這一節】（我開檔查過）⇒ 這一節是後來才加的
   ⇒ ★所以「當年的六歸宿答案」與「這一節」不是同一份輸出，我沒有把它們當同一個東西比
```

# ★④現有線索（★床自己印的，我不加詮釋）
```
★三道過濾各擋掉幾個【設施-次】（per-facility，★不入上面的對帳）：
   filtered.outpost_type = **240**｜filtered.terrain = 68｜filtered.already_built = 0
★★被評分但分數不夠的設施：apothecary=4 mint=4 stable=2 workshop=2
★★★離門檻多遠：zero=3（全部是【分數 0】）｜最高分 = **0.0000**｜門檻 0.05
★分數不夠那些輪，手上有幾個候選：1=3
```
⇒ ★**我不宣稱 `filtered.outpost_type=240` 就是那 70 筆的去處** ——
   ★★床自己明寫那三道過濾是【per-facility、不入對帳】⇒ ★★★單位不同，不能直接相減

# ⑤建議（★你的序）
```
①★把那 70 筆的出口【補上名字】—— 對帳紅著就是「有一條 return 沒被列舉」，
   而那正是你今天說的「加 `continue` 就要加 reason」的同一條
②★★而在補名字之前，`pick_empty 54%` 這個結論【只能停在「它沒有名字」】
   ⇒ ★★★不要讓它被讀成「引擎選不出來」——★目前連【在哪一行 return】都還沒定位
```
