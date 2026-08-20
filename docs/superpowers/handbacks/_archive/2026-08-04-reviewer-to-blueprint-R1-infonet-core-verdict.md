---
from: reviewer
to: blueprint
status: consumed
topic: "[R①判決 CLEAN] 資訊網核心——P1-P5全親驗坐實，★「一root三症」詮釋不是表面相似，是文字性驗證：D1(食物尋覓源②)跟D2(distribute)親讀確認literally讀同一個team_known底層結構、同一個propagate_on_arrival co-location閘，非巧合式的類比；P2「只缺拓撲非缺decay」親算decay公式本身已是multi-hop-ready架構佐證；鎖spec、dispatch systems whole build"
---

# R①判決：資訊網核心 — P1-P5 CLEAN，一root三症親驗坐實非表面類比

給定這輪R①決定的是「whole-build一次量」這個大範圍、難逆的scope決策，逐條認真核對，D1/D2交會處我親自往下追了一層機制層級的證據，非停在citation表面。

## P1——co-location閘親讀坐實
`message_system.gd:79`：`if other_team.tile_pos != arrived_team.tile_pos: continue`——這是propagation唯一的gate，兩隊沒有站在同一格，訊息交換完全不會發生。一個settled隊如果從不離開自己的據點、也沒有別隊剛好路過共位，這條路徑對它來說永遠是死的。「settled不共位=死角」不是誇大，是這行code唯一能做的事的直接後果。

## P2——「只缺拓撲」的框架親算佐證
`:103`：`copy.strength=msg.strength×(1-HOP_DECAY)×time_factor`——這個公式的形狀本身就是為**多跳**傳播設計的(每經一手乘一次`(1-HOP_DECAY)`)，加上`義氣/慎重`人格影響的`_decide_propagation_mode`(honest/unintentional distort分支)——這整套decay/distort機制已經是一個成熟的、預期訊息會經過多手carrier傳遞的架構，只是現在唯一觸發它的條件(共位)太窄，導致訊息很少真的傳超過一手。這支持「decay底子在、缺的是讓訊息能傳出去的拓撲(relay/看板/多路徑)」這個框架，不是「decay公式本身有問題、whole-build後才發現要重寫」的風險。

## P3/P4/P5——確認坐實
`order_system.gd:194 read_market_board`：親讀確認`tile.outpost_level<=0`(不在市集)就直接return——賣方/買方必須物理抵達市集這個outpost才能讀到板上的單，這是既有唯一的「物理抵達換取跨距離firsthand資訊」的模式，P3精準。P4(求援/派信使決策不存在)——本session這麼多輪下來我反覆讀過`options.gd`的決策選單全貌，從未遇到任何類似「主動求援」「派人查」的選項，跟這個negative claim一致。P5——`interaction_system.gd`的`_market_visitor_buy`/`_market_visitor_sell`我在這個session已經直接讀過好幾輪，運作對象都是`tile.public_storage`/`TileBank`(屋主公庫)，不是任意同格team的私產，跟「窄」的定性一致。

## ★D1/D2「一root三症」——親驗到機制層，非表面類比
這是這輪最重要的判斷。我親讀`faction_ai_system.gd:3908-3933`(`_find_food_seek_target`)：源②(3924-3932)明確呼叫`OrderSystem.new().received_sell_orders(state,team)`——這個函式(跟`received_buy_orders`同一個家族)讀的是`state.team_known.get(team.team_id,[])`，**跟distribute-zero(D2)問題裡`received_buy_orders`讀的是同一個底層資料結構、同一套由`propagate_on_arrival`的co-location閘餵進去的東西**。這不是「兩個問題看起來很像所以我假設同根」，是我直接讀到兩段code呼叫的是**同一個資料管道**，被**同一個機制**(P1的co-location gate)餓死。這比D1/D2診斷JSON本身的斷言更硬——是我自己往下追一層挖到的file:line級證據。

加上D2(distribute-zero)這個症狀我在SLICE B分配政策那兩輪R②已經徹底審過：util/argmax/candidate生成全部驗證正常(rank0贏util1.33)，唯一binding就是`received_buy_orders`不達——這代表D2「非決策層問題、純資訊層問題」這個結論不是這次audit新猜的，是我自己在更早、獨立於這次資訊網大框的審查裡已經確認過的事實。兩條線收斂在同一個答案，互相佐證。

## 判決
**CLEAN → 你鎖spec → dispatch systems whole build。** P1-P5坐實、P2的「只缺拓撲」框架有decay公式本身的multi-hop設計佐證、D1/D2「一root」不是表面類比是機制層面的同一個底層資料結構——這次whole-build一次量的地基站得住，不是三個各自獨立問題硬湊成一個故事。
