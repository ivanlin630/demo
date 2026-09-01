---
from: systems
to: implementer
status: open
slice: lod-production-neutrality
tier: infra
topic: ★R² CLEAN(②③已改)⇒ 動工;★★★而 R² 查出【四系統本身就不一致 3:1】(collect/consumption/fatigue 倍率式、reactions 迴圈式)⇒ 我原本寫的「照同族做」沒有指向,已作廢;★★改成明確指定【形狀 A 迴圈式,照 reactions】,理由是【性質】不是【多數】——照多數派會選到倍率式,而那正好是錯的那一個
---

# ★①修什麼
```
①sim_runner.gd:164   shape "teams" → "teams_cadence"（⇒ :200 變成 call(fn, state, teams, cadence)）
②manufacturing_system.gd:97  tick_all(state, team_ids) → tick_all(state, team_ids, cadence)
③★補償形狀 ＝ 【A 迴圈式，照 reactions】（sim_runner.gd:515-517 那型）
```
## ★★為什麼不是多數派
```
collect / consumption / fatigue ＝ 倍率式（★它們是【連續量】：×N 有意義，不存在「湊不齊一份」）
reactions                        ＝ 迴圈式
★★★而 manufacturing 是【離散】的：產一件吃一份材料
⇒ 倍率式會變成「要一次湊齊 N 份材料才能產」＝【門檻抬高】＝一個新的行為
```
★**這一條是 R² 幫我查出來的** —— ★★**我原本寫「照同族做」，而同族本身就分兩派。**

# ★★②估算端與自述【同批改】（★否則下一次又有人照它銷案）
```
manufacturing_system.gd:78-81 自述「產線在 NEAR pass ⇒ 24 次/日」⇒ ★那句是假的
   ⇒ 病4 當初就是因為它被標成 healed 銷案
★★同批補【假設告警】：對照 outpost_system 有 _outpost_tick_runs_in_near_pass()，manufacturing 沒有
   ⇒ ★★★所以它的假設壞了也不會叫
★runs_per_day() 也要跟著對（它現在對 far 隊高估）
```

# ★★★③驗收（★③換掉了，原來那條是恆真的）
```
①★far/near → ≈1.0，★★raw + per-team 雙軌並報（判準⑧）
   ★★★上一輪的 confound（near 1 隊 / far 9 隊）要嘛消除、要嘛照樣標記——不得靜默
②★陽性對照：把補償拿掉再跑 ⇒ 必須回到 ≈0.5（失敗長相＝拿掉也 1.0 ⇒ 補償沒生效）
③★★★【新】材料受限下 far 隊必須出現【部分產出】0 < q < N，次數 > 0
   ★失敗長相＝只有 {0, N} 雙峰 ⇒ 門檻抬高了，材料緊時整個停產
   （★原條「材料消耗÷產出 比值不變」作廢：R² 讀 code 證實兩者同一行同一個 q ⇒ 結構上恆真）
④★fp【會變】，而變了不是失敗（intended-change），但要標注
⑤★假設告警：把 registry 的 lod 改掉 ⇒ 告警必須 fire（否則那顆告警是裝飾）
```

# ★④不做
```
★不動其他系統的 shape ——★★若發現別的系統也有同病,【列出來】不順手改（型③的下一輪）
★★不解上一輪的 population confound（修完後 far/near→1.0 本身就是答案）
```
