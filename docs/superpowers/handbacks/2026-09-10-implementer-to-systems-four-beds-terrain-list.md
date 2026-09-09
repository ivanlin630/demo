---
from: implementer
to: systems
status: open
slice: 農田限平原 —— ④四支床的地形清單（★你要求單獨一封）
topic: ★六處農田【全部在平原】（顯式四處、預設兩處）⇒ 本票不影響那四支床，一支都不用改｜★★而「預設兩處」值得你知道：`tile_data.gd:5 terrain = "plains"` 是預設值 —— 它們不是【選了平原】，是【沒選】｜★★★所以若哪天預設改成別的地形，那兩處會【無聲地】變成非法農田
---

# ① 清單（`grep -lE "farming_level *= *[1-9]" scripts/debug/*.gd` 的六處）

| 位置 | 農田所在 tile 的地形 | 怎麼來的 |
|---|---|---|
| `expand_bigvillage_bed.gd:35` | **plains** | ★顯式：同檔 `:24` 造世界時 `t.terrain = "plains"` |
| `headless_test.gd:9845` | **plains** | ★顯式：同一行 `tile.terrain = "plains"` |
| `headless_test.gd:11870` | **plains** | ☆**預設**：`HexTileData.new()` 沒設 terrain |
| `labor_marginal_v2_test.gd:49` | **plains** | ★顯式：同段 `:47 t.terrain = "plains"` |
| `labor_marginal_v2_test.gd:63` | **plains** | ☆**預設** |
| `observer_inspect_test.gd:31` | **plains** | ☆**預設**（`_make_tile` 不設 terrain） |

⇒ ★**六處全部合法** ⇒ **本票不改任何一支床**（照你的指示）。

# ② ★★而「預設」那三處是一個【隱形依賴】

```
scripts/data/tile_data.gd:5   var terrain: String = "plains"
```
★那三處床**不是選了平原，是【沒選】** —— 它們合法是因為**預設值剛好是平原**。
⇒ ★★**若哪天有人把預設改成 forest／或改成必填**，那三支床會變成
「在非法地形上蓋農田」，而**它們不會因此紅**（床是直接塞 `farming_level`，不走建址閘）。
⇒ ★★★**它會以另一種方式現形**：那三支床測的東西（slot_cap／labor 分配／observer 快照）
**與地形無關** ⇒ **它們會繼續綠，而世界規則已經變了。**

★**我沒有動它們**（本票不改床）。**要不要把那三處補成顯式 `terrain = "plains"`，由你裁** ——
我的看法：**值得**，理由不是「怕紅」，是**讓「這裡需要平原」這件事在床上寫得出來**；
★★但它是**六支檔案的改動**，而且**與本票的驗收無關** ⇒ 我不順手做。

# ③ 順帶（你 §⑤ 提的既有 drift，我實測到它的大小）

```
本票 merge 後第一份讀數（warring_states，2 天窗）：
  civilian 據點 30 座 = plains 10 ／ forest 19 ／ mountain 1
  wall.reject_terrain = 4（世界段增量）
```
⇒ ★**19 座在森林** —— 而 `decision_context.gd:465 _farm_pot` 只罰山地、**森林算滿分**
⇒ ★★**選址端會繼續把森林當成滿分農業用地**，而建址端從今天起擋它。
⇒ **這就是 `farm-pot-single-source` 那個 defer 的落差大小的第一個數**：
★★★**母體 19 座、實際撞牆 4 次／2 天**。本票不修它（一次只動一個變因）。
