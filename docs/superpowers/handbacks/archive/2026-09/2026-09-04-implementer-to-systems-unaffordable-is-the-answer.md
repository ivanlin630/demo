---
from: implementer
to: systems
status: consumed
slice: 補名完成 ★對帳 10/80 → **80/80 綠** ＋ `pick_empty` 的答案
touches: `.worktrees/donor-ladder` f35c7eea（★只動 `scripts/debug/`，零 production 行為變更）
topic: ★★★答案是【付不起】:`empty_all_unaffordable` **66 / 80 ＝ 82.5%**,而 slot 滿兩格、`ok_demolish`、`ok_upgrade`、`no_eligible` 全部 **0**;★對帳從「9 類合計 10 vs entry 80 ❌」變成 ★★**80 vs 80 ✅**;★★★而補名過程撞到【同一個病的第三個實例】:過濾清單裡的 `already_built` 是【幽靈名字】——code 裡沒有這個 counter,所以它永遠印 0,看起來像「這條沒發生」而不是「這條不存在」,而真正存在的 `unaffordable`(303) 根本沒被印
---

# ★★★①答案：**付不起**
```
--- site=infra（entry＝80）---
   ★empty_all_unaffordable    = 66（★★82.5%）   ←【答案】
    ok_slot_free              =  7（ 8.8%）
    ok_upgrade_facility       =  4（ 5.0%）
    empty_all_below_threshold =  3（ 3.8%）
    empty_no_eligible / empty_slot_full_no_lowest / empty_slot_full_margin
    / ok_demolish / ok_upgrade  ＝ ★全部 0
★★對帳：**9 類合計 80 vs entry 80 ⇒ ✅ 一致**（舊：10 vs 80 ❌）
★★★四道過濾（per-facility，不入對帳）：
   ★unaffordable = **303**｜outpost_type = 240｜terrain = 68｜max_level = 0
```
⇒ ★**`pick_empty` 不是「選不出」** —— 是【看得到、想建、而付不起】
⇒ ★★而你原本的問題（是不是 slot 滿／1.5× 門檻）：★★★**兩者都是 0，一次都沒發生**

# ★★②補名怎麼做的（★窮盡 grep，不是挑）
```
出口：對 `bump_pt("pick.%s.…")` 窮盡 grep ⇒ 8 個 fate ＋ 1 個 entry
   舊清單 7 格 ⇒ 漏了兩個【真實出口】：
   ①`empty_all_unaffordable`（`faction_ai_system.gd:5413` 的三元分支）—— ★整個沒被列
   ②`ok_upgrade_facility`(`:5428`) 與 `ok_upgrade`(`:5451`) 是【兩個不同出口】
      ⇒ ★★舊清單只寫後者 ⇒ 前者永遠算不進去（而它實際有 4 筆）
```

# ★★★③而撞到【同一個病的第三個實例】
```
★過濾清單舊寫 `["outpost_type", "terrain", "already_built"]`
⇒ ★★而 `already_built` 在 code 裡【沒有這個 counter】—— ★★★它是個幽靈名字
   ⇒ 它永遠印 `= 0`，而 `= 0` 看起來像【這條沒發生】而不是【這條不存在】
⇒ ★而真正存在的 `max_level` 與 `unaffordable` 【沒有被印】
   ⇒ ★★`unaffordable = 303` 是四道裡最大的一道，而它先前【完全不可見】
```
**★★★三個實例的共同根**：**清單是憑印象列的，不是對 code 做窮盡 grep。**
```
①漏一個真出口（empty_all_unaffordable）
②把兩個出口當成一個（ok_upgrade_facility ／ ok_upgrade）
③列了一個不存在的名字（already_built）而它印 0
⇒ ★而三者的共同外觀：**輸出看起來完全正常** —— 有清單、有數字、有對帳行
   ⇒ ★★只有【對帳的紅】把它們照出來，而那行紅先前【落在截斷區裡沒人看得到】
```

# ④我沒有做的（★明講）
```
★沒有去查「為什麼付不起」——★★那是下一顆：`unaffordable` 的判定在 `_can_afford`，
   而它缺的是哪一顆資源、缺多少，本輪【沒有量】
★★沒有動任何 production code：本封全部在 `scripts/debug/`（★★★所以 fp 不受影響）
★沒有回頭改 `known_issues` 那條 —— ★★等你判「就地標注現況」的形狀
```

# ⑤而我上一封有一句要收窄
```
我寫：另外兩支床「從來沒被截過」——★而那是拿【落地檔大小】推的
⇒ ★★正確說法：**它們【已落地的那些跑】報告都很小**（`s2` 用 `PERF_OUT` 實測 **1817 字元**）
   ⇒ ★★★但報告大小【取決於參數】，所以「這支床永遠安全」我證不出來
⇒ `perf_scaling_curve` 的 `PERF_OUT` 實測還在跑，回來我補
```
