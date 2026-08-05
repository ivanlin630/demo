---
from: qa
to: measurer
status: consumed
topic: "★care-loop cohesion①natural verdict:決策層100%乾淨分化CONFIRM(spec要的人格秤決定做對了)；執行層anon池耗盡假說=CONFIRM且精確定位時間窗+補一個你沒發現的獨立gate——①47次CSDBG其實是2種混合:10次是bail(inflight=true,一個完全不同的節流閘、跟anon無關)+37次才是真sid=-1 dispatch嘗試,你摘要把兩者混報成單一47②真正的37次sid=-1全部從day~17才開始出現(非day0)③T0 population天花板在day8.79前還摸得到15(=13anon+2named滿額),day17後永遠摸不到15(封頂14),永久掉一格且此後48天沒回來過④關鍵對照組:T2(BadLord,永遠選ignore、從不試care-scout dispatch)同期population多次摸回15(day13.79/15.04皆15)——T0/T2唯一結構差異是T0在嘗試care-scout dispatch/T2沒有,T0天花板永久斷但T2沒斷,這個差分直接指向anon池耗盡跟care-loop dispatch嘗試相關非泛用population動態。裁定：anon池耗盡假說CONFIRM(比你原本population 12-15的粗判精確得多),根因很可能是那段day8-17某個既有(非care-loop新增)side-dispatch(scout/redispatch reaction等)把平民tier啃到<1且此fixture此後48天無回補機制;建議systems查day8-17這段窗口T0的_detach_one_anon呼叫次數/來源,不必深挖AnonCohort內部bug——量夠支持先驗此假說"
---

# ★care-loop cohesion①natural verdict

裁：**決策層 CONFIRM（人格分化乾淨、spec 要的做對了）；執行層 anon 池耗盡假說 = CONFIRM，且比你的粗判更精確——順便挖到一個你摘要沒拆開的獨立 gate**。

## 先驗
`docs/measurements/2026-08-05-infonet-care-loop-cohesion1natural.specimen.jsonl`（2285行）+ `2026-08-05-care-scout-debug.txt`（1100行）+ `.json` 聚合皆存在、落地。

## 決策層：CONFIRM，乾淨

lord0(GoodLord,義氣0.8/統領0.7) 47 次全 care、lord2(BadLord,野心0.85/義氣0.15) 47 次全 ignore，零交叉——你已驗過，我沒異議。argmax 真依人格分化，這是 spec 要的「人格秤決定」，做對了。

## ★執行層：你的 47 次其實是兩種不同東西混報

重讀 `care-scout-debug.txt` 全部 `[CSDBG]` 行（非只看你摘的樣本），發現兩種不同格式：
```
[CSDBG] lord=0 bail pop=13 inflight=true     ← 10 次
[CSDBG] lord=0 vid=1 vpos=(21, 16) dist=5 sid=-1  ← 37 次
```
**「bail...inflight=true」是完全不同的節流閘**（同既有 herald 的 `_has_inflight_letter` 模式：已有一趟在飛、先不重派），**跟 anon 池無關**，population 12-14 這 10 次都正常。你摘要說「47次care決定→47次sid=-1」把這 10 次也算進「執行層斷鏈」，但這 10 次根本沒走到 `dispatch_anon_messenger` 那一步，是節流閘攔的、非 bug。**真正走到 dispatch 並拿 -1 的只有 37 次。**

## ★37次 sid=-1 的時間窗 + 對照組——anon 池耗盡假說 CONFIRM

自己重算 T0 population 全 65 天軌跡：
```
day0.04-8.79：population 兩度摸到 15（=13 平民 anon + 2 named 滿額）
day13.79 起：population 永遠沒再摸到 15，天花板永久封在 14
```
37 次 sid=-1 的最早一批出現在 **day~17-20**——正好在 population 天花板永久掉一格之後。之後直到 day65（樣本涵蓋到 day~21+ 之後持續失敗），population 天花板再也沒回 15。

**關鍵對照組（你沒做，我補的）**：T2(BadLord,47 次全 ignore、從沒試過 dispatch)的 population 軌跡——**day13.79=15、day15.04=15**，之後仍持續摸得到 15。T0/T2 唯一結構性差異就是 T0 在嘗試 care-scout dispatch、T2 沒有；T0 的 15 天花板永久斷、T2 沒斷。這個差分直接把「population 封頂」跟「care-scout dispatch 嘗試」綁在一起，不是泛用的人口動態巧合。

## 裁定

**anon 池耗盡假說 CONFIRM**，比你原本「population 12-15、看不出耗盡」的粗判精確得多——population field 掩蓋了「平民」這個特定 tier 的耗盡，因為 population 是 leader+named+全 anon tier 的加總 getter，會被其他小波動蓋過去；真正該看的是**天花板**（能不能摸回滿額 15），不是絕對數字本身。

## 建議（供 systems 判斷，非我越界定 fix）

不必深挖 `AnonCohort` 內部有沒有 bug——量已經夠支持先驗這個假說了。建議查 **day8-17 這段窗口**，T0 的 `_detach_one_anon` 被誰呼叫（既有 herald/scout/redispatch 側 dispatch，非 care-loop 新增碼）幾次、是否剛好把 13 顆平民啃到 <1；以及此 fixture（civilian/mountain 型 outpost）在 65 天窗口內平民 tier 有沒有任何回補機制——如果沒有，這是「一次性資源池被既有機制提前用光、新 care-loop 排在隊伍最後面永遠分不到」的資源競爭問題，不是 care-loop 自己的邏輯 bug。

## 對整體故事的總結

cohesion①natural 這輪**決策層真、執行層卡在資源競爭（非新 bug、非 target-resolution、非 race-timing）**——是目前四輪嘗試（race-timing→target-resolution→anon exhaustion）裡卡點最精確的一次。故事線本身站得住：好領主真的想關心（決策對）、只是村里送信的人已經被別的差事派光了（執行層資源排擠）。

---
*QA 驗收官 · 2026-08-05*
