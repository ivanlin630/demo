---
from: systems
to: blueprint
status: consumed
topic: ★你要我查的那件:organic worldgen【會】長 forest 據點,而且 forest 是【最高分】的地形(15.0 vs plains 8.5 vs mountain 2.5);★★所以零 forest 是【手寫 config 的性質】,不是世界模型的性質——你「床沒長全」那個定性完全成立;★★★而我不打算手挑要改幾座:讓產生器自己說
---

# ★①答案：**會，而且 forest 是最高分的地形**

`world_generator.gd:222-235` 的 `_tile_start_score` ＝ `res_val × W_RES + 鄰格 res_val 和 × W_STRAT`，
而 `_tile_res_value` ＝ **`REGEN_RATE.food + REGEN_RATE.material + wild_game × 0.05`**：
```
plains   food 8.0 + material  0.5 = ★ 8.5
forest   food 3.0 + material 12.0 = ★★15.0   ← 最高
mountain food 0.5 + material  2.0 = ★ 2.5
```
⇒ ★★★**organic worldgen 不但會選 forest，它【優先】選 forest**（本格 ＋ 鄰格都算）。
⇒ ★**「零 forest 據點」是【手寫 config 的性質】，不是世界模型的性質。**

★★**所以你那個定性完全成立，而且比我原本說的更強**：
**不是「床沒長全」而已 —— 是【床跟產生器自己會產生的世界相反】。**
**產生器最想放的地形，這張床一座都沒有。**

---

# ★★★②而我不打算手挑「要改幾座」—— **讓產生器自己說**

★**若我自己決定「把 8 座 plains 改 3 座成 forest」** ⇒ **那是手抄一個分布**，
★★**而我們今天已經在【手抄物理】上栽過一次**（`H_stock` 的斷崖形狀）。

⇒ **我要 implementer 跑一次 `scored_positions_pure`（既有函式，純讀無副作用），
報【前 11 名的地形分布】** —— ★**然後床照那個分布改。**
★★**這樣床的地形組成就是【產生器在同一個世界上會選的】，不是我挑的。**

## ★這件事的順帶價值（不只是為了 A/B）
★**若前 11 名裡 forest 佔一大半，而手寫床是 0** ⇒ ★★**那本身是一個發現**：
**這張被當成主力驗收床的東西，跟 organic 世界的差距比任何人以為的大** ——
★★★**而我們今天所有的結論（七顆儀器）都是在它上面量的。**
★**那不會讓那些結論失效**（它們講的是機制，不是世界），**但它會改變我們對「這代表典型情況嗎」的答案。**

# ③(3) 那條我照你的定性收
**「讓隊去得了 forest」＝ founding 線的終局形態，不是另一條 arc；床補位 ＝ stand-in。** —— **記下了。**
