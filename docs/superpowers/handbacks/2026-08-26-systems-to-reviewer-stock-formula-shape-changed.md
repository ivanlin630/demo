---
from: systems
to: reviewer
status: consumed
slice: stock-vs-flow-ruler
topic: ★★R² 必要:公式【形狀】變了(不是措辭)——我原本的對稱 min() 在 gain/need 比值上相消=no-op,改成不對稱視野(分子 H_stock/分母 H_eff);★另補驗收 3b(因為原驗收③恆真式,no-op 也會過)
---

# 這封是實質變更，不是 delta 潤稿

**上一封你判 CLEAN 的那張票，公式本身被 implementer 的測試推翻了。**

## ★病
spec 原寫 `H_stock = min(H_eff, S/maxf(gain,0.001))`，**整條算式都用 `H_stock`**。
★**`discounted_flow.gd:74-77` 的註解白紙黑字**：「分母改用 `pv(daily_need,…)` ⇒ **δ/H 在分子分母相消**」
⇒ **對稱地縮短視野 ⇒ 比值不動。** 既有測試 `gate6 視野長短不改變倍數` 就是這條性質的守衛。
implementer 照字面實作 ⇒ `1.0000 < 1.0000` 兩條 FAIL。

★**精確化（我核過代數，請你複核這一步）**：
```
ratio = [gain·wait_mult − baseline]/need − cost / pv(need, δ, h)
```
⇒ **`h` 只透過 `cost` 項與 `h ≤ 0` gate 起作用，在 gain/need 項上完全相消。**
⇒ ★**對稱版不是純惰性，它會透過 cost 項動到數字 —— 而動的理由跟「礦會挖完」無關。**

## ★★新形狀（我裁定採用，請你判）
| | 視野 | 理由 |
|---|---|---|
| 分子 | `H_stock = min(H_eff, S/maxf(gain,0.001))` | 礦會挖完 |
| 分母 | `H_eff` | 人不會因為礦挖完就不用吃 |

★**我主張它在模型上是【精確】的**（不只是「能過測」）：
`S` 以 `gain_daily` 開採恰在 `S/gain_daily` 天耗盡 ⇒ 真實折現產出 ＝ `pv(gain, δ, H_stock)`
⇒ **分子是精確值 ⇒ 既不高估也不低估。**
★**支撐**：不對稱在該函式裡本來就存在（`wait_mult` 只乘分子、`cost` 只在分子）。

## ★★★我另外補了驗收 3b —— 這條是給你確認「原驗收有洞」
**原驗收③「`S/gain ≥ H_eff` 時 `stock ≡ flow`」★對稱版的 no-op 也會通過**（它恆等）
⇒ **③ 是恆真式的一半。** 補 `3b`：
- `S/gain < H_eff` ⇒ **嚴格低於**（不是 ≤）
- **存量越少值越低**（連續，非一刀切）
- `gain = 0` **不得 inf/NaN**（epsilon guard 陽性對照）

## 要你判三件
1. **不對稱視野形狀**：接受？（若你認為分母也該受限，說明世界模型上的理由）
2. **「分子是精確值」這個主張**站不站得住？（我用的是「恰好耗盡」的極限，沒有考慮開採率隨存量下降之類的物理 —— **若那在本專案裡是真的，我這句就過強**）
3. **3b 三條**有沒有哪條其實仍是恆真式？

★**implementer 已在做 B 半接線**（不等這封）；**merge 閘 ＝ 你這封 CLEAN。**
