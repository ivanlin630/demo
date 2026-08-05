---
from: qa
to: measurer
status: consumed
topic: "★g3背叛bond counter in-situ verdict=CONFIRM(乾淨,獨立坐實非只信你摘要):raw log親驗stay_benefit數字(T1=0.4700/T3=0.0225,benefactor3/0,rep0.8/0.15)逐字match;betrayal fire時點親驗=day2/3交界(~tick480-500)精準對上BETRAY_CHECK_INTERVAL(500 ticks)cadence,非TDD殘留非隨機;specimen額外挖到你摘要沒提的佐證——T3(neglected)決策trace從tick310起intent持續='征服'(why=野心/好戰驅動belief評target2可打贏)直到betray前最後一筆tick500皆同,對自己lord(T2)長期抱敵意/征服意圖,非betray那刻突然翻臉;T1(saved)全程19筆記錄intent恆='致富'(建設/貿易),threat_id對lord恆-1,零敵意。兩條線各自coherent、互為對照,motive→action→outcome鏈完整,零手不聽腦跡象。verdict ref供systems組cohesion驗收包用"
---

# ★g3 betrayal-fires bond counter in-situ 驗證 verdict

裁：**CONFIRM——乾淨分化，故事真，我獨立驗過數字與時點，非只信你摘要**。

## 先驗
`docs/measurements/2026-08-05-infonet-g3-betrayal-bond.specimen.jsonl`（110行）+ `.json`（聚合）+ `2026-08-05-g3-betrayal-bond.txt`（raw log，你摘要未點名但補審用）皆存在、落地。

## 數字獨立驗證（非信你摘要，自己 grep raw log 撈的）

```
[setup] T1(saved) benefactor=3 rep=0.8 | T3(neglected) benefactor=0 rep=0.15
[setup] T1 stay_benefit(pre-run)=0.4700  T3 stay_benefit(pre-run)=0.0225
[Diplomacy] Team3 背叛 Team2
```
逐字對上你附的數字，無出入。

## ★時點獨立驗證：真經 live cadence、非 TDD 殘留

`[Diplomacy] Team3 背叛 Team2` 前一行是 `[TickPerf] day=2...`，後一行 `[DayNight] Day 3 開始`——**betray 精準落在 day2/day3 交界（≈tick480-500）**，對上你附的 `BETRAY_CHECK_INTERVAL=500 ticks` cadence 首個評估窗。跟 specimen jsonl 的 T3 faction_id 翻轉窗口（tick500 仍=1、tick560 已=-1）互相對得上。**這確認是真經 tick loop cadence 觸發、非任何殘留 TDD 手呼痕跡**——你「in-situ 真 fire 層獨立驗證」的核心主張成立。

## ★motive→action→outcome：讀 specimen 挖到你摘要沒提的加分佐證

T3（neglected member）逐筆 intent 軌跡：
```
tick10-250:  日常/致富（正常經營）
tick310-500: 征服（why="野心/好戰驅動，belief 評 target2 可打贏"，threat_id=2 恆定、threat_react=0.73）
```
**T3 早在正式 betray（tick~500）前 190 個 tick 就已經對自己的領主（T2/target2）持續抱著「evaluate 可打贏」的征服意圖**——不是 betray 那一刻才翻臉，是野心(1.0)+力量優勢(pop20>pop5)+零 benefactor 記憶這組合，長期累積出的敵意態度，正式 betray 事件只是這個已成形態度在 cadence 窗口打開時的結案動作。

對照 T1（saved member）全 19 筆記錄：intent 恆為「致富」（建設/貿易導向），對自己領主（T0）的 `threat_id` 全程 `-1`（從未評估領主為威脅對象）。**同樣的野心=1.0 起始人格，因為有 benefactor 記憶 + 高 rep，從頭到尾沒有形成任何敵意軌跡**。

兩條線各自內部一致、彼此對照鮮明——這是 genuine bond counter 在跑，不是「決策贏了但沒人物設定支撐」的空殼故事。零手不聽腦跡象：util 算、決策依 util、betray 執行後 faction_id 真變、事件真 emit。

## 總結

CONFIRM。數字、時點、motive 軌跡三者independent 核過，皆與你的誠實淨判一致，且 specimen 本身提供了比聚合數字更強的佐證（T3 的持續征服意圖軌跡）。verdict ref 供 systems 組 cohesion 驗收包（③②①+g3）：**「g3 betrayal bond counter 經 in-situ live cadence 驗證通過，T1/T3 分化乾淨、motive 軌跡連貫，可信度高於純 TDD 驗證，予以採納」**。

---
*QA 驗收官 · 2026-08-05*
