---
from: reviewer
to: systems
status: consumed
topic: "[R²·異質框外審判決·issues] 統一商業框架——方向(market-as-place/accessor統一)認同,但3項結構級缺口(賣方變現半環全空白/belief基底不存在會拆掉WS-2b死鎖破除器/absorb拆除致settle_orders履約記帳失明)+6項具體補完項;大框寧可多轉"
---

# R² 判決（★異質框外審，別家模型代跑 refute-first）：統一商業框架 spec

verdict: **issues**
premise_contradiction: false

## 框外審執行方式
三對齊確認（藍圖願景+用戶親裁+systems HOW，redirect 大量工作、structural、難逆）→ 派**別模型家族（Fable）**獨立子 agent，refute-first prompt，全程自行 Read/Grep 驗證。我事後抽查其最關鍵斷言，**全部坐實**：

1. `belief_system.gd:102-103 claims(state,obs_id,tgt_id)` 讀 `state.team_intel.get(obs_id,{}).get(tgt_id,null)`——**team-keyed，全 codebase 無 tile/market 級知識庫**。
2. `faction_ai_system.gd:2044-2059 _merchant_trade_target` 三層 fallback 確認：`:2050-2051` 註解逐字白紙黑字「WS-2b **破死鎖**：無 arb→巡最近市集 outpost（公開地標）→抵達親讀看板取得 arb。有理由出門→碰得到看板→下輪有 arb」——`_nearest_market_outpost`(`:2063-2076`) 確認**掃全 `state.world.tiles`**，且本身已被專案自己判定為「公開地標，非偷看他隊內部」的合理豁免，非疏漏。
3. `grep add_tag.*TAG_MERCHANT` 全 codebase **零指派**（8 處只有 `.has()` 讀取消費，無一處 `add_tag`/`tags.append` 寫入）——`deal_merchant` probe(`interaction:744`)/`merchant_inventory` 進貨(`:783/814`) 全建立在永遠是空的旗標上。
4. `faction_ai_system.gd:2027-2037 _can_trade`：`:2031 team.resources.get(res,0)` 直讀（非 accessor）+ `:2032-2034` `pop×0.1×FOOD_RESERVE_TICKS` 殭屍公式（`trade_valuation.gd:68` 註解自稱已退役的同一條算式，卻還活在貿易總閘）——spec 5 縫清單漏收此第 6 縫，屬實。

四項核心斷言坐實 → 採納異質報告的核心結論。

## 三項結構級缺口（不修就 dispatch，第一次量測會產出無法解讀的結果）

### 1. 賣方變現半環全空白（最大缺口）
M2 通篇只寫「買方向 outpost stock 買」，**賣方（尤其漫遊商隊）怎麼把貨賣進市場、誰付他錢**——spec 一個字沒有。現行非 owner 隊上不了 board（`order_system.gd:53-55` 要求 `outpost_owner==team.team_id`）。這不是「收斂雙 resolver」，是砍掉一個（team-to-team ask/bid）、另一個（market-as-place）只寫了買方那一半。商隊「低買高賣」套利循環的「高賣」端沒有 resolver。**要求**：M2 補「賣方到場入庫+計價」機制（owner 代收寄售 / 對沖現有 buy 單 / 其他，三選一擇一明定），否則商隊循環斷、coin 變單向泵。

### 2. belief 基底不存在，純化會拆掉已知的死鎖破除器
`_nearest_market_outpost` 的全圖掃描是專案**已經自覺、已經論證過**的合理豁免（「市集是公開地標」），且是 WS-2b 曾經修過的死鎖破除器——沒有它，冷啟動世界裡沒人「去過/聽過」任何市場 → 沒人出門 → 沒人讀 board → 永遠沒 arb → 經濟停擺。spec 說「用 belief（去過/傳聞的市場），非 god-view 掃全 tile」時，沒有意識到**belief 系統目前沒有 tile/market 級別的知識庫可用**（`BeliefSystem` 全部 API 以 team 為鍵，非 tile），把三路收斂成純 belief-based 單路等於無中生有一個未經審查的新子系統，或者悄悄繼續 god-view 卻假裝合規。**要求**：spec 明文三選一——(a) 世界生成時 seed 初始市場知識（同 faction 據點/鄰近地標開局已知）；(b) 市場 outpost 保留「公開地標」豁免地位，誠實寫進 invariants 豁免清單（現行②的路線，只是承認非假裝）；(c) 新建 market-knowledge store（去過記錄+訊息 origin_pos 落庫）。不能只寫「用 belief」四字帶過。

### 3. 拆 absorb/spill 後履約記帳失明
`settle_orders`（現行履約沖銷機制）靠「交易窗前後 team.resources 淨變化」推斷單被填——這個推斷法之所以對定居隊糧倉賣單有效，正是因為 absorb 機制把糧倉貨暫時拉進 team.resources，讓 delta 在 team 池顯形。拆掉 absorb 後，若新 resolver 直接扣 `public_storage`（不經 team.resources），`settle_orders` 對 storage 側成交會完全失明——sell 單永不沖銷、掛到過期、board 掛幽靈單讓買方撲空（正是 WS-2b 要消滅的問題原地復活）。**要求**：spec 補「履約記帳」一節——新 resolver 成交時直接按 `order_id` 沖 `active_orders`（權威側直接記，不靠 delta 推斷），`settle_orders` 降級只服務巧遇路。

## 六項需補完項（措辭/清單補鎖，非結構級但影響能否乾淨 dispatch）

4. **無主/死主 outpost 的 coin 去向未定義**：`_route_extinct_assets`（`faction_ai:2299-2342`）證明「owner 已滅團、倉裡還有貨」是既存常態。要求明定 fallback：owner 不存在→coin 入 `tile.public_storage.coin` 或 `abandoned_coin`（兩者皆在 CoinAudit 池內，不致蒸發/憑空）。
5. **賣超語意未鎖**：resolver 應以 `TileBank.withdraw` 的實際取出量計價（withdraw 已有現量 clamp），禁止直接信任 board 鏡像數字。
6. **「+」語意模糊致活命糧被搬空**：M2「讀 board 的 sell 單 **+** public_storage stock」——若無掛單也能買，SURVIVAL_GOODS 可能被買穿，違反 spec 自己的驗收#6。要求：可購量=min(board單餘量,現貨)，無單不賣，至少 SURVIVAL_GOODS 強制要求有單。
7. **驗收指標#1 不可達**：`deal_merchant` 閘在零指派的 `TAG_MERCHANT` 上，中性世界量測上不可能達成。要求：修 tag 指派或把 probe 改按 `ARCHETYPE_TRADE` 分流；順手處理 `merchant_inventory` 同款死路。
8. **巧遇路/市場路交界未定義**：outpost tile 上 pairwise 巧遇 resolver（`interaction:238-239` 任一方掛 TASK_TRADE 同格即觸發）與新 market resolver 會不會同 tick 都 fire、履約會不會重複沖銷——spec 要明文分工（outpost tile=market 路專屬 / pairwise 限非市場格 / 或明定共存規則）。
9. **死常數清單不完整**：spec 只點名 3 個（`SURPLUS_RESERVE_MULT`確孤兒/`FOOD_SELL_RESERVE_RATIO`/`FOOD_BUY_DAYS`），但同層還有 `SHORTAGE_QTY`/`×0.5`硬碼/`20.0`門檻/`FOOD_BUY_TARGET_DAYS`/**`MERCHANT_MAX_RANGE` 兩處重複宣告**（`order_system.gd:10` + `faction_ai_system.gd:2039`）/`TRADE_MIN_STOCK`/arb收益`×0.1`硬碼，加上 `_can_trade` 殭屍公式（缺口3）。要求：implementer 需要一張明確 kill-list，否則必然拆一半留一半。

## coin 循環交互（額外檢查，同意異質報告）
market-as-place 現貌是結構性單向 coin 泵：coin 只從買方流向 outpost owner，而(1)賣方變現半環缺失→商隊只出不進；(2)貨常是 resident 生產隊產進公庫（非 owner.resources）而錢卻歸 owner→resident 賺不到 coin。可預期 deals 起初暴增（達標）→ 流動隊 coin 抽乾 → 成交再度歸零，量到的是脈衝非穩態。不必把 coin 循環整包提前，但要求驗收加「長窗 deals 不得單調衰減到 0 / coin 分佈記錄」的觀測項，把此已知風險納入量測視野。

## 框外審評估
同意升異質框外審——這正是三對齊該召的規模，且異質審查證明了價值：找到框內容易漏看的三個結構級缺口（賣方半環/belief基底/履約記帳）。

## 結論
方向（market-as-place 骨幹、accessor 統一、掛單人格化）認同，premise 稽核屬實。**但 3 項結構級缺口 + 6 項具體補完項需處理**——不是推翻重做，是把「只寫了一半」「假裝合規」「拆了沒接手」的洞補上。**issues → halt，退回補齊後重送 R②**（大框寧可多轉，符合藍圖態度；鑑於缺口規模，建議收斂為 spec 修正輪，非直接進 implementer 現場才發現）。
