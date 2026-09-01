---
status: R² CLEAN(2026-09-01 issues→②③已改)
owner: systems
slice: lod-production-neutrality
what: LOD 率等價原則（invariant）—— 世界的行為不得隨 LOD 改變
authority: blueprint GO 2026-09-01（intended-change 級已裁：接既有 teams_cadence 補償，驗收 far/near → ≈1.0）
---

# ★①病
```
sim_runner.gd:164  {"name":"manufacture", "lod": LOD_BOTH, "shape":"teams"}
  ★LOD_BOTH ⇒ far 隊也跑；★★shape "teams" ⇒ sim_runner.gd:199 `call(fn, state, teams)` 不傳 cadence
  ⇒ 每次呼叫產固定量，間隔變長【不補回】
實測：far/near ≈ 0.47~0.53（★不是我推導的 1/10 —— ★★量級我認錯，方向仍違規）
★★★confound 誠實標：near 1 隊 vs far 9 隊，population 分岔未完全排除
```
★**而 confound 不擋修**：★★率等價是 invariant ⇒ **方向本身就是違規**；
★★★**修法不依賴量級**（接既有機制、零發明）⇒ **不需要先知道差多少，才知道該不該補回。**

# ★★②修法：接既有 `teams_cadence`（★零發明）
```
①sim_runner.gd:164  shape "teams" → "teams_cadence"
   ⇒ 呼叫變成 `call(fn, state, teams, cadence)`（:200）
②manufacturing_system.gd:97  tick_all(state, team_ids) → tick_all(state, team_ids, cadence)
③★對照組（同一張 registry，四個系統已在用）：collect / consumption / fatigue / reactions
   ⇒ ★★【照它們的既有形狀做，不要發明新的補償方式】
```

# ★★★③核心風險（★這是本票最容易做錯的地方，先寫死）
> **製造是【離散】的：產一件要吃材料。而補償有兩種形狀，選錯會壞。**
```
形狀A【迴圈式】：跑 N 次（N = cadence 比），每次照常檢查材料 ⇒ ★材料不夠就自然停
   ⇒ reactions 用的就是這型（sim_runner.gd:515-517 明寫「far pass 用 trials 補回被跳過的窗次」）
形狀B【倍率式】：一次產出 ×N ⇒ ★★★可能出現「一次產 10 件而材料只夠 1 件」
   —— 或反過來,把材料檢查也 ×N 而變成【要一次湊齊 10 份材料才能產】,那是新的行為
```
## ★★★裁定（R² 2026-09-01 查出實況後改）：**形狀 A 迴圈式，照 `reactions`**
```
★四個系統【本身就不一致】,3:1：
   collect / consumption / fatigue ＝ ★倍率式
   reactions                        ＝ ★★迴圈式
⇒ ★★★所以我原本寫的「照同族做」【沒有指向】—— 那是我沒查就寫的指示,已作廢
```
★**指定 A（迴圈式，照 `reactions`）**，★★**理由是【性質】不是【多數】**：
> **manufacturing 是離散的（產一件吃一份材料）—— 而倍率式的三個都是連續量**
> （採集量／消耗量／疲勞值：×N 有意義，且不存在「湊不齊一份」的問題）。
★★★**照多數派會選到倍率式，而那正好是錯的那一個。**

# ★④估算端與自述【同批改】（★否則下一次又有人照它銷案）
```
manufacturing_system.gd:78-81 註解自述「★一天跑幾次：產線在 NEAR pass ⇒ TICKS_PER_DAY / NEAR_CADENCE」
⇒ ★那句話是【假的】,而病4 當初就是因為它被標成 healed 銷案
⇒ ★★改 code 的同批把它改對,並補上 outpost_tick 那種【假設告警】：
   若 registry 上 manufacture 的 lod/shape 不再是預期值 ⇒ Probe 記一筆
   （★★★對照：outpost_system.gd 有 `_outpost_tick_runs_in_near_pass()` 告警，manufacturing 沒有
     ⇒ 所以它的假設壞了也不會叫）
★runs_per_day() 那個估算端也要跟著對（它現在對 far 隊高估）
```

# ★★⑤驗收（★每條寫下【怎麼會失敗】）
```
①★far/near → ≈1.0（blueprint 定）★★而要同時報 raw 與 per-team（判準⑧：分母動 >5% 雙軌並報）
   ★★★上一輪的 confound（near 1 隊 / far 9 隊）要嘛消除、要嘛照樣標記 —— 不得靜默
②★陽性對照：把補償拿掉再跑 ⇒ 必須回到 ≈0.5（★★失敗長相＝拿掉也 1.0 ⇒ 補償根本沒生效）
③★★★【原「材料守恆比值不變」作廢】—— R² 讀 code 證實 output 與 material 是**同一行同一個 q** 算的
   ⇒ ★結構上保證比值不變 ⇒ ★★恆真 ⇒ 跟修法對不對無關
   ★★★改成有偵測力的那條：**材料受限情境下，far 隊必須出現【部分產出】**
```
形狀A（迴圈式）：材料不夠時逐次停 ⇒ 單次窗產出落在 0 < q < N 的【連續】範圍
形狀B（門檻式）：要湊齊 N 份才動 ⇒ ★產出只會是 {0, N} 的【雙峰】
⇒ 驗收：far 隊出現 0 < q < N 的次數【必須 > 0】
★失敗長相＝只有 0 與 N ⇒ 門檻抬高了，材料緊時整個停產（而 near 隊照樣涓滴生產）
```
④★fp：★★這是 intended-change ⇒ fp【會變】,而變了不是失敗 —— 但要標注
⑤★假設告警：把 registry 的 lod 改掉 ⇒ 告警必須 fire（★★否則那顆告警是裝飾）
```

# ★⑥不做
```
★不動其他系統的 shape（★★若發現別的系統也有同病，【列出來】不順手改 —— 那是型③的下一輪）
★★不解上一輪的 population confound（修完後 far/near→1.0 本身就是答案）
```
