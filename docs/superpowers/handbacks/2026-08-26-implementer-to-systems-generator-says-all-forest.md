---
from: implementer
to: systems
status: open
slice: generator-ranking-probe
tier: probe
topic: ★★★數字回來且是極端值:產生器前 11 名【11/11 全是 forest】(偏好倍數 3.50×),而手寫床擺的是 plains 8／mountain 3／forest 0 ⇒【零重疊】;★我多報了全圖母體分布,理由在內;★床一行未改;@d56da03a
---

# 產生器排名的地形分布 — 數字

| | |
|---|---|
| **worktree / branch** | `A:\GDS\demo\.worktrees\gen-ranking`／`feat/generator-ranking-probe` |
| **commit** | `d56da03a` |
| **落地** | `docs/measurements/2026-08-26-generator-ranking-terrain.txt` |
| **床** | ★**一行未改**（照你說的先只要數字） |

# ★★★結果
```
[peaceful_economy / seed 1337] tiles = 217

母體（全圖）      ：plains 105（48.4%）｜forest 62（28.6%）｜mountain 50（23.0%）
★產生器前 11 名  ：forest 11  ——【100%】，★偏好倍數 3.50×
★★這張床實際擺的：plains 8｜mountain 3｜forest 0
```
⇒ ★★★**零重疊。產生器最想去的 11 格【全是 forest】，而床上一座 forest 據點都沒有。**

## ★逐格（前 11 名，供你決定改法時直接用）
```
#1 (2,9)  #2 (9,3)  #3 (9,13) #4 (10,2) #5 (7,2) #6 (5,5)
#7 (5,4)  #8 (4,15) #9 (9,4)  #10 (3,8) #11 (4,5)   ★全部 forest
```

# ★我多報了一欄：**全圖母體分布**（★你沒要，但沒有它那個 100% 讀不出意思）
★**若只報「前 11 名有 11 座 forest」** ⇒ **讀的人分不出是【產生器偏好 forest】還是【這張圖本來就一堆 forest】** ——
★★**兩者結論相反**：前者代表床跟產生器不一致，後者代表床只是反映地圖。
⇒ **附上母體才算出 `3.50×` 這個偏好倍數** —— ★**forest 只佔全圖 28.6%，卻吃下前 11 名的 100%。**

# ★★這個數字對你的裁決意味什麼（★我只講讀法，不挑改法）
★**「改幾座」這個問題的答案不是一個數字，是【床與產生器的差距有多大】** ——
**而量出來是【完全不重疊】，不是「差幾座」。**
⇒ ★★**所以你上一封留的三個選項裡，「換幾座」那個選項在資料上是最弱的** ——
**它預設了兩者大致相符、只差幾座，而實際是零重疊。**
★★★**但要不要整批照排名重擺、或判定手寫床不該留，那是你的裁決，我不代選。**

# ★一件小事
★`WorldGenerator` **沒有 `class_name`** ⇒ 我照既有 caller 的載法（`game_setup.gd:93` 的
`load("res://scripts/simulation/world_generator.gd").new()`）。**第一版我寫 `WorldGenerator.new()`，parse error。**
★★**照紀律先看錯誤原文再改** —— **這次錯誤直接說了名字沒宣告，一眼可辨，沒有走冤路。**
