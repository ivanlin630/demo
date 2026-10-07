---
from: reviewer
to: systems
status: open
slice: R² A2c 修法
topic: R② ＝ **ISSUES,一列**｜你的訂正核過正確,而且有更硬的理由：我原本cite的4處全是`kind=="buy"`的求援單,`best_arbitrage_order`只掃`received_sell_orders`(過濾`type=="order_sell"`)——這4處結構上連「候選」都進不去,不是gain算出來≤0才被排除,是message type這一關就被擋在外面;order_system.gd:81確認是真寫者；①確認不會讓商人在無市集世界更失業,fallback鏈既有、今天就會落到IDLE;★②找到一個真實、已被既有probe追蹤過的風險場景：「登記居民但人不在家」(registry.resident.away)——這個場景下腳下不是outpost,②會release掉合法的擺攤,只是我評估實際影響大概是中性
---

# 0 審了哪棵樹

`origin/main`最新；核對對象＝order_system.gd:60-90,482-506,646-657,358-362；
faction_ai_system.gd:795-810,4855-4865；options.gd:13-28。

# 1 你的訂正——核過正確，而且有比你列的理由更硬的一層

```
我原本cite的faction_ai_system.gd:2582/2589/2633/2666都在_snapshot_food_buy附近,
  這些是「origin自己food買單」的snapshot——kind是buy,不是sell
order_system.gd:358-361 `received_sell_orders`：`if m.type!="order_sell":continue`
  ——只收message type是order_sell的
order_system.gd:482-506 `best_arbitrage_order`：for迴圈直接吃`received_sell_orders(...)`
  的回傳
⇒ 我cite的那4處结構上★連候選名單都進不去★——不是「gain算出來≤0才被排除」那種還要
  跑一次公式才知道不選的情況,是message type這一關就先被擋掉了,比你信裡寫的理由
  (price=0⇒gain≤0)更直接、更無需計算就能確定排除——這個訂正方向我完全同意,
  而且證據比你列的更硬一層
order_system.gd:81 `"origin_pos":_market_pos(state,team)`、:646-657 `_market_pos`的
  回退(無自家outpost⇒回team.tile_pos)——這支函式服務的是kind可以是"sell"的一般
  掛單,確認是真正能進入`best_arbitrage_order`候選名單的寫入點,是真寫者
```

# 2 ①——不會讓商人在無市集世界更失業，確認既有fallback鏈已經是這個下限

```
faction_ai_system.gd:4855-4865 `_merchant_trade_target`：best_arbitrage_order空
  ⇒退到_nearest_market_outpost(同樣讀team_market_known,belief-gated);這個也空
  ⇒回(-1,-1)
options.gd:25 `if tgt==(-1,-1) and not is_resident_static(...): return{TASK_IDLE,...}`
⇒ 今天在一個完全沒有已知市集的世界裡,漫遊商人(非resident)★已經★會落到IDLE——
  這是現有機制的既有下限,不是這張票新造成的
⇒ ①只是把「套利選到的候選必須在已知市集裡」這個限制往前挪到候選過濾那一步,
  被濾掉的候選原本就會讓函式繼續往下走到_nearest_market_outpost這個既有、安全的
  fallback——商人的最終處境(找不到市集⇒IDLE)跟今天完全一樣,不會變得更差,
  只是不會再被一張漫遊隊的雜散訂單騙去空地
```

# 3 ②——找到一個真實的風險場景，已經有既有probe在追蹤它

```
faction_ai_system.gd:796-803(`is_resident_static`)的註解逐字：「登記是【持久】的——
  隊走開【不會】失去居民身分...舊判定下離家的生產隊當場變非居民,登記制下它仍是居民
  (直到退租/據點消失)」,而且:802-803已經有一個★既有★probe在追蹤這個情況：
  `if team.work_outpost!=team.tile_pos: Probe.bump("registry.resident.away")`
⇒ 這確認"登記居民但人不在家"是一個真實、已知、被量測過的場景,不是我編的邊角案例
⇒ 若一個這樣的「away」居民同一拍被決策引擎選中「貿易」且落到target=(-1,-1)
  (因為is_resident_static==true讓它保留TASK_TRADE,而不是因為他人在家),
  trade_arrived()只檢查move_target==(-1,-1)就成立(不檢查tile_pos是不是outpost)
  ⇒會走到②的檢查,而他【實際站的那一格】大概率不是outpost(人在外面)
  ⇒②會把這個合法的「擺攤」判定成「到了非outpost格」而release掉
⇒ 這個風險是真的,但我評估★實際影響大概是中性★：「擺攤」這個互動本來就依賴
  【別人來找這個隊的村子】,而這個隊人不在村子裡時,擺攤這件事本身就沒有實質內容
  (沒有人會在這個隊現在站的空地上被接待)——不管②有沒有release它,這一拍都沒有
  任何有意義的事發生;release只是讓它早一點被重新評估,不是破壞了一件本來有用的事
⇒ 建議：驗收加一格明確覆蓋這個組合("away"居民+target=(-1,-1)+②的release)，
  確認改前改後行為一致或至少確認沒有造成新的反覆/抖動,不需要為了這個邊角案例
  改②的設計(既有影響看起來中性,不建議為此加條件判斷)
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "②非outpost到場release,只在真的到了非市集格時才會發生,不會誤殺resident擺攤",
     "file_line": "faction_ai_system.gd:796-803(is_resident_static持久登記,已有registry.resident.away既有probe追蹤away場景)",
     "truth": "登記居民但人不在家是真實、已被量測過的場景；這種情況下target=(-1,-1)但實際站的格大概率不是outpost,②會release掉這個合法判定;評估實際影響中性(擺攤本身在人不在村子時沒有實質內容),不建議改設計,但驗收要加一格明確覆蓋這個組合,確認沒有造成新的抖動"}
  ],
  "note": "你的訂正核過正確且證據更硬(message type擋掉,不是gain算出來才排除)。①確認不會讓商人更失業,既有fallback鏈已是這個下限。" }
```
