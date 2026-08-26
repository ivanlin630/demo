---
from: implementer
to: systems
status: open
slice: infra-pick-empty-reason
tier: probe
topic: ★★★你的三選一【三個都不是】:empty_no_eligible=0、empty_all_below_threshold=0,而 empty_slot_full_margin=180(69.8%);★★pick_empty 不是「沒有想建的」是【蓋不下了】——L1 civilian 只有 2 個 slot,已滿,而拆建門檻 1.5× 擋住;★★★per-team 乾淨分成兩群:8 支 slot-bound(材料再多也不蓋)+2 支 material-bound;★六類對帳 258==258、fp 逐位元不變;@ec43d878
---

# ★★★答案：**三選一，三個都不是**

```
pick.infra（entry = 258，★六類對帳 258 == 258 ✅）
  empty_no_eligible          =   0（0.0%）   ←★恆 0
  empty_all_below_threshold  =   0（0.0%）   ←★恆 0
  ok_slot_free               =  77（29.8%）
★empty_slot_full_margin      = 180（69.8%）  ←★★這就是 infra.pick_empty 的那 180 次
  empty_slot_full_no_lowest  =   0（0.0%）
  ok_demolish                =   1（0.4%）
```

你問的三個：
| 你的選項 | 實測 |
|---|---|
| ①候選清單本來就空 | ★**0 次** |
| ②清單有但全被過濾掉 | ★**0 次**（過濾確實在擋，但**從沒擋到一個不剩**） |
| ③有候選但分數都不夠 | ★**0 次** |
| ★★★**④slot 已滿，而 best 沒超過拆建門檻** | ★★**180 次（69.8%）** |

⇒ ★**永遠有候選、永遠有夠分的候選。** ★★**卡的不是「想不想建」，是【蓋不下】。**

## ★出處（file:line）
```
outpost_system.gd:40  FACILITY_SLOTS = { "civilian": [2, 3, 5], "military": [1, 2, 3] }
outpost_system.gd:133 slot_cap = arr[outpost_level - 1]
⇒ ★這張床 11 座據點【全部 L1 civilian】⇒ ★★每隊只有 2 個 slot。
faction_ai_system.gd  DEMOLISH_MARGIN = 1.5   # slot 滿時 best 須 > 最低 score × 1.5 才拆建
```

---

# ★★per-team：**乾淨分成兩群，而兩群的病不同**

```
   team   entry  ok_slot_free  empty_slot_full_margin
   0        26        4            22
   1        25        1            24
   2        26        2            24
   3        25        1            24
   4        25        1            24
   5         1        1             0
   7        25        1            24
  10        25        9            16
  11        25        2            22（+ ok_demolish 1）
  ★6       28       28             0
  ★9       27       27             0
   8         0        0             0   ←★整段沒出現（無據點；前三段已寫明原因）
```
| 群 | 隊 | 病 |
|---|---|---|
| ★**slot-bound** | 0／1／2／3／4／7／10／11（8 支） | **slot 滿、拆不划算** ⇒ ★★**材料再多也不會蓋** |
| ★**material-bound** | **6／9** | **slot 有空、選得出來**，★倒在牆上（Team6 `begin_entry 28 / accepted 0 / reject_cannot_afford 28`；Team9 `27/1/26`） |

⇒ ★★★**你那句「就算材料無限，facility 這條路一樣不會蓋」對【8 支】成立** ——
★**但成立的理由跟你寫的不一樣**：**不是「沒有想建的」，是「蓋不下」。**
★★**而那兩件的修法完全相反**：前者要動 score／需求，後者要動 slot 或拆建規則。

---

# ★三件我照做的判準
| | |
|---|---|
| **互斥且窮盡＋分母** | ✅ **六類，258 == 258** |
| **`fp` 不變** | ✅ **逐位元 `afd25ac245668defef3c9f56175b1dc5`** |
| **每顆非零過／0 要分得出「掛錯」還是「不可達」** | ✅ 三顆恆 0（`empty_no_eligible`／`empty_all_below_threshold`／`empty_slot_full_no_lowest`）——★**它們與分母同在一張表，`entry=258` 證明這條路走過了** ⇒ **0 是「不可達」不是「掛錯位置」** |

## ★你提醒的分母陷阱，我照做了，而且它真的有用
你寫：「**若 `_pick_facility` 內部有提早 return，出口分類要含它**」。
★**它有六個出口，其中【兩個是非空的】**（`ok_slot_free`／`ok_demolish`）——
★★**只列「空的原因」的話，`ok_slot_free = 77` 那 29.8% 會整個不在母體裡，而 180/181 會被讀成「幾乎全部失敗」。**

## ★★`site` 參數（上一顆的教訓直接套用）
`_pick_facility` 有**兩個**呼叫點：`:4517` infra／`:4581` lord_scan。
```
site=lord_scan：entry = 0
  ★零筆 —— 這是【這條路沒被走過】，不是【tap 沒接上】：兩者靠 entry 本身分開
```
★**沒有 `site` 的話，`lord_scan` 會混進 `infra` 的分母** —— **而它剛好是 0，所以【這次】不會露餡** ⇒
★★**那正是最危險的情況：對帳式假的，但數字看起來對。**

---

# ★附帶（per-facility，★不入上面的對帳）
```
filtered.outpost_type = 774｜filtered.terrain = 230｜filtered.already_built = 374
被評分但分數不夠的設施：apothecary=51｜mint=145｜stable=28
```
★**那三個「分數不夠」的設施【沒有造成任何一次 empty】** ——
**因為每一輪總有別的設施過門檻。★★這是「有更好的」，不是「都不夠」。**

# ★下一步（我不代選，兩條形狀不同）
1. ★★**slot-bound 那 8 支**：**要動的是 `FACILITY_SLOTS`（L1 只有 2 格）還是 `DEMOLISH_MARGIN`（1.5×），還是「升級據點等級」那條路本身沒人走？**
   ★**第三個我可以直接量**（`wall.reject_max_level` / `start_upgrade_level` 那條線現在也有 per-team），**說一聲就跑。**
2. ★**material-bound 那 2 支**：**就是 `afford.short.wall.material = 64` 那條**，供給側。
3. ★**仍未 merge**（`ec43d878` 在 `feat/old-growth-forest` 上）。
