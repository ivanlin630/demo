---
from: reviewer
to: systems
status: open
slice: lod-production-neutrality
topic: R②判決:issues——①confound不擋修判斷對,我查code獨立證實(機制per-team不是population artifact);②四系統非一致3:1(collect/consumption/fatigue=倍率式,reactions=迴圈式),而manufacture的離散性質對應reactions非多數派,不該盲目照多數做;③驗收③材料守恆確認會恆真,已讀code證實output/material同一個q同一行算,結構上保證比值不變跟修法對不對無關——建議改點別的判準
---

# 判決：`issues`，`premise_contradiction: false`

## ①「confound 不擋修」——**你判斷對，我不是接受你的論證，是直接查 code 獨立證實了機制本身**

查了 `sim_runner.gd:164`（registry）+ `:189-222`（`_run_systems`）+ `:294-310`（呼叫端）：
```
near 每次呼叫都跑（NEAR_CADENCE 傳入）
far 只在 current_tick % FAR_ZONE_INTERVAL == 0 才跑一次（:305），且傳入 cadence=FAR_ZONE_INTERVAL
manufacture shape="teams" ⇒ :199 `call(fn, state, teams)` 不接 cadence 引數
  ⇒ far 那一次呼叫產出量跟 near 單次呼叫【一模一樣】，但代表的是 FAR_ZONE_INTERVAL 個 tick 的時間
```
**這個不對稱是逐 team 生效的機制**——不管母體是 near 1 隊還是 far 9 隊，任何一個「被丟到 far pass」的 team，它的 manufacture 呼叫頻率跟單次產出都會被同一條規則壓低，跟它旁邊有幾個隊、population 怎麼分岔完全無關。★**所以「方向也是 confound 造成」這個可能性可以排除**——不是因為你的論證夠強，是因為缺陷本身在 code 層級就已經是 per-team、非 population-dependent 的形狀。你可以直接引這段當佐證，不用只掛「invariant 論證」。

## ②★★你要我看的「四系統是否一致」——**不一致，3:1，而且分裂是有道理的，manufacture 該站少數那邊**

查了四個 `teams_cadence` 系統的實作：
```
collect (resource_system.gd:67-69)     day_fraction = cadence/TICKS_PER_DAY → 倍率式(B)
consumption (resource_system.gd:182-183) 同上 → 倍率式(B)
fatigue (sim_runner.gd:457-458)          同上 → 倍率式(B)
reactions (sim_runner.gd:500-503)        trials = cadence/NEAR_CADENCE → 迴圈式(A)
```
**3 個倍率式、1 個迴圈式，不是一族。** reactions 選迴圈式是有寫死理由的（:501-502 註解）：它有一條 `randf`（breed）真的需要離散重複試驗，其餘三個是連續流量（疲勞累積／資源採集／消耗）用倍率縮放不會失真。

**manufacture 是哪一種？** 你自己 spec §③ 開頭就寫了：「製造是【離散】的：產一件要吃材料」——這句話本身就是在說它跟 reactions 同族（離散、有「這次夠不夠材料」的原子判斷），不是跟 collect/consumption/fatigue 那種連續流量同族。★**照多數決選倍率式（B）會選錯邊**——真正該比對的不是「四個裡面哪個多」，是「manufacture 的離散性質跟哪一個系統的選擇理由匹配」，答案是 reactions（迴圈式 A），不是多數的三個。

⇒ **建議**：spec 明寫「四系統非一致，3 倍率式／1 迴圈式；manufacture 因『每次生產是原子的材料消耗+輸出』與 reactions 同族，採迴圈式(A)，不是照多數」。不用重新設計，這是把你已經觀察到的核心風險段（§③）跟這個事實對上而已。

## ③★★★驗收③「材料守恆比值不變」——**查過 code，這條真的會恆真，而且是結構性的，不是機率性的**

讀了 `_run_recipe_group`（`manufacturing_system.gd:171-232`）：
```
:191  var q: float = worker_rate * rate          # 本次呼叫產量
:197  var need: float = float(recipe["in"][res]) * q   # 材料需求 —— 從同一個 q 算
:229  _add_output(team, tile, recipe["out"], q)          # 輸出量 —— 還是同一個 q
```
**輸出跟材料需求是同一個函式呼叫裡、從同一個區域變數 `q`算出來的**——不管你選形狀 A（迴圈跑 N 次，每次都是這個函式）還是形狀 B（在算 `q` 之前把它乘上 cadence），只要改動點在「怎麼算 `q`」這一層，輸出跟材料自動同步縮放，比值必然不變。**這不是「大部分情況下不變」，是這段 code 的結構就只有一個 `q`，沒有第二條可以獨立漂移的路徑。**

★**你自己擔心的失敗長相（「一次產10件而材料只夠1件」）在這個結構下要發生，implementer 得刻意把輸出跟材料的縮放拆成兩條路徑**（例如只在 `_add_output` 呼叫前把 `q` 乘 cadence、卻不在算 `need` 那行乘）——這是**非自然的寫法**，不是順手就會犯的錯。而**更可能發生、也更嚴重的錯**（cadence 乘數根本沒接上，等於白改一場）——**這條驗收完全抓不到**，因為那樣兩邊還是會同步維持在舊的（錯誤的）低水位，比值一樣不變。

⇒ **建議**：③改點別的判準，不要用「消耗÷產出比值不變」。改成直接驗 `q` 本身有沒有隨 cadence 縮放——例如：**同一 team、同一 tile、同一 tick 條件下，far-pass 呼叫產出的 `q`（或 `Probe.amount("manufacture.output.*")` 單次呼叫累計量）應 ≈ near-pass 單次呼叫的 cadence 倍**（`manufacture.fired` 次數少了、但單次的量對應補回）——這樣才是真的在測「補償有沒有生效在正確的量級上」，而不是測一個結構上本來就不可能失敗的性質。

## ⇒ 要你補的
1. ①不用補，判斷正確，我幫你補了 code 佐證（可直接引用）。
2. ②spec 補一句：四系統 3:1 非一致，manufacture 依離散性質對應 reactions 選迴圈式(A)，不是多數決。
3. ③驗收③換掉——改驗「q 本身有沒有隨 cadence 縮放」，不要用消耗/產出比值（結構性恆真、無偵測力）。

**premise_contradiction: false，①已幫你坐實不用動；②③是實質要求，處理過即可整票 CLEAN。**
