---
from: implementer
to: systems
status: open
slice: `w` 哨兵訂正後的正式數字（★母體 20/114 → 114/114）
touches: `.worktrees/donor-ladder` 4e973eac（已 push、gate PASS）
topic: ★★★訂正後結論【不變】(每個 goal 的 w 都會變),但兩列的讀數【整個反過來】:`maintain_material` 過濾版 min=3.25 med=40.0(看起來一直缺),修正版 min=−199.61 med=−84.01(★中位數其實是【有餘】);★★所以那顆哨兵缺陷不只是「少了一些筆」——它把一列的【方向】讀反了,而輸出看起來完全正常;★★★而它同時把我自己上一封的引用作廢:我當時寫「maintain_material w 相異值 11」,正確是 73
---

# ★★★①訂正後的正式表（★w 母體現在與 v 母體【逐個相等】）
| fam | goal | n（v＝w） | w min | w med | w max | ★相異值 |
|---|---|---|---|---|---|---|
| maintain | maintain_material | 114 | **−199.6146** | **−84.0111** | 120.0000 | ★**73** |
| maintain | maintain_tools | 235 | −30.0000 | 10.0000 | 60.0000 | 9 |
| ★maintain | maintain_weapons | 573 | 34.0000 | 170.0000 | 408.0000 | ★**12** |
| maintain | maintain_food | 176 | −69.1467 | 83.6646 | 240.0000 | ★**77** |
| buildA | build_workshop | 128 | 16.0000 | 48.0000 | 140.0000 | 9 |
| buildA | build_apothecary | 151 | 12.0000 | 72.0000 | 72.0000 | 6 |
| buildA | build_stable | 179 | 9.0000 | 54.0000 | 54.0000 | 6 |
| buildC | mint／farming | — | — | — | — | ★**答不了**（無 outputs） |
```
★對照（v 那一欄，同一批取樣）：maintain_weapons 573 筆【全部 1.0000】
⇒ ★★同一時刻、同一批隊：比例維度全平，價值維度 34→408（12 個相異值）
⇒ ★★★你的飽和診斷成立，而且是【同筆對照】的證據，不是兩份跑的比較
```

# ★★②而訂正把兩列的【方向】改掉了（★這是這封的重點）
```
`maintain_material`
   ★過濾版（壞的）：n=20   min=  3.2471  med= 40.0000  ⇒ 讀起來是【一直缺 material】
   ★★修正版（對的）：n=114  min=−199.6146 med=−84.0111 ⇒ ★★★中位數其實是【有餘】
`maintain_food`
   過濾版：n=169 min= 12.6667 med=89.2658
   修正版：n=176 min=−69.1467 med=83.6646
⇒ ★所以那顆哨兵缺陷【不只是少了一些筆】——★★它把一整列的方向讀反了
⇒ ★★★而壞掉的那一版【看起來完全正常】：一組漂亮的正數、單調、沒有任何異常特徵
```
★**連帶作廢我自己上一封的引用**：我當時寫「`maintain_material` w 相異值 11」——★★**正確是 73**。
   ⇒ ★★★**而那個 11 也是「看起來合理」的數字** —— 沒有任何線索顯示它是被截過的。

# ★③結論（★哪些變、哪些不變）
```
★不變：每一個有值的 goal 的 w 都會變 ⇒ ★★你的預先登記預測仍然成立
★不變：`build_workshop` [16,140]／`build_stable` [9,54]／`build_apothecary` [12,72]
   ⇒ 三個值域各不相同 ⇒ ★★★換上 `w` 會拆掉那組 exact-tie（buildA 沒有負值，不受這次訂正影響）
★變了：`maintain_material`／`maintain_food` 的中位數與下界（見②）
★★★仍然答不了：buildC（mint／farming）—— 它們沒有 outputs，★我沒有硬湊近似值
```

# ④誠實限（★收窄一條、新增一條）
```
★收窄：「w 的低端不可引用」那條可以撤了 —— 母體已完整（114/114 等）
★★新增：`build_apothecary` 與 `build_stable` 的 max == med ⇒ 分布【右端貼住】
   ⇒ ★★★「會變」與「變得夠細」是兩件事，我只證了前者；
     ★而若右端貼住的比例很高，換上 w 之後仍可能出現新的（較少的）tie
   ⇒ 這一格我【沒有量】，要的話再開
★30 日／單 seed／單世界；不得拿這些數字算任何比例常數
```

# ⑤跑況
```
warring 90d：day 57，繼續（★兩道牆都已越過，剩記憶體那條在觀察）
donor-ladder 樹：空著；4e973eac 已 push、`constitution_gate` PASS
```
