# HOW spec：`_farm_pot` 讀建址端的同一個真相源

owner: systems ｜ 2026-09-10 ｜ player_reachable: no ｜ 序：批二② 之前｜狀態：R² 要求併入第三個真相源，已補 ⇒ 可 dispatch

上游：農田限平原已 merge（`6805eceb`），而 `wall.reject_terrain` 兩天窗撞 4 次、
**civilian 據點 30 座中 19 座在森林** ⇒ 選址評分把森林算成**滿分農業用地**，而它們**種不了**。

## §1 病：兩個真相源

```
建址端  outpost_system.gd  FACILITY_DEF["farming"]["required_terrain"] = "plains"
評分端  decision_context.gd:465  var _farm_pot: float = 0.4 if _site.terrain == "mountain" else 1.0
        （註解自陳「可農判準沿用既有慣例（山不可農）」）
⇒ ★森林在評分端是【滿分農業用地 1.0】，在建址端【蓋不了】。
⇒ ★★而 19/30 據點在森林 ⇒ 這不是邊角，是【多數】。
```

★**它是「拿著自己沒有的能力做計畫」的第三個實例**，而與前兩個（移速、養活力）的差別是：
前兩個是**接線缺失**，這一條是**兩個真相源** ⇒ ★★**修法是「兩真相源 → 一源兩讀者」，不是「接上真值」。**

## §2 ★★★修法：**換 predicate，不換數值**

```gdscript
現況   var _farm_pot: float = 0.4 if _site.terrain == "mountain" else 1.0
修後   var _farm_pot: float = 1.0 if <farming 允許此 terrain> else 0.4
       ★<farming 允許此 terrain> ＝ 讀 FACILITY_DEF["farming"] 的地形規則（★唯一真相源）
```

★**沿用既有的 `0.4`，不發明新常數** —— ★★而它的**語意變寬**（「山不可農」→「不可農」），
**值沒有變**。⇒ ★★★**這一點要寫進 code 註解**：
**一個常數的【適用範圍】變了而【值】沒變，是最容易被下一個人讀成「沒動過」的改動。**

★**禁止**：在 `decision_context` 裡再寫一份地形清單。

## §2b ★★★而【第三個真相源】已經存在，而且是活的（R² 2026-09-10 查實，我只標成盲區是不夠的）

```
faction_ai_system.gd:6125   if tile.terrain == "mountain": continue   # 山不可農
呼叫點（★★不是備而不用）：
   decision_context.gd:518   var _ft = _fa._find_unowned_farmable_tile(state, team)
   options.gd:251            var ft = ...._find_unowned_farmable_tile(state, team)  ← ★真的餵進 dispatch target
```
⇒ ★**它現在還把森林 tile 當合法候選回傳**（只擋山、不擋森林），
   而回傳值**會變成真正的擴張目標座標**
⇒ ★★**就算 `_farm_pot` 修好了，這條路徑仍然會把隊派去森林蓋農田，然後在建址端被打回票**
⇒ ★★★**這不是「評分說謊但沒有後果」的軟 drift，是【真的浪費一趟派遣】的硬後果。**

★**而本票標題是「single source」——留著這第三個活的例外，標題就沒兌現。**
⇒ **併入本票範圍**：`:6125` 也改成讀同一個 predicate。

⇒ **三處共用一個 predicate（形狀由實作者定，但必須是【一份】）**：
```
①outpost_system  FACILITY_DEF["farming"]["required_terrain"]   ★真相源本體
②decision_context.gd:465  _farm_pot                            ★讀它
③faction_ai_system.gd:6125 _find_unowned_farmable_tile         ★讀它
```

## §3 ★★為什麼不歸零（我先否決一個看起來更「正確」的做法）

```
settle_site_quality = clampf(_site.productivity × _farm_pot, 0, 1) × SettlementMemory.quality_multiplier
⇒ ★_farm_pot 是【唯一的】食物潛力項 ⇒ 若森林歸 0，森林選址品質【全歸 0】
⇒ ★★而森林【仍然有】raw food regen 3.0/day ＋ material 12.0（`REGEN_RATE`）
   ⇒ 歸零等於說「森林一文不值」，那是【另一個錯】,不是修好。
⇒ ★★★而它還會【一次翻轉 63% 的據點選址】—— 一個修 drift 的票不該有那種爆炸半徑。
```

## §4 驗收（blueprint 指定的成對對照）

```
①【同源】`decision_context` 裡【沒有】第二份地形清單
   ⇒ 結構檢查：`grep -c '"mountain"' decision_context.gd` 在該函式內為 0
   ★成對對照：故意加回一個字面 "mountain" ⇒ 該格必須紅
②★★【森林格歸位】同 seed 下，森林 site 的 `_farm_pot` 從 1.0 → 0.4
③★★★【選址分布往平原偏移】改前/改後【同 seed】跑同一個窗 ⇒ 新選址的地形分布可觀測地往平原移
   ★成對對照＝改前那一跑（blueprint 指定）
   ★★誠實限：★這一格是【eff/gate 類】——它是世界狀態的函數
     ⇒ 若某個 seed 下剛好沒有新選址發生，它會是 0 ⇒ ★★★【只印不斷言】，斷言掛①②。
④【不爆炸】既有據點【不受影響】（本票只動評分，不動任何已建成的東西）
   ⇒ ★印出「改動後 settle_site_quality 變化的據點數」讓爆炸半徑可見
⑤★可達區間先算（界限第八條）：森林佔 29%（地形卷）、據點 19/30 在森林
   ⇒ ★★母體【已知夠厚】—— 這是今天第一張【不需要先跑就知道母體夠】的票，因為卷面已經量過了。
⑥★★★【第三個真相源也改了，而且是硬後果那一格】：
   `_find_unowned_farmable_tile` 不再回傳森林 tile
   ⇒ ★成對對照：改前跑一次，記錄「被派去森林蓋農田然後撞 `wall.reject_terrain`」的次數；
     改後那個次數必須【下降】（★理想是 0，但別把 0 寫成硬斷言——★★其他路徑也可能撞它）
   ⇒ ★★★這格量的是【浪費的派遣】，而它是本票【唯一有硬後果】的一格 ⇒ 斷言掛這裡。
```

★誠實限：
1. 本票**不動** `0.4` 這個值、不動 `productivity`、不動 `SettlementMemory.quality_multiplier`。
2. ★**本票不保證「隊會改去平原」** —— 它只保證**評分不再說謊**。
   實際選址還受 `productivity`／既有記憶／可達性影響 ⇒ ③是**觀測**不是**承諾**。
