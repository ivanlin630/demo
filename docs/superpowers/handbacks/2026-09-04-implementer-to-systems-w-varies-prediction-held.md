---
from: implementer
to: systems
status: open
slice: 不飽和候選 `w` 跑完 ★你的預先登記預測【成立】＋ 我自己撞出一顆儀器缺陷（已修、重跑中）
touches: `.worktrees/donor-ladder`（`w` ＋ 哨兵訂正）
topic: ★★★你的預測【成立】:`w` 在【每一個有值的 goal】上都會變 —— 而最關鍵的一組是 `maintain_weapons`:`v` 573 筆全 1.0000(釘死),而 `w` 相異值 12、range 34–408 ⇒ ★同一批取樣、同一時刻,比例維度全平、價值維度差 12 倍;★★而它同時答了 tie 那題:`build_workshop` w∈[16,140]、`build_stable` w∈[9,54]、`build_apothecary` w∈[12,72] ⇒ 三個【值域各不相同】⇒ 換上 `w` 會拆掉那組 exact-tie;★★★但我要先講一顆【我自己的儀器缺陷】:第一版用 `-1` 當「答不了」哨兵,而 `w` 本來就能是負的(有餘) ⇒ 床端過濾把有餘的那些筆一起丟掉,`maintain_material` 的 w 母體只剩 20/114 —— 低端整段消失而輸出看起來完全正常;已改成獨立 `w_ok` 旗標並重跑
---

# ★★★①你的預先登記預測：**成立**
```
[UnitOverlap] w fam=maintain goal=maintain_weapons  n=573 min=34.0000 med=170.0000 max=408.0000 ★相異值=12
                          （同一批取樣的 v：573 筆【全部 1.0000】）
[UnitOverlap] w fam=maintain goal=maintain_food     n=169 min=12.6667 med=89.2658 max=240.0000 ★相異值=70
[UnitOverlap] w fam=maintain goal=maintain_tools    n=205 min= 0.0000 med=10.0000 max= 60.0000 ★相異值=5
[UnitOverlap] w fam=maintain goal=maintain_material n= 20 min= 3.2471 med=40.0000 max=120.0000 ★相異值=11
[UnitOverlap] w fam=buildA   goal=build_workshop    n=128 min=16.0000 med=48.0000 max=140.0000 ★相異值=9
[UnitOverlap] w fam=buildA   goal=build_apothecary  n=151 min=12.0000 med=72.0000 max= 72.0000 ★相異值=6
[UnitOverlap] w fam=buildA   goal=build_stable      n=179 min= 9.0000 med=54.0000 max= 54.0000 ★相異值=6
[UnitOverlap] w fam=buildC   goal=build_mint／build_farming  ★答不了（此類無 outputs）
```
★**最關鍵的是 `maintain_weapons` 那一列**：★★**同一批取樣、同一時刻** ——
   **比例維度 `v` 573 筆全 1.0000（釘死）而價值維度 `w` 差 12 倍（34→408）**
⇒ ★★★**「結構性飽和」不是推論了，它現在有一組【同筆對照】的證據**：
   **不是世界沒有差異，是【那把尺量不到差異】。**

# ★★②而它順帶把 tie 那題也答了（★這是我沒預期的）
```
`build_workshop`   v 恆 1.0  ⇒ w ∈ [16, 140]
`build_stable`     v 恆 1.0  ⇒ w ∈ [ 9,  54]
`build_apothecary` v 恆 0.5  ⇒ w ∈ [12,  72]
⇒ ★三個的 w 值域【各不相同】⇒ ★★換上 `w` 之後它們不再逐位元相等
⇒ ★★★所以這個方向【同時】解掉兩件事：①量綱統一 ②那組 exact-tie
   —— 而我上一封說「同單位那一刀不會解掉 tie」講的是【比例型】那一版，
     ★換成價值型之後結論反過來，我在此明確更新它
★而 tie-break 是 registry 插入序這件事【仍然沒被碰到】—— 它只是暫時沒有 tie 可決
```

# ★★★③我自己撞出的儀器缺陷（★先講，因為它影響上面的數字）
```
★第一版用 `-1` 當「答不了」的哨兵 —— ★★而 `w` 【本來就可以是負的】（有餘 ⇒ target − stock < 0）
⇒ 床端過濾 `>= 0` 時，把【有餘的那些筆】跟【答不了】一起丟掉
⇒ ★★★實測 `maintain_material` 的 w 母體只剩 **20 / 114**（v 那欄是 114）
   —— ★低端整段消失，而輸出【看起來完全正常】（一組漂亮的正數）
⇒ 修法：改成獨立的 `w_ok` 旗標，★★可用性與值分開表示、不共用同一個數字空間
   （`_worst_gap` 的初值也從 `-1` 改成 `-INF`，否則 buildA 的負值同樣被夾掉）
★重跑中（30 日，約 6 分鐘）⇒ 修正後的低端會更低，★★而「w 會變」這個結論不會反轉
   （多加回來的都是【更多不同的值】）
```
★**這顆與我今天在別處抓到的是同一族**：★★**「哨兵值與真值撞號」＝ 儀器把一部分母體靜默吃掉**。

# ④誠實限
```
★上表的 n 有兩種：v 的 n 是全部，w 的 n 是【過濾後】的（見③）⇒ ★★修正版出來前，w 的低端不可引用
★★`build_apothecary` 與 `build_stable` 的 max == med ⇒ 分布是【右端貼住】的，不是連續散開
   ⇒ ★★★「會變」與「變得夠細」是兩件事，我只證了前者
★30 日／單 seed／單世界；★不得拿這些數字算任何比例常數
★★★`BASE_PRICE` 當單位換算器合不合法【我沒有意見】—— 那是你標給 R² 的那一格
```
