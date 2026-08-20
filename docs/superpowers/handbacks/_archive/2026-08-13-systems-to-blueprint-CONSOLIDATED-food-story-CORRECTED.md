---
from: systems
to: blueprint
status: consumed
topic: "[★單一完整食物故事收口(用戶怒點『一次到位帳關起來』達成)·ledger CLOSE(diff=-7e-11 浮點級)·★★重大訂正:舊『世界無盈餘引擎/出生資不抵債』過強假說 RETRACTED——GRAND 世界真總量僅 -8.1%(120735→111009.6)溫和衰退非死亡螺旋;-75.6% 那數字真身=team.food(-72.9%,團私產非世界總量)·pool 分解定生死:tile 自然池(佔 GRAND 6 成+、76805)-0.04% 全程紋風不動+granary +2.5% 穩定→世界食物沒在崩、崩在團私產分配層·dominant sink=eat_team -10366.7=99% SINK=genuine 消耗(團有糧吃掉扣掉、非機械榨乾非雙扣非神秘 sink)·erase-蒸發=0(本月無滅團、未觀測非證偽、我 code-read 的 structural break latent 未 fire)·★真根 reframe:資不抵債→分配/接入問題+執行斷:世界富(tile 池滿+倉穩)但 91%+ 流浪團接不到(不定居→無倉→糧背身上一路吃只出不進 eat_team)·Q1 用戶『兩月抽乾必有未知 sink』=DISSOLVED(帳 close 無神秘 sink、-75.6% 是量錯層 team.food 非 grand)·★我 census-artifact 假設誠實結算:方向對(非物理世界餓死=坐實)but 機制錯(不是 effective_food 站家才計倉的 census undercount、是 team.food genuine drain via eat_team)——measurer decomposition 才是訂正功臣、我假設別當坐實·Q2 建設:贏 argmax 15 次 but 除 tick10 bootstrap 3 筆、其餘 12 全 try_set_noop=同 JOIN/raid/occupy funnel『決策贏執行斷』(手不聽腦第 4 型)·★附:發現 record_driver 契約 bug(set_amt/pool_set 記絕對值非 delta、tile_bank:40 自認、污染守恆稽核不影響 gameplay=driver_ledger off)=我 owner observability 領域、log known_issues+formal fix 候選·evidence-only 禁 fix·序:你用訂正版帶用戶(GRAND-8.1%/team_food-72.9%/genuine eat/分配接入+執行斷)取代舊資不抵債框、生存經濟基座 arc reframe=修 settle/build 執行 funnel 讓多數接到富池 非加盈餘引擎(池本就滿)·地基 KEEP"
---

# ★單一完整食物故事收口（用戶怒點「一次到位、帳關起來」達成）

ledger **CLOSE**（diff=-7.276e-11 浮點級精確）。evidence-only、禁 fix。**這封取代先前所有食物 handback 的單一聚合數字 + 過強假說。**

## ★★重大訂正（RETRACT 舊「世界無盈餘引擎/資不抵債」）
用戶 Q1「兩月能把食物抽乾嗎、必有未知 sink」= **DISSOLVED**：帳 close、**無神秘 sink**。舊 -75.6% 是**量錯層**。

### pool 分解定生死（t0→day30）
| pool | t0 | day30 | 變化 | 意義 |
|---|---|---|---|---|
| tile 自然池（佔 GRAND 6 成+） | 76805 | 76795 | **-0.04%** | 世界糧源紋風不動 |
| granary | 29600 | 30327 | **+2.5%** | 穩定微升 |
| **team.food（團私產）** | 14330 | 3887 | **-72.9%** | ★真崩在這 |
| **GRAND（世界真總量）** | 120735 | 111010 | **-8.1%** | 溫和衰退、非死亡螺旋 |

**-75.6% 那數字真身 = team.food（團私產、非世界總量）。** 世界食物沒在崩——tile 自然池滿著不動、倉穩定。**崩的是團私產這一層的分配。**

## ★Q1 dominant sink（無神秘兇手）
`eat_team = -10366.7 = 99% of SINK` = **genuine 消耗**（團有糧、吃了、扣掉——非機械榨乾/非雙扣/非神秘 sink）。erase-蒸發=0（本月無滅團，未觀測≠證偽，我 code-read 的 structural conservation-break latent 未 fire）。eat_depleted/eat_granary_depleted 量都零頭、genuine 非超吃。

## ★★真根 reframe（比「資不抵債」精確且可修）
**不是世界窮，是世界富但多數接不到 + 建設執行斷。**
1. 世界總量溫和（-8.1%）、tile 池 6 成+ 靜止滿、倉穩 → **世界糧食產能足、有盈餘可及**（≠無盈餘引擎）。
2. team.food -72.9% via genuine eat_team → **流浪團把糧背身上一路吃、只出不進**。
3. 為何不進：**91%+ 從未定居**（佔據率月底 8.6%）、resident **0% 執行過生產** → 無法把滿著的 tile 池轉成受保護的 granary 糧。
4. 為何不定居/建設：**建設 option 贏 argmax 15 次、但除 tick10 bootstrap 3 筆、其餘 12 全 `try_set_noop`**（TaskArbiter.try_set 沒真設上）= 同 JOIN/raid/occupy 的 funnel = **決策贏、執行斷（手不聽腦第 4 型 [[project_hand_obeys_brain_arc]]）**。

∴貧困**非資源清償不能**，是**執行/接入失敗**：世界富、majority 接不到（settle/build 決策不執行）+ 流浪 carry-and-eat。

## ★我 census-artifact 假設誠實結算
我先前頭號假設「-75.6% 是 effective_food 站家才計倉的 census 位置蒸發」——**方向對**（非物理世界餓死=坐實 GRAND 只 -8.1%）**but 機制錯**：真身是 team.food genuine drain via eat_team，不是 census undercount。**measurer 的 pool decomposition 才是訂正功臣、我假設別當坐實**（守 measure-first、別 over-claim [[feedback_structural_audit_complement]]）。

## ★附：record_driver 契約 bug（observability、我 owner 領域）
`record_driver(entity,field,delta,reason)` 收 delta，但 `TileBank.set_amt`(tile_bank:41)/`pool_set`(:65)（及 `ResourceBank.set_amt`）傳**絕對值**當 delta（deposit/withdraw/pool_add 傳真 delta ✓；:40 註自認「delta 記絕對值慣例」）。**不影響 gameplay**（driver_ledger 預設 off、純觀測）**但污染守恆稽核**（measurer 第一版帳差 5600 萬即此，已 prototype fix+revert）。= [[feedback_full_transient_observability]] tap 完整性領域。我 log known_issues + formal fix 候選、待你/用戶排序。

## 序
你用**訂正版**帶用戶（GRAND -8.1% / team_food -72.9% / genuine eat_team / 分配-接入 + 執行斷）**取代舊資不抵債框**。生存經濟基座 arc **reframe** = 修 **settle/build 執行 funnel**（讓多數團接到富池）**非加盈餘引擎**（池本就滿）。落地檔 measurer commit `13fb36d3`（pool_curve/food_flow/close_check）。地基 KEEP。
