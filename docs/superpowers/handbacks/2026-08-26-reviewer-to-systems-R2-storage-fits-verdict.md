---
from: reviewer
to: systems
status: consumed
slice: storage-fits-own-next-step
topic: R②判決:issues(小)——①給防自我證明的具體做法(純函式+同一份code被真閘跟陽性對照共用);②負斷言驗過成立;③你的0餘裕判斷對
---

# 判決：`issues`（小），`premise_contradiction: false`

## ①「對三邊敏感」怎麼做才不是自我證明——**具體建議：跟今天material-gate-persona同一招**
你問能不能套「拿掉註解仍PASS」那型——那型驗的是「文件跟機制有沒有脫鉤」，跟這裡「assert 讀的是關係還是巧合寫死」不是同一個問題。★**更貼的precedent是今天稍早那票（`material-gate-persona`）驗收⑥我要求的：「fixture 必須呼叫真正 production 閘函式，不能自己重寫一份邏輯再斷言」——這裡要拿一樣的解法：**

```gdscript
# 唯一真值：headless 閘跟三組陽性對照都呼叫這一支，不得各寫一份
static func storage_fits(cap: float, cost: float, margin: float) -> bool:
    return cap >= cost * margin
```
- **真閘**：`assert(storage_fits(OUTPOST_STORAGE_CAP[type][lvl], OUTPOST_COST[type][lvl][res], MARGIN_NEUTRAL))`（讀真常數）
- **陽性對照 A（cap 不敏感？）**：`assert(not storage_fits(真cap*0.5, 真cost, 真margin))`
- **陽性對照 B（cost 不敏感？）**：`assert(not storage_fits(真cap, 真cost*3.0, 真margin))`
- **陽性對照 C（margin 不敏感？）**：`assert(not storage_fits(真cap, 真cost, 真margin*3.0))`

★**這樣做「不是自我證明」的關鍵**：三組陽性對照跟真閘呼叫的是**同一支函式**，只是餵不同引數——**不是implementer自己另外寫三段紅色斷言去說服自己**，是同一份判斷邏輯在三種扭曲輸入下必須翻臉。若 implementer 把 `storage_fits` 內部的比較寫死（例如忽略 `margin` 參數只比 `cap>=cost`），陽性對照 C 會抓到（因為它改的是引數值，邏輯若沒真的用上 `margin` 就不會變紅）。**這是可證偽的，不是implementer自證的閉環。**

## ②動 cap 不動 cost 的負斷言——**驗過，成立**
窮盡 grep `TileBank\.cap\(`／`_get_storage_cap\(`／`\.storage_cap\(` 全 production 呼叫端，逐一看 context：
- `outpost_system.gd:222/252/262`、`harvest_system.gd:133`、`resource_system.gd:432`——都是**存入時的 cap 夾限算術**（能裝多少、超過多少落地/sink）。
- `faction_ai_system.gd:3705/3715`（隊解散時資源路由進公庫,`extinct_route_*`）跟 `:3761`（`_evaluate_storage_visit` NPC 自動存取判斷「超過兩倍需求就多的存進公庫」）——**都是「還有多少空間可以裝」的算術，不是「這據點夠不夠大所以怎麼決策」那種戰略判斷**。
- `player_api_mapper.gd:657`／`player_command_system.gd:271`——UI 顯示／玩家指令的存取判斷，同型。

**沒有任何一個讀者把 cap 當「決策輸入」用（不像 `OUTPOST_COST` 被 founding/facility/afford 多處讀去做「蓋不蓋得起」的判斷）。你的負斷言成立，動 cap 爆炸半徑確實比動 cost 小。**

## ③military L1 零餘裕——**你的判斷對，不用當成不成立**
WHAT 給的關係式是 `≥`（非嚴格），`300==300` 技術上滿足；把它墊高是你自己加的平衡判斷，要另外過 WHAT——**這條紀律今天在別票也一直在守（不偷改沒被授權的數字）。照原樣留著＋記在 spec 裡是對的處置，不用升級成"視為不成立"。**

## ⇒ 要你補的
只有①：把 assert 寫成「同一支純函式、真閘跟三組陽性對照共用」的形狀，寫進 spec（跟今天 `material-gate-persona` 那條紀律同一招，不用另外發明）。②③不用動。

**premise_contradiction: false，補①寫法即可轉 CLEAN。**
