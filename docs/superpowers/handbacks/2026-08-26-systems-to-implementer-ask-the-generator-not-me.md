---
from: systems
to: implementer
status: consumed
slice: bed-terrain-representative
tier: probe
topic: ★★★一件小事,但形狀重要:床要加 forest 據點,而我【不挑數字】——跑 scored_positions_pure 報前 11 名的地形分布,床照它改;★理由:我自己挑=手抄一個分布,而我們今天才在手抄物理上栽過一次;★先只要數字,不要改床
---

# ★①背景一句
**blueprint 裁定改床（加 forest 據點）**，定性是 ★**「床沒長全」**：
**用戶的世界模型裡 forest 隊是材料生產者，而 `peaceful_economy` 的 11 座 outpost 是 `plains 8 / mountain 3 / forest 0`。**

★**而我查了 organic worldgen**：`_tile_start_score` 用 `REGEN_RATE.food + material`，
```
plains 8.5 ／ ★forest 15.0（最高）／ mountain 2.5
```
⇒ ★★**產生器不但會選 forest，它【優先】選 forest。零 forest 是手寫 config 的性質。**

---

# ★★②要你做的（**只有數字，先不要改床**）

★**跑 `WorldGenerator.scored_positions_pure(state)`**（既有函式、純讀、無副作用），
**在 `peaceful_economy` 的同一個世界／同一個 seed 上**，**報【前 11 名的地形分布】**。

| 要報 | |
|---|---|
| ★**前 11 名各是什麼地形** | `plains N ／ forest N ／ mountain N` |
| ★★**前 11 名的分數** | ★**讓「差距有多大」看得見** —— **第 11 名跟第 12 名差多少也報** |
| ★★★**現行 11 座手寫據點在那個排名裡的位置** | ★**若它們排在很後面 ⇒ 這張床不只是「少了 forest」，是【整體選在不好的地方】** |

★**若 `scored_positions_pure` 需要一個已生成的世界才能跑**（我沒細看它的前置），
**回報你需要什麼，不要為了跑它去改任何東西。**

---

# ★★★③為什麼我不自己挑「改幾座」

★**我大可以說「把 8 座 plains 改 3 座成 forest」** —— ★★**那是手抄一個分布。**
**而我們今天才在【手抄物理】上栽過一次**（`H_stock` 我憑直覺造了一個「先打平再斷崖」的形狀，
reviewer 用 `COLLECT_RATE` 打回，實算高估 32%）。
⇒ ★★★**床的地形組成要是【產生器在同一個世界上會選的】，不是我挑的。**

★**同一條紀律的第二個用法**：**它不只管估值器，也管【床】** ——
**一張手挑的床，跟一個手抄的常數，在「它憑什麼是這個數字」這件事上是一樣的。**

# ④先不要改床
★**數字回來我再定改法**（可能是換幾座、可能是整批照排名重擺、也可能發現手寫床根本不該留）。
★★**而改床之後前七顆儀器的基線要重跑** —— **那件事已經跟 blueprint 講定，你不用擔心它。**
