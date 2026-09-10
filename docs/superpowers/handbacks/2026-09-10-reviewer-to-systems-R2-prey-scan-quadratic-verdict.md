---
from: reviewer
to: systems
status: consumed
slice: 獵物掃描的 O(N²)×尋路
topic: R² 判決 — 非CLEAN,而且比你問的更根本：weakness跟trip【兩個都不是gate】,只是計分項,整個函式從has_belief之後到return之間沒有第二個continue——重排它們對尋路呼叫次數的影響是零,不是「省一半」；(2)你的0命中直覺對,而且找到了真正可省的地方但它在PathSystem內部,踩到本票自己的邊界；(3)你的疑慮被放大——連到我剛審完的錯開票,那張的殘餘spike可能比你猜的更嚴重
---

# R² 判決：`2026-09-10-prey-scan-quadratic-pathfinding-HOW.md`

## 判決：非 CLEAN——(1) 是這張票能不能成立的地基，追下去發現地基本身有洞

## (1) 語意真的不變：你自己抓到 `trip` 依賴 `catch_result` 是對的，但問題比這個大——
weakness 跟 trip 都【不是 gate】，整個函式沒有第二個 continue

先確認你自己的疑慮：`trip_need`（:279）用 `eta_days`（:276），`eta_days` 用
`catch_result.eta`（:276）——`trip` **確實依賴尋路結果**，不能移到 :251 之前。
你抓到這個是對的，判 (a) 那半不成立。

**但我把整個函式讀到 :315 的 `return best_id`，發現一件更根本的事**：

```
faction_ai_system.gd:245   if tid == team.team_id: continue
faction_ai_system.gd:248   if prey.faction_id != -1 and prey.faction_id == team.faction_id: continue
faction_ai_system.gd:250   if not BeliefSystem.has_belief(...): continue
faction_ai_system.gd:251   var catch_result = PathSystem.estimate_catch_up(...)   ← 尋路
faction_ai_system.gd:252   if not catch_result.reachable: continue
faction_ai_system.gd:253-309   bel／armed_est／weakness／border／eta_days／trip／own／logistics 全部算完
faction_ai_system.gd:310-311   score = (richness*greed + weakness*cruelty + border*ambition) / eta_days * logistics
faction_ai_system.gd:312       if score > best_score: best_score = score; best_id = tid
faction_ai_system.gd:315       return best_id
```

★★★**從 :253 到 :315，中間【沒有第二個 continue】。** `weakness` 從頭到尾只是加進
`score` 這條算式的一個乘數項，它的值再低也不會讓那個候選被跳過——它跟 `richness`／
`border`／`trip` 一樣，只影響最後排第幾名，不影響「要不要付尋路的錢」。
⇒ **真正會讓候選跳過尋路的條件只有三個（:245/:248/:250），而它們已經全部排在
:251 尋路之前**——現在的程式碼在「先過濾再尋路」這件事上，**已經是對的**，
沒有東西可以再往前搬。

⇒ **把 `weakness` 移到 :251 之前,對尋路呼叫次數的影響是零**——不是「省一半」，
是完全不省。這張票標題「先過便宜的濾網,再尋路」描述的操作**在這支函式裡沒有對象
可以操作**：唯一「便宜」的東西（自己/同派系/無belief）已經在前面了，
「貴」的東西（weakness/trip/richness/border/eta）沒有一個是 gate，全部是純計分項，
重排計分項的順序不會少呼叫一次 `estimate_catch_up`。

**這張票目前的核心機制（§④①）不成立，不是打折，是空的。**

## (2) per-tick 快取：你的 0 命中直覺對，但我往下多查了一層——真正能省的地方存在，
只是在 `estimate_catch_up` 內部，踩到你自己劃的線

你猜「`estimate_catch_up` 第一個參數是發問的那支隊,每支隊問的都是不同key,
命中率可能是0」——查了函式簽名跟呼叫慣例（每支隊各自 gather 一次，`(team,tid)`
組合天然不重複），這個直覺對，若照 spec 現在寫的 `(team, tid)` 當快取 key，命中率確實
接近 0，這一項該從 spec 拿掉。

**但我往 `PathSystem.estimate_catch_up`（path_system.gd:230-260）內部多讀了一層**：
真正貴的那步是 :246 `cost = catch_cost(state, self_team.tile_pos, tgt_pos)`——
★★這一步的輸入是【兩個位置】，不是兩個隊的身分。若在同一個 tick 裡，
不同的隊剛好問到【相近或相同的起點/終點位置】（例如聚在同一個市集附近的幾支隊
都在評估同一批鄰近目標），`catch_cost(posA, posB)` 是可能重複算的——
★這個快取如果存在，鍵應該是**位置對**不是**隊身分對**。
⇒ 但這個快取要做，得**開 `PathSystem` 的內部函式**，而你 §⑥③ 已經明寫
「不順手改 `estimate_catch_up` 本身——它是別人的東西」。**這正確**，但也代表
「本票的第二部分（per-tick 快取）如果照 spec 現在寫的鍵，砍掉沒有損失；
如果要做真正有效的那個版本，範圍已經超出本票自己劃的線，要嘛擴大範圍要嘛留給下一票。**

## (3) 「74ms／tick，不是急件」這個序的前提，我要點出一個你可能沒接到的訊息

我剛審完「錯開每小時的思考pass」那張票（`stagger-hourly-thinking-pass`）——
判決是**非 CLEAN**，而且原因正好打在你這格的前提上：我算出那張票的錯開機制
（在現有 `%NEAR_CADENCE` 每60tick才檢查一次的結構下用 `CadenceStagger` 的連續
offset）會讓**幾乎所有隊（59/60）的思考間隔從60tick變成120tick，而且collapse到
同一個檢查點**，不是均勻分散——也就是說，那張票如果照現在的形狀 dispatch，
**「74ms/tick 的平均值」這個算式本身可能不成立**（分母的分散假設是錯的）。

你的疑慮「錯開之後仍可能有5-6隊同時到期」判斷方向是對的，但幅度可能比你猜的嚴重
很多——我的推導顯示可能不是「還有5-6隊沒錯開乾淨」，是「錯開機制本身在這個
cadence量級下數學上會讓大部分隊collapse回同一個檢查點」。這件事需要那張票先定案
（它現在卡在要不要回blueprint談，看要選桶模式還是拆掉全域閘），**這張票的序
（排體驗窗與攻擊門之後）在那張票定案前是不可信的**——不是你算錯，是你依賴的
那個輸入（錯開票的效果）本身還沒確定。

## 要求

(1) 是本票能不能成立的地基，地基目前是空的——**這張票需要重新想第一層修法要做什麼**，
不是排序或用詞問題。可能的方向（供你判，不裁）：真正有效的第一層修法要嘛是
在 :250 (has_belief) 之後、:251 (尋路) 之前，找一個【目前不存在但可以無害新增的
早退條件】（例如：若 belief 給的 armed_est 已經高到不可能贏，直接不評分這個候選——
但這會是【新的 continue】不是【重排既有的】，要重新過一次「語意不變」這關，
可能得升到第二層甚至要 blueprint 過目）；要嘛承認第一層目前沒有東西可做，
直接跳去談快取（在 PathSystem 內、位置鍵）或第二三層。

(2)(3) 記錄，不阻塞——都需要跟著(1)的結論調整,不用單獨處理。

CLEAN 差：(1) 的地基問題解決之前，這張票不能 dispatch。
