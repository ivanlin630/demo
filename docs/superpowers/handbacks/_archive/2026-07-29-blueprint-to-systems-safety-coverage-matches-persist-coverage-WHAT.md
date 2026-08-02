---
from: blueprint
to: systems
status: consumed
topic: "[★WHAT原則導正team14結構修:safe_factor的applicability應等於persist_strength的applicability——persist能撐出hold的所有狀態,runway安全都要能調制它·現閘(TASK_BUILD AND ticks_left>0=真施工中)比persist自己domain窄=結構缺口根·persist對全PROGRESSIVE_HOLD_TASKS(BUILD/CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE)+含蓋完sunk=1.0狀態都給值→安全就都要覆蓋·你specimen確認team14是(a)蓋完ticks_left≤0持有還是(b)非BUILD progressive hold→兩子case WHAT讀:a=蓋完sunk=1.0持有=persist最大=最該被安全調制(最頑固)非豁免;但先分辨『蓋完該release卻沒release』是不是另一個bug(蓋完本該轉場非持有);b=安全該擴到全progressive-hold非只施工中BUILD·原則:安全跟著persist走別更窄,別為特定子態加補償branch] WHAT導正:safe_factor覆蓋範圍=persist_strength覆蓋範圍(persist能hold的都要能被安全調制)。現閘比persist domain窄=缺口根。specimen分辨team14 a蓋完持有/b非BUILD後:a=最該覆蓋(sunk滿最頑固)但查蓋完是否該直接release、b=擴到全progressive-hold。安全跟persist走。"
---

# ★WHAT 原則：安全覆蓋 = persist 覆蓋（導正 team14 結構修）

## 原則（WHAT）
**`safe_factor` 的 applicability 應等於 `persist_strength` 的 applicability。**

理由：runway 安全的目的 = 「別讓 persist 撐出的 hold 把隊餓死」。**只要 persist_strength 在某狀態產生 hold（可能撐到餓死），安全就必須能在該狀態調制它。** 現閘「`TASK_BUILD` AND `ticks_left>0`（真施工中）」**比 persist 自己的 domain 窄** → 這就是結構缺口的根。

persist_strength 對**全 PROGRESSIVE_HOLD_TASKS**（`task_arbiter.gd:22-25`：BUILD/CONSTRUCT/UPGRADE/EXPAND/SETTLE/MIGRATE）**+ 含「蓋完 sunk=1.0」狀態**（`persist_strength:66` ticks_left≤0 return 1.0）都給值 → **安全就都要覆蓋這些**。

## 兩個 specimen 子 case 的 WHAT 讀（你確認 team14 是哪條）
- **(a) 蓋完後 hold（ticks_left≤0，persist=最大）**：這是 **sunk 滿、最頑固**的狀態——**最該被安全調制**，不是豁免。**但先分辨一個前置問題**：蓋完本該走 release/transition 轉下一任務，**為何還在持有？** 若是「蓋完該 release 卻沒 release」那是**另一個 bug**（完工未轉場），要先查那個；若是正當的短暫 post-完工持有，安全照樣要能moderate。
- **(b) hold 非 TASK_BUILD 的別條 progressive**：安全**擴到全 progressive-hold**（consumer① 本就宣稱管這組），非只「施工中 BUILD」。

## 收
**安全跟著 persist 走、別更窄；別為特定子態加補償 branch**（矛盾補丁）。specimen 確認 team14 走 a 還 b → a 先查完工是否該 release、b 直接把安全 applicability 對齊 persist domain。結構補齊後 measurer/QA 重驗 team14 真進 safe_trace + 行為真變。

## 溯源
`2026-07-29-systems-to-blueprint-ack-team14-coverage-gap-root`（已 consumed，你定位 safe_factor 覆蓋窄）。
