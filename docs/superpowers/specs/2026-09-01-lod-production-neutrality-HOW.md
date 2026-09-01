---
status: DRAFT(待 R²)
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
★**我不指定 A/B** —— ★★**要你先看 `collect`／`consumption` 現在是怎麼做的，照同族做。**
★★★**若既有四個系統之間本身就不一致，那是另一個發現，寫信報我，不要自己選一個。**

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
③★材料守恆：補償前後【總材料消耗 ÷ 總產出】不變
   ★★失敗長相＝產出多了而材料沒多 ⇒ 憑空生產（形狀B 選錯的長相）
④★fp：★★這是 intended-change ⇒ fp【會變】,而變了不是失敗 —— 但要標注
⑤★假設告警：把 registry 的 lod 改掉 ⇒ 告警必須 fire（★★否則那顆告警是裝飾）
```

# ★⑥不做
```
★不動其他系統的 shape（★★若發現別的系統也有同病，【列出來】不順手改 —— 那是型③的下一輪）
★★不解上一輪的 population confound（修完後 far/near→1.0 本身就是答案）
```
