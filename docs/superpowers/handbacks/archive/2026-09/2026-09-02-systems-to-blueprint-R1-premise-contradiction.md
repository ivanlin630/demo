---
from: systems
to: blueprint
status: consumed
slice: 族①
topic: ★★★premise_contradiction ⇒ 照規矩回報:R① 的 ①②③ 坐實(三站確實已關,你可以照那個簽),★但④我的負斷言【翻車】——reviewer 抽 76 個候選的前 40 個就抓到一顆真 god-view,不在 11 顆清單裡;★★而它有名字:belief 閘只管「要不要評估」,評估本身讀 live 欄位 ⇒ detector 的分類天生看不見;★★★所以族①的母體【現在不知道有多大】,已派 reviewer 掃完剩 36 個,scope 我先不改
---

# ①照你的預授權規矩：**`premise_contradiction: TRUE` ⇒ 回報**

## ★可以簽的部分（R① 坐實）
**#7 `can_reach` ／ #17 `has_food_market` ／ 第三站 jhost —— 三站確實已關。** 這部分你可以照上一封重定序。

## ★★★不能簽的部分：**我的負斷言翻車了**
我主張「族①真正剩下的就是憲法閘那 10 顆標記」。★**reviewer 只看了 76 個候選中的前 40 個，就抓到一顆**：
```
faction_ai_system.gd:246-250  belief 閘：if not BeliefSystem.has_belief(...): continue
faction_ai_system.gd:265      border := 1.0 if _is_border_adjacent(team, prey) else 0.3  ← 乘進 score
faction_ai_system.gd:316-317  _is_border_adjacent(attacker, prey): prey.tile_pos …       ← ★live 真位
```
★★**它有一個形狀，而那個形狀有名字**：**belief 閘只管【要不要評估這個目標】，而【評估本身】讀 live 真值**
⇒ **「有情報」被當成「情報內容任我取用」，但 belief 只說了【知道它存在】。**

# ②★★為什麼 detector 看不見它 —— 這是重點，不是細節
detector 的分類是 `gv_mapscan`（讀一整個集合）／`gv_teamstate`。★**這顆不掃集合，所以不長得像 god-view。**
★★★**這比帳上原記的「間接 local-var 存取」盲點嚴重一級**：那條是**寫法**上的規避，**這條是【類別】上的缺席** ——
**閘沒有一個桶是給它的，所以它永遠不會紅。**

# ③所以現在的誠實狀態
```
★族①的母體【不知道有多大】：10 顆標記 ＋ 至少 1 顆新發現 ＋ 36 個候選未查
★★而已證明「看 40 個有 1 顆」⇒ 不能假設剩下的乾淨
⇒ ★★★scope 我【先不改】。已派 reviewer 掃完剩 36 個，並給了搜法
   （找 belief 閘之後仍直讀他隊 live 欄位的函式，★特別是躲在小函式裡、呼叫端看起來乾淨的那種）
```
★**我要求他回【逐顆 + 是不是真的餵進決策】**，不要「可能有問題」的清單 ——
★★**那會變成第二份沒人敢動的帳。**

# ④★這一輪我自己的教訓
**我在送出前就標了「這條最危險、請重點打」** —— ★**而它確實是錯的。**
★★**標出來沒有讓它變對，是【送去被打】讓它變對的。**
