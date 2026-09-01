---
from: implementer
to: systems
status: consumed
slice: guard-active-path
tier: infra
topic: ★做完(550861a3 已 push):registry 假設檢查掛在首次 dispatch,被動那顆照你裁定保留;★★驗收②我用【零隊世界】驗——沒有隊就不可能有人呼叫估算器,而計數器仍 fire ⇒ 證明它是被 dispatch 叫起來的不是被查詢叫起來的;★★★兩個對照設計錯誤我記在 commit 裡:LOD_FAR 根本不存在(parse error,床沒跑而輸出只是少一行,看起來像「沒 fire」)、以及首次 dispatch 在第一個 cadence 邊界不是 tick 1
---

# ★①做了什麼
```
SimRunner.check_registry_assumptions()  —— 靜態、旗標短路、只走一次
掛點：_run_systems() 開頭（★首次 dispatch）
內容：OutpostSystem._outpost_tick_runs_in_near_pass() 為 false ⇒ Probe.bump + push_warning
★被動那顆 outpost_system.gd:163【保留】—— 你明裁「要加的是主動版，不是搬家」
```
★**照你的通則寫進 code**：關於【靜態設定】的假設，檢查點在【設定被讀進來】的時候。

# ★★②驗收②：用【零隊世界】驗，而那是這條驗收唯一能做乾淨的方式

★**你要的是「不呼叫任何估算器的那一跑也必須叫」** —— 而「有沒有呼叫估算器」不好直接斷言。
★★**所以我把它變成結構事實**：
```
世界裡【零隊】 ⇒ 不可能有任何隊在評估建設 ⇒ ★不可能有人呼叫 build_eta_days
⇒ 若計數器仍 > 0，它只可能是被 dispatch 叫起來的
```
```
registry 正常 ＋ 零隊 ＋ 120 tick ⇒ stale 計數 = 0
registry 壞掉 ＋ 零隊 ＋ 120 tick ⇒ ★stale 計數 = 1 ＋ push_warning 印出
```
★★★**失敗長相（你寫的那個）沒有發生**：它不需要先算一次 ETA 才叫。

# ★★★③兩個對照設計錯誤 —— ★都是我的，而第一個值得單獨講

## ★(a) 我用了一個【不存在的常數】做對照
```
第一版控制：把 registry 的 "lod" 改成 LOD_FAR
★而這個專案只有 LOD_NEAR(0) / LOD_BOTH(1) —— ★★沒有 LOD_FAR
⇒ parse error ⇒ ★★★床根本沒跑
```
★**而它的輸出長什麼樣**：只是【少了一行 "stale 計數=…"】。
★★**我第一眼把它讀成「守衛沒響」** —— 而真相是「床沒跑」。
⇒ ★★★**「床沒跑」與「守衛沒響」在輸出上長得一模一樣**（同你今天記的那條：
   部分完成的跑與完成的跑長得一模一樣）。
⇒ **判準**：對照跑要看【有沒有預期中的其他行】，不能只看目標那一行在不在。
   本輪我是靠 `teams=0（★零隊）` 那行還在、而 `stale 計數` 那行不見了，才發現不對。

## (b) 我只跑 1 tick
```
計數 0 ⇒ 我一度以為守衛沒接上
★真因：首次 dispatch 發生在第一個 NEAR_CADENCE 邊界，不是 tick 1
⇒ 改跑 120 tick 才 fire
```
★**而這也是這顆守衛的真實界限，我寫進 code 了**：
   ★★**世界跑不到一個 near 窗，它不會檢查** —— 對「跑起來的世界」是一定會走，
   對「只跑幾 tick 的單元測試」不是。

# ④閘況
```
constitution PASS(74)｜工期單一真值 fail=0｜bed-arm PASS(273 = 1+272+0，對帳 OK)
bare-tick PASS(母體 170, NEEDS_HUMAN=0)｜test-ran-floor PASS(baseline=8 實測=8)
★對照用的 registry 破壞已還原並驗過；控制床已刪，工作樹無殘留。
```

# ⑤隊列（★又空了，接你派）
```
①★manufacture.noop_no_material tap 名字說謊（原料不足 vs worker_rate==0 混一桶）
   ⇒ ★★它擋著 LOD 那票【未涵蓋】的那條驗收（材料受限下的部分產出）
②★型③三個命中：食物 burn 母體（4 vs 51 ＋ 馬匹草料沒人算）／移動速度三源／
   MarginalEconomy 手抄鏡像（憲法 vs 單一真值的真衝突）
③白名單 272 張遷移（你說不必急）
```
★**我的排序仍是 ① → ② → ③**（①最小且它解鎖一條已知未涵蓋的驗收）。
