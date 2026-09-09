---
from: systems
to: implementer
status: open
slice: 農田限平原（用戶裁）
topic: ★DISPATCH（用戶裁 ＋ R² CLEAN）｜★★修法【一行】,機制與 tap 都現成 —— 而這張票的重量【不在修法,在三件別的事】：①存量不追溯(建址擋不在產出擋) ②驗收③才吃母體(不是①) ③四支床的清單【要真的寄信】｜★★★而 R² 順手挖到一個【既有】drift：`_farm_pot` 只罰山地、森林滿分,而建址端森林蓋不了 ⇒ 評分端不知道建址端變嚴
---

# 開票：`docs/superpowers/specs/2026-09-10-farming-requires-plains-HOW.md`

# ① 修法：一行

```gdscript
outpost_system.gd  FACILITY_DEF["farming"]
+   "required_terrain": "plains",     ← ★照抄 stable（:126）
```
★檢查點（`:619-620`）與 tap（`wall.reject_terrain`）**都現成** ⇒ **不新增機制、不動 worldgen**。

# ② ★★存量處置：**建址擋，產出不擋，既有不追溯**（systems 裁）

```
①同一個規則放兩個地方【必然 drift】⇒ 產出端【不要】再判一次地形
②不追溯沒收 —— 規則約束的是【未來的建址】
③★R² 查實：★★這支 codebase【沒有讀檔恢復 WorldState 的路徑】
   ⇒ 存量池【不是「現在空」,是【結構性空】—— 它不可能非空,除非未來加存檔系統
```
⇒ ★**產出端（`resource_system.gd:131`）一個字都不要動。**

# ③ ★★★驗收：⑤先跑，而它決定的是【③】不是①（★我原本標錯，R² 訂正）

```
①② 手動構造場景（放一支隊在手選 tile 上直接呼叫建造）⇒ ★不吃母體,隨時可測
③  raw ＝ `wall.reject_terrain` 計數【必須 > 0】(這是斷言) ⇒ ★★只能從【真的在跑】的世界量
⇒ ★★★⑤（civilian 據點落在非平原的比例）決定【③】有沒有母體
★而母體風險的形狀跟我想的不一樣（R² 查的）：
   decision_context.gd:465  _farm_pot = 0.4 if mountain else 1.0
   ⇒ ★選址【只罰山地】,森林與平原同分 ⇒ 「落在森林」不見得稀少
   ⇒ ★★③的母體要看【森林】的比例,不是只看山地。
```

其餘格：
```
①擋得住（山地/森林嘗試 ⇒ 被擋 ＋ 計數 +1）★成對對照：平原上同樣的嘗試【成功】
②不追溯（預放一座山地 farming_level=2 ⇒ 規則上線後【照常產出】）
   ★這格是本票 HOW 裁定的守衛 —— 它證明我們做的是 (a) 不是 (b)
③raw/eff/gate（raw 掛斷言、eff/gate 只印不斷言；短窗下只能回答「沒翻轉」）
④四支床的地形清單（見下）
```

# ④ ★★四支床：不動，只回報清單 —— **而清單要【真的寄信】**

```
expand_bigvillage_bed / headless_test / labor_marginal_v2_test / observer_inspect_test
（`grep -lE "farming_level *= *[1-9]" scripts/debug/*.gd`）
⇒ ★逐支回報【它構造農田的那個 tile 是什麼地形】,★★本票【不改它們】
⇒ ★★★清單完稿【必須寄一封 handback 給我】,不能只寫在你的交件信的驗收段落裡
   —— 否則它是【落地但沒通知】：寫在 diff 裡而沒進信箱 ＝ 沒有人會回頭裁它。
```

# ⑤ 你不用做、但要知道的（★R² 順手挖到的既有 drift）

```
decision_context.gd:465 的 `_farm_pot` 與 FACILITY_DEF 的 required_terrain 是【兩個真相源】
⇒ 上線後：隊伍的選址評分會【繼續把森林算成滿分農業用地】,
   直到它真的去蓋才被 wall.reject_terrain 打回票。
★這是【既有】落差,不是本票造成的 —— 本票只是【讓它變得可見】。
⇒ ★★已記 known_issues ＋ defer token `farm-pot-single-source`,
   回訪＝本票 merge 後第一份 `wall.reject_terrain` 讀數（★屆時那個計數就是落差的大小）。
⇒ ★★★**本票不要順手修它** —— 一次只動一個變因。
```

完後改本信 `status: consumed`。
