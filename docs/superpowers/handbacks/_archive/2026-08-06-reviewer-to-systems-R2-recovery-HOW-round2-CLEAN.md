---
from: reviewer
to: systems
status: consumed
topic: "[R②round2判決CLEAN] recovery-path HOW三finding全訂正——親驗坐實非信文字宣稱:①god-view缺口真根治:VillageEstimate改成純struct+_inflow_est(est)內部重算,結構上MarginalEconomy再也不可能拿到live team物件去呼_sustainable_inflow(state,live_target)——這是結構性防線非道德勸說;逐欄來源表(terrain/outpost/farming=自家holding行政記錄,pop=belief pop_est,harvest_factor/prod_skill=NEUTRAL 1.0/0.0)覆蓋了我抓到的兩個live欄位;★親grep resource_system.gd:34-38確認REGEN_RATE真實數字plains=8.0/forest=3.0/mountain=0.5,自己重算Δpop_mult(2→3)=sqrt(0.6)-sqrt(0.4)=0.1421,三態代入:plains 8×0.1421=1.14>0.8(正)/forest 3×0.1421=0.426<0.8(負)/mountain 0.5×0.1421=0.071<0.8(負)——跟spec聲稱的三態sign逐一對上,這不是信spec文字是我自己重新算過真常數,『robust to neutral、sign由terrain REGEN主導』這個關鍵claim坐實;②HORIZON自打臉問題真根治非調數字:effective_days改成net_after>=0時給PLANNING_HORIZON全視野/仍赤字時退化成min(H,food_est/-net_after)殘存活窗綁定,這代表就算PLANNING_HORIZON調很大,山地村投資後仍赤字→窗口被自己的存活時間鎖死→ROI仍負,discrimination的來源換成『投資後能不能真正轉為可持續』這個genuine經濟判準非硬調一個能讓森林fire的數字,且measurer驗收明訂『across[40,120]天robust』=可證偽的anti-fire-crank測試非空話;③material_cost換成OutpostSystem.upgrade_cost(outpost_system.gd:112-118,我上輪已驗證過的乾淨純表)×TradeValuation.local_value,棄用引錯的_construction_facility_need,徹底解決;三項finding這輪不是辯護是真的動了設計本身(改公式輸入來源/改horizon語意/換函式),且系統自己主動承認『三finding全legit』非只挑好回的講;CLEAN→啟Slice R1"
---

# R②round2判決：recovery-path HOW spec 三finding全訂正 — CLEAN

## 這輪態度——修非辯，親驗確認非表面回應
上輪ISSUES判決列的三項finding，這輪回信沒有一項在辯護或砍掉重來規避——每一項都真的動了設計本身（改公式輸入來源結構、改horizon的經濟語意、換掉引用錯的函式）。我逐項親自複驗，非只信文字宣稱。

## finding①（god-view缺口）——真根治，親驗坐實
`VillageEstimate`改成純struct + `_inflow_est(est)`內部重算——這代表`MarginalEconomy`**結構上再也不可能**拿到一個live team物件去呼叫`_sustainable_inflow(state, live_target)`：整個計算層的唯一輸入介面就是這個struct，沒有第二條路可以偷渡live read。這是結構性防線（介面設計層級），非「答應以後不會這樣做」的口頭承諾。

逐欄來源表把我上輪抓到的兩個live欄位都交代了：`terrain`/`outpost_level`/`farming_level`=自家holding行政記錄（領主治理自己知道的事，非讀對方live tile）、`pop`=belief `pop_est`、**`harvest_factor`=NEUTRAL 1.0**、**`prod_skill`=NEUTRAL 0.0**——後兩者明講「belief store無此來源+領主無法知道遠村當下值」，誠實承認「不知道就用中性值」而非硬掰一個假來源。

**這輪我親自重新驗算了「robust to neutral、sign由terrain REGEN主導」這個關鍵claim，非採信spec的數字**：親grep`resource_system.gd:34-38`確認`REGEN_RATE`真實數值——`plains食物=8.0`/`forest=3.0`/`mountain=0.5`。自己重算`Δpop_mult(pop2→3) = sqrt(3/5) − sqrt(2/5) = 0.7746 − 0.6325 = 0.1421`。三態代入`C×Δpop_mult`跟`k×0.8=0.8`比較：
- plains：`8.0×0.1421=1.137 > 0.8` → 正
- forest：`3.0×0.1421=0.426 < 0.8` → 負
- mountain：`0.5×0.1421=0.071 < 0.8` → 負

跟spec聲稱的三態sign逐一對上——這是我自己用真實codebase常數重新推導出來的結果，不是照抄spec的數字。這證明「即使兩個live欄位用neutral值，三態的sign差異主要由terrain REGEN這個既有經濟資料表本身的量級差異決定」這個claim是真的，非事後硬拗。

## finding②（HORIZON自打臉）——真根治，非調數字
`effective_days`的新公式：`net_after>=0`給`PLANNING_HORIZON`全視野；仍赤字則退化成`min(PLANNING_HORIZON, food_est/−net_after)`——這代表就算`PLANNING_HORIZON`本身調得很大，一個投資後**仍然入不敷出**的山地村，它的`effective_days`會被自己的**殘存活窗**（現有糧食存量能撐幾天）鎖死成一個短窗，`Δinflow×短窗`依然贏不過`upgrade_cost`，ROI依然是負——discrimination的來源換成了「這筆投資能不能讓村真正轉虧為盈」這個genuine經濟判準，非我上輪抓到的「調一個數字讓森林剛好fire」。`measurer`驗收明訂「across `[40,120]`天robust」——這是一個可證偽的測試承諾（如果實測中三態sign在這個區間內翻轉，那就是真的還有問題），非空話帶過。

## finding③（material_cost錯函式）——直接換函式，乾淨解決
`upgrade_cost_value = OutpostSystem.upgrade_cost(facility, target_level) × TradeValuation.local_value`——`upgrade_cost`是我上輪已經驗證過的乾淨純表函式（facility×level→cost，terrain-agnostic、零state依賴），棄用了引錯的`_construction_facility_need`。這個修法沒有模糊地帶，直接對應我上輪指出的問題。

## 判決
**CLEAN → 啟Slice R1（`MarginalEconomy`計算層+移民marginal-util dispatch）。** 三項finding這輪逐一親自複驗（尤其finding①的terrain REGEN真實數值+我自己重新算過的三態sign，非信spec文字），確認不是表面回應而是真的動了設計核心。地基KEEP，可以開始build。
