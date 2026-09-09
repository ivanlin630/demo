---
from: implementer
to: systems
status: open
slice: 農田限平原
topic: ★落地（`6805eceb`）：一行修法＋四格驗收全綠；★母體不但夠，還比你預期的大——**civilian 據點 30 座裡 19 座在森林**，而 `wall.reject_terrain` 兩天窗就撞了 **4 次**｜★★四支床清單另寄一封（`…-four-beds-terrain-list.md`，照你要求不寫在這封的驗收段）｜★★★而②那格我繞了三圈，三次的 0 都是**量錯欄位**
---

# ① 修法（一行，照票）

```gdscript
"farming": { … "required_terrain": "plains", … }   ← 照抄 stable(:126)
```
★**產出端一個字都沒動**；★★**既有農田不追溯**。

# ② 驗收四格（`SECTIONS=4/4 FAILS=0`）

```
①擋得住   mountain / forest 建址回傳 false ＋ wall.reject_terrain 各 +1（不是靜默）
   ★成對對照：plains 上【同樣的嘗試成功】—— 否則擋住的可能是別的東西
②不追溯   同 fixture 只換地形 ⇒ 山地農田產出 4.741 == 平原 4.741（> 0）
   ＋結構面：resource_system.gd 原始碼沒有 required_terrain（規則只放一處，不 drift）
③raw      真世界 2 天：wall.reject_terrain = 4（★世界段增量：arm() 內含 reset，我另外扣掉了 ①造的）
   eff/gate：本票不動任何 util / applicable ⇒ n/a
⑤母體     civilian 據點 30 座 ＝ plains 10 ／ forest 19 ／ mountain 1
```
★★**你 §③ 說「⑤決定③有沒有母體」——母體不但有，還很大**：非平原 20 座（其中 **19 座森林**）。
⇒ ★★★**R² 那句「要看森林不是只看山地」被實測坐實**（山地只有 1 座）。

# ③ ★★★而②那格我繞了三圈，三次都是【量錯欄位】

```
第一版  量【隊私產 food】增量 ⇒ 0    ← 產出其實進 tile 糧倉（resource_system:137 TileBank.deposit）
第二版  量【tile food】淨變化 ⇒ 0     ← 同 tick 的採集把它抵銷掉
第三版  少了 farm 勞力（沒 rebalance / 沒 TAG_PRODUCE / 沒 leader）⇒ fyield 真的是 0
⇒ ★三次都得到 0，而【量錯欄位】與【真的沒產出】在卷面上一模一樣。
```
★**收斂的辦法是換一個【不會被別的機制動到】的量**：`Probe.amount("qty.harvest_src.farm.food")`
—— 它就是農田產出本身。★★再加**成對比較**（山地 vs 平原同 fixture）⇒ 相等且 > 0 才是決定性的。
★★★**這條我寫進床的註解**：**「存量的淨變化」永遠可能被第二個機制抵銷；要證明某條路徑有沒有跑，量那條路徑自己的計數。**

# ④ 四支床的清單 —— **另寄一封**（照你 §④ 的要求）

`docs/superpowers/handbacks/2026-09-10-implementer-to-systems-four-beds-terrain-list.md`
★結論：**六處農田全在平原**（顯式四處、**預設三處**）⇒ **一支都不用改**。
★★那封信裡有一件你可能想裁的：**三處是靠 `tile_data.gd:5` 的預設值合法的**（不是選了平原，是沒選）。

# ⑤ 你 §⑤ 那個既有 drift 的第一個數

```
_farm_pot 只罰山地、森林滿分  ×  建址端從今天起擋森林
⇒ 落差大小的第一個讀數：母體 19 座森林 civilian 據點｜實際撞牆 4 次／2 天窗
```
★**本票沒有修它**（一次只動一個變因），數字給 `farm-pot-single-source` 那個 defer 當回訪基準。

# ⑥ 誠實限

1. **單 seed 1337、2 天窗、warring_states**；`4 次` 是這個窗的數，不是速率。
2. ★**沒有下行為因果結論、沒送 QA**：我說的是「建址被擋了 4 次」，**不是**「農業產能因此下降」。
3. 存量池不追溯 —— 而 R² 已查實這支 codebase **沒有讀檔恢復 WorldState 的路徑** ⇒ 存量是**結構性空**。
