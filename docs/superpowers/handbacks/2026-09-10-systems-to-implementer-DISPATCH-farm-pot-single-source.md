---
from: systems
to: implementer
status: open
slice: `_farm_pot` 單一真相源（含 R² 併入的第三處）
topic: ★DISPATCH（R² 兩輪，第二輪要求擴大範圍）｜★★★本票的重點是【三處共用一個 predicate】,而第三處是 R² 查出來的、我只標成盲區的那個——`faction_ai_system.gd:6125` 只擋山不擋森林,而它的回傳值【真的餵進 dispatch target】⇒ 就算 `_farm_pot` 修好,隊仍然會被派去森林蓋農田然後被建址端打回票｜★★那是【浪費一趟派遣】的硬後果,不是評分說謊的軟 drift
---

# 開票：`docs/superpowers/specs/2026-09-10-farm-pot-single-source-HOW.md`

# ① 病：**三個**真相源（不是兩個）

```
①outpost_system  FACILITY_DEF["farming"]["required_terrain"] = "plains"   ★真相源本體（已 merge）
②decision_context.gd:465   _farm_pot = 0.4 if mountain else 1.0            ★森林 = 滿分農業用地
③faction_ai_system.gd:6125 if tile.terrain == "mountain": continue         ★只擋山、不擋森林
   呼叫點：decision_context.gd:518 ／ options.gd:251 ← ★★真的餵進 dispatch target
```
★★★**②是評分說謊（軟），③是【真的把隊派過去然後被拒】（硬）。**
⇒ 實測背景：`wall.reject_terrain` 兩天窗撞 4 次、civilian 據點 **19/30 在森林**。

# ② 修法：**換 predicate，不換數值；三處共用一份**

```
②`_farm_pot`：0.4 if mountain else 1.0  →  1.0 if <farming 允許此 terrain> else 0.4
   ★沿用既有的 0.4，【不發明新常數】
   ★★而它的【語意變寬】（「山不可農」→「不可農」）而【值沒變】
      ⇒ ★★★這件事【必須寫進 code 註解】：
        「一個常數的適用範圍變了而值沒變，是最容易被下一個人讀成【沒動過】的改動。」
   ★R² 的免費建議（不強制，你判）：把裸字面 0.4 提成有名字的本地常數，讓語意變化不可忽略。
③`:6125`：改成讀同一個 predicate（★不再只擋山）
★★★predicate 只能有【一份】—— 形狀你定（static helper／直接讀字典），
   但★禁止在 decision_context 或 faction_ai 裡再寫一份地形清單（那會是第四個）。
```

# ③ ★★我先否決過一個看起來更「正確」的做法（別走回去）

```
「森林 _farm_pot 歸零」⇒ ★不採用。
理由（R² 驗過乘法結構後同意）：
   settle_site_quality = clampf(productivity × _farm_pot, 0,1) × quality_multiplier
   ★_farm_pot 是唯一的地形調整項,而且是【乘法】
   ⇒ 森林歸零 ⇒ 森林 site 的 settle 分數【全部歸零】—— 波及的不只農田,
     是【任何理由想在森林建據點】的分數
   ⇒ ★★而森林確有真實產出（REGEN_RATE forest: food 3.0／material 12.0）
   ⇒ ★★★爆炸半徑比 0.4 大得多,而這是一張【修 drift】的票。
```

# ④ 驗收

```
①【同源】decision_context / faction_ai 裡【沒有】第二、三份地形清單
   ★成對對照：故意加回一個字面 "mountain" ⇒ 該格必須紅
②【森林格歸位】同 seed 下森林 site 的 _farm_pot 1.0 → 0.4
③【選址往平原偏移】★只印不斷言（eff/gate 類：某 seed 下可能沒有新選址發生）
④【不爆炸】既有據點不受影響；★印出 settle_site_quality 有變化的據點數（爆炸半徑要看得見）
⑤母體已知夠厚（森林 29%、據點 19/30 在森林）⇒ ★本票【不需要先跑量母體】
⑥★★★【硬後果那一格 —— 斷言掛這裡】：
   改前跑一次，記錄「被派去森林蓋農田然後撞 wall.reject_terrain」的次數
   改後那個次數必須【下降】
   ★理想是 0，但★★別把 0 寫成硬斷言 —— 其他路徑也可能撞 wall.reject_terrain。
```

# ⑤ 兩個我沒查的（★你若順手看到，回報我，不要順手修）

```
①`productivity` 怎麼生成的我沒查 ⇒ ★若它本身已含地形因素，`× _farm_pot` 可能是【雙算】
  （blueprint 今天才在 DELIVER_PAYOFF_NORM 提醒過「同一資訊禁進兩次秤」）
②`:6125` 註解提到的「山村特化待 spec」我沒查它是什麼
  ⇒ ★★若那個 spec 存在且與本票衝突，★★★停下來回報我，不要自己判。
```

完後改本信 `status: consumed`。
