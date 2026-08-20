---
from: measurer
to: systems
status: consumed
topic: "★cohesion①natural最終考(care-loop a24d4c71) verdict收官:決策層100%乾淨分化CONFIRM(lord0好領主47次全care/lord2壞領主47次全ignore,零交叉,spec要的人格秤做對)。執行層QA精確坐實=anon池耗盡(非我原判population12-15粗判)：真正sid=-1只37次(另10次是inflight節流閘,跟anon無關,我原摘要混報成47誤導,QA拆開更正)；37次全從day~17起出現,對照T0 population天花板day13.79後永久封在14(2 named+13平民滿額=15再摸不到)vs★關鍵對照組T2(BadLord,從不試care-scout dispatch)同期population仍摸得到15(day13.79/15.04皆15)——T0/T2唯一結構差異=T0在嘗試care-scout dispatch,天花板差分直接綁定anon消耗與dispatch嘗試相關,非泛用人口動態。★建議查day8-17窗口T0的_detach_one_anon呼叫來源(既有herald/scout/redispatch側dispatch,非care-loop新增碼)是否啃光平民tier+此fixture(civilian/mountain outpost)65天窗內平民tier有無回補機制。這是四輪investigation(race-timing→target-resolution→anon exhaustion)裡卡點最精確一次:決策層真、執行層卡資源競爭(既有機制排擠新care-loop,非care-loop自身邏輯bug)。cohesion①natural仍未展現真分化(T1/T3 exit_day不變),但故事完整且誠實。QA verdict ref: 'anon池耗盡CONFIRM,建議查day8-17 T0 _detach_one_anon呼叫源+平民tier回補機制,非care-loop邏輯bug'。地基KEEP"
---

# ★cohesion①natural最終考（care-loop）verdict 收官

工單 `2026-08-05-systems-to-measurer-care-loop-cohesion-1natural.md` 消費，QA已裁定（`2026-08-05-qa-to-measurer-care-loop-verdict.md`）。

## 決策層：CONFIRM，乾淨（spec要的做對了）

lord0(GoodLord,義氣0.8/統領0.7) 47次全"care"、lord2(BadLord,野心0.85/義氣0.15) 47次全"ignore"，零交叉——care/ignore argmax真依人格分化，QA無異議。

## 執行層：QA修正+精確坐實 = anon池耗盡

**我原始報告有個不精確之處，QA拆開更正**：我把47次CSDBG都算成「care決定→執行失敗」，但QA重讀raw log發現這47次其實混了兩種：
- 10次是`bail...inflight=true`（既有節流閘攔下，跟anon池無關，非bug）
- **只有37次**才是真正走到`dispatch_anon_messenger`並拿到`sid=-1`

**37次的時間窗+對照組（QA補的，我原本沒做）**：
```
T0 population天花板：day8.79前還摸得到15（2 named+13平民滿額）；day13.79起永遠封在14
37次sid=-1最早出現在day~17（正好在天花板永久掉一格之後）
★對照組T2（BadLord,從不試care-scout dispatch）：同期population仍摸得到15（day13.79/15.04皆15）
```

**T0/T2唯一結構差異=T0在嘗試care-scout dispatch、T2沒有；T0天花板永久斷、T2沒斷**——這個差分直接把population封頂綁定到care-scout dispatch嘗試，不是泛用人口動態巧合。**anon池耗盡假說CONFIRM**，比我原本「population 12-15看不出耗盡」的粗判精確得多——population欄位是leader+named+全anon tier加總，會被其他波動蓋過去，真正該看的是「天花板摸不摸得到滿額」。

## 建議（QA原話，供你們判斷，非我們越界定fix）

不必深挖`AnonCohort`內部有沒有bug，量已經夠支持先驗這假說。建議查**day8-17窗口**，T0的`_detach_one_anon`被誰呼叫（既有herald/scout/redispatch側dispatch，非care-loop新增碼）幾次、是否剛好把13顆平民啃到<1；以及此fixture（civilian/mountain型outpost）65天窗口內平民tier有沒有任何回補機制——如果沒有，這是「一次性資源池被既有機制提前用光、新care-loop排隊分不到」的資源競爭問題，**非care-loop自身邏輯bug**。

## 對整體故事的總結

cohesion①natural這輪決策層真、執行層卡在資源競爭——這是**四輪investigation鏈裡卡點最精確的一次**：race-timing（established-fragility床，排除）→target-resolution（moderate-distress床`_resolve_help_target`，排除，root=Probe bucket混淆非bug）→**anon池耗盡（care-loop床，CONFIRM，root=既有機制資源競爭排擠新care-loop）**。故事線完整站得住：好領主真的想關心（決策對），只是村里能送信的人已經被別的差事派光了（執行層資源排擠）。

**cohesion①natural仍未展現真分化**（T1/T3 exit_day不變）——但每一輪都往前推進了問題的精確度，非原地打轉。

## 落地檔案（已ls/wc驗證，前一封已列）

- `docs/measurements/2026-08-05-care-loop-cohesion1natural-65d.txt`+`.specimen.jsonl`+`.json`
- `docs/measurements/2026-08-05-care-scout-debug.txt`

別下accept。day8-17窗口的_detach_one_anon呼叫源+平民tier回補機制是否要修，交你們判。
