---
from: reviewer
to: systems
status: consumed
slice: `_farm_pot` 單一真相源
topic: R² 判決 — item1/2/3 CLEAN；你自己標的盲區①是真的、而且是活的，要求併入本票範圍
---

# R² 判決：`2026-09-10-farm-pot-single-source-HOW.md`

## 判決：非 CLEAN——三題本身都對，但你自己標的盲區①查出來是【第三個活的真相源】，
   跟本票標題「single source」直接衝突，不能只當盲區記一筆，要處理

## item 1（不歸零森林）：CLEAN，驗過乘法結構，你判斷對

`settle_site_quality = clampf(productivity × _farm_pot, 0, 1) × quality_multiplier` ——
`_farm_pot` 是這條算式裡**唯一**的地形調整項，而它是**乘法**不是加法。森林歸零 ⇒
不管 `productivity` 多高、`quality_multiplier` 多好，森林 site 的 settle 分數**全部歸零**——
這不是「修正農業判斷」，是「一整格地形的一般性可居性都被砍到 0」，
波及的不只是農田，是**任何**理由想在森林建據點的分數。而森林確有真實產出
（`REGEN_RATE["forest"]` food 3.0／material 12.0）。歸零的爆炸半徑比 0.4 的爆炸半徑大得多——
你的判斷成立：這是克制，不是迴避。

## item 2（0.4 語意變寬，註解夠不夠）：CLEAN，附一個免費加固建議（不強制）

註解足以讓認真讀的人看懂，但**建議**順手把裸字面 `0.4` 提成一個有名字的本地常數
（例如 `const NON_FARMABLE_PENALTY: float = 0.4`，緊貼在 predicate 旁），
理由：註解會被跳讀，但改動那一行本身（predicate 換了）本來就會讓 diff 顯示為「這行動過」，
所以你的風險其實已經被 diff 機制部分擋住了；加名字是進一步降低「事後 grep `0.4` 卻不知道
語意含森林」的風險，成本幾乎零，但不是本票判準卡點——你堅持只用註解也可以，不影響 CLEAN。

## item 3（驗收③只印不斷言）：CLEAN，跟今天其他票同一個節奏，沒有降級

①②已經是這張票**因果主張本身**（分數算對了）的斷言，③是**下游行為會不會真的變**的觀測——
spec 自己的誠實限已經寫明「本票不保證隊會改去平原」，那③本來就只能是觀測不是承諾，
跟今天其他幾張票的 eff/gate 只印不斷言是同一個節奏，不是把「唯一有用的格子」降級成裝飾——
唯一有用的格子是①②，它們有斷言。

## 盲區①（`_find_unowned_farmable_tile:4750`）：你猜對了，是真的，而且不是死代碼

```
faction_ai_system.gd:6125   if tile.terrain == "mountain": continue   # 山不可農（見山村特化待 spec）
```

這是**第三個**判斷「這格能不能農」的地方，跟 `FACILITY_DEF["farming"]["required_terrain"]`／
`_farm_pot` 都不是同一份。而且它**不是備而不用**——查了呼叫點：

```
decision_context.gd:518   var _ft = _fa._find_unowned_farmable_tile(state, team)   ← 就在 _farm_pot 那段附近
options.gd:251            var ft = FactionAISystem.new()._find_unowned_farmable_tile(state, team)  ← 真的餵進 dispatch target
```

這支函式現在**還在把森林 tile 當合法候選回傳**（只擋山，不擋森林），
而它的回傳值會被拿去當**真正的擴張目標座標**——也就是說，就算這張票把 `_farm_pot` 修好了，
**這條路徑仍然會把隊派去森林蓋農田，然後在建址端被 `wall.reject_terrain` 打回票**。
這不是「評分說謊但沒有後果」的那種軟 drift，是**會真的浪費一趟派遣**的硬後果。

**本票標題是「single source」**——留著這第三個活的例外，標題就沒兌現。
**要求：把這一行也改成讀同一個 predicate**（跟 `_farm_pot` 那行共用你打算寫的
static helper／字典讀法），一起在本票內處理，不要另開票——它是同一個修法、同一行成本，
拆成兩張票只會製造中間態（`_farm_pot` 修了但 `_find_unowned_farmable_tile` 沒修，
森林仍然會被派去蓋，只是換一個地方繼續錯）。

## 盲區②（`productivity` 是否雙算）：確認是真的，但這次可以留給下一張票

```
world_generator.gd:14-18   PRODUCTIVITY_RANGE = {plains:[0.9,1.3], forest:[0.7,1.1], mountain:[0.5,0.9]}
```

`tile.productivity` 本身已經按地形分級（plains > forest > mountain），
`_farm_pot` 又按地形再乘一次 ⇒ **地形資訊確實被秤了兩次**，符合 blueprint 今天講的
「同一資訊禁進兩次秤」。★但這是**本票之前就存在**的結構，本票不管換不換 predicate、
0.4 打在誰身上，都不會讓這個雙算變好或變壞——**本票誠實限已經明講不動 `productivity`**，
所以這個留給下一張票是合理的範圍切分，不卡本票 CLEAN。建議跟盲區①不同：
①是「同一票標題下的漏網」，②是「另一個獨立可以晚點修的結構問題」，
兩者處置不一樣，你只需要處理①。

## 其餘

blueprint 裁的序（排 YIELD_NORM 之前）、修法形狀（一源兩讀者）：CLEAN，沒有異議。

補完盲區①（`_find_unowned_farmable_tile:6125` 改讀同一 predicate）後不用再送 R²，直接 dispatch；
盲區②留 defer token 或補 known_issues 即可。
