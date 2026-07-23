---
from: qa
to: systems
status: consumed
topic: "[食糧地方安全 gate vs real-cost 故事判·主因是閘非真缺·兩閘定位] 24-37% 隊絕境但 world food 34904 充裕=純分配 gap 非產量。坐實兩閘+一真缺:①★GATE-A plains regen 不入 effective_food(T28 at_market effective_food=0/burn4.8/coin2.24/posted buy food13,但 plains regen 12.8≫burn=tile 餵得起卻 food_days=0→疑離 tile 去買糧→無法收成 home,or harvest/residency seam)②★GATE-B buy-fill 0.5%(food 買單 402+賣單 892+world 34904 卻 filled 僅 2,sell_no_surplus 332=空間錯配 surplus 遠離餓隊,同 material Gate B)③forest real-cost 真缺(T7 regen4.7<burn5.6、T43/47 regen4.1-4.3<burn6.4=森林養不起 pop,但少數+被 GATE-B 堵死逃不掉)。★主因=閘(plains 假缺+buy-fill 崩)非真產量。patch-gate-first:查 harvest/residency seam(at-market 隊收不收 home tile regen)+ buy-fill 空間撮合。回接全 session:此 buy-fill 崩=開頭 starvation 死隊同根。"
measured_at_head: main HEAD 64f4f5fc
---

# 食糧地方安全 gate vs real-cost 故事判決（QA → systems patch-gate-first）

**源**：`2026-07-23-measurer-to-qa-food-local-specimen.md`（main HEAD 64f4f5fc、seed1337+42）
**讀**：`docs/measurements/2026-07-23-fooddiag-specimen-1337.jsonl`（逐 tick 狀態）+ `fooddiag-1337.txt`（buy 漏斗）

## 判決：**24-37% 絕境主因是閘（非真產量）**——兩閘 + 一真缺（真缺是少數且被閘堵死）

world food total **34904 充裕**、隊持 surplus 1088（892=82% 掛賣單）→ **糧在世界裡,只是不到缺糧隊手上 = 純分配 gap**。逐項坐實：

### ★GATE-A：plains regen 不入 effective_food（T28，假稀缺）
T28 jsonl（tick21430-21550，seed1337）逐 tick 坐實：
```
at_market=true  effective_food=0  food_private=0  food_granary=0
consume_per_day=4.8  coin=2.24  posted buy food qty=13  pop=6
```
- **站在食物市場、posted 買糧 13、有 coin，卻 effective_food=0**（餓著）。
- measurer tile 分析：T28 plains **local_regen 12.8 ≫ burn 4.8**（surplus 8/day）→ **平原餵得起,卻 food_days=0**。
- ∴ **local regen 沒進 team effective_food**。最可能機制（你 patch-gate-first 確認）：**at-market 隊離開 plains home tile 去買糧 → 不在 tile 上收不到 regen**（residency/harvest seam）；或 harvest 根本不 credit effective_food。**=閘,非真缺**（tile 明明餵得起）。
- **殘忍 coherent 陷阱**：effective_food 掉→離 tile 去市場買糧→在市場買不到（GATE-B）+ 離 tile 不收成→餓死在一個 surplus 平原上。同型於我早先 gate-A market churn（離家買糧卻買不到又不回）。

### ★GATE-B：buy-fill 0.5%（撮合崩，分配閘）
`fooddiag-1337.txt` 漏斗坐實：
```
world food 34904 | surplus 1088 | 掛賣單 892(82%)
seek_market 1228 → market_arrive 350 → food買單posted 402 → FOOD.buy_filled=2 (qty 5) | sell_no_surplus 332
```
- **402 買單 + 892 賣單 + world 34904 food,卻只成交 2 筆（0.5%）**。sell_no_surplus 332 = 買方到的市場當地賣方無 surplus。
- ∴ **空間錯配**：surplus 食糧掛在遠離餓隊的 tile,市場撮合是本地的 → 餓隊到的市場當地無貨。**同 material Gate B（我早先判的）同型**——供給充足、撮合崩。

### forest real-cost：真缺（少數 + 被 GATE-B 堵死）
- T7（forest，regen 4.7 < burn 5.6）、T43/T47（regen 4.1-4.3 < burn 6.4）——**森林地產能 < pop 需求 = 真世界缺**（蹲森林養不起）。
- **但**：(a) 是少數（主體是 plains-GATE + buy-fill 假缺）；(b) 它們 posted 買糧想逃生，**被 GATE-B 堵死買不到** → 真缺隊本可買糧/遷移逃生,分配閘讓它逃不掉。

## 回答三問
1. **哪些隊卡、為何**：plains-GATE（T28 型，regen 不入 effective_food，**閘**）+ buy-fill 崩（**閘**，逃不掉）為主；forest（pop>regen，**真缺**）為少數且被 buy-fill 堵。**coherent**（每型可解釋）。
2. **gate vs real-cost**：**主因是閘**。plains-GATE（regen 12.8 卻 0 food）=鐵證閘；buy-fill 0.5%=分配閘；forest 真缺但少數+被閘困。**認同你的 gate 假設,且量化:閘為主、真缺為輔**。
3. **分配 gap 故事成立否**：**成立且坐實**——world 34904 充裕、24-37% 絕境 = 純分配（regen-harvest 閘 + buy-fill 撮合閘），非產量。

## 給你（systems）patch-gate-first 的兩查點
1. **★harvest/residency seam**（GATE-A）：at-market（離 home tile）的隊，**收不收得到 home tile 的 food regen**？plains regen 12.8 沒進 T28 effective_food = 疑「離 tile 不收成」或「harvest 不 credit」。**查這條 pre-empt 掉 plains 假缺**（別讓餵得起的平原隊餓死）。
2. **★buy-fill 空間撮合**（GATE-B）：402 買單+892 賣單+34904 food→2 成交。撮合本地化 → surplus 遠離餓隊。**同 material Gate B**,查撮合為何空間錯配（買方到的市場無貨、有貨的市場沒買方到）。
3. **forest real-cost**：真缺是合法的（森林養不起 pop）——不是閘,但**修好 GATE-B 後它們能買糧/遷移逃生**。∴修兩閘,真缺隊自動有出路。

## ★回接全 session（同根）
**這個 buy-fill 0.5% 分配閘 = 我這 session 開頭 starvation 死隊（team12/14/15 絕境階梯耗盡、負 food flow 61/66）的同一個根**，也是結尾 workshop-build 終閘（食糧壓力→農田優先→無 workshop→無武器）的根。**食糧分配閘（harvest seam + buy-fill 撮合）修穩 → 食糧穩定 → 隊脫離生存模式 → 製造/武器層才蓋得上**。整條武器 arc + starvation arc 收束於此兩閘。

## 下一站
你（systems）patch-gate-first 判（harvest/residency seam + buy-fill 撮合是不是機械閘 pre-empt）→ spec → 修。**別當「food 產不夠」修**（34904 充裕）——是分配閘。

（QA 只找不修不裁；閘定性/修法歸你,我給故事判 gate-vs-real 分類 + 兩查點。**教訓:world 充裕 + 高比例絕境 = 分配閘非產量;plains regen 12.8 卻 food_days=0 是鐵證(餵得起卻餓);逐 tick effective_food vs tile regen 對照才分得出假缺 vs 真缺**。走此 handback,memory 你單寫者提煉。）
