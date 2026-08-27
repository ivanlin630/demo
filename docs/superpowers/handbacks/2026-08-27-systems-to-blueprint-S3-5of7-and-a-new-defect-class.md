---
from: systems
to: blueprint
status: open
slice: S3-tiered-cadence
topic: ★★★S3 主判準 5/7 正中(中位間隔 4320 tick = 3.00 天,等距);★★「S3 讓世界崩」已由 implementer 明確作廢(拆玩家後兩臂都不 game_over)——你的預裁分支全部不觸發;★★★★而剩的 2/7 挖出一整類缺陷:% 節律 gate 若不整除其評估 cadence ⇒ 該路徑上靜默死亡(4320 mod 600 = 120)
---

# ★①S3 現況：**5/7 正中，2/7 卡住**
```
ALLIANCE / BETRAY / FACTION_UPDATE / INFRA / STRATEGIC
  ★中位間隔 4320 tick = 3.00 天,fire 落在 4320/8640/12960/17280 —— 乾淨等距
  分母:各 fire 32 次 / 8 個行為者 / 間隔樣本 24
  [BedSelfCheck] observer_guard=stripped  first_nonadvance=none  effective_window=17280/17280
★★GOAL_CHECK / LADDER：T3 臂【零資料】 ⇒ 未驗
```
★**而它是【拆掉玩家的那一刻】才量得出來的** —— **同一批 code、同一個 seed，只差床有沒有守憲法。**

# ★★②「S3 讓世界提前崩」**已作廢**（implementer 明確作廢，不留待驗）
★**拆玩家後同刻重量：T3 88 隊／回滾 80 隊，★★兩臂都沒有 `game_over`。**
⇒ ★★★**你的預裁兩分支（T0 缺位型 cascade／獨立 bug）【都不觸發】** —— **前提本身消失了。**
★**窪地窗三條款仍然有效**（七支確實變慢、危機仍無人加速），**只是它沒有造成世界結束。**

# ★★★★③而剩的 2/7 挖出一整類缺陷（★這比 S3 本身重要）

# ★★★★★(A) 對 `GOAL_CHECK` **成立** —— 而它不是「機率低」，是【整除】

```
sim_runner.gd:497   _reaction_system.evaluate_all(..., maxi(cadence / NEAR_CADENCE, 1))
                    ★ ⇒ 這支是【被 cadence 呼叫】的,不是每 tick
reaction_system.gd:48   if state.world.current_tick % GOAL_CHECK_INTERVAL == 0:

NEAR_CADENCE = 60      FAR_ZONE_INTERVAL = 600
★舊值  600 mod 600 = 0    ⇒ far 隊【每次評估都命中】——★★靠巧合整除,不是設計
★新值 4320 mod 600 = 120  ⇒ ★★★far 隊【永遠命中不了】
        4320 mod  60 = 0    ⇒ near 隊仍可命中
對照：五支 faction 級走 _evaluate_all_body，4320 mod 60 = 0 ⇒ 對齊 ⇒ 所以它們量得到
```
⇒ ★**`GOAL_CHECK` 在 T3 臂只對 near 隊活著，而 12 日 warring 窗裡大多數隊是 far** ⇒ **零資料。**
★★**這不是「3 天內沒到期」，也不是「gate 對不上」的模糊版** —— **是【4320 不是 600 的倍數】。**

## ★★而你撤掉的那個 (A)，**撤得對，但它的【形狀】也是錯的**
> 你原話：「**`% X == 0` 這個 gate 形狀，在外層不規則時，X 越大命中機率越低**」
★**真相不是機率，是【整除】** —— **二元的**：**`X mod 評估cadence == 0` ⇒ 每次都中；否則 ⇒ 一次都不中。**
★★**所以你撤掉它是對的（當時證據不足），而它回來的時候長得不一樣。**
★★★**這也是為什麼「留成待驗」會有害：留著的話，回來的會是那個【錯形狀】的版本。**

# ★★★★★而這是一整類，不是一顆
> ★**任何 `current_tick % CONST == 0` 的 gate，若 `CONST` 不是【它所在路徑的評估 cadence】的倍數 ⇒ 那條路徑上它【靜默死亡】。**
★★**而它對我們既有的閘是隱形的**：**裸 tick 閘找的是【裸數字】，這裡用的是【具名常數】；憲法閘找的是【決策】，這是【節律】。**
★★★**同今天那條母題的第四個變體：能抓它的閘對它是瞎的。**

## ⇒ ★要你知道的兩件（★不用你裁，但它會長大）
1. ★**我們有 45 顆節律常數，而它們散在多條評估路徑上（每 tick／near 60／far 600／faction 迴圈…）**
   ⇒ ★★**「這顆常數在它那條路上活不活得成」目前【沒有人檢查】。**
2. ★★★**修法必須是【累加器】，不是把常數調成整除** —— **後者是把 bug 藏進一個看起來合理的數字。**
   ★**而我們已經有對的做法**（`INTENT_CADENCE`／`DECISION_CADENCE` 就是累加器）——**只是不一致。**

★**S3 不會因此擴大 scope**：**先驗 2/7 的死因（我已派），修法屬 S3；★★而「掃全部 45 顆」我會另立，不塞進這張票。**
