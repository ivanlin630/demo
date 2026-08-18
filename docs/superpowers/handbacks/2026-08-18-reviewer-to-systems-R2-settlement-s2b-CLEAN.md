---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN] settlement S2b(L0→L1工期)HOW——①親讀outpost_system.gd:272-374確認_tick_construction(:272)driver`ticks_left-=maxi(pop,1)`(:307)逐字對得上,_complete_construction(:315)的crude_camp action分支(:361-373)確認做L1-founding:outpost_type/outpost_level=1/set_owner/food cap=40.0(:366,精準對得上PlayerCommandSystem.CAMP_FOOD_CAP)/tag躍遷/清流亡/TaskArbiter.release——comment明講『玩家紮營完工』,確認這條現況只服務玩家路,NPC沒走過;②親讀establish_crude_camp現況(faction_ai_system.gd:4711-4719,S2a merged後版本)確認只設camp_level=1+camp_ticks_left,comment明講『不設outpost_level...不set_owner...L1據點=S2b工期非本函式』,精準對得上『S2a後NPC無L0→L1路』的負斷言;★附帶發現comment裡寫『不觸全樹47個level==0空tile哨兵』——這正是我上輪S2審抓到spec漏算(聲稱~10處實際45+處)後要求訂正的數字,confirmed systems確實把我上輪必查項的完整計數(47跟我親數的45+同量級)吸收進這輪code comment裡,回饋迴圈生效;③設計冗餘查(這輪R②命門):親讀_dispatch_builder(faction_ai_system.gd:3564起)確認這是『派子隊遠方建新』(target_pos參數+子隊dispatch+旅行到位)的機制,跟S2b提議的『team站自己L0原地投勞力升L1』(in-place、無子隊、無旅行、當下current_task直接變建設)結構上完全不同兩條路——親驗這不是框架內冗餘求解器,是兩個物理情境(已經站在那裡vs需要先走過去)各自合理的獨立決策,不需要收斂成一個;④補丁閘複用_tick_construction/_complete_construction既有spine非新gate確認合理;⑤感知鐵律proximate讀法(站自己腳下L0)跟這session一路驗證過的同款pattern一致;判決=CLEAN→S2b plan→dispatch"
---

# R②判決：settlement S2b（L0→L1 工期）HOW — CLEAN

## ①construction spine 親讀坐實
親讀 `outpost_system.gd:272-374` 確認 `_tick_construction`（`:272`）driver `ticks_left -= maxi(pop,1)`（`:307`）逐字對得上；`_complete_construction`（`:315`）的 `"crude_camp"` action 分支（`:361-373`）確認做 L1-founding：`outpost_type`/`outpost_level=1`/`set_owner`/`food cap=40.0`（`:366`，精準對得上 `PlayerCommandSystem.CAMP_FOOD_CAP`）/tag 躍遷/清流亡/`TaskArbiter.release`——comment 明講「玩家紮營完工」，確認這條現況只服務**玩家路**，NPC 沒走過。

## ②S2a 後 NPC 無 L0→L1 路——確認 + 附帶發現我上輪必查項已被吸收
親讀 `establish_crude_camp` 現況（`faction_ai_system.gd:4711-4719`，S2a merged 後版本）確認只設 `camp_level=1`+`camp_ticks_left`，comment 明講「不設 outpost_level...不 set_owner...L1 據點=S2b 工期非本函式」，精準對得上「S2a 後 NPC 無 L0→L1 路」的負斷言。

**★附帶發現**：comment 裡寫「不觸全樹 **47** 個 level==0 空 tile 哨兵」——這正是我上輪 S2 審抓到 spec 漏算（聲稱「~10 處」、實際 45+ 處）後要求訂正的數字，confirmed systems 確實把我上輪必查項的完整計數（47 跟我親數的 45+ 同量級）吸收進這輪 code comment 裡，回饋迴圈生效。

## ③設計冗餘查（這輪 R②命門）——親驗非重疊，兩個獨立物理情境
親讀 `_dispatch_builder`（`faction_ai_system.gd:3564` 起）確認這是「派子隊遠方建新」（`target_pos` 參數+子隊 dispatch+旅行到位）的機制，跟 S2b 提議的「team 站自己 L0 原地投勞力升 L1」（in-place、無子隊、無旅行、當下 `current_task` 直接變建設）結構上完全不同兩條路。親驗這**不是**框架內冗餘求解器，是兩個物理情境（已經站在那裡 vs 需要先走過去）各自合理的獨立決策，不需要收斂成一個。

## ④⑤其餘
補丁閘複用 `_tick_construction`/`_complete_construction` 既有 spine 非新 gate，確認合理；感知鐵律 proximate 讀法（站自己腳下 L0）跟這 session 一路驗證過的同款 pattern 一致。

## 判決
**CLEAN → S2b plan → dispatch。**
