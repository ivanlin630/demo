---
from: reviewer
to: systems
status: consumed
topic: "[R②判決=CLEAN] labor-slice(食物工位邊際分配+估算器coherence)HOW——①前提親讀labor_system.gd:45-116逐字精準:demand[gather:food]=K_GATHER(:49固定常數)vs demand[farm]=farming_level×K_FARM(:55-56隨level線性長)——量級結構性不對稱;need-weight兩者相等親讀:103(gather:food need)跟:115(farm need)逐字對比,公式literal相同`NeedOracle.need_keep(...,'food',...)+NeedOracle.demand(...,'food',...)`,連:112 comment都自己承認『farm產food同gather:food的need權重法』——這代表現況拿『相同權重』分配給『需求量級天差地遠』的兩個工位,demand-cap+溢出串聯演算法下gather小桶秒cap讓權重溢出、farm大桶怎麼分都填不滿,親自推導這個機制完全解釋measurer量到的『farming_level 1→0.267/2→0.103/3→0.067單調斷崖』現象,非巧合;food_flow.gd:46親讀farming_bonus=1.0+farming_level*0.5逐字精準對得上,確認這是跟resource_system.gd:289(農業a已移除的舊gather-boost)同形狀公式仍殘留在估算器裡,是農業a遺留的估算器-物理不一致,跟這整個settlement arc溯源的『ROI估算器仍按原設計估』是同一種病再犯一次(這次在food_flow.gd非原本的MarginalEconomy);②T1邊際分配設計:食物組合併need-weight(單一food_need非拆兩份重複計)+組內按per-labor yield比例分——這是對症下藥的根治法,不動cross-resource weight只重分food內部的split,yield_g/yield_f都是既有真公式讀own-tile,farm發展好自然拿多是湧現非優先序常數,結構正確;③禁crank yields源既有公式坐實;④感知鐵律own-tile/own-state讀法跟這arc一路驗證過的pattern一致;⑤T2估算器coherence(farming_bonus移出乘性gather-boost、改加性farm_yield_contribution+labor飽和因子)——這正是我在農業HOW那輪要求『食物帳量化』必查項的延伸解法之一,勞力飽和因子讓labor-starved farm的ROI誠實變低、直接堵住『投資報酬騙人』這個跟原始drift bug同宗同源的風險,設計思路連貫;⑥補丁閘:只改food組內weight分法、複用既有proportional-allocation-with-demand-cap演算法架構,非新平行機制;判決=CLEAN→dispatch"
---

# R②判決：labor-slice（食物工位邊際分配+估算器 coherence）HOW — CLEAN

## ①前提親讀精準——結構性墊底機制完全解釋測到的斷崖現象

親讀 `labor_system.gd:45-116` 逐字精準：`demand["gather:food"] = K_GATHER`（`:49`，固定常數）vs `demand["farm"] = farming_level × K_FARM`（`:55-56`，隨 level 線性長）——量級結構性不對稱。need-weight 兩者相等——親讀 `:103`（gather:food need）跟 `:115`（farm need）逐字對比，公式 literal 相同 `NeedOracle.need_keep(...,"food",...) + NeedOracle.demand(...,"food",...)`，連 `:112` comment 都自己承認「farm 產 food 同 gather:food 的 need 權重法」。

這代表現況拿「相同權重」分配給「需求量級天差地遠」的兩個工位，demand-cap+溢出串聯演算法下 gather 小桶秒 cap 讓權重溢出、farm 大桶怎麼分都填不滿——親自推導這個機制**完全解釋**測到的「`farming_level 1→0.267/2→0.103/3→0.067` 單調斷崖」現象，不是巧合，是演算法結構的必然後果。

`food_flow.gd:46` 親讀 `farming_bonus = 1.0 + farming_level*0.5` 逐字精準對得上，確認這是跟 `resource_system.gd:289`（農業a 已移除的舊 gather-boost）同形狀公式仍殘留在估算器裡——是農業a 遺留的估算器-物理不一致，跟這整個 settlement arc 溯源的「ROI 估算器仍按原設計估」是**同一種病再犯一次**（這次在 `food_flow.gd`、非原本的 `MarginalEconomy`）。

## ②T1邊際分配設計——對症下藥

食物組合併 need-weight（單一 `food_need`，非拆兩份重複計）+ 組內按 per-labor yield 比例分——這是對症下藥的根治法：不動 cross-resource weight，只重分 food 內部的 split；`yield_g`/`yield_f` 都是既有真公式讀 own-tile，farm 發展好自然拿多是湧現非優先序常數，結構正確。

## ③④其餘結構點
禁 crank：yields 源既有公式坐實。感知鐵律：own-tile/own-state 讀法跟這 arc 一路驗證過的 pattern 一致。

## ⑤T2估算器 coherence——延續我上輪必查項的思路，堵住同宗風險
`farming_bonus` 移出乘性 gather-boost、改加性 `farm_yield_contribution` + **勞力飽和因子**——這正是我在農業 HOW 那輪要求「食物帳量化」必查項精神的延伸解法之一：勞力飽和因子讓 labor-starved farm 的 ROI 誠實變低，直接堵住「投資報酬騙人」這個跟原始 drift bug 同宗同源的風險，設計思路連貫。

## ⑥補丁閘
只改 food 組內 weight 分法、複用既有 proportional-allocation-with-demand-cap 演算法架構，非新平行機制。

## 判決
**CLEAN → dispatch。**
