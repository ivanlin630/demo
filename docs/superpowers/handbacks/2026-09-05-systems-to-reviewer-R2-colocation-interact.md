---
from: systems
to: reviewer
status: open
slice: colocation-interact（R² 審設計）
topic: ★形狀:保留移動觸發 + 補【駐留共位 pair 的週期機會】,而【不新增互動語意】—— 呼叫的是同一支 _try_interact,只新增進入它的路;★★兩個結構都現成:state.teams_by_tile(只取 size≥2)與 CadenceStagger(零 RNG 純函式);★★★而我不自己選的一格是【cadence 用哪個既有值】—— blueprint 說掛 T1/T2,而我不想新造常數,也沒把握哪個語意上對,交你判(同 cap 那票的做法)
---

# 審什麼
`docs/superpowers/specs/2026-09-05-colocation-interact-HOW.md`

# ★①請確認這個約束是對的（★我認為它是本設計最重要的一條）
```
★【不新增互動語意】:呼叫同一支 `_try_interact`,只新增【進入它的路】
⇒ ★★理由:新語意 = 新 bug 面;新入口 = 既有語意被套用到【本來就該套用的情境】
⇒ ★★★而驗收 #3 把它變成可驗的:diff 顯示 `_try_interact` 本體【未改】
```

# ★★②請判我不自己選的那一格：**cadence 用哪個既有值**
```
★blueprint 說「掛 T1/T2 cadence 經 CadenceStagger」,而我【不想新造常數】
⇒ ★★候選是沿用決策層既有的 social/interaction 類 cadence,而我【沒把握哪個語意上對】
⇒ ★★★而這裡的 cadence 【不是 perf 節流】,是【避免同格兩隊每 tick 互動一次＝洪水】
   ⇒ 所以它該對齊的是【一次社交互動的合理間隔】,不是【一次思考的間隔】—— 這兩者可能不同
```

# ③★三個坑我寫死了，請看有沒有漏
```
①★迭代順序:teams_by_tile 是 Dictionary ⇒ 必須用【排序鍵】迭代
   ⇒ ★★否則「誰先互動」隨字典順序漂 —— 而那是 fp 假紅與真行為漂移的老來源
②★★同 tick 去重:一個 pair 可能同 tick 既被 moved 觸發又被駐留觸發 ⇒ key 用 (min_id, max_id) 對稱
③★★★零 RNG:排程與列舉都不得耗 global RNG
```

# ④★而這一票會吃掉共位必見那票的 #3/#4
```
★#3(JOIN true<belief 下降)/#4(resolve>0)【移到本票】—— 因為它們需要【互動能發生】才可能綠
⇒ ★★而共位必見照它自己的驗收(#1 同格未偵測 880→0 等)收,已與 blueprint 對齊
⇒ ★★★這也是為什麼我把「驗收要對準【這一刀的因果範圍】」寫進帳:
   跨機制的 outcome 判準,會在另一個機制沒修時【必然不綠】,而那不代表這一刀無效
```
