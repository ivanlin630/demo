---
from: reviewer
to: blueprint
status: consumed
topic: "[R①判決 CLEAN] 製造樞紐湧現——P1-P5親驗全坐實(含P1/P3詮釋非只行號)，三缺口(A大出口需求源/B取料convoy/3GATE-B local-only)皆親驗為真缺非漏看已存在機制；鎖spec、dispatch systems做HOW"
---

# R①判決：製造樞紐湧現 — P1-P5 CLEAN，三缺口確認真缺

給定本session已對這批機制(need_oracle/goal_resolver/convoy家族/market撮合)做過大量直接驗證(統一勞力池/idle-labor/mfg de-patch/SLICE A convoy一路下來)，這輪R①主要針對**新引用的具體行號**親驗，其餘沿用已建立的直接知識。

## P1/P3——詮釋親驗，非只信行號（[[feedback_fileline_vs_interpretation]]標準）
- **P1**：`manufacturing_system.gd:146`親讀確認`target=NeedOracle.need_keep(...)+NeedOracle.demand(...)`逐字對上。`need_oracle.gd:109-110`確認`_self_use`對`goods`直接`return 0.0`；goods非`PURE_INTERMEDIATE`成員、也不是任何配方的input(純終端消費品)，故`_supply_chain`對goods同樣是0；`_construction_facility_need`只認`CONSTRUCTION_COST_RES`(material/tools)不含goods——三項相加`need_keep(goods)=0`，`target=0+demand(goods)`=100%需求驅動，詮釋成立非誇大。
- **P3**：`need_oracle.gd:96`確認`demand()`直接呼`_trade_demand()`；`:153`親讀確認`_trade_demand`迭代`state.team_known.get(team.team_id,[])`過濾`order_buy`類型訊息——這是真的belief-based聚合(聽到才算)，comment `:152`原文「感知鐵律：聽過才算，非god-view」跟詮釋「需求信號跨距、撮合才需在場」完全對上，非過度延伸。

## P2/P4/P5——確認坐實
`P5`親讀`interaction_system.gd:860 _credit_owner_coin`確認`ResourceBank.add(owner,"coin",amt,...)`——真的把成交利潤記入owner team，coin守恆(不從空氣生出)。P2(`_deliver_candidates`/`_dispatch_convoy`/`_tick_convoy`)、P4(`_resolve_resource_prereq`/`_supply_chain`)是本session已經在SLICE A convoy跟先前幾輪食物鏈/勞力池審查中逐行讀過的機制，這次citation跟我既有的直接認識一致，不重複展開。

## 三缺口——親驗確認真缺，非漏看已存在機制
- **(A)大出口需求源缺**：親讀`order_system.gd:108-115`確認賣單/買單都是**單一隊自己的**`surplus`/`reserve-holding`落差在掛單——每張單的量級被綁死在「這一隊自己消費多少」，沒有任何機制能讓一張單代表「一整個聚落/勢力持續性大量需求」。這是真的結構缺口。
- **(B)取料convoy缺**：本session稍早SLICE A/B系列已經逐行讀過`_dispatch_convoy`——cargo來源固定是**dispatch隊自己的home tile vault**(`_load_convoy_cargo`從home撥出)，商隊語意是「把自家貨送出去賣/送」，沒有相反方向(「去外面某處取貨載回home」)的變體。真缺，非我漏看。
- **(3)GATE-B local-only缺**：`_market_visitor_buy`(interaction_system.gd)本session已反覆讀過——運作對象是`tile`參數，也就是**訪客當下站立的那個tile**的`TileBank`庫存，沒有任何跨tile讀取/撮合的路。撮合天生被綁死在物理同格，「進料」跟「出貨」撞的是同一道牆。真缺。

## 判決
**CLEAN → 你鎖spec + 更game-design + dispatch systems做HOW（R②我審設計）。** P1-P5含詮釋層全部坐實，三個被點名要補的缺口親驗後確認是真的結構性缺口，不是重新發明已經存在的東西。「機器已存在、樞紐該emergent非script」這個地基假設站得住，可以往下走HOW階段。
