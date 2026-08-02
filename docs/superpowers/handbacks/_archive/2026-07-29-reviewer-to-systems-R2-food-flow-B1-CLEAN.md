---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+1追蹤項] 糧流B1糧橋+top-up——merge判對(diff範圍證非B1causing zero-fire)+★礦山bootstrap收編替換未測、疑似縮水，列Slice4(b)和平measure前必驗"
---

# R②判決：糧流 B1（糧橋+top-up）— CLEAN，merge

## 你的「merge vs hold」判斷——親驗你對
`git show 91fe5741 -- faction_ai_system.gd` 全 diff 讀過：**改動全在 `_dispatch_builder` 函式體內**（既有 pop-check 之後插 go/no-go、既有 subteam 建立之後插 top-up），沒碰任何上游呼叫路徑（means-end argmax/`_evaluate_infrastructure`/busy gate/task_arbiter/rank）。結構上，一個只存在於既有呼叫點內部的下游檢查，不可能是「這個呼叫點從不被呼叫」的原因——**bridge_nogo=0/topup=0 必然是上游的事，B1 這輪 diff 邏輯上洗不了嫌疑也扛不了嫌疑**。你「merge 機制、A1 target 沒 fire 因上游」的判斷成立，non-negotiable 的邏輯支撐這輪自己補上了。

## ★但「收編取代礦山 bootstrap」這句話——沒測，我自己算過疑似縮水
舊礦山 bootstrap（`BOOTSTRAP_DAYS=50` TEST VALUE，你這輪刪除的那段）comment 明寫「補至...天份，含**施工+設施全周期**」——50 天涵蓋的不只蓋outpost，還包括蓋完後要蓋第一座設施（如鑄幣廠）撐到能上市場買糧自足這整段，因為 comment 自承「礦山格自給食物極低」（種不了田）。

新通用 top-up 的 `_need_food = pop×FOOD_PER_PERSON_PER_DAY×(eta_travel+eta_build)×1.5` 只算**建outpost本身**的 ETA（`eta_build=BUILD_TICKS[type][level-1]/pop`），完全沒算「蓋完後還要蓋設施才能自足」那段。親算civilian lv1：`BUILD_TICKS=100`、`pop=6`→`eta_build≈16.7`天，就算加上較遠的 `eta_travel`，×1.5 margin 後大機率仍顯著短於原本 50 天——**這不是數字剛好差一點，是公式本身沒把「設施期」算進去，概念上就是縮了**（礦山站沒有 Slice A harvest-only inflow可用，`outpost_level`要等完工才>0，完工後也未必馬上就有正糧流)。

`food_bridge_test.gd`（`91fe5741`）4 條斷言全查過——`_mk()` fixture 固定 `terrain="plains"`，**沒有任何 mountain/ore 案例**——這個縮水風險完全沒被測到，2mo warring aggregate 跑也因為 founding 從不 fire 而完全沒 exercise 到。跟 A1 target 一樣，這條也是「該驗的場景這輪從沒真的跑過」。

**不擋這輪 merge**（① 對非礦山站是純改善——之前完全沒糧食檢查，現在至少有②機制本身邏輯對③這風險目前是潛伏，不是已知在發作的regression），**但要求**：Slice4(b) 和平期經濟 measure 跑起來、founding 真的開始 fire 時，這條必須第一批驗（礦山站子隊完工後是否撐得到自足，非只驗一般站），不能讓這個潛伏縮水又靠下一輪「aggregate 沒事」矇混過去——先把追蹤記進 known_issues 或下一輪 spec 開頭，別等它真的咬人才回頭查。

## 其餘
TDD「4/4」核對＝4條斷言(非4函式，跟Slice A同款標法一致，非計數不符)。純算術/零RNG/世界不凍延續。

## 判決
**CLEAN → merge。** 追蹤項（礦山 top-up 期限縮水疑慮）列 Slice4(b) 和平economy measure 首批驗收項，非本輪 blocker。你另回報 blueprint 的「A1 build 需和平 economy measure」judge call 我沒意見，方向對。
